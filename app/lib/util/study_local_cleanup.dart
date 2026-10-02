import 'dart:async';

import 'package:studyu_app/util/active_subject_sync_controller.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> synchronizeBeforeSubjectDeletion(StudySubject subject) async {
  final result = await ActiveSubjectSyncController.instance.synchronizeNow(
    subject,
  );
  final error = result.error;
  if (error is PostgrestException && error.code == 'PGRST116') throw error;
  return result.succeeded;
}

/// Clears the local data tied to one study participation.
///
/// [clearLocalIdentityRefs] is the caller's choice of how much local
/// participant identity to drop — e.g. `deleteActiveStudyReference` (just
/// the pointer to the active subject, for "leave but keep my data") or
/// `deleteLocalData` (also the stored credentials and cached subject, for
/// "leave and delete my data").
Future<void> clearStudyLocalData({
  required String studyId,
  required Future<void> Function() clearLocalIdentityRefs,
}) async {
  await clearLocalIdentityRefs();
  await FitbitHandler.deleteFitbitCredentials(studyId);
}

/// Orchestrates deleting a study subject: pause background sync → attempt
/// one final sync → on success, delete the remote subject then clear local
/// data; on failure, leave local data untouched and resume sync.
///
/// Returns `false` when the final sync couldn't complete — the caller
/// should tell the user and must not treat the subject as deleted. A
/// failure *after* [deleteRemoteSubject] succeeds (i.e. inside
/// [clearLocalIdentityRefs] or [onLocalDataCleared]) is a genuine
/// partial-failure state — the remote subject is already gone — so it is
/// deliberately not caught here: it propagates to the caller as an error
/// rather than being silently swallowed.
Future<bool> deleteStudySubjectAndClearLocalData({
  required StudySubject subject,
  required Future<bool> Function(StudySubject subject) synchronizeBeforeDelete,
  required Future<void> Function() deleteRemoteSubject,
  Future<bool> Function()? confirmDiscardUnsyncedData,
  required Future<void> Function() clearLocalIdentityRefs,
  required FutureOr<void> Function() onLocalDataCleared,
}) async {
  // Stop the background retry loop first so the one deliberate sync attempt
  // below isn't racing (or being raced by) the controller's own timer.
  await ActiveSubjectSyncController.instance.pauseAndWait();

  bool synced;
  var alreadyDeleted = false;
  try {
    synced = await synchronizeBeforeDelete(subject);
    if (!synced && confirmDiscardUnsyncedData != null) {
      synced = await confirmDiscardUnsyncedData();
    }
  } on PostgrestException catch (error) {
    if (error.code != 'PGRST116') {
      ActiveSubjectSyncController.instance.resume();
      rethrow;
    }
    alreadyDeleted = true;
    synced = true;
  } catch (_) {
    ActiveSubjectSyncController.instance.resume();
    rethrow;
  }
  if (!synced) {
    ActiveSubjectSyncController.instance.resume();
    return false;
  }

  // From here on, also block Cache.synchronize() itself — belt-and-braces
  // against any other caller (not just the controller) landing a write
  // mid-delete; see spec.md's reentrancy-guard edge case.
  await Cache.pauseAndWaitSynchronization();
  try {
    if (!alreadyDeleted) await deleteRemoteSubject();
    ActiveSubjectSyncController.instance.onAccountCleared();
    await TemporaryStorageHandler.deletePendingBlobFiles(
      subject.studyId,
      subject.userId,
    );
    await Cache.delete();
    for (final request in await Cache.loadDeferredFitbitRequests()) {
      if (request.subjectId == subject.id) {
        await Cache.removeDeferredFitbitRequest(request.id);
      }
    }
    await clearStudyLocalData(
      studyId: subject.studyId,
      clearLocalIdentityRefs: clearLocalIdentityRefs,
    );
    await onLocalDataCleared();
    return true;
  } finally {
    Cache.resumeSynchronization();
    ActiveSubjectSyncController.instance.resume();
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/models/deferred_fitbit_request.dart';
import 'package:studyu_app/util/deferred_fitbit_sync.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

/// The outcome of a [Cache.synchronize] attempt.
///
/// [succeeded] is `false` whenever the merge couldn't be completed or
/// couldn't be safely persisted (a concurrent write landed, synchronization
/// was paused/already running, or an upload/save failed) — [error] carries
/// the exception for the failure case, and is `null` for a transient "retry
/// me" outcome (reentrancy/pause/stale-revision) that isn't itself an error.
/// [subject] is always the best known current subject: the merged result on
/// success, or the latest cached/remote subject on failure.
class CacheSynchronizationResult({
  required final StudySubject subject,
  required final bool succeeded,
  final Object? error,
});

/// Local-only progress to upload (`newProgress`) plus the full merged list
/// to persist (`mergedProgress`), with the save functions to use — injectable
/// for tests, defaulting to the real remote calls.
class SubjectProgressSyncPlan({
  required final List<SubjectProgress> newProgress,
  required final List<SubjectProgress> mergedProgress,
  required final Future<SubjectProgress> Function(SubjectProgress progress)
  saveProgress,
  required final Future<StudySubject> Function(StudySubject subject)
  saveSubject,
}) {
  bool get hasChanges => newProgress.isNotEmpty;
}

class DeferredFitbitQueueFullException() implements Exception {
  @override
  String toString() => 'The pending Fitbit request queue is full.';
}

class Cache() {
  static const maxDeferredFitbitRequests = 256;
  static const _deferredFitbitKey = 'deferred_fitbit_requests';
  static Future<void>? _deferredQueueTail;

  // Serialize read-modify-write operations to preserve concurrent appends.
  static Future<T> _withDeferredQueue<T>(Future<T> Function() action) async {
    final previous = _deferredQueueTail;
    final completion = Completer<void>();
    _deferredQueueTail = completion.future;
    if (previous != null) await previous;
    try {
      return await action();
    } finally {
      completion.complete();
      if (identical(_deferredQueueTail, completion.future)) {
        _deferredQueueTail = null;
      }
    }
  }

  static Future<List<DeferredFitbitRequest>>
  loadDeferredFitbitRequests() async {
    final encoded = await SecureStorage.read(_deferredFitbitKey);
    if (encoded == null) return [];
    return (jsonDecode(encoded) as List<dynamic>)
        .map(
          (entry) =>
              DeferredFitbitRequest.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
  }

  static Future<void> storeDeferredFitbitRequest(
    DeferredFitbitRequest request,
  ) => storeDeferredFitbitRequests([request]);

  static Future<void> storeDeferredFitbitRequests(
    List<DeferredFitbitRequest> additions, {
    Future<void> Function()? preparePayload,
  }) => _withDeferredQueue(() async {
    final requests = {
      for (final request in await loadDeferredFitbitRequests())
        request.id: request,
    };
    for (final request in additions) {
      requests[request.id] = request;
    }
    if (requests.length > maxDeferredFitbitRequests) {
      throw DeferredFitbitQueueFullException();
    }
    await preparePayload?.call();
    await SecureStorage.write(
      _deferredFitbitKey,
      jsonEncode(requests.values.map((entry) => entry.toJson()).toList()),
    );
  });

  static Future<void> removeDeferredFitbitRequest(String id) =>
      _withDeferredQueue(() async {
        final requests = await loadDeferredFitbitRequests();
        requests.removeWhere((entry) => entry.id == id);
        await SecureStorage.write(
          _deferredFitbitKey,
          jsonEncode(requests.map((entry) => entry.toJson()).toList()),
        );
      });

  static bool isSynchronizing = false;
  static Completer<void>? _synchronizationFinished;
  static Future<void>? _subjectWriteTail;
  static int _subjectRevision = 0;

  static Future<T> _withSubjectWrite<T>(Future<T> Function() action) async {
    final previous = _subjectWriteTail;
    final completion = Completer<void>();
    _subjectWriteTail = completion.future;
    if (previous != null) await previous;
    try {
      return await action();
    } finally {
      completion.complete();
      if (identical(_subjectWriteTail, completion.future)) {
        _subjectWriteTail = null;
      }
    }
  }

  static Future<void> pauseAndWaitSynchronization() async {
    pauseSynchronization();
    await _synchronizationFinished?.future;
    await _subjectWriteTail;
  }

  static int _synchronizationBlockCount = 0;

  @visibleForTesting
  static Future<void> Function()? debugUploadBlobFilesOverride;

  @visibleForTesting
  static Future<SubjectProgress> Function(SubjectProgress progress)?
  debugSaveProgressOverride;

  @visibleForTesting
  static Future<StudySubject> Function(StudySubject subject)?
  debugSaveSubjectOverride;

  /// Called right after `synchronize()` loads its local-cache snapshot.
  /// Lets tests deterministically interleave a concurrent cache write
  /// between the snapshot read and the eventual write-back.
  @visibleForTesting
  static Future<void> Function()? debugAfterSubjectSnapshotLoaded;

  @visibleForTesting
  static void debugResetSynchronizationStateForTesting() {
    isSynchronizing = false;
    _subjectRevision = 0;
    _synchronizationBlockCount = 0;
    _subjectWriteTail = null;
    _deferredQueueTail = null;
    _synchronizationFinished = null;
    debugUploadBlobFilesOverride = null;
    debugSaveProgressOverride = null;
    debugSaveSubjectOverride = null;
    debugAfterSubjectSnapshotLoaded = null;
  }

  /// Pauses `synchronize()` so a destructive action (e.g. deleting the
  /// subject) can run without a concurrent sync write landing mid-delete.
  /// Must be paired with [resumeSynchronization].
  static void pauseSynchronization() {
    _synchronizationBlockCount++;
  }

  static void resumeSynchronization() {
    if (_synchronizationBlockCount > 0) _synchronizationBlockCount--;
  }

  @visibleForTesting
  static bool get debugIsSynchronizationPaused =>
      _synchronizationBlockCount > 0;

  static bool isCompatibleCachedSubject({
    required StudySubject localSubject,
    required StudySubject remoteSubject,
  }) {
    return localSubject.id == remoteSubject.id &&
        localSubject.studyId == remoteSubject.studyId &&
        localSubject.userId == remoteSubject.userId;
  }

  static String _progressSyncKey(SubjectProgress progress) =>
      '${progress.completedAt?.toIso8601String()}|${progress.subjectId}';

  /// Builds the plan to reconcile [localSubject]'s progress into
  /// [remoteSubject]'s, keyed by the real `(completed_at, subject_id)`
  /// primary key rather than list length — a length-based diff can't tell
  /// two different entries apart from one changed one, and silently drops
  /// local-only progress whenever the counts happen to already match.
  static SubjectProgressSyncPlan buildProgressSyncPlan({
    required StudySubject localSubject,
    required StudySubject remoteSubject,
  }) {
    final remoteKeys = remoteSubject.progress.map(_progressSyncKey).toSet();
    final mergedProgress = [...remoteSubject.progress];
    final newProgress = <SubjectProgress>[];

    for (final progress in localSubject.progress) {
      if (remoteKeys.add(_progressSyncKey(progress))) {
        if (!hasDeferredFitbitProgress(localSubject.study, progress)) {
          newProgress.add(progress);
        }
        mergedProgress.add(progress);
      }
    }

    return SubjectProgressSyncPlan(
      newProgress: newProgress,
      mergedProgress: mergedProgress,
      saveProgress: debugSaveProgressOverride ?? (progress) => progress.save(),
      saveSubject:
          debugSaveSubjectOverride ??
          (subject) => subject.save(onlyUpdate: true),
    );
  }

  /// Uploads [SubjectProgressSyncPlan.newProgress] (sequentially — a
  /// mid-list failure still leaves the earlier saves committed, so a retry
  /// only needs to resend what's left) then persists the merged progress
  /// list on [remoteSubject].
  static Future<StudySubject> applyProgressSyncPlan({
    required StudySubject remoteSubject,
    required SubjectProgressSyncPlan syncPlan,
  }) async {
    for (final progress in syncPlan.newProgress) {
      await syncPlan.saveProgress(progress);
    }
    remoteSubject.progress = syncPlan.mergedProgress;
    return await syncPlan.saveSubject(remoteSubject);
  }

  static Future<void> storeSubject(
    StudySubject? subject, {
    bool replaceProgress = false,
  }) async {
    if (subject == null) return;
    final encoded = jsonEncode(subject.toFullJson());
    _subjectRevision++;
    await _withSubjectWrite(() async {
      final incoming = StudySubject.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );
      if (!replaceProgress &&
          await SecureStorage.containsKey(cacheSubjectKey)) {
        final cached = await loadSubject(backupSubject: incoming);
        if (isCompatibleCachedSubject(
          localSubject: cached,
          remoteSubject: incoming,
        )) {
          incoming.progress = buildProgressSyncPlan(
            localSubject: cached,
            remoteSubject: incoming,
          ).mergedProgress;
        }
      }
      await SecureStorage.write(
        cacheSubjectKey,
        jsonEncode(incoming.toFullJson()),
      );
    });
  }

  static Future<StudySubject> loadSubject({StudySubject? backupSubject}) async {
    // debugPrint("Load subject from cache");
    if (await SecureStorage.containsKey(cacheSubjectKey)) {
      final cachedSubjectStr = await SecureStorage.read(cacheSubjectKey);
      Map<String, dynamic>? cachedSubject;
      try {
        cachedSubject = jsonDecode(cachedSubjectStr!) as Map<String, dynamic>;
        return await restoreDeferredFitbitProgress(
          StudySubject.fromJson(cachedSubject),
        );
      } catch (e) {
        StudyULogger.warning('Failed to parse the cached subject.');
        if (backupSubject != null) {
          // Only take progress from cached subject and rest from backup,
          // as the cached subject might be outdated or corrupted

          // compare IDs to make sure we are not mixing up subjects
          // If IDs do not match we should not use the cached subject
          if (cachedSubject == null) return backupSubject;
          if (backupSubject.id != cachedSubject['id']) {
            throw Exception(
              "Cached subject ID does not match remote subject ID",
            );
          }
          final cachedProgress = (cachedSubject['subject_progress'] as List?)
              ?.map((e) => SubjectProgress.fromJson(e as Map<String, dynamic>))
              .toList();
          backupSubject.progress = cachedProgress ?? backupSubject.progress;
          return backupSubject;
        }
        throw Exception("No backup subject provided");
      }
    } else {
      throw Exception("No cached subject found");
    }
  }

  static Future<void> storeAnalytics(StudyUAnalytics analytics) async {
    SecureStorage.write(
      StudyUAnalytics.keyStudyUAnalytics,
      jsonEncode(analytics.toJson()),
    );
  }

  static Future<StudyUAnalytics?> loadAnalytics() async {
    try {
      if (await SecureStorage.containsKey(StudyUAnalytics.keyStudyUAnalytics)) {
        final analyticsData = await SecureStorage.read(
          StudyUAnalytics.keyStudyUAnalytics,
        );
        if (analyticsData != null) {
          return StudyUAnalytics.fromJson(
            jsonDecode(analyticsData) as Map<String, dynamic>,
          );
        }
      }
    } catch (e) {
      StudyULogger.warning("Failed to load analytics from cache: $e");
    }
    return null;
  }

  static Future<void> delete() {
    StudyULogger.warning("Delete cache");
    _subjectRevision++;
    return _withSubjectWrite(() => SecureStorage.delete(cacheSubjectKey));
  }

  static Future<void> uploadBlobFiles() async {
    final blobStorageHandler = BlobStorageHandler();
    final futureBlobFiles = await TemporaryStorageHandler.getFutureBlobFiles();
    for (final futureBlobFile in futureBlobFiles) {
      await blobStorageHandler.uploadObservation(
        futureBlobFile.futureBlobId,
        File(futureBlobFile.localFilePath),
      );
      await File(futureBlobFile.localFilePath).delete();
    }
  }

  /// Merges the locally cached subject's progress into [remoteSubject] and
  /// persists the result, both remotely and back to the cache.
  ///
  /// Never silently discards unsynced local progress: unlike the previous
  /// implementation, there is no early return based on comparing the
  /// subjects' `startedAt` values — that comparison was meant to detect "the
  /// cache belongs to a different subject" but used the wrong signal for it
  /// (chronology instead of identity), and would drop real unsynced local
  /// progress whenever the remote happened to have a later `startedAt`.
  /// [isCompatibleCachedSubject] now does that identity check directly.
  static Future<CacheSynchronizationResult> synchronize(
    StudySubject remoteSubject,
  ) async {
    if (_synchronizationBlockCount > 0 || isSynchronizing) {
      return CacheSynchronizationResult(
        subject: remoteSubject,
        succeeded: false,
      );
    }

    isSynchronizing = true;
    _synchronizationFinished = Completer<void>();
    await _subjectWriteTail;
    final startRevision = _subjectRevision;

    // Any conclusion reached from the snapshot loaded below — "equal,
    // nothing to do", "incompatible, nothing to do", or a computed merge —
    // is only valid if the cache didn't change again while we were working.
    // If it did (e.g. another task completed offline mid-sync), that
    // conclusion is stale: report the latest cache contents instead of
    // trusting (or worse, overwriting) them with a stale answer.
    Future<CacheSynchronizationResult> finishUnlessStale(
      Future<CacheSynchronizationResult> Function() onFresh,
    ) async {
      await _subjectWriteTail;
      if (_synchronizationBlockCount > 0) {
        return CacheSynchronizationResult(
          subject: remoteSubject,
          succeeded: false,
        );
      }
      if (_subjectRevision != startRevision) {
        return CacheSynchronizationResult(
          subject: await loadSubject(backupSubject: remoteSubject),
          succeeded: false,
        );
      }
      return await onFresh();
    }

    try {
      final localSubject = await SecureStorage.containsKey(cacheSubjectKey)
          ? await loadSubject(backupSubject: remoteSubject)
          : StudySubject.fromJson(remoteSubject.toFullJson());
      await debugAfterSubjectSnapshotLoaded?.call();

      final queued = (await loadDeferredFitbitRequests()).any(
        (request) => request.subjectId == remoteSubject.id,
      );
      if (localSubject == remoteSubject && !queued) {
        return await finishUnlessStale(
          () async => CacheSynchronizationResult(
            subject: remoteSubject,
            succeeded: true,
          ),
        );
      }
      if (!isCompatibleCachedSubject(
        localSubject: localSubject,
        remoteSubject: remoteSubject,
      )) {
        return await finishUnlessStale(
          () async => CacheSynchronizationResult(
            subject: remoteSubject,
            succeeded: true,
          ),
        );
      }

      debugPrint("Synchronize subject with cache");

      final plan = buildProgressSyncPlan(
        localSubject: localSubject,
        remoteSubject: remoteSubject,
      );
      remoteSubject.progress = plan.mergedProgress;
      if (plan.hasChanges || queued) {
        await (debugUploadBlobFilesOverride ?? uploadBlobFiles)();
      }
      if (plan.hasChanges) {
        await applyProgressSyncPlan(
          remoteSubject: remoteSubject,
          syncPlan: plan,
        );
      } else {
        remoteSubject.progress = plan.mergedProgress;
      }
      Object? deferredError;
      final deferred = await synchronizeDeferredFitbitRequests(
        remoteSubject,
        onError: (error) {
          if (deferredError == null ||
              connectionStatusFromError(error) != null) {
            deferredError = error;
          }
        },
        saveProgress: debugSaveProgressOverride ?? (p) => p.save(),
        saveSubject:
            debugSaveSubjectOverride ?? (s) => s.save(onlyUpdate: true),
      );
      return await finishUnlessStale(() async {
        final written = await _withSubjectWrite(() async {
          if (_subjectRevision != startRevision ||
              _synchronizationBlockCount > 0) {
            return false;
          }
          await SecureStorage.write(
            cacheSubjectKey,
            jsonEncode(remoteSubject.toFullJson()),
          );
          return true;
        });
        await _subjectWriteTail;
        if (!written ||
            _subjectRevision != startRevision ||
            _synchronizationBlockCount > 0) {
          return CacheSynchronizationResult(
            subject: await loadSubject(backupSubject: remoteSubject),
            succeeded: false,
          );
        }
        return CacheSynchronizationResult(
          subject: remoteSubject,
          succeeded: deferred,
          error: deferredError,
        );
      });
    } catch (exception) {
      StudyULogger.warning(exception);
      await _subjectWriteTail;
      try {
        final latest = await loadSubject(backupSubject: remoteSubject);
        if (isCompatibleCachedSubject(
          localSubject: latest,
          remoteSubject: remoteSubject,
        )) {
          remoteSubject.progress = buildProgressSyncPlan(
            localSubject: latest,
            remoteSubject: remoteSubject,
          ).mergedProgress;
        }
      } catch (_) {
        // Keep the merged snapshot when the cache cannot be read.
      }
      return CacheSynchronizationResult(
        subject: remoteSubject,
        succeeded: false,
        error: exception,
      );
    } finally {
      isSynchronizing = false;
      _synchronizationFinished?.complete();
      _synchronizationFinished = null;
    }
  }

  static Future<String> getCachedUserData() async {
    final debugInfo = StringBuffer();
    debugInfo.writeln('=== Cached User Data Debug Info ===');

    try {
      // Check selected subject ID
      if (await SecureStorage.containsKey('selected_study_object_id')) {
        final selectedSubjectId = await SecureStorage.read(
          'selected_study_object_id',
        );
        debugInfo.writeln('Selected Subject ID: $selectedSubjectId');
      } else {
        debugInfo.writeln('Selected Subject ID: NOT FOUND');
      }

      // Check user email
      if (await SecureStorage.containsKey('user_email')) {
        final userEmail = await SecureStorage.read('user_email');
        debugInfo.writeln('User Email: $userEmail');
      } else {
        debugInfo.writeln('User Email: NOT FOUND');
      }

      // Check cached subject
      if (await SecureStorage.containsKey('cache_subject')) {
        debugInfo.writeln('Cache Subject: EXISTS (data present)');
        try {
          final cachedSubject = await loadSubject();
          debugInfo.writeln('  - Subject ID: ${cachedSubject.id}');
          debugInfo.writeln('  - Study ID: ${cachedSubject.studyId}');
          debugInfo.writeln('  - Started At: ${cachedSubject.startedAt}');
          debugInfo.writeln(
            '  - Progress Count: ${cachedSubject.progress.length}',
          );
        } catch (e) {
          debugInfo.writeln('  - Error loading cached subject: $e');
        }
      } else {
        debugInfo.writeln('Cache Subject: NOT FOUND');
      }

      // Check user password (without revealing the actual password)
      if (await SecureStorage.containsKey('user_password')) {
        debugInfo.writeln('User Password: EXISTS (hidden for security)');
      } else {
        debugInfo.writeln('User Password: NOT FOUND');
      }
    } catch (e) {
      debugInfo.writeln('Error retrieving cached data: $e');
    }

    return debugInfo.toString();
  }
}

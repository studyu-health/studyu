import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

/// Creates the study subject on the backend and navigates to the next screen
/// (recovery phrase or dashboard).
///
/// Callers own the loading UI: show a spinner while this runs and treat a
/// `false` result as failure. On success this method navigates away, so the
/// calling screen is disposed.
class const StudyStartService._() {
  /// Returns `true` when the study was started and navigation happened;
  /// `false` when the subject could not be created.
  static Future<bool> startStudy(
    BuildContext context,
    StudySubject subject,
  ) async {
    final state = context.read<AppState>();
    final expectedPhase = subject.study.hasConsentCheck
        ? StudyOnboardingPhase.consent
        : StudyOnboardingPhase.journey;
    // Defense in depth: only the current enrollment step may start an
    // un-started subject. The route policy normally enforces this first.
    if (!state.isPreview &&
        (subject.startedAt != null ||
            state.effectiveOnboardingPhase != expectedPhase)) {
      StudyULogger.warning('Study start skipped: invalid enrollment state');
      if (context.mounted) {
        context.go(onboardingStepRoute(state.effectiveOnboardingPhase));
      }
      return false;
    }

    try {
      // Start study at the next day
      final now = DateTime.now();
      subject.startedAt = DateTime(now.year, now.month, now.day + 1).toUtc();
      final saved = await subject.save();
      final updated = await _fetchRemoteSubject(saved.id);
      if (updated == null) {
        throw StateError('Could not re-fetch subject ${saved.id} after saving');
      }
      if (!context.mounted) return false;
      final state = context.read<AppState>();
      state.activeSubject = updated;
      state.init(context);
      await Cache.storeSubject(state.activeSubject);
      await storeActiveSubjectId(updated.id);
      await PendingDeepLinkService.clearStorage();
      state.clearPendingDeepLink();
      if (!context.mounted) return false;
      if (state.showParticipantRecovery) {
        await RecoveryPhraseStorage.markPending(updated.id);
        if (!context.mounted) return false;
        context.goNamed(
          RouteNames.recoveryPhrase,
          queryParameters: {'next': RouteNames.dashboard},
        );
      } else {
        context.goNamed(RouteNames.dashboard);
      }
      return true;
    } catch (e) {
      StudyULogger.fatal('Failed creating subject: $e');
      return false;
    }
  }

  static Future<StudySubject?> _fetchRemoteSubject(String subjectId) {
    StudyULogger.debug('Fetching subject with ID: $subjectId');
    return SupabaseQuery.getById<StudySubject>(
      subjectId,
      selectedColumns: [
        '*',
        // Retrieve the related study along with its fitbit credentials
        'study!study_subject_studyId_fkey(*, study_fitbit_credentials:study_fitbit_credentials_studyId_fkey(*))',
        'subject_progress(*)',
      ],
    );
  }
}

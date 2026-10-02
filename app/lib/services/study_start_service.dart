import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

sealed class StudyStartResult();

class StudyStartSuccess(final StudySubject subject) extends StudyStartResult;
class StudyStartFitbitAuthFailed() extends StudyStartResult;
class StudyStartNetworkFailed(final Object error) extends StudyStartResult;
class StudyStartGenericFailed(final Object error) extends StudyStartResult;

String studyStartFailureMessage(
  StudyStartResult result,
  AppLocalizations l10n,
) => switch (result) {
  StudyStartFitbitAuthFailed() => l10n.fitbit_authorization_failed,
  StudyStartNetworkFailed() => l10n.no_internet_connection,
  _ => l10n.error,
};

class const StudyStartService._() {
  @visibleForTesting
  static Future<StudySubject> Function(StudySubject subject)?
  debugSaveSubjectOverride;
  @visibleForTesting
  static Future<StudySubject?> Function(String id)? debugFetchSubjectOverride;
  @visibleForTesting
  static Future<StudyFitbitCredentials?> Function(StudySubject subject)?
  debugLoadFitbitConfigurationOverride;

  static Future<StudyFitbitCredentials?> _loadFitbitConfiguration(
    StudySubject subject,
  ) async {
    final response = await Supabase.instance.client.rpc(
      'get_enrollment_fitbit_configuration',
      params: {
        'p_study_id': subject.studyId,
        'p_invite_code': subject.inviteCode,
      },
    );
    return response == null
        ? null
        : StudyFitbitCredentials.fromJson(response as Map<String, dynamic>);
  }

  static StudyStartResult _failure(Object error) {
    final status = connectionStatusFromError(error);
    if (status != null) {
      appConnectionStatusController.setStatus(status);
      return StudyStartNetworkFailed(error);
    }
    return StudyStartGenericFailed(error);
  }

  static Future<StudyStartResult> createSubject(
    StudySubject subject, {
    bool requireFitbitAuthorization = true,
  }) async {
    final previousStart = subject.startedAt;
    try {
      if (requireFitbitAuthorization &&
          FitbitHandler.requiredTypesForStudy(subject.study).isNotEmpty &&
          subject.study.fitbitCredentials == null) {
        subject.study.fitbitCredentials =
            await (debugLoadFitbitConfigurationOverride ??
                _loadFitbitConfiguration)(subject);
        if (subject.study.fitbitCredentials == null) {
          return StudyStartFitbitAuthFailed();
        }
      }
      if (requireFitbitAuthorization &&
          !await FitbitHandler.authorizeForOfflineParticipation(
            subject.study,
          )) {
        return StudyStartFitbitAuthFailed();
      }
      final now = DateTime.now();
      subject.startedAt = DateTime(now.year, now.month, now.day + 1).toUtc();
      final saved = await (debugSaveSubjectOverride ?? (s) => s.save())(
        subject,
      );
      final updated = await (debugFetchSubjectOverride ?? _fetchRemoteSubject)(
        saved.id,
      );
      if (updated == null) {
        throw StateError('Could not fetch the created subject.');
      }
      appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
      return StudyStartSuccess(updated);
    } catch (error) {
      subject.startedAt = previousStart;
      return _failure(error);
    }
  }

  static Future<StudyStartResult> startStudy(
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
      return StudyStartGenericFailed(
        StateError('Study start was interrupted.'),
      );
    }

    try {
      final result = await createSubject(
        subject,
        requireFitbitAuthorization: !state.isPreview,
      );
      if (result is! StudyStartSuccess) return result;
      final updated = result.subject;
      if (!context.mounted) {
        return StudyStartGenericFailed(
          StateError('Study start was interrupted.'),
        );
      }
      state.activeSubject = updated;
      state.init(context);
      await Cache.storeSubject(state.activeSubject);
      await storeActiveSubjectId(updated.id);
      await PendingDeepLinkService.clearStorage();
      state.clearPendingDeepLink();
      if (!context.mounted) {
        return StudyStartGenericFailed(
          StateError('Study start was interrupted.'),
        );
      }
      if (state.showParticipantRecovery) {
        await RecoveryPhraseStorage.markPending(updated.id);
        if (!context.mounted) {
          return StudyStartGenericFailed(
            StateError('Study start was interrupted.'),
          );
        }
        context.goNamed(
          RouteNames.recoveryPhrase,
          queryParameters: {'next': RouteNames.dashboard},
        );
      } else {
        context.goNamed(RouteNames.dashboard);
      }
      return StudyStartSuccess(updated);
    } catch (e) {
      StudyULogger.fatal('Failed creating subject: $e');
      return _failure(e);
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

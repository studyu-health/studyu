import 'package:flutter/foundation.dart';
import 'package:studyu_core/core.dart';

/// Result types for deep link processing
sealed class DeepLinkResult();

/// Deep link was successfully processed
class DeepLinkSuccess({
  required final Study study,
  final String? inviteCode,
  final List<String>? preselectedInterventionIds,
  final bool alreadyEnrolled = false,
}) extends DeepLinkResult;

/// Deep link processing failed
class DeepLinkError(final DeepLinkErrorType type, [final String? errorValue])
    extends DeepLinkResult;

/// User needs to authenticate first
class DeepLinkNeedsAuth({
  required final Study study,
  final String? inviteCode,
  final List<String>? preselectedInterventionIds,
}) extends DeepLinkResult;

/// Types of deep link errors
enum DeepLinkErrorType() {
  studyNotFound,
  inviteOnly,
  invalidInvite,
}

class DeepLinkService() {
  @visibleForTesting
  static Future<(StudyInvite?, Study?)> Function(String code)
  fetchInviteForDeepLink = Study.fetchByInviteCode;

  @visibleForTesting
  static Future<Study?> Function(String studyId) fetchStudyForDeepLink =
      fetchStudyById;

  @visibleForTesting
  static void resetTestOverrides() {
    fetchInviteForDeepLink = Study.fetchByInviteCode;
    fetchStudyForDeepLink = fetchStudyById;
  }

  /// Fetches a study by its ID
  static Future<Study?> fetchStudyById(String studyId) async {
    try {
      return await Study.fetchById(studyId);
    } catch (e) {
      debugPrint('Failed to fetch study by ID: $e');
      return null;
    }
  }

  /// Process a deep link and return the appropriate result.
  ///
  /// This is the main entry point for deep link handling. It validates
  /// authentication, fetches the study/invite, and returns an appropriate result.
  ///
  /// ## Parameters
  /// - [studyId]: The UUID of a study to navigate to (from `app.studyu.health/study/{uuid}`)
  /// - [inviteCode]: An invite code for a private study (from `app.studyu.health/invite/{code}`)
  /// - [isAuthenticated]: Whether the user is currently logged in
  /// - [activeStudyId]: The ID of the study the user is currently enrolled in (if any)
  ///
  /// ## Return Values
  /// - [DeepLinkNeedsAuth]: User is not authenticated. Redirect to auth flow.
  /// - [DeepLinkSuccess]: Deep link processed successfully.
  ///   - Check [DeepLinkSuccess.alreadyEnrolled] to see if user is already in the study.
  ///   - Use [DeepLinkSuccess.inviteCode] and [DeepLinkSuccess.preselectedInterventionIds]
  ///     for invite-based enrollment.
  /// - [DeepLinkError]: Deep link processing failed.
  ///   - [DeepLinkErrorType.studyNotFound]: Study doesn't exist or was deleted.
  ///   - [DeepLinkErrorType.inviteOnly]: Study requires an invite code (use invite link instead).
  ///   - [DeepLinkErrorType.invalidInvite]: Invite code is invalid or expired.
  static Future<DeepLinkResult> processDeepLink({
    required String? studyId,
    required String? inviteCode,
    required bool isAuthenticated,
    String? activeStudyId,
  }) async {
    // Process invite deep link
    if (inviteCode != null) {
      final result = await _processInviteDeepLink(
        inviteCode: inviteCode,
        isAuthenticated: isAuthenticated,
        activeStudyId: activeStudyId,
      );
      if (result is DeepLinkError && result.errorValue == null) {
        return DeepLinkError(
          result.type,
          inviteCode,
        ); // Ensure inviteCode is passed
      }
      return result;
    }
    // Process study deep link
    else if (studyId != null) {
      final result = await _processStudyDeepLink(
        studyId: studyId,
        activeStudyId: activeStudyId,
        isAuthenticated: isAuthenticated,
      );
      if (result is DeepLinkError && result.errorValue == null) {
        return DeepLinkError(result.type, studyId); // Ensure studyId is passed
      }
      return result;
    }

    // No valid deep link data provided
    return DeepLinkError(DeepLinkErrorType.studyNotFound);
  }

  /// Process a study ID deep link
  static Future<DeepLinkResult> _processStudyDeepLink({
    required String studyId,
    String? activeStudyId,
    required bool isAuthenticated,
  }) async {
    final study = await fetchStudyForDeepLink(studyId);

    if (study == null) {
      return DeepLinkError(DeepLinkErrorType.studyNotFound, studyId);
    }

    if (!isAuthenticated) {
      return DeepLinkNeedsAuth(study: study);
    }

    // Check if study requires an invite
    if (study.participation == Participation.invite) {
      return DeepLinkError(DeepLinkErrorType.inviteOnly);
    }

    // Check if user is already enrolled in this study
    if (activeStudyId == study.id) {
      return DeepLinkSuccess(study: study, alreadyEnrolled: true);
    }

    return DeepLinkSuccess(study: study);
  }

  /// Process an invite code deep link
  static Future<DeepLinkResult> _processInviteDeepLink({
    required String inviteCode,
    required bool isAuthenticated,
    String? activeStudyId,
  }) async {
    try {
      final (invite, study) = await fetchInviteForDeepLink(inviteCode);

      if (invite == null || study == null) {
        return DeepLinkError(DeepLinkErrorType.invalidInvite, inviteCode);
      }

      if (!isAuthenticated) {
        return DeepLinkNeedsAuth(
          study: study,
          inviteCode: inviteCode,
          preselectedInterventionIds: invite.preselectedInterventionIds,
        );
      }

      return DeepLinkSuccess(
        study: study,
        inviteCode: inviteCode,
        preselectedInterventionIds: invite.preselectedInterventionIds,
        alreadyEnrolled: activeStudyId == study.id,
      );
    } catch (e) {
      debugPrint('Failed to fetch study by invite code: $e');
      return DeepLinkError(DeepLinkErrorType.invalidInvite, inviteCode);
    }
  }
}

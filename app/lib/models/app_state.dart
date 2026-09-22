import 'package:flutter/material.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/notifications.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';

/// Phases of the normal (non-preview) study enrollment flow, in guarded
/// progression order.
///
/// Optional phases are skipped by the transition logic when a study has no
/// eligibility check, has preselected interventions or at most two
/// interventions, or requires no consent. [complete] marks a started
/// subject.
enum StudyOnboardingPhase() {
  overview,
  terms,
  eligibility,
  interventionSelection,
  journey,
  consent,
  complete,
}

class AppState() with ChangeNotifier {
  Study? selectedStudy;
  List<Intervention>? selectedInterventions;
  StudySubject? activeSubject;
  String? inviteCode;
  List<String>? preselectedInterventionIds;
  StudyNotifications? studyNotifications;
  bool isPreview = false;

  /// Transient phase of the normal (non-preview) enrollment flow.
  ///
  /// Set immediately before each legitimate navigation to the next phase
  /// and reset when enrollment is abandoned; see [effectiveOnboardingPhase]
  /// for how it is interpreted. It is not persisted: fresh loads re-enter
  /// through /loading and derive a safe restart phase.
  StudyOnboardingPhase? onboardingPhase;

  /// Effective enrollment phase used by the route policy.
  ///
  /// [StudyOnboardingPhase.complete] is authoritative through
  /// [StudySubject.startedAt]. A stored phase is only trusted while it is
  /// consistent with the subject state: the subject phases (journey and
  /// consent) require an un-started active subject, the selection
  /// phases (overview, terms, eligibility, interventionSelection) require
  /// a selected study without a subject. Otherwise the safe restart phase
  /// applies: [StudyOnboardingPhase.journey] for an un-started subject and
  /// [StudyOnboardingPhase.overview] for a selected study.
  StudyOnboardingPhase? get effectiveOnboardingPhase {
    if (activeSubject?.startedAt != null) {
      return StudyOnboardingPhase.complete;
    }
    if (activeSubject != null) {
      return switch (onboardingPhase) {
        StudyOnboardingPhase.journey ||
        StudyOnboardingPhase.consent => onboardingPhase!,
        _ => StudyOnboardingPhase.journey,
      };
    }
    if (selectedStudy != null) {
      return switch (onboardingPhase) {
        StudyOnboardingPhase.overview ||
        StudyOnboardingPhase.terms ||
        StudyOnboardingPhase.eligibility ||
        StudyOnboardingPhase.interventionSelection => onboardingPhase!,
        _ => StudyOnboardingPhase.overview,
      };
    }
    return null;
  }

  String? pendingDeepLinkStudyId;
  String? pendingDeepLinkInviteCode;

  bool get hasPendingDeepLink =>
      pendingDeepLinkStudyId != null || pendingDeepLinkInviteCode != null;

  bool get showParticipantRecovery => !isPreview;

  void setPendingDeepLink({
    required Study study,
    String? inviteCode,
    List<String>? preselectedInterventionIds,
  }) {
    pendingDeepLinkStudyId = inviteCode == null ? study.id : null;
    pendingDeepLinkInviteCode = inviteCode;
    selectedStudy = study;
    this.inviteCode = inviteCode;
    this.preselectedInterventionIds = preselectedInterventionIds;
    notifyListeners();
  }

  void clearPendingDeepLink() {
    pendingDeepLinkStudyId = null;
    pendingDeepLinkInviteCode = null;
    notifyListeners();
  }

  /// Clears all state that belongs to the signed-out participant.
  void clearAccountState() {
    activeSubject = null;
    selectedStudy = null;
    selectedInterventions = null;
    inviteCode = null;
    preselectedInterventionIds = null;
    studyNotifications = null;
    pendingDeepLinkStudyId = null;
    pendingDeepLinkInviteCode = null;
    onboardingPhase = null;
    notifyListeners();
  }

  /// Flag indicating whether the participant's progress should be tracked
  ///
  /// We always track the participant's progress except when the study is
  /// being viewed in test/preview mode while already launched (to avoid
  /// mixing results from test users with actual participants)
  bool get trackParticipantProgress => !(isPreview && selectedStudy!.isRunning);

  void init(BuildContext context) {
    scheduleNotifications(context);
    initCache();
  }

  void initCache() {
    activeSubject!.onSave.listen((StudySubject subject) async {
      await Cache.storeSubject(subject);
    });
  }

  void updateStudy(Study study) {
    // todo baseline
    study.schedule.includeBaseline = false;
    selectedStudy = study;
    if (activeSubject?.study.id == study.id) {
      activeSubject!.study = study;
    }
    notifyListeners();
  }

  /// Updates the preview mode state for the debug mode of the app
  ///
  /// Sets [isPreview] to the given value and updates [selectedStudy]
  /// to the active subject's study. Notifies listeners of the change.
  void updatePreviewMode(bool preview) {
    isPreview = preview;
    selectedStudy = activeSubject?.study;
    notifyListeners();
  }
}

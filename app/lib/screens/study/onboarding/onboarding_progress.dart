import 'package:flutter/material.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';

/// Pages of the study onboarding flow, in the order participants see them.
enum OnboardingStep() {
  overview,
  terms,
  eligibility,
  interventions,
  journey,
  consent,
  recovery,
}

class const OnboardingProgress({
  /// 0-based index of the page the participant is currently on.
  required final int currentStep,

  /// Number of pages this study's onboarding flow shows.
  required final int stepCount,
  super.key,
}) extends StatelessWidget {
  /// Builds the progress for [page] with one segment per page that this
  /// study's onboarding flow actually shows. Conditional pages (eligibility
  /// check, intervention selection, consent, recovery phrase) only count
  /// when the study includes them.
  factory forPage(AppState state, OnboardingStep page) {
    final study = state.selectedStudy ?? state.activeSubject?.study;
    final shownPages = [
      true, // study overview
      true, // terms
      study?.hasEligibilityCheck ?? false,
      _showsInterventionSelection(state, study),
      true, // journey
      study?.hasConsentCheck ?? false,
      state.showParticipantRecovery,
    ];
    return OnboardingProgress(
      currentStep: shownPages.take(page.index).where((shown) => shown).length,
      stepCount: shownPages.where((shown) => shown).length,
    );
  }

  /// Intervention selection is skipped when interventions are preselected
  /// (deep link) or when there are at most two interventions to pick from.
  static bool _showsInterventionSelection(AppState state, Study? study) {
    if (study == null) return false;
    return state.preselectedInterventionIds == null &&
        study.interventions.length > 2;
  }

  double _segmentValue(int segment) => segment <= currentStep ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var segment = 0; segment < stepCount; segment++) ...[
          if (segment > 0) const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: _segmentValue(segment)),
            ),
          ),
        ],
      ],
    );
  }
}

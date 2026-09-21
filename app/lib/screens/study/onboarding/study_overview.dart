import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/terms.dart';
import 'package:studyu_app/screens/study/dashboard/contact_tab/contact_screen.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/screens/study/onboarding/onboarding_progress.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/onboarding_shell.dart';
import 'package:studyu_app/widgets/study_tile.dart';
import 'package:studyu_app/widgets/title_description_layout.dart';
import 'package:studyu_core/core.dart';

@visibleForTesting
bool shouldReturnToStudySelection(AppState state) => !state.hasPendingDeepLink;

class const StudyOverviewScreen({super.key}) extends StatefulWidget {
  @override
  State<StudyOverviewScreen> createState() => _StudyOverviewScreen();
}

class _StudyOverviewScreen() extends State<StudyOverviewScreen> {
  Study? study;

  @override
  void initState() {
    super.initState();
    study = context.read<AppState>().selectedStudy;
  }

  Future<void> _continueOnboarding(BuildContext context) async {
    final appState = context.read<AppState>();
    // The terms phase is entered only through this action.
    appState.onboardingPhase = StudyOnboardingPhase.terms;
    await context.push<void>(
      '/${RouteNames.terms}',
      extra: TermsScreenArguments(onAccepted: _continueAfterTerms),
    );
    // When the terms screen is popped, the enrollment restarts at the
    // overview phase (unless a later phase has since taken over).
    if (appState.onboardingPhase == StudyOnboardingPhase.terms) {
      appState.onboardingPhase = StudyOnboardingPhase.overview;
    }
  }

  Future<void> _continueAfterTerms(BuildContext context) async {
    // Only the terms-accept callback advances enrollment past the terms
    // phase; informational `/terms` access carries no callback.
    if (context.read<AppState>().onboardingPhase !=
        StudyOnboardingPhase.terms) {
      return;
    }
    if (study!.hasEligibilityCheck) {
      await navigateToEligibilityCheck(context);
    } else {
      await continueAfterEligibility(context);
    }
  }

  Future<void> navigateToEligibilityCheck(BuildContext context) async {
    final appState = context.read<AppState>();
    // The eligibility phase is entered only after terms were accepted.
    appState.onboardingPhase = StudyOnboardingPhase.eligibility;
    await context.push<void>(
      '/${RouteNames.eligibilityCheck}',
      extra: EligibilityScreenArguments(
        study: context.read<AppState>().selectedStudy,
        onEligible: continueAfterEligibility,
      ),
    );
    // When the eligibility check is popped, the participant is back on
    // the terms screen (unless a later phase has since taken over).
    if (appState.onboardingPhase == StudyOnboardingPhase.eligibility) {
      appState.onboardingPhase = StudyOnboardingPhase.terms;
    }
  }

  void _clearStudySelection(AppState appState) {
    appState
      ..selectedStudy = null
      ..selectedInterventions = null
      ..inviteCode = null
      ..preselectedInterventionIds = null
      ..onboardingPhase = null;
  }

  Future<void> _returnToStudySelection(AppState appState) async {
    if (!context.canPop()) {
      _clearStudySelection(appState);
      context.go('/${RouteNames.studySelection}');
      return;
    }

    final route = ModalRoute.of(context);
    context.pop();
    await route?.completed;
    _clearStudySelection(appState);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final returnToStudySelection = shouldReturnToStudySelection(appState);

    final nav = BottomOnboardingNavigation(
      backButtonKey: const ValueKey('study_overview_back'),
      onBack: () {
        if (!returnToStudySelection) {
          context.pop();
          return;
        }
        unawaited(_returnToStudySelection(appState));
      },
      nextButtonKey: const ValueKey('study_overview_continue'),
      onNext: () => _continueOnboarding(context),
      progress: OnboardingProgress.forPage(appState, OnboardingStep.overview),
    );

    final navNotifier = OnboardingNavNotifier.maybeOf(context);
    navNotifier?.register(
      this,
      '/${RouteNames.studyOverview}',
      OnboardingNavConfig.fromNav(nav),
    );

    return Scaffold(
      key: const ValueKey('study_overview_screen'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.study_overview_title),
      ),
      body: TitleDescriptionLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'study_tile_${study!.id}',
              child: Material(
                type: MaterialType.transparency,
                child: StudyTile.fromStudy(study: study!),
              ),
            ),
            const SizedBox(height: 16),
            StudyDetailsView(study: study),
          ],
        ),
      ),
      bottomNavigationBar: navNotifier != null ? null : nav,
    );
  }
}

class const StudyDetailsView({required final Study? study, super.key})
    extends StatelessWidget {
  double get iconSize => 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studyLength = study!.studyLength;
    return Column(
      key: const ValueKey('study_details'),
      children: [
        ListTile(
          key: const ValueKey('study_duration_tile'),
          title: Text(
            AppLocalizations.of(context)!.intervention_phase_duration,
          ),
          subtitle: Text(
            '${study!.schedule.phaseDuration} ${AppLocalizations.of(context)!.days}',
          ),
          leading: Icon(
            MdiIcons.clock,
            color: theme.primaryColor,
            size: iconSize,
          ),
        ),
        ListTile(
          key: const ValueKey('study_length_tile'),
          title: Text(AppLocalizations.of(context)!.study_length),
          subtitle: Text('$studyLength ${AppLocalizations.of(context)!.days}'),
          leading: Icon(
            MdiIcons.calendar,
            color: theme.primaryColor,
            size: iconSize,
          ),
        ),
        const SizedBox(height: 16),
        ContactWidget(
          key: const ValueKey('study_publisher_contact'),
          contact: study!.contact,
          title: AppLocalizations.of(context)!.study_publisher,
          color: theme.colorScheme.secondary,
        ),
      ],
    );
  }
}

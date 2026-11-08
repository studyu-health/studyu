import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/onboarding_progress.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_app/services/study_start_service.dart';
import 'package:studyu_app/util/date_time_preferences.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/loading_overlay.dart';
import 'package:studyu_app/widgets/onboarding_shell.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';
import 'package:studyu_app/widgets/title_description_layout.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:timeline_tile/timeline_tile.dart';

class const JourneyOverviewScreen({super.key}) extends StatefulWidget {
  @override
  State<JourneyOverviewScreen> createState() => _JourneyOverviewScreen();
}

class _JourneyOverviewScreen() extends State<JourneyOverviewScreen> {
  StudySubject? subject;
  bool _isStartingStudy = false;

  // Creates the study subject on the backend and navigates to the next
  // screen. Runs in-place on this screen (with a loading state) so no
  // transient route flickers between the consent screen and the next step.
  Future<void> _startStudy(BuildContext context) async {
    setState(() => _isStartingStudy = true);
    final started = await StudyStartService.startStudy(context, subject!);
    if (started || !mounted) return;
    setState(() => _isStartingStudy = false);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.error)),
    );
  }

  void _goBack() {
    final appState = context.read<AppState>();
    if (!appState.isPreview) {
      final study = subject!.study;
      final needsInterventionSelection =
          appState.preselectedInterventionIds == null &&
          study.interventions.length > 2;
      appState.activeSubject = null;
      appState.onboardingPhase = needsInterventionSelection
          ? StudyOnboardingPhase.interventionSelection
          : study.hasEligibilityCheck
          ? StudyOnboardingPhase.eligibility
          : StudyOnboardingPhase.terms;
    }
    context.pop();
  }

  Future<void> getConsentAndNavigateToDashboard(BuildContext context) async {
    if (subject!.study.hasConsentCheck) {
      // Accepting consent is handled inside the consent screen: it shows the
      // loading state in place and navigates directly, avoiding a
      // pop-then-push route animation. This await therefore only completes
      // on decline or when the user leaves the consent screen.
      context.read<AppState>().onboardingPhase = StudyOnboardingPhase.consent;
      final consentGiven = await context.push<bool>('/${RouteNames.consent}');
      if (!context.mounted) return;
      final appState = context.read<AppState>();
      appState.activeSubject = null;
      appState.onboardingPhase = null;
      if (consentGiven == false) {
        context.go('/${RouteNames.welcome}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.user_did_not_give_consent,
            ),
          ),
        );
        context.go('/${RouteNames.studySelection}');
      }
      await PendingDeepLinkService.clear(appState);
    } else {
      await _startStudy(context);
    }
  }

  @override
  void initState() {
    super.initState();
    subject = context.read<AppState>().activeSubject;
  }

  @override
  Widget build(BuildContext context) {
    final nav = BottomOnboardingNavigation(
      nextButtonKey: const ValueKey('journey_overview_next'),
      onBack: context.canPop() ? _goBack : null,
      onNext: () => getConsentAndNavigateToDashboard(context),
      progress: OnboardingProgress.forPage(
        context.read<AppState>(),
        OnboardingStep.journey,
      ),
    );

    final navNotifier = OnboardingNavNotifier.maybeOf(context);
    navNotifier?.register(
      this,
      '/${RouteNames.journey}',
      OnboardingNavConfig.fromNav(
        nav,
        loadingMessage: _isStartingStudy
            ? AppLocalizations.of(context)!.starting_study
            : null,
      ),
    );

    final scaffold = Scaffold(
      key: const ValueKey('journey_overview_screen'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.your_journey),
      ),
      body: TitleDescriptionLayout(
        descriptionWidget: StudyOnboardingDescription(
          text: AppLocalizations.of(context)!.journey_overview_description,
        ),
        descriptionBottomSpacing: 0,
        child: Timeline(subject: subject),
      ),
      bottomNavigationBar: navNotifier != null ? null : nav,
    );

    // In shell mode the loading overlay is rendered by OnboardingShell so it
    // covers the full screen including the persistent bottom nav.
    if (navNotifier != null) return scaffold;

    return Stack(
      children: [
        scaffold,
        if (_isStartingStudy)
          LoadingOverlay(message: AppLocalizations.of(context)!.starting_study),
      ],
    );
  }
}

class const Timeline({required final StudySubject? subject, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interventionsInOrder = subject!.getInterventionsInOrder();
    final now = DateTime.now();
    return Column(
      key: const ValueKey('journey_timeline'),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...interventionsInOrder.asMap().entries.map((entry) {
          final index = entry.key;
          final intervention = entry.value;
          return InterventionTile(
            key: ValueKey('journey_intervention_tile_$index'),
            title: intervention.name,
            iconName: intervention.icon,
            color: intervention.isBaseline()
                ? Colors.grey
                : theme.colorScheme.secondary,
            date: now.add(
              Duration(days: index * subject!.study.schedule.phaseDuration),
            ),
            isFirst: index == 0,
          );
        }),
        InterventionTile(
          key: const ValueKey('journey_results_tile'),
          title: AppLocalizations.of(context)!.journey_results_available,
          iconName: 'flagCheckered',
          color: Colors.green,
          isLast: true,
          date: subject!.endDate(now),
        ),
      ],
    );
  }
}

class const InterventionTile({
  required final String? title,
  required final String iconName,
  required final DateTime date,
  final Color? color,
  final bool isFirst = false,
  final bool isLast = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateTimePreferences = context.watch<DateTimePreferences?>();
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.4,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        indicator: IconIndicator(iconName: iconName, color: color),
      ),
      beforeLineStyle: LineStyle(color: theme.primaryColor),
      afterLineStyle: LineStyle(color: theme.primaryColor),
      endChild: TimelineChild(
        child: Text(
          title!,
          style: theme.textTheme.titleLarge!.copyWith(
            color: theme.primaryColor,
          ),
        ),
      ),
      startChild: TimelineChild(
        child: Text(
          dateTimePreferences?.formatDate(context, date) ??
              DateTimeFormat.formatDate(context, date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class const IconIndicator({
  required final String iconName,
  final Color? color,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? Theme.of(context).colorScheme.secondary,
      ),
      child: Center(
        child: Icon(MdiIconsHelper.fromString(iconName), color: Colors.white),
      ),
    );
  }
}

class const TimelineChild({super.key, final Widget? child})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minHeight: 80),
      child: Center(child: child),
    );
  }
}

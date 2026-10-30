import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/onboarding_progress.dart';
import 'package:studyu_app/util/debug_mode.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/intervention_card.dart';
import 'package:studyu_app/widgets/onboarding_shell.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';
import 'package:studyu_app/widgets/title_description_layout.dart';
import 'package:studyu_app/widgets/why_dialog.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class const InterventionSelectionScreen({super.key}) extends StatefulWidget {
  @override
  State<InterventionSelectionScreen> createState() =>
      _InterventionSelectionScreenState();
}

class _InterventionSelectionScreenState()
    extends State<InterventionSelectionScreen> {
  final List<String> selectedInterventionIds = [];
  Study? selectedStudy;

  @override
  void initState() {
    super.initState();
    selectedStudy = context.read<AppState>().selectedStudy;
    if (isDebugMode && selectedStudy != null) {
      selectedInterventionIds.addAll(
        selectedStudy!.interventions
            .take(2)
            .map((intervention) => intervention.id),
      );
    }
  }

  Widget _buildInterventionSelectionList() {
    final interventions = selectedStudy?.interventions;
    if (interventions == null || interventions.isEmpty) {
      return Text(AppLocalizations.of(context)!.no_interventions_available);
    }

    return ListView.builder(
      key: const ValueKey('intervention_selection_list'),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: interventions.length,
      itemBuilder: (context, index) => Card(
        key: ValueKey('intervention_card_${interventions[index].id}'),
        child: InterventionCard(
          interventions[index],
          showCheckbox: true,
          showDescription: false,
          selected: selectedInterventionIds.any(
            (interventionId) => interventionId == interventions[index].id,
          ),
          onTap: () => onSelect(interventions[index].id),
        ),
      ),
    );
  }

  void onSelect(String interventionId) {
    setState(() {
      if (!selectedInterventionIds.contains(interventionId)) {
        selectedInterventionIds.add(interventionId);
        if (selectedInterventionIds.length > 2) {
          selectedInterventionIds.removeAt(0);
        }
      } else {
        selectedInterventionIds.removeWhere((id) => id == interventionId);
      }
    });
  }

  void _goBack() {
    final appState = context.read<AppState>();
    if (!appState.isPreview) {
      appState.onboardingPhase = selectedStudy!.hasEligibilityCheck
          ? StudyOnboardingPhase.eligibility
          : StudyOnboardingPhase.terms;
    }
    context.pop();
  }

  Future<void> onFinished() async {
    final appState = context.read<AppState>();
    // Defense in depth: never replace a started subject's active study.
    if (!appState.isPreview && appState.activeSubject?.startedAt != null) {
      context.go('/${RouteNames.dashboard}');
      return;
    }
    appState.activeSubject = StudySubject.fromStudy(
      appState.selectedStudy!,
      Supabase.instance.client.auth.currentUser!.id,
      selectedInterventionIds,
      appState.inviteCode,
    );
    appState.onboardingPhase = StudyOnboardingPhase.journey;
    context.push('/${RouteNames.journey}');
  }

  @override
  Widget build(BuildContext context) {
    final nav = BottomOnboardingNavigation(
      nextButtonKey: const ValueKey('intervention_selection_continue'),
      onBack: context.canPop() ? _goBack : null,
      onNext: selectedInterventionIds.length == 2 ? onFinished : null,
      progress: OnboardingProgress.forPage(
        context.read<AppState>(),
        OnboardingStep.interventions,
      ),
    );

    final navNotifier = OnboardingNavNotifier.maybeOf(context);
    navNotifier?.register(
      this,
      '/${RouteNames.interventionSelection}',
      OnboardingNavConfig.fromNav(nav),
    );

    return Scaffold(
      key: const ValueKey('intervention_selection_screen'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.intervention_selection_title),
      ),
      body: TitleDescriptionLayout(
        descriptionWidget: StudyOnboardingDescription(
          text: AppLocalizations.of(context)!.please_select_interventions,
          actionLabel: AppLocalizations.of(context)!
              .please_select_interventions_why,
          onAction: () => showDialog(
            context: context,
            builder: (context) => WhyDialog(
              content: AppLocalizations.of(context)!
                  .please_select_interventions_description,
            ),
          ),
        ),
        descriptionBottomSpacing: 0,
        child: Column(
          children: [
            _buildInterventionSelectionList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: navNotifier != null ? null : nav,
    );
  }
}

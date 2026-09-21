import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/onboarding_progress.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/onboarding_shell.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_widget.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';
import 'package:studyu_app/widgets/title_description_layout.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EligibilityResult(
  final QuestionnaireState answers, {
  required final bool eligible,
  final EligibilityCriterion? firstFailed,
});

typedef EligibilityContinuation = Future<void> Function(BuildContext context);

Future<void> continueAfterEligibility(BuildContext context) async {
  final appState = context.read<AppState>();
  if (!appState.isPreview && appState.activeSubject?.startedAt != null) {
    context.go('/${RouteNames.dashboard}');
    return;
  }

  final study = appState.selectedStudy!;
  final selectedIds = appState.preselectedInterventionIds;
  if (selectedIds == null && study.interventions.length > 2) {
    appState.onboardingPhase = StudyOnboardingPhase.interventionSelection;
    context.push('/${RouteNames.interventionSelection}');
    return;
  }

  appState.activeSubject = StudySubject.fromStudy(
    study,
    Supabase.instance.client.auth.currentUser!.id,
    selectedIds ??
        study.interventions.map((intervention) => intervention.id).toList(),
    appState.inviteCode,
  );
  appState.onboardingPhase = StudyOnboardingPhase.journey;
  context.push('/${RouteNames.journey}');
}

class const EligibilityScreenArguments({
  required final Study? study,
  final EligibilityContinuation? onEligible,
});

class const EligibilityScreen({
  required final Study? study,
  final EligibilityContinuation? onEligible,
  super.key,
}) extends StatefulWidget {
  static MaterialPageRoute<EligibilityResult> routeFor({
    required Study? study,
  }) => MaterialPageRoute(
    builder: (_) => EligibilityScreen(study: study),
    settings: const RouteSettings(name: '/eligibilityCheck'),
  );

  @override
  State<StatefulWidget> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState() extends State<EligibilityScreen> {
  EligibilityResult? activeResult;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _ignoreNextNullResponse = false;

  @override
  void initState() {
    super.initState();
    activeResult = null;
  }

  void _invalidateResponse() {
    setState(() {
      activeResult = null;
    });
  }

  bool _checkContinuation(QuestionnaireState qs) {
    // Invalidate any existing result when checking continuation
    // This ensures the banner disappears when answers change
    if (activeResult != null) {
      setState(() {
        activeResult = null;
      });
    }

    final criteria = widget.study!.eligibilityCriteria;
    final EligibilityCriterion? failingResult = criteria.firstWhereOrNull((
      element,
    ) {
      return element.isViolated(qs);
    });
    if (failingResult == null) return true;
    // QuestionnaireWidget reports null after the continuation predicate stops.
    _ignoreNextNullResponse = true;
    // freetext quickfix start
    // failingResult = _isFreeTextCriterion(failingResult) ? null : failingResult;
    // freetext quickfix end
    setState(() {
      activeResult = EligibilityResult(
        qs,
        eligible: false,
        firstFailed: failingResult,
      );
    });
    return false;
  }

  void _evaluateResponse(QuestionnaireState? qs) {
    if (qs == null) {
      if (_ignoreNextNullResponse) {
        _ignoreNextNullResponse = false;
        return;
      }
      _invalidateResponse();
      return;
    }
    final criteria = widget.study!.eligibilityCriteria;
    setState(() {
      final firstFailed = criteria.firstWhereOrNull((criterion) {
        // freetext quickfix start
        /*if (_isFreeTextCriterion(criterion)) {
          print('Criterion is free text, automatically satisfying it.');
          return false;
        }*/
        // freetext quickfix end
        return !criterion.isSatisfied(qs);
      });
      final isEligible = firstFailed == null;
      if (isEligible) {
        activeResult = EligibilityResult(qs, eligible: isEligible);
      } else {
        activeResult = EligibilityResult(
          qs,
          eligible: isEligible,
          firstFailed: firstFailed,
        );
      }
    });
  }

  // todo quickfix until other question types are implemented (see DesignerV2's QuestionFormData)
  // make all free text questions eligible
  // does not work
  /*bool _isFreeTextCriterion(EligibilityCriterion criterion) {
    return widget.study?.questionnaire.questions.any((element) {
          if (criterion.condition.type == ChoiceExpression.expressionType) {
            final ChoiceExpression choiceExpression =
                criterion.condition as ChoiceExpression;
            return element.id == choiceExpression.target!;
          }
          return false;
        }) ??
        false;
  }*/

  Future<void> _finish() async {
    final result = kDebugMode && activeResult?.eligible != true
        ? EligibilityResult(
            activeResult?.answers ?? QuestionnaireState(),
            eligible: true,
          )
        : activeResult;

    if (result?.eligible == true && widget.onEligible != null) {
      await widget.onEligible!(context);
      return;
    }

    context.pop(result);
  }

  Widget _constructPassBanner() => MaterialBanner(
    key: const ValueKey('eligibility_pass_banner'),
    leading: const Icon(
      MdiIcons.checkboxMarkedCircle,
      color: Colors.green,
      size: 32,
    ),
    content: Text(
      AppLocalizations.of(context)!.eligible_yes,
      style: Theme.of(context).textTheme.titleMedium,
    ),
    actions: [Container()],
    forceActionsBelow: true,
    backgroundColor: Colors.green[50],
  );

  Widget _constructFailBanner() => MaterialBanner(
    key: const ValueKey('eligibility_fail_banner'),
    leading: const Icon(MdiIcons.closeCircle, color: Colors.red, size: 32),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.eligible_no,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        if (activeResult?.firstFailed?.reason != null)
          Text(activeResult!.firstFailed!.reason!)
        else
          const SizedBox.shrink(),
        if (activeResult?.firstFailed?.reason != null)
          const SizedBox(height: 4)
        else
          const SizedBox.shrink(),
        Text(AppLocalizations.of(context)!.eligible_mistake),
      ],
    ),
    actions: [
      TextButton(
        key: const ValueKey('eligibility_failed_back'),
        onPressed: () => context.pop(activeResult),
        child: Text(AppLocalizations.of(context)!.back),
      ),
    ],
    forceActionsBelow: true,
    backgroundColor: Colors.red[50],
  );

  Widget _constructResultBanner() =>
      activeResult!.eligible ? _constructPassBanner() : _constructFailBanner();

  @override
  Widget build(BuildContext context) {
    final nav = BottomOnboardingNavigation(
      onBack: context.canPop() ? () => context.pop() : null,
      nextButtonKey: const ValueKey('eligibility_continue'),
      onNext: activeResult?.eligible == true || kDebugMode ? _finish : null,
      progress: OnboardingProgress.forPage(
        context.read<AppState>(),
        OnboardingStep.eligibility,
      ),
    );

    final navNotifier = OnboardingNavNotifier.maybeOf(context);
    navNotifier?.register(
      this,
      '/${RouteNames.eligibilityCheck}',
      OnboardingNavConfig.fromNav(nav),
    );

    return Scaffold(
      key: const ValueKey('eligibility_screen'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.eligibility_questionnaire_title,
        ),
      ),
      body: TitleDescriptionLayout(
        descriptionWidget: StudyOnboardingDescription(
          text: AppLocalizations.of(context)!.please_answer_eligibility,
        ),
        descriptionBottomSpacing: 0,
        scrollable: false,
        bottomContent: activeResult != null ? _constructResultBanner() : null,
        child: Expanded(
          child: QuestionnaireWidget(
            widget.study!.questionnaire.questions,
            title: widget.study!.title,
            onComplete: _evaluateResponse,
            shouldContinue: _checkContinuation,
            hideCta: activeResult?.eligible == false,
            autoComplete: true,
          ),
        ),
      ),
      bottomNavigationBar: navNotifier != null ? null : nav,
    );
  }
}

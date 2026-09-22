import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/onboarding_progress.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_app/util/debug_mode.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/onboarding_shell.dart';
import 'package:studyu_app/widgets/recovery_phrase_content.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';
import 'package:studyu_app/widgets/title_description_layout.dart';
import 'package:studyu_app/widgets/why_dialog.dart';

class const RecoveryPhraseScreen({
  super.key,
  final List<String>? initialPhrase,
  final bool continueToDashboard = false,
}) extends StatefulWidget {
  @override
  State<RecoveryPhraseScreen> createState() => _RecoveryPhraseScreenState();
}

class _RecoveryPhraseScreenState() extends State<RecoveryPhraseScreen> {
  bool _isChecked = isDebugMode;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _isRevealed = widget.continueToDashboard;
  }

  Future<void> _continueToDashboard() async {
    final subjectId = context.read<AppState>().activeSubject?.id;
    if (subjectId != null) {
      await RecoveryPhraseStorage.clearPending(subjectId);
    }
    if (!mounted) return;
    context.goNamed(RouteNames.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final nav = _buildNavigation();
    final navNotifier = OnboardingNavNotifier.maybeOf(context);
    navNotifier?.register(
      this,
      '/${RouteNames.recoveryPhrase}',
      OnboardingNavConfig.fromNav(nav),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.recovery_phrase_header),
      ),
      bottomNavigationBar: navNotifier != null ? null : nav,
      body: TitleDescriptionLayout(
        descriptionWidget: StudyOnboardingDescription(
          text: localizations.recovery_phrase_description,
          actionLabel: localizations.recovery_phrase_why,
          onAction: () => showDialog(
            context: context,
            builder: (context) =>
                WhyDialog(content: localizations.recovery_phrase_reason),
          ),
        ),
        descriptionBottomSpacing: 8,
        child: _isRevealed
            ? RecoveryPhraseContent(
                initialPhrase: widget.initialPhrase,
                isChecked: _isChecked,
                useGridLayout: false,
                showRotation: false,
                onCheckedChanged: (value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
              )
            : Center(
                child: FilledButton(
                  onPressed: () => setState(() => _isRevealed = true),
                  child: Text(
                    AppLocalizations.of(context)!.show_recovery_phrase,
                  ),
                ),
              ),
      ),
    );
  }

  BottomOnboardingNavigation _buildNavigation() {
    return BottomOnboardingNavigation(
      hideBack: widget.continueToDashboard,
      onBack: widget.continueToDashboard
          ? null
          : () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(RouteNames.terms);
              }
            },
      onNext: _isChecked
          ? widget.continueToDashboard
                ? _continueToDashboard
                : () => context.pushNamed(RouteNames.studySelection)
          : null,
      nextLabel: widget.continueToDashboard
          ? AppLocalizations.of(context)!.continue_to_study
          : null,
      primaryNext: widget.continueToDashboard,
      showNextIcon: false,
      progress: widget.continueToDashboard
          ? null
          : OnboardingProgress.forPage(
              context.read<AppState>(),
              OnboardingStep.recovery,
            ),
    );
  }
}

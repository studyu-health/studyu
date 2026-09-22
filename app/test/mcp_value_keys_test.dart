import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/onboarding_screen.dart';
import 'package:studyu_app/screens/app_onboarding/terms.dart';
import 'package:studyu_app/screens/study/onboarding/consent.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/screens/study/onboarding/intervention_selection.dart';
import 'package:studyu_app/screens/study/onboarding/journey_overview.dart';
import 'package:studyu_app/screens/study/onboarding/study_overview.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/testing.dart';
import 'package:studyu_mcp/ui/app/app_ui_flow.dart';

void main() {
  testWidgets('onboarding exposes the MCP navigation keys', (tester) async {
    await _pump(tester, const OnboardingScreen());

    final next = find.byKey(const ValueKey(StudyUAppKey.onboardingNext));
    expect(next, findsOne);
    for (var page = 0; page < 4; page++) {
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const ValueKey(StudyUAppKey.onboardingDone)), findsOne);
  });

  testWidgets('legal checkboxes expose the MCP keys in debug mode', (
    tester,
  ) async {
    await _pump(
      tester,
      const Scaffold(
        body: Column(
          children: [
            LegalSection(
              title: 'Terms',
              description: 'Terms',
              acknowledgment: 'Accept terms',
              pdfUrl: 'https://example.com/terms',
              pdfUrlLabel: 'Read terms',
              isChecked: true,
              checkboxKey: ValueKey(StudyUAppKey.termsCheckbox),
              checkedKey: ValueKey(StudyUAppKey.termsCheckboxChecked),
            ),
            LegalSection(
              title: 'Privacy',
              description: 'Privacy',
              acknowledgment: 'Accept privacy',
              pdfUrl: 'https://example.com/privacy',
              pdfUrlLabel: 'Read privacy',
              isChecked: true,
              checkboxKey: ValueKey(StudyUAppKey.privacyCheckbox),
              checkedKey: ValueKey(StudyUAppKey.privacyCheckboxChecked),
            ),
          ],
        ),
      ),
    );

    expect(find.byKey(const ValueKey(StudyUAppKey.termsCheckbox)), findsOne);
    expect(
      find.byKey(const ValueKey(StudyUAppKey.termsCheckboxChecked)),
      findsOne,
    );
    expect(find.byKey(const ValueKey(StudyUAppKey.privacyCheckbox)), findsOne);
    expect(
      find.byKey(const ValueKey(StudyUAppKey.privacyCheckboxChecked)),
      findsOne,
    );
  });

  testWidgets(
    'study onboarding screens expose MCP destination and action keys',
    (tester) async {
      final study = StudyFixtures.fullValid();
      final state = AppState()..selectedStudy = study;

      await _pump(tester, const StudyOverviewScreen(), state: state);
      _expectKeys([
        StudyUAppKey.studyOverviewScreen,
        StudyUAppKey.studyOverviewNext,
      ]);

      await _pump(tester, EligibilityScreen(study: study), state: state);
      _expectKeys([
        StudyUAppKey.eligibilityScreen,
        StudyUAppKey.eligibilityContinue,
      ]);

      for (final intervention in study.interventions) {
        for (final task in intervention.tasks) {
          task.title = 'Task';
        }
      }
      study.interventions = [
        ...study.interventions,
        Intervention.withId()..name = 'Treatment C',
      ];
      await _pump(tester, const InterventionSelectionScreen(), state: state);
      _expectKeys([
        StudyUAppKey.interventionSelectionScreen,
        StudyUAppKey.interventionSelectionContinue,
      ]);
    },
  );

  testWidgets('journey and consent expose MCP destination and action keys', (
    tester,
  ) async {
    final study = StudyFixtures.fullValid();
    final state = AppState()
      ..selectedStudy = study
      ..activeSubject = StudySubject.fromStudy(
        study,
        'subject-id',
        study.interventions.map((intervention) => intervention.id).toList(),
        null,
      );

    await _pump(tester, const JourneyOverviewScreen(), state: state);
    _expectKeys([
      StudyUAppKey.journeyOverviewScreen,
      StudyUAppKey.journeyOverviewNext,
    ]);

    await _pump(tester, const ConsentScreen(), state: state);
    expect(find.byKey(const ValueKey(StudyUAppKey.consentAccept)), findsOne);
  });
}

Future<void> _pump(WidgetTester tester, Widget child, {AppState? state}) async {
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => child)],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: state ?? AppState(),
      child: MaterialApp.router(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _expectKeys(List<String> keys) {
  for (final key in keys) {
    expect(find.byKey(ValueKey(key)), findsOne, reason: 'missing $key');
  }
}

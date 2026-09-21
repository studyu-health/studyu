import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_core/core.dart';

void main() {
  testWidgets('debug can continue without eligibility answers', (tester) async {
    final question = BooleanQuestion.withId()
      ..id = 'eligible'
      ..prompt = 'Do you fulfill the criterion?';
    final criterion = EligibilityCriterion.withId()
      ..condition = (BooleanExpression()..target = question.id);
    final study = Study.withId('user')
      ..title = 'Study'
      ..interventions = [
        Intervention('first', 'First'),
        Intervention('second', 'Second'),
        Intervention('third', 'Third'),
      ]
      ..questionnaire.questions = [question]
      ..eligibilityCriteria = [criterion];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => EligibilityScreen(
            study: study,
            onEligible: continueAfterEligibility,
          ),
        ),
        GoRoute(
          path: '/interventionSelection',
          builder: (_, _) => const Scaffold(body: Text('Intervention')),
        ),
      ],
    );
    addTearDown(router.dispose);

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: AppState()..selectedStudy = study,
        child: MaterialApp.router(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Intervention'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    expect(find.byType(EligibilityScreen), findsOneWidget);
  });

  testWidgets('assesses eligibility immediately after the last answer', (
    tester,
  ) async {
    final firstQuestion = BooleanQuestion.withId()
      ..id = 'first'
      ..prompt = 'First question';
    final lastQuestion = BooleanQuestion.withId()
      ..id = 'eligible'
      ..prompt = 'Do you fulfill the criterion?';
    final criterion = EligibilityCriterion.withId()
      ..reason = 'Criterion not fulfilled'
      ..condition = (BooleanExpression()..target = lastQuestion.id);
    final study = Study.withId('user')
      ..title = 'Study'
      ..questionnaire.questions = [firstQuestion, lastQuestion]
      ..eligibilityCriteria = [criterion];
    final router = GoRouter(
      initialLocation: '/terms',
      routes: [
        GoRoute(
          path: '/terms',
          builder: (context, state) => Scaffold(
            body: Column(
              children: [
                const Text('Terms'),
                TextButton(
                  onPressed: () => context.push('/eligibility'),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/eligibility',
          builder: (context, state) => EligibilityScreen(study: study),
        ),
      ],
    );
    addTearDown(router.dispose);

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: AppState()..selectedStudy = study,
        child: MaterialApp.router(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.leading, isNull);
    expect(
      find.text(
        'Please answer a few questions to make sure that you can safely participate in this study.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();

    expect(find.text('You are eligible for this study'), findsNothing);
    expect(find.text('Complete task'), findsNothing);

    await tester.tap(find.text('yes').last);
    await tester.pumpAndSettle();

    expect(find.text('You are eligible for this study'), findsOneWidget);
    expect(find.text('Complete task'), findsNothing);

    await tester.tap(find.text('no').last);
    await tester.pumpAndSettle();

    expect(find.text('You are not eligible for this study'), findsOneWidget);
    expect(find.text('Criterion not fulfilled'), findsOneWidget);
    expect(find.text('Complete task'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('eligibility_failed_back')));
    await tester.pumpAndSettle();

    expect(find.text('Terms'), findsOneWidget);
  });

  testWidgets('unevaluable eligibility criterion fails final evaluation', (
    tester,
  ) async {
    final question = BooleanQuestion.withId()
      ..id = 'q1'
      ..prompt = 'Are you ready?';
    final criterion = EligibilityCriterion.withId()
      ..reason = 'Missing answer should fail eligibility.'
      ..condition = (BooleanExpression()..target = 'missing-question');
    final study = Study.withId('user')
      ..title = 'Eligibility Study'
      ..questionnaire.questions = [question]
      ..eligibilityCriteria = [criterion];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => EligibilityScreen(study: study),
        ),
      ],
    );
    addTearDown(router.dispose);

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: AppState()..selectedStudy = study,
        child: MaterialApp.router(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('eligibility_fail_banner')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('eligibility_pass_banner')), findsNothing);

    final nextButton = tester.widget<TextButton>(
      find.byKey(const ValueKey('eligibility_continue')),
    );
    expect(nextButton.onPressed, isNotNull);
  });
}

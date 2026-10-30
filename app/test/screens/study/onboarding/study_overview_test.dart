import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/terms.dart';
import 'package:studyu_app/screens/study/onboarding/study_overview.dart';
import 'package:studyu_core/core.dart';

void main() {
  test('regular study overview returns to study selection', () {
    final state = AppState()..selectedStudy = Study('study-1', 'owner-1');

    expect(shouldReturnToStudySelection(state), isTrue);
  });

  test('invited study overview returns to terms', () {
    final state = AppState()
      ..setPendingDeepLink(
        study: Study('study-1', 'owner-1'),
        inviteCode: 'invite-1',
      );

    expect(shouldReturnToStudySelection(state), isFalse);
  });

  testWidgets('first continue opens terms before study onboarding', (
    tester,
  ) async {
    final study = Study('study-1', 'owner-1')..title = 'Study';
    final state = AppState()..selectedStudy = study;
    TermsScreenArguments? termsArguments;
    final router = GoRouter(
      initialLocation: '/${RouteNames.studyOverview}',
      routes: [
        GoRoute(
          path: '/${RouteNames.studyOverview}',
          builder: (_, _) => const StudyOverviewScreen(),
        ),
        GoRoute(
          path: '/${RouteNames.terms}',
          builder: (_, routeState) {
            termsArguments = routeState.extra! as TermsScreenArguments;
            return const Scaffold(
              body: Text('Terms', key: ValueKey('terms_test_screen')),
            );
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsNothing);
    expect(find.byKey(const ValueKey('study_overview_back')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('study_overview_next')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('terms_test_screen')), findsOneWidget);
    expect(termsArguments, isNotNull);
  });

  testWidgets('eligibility back returns to terms before study overview', (
    tester,
  ) async {
    final study = Study('study-1', 'owner-1')
      ..title = 'Study'
      ..questionnaire.questions = [BooleanQuestion.withId()]
      ..eligibilityCriteria = [EligibilityCriterion.withId()];
    final state = AppState()..selectedStudy = study;
    late TermsScreenArguments termsArguments;
    final router = GoRouter(
      initialLocation: '/${RouteNames.studyOverview}',
      routes: [
        GoRoute(
          path: '/${RouteNames.studyOverview}',
          builder: (_, _) => const StudyOverviewScreen(),
        ),
        GoRoute(
          path: '/${RouteNames.terms}',
          builder: (context, routeState) {
            termsArguments = routeState.extra! as TermsScreenArguments;
            return Scaffold(
              body: Column(
                children: [
                  const Text('Terms', key: ValueKey('terms_test_screen')),
                  TextButton(
                    key: const ValueKey('accept_terms_test'),
                    onPressed: () => termsArguments.onAccepted(context),
                    child: const Text('Accept terms'),
                  ),
                  TextButton(
                    key: const ValueKey('back_from_terms_test'),
                    onPressed: context.pop,
                    child: const Text('Back from terms'),
                  ),
                ],
              ),
            );
          },
        ),
        GoRoute(
          path: '/${RouteNames.eligibilityCheck}',
          builder: (context, _) => Scaffold(
            body: Column(
              children: [
                const Text(
                  'Eligibility',
                  key: ValueKey('eligibility_test_screen'),
                ),
                TextButton(
                  key: const ValueKey('back_from_eligibility_test'),
                  onPressed: context.pop,
                  child: const Text('Back from eligibility'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('study_overview_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('accept_terms_test')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('eligibility_test_screen')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('back_from_eligibility_test')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('terms_test_screen')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('back_from_terms_test')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('study_overview_next')), findsOneWidget);
  });

  testWidgets('regular bottom back clears selection and opens study list', (
    tester,
  ) async {
    final study = Study('study-1', 'owner-1')..title = 'Study';
    final state = AppState()
      ..selectedStudy = study
      ..selectedInterventions = []
      ..inviteCode = 'invite-1'
      ..preselectedInterventionIds = ['intervention-1'];
    final observer = _PopObserver();
    final router = GoRouter(
      initialLocation: '/${RouteNames.studySelection}',
      observers: [observer],
      routes: [
        GoRoute(
          path: '/${RouteNames.studyOverview}',
          builder: (_, _) => const StudyOverviewScreen(),
        ),
        GoRoute(
          path: '/${RouteNames.studySelection}',
          builder: (_, _) => const Scaffold(
            body: Text(
              'Study list',
              key: ValueKey('study_selection_test_screen'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.push('/${RouteNames.studyOverview}');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('study_overview_back')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('study_selection_test_screen')),
      findsOneWidget,
    );
    expect(state.selectedStudy, isNull);
    expect(state.selectedInterventions, isNull);
    expect(state.inviteCode, isNull);
    expect(state.preselectedInterventionIds, isNull);
    expect(observer.popCount, 1);
  });

  testWidgets('pending-link bottom back pops without clearing selection', (
    tester,
  ) async {
    final study = Study('study-1', 'owner-1')..title = 'Study';
    final state = AppState()
      ..setPendingDeepLink(study: study, inviteCode: 'invite-1');
    final router = GoRouter(
      initialLocation: '/source',
      routes: [
        GoRoute(
          path: '/source',
          builder: (_, _) => const Scaffold(
            body: Text('Source', key: ValueKey('source_test_screen')),
          ),
        ),
        GoRoute(
          path: '/${RouteNames.studyOverview}',
          builder: (_, _) => const StudyOverviewScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.push('/${RouteNames.studyOverview}');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('study_overview_back')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('source_test_screen')), findsOneWidget);
    expect(state.selectedStudy, same(study));
    expect(state.hasPendingDeepLink, isTrue);
  });

  testWidgets('pending link clear does not rebuild with a null study', (
    tester,
  ) async {
    final study = Study('study-1', 'owner-1')..title = 'Study';
    final state = AppState()..setPendingDeepLink(study: study);
    final router = GoRouter(
      initialLocation: '/${RouteNames.studyOverview}',
      routes: [
        GoRoute(
          path: '/${RouteNames.studyOverview}',
          builder: (_, _) => const StudyOverviewScreen(),
        ),
        GoRoute(
          path: '/${RouteNames.studySelection}',
          builder: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    state.selectedStudy = null;
    state.clearPendingDeepLink();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

class _PopObserver() extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
    super.didPop(route, previousRoute);
  }
}

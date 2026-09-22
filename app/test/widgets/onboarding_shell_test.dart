import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/onboarding_shell.dart';

void main() {
  testWidgets('hides navigation for routes without onboarding actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingShell(
          routePath: '/studySelection',
          hideNavigation: true,
          child: Scaffold(body: SizedBox.expand()),
        ),
      ),
    );

    expect(find.byType(BottomOnboardingNavigation), findsNothing);
  });

  testWidgets('ignores navigation updates from the previous route', (
    tester,
  ) async {
    final termsOwner = Object();
    final eligibilityOwner = Object();
    OnboardingNavNotifier? notifier;
    late StateSetter updateShell;
    var routePath = '/terms';
    var termsClicks = 0;
    var eligibilityClicks = 0;

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => StatefulBuilder(
            builder: (context, setState) {
              updateShell = setState;
              final isTerms = routePath == '/terms';
              return OnboardingShell(
                routePath: routePath,
                child: Builder(
                  builder: (context) {
                    notifier = OnboardingNavNotifier.maybeOf(context)!;
                    notifier!.register(
                      isTerms ? termsOwner : eligibilityOwner,
                      routePath,
                      OnboardingNavConfig(
                        onNext: isTerms
                            ? () => termsClicks++
                            : () => eligibilityClicks++,
                      ),
                    );
                    return const Scaffold(body: SizedBox.expand());
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    final navigationElement = tester.element(
      find.byType(BottomOnboardingNavigation),
    );

    notifier!.register(
      termsOwner,
      '/terms',
      OnboardingNavConfig(onNext: () => termsClicks++),
    );
    updateShell(() => routePath = '/eligibilityCheck');
    await tester.pumpAndSettle();

    expect(
      tester.element(find.byType(BottomOnboardingNavigation)),
      same(navigationElement),
    );
    await tester.tap(find.text('Next'));

    expect(termsClicks, 0);
    expect(eligibilityClicks, 1);
  });

  testWidgets('renders the primary next action as a filled button', (
    tester,
  ) async {
    final owner = Object();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => OnboardingShell(
            routePath: '/',
            child: Builder(
              builder: (context) {
                OnboardingNavNotifier.maybeOf(context)!.register(
                  owner,
                  '/',
                  OnboardingNavConfig.fromNav(
                    const BottomOnboardingNavigation(
                      nextLabel: 'Done',
                      primaryNext: true,
                    ),
                  ),
                );
                return const Scaffold(body: SizedBox.expand());
              },
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Done'), findsOneWidget);
  });
}

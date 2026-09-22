import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/welcome.dart';
import 'package:studyu_app/screens/study/onboarding/journey_overview.dart';
import 'package:studyu_core/core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  testWidgets('declining consent clears the draft subject and pending study', (
    tester,
  ) async {
    final study = Study('study-1', 'owner-1')
      ..title = 'Study'
      ..consent = [ConsentItem('consent-1')]
      ..schedule.includeBaseline = false
      ..schedule.numberOfCycles = 0;
    final subject = StudySubject('subject-1', study.id, 'user-1', const [])
      ..study = study;
    final state = AppState()
      ..activeSubject = subject
      ..setPendingDeepLink(
        study: study,
        inviteCode: 'invite-1',
        preselectedInterventionIds: ['intervention-1'],
      );
    final router = GoRouter(
      initialLocation: '/${RouteNames.journey}',
      routes: [
        GoRoute(
          path: '/${RouteNames.journey}',
          builder: (_, _) => const JourneyOverviewScreen(),
        ),
        GoRoute(
          path: '/${RouteNames.consent}',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Decline consent'),
            ),
          ),
        ),
        GoRoute(
          path: '/${RouteNames.welcome}',
          builder: (_, _) => const WelcomeScreen(),
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

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Decline consent'));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/${RouteNames.welcome}',
    );
    expect(find.byKey(const ValueKey('invite_dialog_accept')), findsNothing);
    expect(state.activeSubject, isNull);
    expect(state.selectedStudy, isNull);
    expect(state.inviteCode, isNull);
    expect(state.preselectedInterventionIds, isNull);
    expect(state.pendingDeepLinkStudyId, isNull);
    expect(state.pendingDeepLinkInviteCode, isNull);
    expect(state.hasPendingDeepLink, isFalse);
  });
}

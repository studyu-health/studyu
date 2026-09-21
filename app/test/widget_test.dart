// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/about.dart';
import 'package:studyu_app/screens/app_onboarding/app_error_screen.dart';
import 'package:studyu_app/screens/app_onboarding/loading_screen.dart';
import 'package:studyu_app/screens/app_onboarding/restore_account_screen.dart';
import 'package:studyu_app/screens/app_onboarding/terms.dart';
import 'package:studyu_app/screens/app_onboarding/welcome.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_app/screens/study/onboarding/study_selection.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase/supabase.dart';

Widget setup(Widget child, {AppState? appState, AppLanguage? appLanguage}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => appState ?? AppState()),
      ChangeNotifierProvider<AppLanguage>.value(
        value: appLanguage ?? _TestAppLanguage(),
      ),
    ],
    child: MaterialApp.router(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => child),
          GoRoute(
            path: '/${RouteNames.about}',
            builder: (_, _) => const AboutScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.terms}',
            builder: (_, _) => const TermsScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.studySelection}',
            builder: (_, _) => const Text(
              'Study selection',
              key: ValueKey('study_selection_test_screen'),
            ),
          ),
          GoRoute(
            path: '/${RouteNames.restoreAccount}',
            name: RouteNames.restoreAccount,
            builder: (_, _) => const RestoreAccountScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.welcome}',
            builder: (_, _) => const WelcomeScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.studyOverview}',
            builder: (context, _) => Scaffold(
              body: TextButton(
                key: const ValueKey('invited_study_overview_back'),
                onPressed: context.pop,
                child: const Text('Back'),
              ),
            ),
          ),
          GoRoute(
            path: '/${RouteNames.onboarding}',
            builder: (_, _) => const Text(
              'Onboarding',
              key: ValueKey('onboarding_test_screen'),
            ),
          ),
        ],
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    setEnv(
      'https://example.supabase.co',
      'test-anon-key',
      supabaseClient: SupabaseClient('https://example.supabase.co', 'test'),
    );
  });

  test('startup session restore keeps going on backend failures', () async {
    AppConnectionStatus? connectionStatus;
    Object? capturedError;

    await tryRestoreParticipantSession(
      isLoggedIn: () => false,
      hasStoredCredentials: () async => true,
      signIn: () =>
          Future<void>.error(Exception('ClientException: Failed to fetch')),
      onConnectionStatusChanged: (status) => connectionStatus = status,
      onError: (error) => capturedError = error,
    );

    expect(connectionStatus, AppConnectionStatus.backendUnavailable);
    expect(capturedError, isNotNull);
  });

  test('maps deleted subject failure to deleted study app error', () {
    final args = appErrorArgumentsForSubjectLoadFailure(
      selectedSubjectId: 'subject-1',
      error: const SubjectDeletedException(),
    );

    expect(args.selectedSubjectId, 'subject-1');
    expect(args.reason, AppErrorReason.deletedStudy);
  });

  test('maps cache failure to cache unavailable app error', () {
    final args = appErrorArgumentsForSubjectLoadFailure(
      selectedSubjectId: 'subject-1',
      error: const SubjectCacheUnavailableException('No cached subject found'),
    );

    expect(args.selectedSubjectId, 'subject-1');
    expect(args.reason, AppErrorReason.cacheUnavailableMissing);
  });

  test('maps corrupt cache failure to cache corrupt app error', () {
    final args = appErrorArgumentsForSubjectLoadFailure(
      selectedSubjectId: 'subject-1',
      error: const SubjectCacheUnavailableException(
        'No backup subject provided',
      ),
    );

    expect(args.selectedSubjectId, 'subject-1');
    expect(args.reason, AppErrorReason.cacheUnavailableCorrupt);
  });

  test(
    'startup session restore skips sign-in when no stored credentials',
    () async {
      var signInCalls = 0;

      await tryRestoreParticipantSession(
        isLoggedIn: () => false,
        hasStoredCredentials: () async => false,
        signIn: () {
          signInCalls++;
          return Future<void>.value();
        },
      );

      expect(signInCalls, 0);
    },
  );

  testWidgets('welcome prioritizes study discovery', (tester) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Find what works for you'), findsOneWidget);
    final heading = tester.widget<Text>(find.text('Find what works for you'));
    expect(heading.style?.fontWeight, isNot(FontWeight.w600));
    expect(find.text('Made with ♥ in Potsdam'), findsOneWidget);
    expect(
      find.text('Choose a public study or use an invitation.'),
      findsNothing,
    );
    expect(
      find.widgetWithText(FilledButton, 'Browse public studies'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Join with an invite code'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'Restore account'), findsOneWidget);
  });

  testWidgets('welcome language picker changes the app language', (
    tester,
  ) async {
    final appLanguage = _TestAppLanguage();
    await tester.pumpWidget(
      setup(const WelcomeScreen(), appLanguage: appLanguage),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('welcome_language_picker')));
    await tester.pumpAndSettle();

    expect(find.text('Korean'), findsOneWidget);
    await tester.tap(find.text('Korean').last);
    await tester.pumpAndSettle();

    expect(appLanguage.appLocal, const Locale('ko'));
  });

  testWidgets('invite dialog returns after backing out of study overview', (
    tester,
  ) async {
    final state = AppState()
      ..setPendingDeepLink(
        study: Study('study-1', 'owner-1')..title = 'Study',
        inviteCode: 'invite-1',
      );
    await tester.pumpWidget(setup(const WelcomeScreen(), appState: state));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('invite_dialog_accept')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('invited_study_overview_back')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byKey(const ValueKey('invite_dialog_accept')), findsOneWidget);
  });

  testWidgets('restore account opens restore account route', (tester) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restore account'));
    await tester.pumpAndSettle();

    expect(find.byType(RestoreAccountScreen), findsOneWidget);
  });

  testWidgets('browse action opens study selection directly', (tester) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('welcome_get_started')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('study_selection_test_screen')),
      findsOneWidget,
    );
    expect(find.byType(TermsScreen), findsNothing);
  });

  testWidgets('study selection uses top app bar navigation', (tester) async {
    await tester.pumpWidget(setup(const StudySelectionScreen()));
    await tester.pump();

    expect(
      find.widgetWithText(AppBar, 'Browse public studies'),
      findsOneWidget,
    );
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Please select a study.'), findsNothing);
    expect(find.widgetWithText(TextButton, 'Back'), findsNothing);
    expect(
      find.byKey(const ValueKey('study_selection_invite_code')),
      findsNothing,
    );
  });

  testWidgets(
    'study selection shows an alternative when no public studies exist',
    (tester) async {
      await tester.pumpWidget(
        setup(
          StudySelectionScreen(
            publicStudies: Future.value(ExtractionSuccess<Study>([])),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NoPublicStudiesWidget), findsOneWidget);
      expect(
        find.text(
          'There are currently no public studies available. If you have an invite code, you can still join a private study.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'study selection shows a banner and extracted studies when some studies fail to load',
    (tester) async {
      final study = Study('study-1', 'owner-1')
        ..title = 'Study'
        ..iconName = 'account';
      await tester.pumpWidget(
        setup(
          StudySelectionScreen(
            publicStudies: Future.value(
              ExtractionFailedException<Study>(
                [study],
                [JsonWithError(const {}, Exception('invalid json'))],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MaterialBanner), findsOneWidget);
      expect(
        find.textContaining('Some studies could not be displayed'),
        findsOneWidget,
      );
      expect(find.text('Study'), findsOneWidget);
    },
  );

  testWidgets('study selection opens the why dialog', (tester) async {
    await tester.pumpWidget(
      setup(
        StudySelectionScreen(
          publicStudies: Future.value(ExtractionSuccess<Study>([])),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Why?'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.text(
        'If you were to participate in multiple studies at a time, the interventions of these studies might interfere with one another and alter the results.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping a study opens the study overview', (tester) async {
    final study = Study('study-1', 'owner-1')
      ..title = 'Study'
      ..iconName = 'account';
    final appState = AppState();
    await tester.pumpWidget(
      setup(
        StudySelectionScreen(
          publicStudies: Future.value(ExtractionSuccess<Study>([study])),
        ),
        appState: appState,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('invited_study_overview_back')),
      findsOneWidget,
    );
    expect(appState.selectedStudy, same(study));
  });

  testWidgets('study selection scrolls to the last study in a short viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final studies = List.generate(
      30,
      (index) => Study('study-$index', 'owner-1')
        ..title = 'Study $index'
        ..iconName = 'account',
    );
    await tester.pumpWidget(
      setup(
        StudySelectionScreen(
          publicStudies: Future.value(ExtractionSuccess<Study>(studies)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Study 29'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Study 29'),
      400,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('Study 29'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invite action opens invite code dialog over welcome', (
    tester,
  ) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('welcome_use_invite_code')));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(InviteCodeDialog), findsOneWidget);
    expect(find.text('Enter invite code'), findsOneWidget);
    expect(
      find.text('Enter the code shared by your study team.'),
      findsOneWidget,
    );
    expect(find.byType(TermsScreen), findsNothing);
  });

  test('dismissed active-study warning continues to the dashboard', () {
    expect(activeStudyDeepLinkRoute(null), '/${RouteNames.dashboard}');
  });

  test('restore account route is registered by name', () {
    final router = createAppRouter(queryParameters: const {});

    expect(router.namedLocation(RouteNames.restoreAccount), '/restoreAccount');
  });

  test('opens welcome screen when tour is completed without preview', () {
    expect(
      initialRouteForMissingSubjectRoute(
        isPreview: false,
        isDebugMode: false,
        onBoarded: true,
      ),
      '/${RouteNames.welcome}',
    );
  });

  test('opens onboarding when tour is not completed', () {
    expect(
      initialRouteForMissingSubjectRoute(
        isPreview: false,
        isDebugMode: false,
        onBoarded: false,
      ),
      '/${RouteNames.onboarding}',
    );
  });

  test('keeps designer preview on study terms', () {
    expect(
      initialRouteForMissingSubjectRoute(
        isPreview: true,
        isDebugMode: false,
        onBoarded: false,
      ),
      '/${RouteNames.terms}',
    );
  });

  test('dashboard showcase waits until next-day study has started', () {
    final now = DateTime(2026, 7, 10, 12);

    expect(
      isDashboardShowcaseEligible(
        startedAt: DateTime(2026, 7, 11),
        now: now,
        isPreview: false,
        checkStarted: false,
      ),
      isFalse,
    );
    expect(
      isDashboardShowcaseEligible(
        startedAt: DateTime(2026, 7, 10),
        now: now,
        isPreview: false,
        checkStarted: false,
      ),
      isTrue,
    );
    expect(shouldMarkDashboardShowcaseCompleted(wasStarted: false), isFalse);
    expect(shouldMarkDashboardShowcaseCompleted(wasStarted: true), isTrue);
  });

  test('skips onboarding in debug mode', () {
    expect(
      initialRouteForMissingSubjectRoute(
        isPreview: false,
        isDebugMode: true,
        onBoarded: false,
      ),
      '/${RouteNames.welcome}',
    );
  });

  testWidgets('welcome keeps debug controls out of the entry hub', (
    tester,
  ) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('welcome_debug_onboarding')),
      findsNothing,
    );
  });

  testWidgets('terms back falls back to welcome without previous screen', (
    tester,
  ) async {
    await tester.pumpWidget(setup(const TermsScreen()));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('terms_back')));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('terms back preserves pending invite state', (tester) async {
    final study = Study('study-1', 'owner-1')..title = 'Study';
    final appState = AppState()
      ..setPendingDeepLink(study: study, inviteCode: 'invite-1');
    const overview = Text('Study overview');
    await tester.pumpWidget(setup(overview, appState: appState));
    await tester.pumpAndSettle();

    GoRouter.of(tester.element(find.byWidget(overview)))
        .push('/${RouteNames.terms}');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('terms_back')));
    await tester.pumpAndSettle();

    expect(appState.hasPendingDeepLink, isTrue);
    expect(appState.selectedStudy, same(study));
  });

  testWidgets('about get started opens study selection', (tester) async {
    await tester.pumpWidget(setup(const WelcomeScreen()));
    await tester.pumpAndSettle();

    final about = find.byKey(const ValueKey('welcome_about'));
    await tester.ensureVisible(about);
    await tester.tap(about);
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(0, -10000));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Get started'));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('study_selection_test_screen')),
      findsOneWidget,
    );
    expect(find.byType(TermsScreen), findsNothing);
    expect(find.byType(AboutScreen), findsNothing);
  });
}

class _TestAppLanguage() extends ChangeNotifier implements AppLanguage {
  Locale? _locale = const Locale('en');

  @override
  Locale? get appLocal => _locale;

  @override
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  @override
  Future<void> changeLanguage(Locale? locale) async {
    _locale = locale;
    notifyListeners();
  }

  @override
  Future<void> fetchLocale() async {}

  @override
  Future<void> synchronizeWithServer() async {}
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/restore_account_screen.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_core/core.dart';

final _validPhrase = encode(BigInt.one).join(' ');

Widget _wrap(Widget child) {
  return ChangeNotifierProvider(
    create: (_) => AppState(),
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

Widget _routerApp(GoRouter router) {
  return ChangeNotifierProvider(
    create: (_) => AppState(),
    child: MaterialApp.router(
      routerConfig: router,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('en'),
    ),
  );
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/restore',
    routes: [
      GoRoute(
        path: '/restore',
        name: RouteNames.restoreAccount,
        builder: (_, _) => const RestoreAccountScreen(),
      ),
      GoRoute(
        path: '/loading',
        name: RouteNames.loading,
        builder: (_, _) => const Scaffold(body: Text('Loading destination')),
      ),
      GoRoute(
        path: '/studies',
        name: RouteNames.studySelection,
        builder: (_, _) =>
            const Scaffold(body: Text('Study selection destination')),
      ),
    ],
  );
}

Future<void> _enterValidPhrase(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField), _validPhrase);
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  final storage = <String, String>{};

  setUp(() {
    storage.clear();
    RestoreAccountService.debugUserLoggedInForTesting = () => false;
    RestoreAccountService.debugConfigureRecoveryForTesting(
      confirmRecovery: () async => true,
      cancelNotifications: (_) async {},
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
          final arguments = call.arguments as Map<Object?, Object?>;
          final key = arguments['key'] as String?;
          return switch (call.method) {
            'write' => storage[key!] = arguments['value']! as String,
            'read' => storage[key],
            'delete' => storage.remove(key),
            _ => throw UnimplementedError(call.method),
          };
        });
  });

  tearDown(() {
    RestoreAccountService.debugResetRecoveryForTesting();
    RestoreAccountService.debugResetUserLoggedInForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  testWidgets('disables restore when recovery phrase has too many words', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const RestoreAccountScreen()));

    await tester.enterText(
      find.byType(TextFormField),
      'one two three four five six seven eight nine ten eleven twelve thirteen fourteen',
    );
    await tester.pump();

    expect(
      find.text(
        'Recovery phrases have 13 words. Remove extra words to continue.',
      ),
      findsWidgets,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Restore account'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('enables restore for exactly 13 valid recovery words', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const RestoreAccountScreen()));

    await _enterValidPhrase(tester);

    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Restore account'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('shows a safe message for an invalid recovery phrase checksum', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const RestoreAccountScreen()));
    final invalidWords = List<String>.from(encode(BigInt.one));
    invalidWords[12] = 'abandon';

    await tester.enterText(find.byType(TextFormField), invalidWords.join(' '));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Restore account'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'This recovery phrase does not match an account. Make sure all 13 words are in the right order.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Checksum mismatch'), findsNothing);
    expect(find.textContaining('ArgumentError'), findsNothing);
  });

  testWidgets('asks signed-in users to confirm account restoration', (
    tester,
  ) async {
    var recoveryCalls = 0;
    RestoreAccountService.debugUserLoggedInForTesting = () => true;
    RestoreAccountService.debugConfigureRecoveryForTesting(
      recoverAccount: (_) async {
        recoveryCalls++;
        return RecoveryResult(success: false);
      },
    );
    await tester.pumpWidget(_wrap(const RestoreAccountScreen()));

    await _enterValidPhrase(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Restore account'));
    await tester.pumpAndSettle();

    expect(find.text('Already signed in'), findsOneWidget);
    expect(
      find.text(
        'You are already signed in on this device. Restoring an account will replace the current account. Your recovery phrase remains valid after recovery.',
      ),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Restore account'), findsNWidgets(3));
    expect(recoveryCalls, 0);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(recoveryCalls, 0);
  });

  testWidgets('restores after a signed-in user confirms', (tester) async {
    var recoveryCalls = 0;
    RestoreAccountService.debugUserLoggedInForTesting = () => true;
    RestoreAccountService.debugConfigureRecoveryForTesting(
      recoverAccount: (_) async {
        recoveryCalls++;
        return RecoveryResult(
          success: true,
          email: 'recovered@example.com',
          password: 'password',
        );
      },
      storeCredentials: (_, _) async {},
      signInParticipant: () async => true,
      clearActiveSubjectState: () async {},
    );
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_routerApp(router));

    await _enterValidPhrase(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Restore account'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Restore account'),
      ),
    );
    await tester.pumpAndSettle();

    expect(recoveryCalls, 1);
    expect(find.text('Study selection destination'), findsOneWidget);
  });

  testWidgets('routes recovered accounts with a subject to loading', (
    tester,
  ) async {
    RestoreAccountService.debugConfigureRecoveryForTesting(
      recoverAccount: (_) async => RecoveryResult(
        success: true,
        email: 'recovered@example.com',
        password: 'password',
        subjectId: 'subject-id',
      ),
      storeCredentials: (_, _) async {},
      signInParticipant: () async => true,
      clearActiveSubjectState: () async {},
    );
    RestoreAccountService.debugSubjectGetterForTesting = (_) async =>
        StudySubject('subject-id', 'study-id', 'user-id', const []);
    addTearDown(RestoreAccountService.debugResetSubjectGetterForTesting);
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_routerApp(router));

    await _enterValidPhrase(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Restore account'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Loading destination'), findsOneWidget);
  });

  testWidgets(
    'routes recovered accounts without a subject to study selection',
    (tester) async {
      RestoreAccountService.debugConfigureRecoveryForTesting(
        recoverAccount: (_) async => RecoveryResult(
          success: true,
          email: 'recovered@example.com',
          password: 'password',
        ),
        storeCredentials: (_, _) async {},
        signInParticipant: () async => true,
        clearActiveSubjectState: () async {},
      );
      final router = _router();
      addTearDown(router.dispose);
      await tester.pumpWidget(_routerApp(router));

      await _enterValidPhrase(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Restore account'));
      await tester.pumpAndSettle();

      expect(find.text('Study selection destination'), findsOneWidget);
    },
  );

  testWidgets('maps server errors to a safe recovery failure message', (
    tester,
  ) async {
    RestoreAccountService.debugConfigureRecoveryForTesting(
      recoverAccount: (_) async => RecoveryResult(
        success: false,
        error: 'database connection refused: secret-host',
      ),
    );
    await tester.pumpWidget(_wrap(const RestoreAccountScreen()));

    await _enterValidPhrase(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Restore account'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Recovery failed. Please check your recovery phrase and try again.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('secret-host'), findsNothing);
  });

  testWidgets('maps network failures to a safe connection message', (
    tester,
  ) async {
    RestoreAccountService.debugConfigureRecoveryForTesting(
      recoverAccount: (_) async => throw Exception('socket error: secret-host'),
    );
    await tester.pumpWidget(_wrap(const RestoreAccountScreen()));

    await _enterValidPhrase(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Restore account'));
    await tester.pumpAndSettle();

    expect(
      find.text('Network error. Please check your connection and try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('secret-host'), findsNothing);
  });
}

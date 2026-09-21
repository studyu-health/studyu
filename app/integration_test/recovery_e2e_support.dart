import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/app.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/main.dart' as app;
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const activeRecoveryId = '00000000-0000-4000-8000-000000000010';
const noStudyRecoveryId = '00000000-0000-4000-8000-000000000020';
const confirmationRecoveryId = '00000000-0000-4000-8000-000000000030';

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  // Network/auth navigation includes timers that make pumpAndSettle unsuitable
  // for the production app. Pump only until the expected production UI appears.
  for (var i = 0; i < 60; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 500));
  }
  expect(finder, findsWidgets);
}

Future<void> waitForAbsent(WidgetTester tester, Finder finder) async {
  // Dialog routes stay mounted while their exit animation runs. Wait until the
  // dialog leaves the tree before interacting with the screen underneath, so
  // taps cannot land on the departing dialog or its barrier.
  for (var i = 0; i < 60; i++) {
    if (finder.evaluate().isEmpty) return;
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(finder, findsNothing);
}

Future<void> launchCleanApp(WidgetTester tester) async {
  await app.main();
  await waitFor(tester, find.byKey(const ValueKey('welcome_restore_account')));
}

/// Starts a test case from the signed-out Welcome screen.
///
/// Use in a merged flutter-drive suite where one process runs several
/// recovery cases. The test framework unmounts the widget tree after every
/// testWidgets case, so each case must re-attach the app. This helper:
/// 1. Signs out. This also removes the persisted Supabase session.
/// 2. Deletes stored participant data: credentials, subject selection,
///    subject cache, onboarding flag, pending deep links.
/// 3. Clears the recovery-phrase cache, which is process-wide static state.
/// 4. Re-attaches the app at the loading route. It must not call main()
///    again: Supabase and other process-level singletons allow only one
///    initialization per process. The loading flow resolves the
///    signed-out state to the Welcome screen.
///
/// Limits: process-level state outside these singletons stays. The app
/// widget tree, router, and AppState are fresh, but the process is not.
/// CI keeps the confirmation target in a separate flutter-drive process
/// for its launch-time sign-in path.
Future<void> resetToSignedOut(WidgetTester tester) async {
  await Supabase.instance.client.auth.signOut();
  await deleteLocalData();
  await SecureStorage.delete('onboarded');
  await PendingDeepLinkService.clearStorage();
  RestoreAccountService.clearCache();
  // This application uses Provider rather than Riverpod, so it does not
  // need a ProviderScope. main() runs runApp with the same ignore.
  // ignore: riverpod_lint/missing_provider_scope
  runApp(
    MyApp(
      Uri.base.queryParameters,
      null,
      initialRoute: '/${RouteNames.loading}',
    ),
  );
  await waitFor(tester, find.byKey(const ValueKey('welcome_restore_account')));
}

String phraseFor(String uuid) =>
    encode(BigInt.parse(uuid.replaceAll('-', ''), radix: 16)).join(' ');

Future<void> openRestoreAccount(WidgetTester tester) async {
  final restore = find.byKey(const ValueKey('welcome_restore_account'));
  expect(restore, findsOneWidget);
  await tester.tap(restore);
  await waitFor(tester, find.byType(TextFormField));
}

Future<void> submitPhrase(WidgetTester tester, String uuid) async {
  await tester.enterText(find.byType(TextFormField), phraseFor(uuid));
  await tester.pump();
  await tester.tap(find.widgetWithText(FilledButton, 'Restore account'));
}

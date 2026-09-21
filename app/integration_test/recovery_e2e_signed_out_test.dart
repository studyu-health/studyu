import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'recovery_e2e_support.dart';

// Merged from the former active, no_study, and reused_phrase targets so CI
// compiles the app once for all three cases. The test framework unmounts the
// widget tree after every testWidgets case. resetToSignedOut re-attaches the
// app and clears persisted participant data between cases, but the process
// stays alive: Supabase and process-level statics are never reset. See
// resetToSignedOut in recovery_e2e_support.dart for the limits.
//
// Declaration order matters. The reused-phrase case must run after the
// active-subject case. It restores the same recovery phrase that the
// active-subject case already consumed. Unlike the former separate-process
// target, it covers restore after resetToSignedOut. It does not cover
// restore in a brand-new browser process.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('recovers an active subject with persisted progress', (
    tester,
  ) async {
    await launchCleanApp(tester);
    await openRestoreAccount(tester);
    await submitPhrase(tester, activeRecoveryId);

    await waitFor(tester, find.text('Dashboard'));
    // This marker is rendered only when the recovered subject has persisted
    // subject_progress, rather than merely when the dashboard is present.
    expect(
      find.byKey(const ValueKey('dashboard_persisted_progress')),
      findsOneWidget,
    );
  });

  testWidgets('recovers a no-study account to public study selection', (
    tester,
  ) async {
    await resetToSignedOut(tester);
    await openRestoreAccount(tester);
    await submitPhrase(tester, noStudyRecoveryId);

    await waitFor(tester, find.text('Browse public studies'));
    expect(find.text('Dashboard'), findsNothing);
    expect(find.textContaining('Something went wrong'), findsNothing);
  });

  testWidgets(
    'restores with the same recovery phrase after a completed recovery',
    (tester) async {
      await resetToSignedOut(tester);
      await openRestoreAccount(tester);
      await submitPhrase(tester, activeRecoveryId);
      await waitFor(tester, find.text('Dashboard'));
    },
  );
}

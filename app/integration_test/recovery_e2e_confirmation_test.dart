import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'recovery_e2e_support.dart';

// Uses waitForAbsent from recovery_e2e_support.dart after Cancel so the
// departing dialog route cannot intercept the resubmission taps.

const _signedInUserId = '55555555-5555-4555-8555-555555555555';
const _recoveryTargetUserId = '77777777-7777-4777-8777-777777777777';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('confirms before replacing an already signed-in account', (
    tester,
  ) async {
    // The E2E dart-defines make production startup store local fixture
    // credentials. LoadingScreen then signs in through signInParticipant,
    // the same app path used to restore a participant session.
    await launchCleanApp(tester);
    expect(Supabase.instance.client.auth.currentUser?.id, _signedInUserId);
    expect(
      find.byKey(const ValueKey('welcome_restore_account')),
      findsOneWidget,
    );

    await openRestoreAccount(tester);
    await submitPhrase(tester, confirmationRecoveryId);
    await waitFor(tester, find.text('Already signed in'));
    await tester.tap(find.text('Cancel'));
    // Wait for the dialog route to leave the tree before resubmitting; while
    // its exit animation runs, taps can hit the departing dialog instead
    // of the restore screen underneath.
    await waitForAbsent(tester, find.text('Already signed in'));
    expect(find.byType(TextFormField), findsOneWidget);
    expect(Supabase.instance.client.auth.currentUser?.id, _signedInUserId);

    // The target phrase was not consumed on cancellation: it remains usable
    // for the subsequent real confirmation and account replacement.
    await submitPhrase(tester, confirmationRecoveryId);
    await waitFor(tester, find.text('Already signed in'));
    // Tap the dialog's Restore button, not the restore screen button that
    // shares its label underneath the modal barrier.
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Restore account'),
      ),
    );
    await waitFor(tester, find.text('Browse public studies'));
    expect(
      Supabase.instance.client.auth.currentUser?.id,
      _recoveryTargetUserId,
    );
  });
}

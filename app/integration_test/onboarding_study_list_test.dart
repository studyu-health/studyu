import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:studyu_app/main.dart' as app_main;
import 'package:studyu_app/studyu_driver_state.dart';
import 'package:studyu_core/testing.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:studyu_mcp/ui/app/app_ui_flow.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(SecureStorage.deleteAll);

  testWidgets('onboarding reaches the study list', (tester) async {
    final staleStudies = [StudyFixtures.invalidBrokenEligibilityRef()];
    StudyUDriverState.visibleStudies = staleStudies;

    await app_main.main();

    final flow = StudyUAppUiFlow(
      waitForKey: (key, {required timeout}) =>
          tester.waitForValueKey(key, timeout: timeout),
      tapKey: tester.tapValueKey,
    );

    await flow.completeOnboardingToStudyList();

    expect(find.byKey(const ValueKey('study_selection_list')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('study_selection_invite_code')),
      findsOneWidget,
    );
    expect(StudyUDriverState.visibleStudies, isNot(same(staleStudies)));
  });
}

extension _StudyUWidgetTester on WidgetTester {
  Future<bool> waitForValueKey(String key, {required Duration timeout}) async {
    final finder = find.byKey(ValueKey(key));
    final deadline = binding.clock.fromNowBy(timeout);
    while (binding.clock.now().isBefore(deadline)) {
      await pump(const Duration(milliseconds: 100));
      if (any(finder)) return true;
    }
    return any(finder);
  }

  Future<void> tapValueKey(String key) async {
    final finder = find.byKey(ValueKey(key));
    await ensureVisible(finder);
    await tap(finder);
    await pumpAndSettle();
  }
}

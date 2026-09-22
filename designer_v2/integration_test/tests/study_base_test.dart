import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/app.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_navigation.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

import '../controller/robots/robots.dart';
import '../controller/study_integration_controller.dart';

abstract class StudyBaseTest.go(
  super.$,
  final Study Function() selectedMockupStudy,
) extends StudyRobots {
  final bool randomTest = true;
  final StudyIntegrationController controller = StudyIntegrationController(
    $,
    selectedMockupStudy,
  );

  Future<void> init() async {
    final email = randomTest
        ? '${DateTime.now().millisecondsSinceEpoch}@studyu.health'
        : 'test@studyu.health';
    const password = 'password';

    await super.$.tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardDispatchProvider.overrideWith(
            (ref) =>
                (studyId) => ref
                    .read(routerProvider)
                    .dispatch(RoutingIntents.studyEdit(studyId)),
          ),
        ],
        child: const ExcludeSemantics(child: App()),
      ),
    );
    await super.$.pumpAndSettle();

    await execute(email, password);
    await finish();
  }

  Future<void> execute(String email, String password) async {}

  Future<void> finish() async {
    expect(await controller.validateFinal(), true);
    // todo navigate to sign out
    //await studiesRobot.tapSignOutButton();
  }
}

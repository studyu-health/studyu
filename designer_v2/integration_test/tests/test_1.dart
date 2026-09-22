import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/src/custom_finders/patrol_tester.dart';
import 'package:studyu_core/src/env/env.dart' as env;

import '../mockup/mockup_studies.dart';
import '../test_log.dart';
import 'study_base_test.dart';

class Test1.go(PatrolTester $) extends StudyBaseTest {
  this : super.go($, MockupStudies.study1);

  @override
  Future<void> execute(String email, String password) async {
    if (randomTest) {
      await _step(
        'sign up: navigate',
        () => authRobot.navigateToSignUpScreen(),
      );
      await _step('sign up: enter email', () => authRobot.enterEmail(email));
      await _step(
        'sign up: enter password',
        () => authRobot.enterPassword(password),
      );
      await _step(
        'sign up: confirm password',
        () => authRobot.enterPasswordConfirmation(password),
      );
      await _step('sign up: accept terms', authRobot.tapTermsCheckbox);
      await _step('sign up: submit', authRobot.tapSignUpButton);
      await _step('sign up: sign out', studiesRobot.tapSignOutButton);
    }

    await _step('sign in: enter email', () => authRobot.enterEmail(email));
    await _step(
      'sign in: enter password',
      () => authRobot.enterPassword(password),
    );
    await _step('sign in: submit', authRobot.tapSignInButton);

    await _step('init controller from current user', () async {
      controller.init(env.client.auth.currentUser!.id);
    });

    await _step('create study: tap new study', studiesRobot.tapNewStudyButton);
    await _step('create study: fill title', controller.fillTitle);
    await _step(
      'create study: open left drawer',
      studyDesignRobot.tapLeftDrawerButton,
    );
    await _step(
      'create study: return to my studies',
      studyDesignRobot.tapMyStudiesButton,
    );

    await _step(
      'draft study: open existing draft',
      studiesRobot.tapOnExistingStudy,
    );
    await _step('draft study: fill info page', controller.fillInfoPage);
    await _step(
      'draft study: navigate participation screen',
      studyDesignRobot.navigateToParticipationScreen,
    );
    await _step(
      'draft study: navigate interventions screen',
      studyDesignRobot.navigateToInterventionsScreen,
    );
    await _step(
      'draft study: fill first intervention',
      () => controller.fillInterventions(
        (interventionList) => [interventionList.first],
      ),
    );
    await _step(
      'draft study: fill second intervention',
      () => controller.fillInterventions(
        (interventionList) => [interventionList.last],
      ),
    );
    await _step(
      'draft study: navigate measurements screen',
      studyDesignRobot.navigateToMeasurementsScreen,
    );
    await _step(
      'draft study: fill observations',
      () => controller.fillObservations((observationList) => observationList),
    );

    await _step(
      'publish study: tap publish button',
      studyDesignRobot.tapPublishButton,
    );
    await _step(
      'publish study: confirm publish',
      studyDesignRobot.tapConfirmPublishButton,
    );
    await _step(
      'publish study: skip follow-up',
      studyDesignRobot.tapSkipForNowButton,
    );
    await _step(
      'publish study: validate live status',
      studyDesignRobot.validateStudyPublished,
    );
    await _step(
      'publish study: open left drawer',
      studyDesignRobot.tapLeftDrawerButton,
    );
    await _step(
      'publish study: return to my studies',
      studyDesignRobot.tapMyStudiesButton,
    );
  }

  Future<T> _step<T>(String name, Future<T> Function() action) async {
    final result = await runLoggedStep(name, action);
    _drainFrameworkExceptions(name);
    return result;
  }

  void _drainFrameworkExceptions(String afterStep) {
    Object? firstException;
    Object? exception;
    while ((exception = $.tester.takeException()) != null) {
      firstException ??= exception;
      markTestStep(
        'taken-framework-exception',
        'after $afterStep',
        error: exception,
      );
    }

    if (firstException != null) {
      throw TestFailure(
        'Flutter framework exception after $afterStep: $firstException',
      );
    }
  }
}

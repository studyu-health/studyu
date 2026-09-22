import 'package:patrol_finders/patrol_finders.dart';

import 'robots.dart';

abstract class StudyRobots(final PatrolTester $) {
  final AppRobot appRobot = AppRobot($);
  final AuthRobot authRobot = AuthRobot($);
  final StudiesRobot studiesRobot = StudiesRobot($);
  final StudyDesignRobot studyDesignRobot = StudyDesignRobot($);
  final StudyInfoRobot studyInfoRobot = StudyInfoRobot($);
  final StudyInterventionsRobot studyInterventionsRobot =
      StudyInterventionsRobot($);
  final StudyMeasurementsRobot studyMeasurementsRobot = StudyMeasurementsRobot(
    $,
  );
}

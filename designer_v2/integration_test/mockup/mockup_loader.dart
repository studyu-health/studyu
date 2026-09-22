import 'package:studyu_core/core.dart';

import 'mockup_studies.dart';

class MockupLoader(final String userID, Study Function() studyRef)
    extends MockupStudies {
  this {
    MockupStudies.init(userID);
    studyRef();
    resetStudy(MockupStudies.study);
  }

  Study emptyMockupStudy() {
    final mockupStudy = Study.withId(userID);
    resetStudy(mockupStudy);
    return mockupStudy;
  }

  /// Resets a study to the expected defaults of the Designer package after it has been created
  void resetStudy(Study studyToReset) {
    void resetSchedule(List<Task> tasks) {
      for (final task in tasks) {
        task.schedule = Schedule()
          ..completionPeriods = [
            CompletionPeriod.noId(
              unlockTime: StudyUTimeOfDay(),
              lockTime: StudyUTimeOfDay(hour: 23, minute: 59),
            ),
          ];
      }
    }

    // The Designer package overrides the defaults set in the core package
    // so that's why we need to do the same here
    studyToReset
      ..iconName = ''
      ..interventions.forEach((intervention) {
        resetSchedule(intervention.tasks);
      })
      ..observations.forEach((observation) {
        resetSchedule([observation]);
      });
  }
}

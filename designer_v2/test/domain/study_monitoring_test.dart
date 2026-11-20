import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';

void main() {
  test('tracks completed nutrition periods on their scheduled UTC days', () {
    final startedAt = DateTime.utc(2026, 1, 1, 23);
    final study = Study('study', 'owner');
    study.schedule
      ..numberOfCycles = 0
      ..includeBaseline = true
      ..phaseDuration = 4;
    final diary = NutritionTask.withId()
      ..scheduleRule = TaskScheduleRule.forSpecificDays([0, 2]);
    diary.schedule.completionPeriods = [
      CompletionPeriod(
        id: 'morning',
        unlockTime: StudyUTimeOfDay(hour: 6),
        lockTime: StudyUTimeOfDay(hour: 12),
      ),
      CompletionPeriod(
        id: 'evening',
        unlockTime: StudyUTimeOfDay(hour: 12),
        lockTime: StudyUTimeOfDay(hour: 23),
      ),
    ];
    final survey = QuestionnaireTask.withId();
    study.observations = [diary, survey];
    final participant = StudySubject('subject', study.id, 'user', [])
      ..startedAt = startedAt;
    study.participants = [participant];

    SubjectProgress recall({
      required int day,
      required String periodId,
      required DateTime submittedAt,
      bool isComplete = true,
      String interventionId = Study.baselineID,
    }) => SubjectProgress(
      subjectId: participant.id,
      interventionId: interventionId,
      taskId: diary.id,
      resultType: 'DailyRecall',
      result: Result<DailyRecall>.app(
        type: 'DailyRecall',
        periodId: periodId,
        result: DailyRecall.withId(
          date: participant.nutritionDateForStudyDay(day),
          recallMode: RecallMode.realtimeRecord,
          entryCompletedAt: isComplete ? submittedAt : null,
          studyDaySnapshot: day,
          meals: [],
        ),
      ),
    )..completedAt = submittedAt;

    study.participantsProgress = [
      recall(
        day: 0,
        periodId: 'morning',
        submittedAt: DateTime.utc(2026, 1, 2, 8),
      ),
      recall(
        day: 0,
        periodId: 'morning',
        submittedAt: DateTime.utc(2026, 1, 2, 9),
      ),
      recall(
        day: 0,
        periodId: 'evening',
        submittedAt: DateTime.utc(2026, 1, 2, 10),
        isComplete: false,
      ),
      recall(
        day: 0,
        periodId: 'evening',
        submittedAt: DateTime.utc(2026, 1, 2, 11),
        interventionId: 'unassigned',
      ),
      recall(
        day: 1,
        periodId: 'morning',
        submittedAt: DateTime.utc(2026, 1, 2, 12),
      ),
      recall(
        day: 2,
        periodId: 'morning',
        submittedAt: DateTime.utc(2026, 1, 3, 8),
      ),
      recall(
        day: 2,
        periodId: 'evening',
        submittedAt: DateTime.utc(2026, 1, 4, 8),
      ),
      SubjectProgress(
        subjectId: participant.id,
        interventionId: Study.baselineID,
        taskId: survey.id,
        resultType: 'QuestionnaireState',
        result: Result<QuestionnaireState>.app(
          type: 'QuestionnaireState',
          periodId: survey.schedule.completionPeriods.single.id,
          result: QuestionnaireState(),
        ),
      )..completedAt = DateTime.utc(2026, 1, 2, 8),
    ];

    final item = study.monitorDataAt(DateTime.utc(2026, 1, 4, 10)).single;

    expect(item.currentDayOfStudy, 3);
    expect(item.completedTasksPerDay, [
      {survey.id},
      <String>{},
      {diary.id},
    ]);
    expect(item.missedTasksPerDay, [
      {diary.id},
      {survey.id},
      <String>{},
    ]);
    expect(item.completedSurveys, 4);
    expect(item.missedSurveys, 2);
    expect(item.totalSurveyTasks, 8);

    final beforeFinalRollingDay = study.monitorDataAt(
      DateTime.utc(2026, 1, 5, 10),
    );
    expect(beforeFinalRollingDay.completedParticipants, isEmpty);
    final afterFinalRollingDay = study.monitorDataAt(DateTime.utc(2026, 1, 6));
    expect(afterFinalRollingDay.completedParticipants, hasLength(1));
  });
}

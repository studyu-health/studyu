import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('advances an untracked preview without saving to the server', () async {
    final startedAt = DateTime.utc(2025, 1, 2);
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = startedAt;

    await subject.setStartDateBackBy(days: 1, persist: false);

    expect(subject.startedAt, DateTime.utc(2025));
  });

  test('uses calendar dates for study days and intervention indexes', () {
    final start = DateTime(2025, 1, 1, 1);
    final nextCalendarDate = DateTime(2025, 1, 2);
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = start
      ..study = (Study('study', 'user')
        ..schedule = (StudySchedule()..phaseDuration = 1));

    expect(nextCalendarDate.difference(start).inHours, lessThan(24));
    expect(subject.getDayOfStudyFor(start), 0);
    expect(subject.getDayOfStudyFor(nextCalendarDate), 1);
    expect(subject.getInterventionIndexForDate(nextCalendarDate), 1);
  });

  test('nutrition schedule and completion use the UTC study-day snapshot', () {
    final startedAt = DateTime.utc(2026, 1, 1, 12);
    final beforeRollover = DateTime.utc(2026, 1, 1, 23, 30);
    final afterRollover = DateTime.utc(2026, 1, 2, 0, 30);
    final dayZeroTask = NutritionTask.withId()
      ..title = 'Day zero'
      ..scheduleRule = TaskScheduleRule.forSpecificDays([0]);
    final dayOneTask = NutritionTask.withId()
      ..title = 'Day one'
      ..scheduleRule = TaskScheduleRule.forSpecificDays([1]);
    final study = Study('study', 'user')
      ..schedule = (StudySchedule()
        ..includeBaseline = false
        ..phaseDuration = 1
        ..numberOfCycles = 1)
      ..interventions = [Intervention('a', 'A'), Intervention('b', 'B')]
      ..observations = [dayZeroTask, dayOneTask];
    final subject = StudySubject.fromStudy(study, 'user', ['a', 'b'], null)
      ..startedAt = startedAt;
    final dayZeroPeriod = dayZeroTask.schedule.completionPeriods.single;
    final recall = DailyRecall.withId(
      date: beforeRollover,
      recallMode: RecallMode.realtimeRecord,
      meals: [],
      entryCompletedAt: afterRollover,
      studyDaySnapshot: 0,
    );
    subject.progress.add(
      SubjectProgress(
        subjectId: subject.id,
        taskId: dayZeroTask.id,
        resultType: 'DailyRecall',
        interventionId: 'a',
        result: Result<DailyRecall>.app(
          type: 'DailyRecall',
          periodId: dayZeroPeriod.id,
          result: recall,
        ),
      )..completedAt = afterRollover,
    );

    expect(subject.scheduleFor(beforeRollover).single.task, dayZeroTask);
    expect(subject.scheduleFor(afterRollover).single.task, dayOneTask);
    expect(subject.getNutritionInterventionForStudyDay(0)!.id, 'a');
    expect(subject.getNutritionInterventionForStudyDay(1)!.id, 'b');
    expect(
      subject.completedTaskInstanceForDay(
        dayZeroTask.id,
        dayZeroPeriod,
        beforeRollover,
      ),
      isTrue,
    );
    expect(
      subject.completedTaskInstanceForDay(
        dayZeroTask.id,
        dayZeroPeriod,
        afterRollover,
      ),
      isFalse,
    );
    expect(subject.getResultsByDate(interventionId: 'a').keys, [
      DateTime(2026),
    ]);
  });

  test(
    'keeps an unfinished UTC nutrition period after the local phase ends',
    () {
      final now = DateTime.utc(2026, 1, 2, 22);
      final task = NutritionTask.withId();
      final firstPeriod = task.schedule.completionPeriods.single;
      task.schedule.completionPeriods.add(
        CompletionPeriod(
          id: 'period-two',
          unlockTime: StudyUTimeOfDay(hour: 12),
          lockTime: StudyUTimeOfDay(hour: 23),
        ),
      );
      final subject = _FinishedLocalStudy()
        ..startedAt = DateTime.utc(2026)
        ..study = (Study('study', 'user')
          ..schedule = (StudySchedule()
            ..includeBaseline = false
            ..phaseDuration = 1
            ..numberOfCycles = 1)
          ..interventions = [Intervention('a', 'A'), Intervention('b', 'B')]
          ..observations = [task]);
      final recall = DailyRecall.withId(
        date: now,
        recallMode: RecallMode.realtimeRecord,
        entryCompletedAt: now,
        studyDaySnapshot: 1,
        meals: [],
      );
      subject.progress.add(
        SubjectProgress(
          subjectId: subject.id,
          taskId: task.id,
          resultType: 'DailyRecall',
          interventionId: 'b',
          result: Result<DailyRecall>.app(
            type: 'DailyRecall',
            periodId: firstPeriod.id,
            result: recall,
          ),
        )..completedAt = now,
      );

      expect(subject.getInterventionForDate(now), isNull);
      expect(subject.getNutritionInterventionForStudyDay(1)!.id, 'b');
      expect(subject.getNutritionInterventionForStudyDay(2), isNull);
      expect(subject.scheduleFor(now), hasLength(2));
      expect(subject.allTasksCompletedFor(now), isFalse);
    },
  );
}

class _FinishedLocalStudy() extends StudySubject {
  this : super('subject', 'study', 'user', ['a', 'b']);

  @override
  int getDayOfStudyFor(DateTime date) => 2;
}

import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('report extraction excludes incomplete recalls', () {
    final task = NutritionTask.withId();
    final completedAt = DateTime.utc(2026, 9, 22, 18);
    final progress = [
      for (final isComplete in [false, true])
        SubjectProgress(
            subjectId: 'subject',
            interventionId: 'intervention',
            taskId: task.id,
            resultType: 'DailyRecall',
            result: Result<DailyRecall>.app(
              type: 'DailyRecall',
              periodId: 'period',
              result: DailyRecall.withId(
                date: completedAt,
                recallMode: RecallMode.realtimeRecord,
                entryCompletedAt: isComplete ? completedAt : null,
                studyDaySnapshot: 0,
                meals: [],
              ),
            ),
          )
          ..completedAt = isComplete
              ? completedAt
              : completedAt.subtract(const Duration(hours: 1)),
    ];

    expect(task.extractPropertyResults<int>('mealCount', progress), {
      completedAt: 0,
    });
    expect(task.extractPropertyResults<DateTime>('completionTime', progress), {
      completedAt: completedAt,
    });
  });

  test('new nutrition tasks serialize water tracking as disabled', () {
    final json = NutritionTask.withId().toJson();
    expect(json['trackWaterIntake'], isFalse);
    expect(NutritionTask.fromJson(json).trackWaterIntake, isFalse);
  });

  test('serializes enabled water tracking', () {
    final task = NutritionTask.withId()..trackWaterIntake = true;

    expect(NutritionTask.fromJson(task.toJson()).trackWaterIntake, isTrue);
  });

  test('loads a study when a nutrition task omits water tracking', () {
    final taskJson = NutritionTask.withId().toJson()
      ..remove('trackWaterIntake');
    final studyJson = Study('study', 'researcher').toJson()
      ..['observations'] = [taskJson];

    final study = Study.fromJson(studyJson);
    final task = study.observations.single as NutritionTask;

    expect(task.trackWaterIntake, isFalse);
    expect(task.toJson()['trackWaterIntake'], isFalse);
  });

  test('rejects a null water tracking setting', () {
    final taskJson = NutritionTask.withId().toJson()
      ..['trackWaterIntake'] = null;

    expect(
      () => NutritionTask.fromJson(taskJson),
      throwsA(isA<DisallowedNullValueException>()),
    );
  });

  test('only completed daily recalls satisfy task completion', () {
    final date = DateTime(2026, 7, 15);
    final period = CompletionPeriod(
      id: 'period',
      unlockTime: StudyUTimeOfDay(),
      lockTime: StudyUTimeOfDay(hour: 23),
    );
    final task = NutritionTask.withId();
    task.schedule.completionPeriods = [period];
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = date
      ..study = (Study('study', 'user')
        ..schedule.includeBaseline = true
        ..schedule.numberOfCycles = 0
        ..observations = [task]);

    SubjectProgress progressFor(Result result) => SubjectProgress(
      subjectId: subject.id,
      interventionId: Study.baselineID,
      taskId: task.id,
      resultType: result.type,
      result: result,
    )..completedAt = date;

    subject.progress = [
      progressFor(
        Result<DailyRecall>.app(
          type: 'DailyRecall',
          periodId: period.id,
          result: DailyRecall(
            id: 'recall',
            date: date,
            recallMode: RecallMode.realtimeRecord,
            entryStartedAt: date,
            studyDaySnapshot: 0,
            meals: [],
          ),
        ),
      ),
    ];
    expect(subject.completedTaskInstanceForDay(task.id, period, date), isFalse);

    subject.progress = [
      progressFor(
        Result<DailyRecall>.app(
          type: 'DailyRecall',
          periodId: period.id,
          result: DailyRecall(
            id: 'recall',
            date: date,
            recallMode: RecallMode.realtimeRecord,
            entryStartedAt: date,
            studyDaySnapshot: 0,
            entryCompletedAt: date,
            meals: [],
          ),
        ),
      ),
    ];
    expect(subject.completedTaskInstanceForDay(task.id, period, date), isTrue);

    subject.progress = [
      progressFor(
        Result<bool>.app(type: 'bool', periodId: period.id, result: true),
      ),
    ];
    expect(subject.completedTaskInstanceForDay(task.id, period, date), isTrue);
  });
}

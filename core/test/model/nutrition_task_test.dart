import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('report extraction excludes legacy drafts', () {
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

  test('only completed daily recalls satisfy task completion', () {
    final date = DateTime(2026, 7, 15);
    final period = CompletionPeriod(
      id: 'period',
      unlockTime: StudyUTimeOfDay(),
      lockTime: StudyUTimeOfDay(hour: 23),
    );
    final subject = StudySubject('subject', 'study', 'user', []);

    SubjectProgress progressFor(Result result) => SubjectProgress(
      subjectId: subject.id,
      interventionId: 'intervention',
      taskId: 'task',
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
            meals: [],
          ),
        ),
      ),
    ];
    expect(subject.completedTaskInstanceForDay('task', period, date), isFalse);

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
            entryCompletedAt: date,
            meals: [],
          ),
        ),
      ),
    ];
    expect(subject.completedTaskInstanceForDay('task', period, date), isTrue);

    subject.progress = [
      progressFor(
        Result<bool>.app(type: 'bool', periodId: period.id, result: true),
      ),
    ];
    expect(subject.completedTaskInstanceForDay('task', period, date), isTrue);
  });
}

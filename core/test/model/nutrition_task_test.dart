import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('missing completion confirmation defaults to required', () {
    final task = NutritionTask.withId();
    final json = task.toJson()..remove('requireDailyCompletionConfirmation');

    expect(
      NutritionTask.fromJson(json).requireDailyCompletionConfirmation,
      isTrue,
    );
  });

  test('serializes an explicitly optional daily completion', () {
    final task = NutritionTask.withId()
      ..requireDailyCompletionConfirmation = false;

    final restored = NutritionTask.fromJson(task.toJson());

    expect(restored.requireDailyCompletionConfirmation, isFalse);
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

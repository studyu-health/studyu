import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/models/deferred_fitbit_request.dart';

DeferredFitbitRequest _buildRequest() {
  return DeferredFitbitRequest(
    subjectId: 'subject-1',
    interventionId: 'intervention-1',
    taskId: 'task-1',
    periodId: 'period-1',
    questionId: 'question-1',
    windowStart: DateTime.utc(2026, 1, 1, 8),
    windowEnd: DateTime.utc(2026, 1, 1, 20),
    completedAt: DateTime.utc(2026, 1, 1, 20, 5),
  );
}

void main() {
  test('round-trips through JSON without losing any field', () {
    final request = _buildRequest();
    final restored = DeferredFitbitRequest.fromJson(request.toJson());

    expect(restored.subjectId, request.subjectId);
    expect(restored.interventionId, request.interventionId);
    expect(restored.taskId, request.taskId);
    expect(restored.periodId, request.periodId);
    expect(restored.questionId, request.questionId);
    expect(restored.windowStart, request.windowStart);
    expect(restored.windowEnd, request.windowEnd);
    expect(restored.completedAt, request.completedAt);
  });

  test('id identifies a request by subject, intervention, task, period, '
      'question, and completedAt', () {
    final request = _buildRequest();
    final sameKey = DeferredFitbitRequest(
      subjectId: request.subjectId,
      interventionId: request.interventionId,
      taskId: request.taskId,
      periodId: request.periodId,
      questionId: request.questionId,
      windowStart: DateTime.utc(2020), // window doesn't affect identity
      windowEnd: DateTime.utc(2020, 1, 2),
      completedAt: request.completedAt,
    );

    expect(sameKey.id, request.id);
  });

  test('id differs when completedAt differs (two completions on different '
      'days are distinct requests)', () {
    final request = _buildRequest();
    final laterCompletion = DeferredFitbitRequest(
      subjectId: request.subjectId,
      interventionId: request.interventionId,
      taskId: request.taskId,
      periodId: request.periodId,
      questionId: request.questionId,
      windowStart: request.windowStart,
      windowEnd: request.windowEnd,
      completedAt: request.completedAt.add(const Duration(days: 1)),
    );

    expect(laterCompletion.id, isNot(request.id));
  });

  test('id differs when questionId differs (two Fitbit questions on the '
      'same task/period are independent requests)', () {
    final request = _buildRequest();
    final otherQuestion = DeferredFitbitRequest(
      subjectId: request.subjectId,
      interventionId: request.interventionId,
      taskId: request.taskId,
      periodId: request.periodId,
      questionId: 'question-2',
      windowStart: request.windowStart,
      windowEnd: request.windowEnd,
      completedAt: request.completedAt,
    );

    expect(otherQuestion.id, isNot(request.id));
  });
}

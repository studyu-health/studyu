import 'package:studyu_core/core.dart';

/// A Fitbit data fetch deferred because the device was offline when a
/// Fitbit-based question was answered.
///
/// Identity ([id]) is `(subjectId, interventionId, taskId, periodId,
/// questionId, completedAt)` — spec.md's dedup key omits `questionId`
/// ("effectively"), but a single questionnaire task can have more than one
/// `FitbitQuestion`, so it's included here to keep two such questions'
/// requests from colliding.
class DeferredFitbitRequest({
  required final String subjectId,
  required final String interventionId,
  required final String taskId,
  required final String periodId,
  required final String questionId,
  required final DateTime windowStart,
  required final DateTime windowEnd,
  required final DateTime completedAt,
  final Map<FitbitQuestionType, DateTime> windowStarts = const {},
  final QuestionnaireState? questionnaireState,
}) {
  String get id =>
      '$subjectId:$interventionId:$taskId:$periodId:$questionId:'
      '${completedAt.toUtc().toIso8601String()}';

  factory fromJson(Map<String, dynamic> json) => DeferredFitbitRequest(
    subjectId: json['subjectId'] as String,
    interventionId: json['interventionId'] as String,
    taskId: json['taskId'] as String,
    periodId: json['periodId'] as String,
    questionId: json['questionId'] as String,
    windowStart: DateTime.parse(json['windowStart'] as String),
    windowEnd: DateTime.parse(json['windowEnd'] as String),
    completedAt: DateTime.parse(json['completedAt'] as String),
    windowStarts: {
      for (final entry
          in (json['windowStarts'] as Map<String, dynamic>? ?? {}).entries)
        FitbitQuestionType.values.byName(entry.key): DateTime.parse(
          entry.value as String,
        ),
    },
    questionnaireState: json['questionnaireState'] == null
        ? null
        : QuestionnaireState.fromJson(
            List<Map<String, dynamic>>.from(json['questionnaireState'] as List),
          ),
  );

  Map<String, dynamic> toJson() => {
    'subjectId': subjectId,
    'interventionId': interventionId,
    'taskId': taskId,
    'periodId': periodId,
    'questionId': questionId,
    'windowStart': windowStart.toIso8601String(),
    'windowEnd': windowEnd.toIso8601String(),
    'completedAt': completedAt.toIso8601String(),
    if (windowStarts.isNotEmpty)
      'windowStarts': windowStarts.map(
        (type, start) => MapEntry(type.name, start.toIso8601String()),
      ),
    if (questionnaireState != null)
      'questionnaireState': questionnaireState!.toJson(),
  };
}

import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/models.dart';

part 'questionnaire_task.g.dart';

@JsonSerializable()
class QuestionnaireTask extends Observation {
  static const String taskType = 'questionnaire';

  StudyUQuestionnaire questions = StudyUQuestionnaire();

  new() : super(taskType);

  new withId() : super.withId(taskType);

  factory fromJson(Map<String, dynamic> json) =>
      _$QuestionnaireTaskFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QuestionnaireTaskToJson(this);

  @override
  Map<DateTime, T> extractPropertyResults<T>(
    String property,
    List<SubjectProgress> sourceResults,
  ) {
    final Question? targetQuestion = questions.questions.firstWhereOrNull(
      (q) => q.id == property,
    );
    if (targetQuestion == null) {
      throw ArgumentError(
        "Questionnaire '$id' does not have a question with '$property'.",
      );
    }
    return Map.fromEntries(
      sourceResults.map(
        (e) => MapEntry(
          e.completedAt!,
          (e.result as Result<QuestionnaireState>).result.getAnswer<T>(
            property,
          ),
        ),
      ),
    );
  }

  @override
  Map<String, Type> getAvailableProperties() => {
    for (final q in questions.questions) q.id: q.getAnswerType(),
  };

  @override
  String? getHumanReadablePropertyName(String property) =>
      questions.questions.firstWhereOrNull((q) => q.id == property)!.prompt;
}

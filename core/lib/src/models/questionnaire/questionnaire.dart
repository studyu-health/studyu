import 'package:studyu_core/src/models/questionnaire/question.dart';

// TODO: We might want to make this @JsonSerializable() as well, but it does not support list types
class StudyUQuestionnaire() {
  late List<Question> questions = [];

  factory fromJson(List<dynamic> data) => StudyUQuestionnaire()
    ..questions = data
        .map((entry) => Question.fromJson(entry as Map<String, dynamic>))
        .toList();

  List<dynamic> toJson() =>
      questions.map((question) => question.toJson()).toList();
}

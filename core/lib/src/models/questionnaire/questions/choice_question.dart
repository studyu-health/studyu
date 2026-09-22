import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/questionnaire/answer.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';
import 'package:uuid/uuid.dart';

part 'choice_question.g.dart';

@JsonSerializable()
class ChoiceQuestion extends Question<List<String>> {
  static const String questionType = 'choice';

  bool multiple = false;
  @JsonKey(defaultValue: false)
  bool selectionRequired = false;
  List<Choice> choices = [];

  new() : super(questionType);

  new withId() : super.withId(questionType);

  factory fromJson(Map<String, dynamic> json) => _$ChoiceQuestionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChoiceQuestionToJson(this);

  Answer<List<String>> constructAnswer(List<Choice> selected) =>
      Answer.forQuestion(this, selected.map((choice) => choice.id).toList());
}

@JsonSerializable()
class Choice {
  String id;
  String text = '';

  new(this.id);

  new withText({String? id, required this.text}) : id = id ?? const Uuid().v4();

  new withId() : id = const Uuid().v4();

  factory fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$ChoiceToJson(this);

  @override
  String toString() => toJson().toString();
}

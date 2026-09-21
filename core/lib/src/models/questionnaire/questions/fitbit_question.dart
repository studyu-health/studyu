import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'fitbit_question.g.dart';

@JsonSerializable()
class FitbitQuestion extends Question<FitbitQuestion> {
  static const String questionType = 'FitbitQuestion';

  @JsonKey(name: 'types')
  List<FitbitQuestionType> types;

  new({required this.types}) : super(questionType);

  new withId({required String questionType, required this.types})
    : super.withId(questionType);

  factory fromJson(Map<String, dynamic> json) => _$FitbitQuestionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FitbitQuestionToJson(this);

  Answer<List<FitbitData>> constructAnswer(List<FitbitData> data) =>
      Answer.forQuestion(this, data);
}

enum FitbitQuestionType() {
  heartrate,
  sleep,
  steps;

  String toJson() => name;

  String toReadable() => name;

  static FitbitQuestionType fromJson(String json) => values.byName(json);
}

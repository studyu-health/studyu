import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';
import 'package:studyu_core/src/models/questionnaire/questions/slider_question.dart';

part 'visual_analogue_question.g.dart';

@JsonSerializable()
class VisualAnalogueQuestion extends SliderQuestion {
  static const String questionType = 'visualAnalogue';

  int minimumColor = 0xFF0000FF;
  int maximumColor = 0xFFFF0000;

  String minimumAnnotation = '';
  String maximumAnnotation = '';

  new() : super(questionType);

  new withId() : super.withId(questionType);

  factory fromJson(Map<String, dynamic> json) =>
      _$VisualAnalogueQuestionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VisualAnalogueQuestionToJson(this);
}

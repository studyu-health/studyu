import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'image_capturing_question.g.dart';

@JsonSerializable()
class ImageCapturingQuestion extends Question<ImageCapturingQuestion> {
  static const String questionType = 'ImageCapturingQuestion';

  new() : super(questionType);

  new withId() : super.withId(questionType);

  factory fromJson(Map<String, dynamic> json) =>
      _$ImageCapturingQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ImageCapturingQuestionToJson(this);

  Answer<FutureBlobFile> constructAnswer(FutureBlobFile response) =>
      Answer.forQuestion(this, response);
}

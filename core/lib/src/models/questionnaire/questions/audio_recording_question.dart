import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'audio_recording_question.g.dart';

@JsonSerializable()
class AudioRecordingQuestion extends Question<AudioRecordingQuestion> {
  static const String questionType = 'AudioRecordingQuestion';

  @JsonKey(name: 'maxRecordingDurationSeconds')
  final int maxRecordingDurationSeconds;

  new({required this.maxRecordingDurationSeconds}) : super(questionType);

  new withId(this.maxRecordingDurationSeconds) : super.withId(questionType);

  factory fromJson(Map<String, dynamic> json) =>
      _$AudioRecordingQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AudioRecordingQuestionToJson(this);

  Answer<FutureBlobFile> constructAnswer(FutureBlobFile response) =>
      Answer.forQuestion(this, response);
}

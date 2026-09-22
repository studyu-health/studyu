import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

enum SurveyQuestionType() {
  choice,
  bool,
  scale,
  image,
  audio,
  freeText,
  fitbit,
  pain,
  date;

  static SurveyQuestionType of(Question question) {
    final typeMapping = {
      BooleanQuestion.questionType: SurveyQuestionType.bool,
      ChoiceQuestion.questionType: SurveyQuestionType.choice,
      ScaleQuestion.questionType: SurveyQuestionType.scale,
      AnnotatedScaleQuestion.questionType: SurveyQuestionType.scale,
      VisualAnalogueQuestion.questionType: SurveyQuestionType.scale,
      FreeTextQuestion.questionType: SurveyQuestionType.freeText,
      ImageCapturingQuestion.questionType: SurveyQuestionType.image,
      AudioRecordingQuestion.questionType: SurveyQuestionType.audio,
      FitbitQuestion.questionType: SurveyQuestionType.fitbit,
      PainQuestion.questionType: SurveyQuestionType.pain,
      DateQuestion.questionType: SurveyQuestionType.date,
    };
    if (!typeMapping.containsKey(question.type)) {
      throw UnimplementedError(
        "Missing SurveyQuestionType for question of type: ${question.type}",
      );
    }
    return typeMapping[question.type]!;
  }

  String get string {
    switch (this) {
      case SurveyQuestionType.choice:
        return tr.question_type_choice;
      case SurveyQuestionType.bool:
        return tr.question_type_bool;
      case SurveyQuestionType.scale:
        return tr.question_type_scale;
      case SurveyQuestionType.image:
        return tr.question_type_image;
      case SurveyQuestionType.audio:
        return tr.question_type_audio;
      case SurveyQuestionType.freeText:
        return tr.question_type_free_text;
      case SurveyQuestionType.fitbit:
        return tr.question_type_fitbit;
      case SurveyQuestionType.pain:
        return tr.question_type_pain;
      case SurveyQuestionType.date:
        return tr.question_type_date;
    }
  }

  IconData? get icon {
    switch (this) {
      case SurveyQuestionType.choice:
        return Icons.format_list_bulleted_rounded;
      case SurveyQuestionType.bool:
        return Icons.check_box_rounded;
      case SurveyQuestionType.scale:
        return Icons.tune_rounded;
      case SurveyQuestionType.image:
        return Icons.photo_camera_rounded;
      case SurveyQuestionType.audio:
        return Icons.mic;
      case SurveyQuestionType.freeText:
        return Icons.edit_square;
      case SurveyQuestionType.fitbit:
        return Icons.fitbit;
      case SurveyQuestionType.pain:
        return Icons.accessibility;
      case SurveyQuestionType.date:
        return Icons.calendar_today;
    }
  }

  String toJson() => name;
  static SurveyQuestionType fromJson(String json) => values.byName(json);
}

extension FreeTextQuestionTypeExtension on FreeTextQuestionType {
  String get string {
    switch (this) {
      case FreeTextQuestionType.any:
        return tr.free_text_question_type_any;
      case FreeTextQuestionType.alphanumeric:
        return tr.free_text_question_type_alphanumeric;
      case FreeTextQuestionType.numeric:
        return tr.free_text_question_type_numeric;
      case FreeTextQuestionType.custom:
        return tr.free_text_question_type_custom;
    }
  }
}

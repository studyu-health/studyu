import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/questionnaire/answer.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';

part 'free_text_question.g.dart';

@JsonSerializable()
class FreeTextQuestion extends Question<String> {
  static const String questionType = 'freeText';

  @JsonKey(name: 'lengthRange')
  List<int> lengthRange;

  @JsonKey(name: 'textType')
  FreeTextQuestionType textType;

  @JsonKey(name: 'customTypeExpression')
  String? customTypeExpression;

  new({
    required this.textType,
    required this.lengthRange,
    this.customTypeExpression,
  }) : super(questionType);

  new withId({
    required this.textType,
    required this.lengthRange,
    this.customTypeExpression,
  }) : super.withId(questionType);

  factory fromJson(Map<String, dynamic> json) =>
      _$FreeTextQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FreeTextQuestionToJson(this);

  Answer<String> constructAnswer(String response) =>
      Answer.forQuestion(this, response);
}

enum FreeTextQuestionType() {
  any,
  alphanumeric,
  numeric,
  custom;

  String toJson() => name;
  static FreeTextQuestionType fromJson(String json) => values.byName(json);
}

const alphanumericPattern = r'^[a-zA-Z0-9]*$';

enum FreeTextValidationError() {
  tooShort,
  tooLong,
  notAlphanumeric,
  notNumeric,
  customMismatch,
  invalidCustomExpression,
}

extension FreeTextQuestionValidation on FreeTextQuestion {
  FreeTextValidationError? validateResponse(String input) {
    // For non-custom text types, length is checked before type.
    if (textType != FreeTextQuestionType.custom) {
      final minLength = lengthRange.first;
      if (input.isEmpty && minLength == 0) {
        return null;
      }
      if (input.length < minLength) {
        return FreeTextValidationError.tooShort;
      }
      if (input.length > lengthRange.last) {
        return FreeTextValidationError.tooLong;
      }
    }

    switch (textType) {
      case FreeTextQuestionType.any:
        return null;
      case FreeTextQuestionType.alphanumeric:
        if (RegExp(alphanumericPattern).hasMatch(input)) {
          return null;
        }
        return FreeTextValidationError.notAlphanumeric;
      case FreeTextQuestionType.numeric:
        if (RegExp(r'^-?[0-9]+$').hasMatch(input)) {
          return null;
        }
        return FreeTextValidationError.notNumeric;
      case FreeTextQuestionType.custom:
        final expression = customTypeExpression;
        if (expression == null || expression.isEmpty) {
          return FreeTextValidationError.invalidCustomExpression;
        }
        try {
          final regex = RegExp('^(?:$expression)\$');
          if (regex.hasMatch(input)) {
            return null;
          }
          return FreeTextValidationError.customMismatch;
        } on FormatException {
          return FreeTextValidationError.invalidCustomExpression;
        }
    }
  }
}

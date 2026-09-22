import 'package:studyu_core/src/models/expressions/types/composite_expression.dart';
import 'package:studyu_core/src/models/expressions/types/value_expression.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/audio_recording_question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/choice_question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/date_question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/free_text_question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/scale_question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/slider_question.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

/// Validate a single question.
/// [context] is the JSON path prefix, e.g. `$.questionnaire.questions[2]`.
/// [allIdsInQuestionnaire] is the full set of question IDs in the same
/// questionnaire (used for conditional-target cross-check, fact 13).
ValidationResult validateQuestion(
  Question question,
  String context,
  ValidationLevel level,
  Set<String> allIdsInQuestionnaire,
) {
  final errors = <ValidationError>[];

  // Fact 1 — prompt required at publish level
  if (level == ValidationLevel.publish) {
    if (question.prompt == null || question.prompt!.trim().isEmpty) {
      errors.add(
        ValidationError(
          code: 'question.prompt_required',
          path: '$context.prompt',
          message: 'Question at $context has no prompt',
          fixHint:
              'Open the question in the Designer and fill in the prompt field.',
        ),
      );
    }
  }

  // Type-specific checks
  final typeResult = _validateByType(question, context);
  errors.addAll(typeResult.errors);

  // Fact 13 — conditional target must exist in this questionnaire
  final conditionalResult = _validateConditionalTarget(
    question,
    context,
    allIdsInQuestionnaire,
  );
  errors.addAll(conditionalResult.errors);

  return ValidationResult(errors: errors, warnings: []);
}

ValidationResult _validateByType(Question question, String path) {
  if (question is ChoiceQuestion) {
    return _validateChoiceQuestion(question, path);
  }
  if (question is SliderQuestion) {
    return _validateSliderQuestion(question, path);
  }
  if (question is FreeTextQuestion) {
    return _validateFreeTextQuestion(question, path);
  }
  if (question is DateQuestion) {
    return _validateDateQuestion(question, path);
  }
  if (question is AudioRecordingQuestion) {
    return _validateAudioQuestion(question, path);
  }
  return ValidationResult.empty();
}

ValidationResult _validateChoiceQuestion(ChoiceQuestion q, String path) {
  final errors = <ValidationError>[];

  // Fact 2
  if (q.choices.isEmpty) {
    errors.add(
      ValidationError(
        code: 'choice_question.no_choices',
        path: '$path.choices',
        message: 'ChoiceQuestion at $path has no choices',
        fixHint: 'Add at least one choice to the question.',
      ),
    );
    return ValidationResult(errors: errors, warnings: []);
  }

  final seenIds = <String>{};
  for (var i = 0; i < q.choices.length; i++) {
    final choice = q.choices[i];

    // Fact 3
    if (choice.text.trim().isEmpty) {
      errors.add(
        ValidationError(
          code: 'choice_question.blank_choice_text',
          path: '$path.choices[$i].text',
          message: 'Choice at index $i in $path has blank text',
          fixHint: 'Fill in the text for every choice option. The Designer text field accepts any non-empty string.',
        ),
      );
    }

    // Fact 4
    if (seenIds.contains(choice.id)) {
      errors.add(
        ValidationError(
          code: 'choice_question.duplicate_choice_id',
          path: '$path.choices[$i].id',
          message: 'Choice id "${choice.id}" appears more than once in $path',
          fixHint: 'Regenerate a unique UUID for the duplicated choice. This cannot happen via the Designer UI; it indicates a manual JSON edit.',
        ),
      );
    }
    seenIds.add(choice.id);
  }

  return ValidationResult(errors: errors, warnings: []);
}

ValidationResult _validateSliderQuestion(SliderQuestion q, String path) {
  final errors = <ValidationError>[];

  // Fact 5 — invalid range (minimum >= maximum)
  if (q.minimum >= q.maximum) {
    errors.add(
      ValidationError(
        code: 'scale_question.invalid_range',
        path: '$path.minimum/$path.maximum',
        message:
            'SliderQuestion at $path has minimum (${q.minimum}) >= maximum (${q.maximum})',
        fixHint: 'Set maximum to a value greater than minimum.',
      ),
    );
  }

  // Fact 6 — invalid step (non-autostep only)
  // ScaleQuestion exposes isAutostep; for plain SliderQuestion, step == 0
  // is treated as "no manual step set" so we skip the step check.
  final bool isAutostep = q is ScaleQuestion ? q.isAutostep : q.step == 0;

  if (!isAutostep && q.step <= 0) {
    errors.add(
      ValidationError(
        code: 'scale_question.invalid_step',
        path: '$path.step',
        message: 'SliderQuestion at $path has step ${q.step} which is <= 0',
        fixHint:
            'Set step to a positive value, or set it to 0 to enable autostep.',
      ),
    );
  }

  return ValidationResult(errors: errors, warnings: []);
}

ValidationResult _validateFreeTextQuestion(FreeTextQuestion q, String path) {
  final errors = <ValidationError>[];

  // Fact 7 — invalid length range
  if (q.lengthRange.length >= 2 && q.lengthRange[0] > q.lengthRange[1]) {
    errors.add(
      ValidationError(
        code: 'free_text_question.invalid_length_range',
        path: '$path.lengthRange',
        message:
            'FreeTextQuestion at $path has lengthRange[0] (${q.lengthRange[0]}) > lengthRange[1] (${q.lengthRange[1]})',
        fixHint: 'Set lengthRange[0] <= lengthRange[1].',
      ),
    );
  }

  // Fact 8 — custom type requires expression
  if (q.textType == FreeTextQuestionType.custom) {
    if (q.customTypeExpression == null ||
        q.customTypeExpression!.trim().isEmpty) {
      errors.add(
        ValidationError(
          code: 'free_text_question.missing_custom_expression',
          path: '$path.customTypeExpression',
          message:
              'FreeTextQuestion at $path has textType=custom but no customTypeExpression',
          fixHint: 'Set customTypeExpression to a valid regex when textType is custom.',
        ),
      );
    }
  }

  return ValidationResult(errors: errors, warnings: []);
}

ValidationResult _validateDateQuestion(DateQuestion q, String path) {
  final errors = <ValidationError>[];

  // Fact 9 — invalid date range (only when both are non-null)
  if (q.minDate != null && q.maxDate != null) {
    if (q.minDate!.isAfter(q.maxDate!)) {
      errors.add(
        ValidationError(
          code: 'date_question.invalid_date_range',
          path: '$path.minDate/$path.maxDate',
          message: 'DateQuestion at $path has minDate after maxDate',
          fixHint: 'Set maxDate to a date after minDate.',
        ),
      );
    }
  }

  return ValidationResult(errors: errors, warnings: []);
}

ValidationResult _validateAudioQuestion(AudioRecordingQuestion q, String path) {
  final errors = <ValidationError>[];

  // Fact 10
  if (q.maxRecordingDurationSeconds <= 0) {
    errors.add(
      ValidationError(
        code: 'audio_question.invalid_duration',
        path: '$path.maxRecordingDurationSeconds',
        message:
            'AudioRecordingQuestion at $path has maxRecordingDurationSeconds <= 0',
        fixHint: 'Set maxRecordingDurationSeconds to at least 1.',
      ),
    );
  }

  return ValidationResult(errors: errors, warnings: []);
}

ValidationResult _validateConditionalTarget(
  Question question,
  String path,
  Set<String> allIds,
) {
  if (question.conditional == null) return ValidationResult.empty();

  // Fact 13 — conditional target ID must exist in same questionnaire
  // QuestionConditional.condition is a CompositeExpression; extract targets
  final errors = <ValidationError>[];
  final condition = question.conditional!.condition;
  final targets = _extractConditionalTargets(condition);

  for (final target in targets) {
    if (!allIds.contains(target)) {
      errors.add(
        ValidationError(
          code: 'question.conditional_target_missing',
          path: '$path.conditional.condition.target',
          message:
              'Question at $path has conditional that references id "$target" which does not exist in this questionnaire',
          fixHint: 'The conditional references a question ID that does not exist in this questionnaire. Add that question or remove the conditional.',
        ),
      );
    }
  }

  return ValidationResult(errors: errors, warnings: []);
}

Set<String> _extractConditionalTargets(dynamic expr) {
  if (expr == null) return {};
  if (expr is CompositeExpression) {
    return expr.expressions
        .expand((e) => _extractConditionalTargets(e))
        .toSet();
  }
  if (expr is ValueExpression) {
    if (expr.target != null) return {expr.target!};
  }
  return {};
}

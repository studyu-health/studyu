import 'package:studyu_core/src/models/observations/tasks/questionnaire_task.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/questionnaire_validator.dart';

ValidationResult validateObservations(Study study, ValidationLevel level) {
  final results = <ValidationResult>[];
  final errors = <ValidationError>[];
  final seenObservationIds = <String>{};
  final knownQuestionIds = study.questionnaire.questions
      .map((question) => question.id)
      .toSet();

  for (var i = 0; i < study.observations.length; i++) {
    final observation = study.observations[i];
    if (!seenObservationIds.add(observation.id)) {
      errors.add(
        ValidationError(
          code: 'observations.duplicate_observation_id',
          path: '\$.observations[$i].id',
          message: 'Observation id "${observation.id}" appears more than once',
          fixHint: 'Regenerate a unique UUID for each observation. This cannot happen via the Designer UI; it indicates a manual JSON edit.',
        ),
      );
    }

    if (observation is QuestionnaireTask) {
      results.add(
        validateQuestionnaire(
          observation.questions,
          '\$.observations[$i].questions',
          level,
          knownIds: knownQuestionIds,
        ),
      );
      knownQuestionIds.addAll(
        observation.questions.questions.map((question) => question.id),
      );
    }
  }

  return ValidationResult.merge([
    ValidationResult(errors: errors, warnings: const []),
    ...results,
  ]);
}

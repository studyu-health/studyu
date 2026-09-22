import 'package:studyu_core/src/models/expressions/expression.dart';
import 'package:studyu_core/src/models/expressions/types/boolean_expression.dart';
import 'package:studyu_core/src/models/expressions/types/composite_expression.dart';
import 'package:studyu_core/src/models/expressions/types/value_expression.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

Set<String> _extractTargets(Expression expr) {
  if (expr is ValueExpression) {
    return {if (expr.target != null) expr.target!};
  }
  if (expr is CompositeExpression) {
    return expr.expressions.expand(_extractTargets).toSet();
  }
  return {};
}

/// Returns true if the expression will always evaluate to true regardless of input.
bool _isAlwaysTrue(Expression expr) {
  // Fact 27 — a plain BooleanExpression with no target is always true
  if (expr is BooleanExpression && expr.target == null) return true;
  // Fact 28 — a CompositeExpression with empty expressions list is always true
  if (expr is CompositeExpression && expr.expressions.isEmpty) return true;
  return false;
}

ValidationResult validateEligibilityConsent(
  Study study,
  ValidationLevel level,
) {
  final errors = <ValidationError>[];
  final warnings = <ValidationError>[];
  final screenerIds = study.questionnaire.questions.map((q) => q.id).toSet();

  for (var i = 0; i < study.eligibilityCriteria.length; i++) {
    final criterion = study.eligibilityCriteria[i];

    // Existing target-missing check
    final targets = _extractTargets(criterion.condition);
    for (final target in targets) {
      if (!screenerIds.contains(target)) {
        errors.add(
          ValidationError(
            code: 'eligibility.target_question_missing',
            path: r'$.eligibility_criteria' + '[$i].condition.target',
            message:
                "Criterion references question '$target' which does not exist in questionnaire",
            fixHint:
                'Add the screener question first, or remove this criterion',
          ),
        );
      }
    }

    // Facts 27-28 — always-true condition warning
    if (_isAlwaysTrue(criterion.condition)) {
      warnings.add(
        ValidationError(
          code: 'eligibility.condition_always_true',
          path: r'$.eligibility_criteria' + '[$i].condition',
          message:
              'Eligibility criterion at index $i will always pass (condition is unconditionally true)',
          fixHint: 'Replace the condition with a specific expression that checks a screener question answer.',
        ),
      );
    }
  }

  return ValidationResult(errors: errors, warnings: warnings);
}

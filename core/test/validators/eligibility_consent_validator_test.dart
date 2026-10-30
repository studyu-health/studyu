import 'package:studyu_core/src/models/eligibility/eligibility_criterion.dart';
import 'package:studyu_core/src/models/expressions/types/boolean_expression.dart';
import 'package:studyu_core/src/models/expressions/types/choice_expression.dart';
import 'package:studyu_core/src/models/expressions/types/composite_expression.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire.dart';
import 'package:studyu_core/src/models/questionnaire/questions/boolean_question.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/eligibility_consent_validator.dart';
import 'package:test/test.dart';

void main() {
  test(
    'passes when eligibility criteria reference existing screener questions',
    () {
      final q = BooleanQuestion.withId();

      final criterion = EligibilityCriterion.withId();
      final expr = ChoiceExpression();
      expr.target = q.id;
      criterion.condition = expr;

      final s = Study('id', 'user');
      s.questionnaire.questions = [q];
      s.eligibilityCriteria = [criterion];

      final r = validateEligibilityConsent(s, ValidationLevel.draft);
      expect(r.valid, isTrue);
    },
  );

  test(
    'fails when eligibility criterion target does not exist in questionnaire',
    () {
      final criterion = EligibilityCriterion.withId();
      final expr = ChoiceExpression();
      expr.target = 'non-existent-question-id';
      criterion.condition = expr;

      final s = Study('id', 'user');
      s.questionnaire = StudyUQuestionnaire(); // empty questionnaire
      s.eligibilityCriteria = [criterion];

      final r = validateEligibilityConsent(s, ValidationLevel.draft);
      expect(r.valid, isFalse);
      expect(r.errors.first.code, 'eligibility.target_question_missing');
    },
  );

  test('BooleanExpression with no target -> eligibility.condition_always_true warning', () {
    final criterion = EligibilityCriterion.withId();
    criterion.condition = BooleanExpression(); // no target set

    final s = Study('id', 'user');
    s.eligibilityCriteria = [criterion];

    final r = validateEligibilityConsent(s, ValidationLevel.draft);
    expect(r.valid, isTrue); // warning only, not an error
    expect(
      r.warnings.any((w) => w.code == 'eligibility.condition_always_true'),
      isTrue,
    );
  });

  test('CompositeExpression with empty expressions -> eligibility.condition_always_true warning', () {
    final criterion = EligibilityCriterion.withId();
    criterion.condition = CompositeExpression(
      logicType: LogicType.and,
      expressions: [],
    );

    final s = Study('id', 'user');
    s.eligibilityCriteria = [criterion];

    final r = validateEligibilityConsent(s, ValidationLevel.draft);
    expect(r.valid, isTrue);
    expect(
      r.warnings.any((w) => w.code == 'eligibility.condition_always_true'),
      isTrue,
    );
  });

  test('CompositeExpression with one valid ChoiceExpression -> no always-true warning', () {
    final q = BooleanQuestion.withId();
    final expr = ChoiceExpression();
    expr.target = q.id;
    final criterion = EligibilityCriterion.withId();
    criterion.condition = CompositeExpression(
      logicType: LogicType.and,
      expressions: [expr],
    );

    final s = Study('id', 'user');
    s.questionnaire.questions = [q];
    s.eligibilityCriteria = [criterion];

    final r = validateEligibilityConsent(s, ValidationLevel.draft);
    expect(
      r.warnings.where((w) => w.code == 'eligibility.condition_always_true'),
      isEmpty,
    );
  });

  test('BooleanExpression with target set -> no always-true warning', () {
    final q = BooleanQuestion.withId();
    final expr = BooleanExpression();
    expr.target = q.id;
    final criterion = EligibilityCriterion.withId();
    criterion.condition = expr;

    final s = Study('id', 'user');
    s.questionnaire.questions = [q];
    s.eligibilityCriteria = [criterion];

    final r = validateEligibilityConsent(s, ValidationLevel.draft);
    expect(
      r.warnings.where((w) => w.code == 'eligibility.condition_always_true'),
      isEmpty,
    );
  });

  test(
    'always-true condition produces warning, not error -> result.valid is true',
    () {
      final criterion = EligibilityCriterion.withId();
      criterion.condition = BooleanExpression();

      final s = Study('id', 'user');
      s.eligibilityCriteria = [criterion];

      final r = validateEligibilityConsent(s, ValidationLevel.draft);
      expect(r.valid, isTrue);
      expect(r.errors, isEmpty);
      expect(r.warnings, isNotEmpty);
    },
  );
}

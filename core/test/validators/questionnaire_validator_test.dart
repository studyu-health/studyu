import 'package:studyu_core/src/models/expressions/types/boolean_expression.dart';
import 'package:studyu_core/src/models/expressions/types/composite_expression.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire.dart';
import 'package:studyu_core/src/models/questionnaire/questions/boolean_question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/choice_question.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/questionnaire_validator.dart';
import 'package:test/test.dart';

StudyUQuestionnaire _questionnaire(List<Question> questions) {
  final q = StudyUQuestionnaire();
  q.questions = questions;
  return q;
}

BooleanQuestion _boolQ(String id, {String? prompt}) {
  final q = BooleanQuestion.withId();
  q.id = id;
  q.prompt = prompt ?? 'Question $id';
  return q;
}

void main() {
  group('validateQuestionnaire', () {
    test('passes for empty questionnaire', () {
      final r = validateQuestionnaire(
        _questionnaire([]),
        r'$.questionnaire',
        ValidationLevel.draft,
      );
      expect(r.valid, isTrue);
    });

    test('fails when two questions share the same id', () {
      final q1 = _boolQ('dup-id');
      final q2 = _boolQ('dup-id');
      final r = validateQuestionnaire(
        _questionnaire([q1, q2]),
        r'$.questionnaire',
        ValidationLevel.draft,
      );
      expect(r.valid, isFalse);
      expect(r.errors.first.code, 'questionnaire.duplicate_question_id');
    });

    test('passes when all question ids are unique', () {
      final r = validateQuestionnaire(
        _questionnaire([_boolQ('a'), _boolQ('b')]),
        r'$.questionnaire',
        ValidationLevel.draft,
      );
      expect(r.valid, isTrue);
    });

    test('allows a conditional to reference a later question', () {
      final first = _boolQ('first')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'later'],
          ),
        );

      final result = validateQuestionnaire(
        _questionnaire([first, _boolQ('later')]),
        r'$.questionnaire',
        ValidationLevel.draft,
      );

      expect(
        result.errors.where(
          (error) => error.code == 'question.conditional_target_missing',
        ),
        isEmpty,
      );
    });

    test('question with blank prompt fails at publish', () {
      final q = _boolQ('q1', prompt: '');
      final r = validateQuestionnaire(
        _questionnaire([q]),
        r'$.questionnaire',
        ValidationLevel.publish,
      );
      expect(r.valid, isFalse);
      expect(r.errors.any((e) => e.code == 'question.prompt_required'), isTrue);
    });

    test('ChoiceQuestion with empty choices fails', () {
      final q = ChoiceQuestion.withId();
      q.id = 'cq1';
      q.prompt = 'Pick one';
      q.choices = [];
      final r = validateQuestionnaire(
        _questionnaire([q]),
        r'$.questionnaire',
        ValidationLevel.draft,
      );
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'choice_question.no_choices'),
        isTrue,
      );
    });

    test('cross-context duplicate ID produces questionnaire.duplicate_question_id_cross_context', () {
      final obsQ = _boolQ('shared-id'); // same ID as screener

      final obsQuestionnaire = _questionnaire([obsQ]);
      final screenerIds = {'shared-id'};

      final r = validateQuestionnaire(
        obsQuestionnaire,
        r'$.observations[0].questions',
        ValidationLevel.draft,
        knownIds: screenerIds,
      );
      expect(r.valid, isFalse);
      expect(
        r.errors.any(
          (e) => e.code == 'questionnaire.duplicate_question_id_cross_context',
        ),
        isTrue,
      );
    });

    test('same ID in two observation questionnaires does NOT produce cross-context error', () {
      // knownIds contains only screener IDs, not observation IDs
      final obsQ = _boolQ('obs-unique-id');
      final obsQuestionnaire = _questionnaire([obsQ]);
      final screenerIds = <String>{}; // no screener questions

      final r = validateQuestionnaire(
        obsQuestionnaire,
        r'$.observations[0].questions',
        ValidationLevel.draft,
        knownIds: screenerIds,
      );
      expect(r.valid, isTrue);
    });
  });
}

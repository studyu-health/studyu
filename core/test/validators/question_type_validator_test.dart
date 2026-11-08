import 'package:studyu_core/src/models/expressions/types/choice_expression.dart';
import 'package:studyu_core/src/models/expressions/types/composite_expression.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';
import 'package:studyu_core/src/models/questionnaire/questions/audio_recording_question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/boolean_question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/choice_question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/date_question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/free_text_question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/scale_question.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/question_type_validator.dart';
import 'package:test/test.dart';

const _ctx = r'$.questionnaire.questions[0]';

void main() {
  group('prompt_required at publish', () {
    test('blank prompt on BooleanQuestion fails at publish', () {
      final q = BooleanQuestion.withId();
      q.prompt = '';
      final r = validateQuestion(q, _ctx, ValidationLevel.publish, {q.id});
      expect(r.valid, isFalse);
      expect(r.errors.any((e) => e.code == 'question.prompt_required'), isTrue);
    });

    test('null prompt on BooleanQuestion fails at publish', () {
      final q = BooleanQuestion.withId();
      q.prompt = null;
      final r = validateQuestion(q, _ctx, ValidationLevel.publish, {q.id});
      expect(r.valid, isFalse);
      expect(r.errors.any((e) => e.code == 'question.prompt_required'), isTrue);
    });

    test('non-empty prompt passes at publish', () {
      final q = BooleanQuestion.withId();
      q.prompt = 'Do you feel well?';
      final r = validateQuestion(q, _ctx, ValidationLevel.publish, {q.id});
      expect(
        r.errors.where((e) => e.code == 'question.prompt_required'),
        isEmpty,
      );
    });

    test('blank prompt passes at draft', () {
      final q = BooleanQuestion.withId();
      q.prompt = '';
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(
        r.errors.where((e) => e.code == 'question.prompt_required'),
        isEmpty,
      );
    });
  });

  group('ChoiceQuestion', () {
    test('empty choices list -> choice_question.no_choices', () {
      final q = ChoiceQuestion.withId();
      q.choices = [];
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'choice_question.no_choices'),
        isTrue,
      );
    });

    test('choice with empty text -> choice_question.blank_choice_text', () {
      final q = ChoiceQuestion.withId();
      q.choices = [Choice.withText(text: 'Valid'), Choice.withText(text: '')];
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'choice_question.blank_choice_text'),
        isTrue,
      );
    });

    test('duplicate choice IDs -> choice_question.duplicate_choice_id', () {
      final q = ChoiceQuestion.withId();
      final c1 = Choice('same-id')..text = 'A';
      final c2 = Choice('same-id')..text = 'B';
      q.choices = [c1, c2];
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'choice_question.duplicate_choice_id'),
        isTrue,
      );
    });

    test('unique choices with text -> passes', () {
      final q = ChoiceQuestion.withId();
      q.choices = [
        Choice.withText(text: 'Option A'),
        Choice.withText(text: 'Option B'),
      ];
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(
        r.errors.where((e) => e.code.startsWith('choice_question')),
        isEmpty,
      );
    });
  });

  group('ScaleQuestion / SliderQuestion', () {
    ScaleQuestion scale({double min = 0, double max = 10, double step = 0}) {
      final q = ScaleQuestion.withId();
      q.minimum = min;
      q.maximum = max;
      q.step = step;
      return q;
    }

    test('minimum == maximum -> scale_question.invalid_range', () {
      final q = scale(min: 5, max: 5);
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'scale_question.invalid_range'),
        isTrue,
      );
    });

    test('minimum > maximum -> scale_question.invalid_range', () {
      final q = scale(min: 10, max: 0);
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'scale_question.invalid_range'),
        isTrue,
      );
    });

    test('step == 0 on ScaleQuestion (autostep) -> passes', () {
      final q = scale();
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(
        r.errors.where((e) => e.code == 'scale_question.invalid_step'),
        isEmpty,
      );
    });

    test(
      'step < 0 on non-autostep ScaleQuestion -> scale_question.invalid_step',
      () {
        final q = scale(step: -1);
        final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
        expect(r.valid, isFalse);
        expect(
          r.errors.any((e) => e.code == 'scale_question.invalid_step'),
          isTrue,
        );
      },
    );
  });

  group('FreeTextQuestion', () {
    test('lengthRange [5, 3] -> free_text_question.invalid_length_range', () {
      final q = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.any,
        lengthRange: [5, 3],
      );
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(r.valid, isFalse);
      expect(
        r.errors.any(
          (e) => e.code == 'free_text_question.invalid_length_range',
        ),
        isTrue,
      );
    });

    test('textType=custom, customTypeExpression=null -> free_text_question.missing_custom_expression', () {
      final q = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [0, 100],
      );
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(r.valid, isFalse);
      expect(
        r.errors.any(
          (e) => e.code == 'free_text_question.missing_custom_expression',
        ),
        isTrue,
      );
    });

    test('textType=custom, customTypeExpression="" -> free_text_question.missing_custom_expression', () {
      final q = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [0, 100],
        customTypeExpression: '',
      );
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(r.valid, isFalse);
      expect(
        r.errors.any(
          (e) => e.code == 'free_text_question.missing_custom_expression',
        ),
        isTrue,
      );
    });

    test('textType=custom, customTypeExpression="[a-z]+" -> passes', () {
      final q = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [0, 100],
        customTypeExpression: '[a-z]+',
      );
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(
        r.errors.where(
          (e) => e.code == 'free_text_question.missing_custom_expression',
        ),
        isEmpty,
      );
    });
  });

  group('DateQuestion', () {
    test('minDate after maxDate -> date_question.invalid_date_range', () {
      final q = DateQuestion.withId(
        minDate: DateTime(2024, 6, 10),
        maxDate: DateTime(2024, 6),
      );
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'date_question.invalid_date_range'),
        isTrue,
      );
    });

    test('only minDate set (maxDate null) -> passes', () {
      final q = DateQuestion.withId(minDate: DateTime(2024, 6));
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(
        r.errors.where((e) => e.code == 'date_question.invalid_date_range'),
        isEmpty,
      );
    });

    test('only maxDate set (minDate null) -> passes', () {
      final q = DateQuestion.withId(maxDate: DateTime(2024, 12, 31));
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(
        r.errors.where((e) => e.code == 'date_question.invalid_date_range'),
        isEmpty,
      );
    });
  });

  group('AudioRecordingQuestion', () {
    test(
      'maxRecordingDurationSeconds == 0 -> audio_question.invalid_duration',
      () {
        final q = AudioRecordingQuestion.withId(0);
        final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
        expect(r.valid, isFalse);
        expect(
          r.errors.any((e) => e.code == 'audio_question.invalid_duration'),
          isTrue,
        );
      },
    );

    test(
      'maxRecordingDurationSeconds < 0 -> audio_question.invalid_duration',
      () {
        final q = AudioRecordingQuestion.withId(-5);
        final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
        expect(r.valid, isFalse);
        expect(
          r.errors.any((e) => e.code == 'audio_question.invalid_duration'),
          isTrue,
        );
      },
    );

    test('maxRecordingDurationSeconds == 30 -> passes', () {
      final q = AudioRecordingQuestion.withId(30);
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(
        r.errors.where((e) => e.code == 'audio_question.invalid_duration'),
        isEmpty,
      );
    });
  });

  group('conditional target', () {
    test('conditional references an id not in the questionnaire -> question.conditional_target_missing', () {
      final q = BooleanQuestion.withId();
      q.prompt = 'Are you okay?';
      final expr = ChoiceExpression();
      expr.target = 'ghost-id';
      final composite = CompositeExpression(
        logicType: LogicType.and,
        expressions: [expr],
      );
      q.conditional = QuestionConditional.withCondition(composite);

      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'question.conditional_target_missing'),
        isTrue,
      );
    });

    test('conditional references a valid id -> passes', () {
      final qA = BooleanQuestion.withId();
      qA.prompt = 'First question';
      final qB = BooleanQuestion.withId();
      qB.prompt = 'Second question';

      final expr = ChoiceExpression();
      expr.target = qA.id;
      final composite = CompositeExpression(
        logicType: LogicType.and,
        expressions: [expr],
      );
      qB.conditional = QuestionConditional.withCondition(composite);

      final allIds = {qA.id, qB.id};
      final r = validateQuestion(qB, _ctx, ValidationLevel.draft, allIds);
      expect(
        r.errors.where((e) => e.code == 'question.conditional_target_missing'),
        isEmpty,
      );
    });

    test('no conditional -> passes', () {
      final q = BooleanQuestion.withId();
      q.prompt = 'Simple question';
      final r = validateQuestion(q, _ctx, ValidationLevel.draft, {q.id});
      expect(
        r.errors.where((e) => e.code == 'question.conditional_target_missing'),
        isEmpty,
      );
    });
  });
}

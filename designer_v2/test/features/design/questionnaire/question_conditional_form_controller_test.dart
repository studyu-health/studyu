import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  late FormControl<QuestionConditional<dynamic>?> conditionalControl;

  FreeTextQuestion freeTextQuestion(
    String id, {
    FreeTextQuestionType textType = FreeTextQuestionType.any,
  }) => FreeTextQuestion.withId(textType: textType, lengthRange: [0, 500])
    ..id = id
    ..prompt = id;

  ConditionalQuestionFormViewModel viewModelWithQuestion(Question question) {
    ConditionRowFormViewModel.availableQuestions = [question];
    conditionalControl = FormControl<QuestionConditional<dynamic>?>();
    final viewModel = ConditionalQuestionFormViewModel(
      currentQuestionId: 'current-question',
      questionConditionalControl: conditionalControl,
    );
    viewModel.addCondition();
    viewModel.conditionModels.single.questionIdControl.value = question.id;
    return viewModel;
  }

  ConditionalQuestionFormViewModel viewModelWithInitialExpression(
    Question question,
    Expression expression,
  ) {
    ConditionRowFormViewModel.availableQuestions = [question];
    conditionalControl = FormControl<QuestionConditional<dynamic>?>(
      value: QuestionConditional.withCondition(
        CompositeExpression(
          logicType: LogicType.and,
          expressions: [expression],
        ),
      ),
    );
    final viewModel = ConditionalQuestionFormViewModel(
      currentQuestionId: 'current-question',
      questionConditionalControl: conditionalControl,
    );
    viewModel.setControlsFrom(null);
    return viewModel;
  }

  tearDown(() {
    ConditionRowFormViewModel.availableQuestions = [];
  });

  group('ConditionalQuestionFormViewModel', () {
    test('saves non-numeric free text same length as text length equality', () {
      final viewModel = viewModelWithQuestion(freeTextQuestion('q1'));
      final condition = viewModel.conditionModels.single;

      condition.comparatorControl.value = TextComparator.lengthEqual;
      condition.valueControl.value = '8';

      final expression = viewModel.compositeExpression!.expressions.single;

      expect(expression, isA<TextExpression>());
      expect(expression.toJson(), containsPair('comparator', 'length_equal'));
      expect(expression.toJson(), containsPair('value', '8'));
      expect(expression.toJson(), containsPair('target', 'q1'));
    });

    test(
      'saves non-numeric free text different length as text length inequality',
      () {
        final viewModel = viewModelWithQuestion(freeTextQuestion('q1'));
        final condition = viewModel.conditionModels.single;

        condition.comparatorControl.value = TextComparator.lengthNotEqual;
        condition.valueControl.value = '8';

        final expression = viewModel.compositeExpression!.expressions.single;

        expect(expression, isA<TextExpression>());
        expect(
          expression.toJson(),
          containsPair('comparator', 'length_not_equal'),
        );
        expect(expression.toJson(), containsPair('value', '8'));
        expect(expression.toJson(), containsPair('target', 'q1'));
      },
    );

    test(
      'saves numeric free text symbolic comparator as numeric expression',
      () {
        final viewModel = viewModelWithQuestion(
          freeTextQuestion('q1', textType: FreeTextQuestionType.numeric),
        );
        final condition = viewModel.conditionModels.single;

        expect(
          condition.availableComparators.map((option) => option.value),
          isNot(contains(TextComparator.contains)),
        );
        expect(
          condition.availableComparators.map((option) => option.value),
          isNot(contains(TextComparator.doesNotContain)),
        );

        condition.comparatorControl.value = NumericComparator.greaterThan;
        condition.valueControl.value = '5';

        final expression = viewModel.compositeExpression!.expressions.single;

        expect(expression, isA<NumericExpression>());
        expect(expression.toJson(), containsPair('comparator', '>'));
        expect(expression.toJson(), containsPair('value', 5));
        expect(expression.toJson(), containsPair('target', 'q1'));
      },
    );

    for (final comparator in [TextComparator.equal, TextComparator.notEqual]) {
      test('migrates legacy numeric free-text $comparator on load', () {
        final question = freeTextQuestion(
          'q1',
          textType: FreeTextQuestionType.numeric,
        );
        final legacyExpression = TextExpression(
          comparator: comparator,
          value: '5',
        )..target = question.id;

        final viewModel = viewModelWithInitialExpression(
          question,
          legacyExpression,
        );
        final expectedComparator = comparator == TextComparator.equal
            ? NumericComparator.equal
            : NumericComparator.notEqual;

        expect(
          viewModel.conditionModels.single.comparatorControl.value,
          expectedComparator,
        );
        final savedExpression =
            conditionalControl.value!.condition.expressions.single;
        expect(savedExpression, isA<NumericExpression>());
        expect(
          (savedExpression as NumericExpression).comparator,
          expectedComparator,
        );
        expect(savedExpression.value, 5);
        expect(savedExpression.target, question.id);
      });
    }

    for (final comparator in [
      TextComparator.contains,
      TextComparator.doesNotContain,
    ]) {
      test('preserves legacy numeric free-text $comparator on load', () {
        final question = freeTextQuestion(
          'q1',
          textType: FreeTextQuestionType.numeric,
        );
        final legacyExpression = TextExpression(
          comparator: comparator,
          value: '5',
        )..target = question.id;

        final viewModel = viewModelWithInitialExpression(
          question,
          legacyExpression,
        );
        final condition = viewModel.conditionModels.single;

        expect(condition.comparatorControl.value, comparator);
        expect(
          condition.availableComparators.map((option) => option.value),
          contains(comparator),
        );
        final savedExpression =
            conditionalControl.value!.condition.expressions.single;
        expect(savedExpression, isA<TextExpression>());
        expect(savedExpression.toJson(), legacyExpression.toJson());
      });
    }
  });
}

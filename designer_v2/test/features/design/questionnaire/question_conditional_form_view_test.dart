import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';

void main() {
  FreeTextQuestion freeTextQuestion(
    String id, {
    FreeTextQuestionType textType = FreeTextQuestionType.any,
  }) => FreeTextQuestion.withId(textType: textType, lengthRange: [0, 500])
    ..id = id
    ..prompt = id;

  ConditionRowFormViewModel viewModelWithQuestion(Question question) {
    ConditionRowFormViewModel.availableQuestions = [question];
    final viewModel = ConditionRowFormViewModel(currentQuestionId: 'current');
    viewModel.questionIdControl.value = question.id;
    return viewModel;
  }

  TextEditingValue formatWithSingleFormatter(
    TextInputFormatter formatter,
    String text,
  ) {
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );
  }

  tearDown(() {
    ConditionRowFormViewModel.availableQuestions = [];
  });

  test('numeric free-text threshold formatter accepts negative values', () {
    final viewModel = viewModelWithQuestion(
      freeTextQuestion('q1', textType: FreeTextQuestionType.numeric),
    );
    viewModel.comparatorControl.value = NumericComparator.lessThan;

    final formatters = freeTextThresholdInputFormatters(viewModel);

    expect(formatters, isNotNull);
    expect(formatters, hasLength(1));
    expect(formatWithSingleFormatter(formatters!.single, '-1').text, '-1');
  });

  test('numeric free-text threshold keyboard allows signed input', () {
    final viewModel = viewModelWithQuestion(
      freeTextQuestion('q1', textType: FreeTextQuestionType.numeric),
    );
    viewModel.comparatorControl.value = NumericComparator.lessThan;

    expect(
      freeTextThresholdKeyboardType(viewModel),
      const TextInputType.numberWithOptions(signed: true),
    );
  });

  test(
    'non-numeric free-text length threshold formatter rejects minus sign',
    () {
      final viewModel = viewModelWithQuestion(freeTextQuestion('q1'));
      viewModel.comparatorControl.value = TextComparator.lengthLessThan;

      final formatters = freeTextThresholdInputFormatters(viewModel);

      expect(formatters, isNotNull);
      expect(formatters, hasLength(1));
      expect(formatWithSingleFormatter(formatters!.single, '-1').text, '');
    },
  );

  test('non-numeric free-text length threshold keyboard stays unsigned', () {
    final viewModel = viewModelWithQuestion(freeTextQuestion('q1'));
    viewModel.comparatorControl.value = TextComparator.lengthLessThan;

    expect(freeTextThresholdKeyboardType(viewModel), TextInputType.number);
  });
}

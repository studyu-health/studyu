import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_data.dart';

void main() {
  group('QuestionnaireFormData', () {
    test('does not create eligibility criteria for free text questions', () {
      final formData = QuestionnaireFormData(
        questionsData: [
          FreeTextQuestionFormData(
            questionId: 'free-text',
            questionText: 'Free text',
            questionType: SurveyQuestionType.freeText,
            textLengthRange: [0, 500],
            textType: FreeTextQuestionType.any,
            textTypeExpression: null,
          ),
        ],
      );

      expect(formData.toEligibilityCriteria(), isEmpty);
    });

    test('keeps eligibility criteria for questions with response options', () {
      final includedChoice = Choice.withId()
        ..id = 'included-choice'
        ..text = 'Included';
      final excludedChoice = Choice.withId()
        ..id = 'excluded-choice'
        ..text = 'Excluded';

      final formData = QuestionnaireFormData(
        questionsData: [
          ChoiceQuestionFormData(
              questionId: 'choice',
              questionText: 'Choice',
              questionType: SurveyQuestionType.choice,
              answerOptions: [includedChoice, excludedChoice],
            )
            ..responseOptionsValidity = {
              includedChoice: true,
              excludedChoice: false,
            },
        ],
      );

      final criteria = formData.toEligibilityCriteria();
      final expression = criteria.single.condition;

      expect(expression, isA<ChoiceExpression>());
      expect(expression.toJson(), containsPair('target', 'choice'));
      expect(expression.toJson(), containsPair('choices', ['included-choice']));
    });
  });
}

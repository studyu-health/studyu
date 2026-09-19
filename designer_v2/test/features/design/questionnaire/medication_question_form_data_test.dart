import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  group('MedicationQuestionFormData', () {
    test('converts a medication question from its domain model', () {
      final question = MedicationQuestion()
        ..id = 'medication-question'
        ..prompt = 'What medication did you take?'
        ..rationale = 'Include the quantity.';

      final formData = QuestionFormData.fromDomainModel(question, []);

      expect(formData, isA<MedicationQuestionFormData>());
      expect(formData.questionType, SurveyQuestionType.medication);
      expect(formData.questionId, question.id);
      expect(formData.questionText, question.prompt);
      expect(formData.questionInfoText, question.rationale);
    });

    test('round-trips prompt, rationale, and conditional', () {
      final conditional = QuestionConditional<MedicationAnswer>.withCondition(
        CompositeExpression(logicType: LogicType.and, expressions: []),
      );
      final formData = MedicationQuestionFormData(
        questionId: 'medication-question',
        questionText: 'What medication did you take?',
        questionType: SurveyQuestionType.medication,
        questionInfoText: 'Include the quantity.',
        conditional: conditional,
      );

      final question = formData.toQuestion();

      expect(question, isA<MedicationQuestion>());
      expect(question.id, formData.questionId);
      expect(question.prompt, formData.questionText);
      expect(question.rationale, formData.questionInfoText);
      expect(
        question.conditional?.condition.toJson(),
        conditional.condition.toJson(),
      );
    });

    test('duplicates without eligibility semantics', () {
      final formData = MedicationQuestionFormData(
        questionId: 'medication-question',
        questionText: 'Medication',
        questionType: SurveyQuestionType.medication,
      );

      final duplicate = formData.copy();

      expect(duplicate.questionId, isNot(formData.questionId));
      expect(duplicate.questionText, 'Medication (Copy)');
      expect(formData.toEligibilityCriterion(), isNull);
    });

    test('exposes medication question type metadata', () {
      expect(
        SurveyQuestionType.of(MedicationQuestion()),
        SurveyQuestionType.medication,
      );
      expect(SurveyQuestionType.medication.string, isNotEmpty);
      expect(SurveyQuestionType.medication.icon, Icons.medication_rounded);
    });

    test('rejects constructing an answer because it has no options', () {
      final formData = MedicationQuestionFormData(
        questionId: 'medication-question',
        questionText: 'Medication',
        questionType: SurveyQuestionType.medication,
      );

      expect(() => formData.constructAnswerFor(null), throwsUnimplementedError);
    });
  });
}

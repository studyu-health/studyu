import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class QuestionnaireFormData({final List<QuestionFormData>? questionsData})
    implements IFormData {
  factory fromDomainModel(
    StudyUQuestionnaire questionnaire,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    return QuestionnaireFormData(
      questionsData: questionnaire.questions
          .map(
            (question) => QuestionFormData.fromDomainModel(
              question,
              // Collect all eligibility criteria for this question
              eligibilityCriteria
                  .where(
                    (c) =>
                        (c.condition as ValueExpression).target == question.id,
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  StudyUQuestionnaire toQuestionnaire() {
    final questionnaire = StudyUQuestionnaire();
    questionnaire.questions = (questionsData != null)
        ? questionsData!.map((formData) => formData.toQuestion()).toList()
        : [];
    return questionnaire;
  }

  List<EligibilityCriterion> toEligibilityCriteria() {
    return questionsData
            ?.map((q) => q.toEligibilityCriterion())
            .nonNulls
            .toList() ??
        [];
  }

  @override
  QuestionnaireFormData copy() {
    return QuestionnaireFormData(
      questionsData: questionsData?.map((formData) => formData.copy()).toList(),
    );
  }

  @override
  FormDataID get id => throw UnimplementedError(); // not available
}

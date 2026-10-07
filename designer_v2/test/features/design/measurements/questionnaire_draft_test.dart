@TestOn('browser')
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_data.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  test(
    'saving a question keeps the existing survey dirty until survey save',
    () async {
      final survey = MeasurementSurveyFormViewModel(
        study: Study.withId('test-user'),
        formData: _surveyData(),
      );
      await Future<void>.delayed(Duration.zero);

      expect(survey.isDirty, isFalse);

      final question = survey.questionModels.single;
      question.questionTextControl.value = 'Changed question';
      await question.save();

      expect(survey.isDirty, isTrue);
      expect(
        survey
            .formData!
            .questionnaireFormData
            .questionsData!
            .single
            .questionText,
        'Original question',
      );
      expect(
        survey
            .buildFormData()
            .questionnaireFormData
            .questionsData!
            .single
            .questionText,
        'Changed question',
      );

      await survey.cancel();

      expect(
        survey.questionModels.single.questionTextControl.value,
        'Original question',
      );
    },
  );

  test('new survey stays local and is removed when cancelled', () async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/studies/:studyId/edit/measurements/:measurementId',
          name: studyEditMeasurementRouteName,
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);
    final measurements = MeasurementsFormViewModel(
      study: Study.withId('test-user'),
      router: router,
      formData: MeasurementsFormData(measurements: []),
    );
    await Future<void>.delayed(Duration.zero);

    measurements.onNewItem();
    await Future<void>.delayed(Duration.zero);

    final survey =
        measurements.measurementViewModels.single
            as MeasurementSurveyFormViewModel;
    expect(
      router.routeInformationProvider.value.uri.pathSegments.last,
      survey.measurementId,
    );
    final question = survey.provide(
      SurveyQuestionFormRouteArgs(
        studyId: 'study-1',
        measurementId: survey.measurementId,
        questionId: Config.newModelId,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    question.questionTextControl.value = 'Local question';
    await question.save();

    expect(survey.isDirty, isTrue);
    expect(measurements.formData!.measurements, isEmpty);
    expect(
      (measurements.buildFormData().measurements.single
              as MeasurementSurveyFormData)
          .questionnaireFormData
          .questionsData!
          .single
          .questionText,
      'Local question',
    );

    await survey.cancel();

    expect(measurements.measurementViewModels, isEmpty);
    expect(measurements.buildFormData().measurements, isEmpty);
  });
}

MeasurementSurveyFormData _surveyData() {
  return MeasurementSurveyFormData(
    measurementId: 'survey-1',
    instanceId: 'instance-1',
    title: 'Survey',
    questionnaireFormData: QuestionnaireFormData(
      questionsData: [
        BoolQuestionFormData(
          questionId: 'question-1',
          questionText: 'Original question',
          questionType: SurveyQuestionType.bool,
        ),
      ],
    ),
    isTimeLocked: false,
    hasReminder: false,
  );
}

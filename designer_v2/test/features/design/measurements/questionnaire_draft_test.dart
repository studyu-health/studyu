@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_list_view.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

import '../../../utils/designer_test_theme.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('survey text edits do not rebuild the question list', (
    tester,
  ) async {
    final survey = MeasurementSurveyFormViewModel(
      study: Study.withId('test-user'),
      formData: _surveyData(),
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: designerTestTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReactiveForm(
                formGroup: survey.form,
                child: MeasurementSurveyFormView(formViewModel: survey),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    var listBuilds = 0;
    final previousCallback = debugOnRebuildDirtyWidget;
    debugOnRebuildDirtyWidget = (element, builtOnce) {
      previousCallback?.call(element, builtOnce);
      if (element.widget is FormListView) listBuilds++;
    };
    addTearDown(() => debugOnRebuildDirtyWidget = previousCallback);
    for (final index in [0, 1, 2]) {
      await tester.enterText(
        find.byType(TextField).at(index),
        'Updated survey text',
      );
      await tester.pump();
    }
    expect(listBuilds, 0);

    final question = survey.questionModels.single;
    question.questionTextControl.value = 'Changed question';
    await question.save();
    await tester.pumpAndSettle();
    expect(listBuilds, greaterThan(0));
    expect(find.text('Changed question'), findsOneWidget);
    survey.questionFormViewModels.remove(question);
    await tester.pumpAndSettle();
    expect(find.text('Changed question'), findsNothing);
  });

  test(
    'saving a question keeps the existing survey dirty until survey save',
    () async {
      final survey = MeasurementSurveyFormViewModel(
        study: Study.withId('test-user'),
        formData: _surveyData(),
      );
      await Future<void>.delayed(Duration.zero);

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
      formData: MeasurementsFormData(surveyMeasurements: []),
    );
    await Future<void>.delayed(Duration.zero);

    measurements.onNewItem();
    await Future<void>.delayed(Duration.zero);

    final survey = measurements.measurementViewModels.single;
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
    expect(measurements.formData!.surveyMeasurements, isEmpty);
    expect(
      measurements
          .buildFormData()
          .surveyMeasurements
          .single
          .questionnaireFormData
          .questionsData!
          .single
          .questionText,
      'Local question',
    );

    await survey.cancel();

    expect(measurements.measurementViewModels, isEmpty);
    expect(measurements.buildFormData().surveyMeasurements, isEmpty);
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

@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_view.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class _MockStudyRepository() extends Mock implements IStudyRepository;

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  test('resolves persisted and staged measurement titles', () {
    final study = Study.withId('study-1');
    final router = _router();
    addTearDown(router.dispose);
    final measurements = MeasurementsFormViewModel(
      study: study,
      router: router,
      formData: MeasurementsFormData(
        measurements: [
          _surveyData('survey-1', 'Persisted survey'),
          _nutritionData('nutrition-1', 'Persisted nutrition'),
        ],
      ),
    );

    final newSurvey = measurements.provideWithType(
      MeasurementFormRouteArgs(
        studyId: study.id,
        measurementId: Config.newModelId,
      ),
      null,
    ) as MeasurementSurveyFormViewModel;
    newSurvey.surveyTitleControl.value = 'Draft survey';
    final newNutrition = measurements.provideWithType(
      MeasurementFormRouteArgs(
        studyId: study.id,
        measurementId: Config.newModelId,
      ),
      'nutrition',
    ) as NutritionFormViewModel;
    newNutrition.titleControl.value = 'Draft nutrition';

    expect(measurements.measurementTitle(newSurvey), 'Draft survey');
    expect(measurements.measurementTitle(newNutrition), 'Draft nutrition');
    expect(
      measurements.measurementViewModelsCollection.retrievableViewModels.map(
        measurements.measurementTitle,
      ),
      containsAll(['Persisted survey', 'Persisted nutrition']),
    );
  });

  testWidgets('custom survey creation dismisses the picker before navigation', (
    tester,
  ) async {
    final study = Study.withId('study-1');
    final router = _router();
    addTearDown(router.dispose);
    final measurements = MeasurementsFormViewModel(
      study: study,
      router: router,
      formData: MeasurementsFormData(measurements: []),
    );
    final state = StudyControllerState(
      studyId: study.id,
      studyRepository: _MockStudyRepository(),
      router: router,
      currentUser: null,
      studyWithMetadata: WrappedModel(study),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyControllerProvider(study.id).overrideWithValue(state),
          measurementsFormViewModelProvider(study.id)
              .overrideWithValue(measurements),
        ],
        child: MaterialApp(
          home: Scaffold(body: StudyDesignMeasurementsFormView(study.id)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PrimaryButton), findsOneWidget);
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('measurement-picker-create-survey')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('measurement-picker-create-survey')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('measurement-picker-create-survey')),
      findsNothing,
    );
    expect(
      measurements.measurementViewModelsCollection.retrievableViewModels,
      hasLength(1),
    );
    expect(
      router.routeInformationProvider.value.uri.path,
      contains('/edit/measurements/'),
    );
  });
}

GoRouter _router() {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
      GoRoute(
        path: '/studies/:studyId/edit/measurements/:measurementId',
        name: studyEditMeasurementRouteName,
        builder: (_, _) => const SizedBox.shrink(),
      ),
    ],
  );
}

MeasurementSurveyFormData _surveyData(String id, String title) {
  return MeasurementSurveyFormData(
    measurementId: id,
    instanceId: '$id-instance',
    title: title,
    questionnaireFormData: QuestionnaireFormData(questionsData: []),
    isTimeLocked: false,
    hasReminder: false,
  );
}

NutritionFormData _nutritionData(String id, String title) {
  return NutritionFormData(
    measurementId: id,
    instanceId: '$id-instance',
    title: title,
    isTimeLocked: false,
    hasReminder: false,
  );
}

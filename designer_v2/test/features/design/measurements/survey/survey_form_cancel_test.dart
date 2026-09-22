@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_view.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/design/study_form_scaffold.dart';
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

  testWidgets(
    'persisted survey opened from Measurements cancels cleanly but protects edits',
    (tester) async {
      final fixture = await _mountMeasurements(tester);

      await tester.tap(find.text('Persisted survey'));
      await tester.pumpAndSettle();

      expect(fixture.survey.isDirty, isFalse);
      await tester.tap(find.byKey(const ValueKey('form_cancel_button')));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes'), findsNothing);
      expect(find.text('Persisted survey'), findsOneWidget);
      expect(
        fixture.measurements.measurementViewModels,
        contains(fixture.survey),
      );

      await tester.tap(find.text('Persisted survey'));
      await tester.pumpAndSettle();
      fixture.survey.surveyTitleControl.value = 'Edited survey';
      await tester.pump();

      expect(fixture.survey.isDirty, isTrue);
      await tester.tap(find.byKey(const ValueKey('form_cancel_button')));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes'), findsOneWidget);
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();

      expect(find.text('Persisted survey'), findsOneWidget);
      expect(fixture.survey.surveyTitleControl.value, 'Persisted survey');
    },
  );
}

Future<
  ({
    MeasurementsFormViewModel measurements,
    MeasurementSurveyFormViewModel survey,
  })
>
_mountMeasurements(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final study = Study.withId('study-1');
  final templateData = MeasurementSurveyFormData.fromDomainModel(
    SurveyTemplateRegistry.findById('ffq_26')!.buildTask(),
  );
  final surveyData = MeasurementSurveyFormData(
    measurementId: 'survey-1',
    instanceId: 'survey-instance-1',
    title: 'Persisted survey',
    isTimeLocked: true,
    timeLockStart: StudyUTimeOfDay(hour: 8, minute: 15),
    timeLockEnd: StudyUTimeOfDay(hour: 20, minute: 45),
    hasReminder: true,
    reminderTime: StudyUTimeOfDay(hour: 9, minute: 30),
    scheduleRule: TaskScheduleRule.forEveryNDays(2, startOffset: 1),
    questionnaireFormData: templateData.questionnaireFormData,
  );

  late final GoRouter router;
  router = GoRouter(
    initialLocation: '/studies/${study.id}/edit/measurements',
    routes: [
      GoRoute(
        path: '/studies/:studyId/edit/measurements',
        name: studyEditMeasurementsRouteName,
        builder: (_, state) => Scaffold(
          body: SingleChildScrollView(
            child: StudyDesignMeasurementsFormView(
              state.pathParameters['studyId']!,
            ),
          ),
        ),
        routes: [
          GoRoute(
            path: ':measurementId',
            name: studyEditMeasurementRouteName,
            builder: (_, state) {
              final args = MeasurementFormRouteArgs(
                studyId: state.pathParameters['studyId']!,
                measurementId: state.pathParameters['measurementId']!,
              );
              return Consumer(
                builder: (_, ref, _) =>
                    StudyFormScaffold<MeasurementSurveyFormViewModel>(
                      studyId: args.studyId,
                      formViewModelBuilder: (ref) =>
                          ref.watch(measurementFormViewModelProvider(args))!
                              as MeasurementSurveyFormViewModel,
                      formViewBuilder: (survey) => SingleChildScrollView(
                        child: MeasurementSurveyFormView(formViewModel: survey),
                      ),
                    ),
              );
            },
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  final measurements = MeasurementsFormViewModel(
    study: study,
    router: router,
    formData: MeasurementsFormData(measurements: [surveyData]),
  );
  final survey =
      measurements.measurementViewModels.single
          as MeasurementSurveyFormViewModel;
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
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();

  return (measurements: measurements, survey: survey);
}

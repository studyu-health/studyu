@TestOn('browser')
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  test('existing DHQ3 survey is not added again after loading', () {
    final entry = SurveyTemplateRegistry.findById('dhq3_14day')!
        .dayEntries!
        .first;
    final persisted = entry.buildTask()..title = 'About you & coffee/tea';
    final measurements = _measurements(existingSurvey: persisted);

    expect(measurements.applyTemplateDayEntry(entry), isNull);
    expect(
      measurements.measurementViewModelsCollection.retrievableViewModels,
      hasLength(1),
    );
  });

  test('applies one single-survey template and prevents duplicates', () {
    final measurements = _measurements();
    final template = SurveyTemplateRegistry.findById('ffq_26')!;

    final survey = measurements.applyTemplate(template);

    expect(survey, isNotNull);
    expect(survey!.buildFormData().title, template.title);
    expect(survey.questionModels, isNotEmpty);
    expect(measurements.applyTemplate(template), isNull);
    expect(
      measurements.measurementViewModelsCollection.stagedViewModels,
      hasLength(1),
    );
  });

  test('canceling a staged single template allows reapplication', () async {
    final measurements = _measurements();
    final template = SurveyTemplateRegistry.findById('ffq_26')!;
    final survey = measurements.applyTemplate(template)!;

    await survey.cancel();

    expect(
      measurements.measurementViewModelsCollection.stagedViewModels,
      isEmpty,
    );
    expect(
      measurements.measurementViewModelsCollection.retrievableViewModels,
      isEmpty,
    );
    expect(measurements.applyTemplate(template), isNotNull);
  });

  test('applies only the selected multi-day entry and prevents duplicates', () {
    final measurements = _measurements();
    final entry = SurveyTemplateRegistry.findById('dhq3_14day')!.dayEntries![3];

    final survey = measurements.applyTemplateDayEntry(entry);

    expect(survey, isNotNull);
    expect(survey!.buildFormData().title, entry.title);
    expect(survey.buildScheduleRule()!.specificDays, [10]);
    expect(measurements.applyTemplateDayEntry(entry), isNull);
    expect(
      measurements.measurementViewModelsCollection.stagedViewModels,
      hasLength(1),
    );
  });

  test('canceling a staged multi-day entry allows reapplication', () async {
    final measurements = _measurements();
    final entry = SurveyTemplateRegistry.findById('dhq3_14day')!.dayEntries![3];
    final survey = measurements.applyTemplateDayEntry(entry)!;

    await survey.cancel();

    expect(
      measurements.measurementViewModelsCollection.stagedViewModels,
      isEmpty,
    );
    expect(
      measurements.measurementViewModelsCollection.retrievableViewModels,
      isEmpty,
    );
    expect(measurements.applyTemplateDayEntry(entry), isNotNull);
  });

  test('adds selected predefined measurements without duplicates', () async {
    final measurements = _measurements();
    final template = SurveyTemplateRegistry.findById('ffq_26')!;
    final dayEntry = SurveyTemplateRegistry.findById('dhq3_14day')!
        .dayEntries!
        .first;

    await measurements.addPredefinedMeasurements(
      includeNutrition: true,
      templates: [template],
      dayEntries: [dayEntry],
    );
    await measurements.addPredefinedMeasurements(
      includeNutrition: true,
      templates: [template],
      dayEntries: [dayEntry],
    );

    final viewModels =
        measurements.measurementViewModelsCollection.retrievableViewModels;
    expect(viewModels, hasLength(3));
    expect(viewModels.whereType<NutritionFormViewModel>(), hasLength(1));
    expect(
      viewModels.whereType<MeasurementSurveyFormViewModel>(),
      hasLength(2),
    );
  });

  test('disabled occurrence schedule delegates to the default schedule', () {
    final survey = MeasurementSurveyFormViewModel(
      study: Study.withId('study-1'),
    );

    expect(survey.isScheduledControl.value, isFalse);
    expect(survey.buildScheduleRule(), isNull);

    final task = survey.buildFormData().toQuestionnaireTask();
    expect(task.scheduleRule, isNull);
    expect(task.toJson(), isNot(contains('scheduleRule')));
  });

  test('selected schedule mode replaces hidden mode settings', () {
    final survey =
        MeasurementSurveyFormViewModel(study: Study.withId('study-1'))
          ..isScheduledControl.value = true
          ..specificDaysControl.value = [0, 4]
          ..intervalDaysControl.value = 3
          ..startDayOffsetControl.value = 0
          ..dayOfCycleControl.value = 2;

    survey.scheduleTypeControl.value = TaskScheduleType.everyNDays.name;
    final everyNDays = survey.buildScheduleRule()!;
    expect(everyNDays.type, TaskScheduleType.everyNDays);
    expect(everyNDays.specificDays, isEmpty);
    expect(everyNDays.resolveScheduledDays(survey.study.schedule).first, 0);

    survey.scheduleTypeControl.value = TaskScheduleType.perCycle.name;
    final perCycle = survey.buildScheduleRule()!;
    expect(perCycle.type, TaskScheduleType.perCycle);
    expect(perCycle.intervalDays, isNull);
    expect(perCycle.resolveScheduledDays(survey.study.schedule).first, 9);
  });
}

MeasurementsFormViewModel _measurements({QuestionnaireTask? existingSurvey}) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
      GoRoute(
        path: '/studies/:studyId/edit/measurements/:measurementId',
        name: studyEditMeasurementRouteName,
        builder: (_, _) => const SizedBox.shrink(),
      ),
    ],
  );
  addTearDown(router.dispose);
  final study = Study.withId('study-1')..observations = [?existingSurvey];
  return MeasurementsFormViewModel(
    study: study,
    router: router,
    formData: MeasurementsFormData.fromStudy(study),
  );
}

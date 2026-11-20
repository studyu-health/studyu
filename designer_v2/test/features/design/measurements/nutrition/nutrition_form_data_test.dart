import 'package:flutter_test/flutter_test.dart';

import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/time_of_day.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  test(
    'designer edit save round-trips the nutrition task schedule rule',
    () async {
      final task = NutritionTask.withId()
        ..title = 'Nutrition'
        ..scheduleRule = TaskScheduleRule.forEveryNDays(3, startOffset: 1);
      final viewModel = NutritionFormViewModel(
        study: Study('study', 'owner'),
        formData: NutritionFormData.fromDomainModel(task),
      );
      viewModel.titleControl.value = 'Updated nutrition';

      await viewModel.save();

      final savedTask = (viewModel.formData!).toNutritionTask();
      expect(savedTask.scheduleRule?.toJson(), task.scheduleRule?.toJson());
    },
  );

  test('duplicating nutrition form data preserves the schedule rule', () {
    final task = NutritionTask.withId()
      ..title = 'Nutrition'
      ..scheduleRule = TaskScheduleRule.forSpecificDays([2, 5]);
    final viewModel = NutritionFormViewModel(
      study: Study('study', 'owner'),
      formData: NutritionFormData.fromDomainModel(task),
    );

    final duplicateTask = viewModel
        .createDuplicate()
        .buildFormData()
        .toNutritionTask();

    expect(duplicateTask.scheduleRule?.toJson(), task.scheduleRule?.toJson());
  });

  test(
    'editing and duplicating preserve imported completion periods',
    () async {
      final task = NutritionTask.withId()..title = 'Nutrition';
      final originalPeriods = [
        CompletionPeriod(
          id: 'morning',
          unlockTime: StudyUTimeOfDay(hour: 6),
          lockTime: StudyUTimeOfDay(hour: 11),
        ),
        CompletionPeriod(
          id: 'afternoon',
          unlockTime: StudyUTimeOfDay(hour: 12),
          lockTime: StudyUTimeOfDay(hour: 16),
        ),
        CompletionPeriod(
          id: 'evening',
          unlockTime: StudyUTimeOfDay(hour: 18),
          lockTime: StudyUTimeOfDay(hour: 23),
        ),
      ];
      task.schedule.completionPeriods = originalPeriods;
      final viewModel = NutritionFormViewModel(
        study: Study('study', 'owner'),
        formData: NutritionFormData.fromDomainModel(task),
      );

      viewModel.titleControl.value = 'Updated nutrition';
      viewModel.restrictedTimeEndControl.value = const Time(
        hour: 10,
        minute: 30,
      );
      await viewModel.save();

      final saved = viewModel.formData!
          .toNutritionTask()
          .schedule
          .completionPeriods;
      expect(
        saved.map((period) => period.id),
        originalPeriods.map((period) => period.id),
      );
      expect(saved.first.lockTime.toJson(), '10:30');
      expect(
        saved.skip(1).map((period) => period.toJson()),
        originalPeriods.skip(1).map((period) => period.toJson()),
      );

      final duplicate = viewModel
          .createDuplicate()
          .buildFormData()
          .toNutritionTask();
      final duplicatePeriods = duplicate.schedule.completionPeriods;
      final duplicateIds = duplicatePeriods.map((period) => period.id).toSet();
      expect(duplicateIds, hasLength(saved.length));
      expect(
        saved.map((period) => period.id).toSet().intersection(duplicateIds),
        isEmpty,
      );
      Iterable<(String, String)> windows(List<CompletionPeriod> periods) =>
          periods.map(
            (period) => (period.unlockTime.toJson(), period.lockTime.toJson()),
          );
      expect(windows(duplicatePeriods), windows(saved));
    },
  );

  test('new nutrition tasks have no schedule rule', () {
    final viewModel = NutritionFormViewModel(study: Study('study', 'owner'));

    final newTask = viewModel.buildFormData().toNutritionTask();

    expect(newTask.scheduleRule, isNull);
  });

  for (final validationSet in [
    StudyFormValidationSet.publish,
    StudyFormValidationSet.test,
  ]) {
    test('$validationSet requires at least one available minute', () {
      final viewModel = NutritionFormViewModel(
        study: Study('study', 'owner'),
        validationSet: validationSet,
      );
      viewModel.isTimeRestrictedControl.value = true;
      viewModel.restrictedTimeStartControl.value = const Time(
        hour: 8,
        minute: 0,
      );

      viewModel.restrictedTimeEndControl.value = const Time(
        hour: 7,
        minute: 59,
      );
      expect(viewModel.form.valid, isFalse);

      for (final end in [
        const Time(hour: 8, minute: 0),
        const Time(hour: 8, minute: 1),
      ]) {
        viewModel.restrictedTimeEndControl.value = end;
        expect(viewModel.form.valid, isTrue);
      }

      viewModel.restrictedTimeEndControl.value = const Time(hour: 7, minute: 0);
      viewModel.isTimeRestrictedControl.value = false;
      expect(viewModel.form.valid, isTrue);
    });
  }

  test(
    'editing and duplicating a nutrition task preserve water tracking',
    () async {
      final task = NutritionTask.withId()
        ..title = 'Nutrition'
        ..trackWaterIntake = true;
      final viewModel = NutritionFormViewModel(
        study: Study('study', 'owner'),
        formData: NutritionFormData.fromDomainModel(task),
      );
      viewModel.titleControl.value = 'Daily nutrition';
      await viewModel.save();

      expect(viewModel.formData!.toNutritionTask().trackWaterIntake, isTrue);
      expect(
        viewModel
            .createDuplicate()
            .buildFormData()
            .toNutritionTask()
            .trackWaterIntake,
        isTrue,
      );
    },
  );
}

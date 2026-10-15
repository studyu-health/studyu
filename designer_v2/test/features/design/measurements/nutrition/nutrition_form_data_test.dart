import 'package:flutter_test/flutter_test.dart';

import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_data.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

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

  test('new nutrition tasks have no schedule rule', () {
    final viewModel = NutritionFormViewModel(study: Study('study', 'owner'));

    final newTask = viewModel.buildFormData().toNutritionTask();

    expect(newTask.scheduleRule, isNull);
  });
}

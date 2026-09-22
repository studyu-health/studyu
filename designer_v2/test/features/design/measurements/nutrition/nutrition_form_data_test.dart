import 'package:flutter_test/flutter_test.dart';

import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_data.dart';

void main() {
  test('designer edit round-trips the nutrition task schedule rule', () {
    final task = NutritionTask.withId()
      ..title = 'Nutrition'
      ..scheduleRule = TaskScheduleRule.forEveryNDays(3, startOffset: 1);
    final formData = NutritionFormData.fromDomainModel(task);
    final viewModel = NutritionFormViewModel(
      study: Study('study', 'owner'),
      formData: formData,
    );

    final savedTask = viewModel.buildFormData().toNutritionTask();

    expect(savedTask.scheduleRule?.toJson(), task.scheduleRule?.toJson());
  });
}

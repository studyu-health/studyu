import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class NutritionFormData({
  required final MeasurementID measurementId,
  required super.instanceId,
  required final String title,
  final String? instructions,
  required super.isTimeLocked,
  super.timeLockStart,
  super.timeLockEnd,
  required super.hasReminder,
  super.reminderTime,
  final bool collectMealContext = true,
  final bool allowRecipes = true,
  final int? minimumMealsRequired,
  final List<String>? customMealTypes,
}) extends IFormDataWithSchedule {
  static String get kDefaultTitle => 'Nutrition Tracking';

  @override
  FormDataID get id => measurementId;

  factory fromDomainModel(NutritionTask nutritionTask) {
    return NutritionFormData(
      measurementId: nutritionTask.id,
      title: nutritionTask.title ?? '',
      instructions: nutritionTask.instructions,
      isTimeLocked: nutritionTask.schedule.isTimeRestricted,
      timeLockStart: nutritionTask.schedule.restrictedTimeStart,
      timeLockEnd: nutritionTask.schedule.restrictedTimeEnd,
      hasReminder: nutritionTask.schedule.hasReminder,
      reminderTime: nutritionTask.schedule.reminderTime,
      instanceId: nutritionTask.schedule.instanceId,
      collectMealContext: nutritionTask.collectMealContext,
      allowRecipes: nutritionTask.allowRecipes,
      minimumMealsRequired: nutritionTask.minimumMealsRequired,
      customMealTypes: nutritionTask.customMealTypes,
    );
  }

  NutritionTask toNutritionTask() {
    final nutritionTask = NutritionTask();
    nutritionTask.id = measurementId;
    nutritionTask.title = title;
    nutritionTask.instructions = instructions;
    nutritionTask.schedule = toSchedule();
    nutritionTask.collectMealContext = collectMealContext;
    nutritionTask.allowRecipes = allowRecipes;
    nutritionTask.minimumMealsRequired = minimumMealsRequired;
    nutritionTask.customMealTypes = customMealTypes;
    return nutritionTask;
  }

  @override
  NutritionFormData copy() {
    return NutritionFormData(
      measurementId: const Uuid().v4(), // always regenerate id
      instanceId: const Uuid().v4(), // always regenerate id
      title: title.withDuplicateLabel(),
      instructions: instructions,
      isTimeLocked: isTimeLocked,
      timeLockStart: timeLockStart,
      timeLockEnd: timeLockEnd,
      hasReminder: hasReminder,
      reminderTime: reminderTime,
      collectMealContext: collectMealContext,
      allowRecipes: allowRecipes,
      minimumMealsRequired: minimumMealsRequired,
      customMealTypes: customMealTypes != null
          ? List.from(customMealTypes!)
          : null,
    );
  }
}

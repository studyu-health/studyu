import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
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
  final bool allowMeals = true,
  final bool requireDailyCompletionConfirmation = false,
  final int? minimumMealsRequired,
  final List<String>? customMealTypes,
  final TaskScheduleRule? scheduleRule,
}) extends IFormDataWithSchedule {
  static String get kDefaultTitle => tr.form_field_nutrition_default_title;

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
      allowMeals: nutritionTask.allowMeals,
      requireDailyCompletionConfirmation:
          nutritionTask.requireDailyCompletionConfirmation,
      minimumMealsRequired: nutritionTask.minimumMealsRequired,
      customMealTypes: nutritionTask.customMealTypes,
      scheduleRule: nutritionTask.scheduleRule,
    );
  }

  NutritionTask toNutritionTask() {
    final nutritionTask = NutritionTask();
    nutritionTask.id = measurementId;
    nutritionTask.title = title;
    nutritionTask.instructions = instructions;
    nutritionTask.schedule = toSchedule();
    nutritionTask.collectMealContext = collectMealContext;
    nutritionTask.allowMeals = allowMeals;
    nutritionTask.requireDailyCompletionConfirmation =
        requireDailyCompletionConfirmation;
    nutritionTask.minimumMealsRequired = minimumMealsRequired;
    nutritionTask.customMealTypes = customMealTypes;
    nutritionTask.scheduleRule = scheduleRule;
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
      allowMeals: allowMeals,
      requireDailyCompletionConfirmation: requireDailyCompletionConfirmation,
      minimumMealsRequired: minimumMealsRequired,
      customMealTypes: customMealTypes != null
          ? List.from(customMealTypes!)
          : null,
      scheduleRule: scheduleRule,
    );
  }
}

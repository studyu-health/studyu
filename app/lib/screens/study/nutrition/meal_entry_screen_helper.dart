import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';
import 'package:uuid/uuid.dart';

String mealLabelInSentence(AppLocalizations l10n, String label) =>
    label == l10n.meal_neutral_label ? l10n.meal_neutral_label_inline : label;

List<String> mealContextDetails(
  AppLocalizations l10n, {
  required MealContext? mealContext,
  required String? locationDescription,
  required CompanyContext? companyContext,
  required DistractionContext? distractionContext,
}) {
  final location = locationDescription?.trim();
  return [
    if (mealContext == MealContext.other &&
        location != null &&
        location.isNotEmpty)
      location
    else if (mealContext != null)
      mealContextLabel(mealContext, l10n),
    if (companyContext != null) mealCompanyLabel(companyContext, l10n),
    if (distractionContext != null)
      mealDistractionLabel(distractionContext, l10n),
  ];
}

String mealContextLabel(MealContext value, AppLocalizations l10n) {
  switch (value) {
    case MealContext.home:
      return l10n.context_home;
    case MealContext.restaurant:
      return l10n.context_restaurant;
    case MealContext.takeout:
      return l10n.context_takeout;
    case MealContext.vending:
      return l10n.context_vending;
    case MealContext.other:
      return l10n.context_other;
  }
}

String mealCompanyLabel(CompanyContext value, AppLocalizations l10n) {
  switch (value) {
    case CompanyContext.alone:
      return l10n.company_alone;
    case CompanyContext.family:
      return l10n.company_family;
    case CompanyContext.friends:
      return l10n.company_friends;
    case CompanyContext.colleagues:
      return l10n.company_colleagues;
    case CompanyContext.other:
      return l10n.company_other;
  }
}

String mealDistractionLabel(DistractionContext value, AppLocalizations l10n) {
  switch (value) {
    case DistractionContext.none:
      return l10n.distraction_none;
    case DistractionContext.tv:
      return l10n.distraction_tv;
    case DistractionContext.phone:
      return l10n.distraction_phone;
    case DistractionContext.work:
      return l10n.distraction_work;
    case DistractionContext.other:
      return l10n.distraction_other;
  }
}

double? parseNutritionAmount(String input) {
  final amount = double.tryParse(input.trim().replaceFirst(',', '.'));
  return amount != null && amount.isFinite && amount >= 0 ? amount : null;
}

/// Finds the local occurrences of a clock time within the selected UTC day.
List<DateTime> localMealTimesOnUtcDay(
  DateTime day, {
  required int hour,
  required int minute,
}) {
  final start = DateTime.utc(day.year, day.month, day.day);
  final matches = <DateTime>[];
  for (var offset = 0; offset < Duration.minutesPerDay; offset++) {
    final local = start.add(Duration(minutes: offset)).toLocal();
    if (local.hour == hour && local.minute == minute) matches.add(local);
  }
  return matches;
}

MealLog cloneMealLog(MealLog meal) => MealLog.fromJson(
  jsonDecode(jsonEncode(meal.toJson())) as Map<String, dynamic>,
);

FoodEntry cloneFoodEntry(FoodEntry food) {
  final clone = FoodEntry.fromJson(
    jsonDecode(jsonEncode(food.toJson())) as Map<String, dynamic>,
  );
  clone.nutrition
    ..unavailableNutrients = {...food.nutrition.unavailableNutrients}
    ..unavailableItemCount = food.nutrition.unavailableItemCount;
  return clone;
}

FoodEntry duplicateFoodEntry(FoodEntry food) {
  final duplicate = cloneFoodEntry(food)
    ..id = const Uuid().v4()
    ..createdAt = DateTime.now()
    ..modifiedAt = null
    ..parentEntryId = null;
  duplicate.componentFoods = duplicate.componentFoods
      ?.map(
        (composition) => FoodComposition.withId(
          parentEntryId: duplicate.id,
          foodId: composition.foodId,
          amount: composition.amount,
          unit: composition.unit,
          sortOrder: composition.sortOrder,
        ),
      )
      .toList();
  return duplicate;
}

FoodEntry rescaleFoodAmount(FoodEntry food, double newAmount) {
  if (!food.amount.isFinite || food.amount <= 0) {
    throw ArgumentError.value(food.amount, 'food.amount', 'Must be positive');
  }
  if (!newAmount.isFinite || newAmount <= 0) {
    throw ArgumentError.value(newAmount, 'newAmount', 'Must be positive');
  }

  final scaled = cloneFoodEntry(food);
  final factor = newAmount / food.amount;
  final nutrition = scaled.nutrition;

  nutrition
    ..energyKcal *= factor
    ..protein *= factor
    ..carbs *= factor
    ..fat *= factor
    ..sugars *= factor
    ..fiber *= factor
    ..saturatedFat *= factor
    ..transFat *= factor
    ..cholesterol *= factor
    ..sodium *= factor
    ..waterContent *= factor
    ..micros = nutrition.micros.map(
      (nutrient, value) => MapEntry(nutrient, value * factor),
    );
  scaled.amount = newAmount;
  return scaled;
}

enum NutritionLibraryEditChoice() {
  current,
  currentAndLibrary,
}

bool canCopyDatabaseFoodToLibrary(FoodEntry food) =>
    food.source != FoodSource.manual &&
    food.entryType != FoodEntryType.meal &&
    food.templateId?.isNotEmpty != true;

Future<NutritionLibraryEditChoice?> showNutritionLibraryEditChoiceDialog({
  required BuildContext context,
  required String currentScopeLabel,
  required String message,
  bool createLibraryCopy = false,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<NutritionLibraryEditChoice>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      scrollable: true,
      title: Text(
        createLibraryCopy
            ? l10n.library_copy_edit_title
            : l10n.library_edit_title,
      ),
      content: Text(
        createLibraryCopy ? l10n.library_copy_edit_message : message,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.cancel),
        ),
        OutlinedButton(
          onPressed: () =>
              Navigator.pop(dialogContext, NutritionLibraryEditChoice.current),
          child: Text(currentScopeLabel),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(
            dialogContext,
            NutritionLibraryEditChoice.currentAndLibrary,
          ),
          child: Text(
            createLibraryCopy
                ? l10n.library_copy_edit_action
                : l10n.library_edit_current_entry_and_library,
          ),
        ),
      ],
    ),
  );
}

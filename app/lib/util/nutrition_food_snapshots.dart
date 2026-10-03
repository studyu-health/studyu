import 'package:studyu_core/core.dart';

/// Converts occurrence-scaled nutrition to the reusable one-serving basis.
FoodEntry normalizeNutritionFoodDefinition(FoodEntry occurrence) {
  final definition = FoodEntry.fromJson(occurrence.toJson());
  final occurrenceAmount = occurrence.amount;
  if (!occurrenceAmount.isFinite || occurrenceAmount <= 0) {
    throw ArgumentError.value(occurrenceAmount, 'amount');
  }
  _scaleNutrition(definition.nutrition, 1 / occurrenceAmount);
  return definition..amount = 1;
}

/// Expands meal occurrences into leaf food snapshots.
///
/// Saved meal components are stored on a one-serving basis. [FoodEntry.amount]
/// therefore scales every component, including components of nested meals.
List<FoodEntry> flattenNutritionFoodEntries(Iterable<FoodEntry> foods) => [
  for (final food in foods) ..._flattenFood(food, multiplier: 1),
];

List<FoodEntry> _flattenFood(FoodEntry food, {required double multiplier}) {
  if (food.entryType != FoodEntryType.meal) {
    return [_rescaleFoodAmount(food, food.amount * multiplier)];
  }
  final servings = food.amount;
  if (!servings.isFinite || servings <= 0) {
    throw StateError('Saved meal amount must be positive');
  }
  final compositions = food.componentFoods;
  final snapshots = food.componentSnapshots;
  if (compositions == null ||
      snapshots == null ||
      compositions.length != snapshots.length) {
    throw StateError('Saved meal requires complete food ingredients');
  }
  final flattened = <FoodEntry>[];
  for (var index = 0; index < compositions.length; index++) {
    final composition = compositions[index];
    final snapshot = snapshots[index];
    if (composition.foodId != snapshot.foodId) {
      throw StateError('Saved meal ingredients do not match their snapshots');
    }
    if (!composition.amount.isFinite || composition.amount <= 0) {
      throw StateError('Saved meal ingredient amount must be positive');
    }
    if (!snapshot.amount.isFinite || snapshot.amount <= 0) {
      throw StateError('Saved meal ingredient snapshot is incomplete');
    }
    final componentMultiplier =
        multiplier * servings * composition.amount / snapshot.amount;
    flattened.addAll(_flattenFood(snapshot, multiplier: componentMultiplier));
  }
  return flattened;
}

/// Converts a meal creator result to a one-serving reusable definition.
FoodEntry normalizeCompositeNutritionFoodDefinition(FoodEntry meal) {
  final servings = meal.amount;
  if (meal.entryType != FoodEntryType.meal ||
      !servings.isFinite ||
      servings <= 0) {
    throw ArgumentError.value(servings, 'amount');
  }
  final definition = FoodEntry.fromJson(meal.toJson());
  final compositions = definition.componentFoods;
  final snapshots = definition.componentSnapshots;
  if (compositions == null ||
      snapshots == null ||
      compositions.length != snapshots.length) {
    throw StateError('Saved meal requires complete food ingredients');
  }
  final reusableOccurrence = meal.templateId?.isNotEmpty == true;
  for (var index = 0; index < compositions.length; index++) {
    final composition = compositions[index];
    final snapshot = snapshots[index];
    if (composition.foodId != snapshot.foodId) {
      throw StateError('Saved meal ingredients do not match their snapshots');
    }
    if (!reusableOccurrence) {
      composition.amount /= servings;
      snapshots[index] = _rescaleFoodAmount(
        snapshot,
        snapshot.amount / servings,
      );
    }
  }
  definition.amount = 1;
  final flattened = flattenNutritionFoodEntries([definition]);
  if (flattened.isEmpty) {
    throw StateError('Saved meals require at least one food ingredient');
  }
  definition.componentFoods = [
    for (var index = 0; index < flattened.length; index++)
      FoodComposition.withId(
        parentEntryId: definition.id,
        foodId: flattened[index].foodId,
        amount: flattened[index].amount,
        unit: flattened[index].unit,
        sortOrder: index,
      ),
  ];
  definition.componentSnapshots = flattened;
  return definition;
}

/// Applies reusable fields while retaining occurrence-owned identity/quantity.
FoodEntry applyNutritionFoodSnapshot(FoodEntry logged, FoodEntry definition) {
  final updated = FoodEntry.fromJson(definition.toJson());
  final definitionAmount = definition.amount;
  if (definitionAmount.isFinite && definitionAmount > 0) {
    _scaleNutrition(updated.nutrition, logged.amount / definitionAmount);
  }
  return updated
    ..id = logged.id
    ..amount = logged.amount
    ..templateId = logged.templateId
    ..createdAt = logged.createdAt
    ..modifiedAt = logged.modifiedAt
    ..parentEntryId = logged.parentEntryId;
}

DailyRecall replaceNutritionFoodSnapshots(
  DailyRecall recall,
  FoodEntry definition, {
  String? entryId,
}) {
  final updated = DailyRecall.fromJson(recall.toJson());
  for (final meal in updated.meals) {
    for (var index = 0; index < meal.foods.length; index++) {
      final logged = meal.foods[index];
      if (logged.foodId == definition.foodId &&
          (entryId == null || logged.id == entryId)) {
        meal.foods[index] = applyNutritionFoodSnapshot(logged, definition);
      }
    }
  }
  return updated;
}

FoodEntry _rescaleFoodAmount(FoodEntry food, double amount) {
  if (!food.amount.isFinite ||
      food.amount <= 0 ||
      !amount.isFinite ||
      amount <= 0) {
    throw ArgumentError.value(amount, 'amount');
  }
  final scaled = FoodEntry.fromJson(food.toJson());
  _scaleNutrition(scaled.nutrition, amount / food.amount);
  return scaled..amount = amount;
}

void _scaleNutrition(NutritionProfile nutrition, double factor) {
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
}

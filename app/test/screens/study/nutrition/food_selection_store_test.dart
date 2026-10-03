import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_core/core.dart' as studyu;

void main() {
  test('selection store combines quantities and materializes scaled food', () {
    final store = FoodSelectionStore();
    final entry = food(id: 'apple', calories: 95);

    store
      ..addOrIncrement('apple', entry)
      ..addOrIncrement('apple', entry);

    expect(store.itemCount, 1);
    expect(store.servingCount, 2);
    expect(store.knownCalories(), 190);
    expect(store.materialize().single.amount, 2);

    store.decrement('apple');
    expect(store.itemFor('apple')?.quantity, 1);

    store.decrement('apple');
    expect(store.isEmpty, isTrue);
  });

  test('selection weight override retains baseline, scales, and resets', () {
    final store = FoodSelectionStore();
    final entry = food(id: 'apple', calories: 95);
    store
      ..addOrIncrement('apple', entry)
      ..addOrIncrement('apple', entry);

    final weighedServing = rescaleFoodAmount(entry, 0.5)
      ..amount = 1
      ..servingSizeGrams = 50;
    store.replaceBase(
      'apple',
      rescaleFoodAmount(weighedServing, 2),
      caloriesKnown: true,
      gramsKnown: true,
    );

    final item = store.itemFor('apple')!;
    expect(entry.servingSizeGrams, 100);
    expect(entry.nutrition.energyKcal, 95);
    expect(item.baselineFood.servingSizeGrams, 100);
    expect(item.baselineFood.nutrition.energyKcal, 95);
    expect(item.baseFood.servingSizeGrams, 50);
    expect(item.baseFood.nutrition.energyKcal, 47.5);
    expect(item.quantity, 2);
    expect(item.servingWeightOverridden, isTrue);

    store.increment('apple');
    final materialized = store.materialize().single;
    expect(materialized.amount, 3);
    expect(materialized.servingSizeGrams, 50);
    expect(materialized.nutrition.energyKcal, 142.5);

    store.replaceBase(
      'apple',
      rescaleFoodAmount(item.baselineFood, 3),
      caloriesKnown: true,
      gramsKnown: true,
    );
    expect(item.quantity, 3);
    expect(item.baseFood.servingSizeGrams, 100);
    expect(item.baseFood.nutrition.energyKcal, 95);
    expect(item.servingWeightOverridden, isFalse);
  });

  test('unknown baseline detects custom weight and survives removal undo', () {
    final store = FoodSelectionStore();
    final entry = food(id: 'apple');
    store.addOrIncrement('apple', entry, gramsKnown: false);

    store.replaceBase(
      'apple',
      entry..servingSizeGrams = 80,
      caloriesKnown: true,
      gramsKnown: true,
    );
    final removed = store.itemFor('apple')!;
    expect(removed.baselineGramsKnown, isFalse);
    expect(removed.servingWeightOverridden, isTrue);

    store.delete('apple');
    store.restore(removed);

    final restored = store.itemFor('apple')!;
    expect(restored.baselineGramsKnown, isFalse);
    expect(restored.baselineFood.servingSizeGrams, 100);
    expect(restored.baseFood.servingSizeGrams, 80);
    expect(restored.quantity, 1);
    expect(restored.servingWeightOverridden, isTrue);
  });

  test('canonical key prefers template and external identities', () {
    expect(
      canonicalFoodSelectionKey(
        food(id: 'local', templateId: 'template-id', externalId: 'external-id'),
      ),
      'template:template-id',
    );
    expect(
      canonicalFoodSelectionKey(
        food(id: 'local', source: studyu.FoodSource.usda, externalId: '123'),
      ),
      'usda:id:123',
    );
  });
}

studyu.FoodEntry food({
  required String id,
  double calories = 100,
  String? templateId,
  String? externalId,
  studyu.FoodSource source = studyu.FoodSource.manual,
}) => studyu.FoodEntry(
  id: id,
  foodId: '$id-definition',
  foodVersionId: '$id-version',
  entryType: studyu.FoodEntryType.singleIngredient,
  name: 'Apple',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
  portionState: studyu.PortionState.asServed,
  nutrition: studyu.NutritionProfile(
    energyKcal: calories,
    protein: 1,
    carbs: 1,
    fat: 1,
    sugars: 0,
    fiber: 0,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: const {},
  ),
  templateId: templateId,
  externalId: externalId,
  source: source,
  confidenceScore: 1,
  createdAt: DateTime.utc(2024),
  originalValues: const {},
);

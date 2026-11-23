import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('composite snapshots round-trip in composition order', () {
    final first = _food('first', 'First');
    final second = _food('second', 'Second');
    final meal = _food('meal', 'Meal')
      ..entryType = FoodEntryType.meal
      ..componentFoods = [
        _composition('composition-first', 'meal-entry', first.foodId, 0),
        _composition('composition-second', 'meal-entry', second.foodId, 1),
      ]
      ..componentSnapshots = [first, second];

    final restored = FoodEntry.fromJson(meal.toJson());

    expect(restored.componentFoods!.map((component) => component.foodId), [
      'first-definition',
      'second-definition',
    ]);
    expect(restored.componentSnapshots!.map((component) => component.foodId), [
      'first-definition',
      'second-definition',
    ]);
    expect(restored.componentSnapshots!.map((component) => component.name), [
      'First',
      'Second',
    ]);
  });

  test(
    'serialized food snapshots require their definition and version IDs',
    () {
      final food = _food('food', 'Food');
      for (final field in ['foodId', 'foodVersionId']) {
        final incomplete = food.toJson()..remove(field);
        expect(() => FoodEntry.fromJson(incomplete), throwsA(isA<TypeError>()));
      }
    },
  );
}

FoodComposition _composition(
  String id,
  String parentEntryId,
  String foodId,
  int sortOrder,
) => FoodComposition(
  id: id,
  parentEntryId: parentEntryId,
  foodId: foodId,
  amount: 1,
  unit: 'serving',
  sortOrder: sortOrder,
);

FoodEntry _food(String id, String name) => FoodEntry(
  id: '$id-entry',
  foodId: '$id-definition',
  foodVersionId: '$id-version',
  entryType: FoodEntryType.singleIngredient,
  name: name,
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 100,
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
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.utc(2026, 7, 15),
  originalValues: const {},
);

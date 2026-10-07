import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_core/core.dart';

FoodEntry foodEntry({double amount = 2}) => FoodEntry(
  id: 'food-id',
  foodId: 'food-definition',
  foodVersionId: 'food-version',
  entryType: FoodEntryType.meal,
  name: 'Soup',
  brandName: 'Kitchen',
  description: 'Description',
  amount: amount,
  unit: 'bowl',
  servingSizeGrams: 250,
  portionReference: '1 bowl',
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  yieldFactor: 0.8,
  ediblePortion: 0.9,
  nutrition: NutritionProfile(
    energyKcal: 100,
    protein: 2,
    carbs: 3,
    fat: 4,
    sugars: 5,
    fiber: 6,
    saturatedFat: 7,
    transFat: 8,
    cholesterol: 9,
    sodium: 10,
    waterContent: 11,
    micros: {'iron': 12, 'vitaminC': 13},
    unavailableNutrients: const {'fiber'},
    unavailableItemCount: 1,
  ),
  foodCode: 'code',
  externalId: 'external-id',
  source: FoodSource.usda,
  confidenceScore: 0.7,
  templateId: 'template-id',
  createdAt: DateTime.utc(2026, 7, 15),
  modifiedAt: DateTime.utc(2026, 7, 16),
  originalValues: {
    'nested': {
      'values': [1, 2],
    },
  },
  parentEntryId: 'parent-id',
  preparationDetails: PreparationDetails(
    rawWeight: 500,
    cookedWeight: 400,
    yieldFactor: 0.8,
    preparationMethod: 'boiled',
    retentionFactors: {'iron': 0.9},
  ),
  componentFoods: [
    FoodComposition(
      id: 'composition-id',
      parentEntryId: 'food-id',
      foodId: 'ingredient-id',
      amount: 1,
      unit: 'piece',
    ),
  ],
);

void main() {
  test('duplicates food with fresh identity and isolated nested state', () {
    final source = foodEntry();
    final duplicate = duplicateFoodEntry(source);

    expect(duplicate.id, isNot(source.id));
    expect(duplicate.foodId, source.foodId);
    expect(duplicate.foodVersionId, source.foodVersionId);
    expect(duplicate.createdAt, isNot(source.createdAt));
    expect(duplicate.modifiedAt, isNull);
    expect(duplicate.parentEntryId, isNull);
    expect(duplicate.source, source.source);
    expect(duplicate.externalId, source.externalId);
    expect(duplicate.templateId, source.templateId);
    expect(duplicate.componentFoods!.single.id, isNot('composition-id'));
    expect(duplicate.componentFoods!.single.parentEntryId, duplicate.id);

    (duplicate.originalValues['nested'] as Map<String, dynamic>)['changed'] =
        true;
    duplicate.nutrition.micros['iron'] = 0;
    duplicate.preparationDetails!.retentionFactors['iron'] = 0;
    duplicate.componentFoods!.single.amount = 99;

    expect(source.originalValues, {
      'nested': {
        'values': [1, 2],
      },
    });
    expect(source.nutrition.micros['iron'], 12);
    expect(source.preparationDetails!.retentionFactors['iron'], 0.9);
    expect(source.componentFoods!.single.amount, 1);
  });

  test('rescales every nutrient without changing per-unit metadata', () {
    final source = foodEntry();
    final scaled = rescaleFoodAmount(source, 4);

    expect(scaled.amount, 4);
    expect(scaled.nutrition.energyKcal, 200);
    expect(scaled.nutrition.protein, 4);
    expect(scaled.nutrition.carbs, 6);
    expect(scaled.nutrition.fat, 8);
    expect(scaled.nutrition.sugars, 10);
    expect(scaled.nutrition.fiber, 12);
    expect(scaled.nutrition.saturatedFat, 14);
    expect(scaled.nutrition.transFat, 16);
    expect(scaled.nutrition.cholesterol, 18);
    expect(scaled.nutrition.sodium, 20);
    expect(scaled.nutrition.waterContent, 22);
    expect(scaled.nutrition.micros, {'iron': 24, 'vitaminC': 26});
    expect(scaled.nutrition.unavailableNutrients, {'fiber'});
    expect(scaled.nutrition.unavailableItemCount, 1);

    expect(scaled.id, source.id);
    expect(scaled.foodId, source.foodId);
    expect(scaled.foodVersionId, source.foodVersionId);
    expect(scaled.servingSizeGrams, 250);
    expect(scaled.source, FoodSource.usda);
    expect(scaled.externalId, 'external-id');
    expect(scaled.templateId, 'template-id');
    expect(scaled.preparationDetails!.retentionFactors, {'iron': 0.9});
    expect(scaled.componentFoods!.single.amount, 1);

    (scaled.originalValues['nested'] as Map<String, dynamic>)['changed'] = true;
    scaled.preparationDetails!.retentionFactors['iron'] = 0;
    scaled.componentFoods!.single.amount = 99;
    scaled.nutrition.micros['iron'] = 0;

    expect(source.originalValues, {
      'nested': {
        'values': [1, 2],
      },
    });
    expect(source.preparationDetails!.retentionFactors['iron'], 0.9);
    expect(source.componentFoods!.single.amount, 1);
    expect(source.nutrition.micros['iron'], 12);
    expect(source.amount, 2);
  });

  test('round trip amount scaling restores the original totals', () {
    final source = foodEntry(amount: 1);
    final restored = rescaleFoodAmount(rescaleFoodAmount(source, 2), 1);

    expect(restored.nutrition.toJson(), source.nutrition.toJson());
  });

  test('rejects invalid source and target amounts', () {
    for (final amount in [0.0, -1.0, double.nan, double.infinity]) {
      expect(
        () => rescaleFoodAmount(foodEntry(amount: amount), 1),
        throwsArgumentError,
      );
      expect(() => rescaleFoodAmount(foodEntry(), amount), throwsArgumentError);
    }
  });
}

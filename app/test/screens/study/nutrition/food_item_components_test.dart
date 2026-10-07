import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_core/core.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('food metadata prefers total grams and marks unknown calories', () {
    final food = _food(amount: 2, servingSizeGrams: 50, energyKcal: 120);
    final unknownFood = _food(
      amount: 2,
      unavailableNutrients: const {'energyKcal'},
    );

    expect(foodTotalMetadata(l10n, food, 2), '200 g · 240 kcal');
    expect(
      foodTotalMetadata(l10n, unknownFood, 2, gramsKnown: false),
      '4 × 1 bowl · — kcal',
    );
  });

  test('food metadata localizes the serving fallback', () {
    final food = _food(amount: 2, portionReference: null);

    expect(
      foodTotalMetadata(l10n, food, 2, gramsKnown: false),
      '4 servings · 200 kcal',
    );
  });

  test('known zero calories are distinct from unavailable calories', () {
    expect(
      formatFoodMetadata(
        l10n,
        servingDescription: l10n.serving_amount(1),
        calories: 0,
      ),
      '1 serving · 0 kcal',
    );
    expect(
      formatFoodMetadata(l10n, servingDescription: l10n.serving_amount(1)),
      '1 serving · — kcal',
    );
  });
}

FoodEntry _food({
  double amount = 1,
  double servingSizeGrams = 100,
  double energyKcal = 100,
  String? portionReference = '1 bowl',
  Set<String> unavailableNutrients = const {},
}) => FoodEntry.withId(
  entryType: FoodEntryType.brandedProduct,
  name: 'Soup',
  amount: amount,
  unit: 'serving',
  servingSizeGrams: servingSizeGrams,
  portionReference: portionReference,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: energyKcal,
    protein: 0,
    carbs: 0,
    fat: 0,
    sugars: 0,
    fiber: 0,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: const {},
    unavailableNutrients: unavailableNutrients,
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  originalValues: const {},
);

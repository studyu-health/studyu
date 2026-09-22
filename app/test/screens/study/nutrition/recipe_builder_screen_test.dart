import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/study/nutrition/recipe_builder_screen.dart';
import 'package:studyu_core/core.dart';

void main() {
  test('recipe nutrition divides micros by servings like other nutrients', () {
    final ingredient = _food(
      amount: 1,
      energy: 100,
      protein: 10,
      carbs: 20,
      fat: 5,
      sugars: 4,
      fiber: 3,
      saturatedFat: 2,
      transFat: 1,
      cholesterol: 6,
      sodium: 7,
      waterContent: 8,
      micros: {'iron': 9},
    );
    final composition = RecipeComposition(
      id: 'composition',
      recipeId: 'recipe',
      ingredientId: ingredient.id,
      amount: 2,
      unit: 'serving',
    );

    final perServing = calculateRecipeNutrition(
      ingredientFoods: [ingredient],
      ingredients: [composition],
      servings: 2,
    );

    expect(perServing.energyKcal, 100);
    expect(perServing.protein, 10);
    expect(perServing.fiber, 3);
    expect(perServing.micros['iron'], 9);

    final recipe = _food(
      amount: 2,
      energy: perServing.energyKcal,
      protein: perServing.protein,
      carbs: perServing.carbs,
      fat: perServing.fat,
      sugars: perServing.sugars,
      fiber: perServing.fiber,
      saturatedFat: perServing.saturatedFat,
      transFat: perServing.transFat,
      cholesterol: perServing.cholesterol,
      sodium: perServing.sodium,
      waterContent: perServing.waterContent,
      micros: perServing.micros,
      entryType: FoodEntryType.recipe,
    );

    expect(recipe.totalNutrition.energyKcal, 200);
    expect(recipe.totalNutrition.micros['iron'], 18);
  });
}

FoodEntry _food({
  required double amount,
  required double energy,
  required double protein,
  required double carbs,
  required double fat,
  required double sugars,
  required double fiber,
  required double saturatedFat,
  required double transFat,
  required double cholesterol,
  required double sodium,
  required double waterContent,
  required Map<String, double> micros,
  FoodEntryType entryType = FoodEntryType.singleIngredient,
}) {
  return FoodEntry(
    id: 'food',
    entryType: entryType,
    name: 'Food',
    amount: amount,
    unit: 'serving',
    servingSizeGrams: 100,
    portionEstimationMethod: PortionEstimationMethod.standardUnit,
    portionState: PortionState.asServed,
    nutrition: NutritionProfile(
      energyKcal: energy,
      protein: protein,
      carbs: carbs,
      fat: fat,
      sugars: sugars,
      fiber: fiber,
      saturatedFat: saturatedFat,
      transFat: transFat,
      cholesterol: cholesterol,
      sodium: sodium,
      waterContent: waterContent,
      micros: micros,
    ),
    source: FoodSource.manual,
    confidenceScore: 1,
    createdAt: DateTime(2026, 9, 22),
    originalValues: const {},
  );
}

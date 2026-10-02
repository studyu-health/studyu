import 'package:studyu_core/src/models/nutrition/daily_recall.dart';
import 'package:studyu_core/src/models/nutrition/food_entry.dart';
import 'package:studyu_core/src/models/nutrition/meal_log.dart';
import 'package:studyu_core/src/models/nutrition/nutrition_profile.dart';

extension FoodEntryNutritionCalculation on FoodEntry {
  /// Nutrition values describe one unit of this entry. [amount] is the number
  /// of those units consumed.
  NutritionProfile get totalNutrition => _scaledNutrition(nutrition, amount);
}

extension MealLogNutritionCalculation on MealLog {
  NutritionProfile get totalNutrition =>
      _sumNutrition(foods.map((FoodEntry food) => food.totalNutrition));
}

extension DailyRecallNutritionCalculation on DailyRecall {
  NutritionProfile get totalNutrition => _sumNutrition(
    meals
        .where((MealLog meal) => !meal.isSkipped)
        .map((MealLog meal) => meal.totalNutrition),
  );
}

NutritionProfile _scaledNutrition(NutritionProfile nutrition, double factor) {
  return NutritionProfile(
    energyKcal: nutrition.energyKcal * factor,
    protein: nutrition.protein * factor,
    carbs: nutrition.carbs * factor,
    fat: nutrition.fat * factor,
    sugars: nutrition.sugars * factor,
    fiber: nutrition.fiber * factor,
    saturatedFat: nutrition.saturatedFat * factor,
    transFat: nutrition.transFat * factor,
    cholesterol: nutrition.cholesterol * factor,
    sodium: nutrition.sodium * factor,
    waterContent: nutrition.waterContent * factor,
    micros: nutrition.micros.map((key, value) => MapEntry(key, value * factor)),
  );
}

NutritionProfile _sumNutrition(Iterable<NutritionProfile> profiles) {
  final total = NutritionProfile(
    energyKcal: 0,
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
    micros: {},
  );

  for (final profile in profiles) {
    total.energyKcal += profile.energyKcal;
    total.protein += profile.protein;
    total.carbs += profile.carbs;
    total.fat += profile.fat;
    total.sugars += profile.sugars;
    total.fiber += profile.fiber;
    total.saturatedFat += profile.saturatedFat;
    total.transFat += profile.transFat;
    total.cholesterol += profile.cholesterol;
    total.sodium += profile.sodium;
    total.waterContent += profile.waterContent;
    profile.micros.forEach((key, value) {
      total.micros[key] = (total.micros[key] ?? 0) + value;
    });
  }

  return total;
}

import 'package:studyu_core/src/models/nutrition/daily_recall.dart';
import 'package:studyu_core/src/models/nutrition/food_entry.dart';
import 'package:studyu_core/src/models/nutrition/meal_log.dart';
import 'package:studyu_core/src/models/nutrition/nutrition_profile.dart';

extension FoodEntryNutritionCalculation on FoodEntry {
  /// Nutrition values describe one unit of this entry. [amount] is the number
  /// of those units consumed.
  NutritionProfile get totalNutrition =>
      scaleNutritionProfile(nutrition, amount);
}

extension MealLogNutritionCalculation on MealLog {
  NutritionProfile get totalNutrition =>
      sumNutritionProfiles(foods.map((FoodEntry food) => food.totalNutrition));
}

extension DailyRecallNutritionCalculation on DailyRecall {
  NutritionProfile get totalNutrition => sumNutritionProfiles(
    meals
        .where((MealLog meal) => !meal.isSkipped)
        .map((MealLog meal) => meal.totalNutrition),
  );
}

NutritionProfile scaleNutritionProfile(
  NutritionProfile nutrition,
  double factor,
) {
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
    unavailableNutrients: {...nutrition.unavailableNutrients},
    partialNutrients: {...nutrition.partialNutrients},
    unavailableItemCount: nutrition.unavailableItemCount,
  );
}

/// Adds only known values and retains missing contributions at every level.
NutritionProfile sumNutritionProfiles(Iterable<NutritionProfile> profiles) {
  final sources = profiles.toList();
  final keys = {
    ...NutritionProfile.nutrientKeys,
    for (final profile in sources) ...[
      ...profile.micros.keys.map((key) => 'micros.$key'),
      ...profile.unavailableNutrients.where((key) => key.startsWith('micros.')),
      ...profile.partialNutrients.where((key) => key.startsWith('micros.')),
    ],
  };
  final unavailable = <String>{};
  final partial = <String>{};
  final values = <String, double>{};
  for (final key in keys) {
    final known = sources.where((profile) => profile.isKnown(key)).toList();
    values[key] = known.fold(
      0.0,
      (sum, profile) => sum + profile.valueFor(key),
    );
    if (known.isEmpty) {
      unavailable.add(key);
    } else if (known.length != sources.length ||
        known.any((profile) => profile.isPartial(key))) {
      partial.add(key);
    }
  }
  return NutritionProfile(
    energyKcal: values['energyKcal']!,
    protein: values['protein']!,
    carbs: values['carbs']!,
    fat: values['fat']!,
    sugars: values['sugars']!,
    fiber: values['fiber']!,
    saturatedFat: values['saturatedFat']!,
    transFat: values['transFat']!,
    cholesterol: values['cholesterol']!,
    sodium: values['sodium']!,
    waterContent: values['waterContent']!,
    micros: {
      for (final key in keys.where((key) => key.startsWith('micros.')))
        key.substring(7): values[key]!,
    },
    unavailableNutrients: unavailable,
    partialNutrients: partial,
    unavailableItemCount: sources.fold(
      0,
      (count, profile) =>
          count +
          (profile.unavailableItemCount > 0
              ? profile.unavailableItemCount
              : profile.unavailableNutrients.isNotEmpty ||
                    profile.partialNutrients.isNotEmpty
              ? 1
              : 0),
    ),
  );
}

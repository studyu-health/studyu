import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/models.dart';

part 'nutrition_task.g.dart';

@JsonSerializable()
class NutritionTask extends Observation {
  static const String taskType = 'nutrition';

  /// Instructions for participants on how to record their nutrition
  String? instructions;

  /// Whether to prompt for meal context (location, company, distractions)
  @JsonKey(defaultValue: true)
  bool collectMealContext = true;

  /// Whether to prompt for recipe details
  @JsonKey(defaultValue: true)
  bool allowRecipes = true;

  /// Minimum number of meals required per day (optional)
  int? minimumMealsRequired;

  /// Custom meal types if needed (otherwise uses default enum values)
  List<String>? customMealTypes;

  new() : super(taskType);

  new withId() : super.withId(taskType);

  factory fromJson(Map<String, dynamic> json) => _$NutritionTaskFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NutritionTaskToJson(this);

  @override
  Map<DateTime, T> extractPropertyResults<T>(
    String property,
    List<SubjectProgress> sourceResults,
  ) {
    return Map.fromEntries(
      sourceResults.map((e) {
        final result = (e.result as Result<DailyRecall>).result;

        final nutrition = result.totalNutrition;

        // Extract different properties based on what's requested
        dynamic value;
        switch (property) {
          case 'totalCalories':
            value = nutrition.energyKcal;
          case 'totalProtein':
            value = nutrition.protein;
          case 'totalCarbs':
            value = nutrition.carbs;
          case 'totalFat':
            value = nutrition.fat;
          case 'mealCount':
            value = result.meals
                .where((MealLog meal) => !meal.isSkipped)
                .length;
          case 'completionTime':
            value = result.entryCompletedAt;
          default:
            throw ArgumentError(
              "Nutrition task does not support property '$property'.",
            );
        }

        return MapEntry(e.completedAt!, value as T);
      }),
    );
  }

  @override
  Map<String, Type> getAvailableProperties() => {
    'totalCalories': double,
    'totalProtein': double,
    'totalCarbs': double,
    'totalFat': double,
    'mealCount': int,
    'completionTime': DateTime,
  };

  @override
  String? getHumanReadablePropertyName(String property) {
    switch (property) {
      case 'totalCalories':
        return 'Total Calories (kcal)';
      case 'totalProtein':
        return 'Total Protein (g)';
      case 'totalCarbs':
        return 'Total Carbohydrates (g)';
      case 'totalFat':
        return 'Total Fat (g)';
      case 'mealCount':
        return 'Number of Meals';
      case 'completionTime':
        return 'Completion Time';
      default:
        return null;
    }
  }
}

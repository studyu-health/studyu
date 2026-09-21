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

        // Extract different properties based on what's requested
        dynamic value;
        switch (property) {
          case 'totalCalories':
            value = _calculateTotalCalories(result);
          case 'totalProtein':
            value = _calculateTotalProtein(result);
          case 'totalCarbs':
            value = _calculateTotalCarbs(result);
          case 'totalFat':
            value = _calculateTotalFat(result);
          case 'mealCount':
            value = result.meals.where((m) => !m.isSkipped).length;
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

  // Helper methods to calculate totals
  double _calculateTotalCalories(DailyRecall recall) {
    double total = 0;
    for (final meal in recall.meals) {
      if (!meal.isSkipped) {
        for (final food in meal.foods) {
          total += food.nutrition.energyKcal;
        }
      }
    }
    return total;
  }

  double _calculateTotalProtein(DailyRecall recall) {
    double total = 0;
    for (final meal in recall.meals) {
      if (!meal.isSkipped) {
        for (final food in meal.foods) {
          total += food.nutrition.protein;
        }
      }
    }
    return total;
  }

  double _calculateTotalCarbs(DailyRecall recall) {
    double total = 0;
    for (final meal in recall.meals) {
      if (!meal.isSkipped) {
        for (final food in meal.foods) {
          total += food.nutrition.carbs;
        }
      }
    }
    return total;
  }

  double _calculateTotalFat(DailyRecall recall) {
    double total = 0;
    for (final meal in recall.meals) {
      if (!meal.isSkipped) {
        for (final food in meal.foods) {
          total += food.nutrition.fat;
        }
      }
    }
    return total;
  }
}

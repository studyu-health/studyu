import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('nutrition totals scale each entry by amount and drive extraction', () {
    final recall = DailyRecall(
      id: 'recall',
      date: DateTime(2026, 9, 22),
      recallMode: RecallMode.realtimeRecord,
      meals: [
        _meal(
          'meal',
          foods: [
            _food('single serving', amount: 1, energy: 10, protein: 1),
            _food('two servings', amount: 2, energy: 20, protein: 2),
            _food(
              'recipe servings',
              amount: 4,
              energy: 30,
              protein: 3,
              entryType: FoodEntryType.recipe,
            ),
          ],
        ),
        _meal(
          'skipped',
          foods: [_food('ignored', amount: 10, energy: 100, protein: 10)],
          isSkipped: true,
        ),
      ],
    );

    final nutrition = DailyRecallNutritionCalculation(recall).totalNutrition;

    expect(nutrition.energyKcal, 170);
    expect(nutrition.protein, 17);
    expect(nutrition.micros['iron'], 17);

    final completedAt = DateTime(2026, 9, 22, 18);
    final progress = SubjectProgress(
      subjectId: 'subject',
      interventionId: 'intervention',
      taskId: 'task',
      resultType: 'DailyRecall',
      result: Result<DailyRecall>.app(
        type: 'DailyRecall',
        periodId: 'period',
        result: recall,
      ),
    )..completedAt = completedAt;

    expect(
      NutritionTask.withId().extractPropertyResults<double>('totalCalories', [
        progress,
      ])[completedAt],
      170,
    );
  });
}

MealLog _meal(
  String id, {
  required List<FoodEntry> foods,
  bool isSkipped = false,
}) {
  return MealLog(
    id: id,
    mealType: MealType.lunch,
    mealContext: MealContext.home,
    timestamp: DateTime(2026, 9, 22, 12),
    timezone: 'UTC',
    isSkipped: isSkipped,
    foods: foods,
  );
}

FoodEntry _food(
  String name, {
  required double amount,
  required double energy,
  required double protein,
  FoodEntryType entryType = FoodEntryType.singleIngredient,
}) {
  return FoodEntry(
    id: name,
    entryType: entryType,
    name: name,
    amount: amount,
    unit: 'serving',
    servingSizeGrams: 100,
    portionEstimationMethod: PortionEstimationMethod.standardUnit,
    portionState: PortionState.asServed,
    nutrition: NutritionProfile(
      energyKcal: energy,
      protein: protein,
      carbs: 0,
      fat: 0,
      sugars: 0,
      fiber: 0,
      saturatedFat: 0,
      transFat: 0,
      cholesterol: 0,
      sodium: 0,
      waterContent: 0,
      micros: {'iron': protein},
    ),
    source: FoodSource.manual,
    confidenceScore: 1,
    createdAt: DateTime(2026, 9, 22),
    originalValues: const {},
  );
}

import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('meal and daily aggregation retain missing contributions', () {
    final known = _food('known zero', amount: 2, energy: 0, protein: 0);
    final missing = _food('unknown', amount: 3, energy: 99, protein: 99)
      ..nutrition.unavailableNutrients = {
        'energyKcal',
        'protein',
        'micros.iron',
      };
    final meal = _meal('mixed', foods: [known, missing]);
    final recall = DailyRecall(
      id: 'recall',
      date: DateTime(2026),
      recallMode: RecallMode.realtimeRecord,
      meals: [
        meal,
        _meal('unknown meal', foods: [missing]),
      ],
    );
    final total = recall.totalNutrition;
    expect(total.energyKcal, 0);
    expect(total.isKnown('energyKcal'), isTrue);
    expect(total.isPartial('energyKcal'), isTrue);
    expect(total.isPartial('micros.iron'), isTrue);
    expect(missing.nutrition.energyKcal, 99);
    expect(missing.nutrition.partialNutrients, isEmpty);
  });

  test('numeric extraction retains only complete values for each nutrient', () {
    final entries = [
      _food('legacy zero', amount: 1, energy: 0, protein: 0),
      _food('known', amount: 2, energy: 10, protein: 3),
      _food('unknown', amount: 1, energy: 99, protein: 4)
        ..nutrition.unavailableNutrients = {'energyKcal'},
      _food('partial', amount: 1, energy: 5, protein: 5)
        ..nutrition.partialNutrients = {'energyKcal'},
    ];
    final progress = [
      for (var i = 0; i < entries.length; i++)
        SubjectProgress(
          subjectId: 'subject',
          interventionId: 'intervention',
          taskId: 'task',
          resultType: 'DailyRecall',
          result: Result<DailyRecall>.app(
            type: 'DailyRecall',
            periodId: 'period',
            result: DailyRecall(
              id: 'recall-$i',
              date: DateTime(2026, 1, i + 1),
              recallMode: RecallMode.realtimeRecord,
              meals: [
                _meal('meal-$i', foods: [entries[i]]),
              ],
              entryCompletedAt: DateTime(2026, 1, i + 1, 18),
            ),
          ),
        )..completedAt = DateTime(2026, 1, i + 1, 18),
    ];
    final task = NutritionTask.withId();
    expect(task.extractPropertyResults<double>('totalCalories', progress), {
      DateTime(2026, 1, 1, 18): 0,
      DateTime(2026, 1, 2, 18): 20,
    });
    expect(
      task.extractPropertyResults<double>('totalProtein', progress).values,
      [0, 6, 4, 5],
    );
    expect(task.extractPropertyResults<int>('mealCount', progress).values, [
      1,
      1,
      1,
      1,
    ]);
    expect(
      task.extractPropertyResults<DateTime>('completionTime', progress).values,
      progress.map((entry) => entry.completedAt),
    );
  });

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
              entryType: FoodEntryType.meal,
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
    foodId: '$name-food',
    foodVersionId: '$name-version',
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

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_history.dart';
import 'package:studyu_core/core.dart' as studyu;

void main() {
  test(
    'builds participant-scoped frequent and non-overlapping recent foods',
    () {
      final apple = food(
        id: 'apple-old',
        name: 'Apple',
        source: studyu.FoodSource.openfoodfacts,
        externalId: '123',
        foodId: 'apple-definition',
      );
      final updatedApple = food(
        id: 'apple-new',
        name: 'Green apple',
        source: studyu.FoodSource.openfoodfacts,
        externalId: '123',
        foodId: 'apple-definition',
      );
      final banana = food(id: 'banana', name: 'Banana');
      final yogurt = food(id: 'yogurt', name: 'Yogurt');

      final history = buildFoodSearchHistory([
        recallProgress('participant', DateTime.utc(2025), [apple]),
        recallProgress('participant', DateTime.utc(2025, 1, 2), [banana]),
        recallProgress('participant', DateTime.utc(2025, 1, 3), [updatedApple]),
        recallProgress('other-participant', DateTime.utc(2025, 1, 4), [
          food(id: 'leak', name: 'Must not appear'),
        ]),
        recallProgress('participant', DateTime.utc(2025, 1, 5), [yogurt]),
      ], subjectId: 'participant');

      expect(history.frequentlyUsed, hasLength(1));
      expect(history.frequentlyUsed.single.food.name, 'Green apple');
      expect(history.frequentlyUsed.single.useCount, 2);
      expect(history.recent.map((item) => item.food.name), [
        'Yogurt',
        'Banana',
      ]);
      expect(
        history.recent.map((item) => item.identity).toSet(),
        isNot(contains(history.frequentlyUsed.single.identity)),
      );
    },
  );

  test('groups only matching stable food identities', () {
    final first = food(
      id: 'first',
      name: ' Greek  Yogurt ',
      brandName: ' Dairy ',
      unit: ' Cup ',
      foodId: 'yogurt-definition',
    );
    final second = food(
      id: 'second',
      name: 'greek yogurt',
      brandName: 'dairy',
      unit: 'cup',
      foodId: 'yogurt-definition',
    );

    final history = buildFoodSearchHistory([
      recallProgress('participant', DateTime.utc(2025), [first]),
      recallProgress('participant', DateTime.utc(2025, 1, 2), [second]),
    ], subjectId: 'participant');

    expect(history.frequentlyUsed, hasLength(1));
    expect(history.frequentlyUsed.single.useCount, 2);
    expect(history.recent, isEmpty);
  });

  test('includes foods from meals with unknown time', () {
    final recentFood = food(id: 'unknown-recent', name: 'Tea');
    final frequentFood = food(id: 'unknown-frequent', name: 'Toast');

    final history = buildFoodSearchHistory([
      recallProgress(
        'participant',
        DateTime.utc(2025, 1, 5),
        [recentFood, frequentFood],
        unknownTime: true,
        occurrenceTimestamp: DateTime.utc(2020),
      ),
      recallProgress('participant', DateTime.utc(2025, 1, 6), [
        frequentFood,
      ], unknownTime: true),
    ], subjectId: 'participant');

    expect(history.recent.single.food.name, 'Tea');
    expect(history.frequentlyUsed.single.food.name, 'Toast');
    expect(history.frequentlyUsed.single.lastUsedAt, DateTime.utc(2025, 1, 6));
  });

  test(
    'creates an independent selection with fresh identity and timestamp',
    () {
      final original = food(id: 'original', name: 'Apple');
      final history = buildFoodSearchHistory([
        recallProgress('participant', DateTime.utc(2025), [original]),
      ], subjectId: 'participant');

      final selected = history.recent.single.createSelection();
      selected.nutrition.energyKcal = 999;

      expect(selected.id, isNot(original.id));
      expect(selected.foodId, original.foodId);
      expect(selected.foodVersionId, original.foodVersionId);
      expect(selected.createdAt, isNot(original.createdAt));
      expect(original.nutrition.energyKcal, 100);
      expect(history.recent.single.food.nutrition.energyKcal, 100);
    },
  );
}

studyu.SubjectProgress recallProgress(
  String subjectId,
  DateTime mealTime,
  List<studyu.FoodEntry> foods, {
  bool unknownTime = false,
  DateTime? occurrenceTimestamp,
}) {
  final recall = studyu.DailyRecall.withId(
    date: mealTime,
    recallMode: studyu.RecallMode.realtimeRecord,
    meals: [
      studyu.MealLog.withId(
        mealType: studyu.MealType.snack,
        mealContext: studyu.MealContext.home,
        timestamp: occurrenceTimestamp ?? (unknownTime ? null : mealTime),
        timePrecision: unknownTime
            ? studyu.MealOccurrenceTimePrecision.unknown
            : studyu.MealOccurrenceTimePrecision.approximate,
        timezone: 'UTC',
        isSkipped: false,
        foods: foods,
      ),
    ],
  );
  return studyu.SubjectProgress(
    subjectId: subjectId,
    interventionId: 'intervention',
    taskId: 'task',
    resultType: 'DailyRecall',
    result: studyu.Result<studyu.DailyRecall>.app(
      type: 'DailyRecall',
      periodId: 'period',
      result: recall,
    ),
  );
}

studyu.FoodEntry food({
  required String id,
  required String name,
  String? brandName,
  String unit = 'serving',
  studyu.FoodSource source = studyu.FoodSource.manual,
  String? externalId,
  String? foodId,
}) => studyu.FoodEntry(
  id: id,
  foodId: foodId ?? '$id-definition',
  foodVersionId: '$id-version',
  entryType: studyu.FoodEntryType.singleIngredient,
  name: name,
  brandName: brandName,
  amount: 1,
  unit: unit,
  servingSizeGrams: 100,
  portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
  portionState: studyu.PortionState.asServed,
  nutrition: studyu.NutritionProfile(
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
  externalId: externalId,
  source: source,
  confidenceScore: 1,
  createdAt: DateTime.utc(2024),
  originalValues: const {},
);

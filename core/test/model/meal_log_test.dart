import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

MealLog consumedMeal({
  MealOccurrenceTimePrecision precision = MealOccurrenceTimePrecision.unknown,
  DateTime? timestamp,
}) => MealLog.withId(
  mealType: MealType.other,
  timePrecision: precision,
  timestamp: timestamp,
  timezone: 'UTC',
  isSkipped: false,
  foods: [
    FoodEntry.withId(
      entryType: FoodEntryType.singleIngredient,
      name: 'Apple',
      amount: 1,
      unit: 'piece',
      servingSizeGrams: 100,
      portionEstimationMethod: PortionEstimationMethod.householdMeasure,
      portionState: PortionState.raw,
      nutrition: NutritionProfile(
        energyKcal: 52,
        protein: 0.3,
        carbs: 14,
        fat: 0.2,
        sugars: 10,
        fiber: 2.4,
        saturatedFat: 0,
        transFat: 0,
        cholesterol: 0,
        sodium: 1,
        waterContent: 86,
        micros: {},
      ),
      source: FoodSource.manual,
      confidenceScore: 1,
      originalValues: {},
    ),
  ],
);

void main() {
  test('untouched context stays absent through repeated JSON copies', () {
    final meal = consumedMeal();
    expect(meal.mealContext, isNull);
    expect(meal.toJson().containsKey('mealContext'), isFalse);
    final restored = MealLog.fromJson(meal.toJson());
    final copied = MealLog.fromJson(restored.toJson());
    expect(copied.mealContext, isNull);
    expect(copied.foods.single.id, meal.foods.single.id);
  });

  test('recall JSON copies preserve absent and supplied contexts', () {
    final meal = consumedMeal();
    final withContext = consumedMeal()..mealContext = MealContext.home;
    final recall = DailyRecall(
      id: 'recall',
      date: DateTime(2026, 7, 15),
      recallMode: RecallMode.realtimeRecord,
      meals: [meal, withContext],
    );
    final restored = DailyRecall.fromJson(recall.toJson());
    expect(restored.meals.first.mealContext, isNull);
    expect(restored.meals.last.mealContext, MealContext.home);
    expect(restored.meals.first.foods.single.id, meal.foods.single.id);
  });

  test('explicit null context loads without a default', () {
    final json = consumedMeal().toJson()..['mealContext'] = null;
    expect(MealLog.fromJson(json).mealContext, isNull);
  });

  test('home context round-trips', () {
    final json = consumedMeal().toJson()..['mealContext'] = 'home';
    final restored = MealLog.fromJson(json);
    expect(restored.mealContext, MealContext.home);
    expect(restored.toJson()['mealContext'], 'home');
  });

  for (final precision in MealOccurrenceTimePrecision.values) {
    for (final hasSelectedTime in [false, true]) {
      for (final timestamp in [null, DateTime(2026, 7, 15, 8)]) {
        test(
          'save validation: $precision, answered=$hasSelectedTime, time=$timestamp',
          () {
            final meal = consumedMeal(
              precision: precision,
              timestamp: timestamp,
            );
            final expected =
                hasSelectedTime &&
                (precision == MealOccurrenceTimePrecision.unknown
                    ? timestamp == null
                    : timestamp != null);
            expect(
              meal.hasValidTimeAnswer(hasSelectedTime: hasSelectedTime),
              expected,
            );
            expect(
              meal.isValidForSave(hasSelectedTime: hasSelectedTime),
              expected,
            );
          },
        );
      }
    }
  }

  test('valid explicit time does not replace the food requirement', () {
    final meal = consumedMeal()..foods.clear();
    expect(meal.hasValidTimeAnswer(hasSelectedTime: true), isTrue);
    expect(meal.isValidForSave(hasSelectedTime: true), isFalse);
  });

  test('labels and context remain optional for a consumed occasion', () {
    final meal = consumedMeal();
    expect(meal.customMealLabel, isNull);
    expect(meal.mealContext, isNull);
    expect(meal.isValidForSave(hasSelectedTime: true), isTrue);
  });

  test('skipped meals require a nonblank reason', () {
    final meal = consumedMeal()
      ..isSkipped = true
      ..foods.clear();
    expect(meal.isValidForSave(hasSelectedTime: false), isFalse);
    meal.skipReason = '  ';
    expect(meal.isValidForSave(hasSelectedTime: false), isFalse);
    meal.skipReason = 'Not hungry';
    expect(meal.isValidForSave(hasSelectedTime: false), isTrue);
  });

  test('a serialized meal must include time precision', () {
    final json = consumedMeal().toJson()..remove('timePrecision');

    expect(
      () => MealLog.fromJson(json),
      throwsA(isA<MissingRequiredKeysException>()),
    );
  });

  test('an unlabeled meal round-trips without a custom label', () {
    final restored = MealLog.fromJson(consumedMeal().toJson());
    expect(restored.mealType, MealType.other);
    expect(restored.customMealLabel, isNull);
  });

  test('unknown time serializes without a fabricated timestamp', () {
    final meal = MealLog.withId(
      mealType: MealType.other,
      mealContext: MealContext.home,
      timePrecision: MealOccurrenceTimePrecision.unknown,
      timezone: 'UTC',
      isSkipped: false,
      foods: [],
    );

    final restored = MealLog.fromJson(meal.toJson());

    expect(restored.timestamp, isNull);
    expect(restored.timePrecision, MealOccurrenceTimePrecision.unknown);
  });
}

import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('legacy timestamp without precision loads as approximate', () {
    final meal = MealLog.withId(
      mealType: MealType.breakfast,
      mealContext: MealContext.home,
      timestamp: DateTime(2026, 7, 15, 8),
      timezone: 'UTC',
      isSkipped: false,
      foods: [],
    );
    final json = meal.toJson()..remove('timePrecision');

    final restored = MealLog.fromJson(json);

    expect(restored.timestamp, meal.timestamp);
    expect(restored.timePrecision, MealOccurrenceTimePrecision.approximate);
  });

  test('missing label provenance preserves legacy Other', () {
    final meal = MealLog.withId(
      mealType: MealType.other,
      mealContext: MealContext.home,
      timezone: 'UTC',
      isSkipped: false,
      foods: [],
    );

    final json = meal.toJson()..remove('isLabelExplicitlyUnset');

    expect(MealLog.fromJson(json).isLabelExplicitlyUnset, isFalse);
  });

  test(
    'explicitly unlabeled meals round-trip separately from legacy Other',
    () {
      final meal = MealLog.withId(
        mealType: MealType.other,
        isLabelExplicitlyUnset: true,
        mealContext: MealContext.home,
        timezone: 'UTC',
        isSkipped: false,
        foods: [],
      );

      expect(MealLog.fromJson(meal.toJson()).isLabelExplicitlyUnset, isTrue);
    },
  );

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

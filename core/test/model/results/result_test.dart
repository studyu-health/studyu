import 'dart:convert';

import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('nested availability round-trips in the normal result JSON', () {
    final child = _food()
      ..nutrition.unavailableNutrients = {'protein'}
      ..nutrition.partialNutrients = {'energyKcal'};
    final parent = _food()..componentSnapshots = [child];
    final result = _result(parent);
    final json =
        jsonDecode(jsonEncode(result.toJson())) as Map<String, dynamic>;

    final restored = Result<DailyRecall>.fromJson(json);
    final nested =
        restored.result.meals.single.foods.single.componentSnapshots!.single;
    expect(nested.nutrition.isKnown('protein'), isFalse);
    expect(nested.nutrition.isPartial('energyKcal'), isTrue);
    expect(restored.toJson(), json);

    nested.nutrition.unavailableNutrients.clear();
    nested.nutrition.partialNutrients.clear();
    final copy = Result<DailyRecall>.fromJson(restored.toJson());
    final cleared =
        copy.result.meals.single.foods.single.componentSnapshots!.single;
    expect(cleared.nutrition.isKnown('protein'), isTrue);
    expect(cleared.nutrition.protein, 0);
    expect(cleared.nutrition.isPartial('energyKcal'), isFalse);
  });

  test('a boolean result retains its existing JSON format', () {
    final result = Result<bool>.app(
      type: 'bool',
      periodId: 'period',
      result: true,
    );
    expect(result.toJson(), {
      'type': 'bool',
      'periodId': 'period',
      'result': true,
    });
  });
}

Result<DailyRecall> _result(FoodEntry food) => Result<DailyRecall>.app(
  type: 'DailyRecall',
  periodId: 'period',
  result: DailyRecall(
    id: 'recall',
    date: DateTime.utc(2026, 10, 4),
    recallMode: RecallMode.realtimeRecord,
    meals: [
      MealLog.withId(
        mealType: MealType.breakfast,
        timezone: 'UTC',
        isSkipped: false,
        foods: [food],
      ),
    ],
  ),
);

FoodEntry _food() => FoodEntry.withId(
  entryType: FoodEntryType.singleIngredient,
  name: 'Food',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
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
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  originalValues: {},
);

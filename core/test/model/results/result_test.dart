import 'dart:convert';

import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test(
    'verified local copies preserve intent and storage omits provenance',
    () {
      final food = _food()
        ..nutrition.unavailableNutrients = {'protein'}
        ..nutrition.partialNutrients = {'energyKcal'};
      final result = _result(food);
      final copied = Result<DailyRecall>.fromJson(
        jsonDecode(jsonEncode(result.toJson())) as Map<String, dynamic>,
      );
      expect(copied.result.canWriteAvailability, isTrue);
      final storage = copied.toJsonForStorage();
      expect(
        storage[NutritionProfile.availabilityWriteIntentKey],
        NutritionProfile.availabilityWriteIntent,
      );
      expect(jsonEncode(storage), isNot(contains('availabilityVerified')));
      final restored = copied.result.meals.single.foods.single;
      expect(restored.nutrition.unavailableNutrients, {'protein'});
      expect(restored.nutrition.partialNutrients, {'energyKcal'});
      restored.nutrition.unavailableNutrients.clear();
      restored.nutrition.partialNutrients.clear();
      final cleared = copied.toJsonForStorage();
      expect(
        cleared[NutritionProfile.availabilityWriteIntentKey],
        NutritionProfile.availabilityWriteIntent,
      );
      expect(restored.nutrition.protein, 0);
      expect(restored.nutrition.isKnown('protein'), isTrue);
      expect(jsonEncode(cleared), isNot(contains('unavailableNutrients')));
      expect(jsonEncode(cleared), isNot(contains('partialNutrients')));
    },
  );

  test(
    'generic JSON cannot verify legacy drafts or trust an intent marker',
    () {
      final storage = _result(_food()).toJsonForStorage();
      final hydrated = Result<DailyRecall>.fromJson(storage);
      expect(hydrated.result.canWriteAvailability, isFalse);
      expect(
        hydrated.toJsonForStorage(),
        isNot(contains(NutritionProfile.availabilityWriteIntentKey)),
      );
      final restored = hydrated.result.meals.single.foods.single;
      expect(restored.availabilityVerified, isFalse);
      expect(restored.nutrition.isKnown('protein'), isTrue);
      expect(restored.nutrition.protein, 0);
      expect(restored.toJson(), _foodWithIdentity(restored).toJsonForStorage());
      final copied = Result<DailyRecall>.fromJson(hydrated.toJson());
      expect(copied.result.canWriteAvailability, isFalse);
      final boolean = Result<bool>.app(
        type: 'bool',
        periodId: 'period',
        result: true,
      );
      expect(boolean.toJsonForStorage(), {
        'type': 'bool',
        'periodId': 'period',
        'result': true,
      });
    },
  );

  test('canonical server extraction verifies nested state, generic decoding does not', () {
    final child = _food()
      ..nutrition.unavailableNutrients = {'protein'}
      ..nutrition.partialNutrients = {'energyKcal'};
    final parent = _food()..componentSnapshots = [child];
    final progress = SubjectProgress(
      subjectId: 'subject',
      interventionId: 'intervention',
      taskId: 'task',
      resultType: 'DailyRecall',
      result: _result(parent),
    );
    final row = progress.toJson()
      ..['result'] = _result(parent).toJsonForStorage();
    expect(
      (SubjectProgress.fromJson(row).result.result as DailyRecall)
          .canWriteAvailability,
      isFalse,
    );
    final canonical = SupabaseQuery.extractSupabaseSingleRow<SubjectProgress>(
      row,
    );
    final recall = canonical.result.result as DailyRecall;
    expect(recall.canWriteAvailability, isTrue);
    final nested = recall.meals.single.foods.single.componentSnapshots!.single;
    expect(nested.availabilityVerified, isTrue);
    expect(nested.nutrition.unavailableNutrients, {'protein'});
    expect(nested.nutrition.partialNutrients, {'energyKcal'});
    expect(
      SupabaseQuery.extractSupabaseList<SubjectProgress>([row]).single.result
          .toJsonForStorage(),
      contains(NutritionProfile.availabilityWriteIntentKey),
    );
  });

  test('unverified ancestors and components cannot be promoted by copies', () {
    final child = _food()..availabilityVerified = false;
    final parent = _food()..componentSnapshots = [child];
    final result = _result(parent);
    expect(result.result.availabilityVerified, isTrue);
    expect(
      result.toJson(),
      isNot(contains(NutritionProfile.availabilityWriteIntentKey)),
    );
    final unverified = _result(_food()).result..availabilityVerified = false;
    final decoded = DailyRecall.fromJson(unverified.toJson());
    expect(decoded.meals.single.foods.single.availabilityVerified, isFalse);
    decoded.meals.add(
      MealLog.withId(
        mealType: MealType.lunch,
        timezone: 'UTC',
        isSkipped: false,
        foods: [_food()],
      ),
    );
    expect(
      DailyRecall.fromJson(decoded.toJson()).canWriteAvailability,
      isFalse,
    );
    final nested = _food()
      ..componentSnapshots = [_food()]
      ..availabilityVerified = false;
    expect(
      FoodEntry.fromJson(nested.toJson())
          .componentSnapshots!
          .single
          .availabilityVerified,
      isFalse,
    );
    expect(
      jsonEncode(nested.toJsonForStorage()),
      isNot(contains('availabilityVerified')),
    );
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

FoodEntry _foodWithIdentity(FoodEntry original) =>
    FoodEntry.fromJson(original.toJsonForStorage());

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

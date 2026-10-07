import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('mutation result round-trips and requires explicit update counts', () {
    final result = NutritionFoodMutationResult(
      definition: NutritionFoodDefinition(
        id: 'food-definition',
        subjectId: 'subject',
        kind: 'food',
        currentVersionId: 'version-2',
        deletedAt: null,
        snapshot: _food(),
        createdAt: DateTime.utc(2026, 7, 15, 8),
        updatedAt: DateTime.utc(2026, 7, 15, 9),
      ),
      progress: const [
        {'task_id': 'historical-task'},
        {'task_id': 'today-task-a'},
        {'task_id': 'today-task-b'},
      ],
      selectedHistoricalUpdateCount: 1,
      todayUpdateCount: 3,
    );

    final restored = NutritionFoodMutationResult.fromJson(result.toJson());

    expect(restored.selectedHistoricalUpdateCount, 1);
    expect(restored.todayUpdateCount, 3);
    expect(restored.progress, hasLength(3));

    final missingCount = result.toJson()..remove('todayUpdateCount');
    expect(
      () => NutritionFoodMutationResult.fromJson(missingCount),
      throwsA(isA<TypeError>()),
    );
  });
}

FoodEntry _food() => FoodEntry(
  id: 'snapshot',
  foodId: 'food-definition',
  foodVersionId: 'version-2',
  entryType: FoodEntryType.singleIngredient,
  name: 'Apple',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
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
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.utc(2026, 7, 15, 8),
  originalValues: const {},
);

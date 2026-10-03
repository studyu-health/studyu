import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_core/core.dart';

void main() {
  test(
    'definition normalization converts occurrence nutrition to one serving',
    () {
      final occurrence = _food(
        id: 'entry',
        foodId: 'food',
        versionId: 'version',
        name: 'Apple',
        amount: 2,
        energy: 200,
      )..nutrition.micros = {'iron': 4};

      final definition = normalizeNutritionFoodDefinition(occurrence);

      expect(definition.amount, 1);
      expect(definition.nutrition.energyKcal, 100);
      expect(definition.nutrition.protein, 0.5);
      expect(definition.nutrition.micros, {'iron': 2});
      expect(occurrence.amount, 2);
      expect(occurrence.nutrition.energyKcal, 200);
      expect(
        () => normalizeNutritionFoodDefinition(
          _food(
            id: 'invalid',
            foodId: 'food',
            versionId: 'version',
            name: 'Invalid',
            amount: 0,
            energy: 0,
          ),
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'definition replacement preserves logged identity and serving state',
    () {
      final logged =
          _food(
              id: 'entry',
              foodId: 'food',
              versionId: 'old-version',
              name: 'Old',
              amount: 2,
              energy: 200,
            )
            ..unit = 'logged servings'
            ..servingSizeGrams = 80
            ..portionReference = 'logged reference'
            ..templateId = 'template'
            ..modifiedAt = DateTime.utc(2026, 7, 15, 9)
            ..parentEntryId = 'meal';
      final definition =
          _food(
              id: 'definition-snapshot',
              foodId: 'food',
              versionId: 'new-version',
              name: 'New',
              amount: 1,
              energy: 150,
            )
            ..unit = 'new serving'
            ..servingSizeGrams = 120
            ..portionReference = 'new reference'
            ..originalValues = const {'reusable': true};

      final updated = applyNutritionFoodSnapshot(logged, definition);

      expect(updated.id, 'entry');
      expect(updated.foodId, 'food');
      expect(updated.foodVersionId, 'new-version');
      expect(updated.name, 'New');
      expect(updated.amount, 2);
      expect(updated.unit, 'new serving');
      expect(updated.servingSizeGrams, 120);
      expect(updated.portionReference, 'new reference');
      expect(updated.originalValues, {'reusable': true});
      expect(updated.templateId, 'template');
      expect(updated.createdAt, logged.createdAt);
      expect(updated.modifiedAt, logged.modifiedAt);
      expect(updated.parentEntryId, 'meal');
      expect(updated.nutrition.energyKcal, 300);
    },
  );

  test('entry-specific replacement leaves same-food siblings unchanged', () {
    final selected = _food(
      id: 'selected-entry',
      foodId: 'food',
      versionId: 'old-version',
      name: 'Selected old',
      amount: 2,
      energy: 200,
    );
    final sibling = _food(
      id: 'sibling-entry',
      foodId: 'food',
      versionId: 'old-version',
      name: 'Sibling old',
      amount: 3,
      energy: 300,
    );
    final recall = DailyRecall(
      id: 'recall',
      date: DateTime.utc(2026, 7, 15),
      recallMode: RecallMode.realtimeRecord,
      entryStartedAt: DateTime.utc(2026, 7, 15, 8),
      meals: [
        MealLog(
          id: 'meal',
          mealType: MealType.breakfast,
          mealContext: MealContext.home,
          timezone: 'UTC',
          isSkipped: false,
          foods: [selected, sibling],
        ),
      ],
    );
    final definition = _food(
      id: 'definition-snapshot',
      foodId: 'food',
      versionId: 'new-version',
      name: 'New',
      amount: 1,
      energy: 150,
    );

    final updated = replaceNutritionFoodSnapshots(
      recall,
      definition,
      entryId: selected.id,
    );

    expect(updated.meals.single.foods.first.name, 'New');
    expect(updated.meals.single.foods.last.name, 'Sibling old');
    expect(updated.meals.single.foods.last.foodVersionId, 'old-version');
  });

  test(
    'composite normalization keeps ordered components on a one-serving basis',
    () {
      final first = _food(
        id: 'first-entry',
        foodId: 'first',
        versionId: 'first-v1',
        name: 'First',
        amount: 2,
        energy: 100,
      );
      final second = _food(
        id: 'second-entry',
        foodId: 'second',
        versionId: 'second-v1',
        name: 'Second',
        amount: 4,
        energy: 200,
      );
      final creatorResult =
          _food(
              id: 'meal-snapshot',
              foodId: 'meal-definition',
              versionId: 'meal-v1',
              name: 'Meal',
              amount: 2,
              energy: 150,
            )
            ..entryType = FoodEntryType.meal
            ..componentFoods = [
              _composition('first-composition', 'meal-snapshot', first, 0),
              _composition('second-composition', 'meal-snapshot', second, 1),
            ]
            ..componentSnapshots = [first, second];

      final definition = normalizeCompositeNutritionFoodDefinition(
        creatorResult,
      );
      final selected = applyNutritionFoodSnapshot(
        _food(
          id: 'selected-meal',
          foodId: 'meal-definition',
          versionId: 'meal-v1',
          name: 'Old',
          amount: 2,
          energy: 0,
        )..entryType = FoodEntryType.meal,
        definition,
      );
      final current = applyNutritionFoodSnapshot(
        _food(
          id: 'current-meal',
          foodId: 'meal-definition',
          versionId: 'meal-v1',
          name: 'Old',
          amount: 3,
          energy: 0,
        )..entryType = FoodEntryType.meal,
        definition,
      );

      expect(definition.amount, 1);
      expect(definition.nutrition.energyKcal, 150);
      expect(definition.componentFoods!.map((component) => component.foodId), [
        'first',
        'second',
      ]);
      expect(definition.componentFoods!.map((component) => component.amount), [
        1,
        2,
      ]);
      expect(
        definition.componentSnapshots!.map((component) => component.amount),
        [1, 2],
      );
      expect(
        definition.componentSnapshots!.map(
          (component) => component.nutrition.energyKcal,
        ),
        [50, 100],
      );
      expect(selected.amount, 2);
      expect(selected.nutrition.energyKcal, 300);
      expect(current.amount, 3);
      expect(current.nutrition.energyKcal, 450);
      expect(creatorResult.amount, 2);
      expect(creatorResult.componentFoods!.first.amount, 2);
    },
  );

  test('flattening recursively expands saved meals with serving scaling', () {
    final leaf = _food(
      id: 'leaf-entry',
      foodId: 'leaf',
      versionId: 'leaf-v1',
      name: 'Leaf',
      amount: 1,
      energy: 50,
    );
    final nested =
        _food(
            id: 'nested-entry',
            foodId: 'nested',
            versionId: 'nested-v1',
            name: 'Nested',
            amount: 1,
            energy: 50,
          )
          ..entryType = FoodEntryType.meal
          ..componentFoods = [
            _composition('nested-component', 'nested-entry', leaf, 0),
          ]
          ..componentSnapshots = [leaf];
    final meal =
        _food(
            id: 'meal-entry',
            foodId: 'meal',
            versionId: 'meal-v1',
            name: 'Meal',
            amount: 2,
            energy: 100,
          )
          ..entryType = FoodEntryType.meal
          ..componentFoods = [
            _composition('meal-component', 'meal-entry', nested, 0),
          ]
          ..componentSnapshots = [nested];

    final flattened = flattenNutritionFoodEntries([meal]);

    expect(flattened, hasLength(1));
    expect(flattened.single.foodId, 'leaf');
    expect(flattened.single.amount, 2);
    expect(flattened.single.nutrition.energyKcal, 100);

    final definition = normalizeCompositeNutritionFoodDefinition(meal);
    expect(definition.componentSnapshots, hasLength(1));
    expect(
      definition.componentSnapshots!.every(
        (food) => food.entryType != FoodEntryType.meal,
      ),
      isTrue,
    );
  });

  test('reusable occurrence normalization keeps scaled ingredient amounts', () {
    final food = _food(
      id: 'food-entry',
      foodId: 'food',
      versionId: 'food-v1',
      name: 'Food',
      amount: 1,
      energy: 50,
    );
    final occurrence =
        _food(
            id: 'meal-entry',
            foodId: 'meal',
            versionId: 'meal-v1',
            name: 'Meal',
            amount: 2,
            energy: 100,
          )
          ..entryType = FoodEntryType.meal
          ..templateId = 'template'
          ..componentFoods = [_composition('component', 'meal-entry', food, 0)]
          ..componentSnapshots = [food];

    final definition = normalizeCompositeNutritionFoodDefinition(occurrence);

    expect(definition.amount, 1);
    expect(definition.componentFoods!.single.amount, 1);
    expect(definition.componentSnapshots!.single.amount, 1);
    expect(definition.componentSnapshots!.single.nutrition.energyKcal, 50);
  });

  test('flattening rejects incomplete nested snapshots', () {
    final meal =
        _food(
            id: 'meal-entry',
            foodId: 'meal',
            versionId: 'meal-v1',
            name: 'Meal',
            amount: 1,
            energy: 0,
          )
          ..entryType = FoodEntryType.meal
          ..componentFoods = [
            FoodComposition.withId(
              parentEntryId: 'meal-entry',
              foodId: 'missing',
              amount: 1,
              unit: 'serving',
            ),
          ]
          ..componentSnapshots = [];

    expect(
      () => flattenNutritionFoodEntries([meal]),
      throwsA(isA<StateError>()),
    );
  });

  test('saved meal component snapshots are replaced but not cascaded', () {
    final oldComponent = _food(
      id: 'component-entry',
      foodId: 'component',
      versionId: 'component-v1',
      name: 'Component old',
      amount: 1,
      energy: 50,
    );
    final loggedMeal = _food(
      id: 'meal-entry',
      foodId: 'meal-definition',
      versionId: 'meal-v1',
      name: 'Meal old',
      amount: 1,
      energy: 50,
    )..componentSnapshots = [oldComponent];
    final newComponent = FoodEntry.fromJson(oldComponent.toJson())
      ..name = 'Component embedded in meal v2';
    final mealDefinition = FoodEntry.fromJson(loggedMeal.toJson())
      ..id = 'meal-snapshot'
      ..foodVersionId = 'meal-v2'
      ..name = 'Meal new'
      ..componentSnapshots = [newComponent];

    final updated = applyNutritionFoodSnapshot(loggedMeal, mealDefinition);

    expect(updated.foodVersionId, 'meal-v2');
    expect(
      updated.componentSnapshots!.single.name,
      'Component embedded in meal v2',
    );
    expect(oldComponent.name, 'Component old');
  });
}

FoodComposition _composition(
  String id,
  String parentEntryId,
  FoodEntry food,
  int sortOrder,
) => FoodComposition(
  id: id,
  parentEntryId: parentEntryId,
  foodId: food.foodId,
  amount: food.amount,
  unit: food.unit,
  sortOrder: sortOrder,
);

FoodEntry _food({
  required String id,
  required String foodId,
  required String versionId,
  required String name,
  required double amount,
  required double energy,
}) => FoodEntry(
  id: id,
  foodId: foodId,
  foodVersionId: versionId,
  entryType: FoodEntryType.singleIngredient,
  name: name,
  amount: amount,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: energy,
    protein: 1,
    carbs: 2,
    fat: 3,
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
  createdAt: DateTime.utc(2026, 7, 15),
  originalValues: const {},
);

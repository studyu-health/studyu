import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_core/core.dart';

import 'fake_nutrition_food_repository.dart';

void main() {
  test(
    'checks restored draft foods for deletion before showing them',
    () async {
      final deleted = _foodEntry(id: 'deleted-food', originalValues: {});
      final draft = DailyRecall.withId(
        date: DateTime(2026),
        recallMode: RecallMode.realtimeRecord,
        meals: [
          MealLog.withId(
            mealType: MealType.lunch,
            timestamp: DateTime(2026),
            timezone: 'UTC',
            isSkipped: false,
            foods: [deleted],
          ),
        ],
      );
      final repository = _PendingDeletionCheckRepository();
      final model = TemplateViewModel(
        userId: 'test-user',
        repository: repository,
        loadDraftRecalls: () async => [
          (recall: draft, taskId: 'task', periodId: 'period'),
        ],
      );
      addTearDown(model.dispose);
      await repository.request.future;
      expect(model.foodTemplates, isEmpty);

      repository.response.complete({deleted.foodId});
      await model.loadAllTemplates();
      expect(model.foodTemplates, isEmpty);
    },
  );

  test(
    'template storage, application and duplication preserve availability',
    () async {
      final food = _foodEntry(id: 'unknown-food', originalValues: {})
        ..nutrition.unavailableNutrients = {'protein', 'micros.iron'}
        ..nutrition.partialNutrients = {'energyKcal'};
      final repository = PreviewNutritionFoodRepository();
      final viewModel = TemplateViewModel(
        userId: 'test-user',
        repository: repository,
      );
      addTearDown(viewModel.dispose);
      await viewModel.saveFoodAsTemplate(name: 'Food', food: food);
      final stored = viewModel.foodTemplates.single;
      expect(stored.prototype.nutrition.unavailableNutrients, {
        'protein',
        'micros.iron',
      });
      final applied = viewModel.applyFoodTemplate(stored);
      expect(applied.nutrition.partialNutrients, {'energyKcal'});
      expect(applied.nutrition.unavailableNutrients, {
        'protein',
        'micros.iron',
      });
      await viewModel.duplicateFoodTemplate(stored.id);
      final duplicates = await repository.loadTemplates('test-user');
      expect(duplicates, hasLength(2));
      expect(duplicates.last.prototype.nutrition.unavailableNutrients, {
        'protein',
        'micros.iron',
      });
    },
  );

  test('meal template sums known subtotals and retains partial zero', () async {
    final known = _foodEntry(id: 'known', originalValues: {})
      ..nutrition.energyKcal = 0;
    final missing = _foodEntry(id: 'missing', originalValues: {})
      ..nutrition.energyKcal = 999
      ..nutrition.unavailableNutrients = {'energyKcal'};
    final repository = FakeNutritionFoodRepository();
    final viewModel = TemplateViewModel(
      userId: 'test-user',
      repository: repository,
    );
    addTearDown(viewModel.dispose);
    await viewModel.saveMealAsTemplate(
      name: 'Meal',
      meal: MealLog(
        id: 'meal',
        mealType: MealType.lunch,
        mealContext: MealContext.home,
        timestamp: DateTime(2026),
        timePrecision: MealOccurrenceTimePrecision.exact,
        timezone: 'UTC',
        isSkipped: false,
        foods: [known, missing],
      ),
    );
    final template = (await repository.loadTemplates('test-user')).single;
    expect(template.prototype.nutrition.energyKcal, 0);
    expect(template.prototype.nutrition.isKnown('energyKcal'), isTrue);
    expect(template.prototype.nutrition.isPartial('energyKcal'), isTrue);
    expect(
      template.prototype.componentSnapshots!.last.nutrition.isKnown(
        'energyKcal',
      ),
      isFalse,
    );
    expect(missing.nutrition.energyKcal, 999);
  });

  test(
    'creating a template expands saved meals into leaf ingredients',
    () async {
      final ingredient = _foodEntry(id: 'ingredient', originalValues: {});
      final recipe =
          _foodEntry(
              id: 'recipe',
              entryType: FoodEntryType.meal,
              originalValues: {},
            )
            ..amount = 2
            ..nutrition.energyKcal = 200
            ..componentFoods = [
              FoodComposition.withId(
                parentEntryId: 'recipe',
                foodId: ingredient.foodId,
                amount: 1,
                unit: ingredient.unit,
              ),
            ]
            ..componentSnapshots = [ingredient];
      final viewModel = await _viewModel();
      addTearDown(viewModel.dispose);

      await viewModel.saveMealAsTemplate(
        name: 'Meal',
        meal: MealLog.withId(
          mealType: MealType.lunch,
          timestamp: DateTime(2026),
          timezone: 'UTC',
          isSkipped: false,
          foods: [recipe],
        ),
      );

      final prototype = viewModel.foodTemplates.single.prototype;
      expect(
        prototype.componentSnapshots!.single.entryType,
        FoodEntryType.singleIngredient,
      );
      expect(prototype.componentSnapshots!.single.amount, 2);
      expect(prototype.componentFoods!.single.foodId, ingredient.foodId);
      expect(prototype.nutrition.energyKcal, 200);
    },
  );

  test(
    'preview library retains changes across view models for its subject',
    () async {
      final repository = PreviewNutritionFoodRepository();
      final first = TemplateViewModel(
        userId: 'test-user',
        repository: repository,
      );
      addTearDown(first.dispose);
      final foodId = await first.saveFoodAsTemplate(
        name: 'Custom food',
        food: _foodEntry(id: 'food', originalValues: {}),
      );
      await first.saveMealAsTemplate(
        name: 'Saved meal',
        meal: MealLog.withId(
          mealType: MealType.lunch,
          timezone: 'UTC',
          isSkipped: false,
          foods: [_foodEntry(id: 'ingredient', originalValues: {})],
        ),
      );

      final reopened = TemplateViewModel(
        userId: 'test-user',
        repository: repository,
      );
      addTearDown(reopened.dispose);
      await reopened.loadAllTemplates();
      expect(reopened.foodOnlyTemplates.single.id, foodId);
      final mealId = reopened.mealTemplates.single.id;
      final renamed = first.foodOnlyTemplates.single.prototype
        ..name = 'Renamed';
      await reopened.updateFoodTemplatePrototype(foodId, renamed);
      await reopened.deleteFoodTemplate(mealId);

      await first.loadAllTemplates();
      expect(first.foodTemplates.single.name, 'Renamed');
      expect(await repository.loadTemplates('other-user'), isEmpty);
    },
  );

  test('saving a template refreshes My library immediately', () async {
    final viewModel = await _viewModel();

    await viewModel.saveFoodAsTemplate(
      name: 'New food',
      food: _foodEntry(id: 'new-food', originalValues: {}),
    );

    expect(viewModel.foodTemplates, hasLength(1));
    expect(viewModel.foodTemplates.single.name, 'New food');
  });

  test(
    'saving returns the committed template when the list refresh fails',
    () async {
      final repository = _RefreshFailureRepository();
      final viewModel = TemplateViewModel(
        userId: 'test-user',
        repository: repository,
      );
      while (viewModel.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }
      repository.failLoads = true;

      final id = await viewModel.saveFoodAsTemplate(
        name: 'New food',
        food: _foodEntry(id: 'new-food', originalValues: {}),
      );

      expect(viewModel.foodTemplates.single.id, id);
      expect(viewModel.foodTemplates.single.name, 'New food');
      expect(viewModel.error, contains('refresh failed'));
    },
  );

  test('applying a template starts at one serving and isolates data', () async {
    final prototype =
        _foodEntry(
            id: 'food-prototype',
            originalValues: {
              'source': 'saved',
              'details': {'verified': true, 'note': null},
              'tags': ['fresh', null],
            },
          )
          ..amount = 1.8
          ..nutrition.energyKcal = 180;
    final viewModel = await _viewModel();

    final applied = viewModel.applyFoodTemplate(
      _template(id: 'food-template', prototype: prototype),
    );

    expect(applied.id, isNot(prototype.id));
    expect(applied.templateId, 'food-template');
    expect(applied.amount, 1);
    expect(applied.nutrition.energyKcal, 100);
    expect(prototype.amount, 1.8);
    expect(applied.nutrition, isNot(same(prototype.nutrition)));
    expect(applied.nutrition.micros, isNot(same(prototype.nutrition.micros)));
    expect(applied.originalValues, isNot(same(prototype.originalValues)));
    final appliedDetails =
        applied.originalValues['details'] as Map<String, dynamic>;
    final prototypeDetails =
        prototype.originalValues['details'] as Map<String, dynamic>;
    final appliedTags = applied.originalValues['tags'] as List<dynamic>;
    final prototypeTags = prototype.originalValues['tags'] as List<dynamic>;
    expect(appliedDetails, isNot(same(prototypeDetails)));
    expect(appliedTags, isNot(same(prototypeTags)));
    expect(appliedDetails['note'], isNull);
    expect(appliedTags[1], isNull);

    applied.nutrition.energyKcal = 999;
    applied.nutrition.micros['iron'] = 999;
    applied.originalValues['source'] = 'applied';
    appliedDetails['verified'] = false;
    appliedTags.add('applied');

    expect(prototype.id, 'food-prototype');
    expect(prototype.templateId, isNull);
    expect(prototype.nutrition.energyKcal, 180);
    expect(prototype.nutrition.micros['iron'], 2);
    expect(prototype.originalValues['source'], 'saved');
    expect(prototypeDetails, {'verified': true, 'note': null});
    expect(prototypeTags, ['fresh', null]);
  });

  test('applyFoodTemplate reparents independent recipe compositions', () async {
    final prototype = _foodEntry(
      id: 'recipe-prototype',
      entryType: FoodEntryType.meal,
      originalValues: {'source': 'recipe-template'},
      preparationDetails: PreparationDetails(
        rawWeight: 500,
        cookedWeight: 400,
        yieldFactor: 0.8,
        preparationMethod: 'baked',
        retentionFactors: {'vitaminC': 0.7},
      ),
      componentFoods: [
        FoodComposition(
          id: 'prototype-composition',
          parentEntryId: 'recipe-prototype',
          foodId: 'ingredient-1',
          amount: 2,
          unit: 'cup',
          sortOrder: 3,
        ),
      ],
    );
    final viewModel = await _viewModel();

    final applied = viewModel.applyFoodTemplate(
      _template(id: 'recipe-template', prototype: prototype),
    );
    final appliedComposition = applied.componentFoods!.single;
    final prototypeComposition = prototype.componentFoods!.single;

    expect(applied.id, isNot(prototype.id));
    expect(applied.templateId, 'recipe-template');
    expect(
      applied.preparationDetails,
      isNot(same(prototype.preparationDetails)),
    );
    expect(
      applied.preparationDetails!.retentionFactors,
      isNot(same(prototype.preparationDetails!.retentionFactors)),
    );
    expect(applied.componentFoods, isNot(same(prototype.componentFoods)));
    expect(appliedComposition, isNot(same(prototypeComposition)));
    expect(appliedComposition.id, isNot(prototypeComposition.id));
    expect(appliedComposition.parentEntryId, applied.id);
    expect(appliedComposition.foodId, prototypeComposition.foodId);
    expect(appliedComposition.amount, prototypeComposition.amount);
    expect(appliedComposition.unit, prototypeComposition.unit);
    expect(appliedComposition.sortOrder, prototypeComposition.sortOrder);

    applied.preparationDetails!.retentionFactors['vitaminC'] = 0.1;
    appliedComposition.amount = 99;
    applied.componentFoods!.add(
      FoodComposition.withId(
        parentEntryId: applied.id,
        foodId: 'ingredient-2',
        amount: 1,
        unit: 'g',
      ),
    );

    expect(prototype.id, 'recipe-prototype');
    expect(prototype.templateId, isNull);
    expect(prototype.preparationDetails!.retentionFactors['vitaminC'], 0.7);
    expect(prototype.componentFoods, hasLength(1));
    expect(prototypeComposition.id, 'prototype-composition');
    expect(prototypeComposition.parentEntryId, 'recipe-prototype');
    expect(prototypeComposition.amount, 2);
  });
}

final class _PendingDeletionCheckRepository()
    extends FakeNutritionFoodRepository {
  final request = Completer<void>();
  final response = Completer<Set<String>>();

  @override
  Future<Set<String>> loadDeletedFoodIds(
    String subjectId,
    Set<String> foodIds,
  ) {
    if (!request.isCompleted) request.complete();
    return response.future;
  }
}

Future<TemplateViewModel> _viewModel() async {
  final viewModel = TemplateViewModel(
    userId: 'test-user',
    repository: FakeNutritionFoodRepository(),
  );
  while (viewModel.isLoading) {
    await Future<void>.delayed(Duration.zero);
  }
  return viewModel;
}

SavedFoodTemplate _template({
  required String id,
  required FoodEntry prototype,
}) => SavedFoodTemplate(
  id: id,
  userId: 'test-user',
  name: prototype.name,
  isPublic: false,
  createdAt: DateTime.utc(2025),
  prototype: prototype,
);

class _RefreshFailureRepository() extends FakeNutritionFoodRepository {
  bool failLoads = false;

  @override
  Future<List<SavedFoodTemplate>> loadTemplates(String subjectId) {
    if (failLoads) return Future.error(StateError('refresh failed'));
    return super.loadTemplates(subjectId);
  }
}

FoodEntry _foodEntry({
  required String id,
  FoodEntryType entryType = FoodEntryType.singleIngredient,
  required Map<String, dynamic> originalValues,
  PreparationDetails? preparationDetails,
  List<FoodComposition>? componentFoods,
}) => FoodEntry(
  id: id,
  foodId: '$id-definition',
  foodVersionId: '$id-version',
  entryType: entryType,
  name: 'Food',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.unknown,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 100,
    protein: 5,
    carbs: 10,
    fat: 2,
    sugars: 3,
    fiber: 4,
    saturatedFat: 1,
    transFat: 0,
    cholesterol: 0,
    sodium: 10,
    waterContent: 70,
    micros: {'iron': 2},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.utc(2025),
  originalValues: originalValues,
  preparationDetails: preparationDetails,
  componentFoods: componentFoods,
);

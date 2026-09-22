import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/util/template_storage_manager.dart';
import 'package:studyu_core/core.dart';

import 'fake_nutrition_food_repository.dart';

void main() {
  setUpAll(() => SharedPreferences.setMockInitialValues({}));
  setUp(() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  });

  test(
    'custom food and saved meal templates round-trip across managers',
    () async {
      final manager = TemplateStorageManager();
      await manager.saveFoodTemplate(
        _template(
          id: 'custom-food',
          name: 'Custom food',
          prototype: _foodEntry(
            id: 'custom-food-prototype',
            originalValues: {},
          ),
        ),
      );
      await manager.saveFoodTemplate(
        _template(
          id: 'saved-meal',
          name: 'Saved meal',
          prototype: _foodEntry(
            id: 'saved-meal-prototype',
            entryType: FoodEntryType.meal,
            originalValues: {},
          ),
        ),
      );

      final templates = await TemplateStorageManager().loadFoodTemplates(
        'test-user',
      );

      expect(templates.map((template) => template.id), [
        'custom-food',
        'saved-meal',
      ]);
      expect(templates[1].prototype.entryType, FoodEntryType.meal);
      expect(
        await TemplateStorageManager().loadFoodTemplates('other-user'),
        isEmpty,
      );
    },
  );

  test('template CRUD persists across managers', () async {
    final manager = TemplateStorageManager();
    final food = _template(
      id: 'custom-food',
      name: 'Custom food',
      prototype: _foodEntry(id: 'custom-food-prototype', originalValues: {}),
    );
    final meal = _template(
      id: 'saved-meal',
      name: 'Saved meal',
      prototype: _foodEntry(
        id: 'saved-meal-prototype',
        entryType: FoodEntryType.meal,
        originalValues: {},
      ),
    );

    await manager.saveFoodTemplate(food);
    await manager.saveFoodTemplate(meal);
    food
      ..name = 'Renamed custom food'
      ..updatedAt = DateTime.utc(2025, 1, 2);
    await manager.saveFoodTemplate(food);
    await manager.deleteFoodTemplate('test-user', meal.id);

    final templates = await TemplateStorageManager().loadFoodTemplates(
      'test-user',
    );
    expect(templates, hasLength(1));
    expect(templates.single.name, 'Renamed custom food');
    expect(templates.single.updatedAt, DateTime.utc(2025, 1, 2));
  });

  test('concurrent template saves preserve both entries', () async {
    await Future.wait([
      TemplateStorageManager().saveFoodTemplate(
        _template(
          id: 'custom-food',
          prototype: _foodEntry(
            id: 'custom-food-prototype',
            originalValues: {},
          ),
        ),
      ),
      TemplateStorageManager().saveFoodTemplate(
        _template(
          id: 'saved-meal',
          prototype: _foodEntry(
            id: 'saved-meal-prototype',
            entryType: FoodEntryType.meal,
            originalValues: {},
          ),
        ),
      ),
    ]);

    final templates = await TemplateStorageManager().loadFoodTemplates(
      'test-user',
    );
    expect(templates.map((template) => template.id).toSet(), {
      'custom-food',
      'saved-meal',
    });
  });

  test(
    'corrupt template data surfaces an error without being overwritten',
    () async {
      const userId = 'corrupt-user';
      const key = 'studyu_food_templates_$userId';
      final prefs = await SharedPreferences.getInstance();
      final manager = TemplateStorageManager();

      for (final corruptJson in ['{', '[{}]']) {
        await prefs.setString(key, corruptJson);

        await expectLater(manager.loadFoodTemplates(userId), throwsA(anything));
        await expectLater(
          manager.saveFoodTemplate(
            _template(
              id: 'replacement',
              userId: userId,
              prototype: _foodEntry(
                id: 'replacement-prototype',
                originalValues: {},
              ),
            ),
          ),
          throwsA(anything),
        );
        expect(prefs.getString(key), corruptJson);
      }
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
    'saving reports refresh failures after preserving saved template',
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

      await expectLater(
        viewModel.saveFoodAsTemplate(
          name: 'New food',
          food: _foodEntry(id: 'new-food', originalValues: {}),
        ),
        throwsA(isA<StateError>()),
      );

      expect(viewModel.foodTemplates.single.name, 'New food');
      expect(viewModel.error, contains('refresh failed'));
    },
  );

  test('applyFoodTemplate isolates mutable food data', () async {
    final prototype = _foodEntry(
      id: 'food-prototype',
      originalValues: {
        'source': 'saved',
        'details': {'verified': true, 'note': null},
        'tags': ['fresh', null],
      },
    );
    final viewModel = await _viewModel();

    final applied = viewModel.applyFoodTemplate(
      _template(id: 'food-template', prototype: prototype),
    );

    expect(applied.id, isNot(prototype.id));
    expect(applied.templateId, 'food-template');
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
    expect(prototype.nutrition.energyKcal, 100);
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
  String userId = 'test-user',
  String name = 'Template',
}) => SavedFoodTemplate(
  id: id,
  userId: userId,
  name: name,
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

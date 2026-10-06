import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_core/core.dart';
import 'package:uuid/uuid.dart';

enum TemplateFilter() {
  all,
  foods,
  meals,
}

class TemplateViewModel({
  required final String userId,
  NutritionFoodRepository? repository,
}) extends ChangeNotifier {
  final NutritionFoodRepository _repository =
      repository ?? NutritionFoodRepository();
  List<SavedFoodTemplate> _foodTemplates = [];

  bool _isLoading = false;
  String? _error;
  TemplateFilter _currentFilter = TemplateFilter.all;
  String _searchQuery = '';

  this {
    loadAllTemplates();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  TemplateFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  List<SavedFoodTemplate> get foodTemplates => _foodTemplates;
  List<SavedFoodTemplate> get mealTemplates => _foodTemplates
      .where((template) => template.prototype.entryType == FoodEntryType.meal)
      .toList();
  List<SavedFoodTemplate> get foodOnlyTemplates => _foodTemplates
      .where((template) => template.prototype.entryType != FoodEntryType.meal)
      .toList();

  List<SavedFoodTemplate> get filteredTemplates {
    final templates = switch (_currentFilter) {
      TemplateFilter.all => _foodTemplates,
      TemplateFilter.foods => foodOnlyTemplates,
      TemplateFilter.meals => mealTemplates,
    };

    if (_searchQuery.isEmpty) return templates;
    final lowerQuery = _searchQuery.toLowerCase();
    return templates
        .where((template) => template.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<void> loadAllTemplates({bool rethrowOnError = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _foodTemplates = await _repository.loadTemplates(userId);
    } catch (error, stackTrace) {
      _error = error.toString();
      StudyULogger.error('Failed to load templates: $error');
      if (rethrowOnError) Error.throwWithStackTrace(error, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveMealAsTemplate({
    required String name,
    required MealLog meal,
    List<String>? tags,
  }) async {
    await saveFoodAsTemplate(
      name: name,
      food: _buildMealEntry(name: name, foods: meal.foods),
      tags: tags,
    );
  }

  Future<String> saveFoodAsTemplate({
    required String name,
    required FoodEntry food,
    List<String>? tags,
  }) async {
    final template = await _repository.saveTemplate(
      subjectId: userId,
      name: name,
      food: _cloneFoodEntry(food),
      tags: tags,
    );
    food
      ..foodId = template.prototype.foodId
      ..foodVersionId = template.prototype.foodVersionId
      ..templateId = template.id;
    _foodTemplates = [
      ..._foodTemplates.where((item) => item.id != template.id),
      template,
    ];
    notifyListeners();
    await loadAllTemplates(rethrowOnError: true);
    return template.id;
  }

  Future<SavedFoodTemplate?> updateFoodTemplatePrototype(
    String templateId,
    FoodEntry prototype,
  ) async {
    var template = _foodTemplates.firstWhereOrNull(
      (item) => item.id == templateId,
    );
    if (template == null) {
      await loadAllTemplates();
      template = _foodTemplates.firstWhereOrNull(
        (item) => item.id == templateId,
      );
    }
    if (template == null) return null;
    final updated = _cloneFoodEntry(prototype)..foodId = template.id;
    final result = await _repository.saveTemplate(
      subjectId: userId,
      name: updated.name,
      food: updated,
      tags: template.tags,
      expectedVersionId: template.prototype.foodVersionId,
    );
    await loadAllTemplates();
    return result;
  }

  Future<void> duplicateFoodTemplate(String templateId) async {
    final source = _foodTemplates.firstWhere(
      (template) => template.id == templateId,
    );
    final duplicate = _cloneFoodEntry(source.prototype)
      ..id = const Uuid().v4()
      ..foodId = const Uuid().v4()
      ..foodVersionId = const Uuid().v4();
    await _repository.saveTemplate(
      subjectId: userId,
      name: source.name,
      food: duplicate,
      tags: source.tags == null ? null : List<String>.from(source.tags!),
    );
    await loadAllTemplates();
  }

  Future<void> deleteFoodTemplate(String templateId) async {
    final template = _foodTemplates.firstWhereOrNull(
      (item) => item.id == templateId,
    );
    if (template == null) return;
    await _repository.deleteTemplate(subjectId: userId, template: template);
    await loadAllTemplates();
  }

  FoodEntry applyFoodTemplate(SavedFoodTemplate template) {
    return _createFoodFromPrototype(template.prototype, template.id);
  }

  void setFilter(TemplateFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  FoodEntry _cloneFoodEntry(FoodEntry original) {
    return FoodEntry.fromJson(original.toJson());
  }

  FoodEntry _createFoodFromPrototype(FoodEntry prototype, String templateId) {
    final food = _cloneFoodEntry(prototype)
      ..id = const Uuid().v4()
      ..originalValues = jsonDecode(
        jsonEncode(prototype.originalValues),
      ) as Map<String, dynamic>
      ..templateId = templateId
      ..createdAt = DateTime.now()
      ..modifiedAt = null
      ..parentEntryId = null;
    food.componentFoods = food.componentFoods
        ?.map(
          (composition) => FoodComposition.withId(
            parentEntryId: food.id,
            foodId: composition.foodId,
            amount: composition.amount,
            unit: composition.unit,
            sortOrder: composition.sortOrder,
          ),
        )
        .toList();
    return food;
  }

  FoodEntry _buildMealEntry({
    required String name,
    required List<FoodEntry> foods,
  }) {
    final nutrition = _sumNutrition(foods);
    final meal = FoodEntry.withId(
      entryType: FoodEntryType.meal,
      name: name,
      amount: 1,
      unit: 'serving',
      servingSizeGrams: foods.fold(
        0,
        (total, food) => total + food.servingSizeGrams * food.amount,
      ),
      portionEstimationMethod: PortionEstimationMethod.householdMeasure,
      portionState: PortionState.asServed,
      nutrition: nutrition,
      source: FoodSource.manual,
      confidenceScore: 0.9,
      originalValues: {},
      componentFoods: [],
      componentSnapshots: foods.map(_cloneFoodEntry).toList(),
    );
    meal.componentFoods = foods
        .map(
          (food) => FoodComposition.withId(
            parentEntryId: meal.id,
            foodId: food.foodId,
            amount: food.amount,
            unit: food.unit,
          ),
        )
        .toList();
    return meal;
  }

  NutritionProfile _sumNutrition(List<FoodEntry> foods) =>
      sumNutritionProfiles(foods.map((food) => food.nutrition));
}

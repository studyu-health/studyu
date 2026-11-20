import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
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
  String _searchQuery = '';
  bool _disposed = false;
  int _loadGeneration = 0;

  this {
    loadAllTemplates();
  }

  bool get isLoading => _isLoading;
  NutritionFoodRepository get repository => _repository;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  List<SavedFoodTemplate> get foodTemplates => _foodTemplates;
  List<SavedFoodTemplate> get mealTemplates => _foodTemplates
      .where((template) => template.prototype.entryType == FoodEntryType.meal)
      .toList();
  List<SavedFoodTemplate> get foodOnlyTemplates => _foodTemplates
      .where((template) => template.prototype.entryType != FoodEntryType.meal)
      .toList();

  List<SavedFoodTemplate> filterTemplates(TemplateFilter filter, String query) {
    final templates = switch (filter) {
      TemplateFilter.all => _foodTemplates,
      TemplateFilter.foods => foodOnlyTemplates,
      TemplateFilter.meals => mealTemplates,
    };
    final lowerQuery = query.trim().toLowerCase();
    if (lowerQuery.isEmpty) return templates;
    return templates
        .where((template) => template.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<void> loadAllTemplates() async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    _error = null;
    _notifyListeners();

    try {
      final templates = await _repository.loadTemplates(userId);
      if (generation == _loadGeneration) _foodTemplates = templates;
    } catch (error) {
      if (generation == _loadGeneration) _error = error.toString();
      StudyULogger.error('Failed to load templates: $error');
    } finally {
      if (generation == _loadGeneration) {
        _isLoading = false;
        _notifyListeners();
      }
    }
  }

  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> saveMealAsTemplate({
    required String name,
    required MealLog meal,
    List<String>? tags,
    String? foodId,
  }) async {
    await saveFoodAsTemplate(
      name: name,
      food: _buildMealEntry(
        name: name,
        foodId: foodId,
        foods: flattenNutritionFoodEntries(meal.foods),
      ),
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
    _replaceTemplate(template);
    await loadAllTemplates();
    return template.id;
  }

  Future<SavedFoodTemplate?> updateFoodTemplatePrototype(
    String templateId,
    FoodEntry prototype, {
    String? expectedVersionId,
  }) async {
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
      expectedVersionId: expectedVersionId ?? template.prototype.foodVersionId,
    );
    _replaceTemplate(result);
    await loadAllTemplates();
    return result;
  }

  void _replaceTemplate(SavedFoodTemplate template) {
    _foodTemplates = [
      ..._foodTemplates.where((item) => item.id != template.id),
      template,
    ];
    _notifyListeners();
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
    _foodTemplates = _foodTemplates
        .where((item) => item.id != templateId)
        .toList();
    await loadAllTemplates();
  }

  FoodEntry applyFoodTemplate(SavedFoodTemplate template) {
    return _createFoodFromPrototype(template.prototype, template.id);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _notifyListeners();
  }

  FoodEntry _cloneFoodEntry(FoodEntry original) {
    return FoodEntry.fromJson(original.toJson());
  }

  FoodEntry _createFoodFromPrototype(FoodEntry prototype, String templateId) {
    final food = rescaleFoodAmount(prototype, 1)
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
    required String? foodId,
    required List<FoodEntry> foods,
  }) {
    final nutrition = _sumNutrition(foods);
    final meal = FoodEntry.withId(
      foodId: foodId,
      entryType: FoodEntryType.meal,
      name: name,
      amount: 1,
      unit: 'serving',
      servingSizeGrams: foods.any((food) => food.servingSizeGrams <= 0)
          ? 0
          : foods.fold(
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

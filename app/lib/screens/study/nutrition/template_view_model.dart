import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_history.dart';
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
  final Future<List<FoodSearchDraft>> Function()? loadDraftRecalls,
}) extends ChangeNotifier {
  final NutritionFoodRepository _repository =
      repository ?? NutritionFoodRepository();
  List<SavedFoodTemplate> _foodTemplates = [];
  List<FoodSearchDraft> _savedDraftRecalls = [];
  FoodSearchDraft? _activeRecall;
  List<MealLog> _activeMeals = [];
  final _draftTemplates = <String, SavedFoodTemplate>{};
  final _deletedFoodIds = <String>{};
  final _checkedDraftFoodIds = <String>{};
  final _checkingDraftFoodIds = <String>{};

  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  int _loadGeneration = 0;

  this {
    loadAllTemplates();
  }

  bool get isLoading => _isLoading;
  NutritionFoodRepository get repository => _repository;
  String? get error => _error;

  List<SavedFoodTemplate> get foodTemplates => {
    for (final entry in _draftTemplates.entries)
      if (_checkedDraftFoodIds.contains(entry.key)) entry.key: entry.value,
    for (final template in _foodTemplates) template.id: template,
  }.values.where((template) => !_deletedFoodIds.contains(template.id)).toList();

  List<FoodSearchDraft> get draftRecalls => [
    for (final recall in _savedDraftRecalls)
      if (_activeRecall == null ||
          foodSearchRecallIdentity(recall) !=
              foodSearchRecallIdentity(_activeRecall!))
        recall,
    ?_activeRecall,
  ];

  List<SavedFoodTemplate> get mealTemplates => foodTemplates
      .where((template) => template.prototype.entryType == FoodEntryType.meal)
      .toList();
  List<SavedFoodTemplate> get foodOnlyTemplates => foodTemplates
      .where((template) => template.prototype.entryType != FoodEntryType.meal)
      .toList();

  List<SavedFoodTemplate> filterTemplates(TemplateFilter filter, String query) {
    final templates = switch (filter) {
      TemplateFilter.all => foodTemplates,
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
    final drafts = _loadSavedDrafts(generation);

    try {
      final templates = await _repository.loadTemplates(userId);
      if (generation == _loadGeneration) _foodTemplates = templates;
    } catch (error) {
      if (generation == _loadGeneration) _error = error.toString();
      StudyULogger.error('Failed to load templates: $error');
    } finally {
      await drafts;
      await _checkDeletedDraftFoods(refresh: true);
      if (generation == _loadGeneration) {
        _isLoading = false;
        _notifyListeners();
      }
    }
  }

  Future<void> _loadSavedDrafts(int generation) async {
    if (loadDraftRecalls == null) return;
    try {
      final drafts = await loadDraftRecalls!();
      if (_disposed || generation != _loadGeneration) return;
      _savedDraftRecalls = drafts;
      _rebuildDraftTemplates();
    } catch (error) {
      StudyULogger.warning('Failed to load nutrition drafts: $error');
    }
  }

  void setActiveRecall(FoodSearchDraft? draft) {
    final recall = draft?.recall;
    final meals = recall?.meals ?? const <MealLog>[];
    if (_activeRecall?.recall.id == recall?.id &&
        _activeRecall?.recall.date == recall?.date &&
        _activeRecall?.taskId == draft?.taskId &&
        _activeRecall?.periodId == draft?.periodId &&
        listEquals(_activeMeals, meals)) {
      return;
    }
    _activeRecall = draft;
    _activeMeals = List.of(meals);
    _rebuildDraftTemplates();
    unawaited(_checkDeletedDraftFoods());
  }

  void _rebuildDraftTemplates() {
    final latest = <String, ({DateTime date, FoodEntry food})>{};
    for (final draft in draftRecalls) {
      final recall = draft.recall;
      for (final meal in recall.meals.where((meal) => !meal.isSkipped)) {
        for (final food in meal.foods) {
          if (!food.amount.isFinite || food.amount <= 0) continue;
          final date = meal.timestamp ?? recall.date;
          final existing = latest[food.foodId];
          if (existing == null || !existing.date.isAfter(date)) {
            latest[food.foodId] = (date: date, food: food);
          }
        }
      }
    }
    _draftTemplates
      ..clear()
      ..addEntries(
        latest.entries.map((entry) {
          final food = rescaleFoodAmount(entry.value.food, 1);
          return MapEntry(
            entry.key,
            SavedFoodTemplate(
              id: entry.key,
              userId: userId,
              name: food.name,
              isPublic: false,
              createdAt: food.createdAt,
              updatedAt: food.modifiedAt,
              prototype: food,
            ),
          );
        }),
      );
    _notifyListeners();
  }

  Future<void> _checkDeletedDraftFoods({bool refresh = false}) async {
    final ids = _draftTemplates.keys.toSet();
    if (!refresh) ids.removeAll(_checkedDraftFoodIds);
    ids
      ..removeAll(_deletedFoodIds)
      ..removeAll(_checkingDraftFoodIds);
    if (ids.isEmpty) return;
    _checkingDraftFoodIds.addAll(ids);
    try {
      final deleted = await _repository.loadDeletedFoodIds(userId, ids);
      _deletedFoodIds.addAll(deleted);
    } catch (error) {
      StudyULogger.warning('Failed to check deleted nutrition foods: $error');
    } finally {
      _checkingDraftFoodIds.removeAll(ids);
      _checkedDraftFoodIds.addAll(ids);
      _notifyListeners();
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
    var template = foodTemplates.firstWhereOrNull(
      (item) => item.id == templateId,
    );
    if (template == null) {
      await loadAllTemplates();
      template = foodTemplates.firstWhereOrNull(
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
      expectedVersionId: _isDraftTemplate(templateId)
          ? null
          : expectedVersionId ?? template.prototype.foodVersionId,
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
    final source = foodTemplates.firstWhere(
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

  Future<bool> deleteFoodTemplate(String templateId) async {
    final template = foodTemplates.firstWhereOrNull(
      (item) => item.id == templateId,
    );
    if (template == null) return false;
    if (_isDraftTemplate(templateId)) {
      await _repository.deleteDraftTemplate(
        subjectId: userId,
        template: template,
      );
    } else {
      await _repository.deleteTemplate(subjectId: userId, template: template);
    }
    _deletedFoodIds.add(templateId);
    _foodTemplates = _foodTemplates
        .where((item) => item.id != templateId)
        .toList();
    await loadAllTemplates();
    return true;
  }

  FoodEntry applyFoodTemplate(SavedFoodTemplate template) {
    return _createFoodFromPrototype(
      template.prototype,
      foodTemplateId(template),
    );
  }

  String? foodTemplateId(SavedFoodTemplate template) =>
      _isDraftTemplate(template.id)
      ? template.prototype.templateId
      : template.id;

  bool _isDraftTemplate(String id) =>
      _draftTemplates.containsKey(id) &&
      !_foodTemplates.any((item) => item.id == id);

  FoodEntry _cloneFoodEntry(FoodEntry original) {
    return FoodEntry.fromJson(original.toJson());
  }

  FoodEntry _createFoodFromPrototype(FoodEntry prototype, String? templateId) {
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

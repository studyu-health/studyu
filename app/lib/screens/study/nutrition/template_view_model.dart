import 'package:flutter/material.dart';
import 'package:studyu_app/util/template_storage_manager.dart';
import 'package:studyu_core/core.dart';

enum TemplateFilter() {
  all,
  meals,
  foods,
  recipes,
}

class TemplateViewModel({required final String userId}) extends ChangeNotifier {
  final TemplateStorageManager _storageManager = TemplateStorageManager();
  List<SavedMealTemplate> _mealTemplates = [];
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

  List<SavedMealTemplate> get mealTemplates => _mealTemplates;
  List<SavedFoodTemplate> get foodTemplates => _foodTemplates;

  List<SavedFoodTemplate> get recipeTemplates => _foodTemplates
      .where((t) => t.prototype.entryType == FoodEntryType.recipe)
      .toList();

  List<SavedFoodTemplate> get foodOnlyTemplates => _foodTemplates
      .where((t) => t.prototype.entryType != FoodEntryType.recipe)
      .toList();

  List<dynamic> get filteredTemplates {
    List<dynamic> results = [];

    switch (_currentFilter) {
      case TemplateFilter.all:
        results = [..._mealTemplates, ..._foodTemplates];
      case TemplateFilter.meals:
        results = _mealTemplates;
      case TemplateFilter.foods:
        results = foodOnlyTemplates;
      case TemplateFilter.recipes:
        results = recipeTemplates;
    }

    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      results = results.where((template) {
        if (template is SavedMealTemplate) {
          return template.name.toLowerCase().contains(lowerQuery);
        } else if (template is SavedFoodTemplate) {
          return template.name.toLowerCase().contains(lowerQuery);
        }
        return false;
      }).toList();
    }

    return results;
  }

  Future<void> loadAllTemplates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mealTemplates = await _storageManager.loadMealTemplates(userId);
      _foodTemplates = await _storageManager.loadFoodTemplates(userId);
    } catch (e) {
      _error = e.toString();
      StudyULogger.error('Failed to load templates: $e');
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
    final template = SavedMealTemplate.withId(
      userId: userId,
      name: name,
      mealType: meal.mealType,
      tags: tags,
      isPublic: false,
      prototypes: meal.foods.map(_cloneFoodEntry).toList(),
    );

    await _storageManager.saveMealTemplate(template);
    await loadAllTemplates();
  }

  Future<void> saveFoodAsTemplate({
    required String name,
    required FoodEntry food,
    List<String>? tags,
  }) async {
    final template = SavedFoodTemplate.withId(
      userId: userId,
      name: name,
      tags: tags,
      isPublic: false,
      prototype: _cloneFoodEntry(food),
    );

    await _storageManager.saveFoodTemplate(template);
    await loadAllTemplates();
  }

  Future<void> deleteMealTemplate(String templateId) async {
    await _storageManager.deleteMealTemplate(userId, templateId);
    await loadAllTemplates();
  }

  Future<void> renameMealTemplate(String templateId, String newName) async {
    final templates = await _storageManager.loadMealTemplates(userId);
    final index = templates.indexWhere((t) => t.id == templateId);
    if (index >= 0) {
      templates[index].name = newName;
      templates[index].updatedAt = DateTime.now();
      await _storageManager.saveMealTemplate(templates[index]);
      await loadAllTemplates();
    }
  }

  Future<void> renameFoodTemplate(String templateId, String newName) async {
    final templates = await _storageManager.loadFoodTemplates(userId);
    final index = templates.indexWhere((t) => t.id == templateId);
    if (index >= 0) {
      templates[index].name = newName;
      templates[index].updatedAt = DateTime.now();
      await _storageManager.saveFoodTemplate(templates[index]);
      await loadAllTemplates();
    }
  }

  Future<void> deleteFoodTemplate(String templateId) async {
    await _storageManager.deleteFoodTemplate(userId, templateId);
    await loadAllTemplates();
  }

  MealLog applyMealTemplate(SavedMealTemplate template) {
    return MealLog.withId(
      mealType: template.mealType,
      mealContext: MealContext.home,
      timestamp: DateTime.now(),
      timezone: DateTime.now().timeZoneName,
      isSkipped: false,
      templateId: template.id,
      foods: template.prototypes
          .map((f) => _createFoodFromPrototype(f, template.id))
          .toList(),
    );
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
    return FoodEntry.withId(
      entryType: prototype.entryType,
      name: prototype.name,
      brandName: prototype.brandName,
      description: prototype.description,
      amount: prototype.amount,
      unit: prototype.unit,
      servingSizeGrams: prototype.servingSizeGrams,
      portionReference: prototype.portionReference,
      portionEstimationMethod: prototype.portionEstimationMethod,
      portionState: prototype.portionState,
      yieldFactor: prototype.yieldFactor,
      ediblePortion: prototype.ediblePortion,
      nutrition: prototype.nutrition,
      foodCode: prototype.foodCode,
      externalId: prototype.externalId,
      source: prototype.source,
      confidenceScore: prototype.confidenceScore,
      templateId: templateId,
      originalValues: prototype.originalValues,
      recipeMetadata: prototype.recipeMetadata,
      recipeIngredients: prototype.recipeIngredients,
    );
  }
}

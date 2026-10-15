import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_core/core.dart';

class TemplateStorageManager() {
  static const String _mealTemplatesKey = 'studyu_meal_templates';
  static const String _foodTemplatesKey = 'studyu_food_templates';

  static SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<SavedMealTemplate>> loadMealTemplates(String userId) async {
    final prefs = await _getPrefs();
    final key = '${_mealTemplatesKey}_$userId';
    final jsonString = prefs.getString(key);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map(
            (json) => SavedMealTemplate.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      StudyULogger.error('Failed to load meal templates: $e');
      return [];
    }
  }

  Future<void> saveMealTemplate(SavedMealTemplate template) async {
    final prefs = await _getPrefs();
    final key = '${_mealTemplatesKey}_${template.userId}';

    final templates = await loadMealTemplates(template.userId);

    final existingIndex = templates.indexWhere((t) => t.id == template.id);
    if (existingIndex >= 0) {
      templates[existingIndex] = template;
    } else {
      templates.add(template);
    }

    final jsonList = templates.map((t) => t.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<void> deleteMealTemplate(String userId, String templateId) async {
    final prefs = await _getPrefs();
    final key = '${_mealTemplatesKey}_$userId';

    final templates = await loadMealTemplates(userId);
    templates.removeWhere((t) => t.id == templateId);

    final jsonList = templates.map((t) => t.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<SavedFoodTemplate>> loadFoodTemplates(String userId) async {
    final prefs = await _getPrefs();
    final key = '${_foodTemplatesKey}_$userId';
    final jsonString = prefs.getString(key);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map(
            (json) => SavedFoodTemplate.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      StudyULogger.error('Failed to load food templates: $e');
      return [];
    }
  }

  Future<List<SavedFoodTemplate>> loadRecipeTemplates(String userId) async {
    final templates = await loadFoodTemplates(userId);
    return templates
        .where((t) => t.prototype.entryType == FoodEntryType.recipe)
        .toList();
  }

  Future<List<SavedFoodTemplate>> loadFoodOnlyTemplates(String userId) async {
    final templates = await loadFoodTemplates(userId);
    return templates
        .where((t) => t.prototype.entryType != FoodEntryType.recipe)
        .toList();
  }

  Future<void> saveFoodTemplate(SavedFoodTemplate template) async {
    final prefs = await _getPrefs();
    final key = '${_foodTemplatesKey}_${template.userId}';

    final templates = await loadFoodTemplates(template.userId);

    final existingIndex = templates.indexWhere((t) => t.id == template.id);
    if (existingIndex >= 0) {
      templates[existingIndex] = template;
    } else {
      templates.add(template);
    }

    final jsonList = templates.map((t) => t.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<void> deleteFoodTemplate(String userId, String templateId) async {
    final prefs = await _getPrefs();
    final key = '${_foodTemplatesKey}_$userId';

    final templates = await loadFoodTemplates(userId);
    templates.removeWhere((t) => t.id == templateId);

    final jsonList = templates.map((t) => t.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<SavedFoodTemplate>> searchFoodTemplates(
    String userId,
    String query,
  ) async {
    final templates = await loadFoodTemplates(userId);
    final lowerQuery = query.toLowerCase();
    return templates
        .where((t) => t.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<List<SavedMealTemplate>> searchMealTemplates(
    String userId,
    String query,
  ) async {
    final templates = await loadMealTemplates(userId);
    final lowerQuery = query.toLowerCase();
    return templates
        .where((t) => t.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}

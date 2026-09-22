import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_core/core.dart';

class TemplateStorageManager() {
  static const String _foodTemplatesKey = 'studyu_food_templates';

  static SharedPreferences? _prefs;
  static final Map<String, Future<void>> _mutationQueues = {};

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<SavedFoodTemplate>> loadFoodTemplates(String userId) async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString('${_foodTemplatesKey}_$userId');
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString);
      if (jsonList is! List) {
        throw const FormatException('Food templates must be a JSON list.');
      }
      return jsonList.map((json) {
        if (json is! Map<String, dynamic>) {
          throw const FormatException('Food template must be a JSON object.');
        }
        return SavedFoodTemplate.fromJson(json);
      }).toList();
    } catch (error) {
      StudyULogger.error('Failed to load food templates: $error');
      rethrow;
    }
  }

  Future<void> saveFoodTemplate(SavedFoodTemplate template) {
    return _mutateForUser(template.userId, () async {
      final prefs = await _getPrefs();
      final key = '${_foodTemplatesKey}_${template.userId}';
      final templates = await loadFoodTemplates(template.userId);
      final existingIndex = templates.indexWhere((t) => t.id == template.id);
      if (existingIndex >= 0) {
        templates[existingIndex] = template;
      } else {
        templates.add(template);
      }
      await _saveFoodTemplates(prefs, key, templates);
    });
  }

  Future<void> deleteFoodTemplate(String userId, String templateId) {
    return _mutateForUser(userId, () async {
      final prefs = await _getPrefs();
      final key = '${_foodTemplatesKey}_$userId';
      final templates = await loadFoodTemplates(userId);
      templates.removeWhere((template) => template.id == templateId);
      await _saveFoodTemplates(prefs, key, templates);
    });
  }

  Future<void> _saveFoodTemplates(
    SharedPreferences prefs,
    String key,
    List<SavedFoodTemplate> templates,
  ) async {
    final saved = await prefs.setString(
      key,
      jsonEncode(templates.map((template) => template.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('Failed to save food templates.');
    }
  }

  Future<T> _mutateForUser<T>(String userId, Future<T> Function() mutation) {
    final key = '${_foodTemplatesKey}_$userId';
    final previous = _mutationQueues[key] ?? Future<void>.value();
    final operation = previous.then<T>(
      (_) => mutation(),
      onError: (_, _) => mutation(),
    );
    final queueTail = operation.then<void>((_) {}, onError: (_, _) {});
    _mutationQueues[key] = queueTail;
    queueTail.whenComplete(() {
      if (identical(_mutationQueues[key], queueTail)) {
        _mutationQueues.remove(key);
      }
    });
    return operation;
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
}

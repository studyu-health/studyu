import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_core/core.dart';

class FakeNutritionFoodRepository([
  Iterable<SavedFoodTemplate> templates = const [],
]) extends NutritionFoodRepository {
  final List<SavedFoodTemplate> _templates = List.of(templates);
  int loadCalls = 0;

  @override
  Future<List<SavedFoodTemplate>> loadTemplates(String subjectId) async {
    loadCalls++;
    return List.of(_templates);
  }

  @override
  Future<void> ensureDefinitions({
    required String subjectId,
    required Iterable<FoodEntry> foods,
  }) async {}

  @override
  Future<SavedFoodTemplate> saveTemplate({
    required String subjectId,
    required String name,
    required FoodEntry food,
    List<String>? tags,
    String? expectedVersionId,
  }) async {
    final template = SavedFoodTemplate(
      id: food.foodId,
      userId: subjectId,
      name: name,
      tags: tags,
      isPublic: false,
      createdAt: DateTime.now(),
      prototype: FoodEntry.fromJson(food.toJson()),
    );
    _templates
      ..removeWhere((item) => item.id == template.id)
      ..add(template);
    return template;
  }

  @override
  Future<void> deleteTemplate({
    required String subjectId,
    required SavedFoodTemplate template,
  }) async {
    _templates.removeWhere((item) => item.id == template.id);
  }
}

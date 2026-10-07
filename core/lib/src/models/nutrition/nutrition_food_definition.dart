import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/nutrition/food_entry.dart';

part 'nutrition_food_definition.g.dart';

/// Subject-scoped active definition and its immutable snapshot revision.
@JsonSerializable()
class const NutritionFoodDefinition({
  required final String id,
  required final String subjectId,
  required final String kind,
  required final String currentVersionId,
  required final DateTime? deletedAt,
  required final FoodEntry snapshot,
  required final DateTime createdAt,
  required final DateTime updatedAt,
}) {
  factory fromJson(Map<String, dynamic> json) =>
      _$NutritionFoodDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionFoodDefinitionToJson(this);
}

/// Canonical RPC result with explicit persisted-row update counts.
@JsonSerializable()
class const NutritionFoodMutationResult({
  required final NutritionFoodDefinition definition,
  required final List<Map<String, dynamic>> progress,
  required final int selectedHistoricalUpdateCount,
  required final int todayUpdateCount,
}) {
  factory fromJson(Map<String, dynamic> json) =>
      _$NutritionFoodMutationResultFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionFoodMutationResultToJson(this);
}

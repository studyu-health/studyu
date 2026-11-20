// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_food_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionFoodDefinition _$NutritionFoodDefinitionFromJson(
  Map<String, dynamic> json,
) => NutritionFoodDefinition(
  id: json['id'] as String,
  subjectId: json['subjectId'] as String,
  kind: json['kind'] as String,
  currentVersionId: json['currentVersionId'] as String,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  snapshot: FoodEntry.fromJson(json['snapshot'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$NutritionFoodDefinitionToJson(
  NutritionFoodDefinition instance,
) => <String, dynamic>{
  'id': instance.id,
  'subjectId': instance.subjectId,
  'kind': instance.kind,
  'currentVersionId': instance.currentVersionId,
  'deletedAt': ?instance.deletedAt?.toIso8601String(),
  'snapshot': instance.snapshot.toJson(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

NutritionFoodMutationResult _$NutritionFoodMutationResultFromJson(
  Map<String, dynamic> json,
) => NutritionFoodMutationResult(
  definition: NutritionFoodDefinition.fromJson(
    json['definition'] as Map<String, dynamic>,
  ),
  progress: (json['progress'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  selectedHistoricalUpdateCount: (json['selectedHistoricalUpdateCount'] as num)
      .toInt(),
  todayUpdateCount: (json['todayUpdateCount'] as num).toInt(),
);

Map<String, dynamic> _$NutritionFoodMutationResultToJson(
  NutritionFoodMutationResult instance,
) => <String, dynamic>{
  'definition': instance.definition.toJson(),
  'progress': instance.progress,
  'selectedHistoricalUpdateCount': instance.selectedHistoricalUpdateCount,
  'todayUpdateCount': instance.todayUpdateCount,
};

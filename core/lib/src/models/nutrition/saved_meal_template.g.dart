// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_meal_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedMealTemplate _$SavedMealTemplateFromJson(Map<String, dynamic> json) =>
    SavedMealTemplate(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      prototypes: (json['prototypes'] as List<dynamic>)
          .map((e) => FoodEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SavedMealTemplateToJson(SavedMealTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'mealType': instance.mealType.toJson(),
      'tags': ?instance.tags,
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': ?instance.updatedAt?.toIso8601String(),
      'prototypes': instance.prototypes.map((e) => e.toJson()).toList(),
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.brunch: 'brunch',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
  MealType.other: 'other',
};

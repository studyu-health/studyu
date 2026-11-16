// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_food_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedFoodTemplate _$SavedFoodTemplateFromJson(Map<String, dynamic> json) =>
    SavedFoodTemplate(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      prototype: FoodEntry.fromJson(json['prototype'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SavedFoodTemplateToJson(SavedFoodTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'tags': ?instance.tags,
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': ?instance.updatedAt?.toIso8601String(),
      'prototype': instance.prototype.toJson(),
    };

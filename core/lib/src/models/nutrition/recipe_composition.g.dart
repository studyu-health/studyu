// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_composition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeComposition _$RecipeCompositionFromJson(Map<String, dynamic> json) =>
    RecipeComposition(
      id: json['id'] as String,
      recipeId: json['recipeId'] as String,
      ingredientId: json['ingredientId'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RecipeCompositionToJson(RecipeComposition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipeId': instance.recipeId,
      'ingredientId': instance.ingredientId,
      'amount': instance.amount,
      'unit': instance.unit,
      'sortOrder': ?instance.sortOrder,
    };

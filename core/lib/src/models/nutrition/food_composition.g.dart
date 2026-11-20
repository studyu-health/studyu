// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_composition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodComposition _$FoodCompositionFromJson(Map<String, dynamic> json) =>
    FoodComposition(
      id: json['id'] as String,
      parentEntryId: json['parentEntryId'] as String,
      foodId: json['foodId'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FoodCompositionToJson(FoodComposition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentEntryId': instance.parentEntryId,
      'foodId': instance.foodId,
      'amount': instance.amount,
      'unit': instance.unit,
      'sortOrder': ?instance.sortOrder,
    };

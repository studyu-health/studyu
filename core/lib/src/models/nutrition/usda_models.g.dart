// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usda_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsdaSearchResponse _$UsdaSearchResponseFromJson(Map<String, dynamic> json) =>
    UsdaSearchResponse(
      totalHits: (json['totalHits'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      foods: (json['foods'] as List<dynamic>)
          .map((e) => UsdaFoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UsdaSearchResponseToJson(UsdaSearchResponse instance) =>
    <String, dynamic>{
      'totalHits': instance.totalHits,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'foods': instance.foods.map((e) => e.toJson()).toList(),
    };

UsdaFoodItem _$UsdaFoodItemFromJson(Map<String, dynamic> json) => UsdaFoodItem(
  fdcId: (json['fdcId'] as num).toInt(),
  description: json['description'] as String?,
  dataType: json['dataType'] as String?,
  brandOwner: json['brandOwner'] as String?,
  brandName: json['brandName'] as String?,
  gtinUpc: json['gtinUpc'] as String?,
  ingredients: json['ingredients'] as String?,
  servingSize: (json['servingSize'] as num?)?.toDouble(),
  servingSizeUnit: json['servingSizeUnit'] as String?,
  householdServingFullText: json['householdServingFullText'] as String?,
  foodNutrients: (json['foodNutrients'] as List<dynamic>)
      .map((e) => UsdaFoodNutrient.fromJson(e as Map<String, dynamic>))
      .toList(),
  foodPortions: (json['foodPortions'] as List<dynamic>?)
      ?.map((e) => UsdaFoodPortion.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UsdaFoodItemToJson(UsdaFoodItem instance) =>
    <String, dynamic>{
      'fdcId': instance.fdcId,
      'description': ?instance.description,
      'dataType': ?instance.dataType,
      'brandOwner': ?instance.brandOwner,
      'brandName': ?instance.brandName,
      'gtinUpc': ?instance.gtinUpc,
      'ingredients': ?instance.ingredients,
      'servingSize': ?instance.servingSize,
      'servingSizeUnit': ?instance.servingSizeUnit,
      'householdServingFullText': ?instance.householdServingFullText,
      'foodNutrients': instance.foodNutrients.map((e) => e.toJson()).toList(),
      'foodPortions': ?instance.foodPortions?.map((e) => e.toJson()).toList(),
    };

UsdaFoodNutrient _$UsdaFoodNutrientFromJson(Map<String, dynamic> json) =>
    UsdaFoodNutrient(
      nutrientId: (json['nutrientId'] as num).toInt(),
      nutrientName: json['nutrientName'] as String?,
      nutrientNumber: json['nutrientNumber'] as String?,
      unitName: json['unitName'] as String?,
      value: (json['value'] as num?)?.toDouble(),
      derivationId: (json['derivationId'] as num?)?.toInt(),
      derivationDescription: json['derivationDescription'] as String?,
    );

Map<String, dynamic> _$UsdaFoodNutrientToJson(UsdaFoodNutrient instance) =>
    <String, dynamic>{
      'nutrientId': instance.nutrientId,
      'nutrientName': ?instance.nutrientName,
      'nutrientNumber': ?instance.nutrientNumber,
      'unitName': ?instance.unitName,
      'value': ?instance.value,
      'derivationId': ?instance.derivationId,
      'derivationDescription': ?instance.derivationDescription,
    };

UsdaFoodPortion _$UsdaFoodPortionFromJson(Map<String, dynamic> json) =>
    UsdaFoodPortion(
      id: (json['id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      measureUnit: json['measureUnit'] as String?,
      portionDescription: json['portionDescription'] as String?,
      modifier: json['modifier'] as String?,
    );

Map<String, dynamic> _$UsdaFoodPortionToJson(UsdaFoodPortion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'measureUnit': ?instance.measureUnit,
      'portionDescription': ?instance.portionDescription,
      'modifier': ?instance.modifier,
    };

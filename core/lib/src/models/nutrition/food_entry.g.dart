// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodEntry _$FoodEntryFromJson(Map<String, dynamic> json) => FoodEntry(
  id: json['id'] as String,
  foodId: json['foodId'] as String,
  foodVersionId: json['foodVersionId'] as String,
  entryType: $enumDecode(_$FoodEntryTypeEnumMap, json['entryType']),
  name: json['name'] as String,
  brandName: json['brandName'] as String?,
  description: json['description'] as String?,
  amount: (json['amount'] as num).toDouble(),
  unit: json['unit'] as String,
  servingSizeGrams: (json['servingSizeGrams'] as num).toDouble(),
  portionReference: json['portionReference'] as String?,
  portionEstimationMethod: $enumDecode(
    _$PortionEstimationMethodEnumMap,
    json['portionEstimationMethod'],
  ),
  portionState: $enumDecode(_$PortionStateEnumMap, json['portionState']),
  yieldFactor: (json['yieldFactor'] as num?)?.toDouble(),
  ediblePortion: (json['ediblePortion'] as num?)?.toDouble(),
  nutrition: NutritionProfile.fromJson(
    json['nutrition'] as Map<String, dynamic>,
  ),
  foodCode: json['foodCode'] as String?,
  externalId: json['externalId'] as String?,
  source: $enumDecode(_$FoodSourceEnumMap, json['source']),
  confidenceScore: (json['confidenceScore'] as num).toDouble(),
  templateId: json['templateId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  modifiedAt: json['modifiedAt'] == null
      ? null
      : DateTime.parse(json['modifiedAt'] as String),
  originalValues: json['originalValues'] as Map<String, dynamic>,
  parentEntryId: json['parentEntryId'] as String?,
  preparationDetails: json['preparationDetails'] == null
      ? null
      : PreparationDetails.fromJson(
          json['preparationDetails'] as Map<String, dynamic>,
        ),
  componentFoods: (json['componentFoods'] as List<dynamic>?)
      ?.map((e) => FoodComposition.fromJson(e as Map<String, dynamic>))
      .toList(),
  componentSnapshots: (json['componentSnapshots'] as List<dynamic>?)
      ?.map((e) => FoodEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FoodEntryToJson(FoodEntry instance) => <String, dynamic>{
  'id': instance.id,
  'foodId': instance.foodId,
  'foodVersionId': instance.foodVersionId,
  'entryType': instance.entryType.toJson(),
  'name': instance.name,
  'brandName': ?instance.brandName,
  'description': ?instance.description,
  'amount': instance.amount,
  'unit': instance.unit,
  'servingSizeGrams': instance.servingSizeGrams,
  'portionReference': ?instance.portionReference,
  'portionEstimationMethod': instance.portionEstimationMethod.toJson(),
  'portionState': instance.portionState.toJson(),
  'yieldFactor': ?instance.yieldFactor,
  'ediblePortion': ?instance.ediblePortion,
  'nutrition': instance.nutrition.toJson(),
  'foodCode': ?instance.foodCode,
  'externalId': ?instance.externalId,
  'source': instance.source.toJson(),
  'confidenceScore': instance.confidenceScore,
  'templateId': ?instance.templateId,
  'createdAt': instance.createdAt.toIso8601String(),
  'modifiedAt': ?instance.modifiedAt?.toIso8601String(),
  'originalValues': instance.originalValues,
  'parentEntryId': ?instance.parentEntryId,
  'preparationDetails': ?instance.preparationDetails?.toJson(),
  'componentFoods': ?instance.componentFoods?.map((e) => e.toJson()).toList(),
  'componentSnapshots': ?instance.componentSnapshots
      ?.map((e) => e.toJson())
      .toList(),
};

const _$FoodEntryTypeEnumMap = {
  FoodEntryType.singleIngredient: 'singleIngredient',
  FoodEntryType.meal: 'meal',
  FoodEntryType.brandedProduct: 'brandedProduct',
  FoodEntryType.manualCustom: 'manualCustom',
};

const _$PortionEstimationMethodEnumMap = {
  PortionEstimationMethod.householdMeasure: 'householdMeasure',
  PortionEstimationMethod.photograph: 'photograph',
  PortionEstimationMethod.standardUnit: 'standardUnit',
  PortionEstimationMethod.userWeighted: 'userWeighted',
  PortionEstimationMethod.unknown: 'unknown',
};

const _$PortionStateEnumMap = {
  PortionState.raw: 'raw',
  PortionState.cooked: 'cooked',
  PortionState.asServed: 'asServed',
};

const _$FoodSourceEnumMap = {
  FoodSource.openfoodfacts: 'openfoodfacts',
  FoodSource.usda: 'usda',
  FoodSource.mealdb: 'mealdb',
  FoodSource.manual: 'manual',
};

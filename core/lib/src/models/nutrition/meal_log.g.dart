// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealLog _$MealLogFromJson(Map<String, dynamic> json) => MealLog(
  id: json['id'] as String,
  mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
  customMealLabel: json['customMealLabel'] as String?,
  mealContext: $enumDecode(_$MealContextEnumMap, json['mealContext']),
  locationDescription: json['locationDescription'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  timezone: json['timezone'] as String,
  isSkipped: json['isSkipped'] as bool,
  skipReason: json['skipReason'] as String?,
  companyContext: $enumDecodeNullable(
    _$CompanyContextEnumMap,
    json['companyContext'],
  ),
  distractionContext: $enumDecodeNullable(
    _$DistractionContextEnumMap,
    json['distractionContext'],
  ),
  templateId: json['templateId'] as String?,
  foods: (json['foods'] as List<dynamic>)
      .map((e) => FoodEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MealLogToJson(MealLog instance) => <String, dynamic>{
  'id': instance.id,
  'mealType': instance.mealType.toJson(),
  'customMealLabel': ?instance.customMealLabel,
  'mealContext': instance.mealContext.toJson(),
  'locationDescription': ?instance.locationDescription,
  'timestamp': instance.timestamp.toIso8601String(),
  'timezone': instance.timezone,
  'isSkipped': instance.isSkipped,
  'skipReason': ?instance.skipReason,
  'companyContext': ?instance.companyContext?.toJson(),
  'distractionContext': ?instance.distractionContext?.toJson(),
  'templateId': ?instance.templateId,
  'foods': instance.foods.map((e) => e.toJson()).toList(),
};

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.brunch: 'brunch',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
  MealType.other: 'other',
};

const _$MealContextEnumMap = {
  MealContext.home: 'home',
  MealContext.restaurant: 'restaurant',
  MealContext.takeout: 'takeout',
  MealContext.vending: 'vending',
  MealContext.other: 'other',
};

const _$CompanyContextEnumMap = {
  CompanyContext.alone: 'alone',
  CompanyContext.family: 'family',
  CompanyContext.friends: 'friends',
  CompanyContext.colleagues: 'colleagues',
  CompanyContext.other: 'other',
};

const _$DistractionContextEnumMap = {
  DistractionContext.none: 'none',
  DistractionContext.tv: 'tv',
  DistractionContext.phone: 'phone',
  DistractionContext.work: 'work',
  DistractionContext.other: 'other',
};

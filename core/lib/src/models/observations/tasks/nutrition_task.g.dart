// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionTask _$NutritionTaskFromJson(Map<String, dynamic> json) =>
    NutritionTask()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..title = json['title'] as String?
      ..header = json['header'] as String?
      ..footer = json['footer'] as String?
      ..schedule = Schedule.fromJson(json['schedule'] as Map<String, dynamic>)
      ..scheduleRule = json['scheduleRule'] == null
          ? null
          : TaskScheduleRule.fromJson(
              json['scheduleRule'] as Map<String, dynamic>,
            )
      ..instructions = json['instructions'] as String?
      ..collectMealContext = json['collectMealContext'] as bool? ?? true
      ..allowRecipes = json['allowRecipes'] as bool? ?? true
      ..minimumMealsRequired = (json['minimumMealsRequired'] as num?)?.toInt()
      ..customMealTypes = (json['customMealTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();

Map<String, dynamic> _$NutritionTaskToJson(NutritionTask instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'title': ?instance.title,
      'header': ?instance.header,
      'footer': ?instance.footer,
      'schedule': instance.schedule.toJson(),
      'scheduleRule': ?instance.scheduleRule?.toJson(),
      'instructions': ?instance.instructions,
      'collectMealContext': instance.collectMealContext,
      'allowRecipes': instance.allowRecipes,
      'minimumMealsRequired': ?instance.minimumMealsRequired,
      'customMealTypes': ?instance.customMealTypes,
    };

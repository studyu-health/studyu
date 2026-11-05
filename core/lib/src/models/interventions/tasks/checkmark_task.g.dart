// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkmark_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckmarkTask _$CheckmarkTaskFromJson(Map<String, dynamic> json) =>
    CheckmarkTask()
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
            );

Map<String, dynamic> _$CheckmarkTaskToJson(CheckmarkTask instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'title': ?instance.title,
      'header': ?instance.header,
      'footer': ?instance.footer,
      'schedule': instance.schedule.toJson(),
      'scheduleRule': ?instance.scheduleRule?.toJson(),
    };

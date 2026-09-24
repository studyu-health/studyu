// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_schedule_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskScheduleRule _$TaskScheduleRuleFromJson(Map<String, dynamic> json) =>
    TaskScheduleRule(
      type: $enumDecode(_$TaskScheduleTypeEnumMap, json['type']),
      specificDays:
          (json['specificDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      intervalDays: (json['intervalDays'] as num?)?.toInt(),
      startDayOffset: (json['startDayOffset'] as num?)?.toInt(),
      dayOfCycle: (json['dayOfCycle'] as num?)?.toInt(),
      targetCycles: (json['targetCycles'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      includeBaseline: json['includeBaseline'] as bool? ?? false,
    );

Map<String, dynamic> _$TaskScheduleRuleToJson(TaskScheduleRule instance) =>
    <String, dynamic>{
      'type': instance.type.toJson(),
      'specificDays': instance.specificDays,
      'intervalDays': ?instance.intervalDays,
      'startDayOffset': ?instance.startDayOffset,
      'dayOfCycle': ?instance.dayOfCycle,
      'targetCycles': ?instance.targetCycles,
      'includeBaseline': instance.includeBaseline,
    };

const _$TaskScheduleTypeEnumMap = {
  TaskScheduleType.specificDays: 'specificDays',
  TaskScheduleType.everyNDays: 'everyNDays',
  TaskScheduleType.perCycle: 'perCycle',
};

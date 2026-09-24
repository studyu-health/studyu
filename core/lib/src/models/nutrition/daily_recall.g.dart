// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_recall.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecall _$DailyRecallFromJson(Map<String, dynamic> json) => DailyRecall(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  isUsualIntakeDay: json['isUsualIntakeDay'] as bool?,
  specialOccasion: json['specialOccasion'] as String?,
  recallMode: $enumDecode(_$RecallModeEnumMap, json['recallMode']),
  entryStartedAt: json['entryStartedAt'] == null
      ? null
      : DateTime.parse(json['entryStartedAt'] as String),
  entryCompletedAt: json['entryCompletedAt'] == null
      ? null
      : DateTime.parse(json['entryCompletedAt'] as String),
  meals: (json['meals'] as List<dynamic>)
      .map((e) => MealLog.fromJson(e as Map<String, dynamic>))
      .toList(),
  studyDaySnapshot: (json['studyDaySnapshot'] as num?)?.toInt(),
  lastAutoSavedAt: json['lastAutoSavedAt'] == null
      ? null
      : DateTime.parse(json['lastAutoSavedAt'] as String),
);

Map<String, dynamic> _$DailyRecallToJson(DailyRecall instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'isUsualIntakeDay': ?instance.isUsualIntakeDay,
      'specialOccasion': ?instance.specialOccasion,
      'recallMode': instance.recallMode.toJson(),
      'entryStartedAt': ?instance.entryStartedAt?.toIso8601String(),
      'entryCompletedAt': ?instance.entryCompletedAt?.toIso8601String(),
      'meals': instance.meals.map((e) => e.toJson()).toList(),
      'studyDaySnapshot': ?instance.studyDaySnapshot,
      'lastAutoSavedAt': ?instance.lastAutoSavedAt?.toIso8601String(),
    };

const _$RecallModeEnumMap = {
  RecallMode.realtimeRecord: 'realtimeRecord',
  RecallMode.yesterdayRecall: 'yesterdayRecall',
};

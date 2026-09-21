// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyUUser _$StudyUUserFromJson(Map<String, dynamic> json) => StudyUUser(
  id: json['id'] as String,
  email: json['email'] as String,
  preferences: json['preferences'] == null
      ? null
      : Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StudyUUserToJson(StudyUUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'preferences': instance.preferences.toJson(),
    };

Preferences _$PreferencesFromJson(Map<String, dynamic> json) => Preferences(
  language: json['lang'] as String? ?? '',
  dateFormat: $enumDecodeNullable(
    _$DateFormatPreferenceEnumMap,
    json['date_format'],
  ),
  timeFormat: $enumDecodeNullable(
    _$TimeFormatPreferenceEnumMap,
    json['time_format'],
  ),
  pinnedStudies:
      (json['pinned_studies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet() ??
      const {},
  studyFiltering: json['study_filtering'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$PreferencesToJson(Preferences instance) =>
    <String, dynamic>{
      'lang': instance.language,
      'date_format': ?_$DateFormatPreferenceEnumMap[instance.dateFormat],
      'time_format': ?_$TimeFormatPreferenceEnumMap[instance.timeFormat],
      'pinned_studies': instance.pinnedStudies.toList(),
      'study_filtering': instance.studyFiltering,
    };

const _$DateFormatPreferenceEnumMap = {
  DateFormatPreference.iso: 'iso',
  DateFormatPreference.european: 'european',
  DateFormatPreference.us: 'us',
  DateFormatPreference.german: 'german',
};

const _$TimeFormatPreferenceEnumMap = {
  TimeFormatPreference.h24: 'h24',
  TimeFormatPreference.h12: 'h12',
};

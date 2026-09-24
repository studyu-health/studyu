// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyTemplate _$SurveyTemplateFromJson(
  Map<String, dynamic> json,
) => SurveyTemplate(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  source:
      $enumDecodeNullable(_$SurveyTemplateSourceEnumMap, json['source']) ??
      SurveyTemplateSource.builtIn,
  sharing:
      $enumDecodeNullable(_$ResultSharingEnumMap, json['sharing']) ??
      ResultSharing.public,
  registryPublished: json['registry_published'] as bool? ?? false,
  userId: json['user_id'] as String?,
  collaboratorEmails:
      (json['collaborator_emails'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  taskJson: json['task_json'] as Map<String, dynamic>?,
  dayEntries: (json['day_entries'] as List<dynamic>?)
      ?.map((e) => SurveyTemplateDayEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SurveyTemplateToJson(SurveyTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'source': instance.source.toJson(),
      'sharing': instance.sharing.toJson(),
      'registry_published': instance.registryPublished,
      'user_id': ?instance.userId,
      'collaborator_emails': instance.collaboratorEmails,
      'tags': instance.tags,
      'task_json': ?instance.taskJson,
      'day_entries': ?instance.dayEntries?.map((e) => e.toJson()).toList(),
      'created_at': ?instance.createdAt?.toIso8601String(),
      'updated_at': ?instance.updatedAt?.toIso8601String(),
    };

const _$SurveyTemplateSourceEnumMap = {
  SurveyTemplateSource.builtIn: 'builtIn',
  SurveyTemplateSource.user: 'user',
};

const _$ResultSharingEnumMap = {
  ResultSharing.public: 'public',
  ResultSharing.private: 'private',
  ResultSharing.organization: 'organization',
};

SurveyTemplateDayEntry _$SurveyTemplateDayEntryFromJson(
  Map<String, dynamic> json,
) => SurveyTemplateDayEntry(
  dayIndex: (json['day_index'] as num).toInt(),
  title: json['title'] as String,
  taskJson: json['task_json'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SurveyTemplateDayEntryToJson(
  SurveyTemplateDayEntry instance,
) => <String, dynamic>{
  'day_index': instance.dayIndex,
  'title': instance.title,
  'task_json': ?instance.taskJson,
};

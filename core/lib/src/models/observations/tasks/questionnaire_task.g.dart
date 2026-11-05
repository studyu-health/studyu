// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionnaireTask _$QuestionnaireTaskFromJson(Map<String, dynamic> json) =>
    QuestionnaireTask()
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
      ..questions = StudyUQuestionnaire.fromJson(
        json['questions'] as List<dynamic>,
      );

Map<String, dynamic> _$QuestionnaireTaskToJson(QuestionnaireTask instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'title': ?instance.title,
      'header': ?instance.header,
      'footer': ?instance.footer,
      'schedule': instance.schedule.toJson(),
      'scheduleRule': ?instance.scheduleRule?.toJson(),
      'questions': instance.questions.toJson(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectProgress _$SubjectProgressFromJson(Map<String, dynamic> json) =>
    SubjectProgress(
        subjectId: json['subject_id'] as String,
        interventionId: json['intervention_id'] as String,
        taskId: json['task_id'] as String,
        resultType: json['result_type'] as String,
        result: Result<dynamic>.fromJson(
          json['result'] as Map<String, dynamic>,
        ),
      )
      ..completedAt = json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String);

Map<String, dynamic> _$SubjectProgressToJson(SubjectProgress instance) =>
    <String, dynamic>{
      'subject_id': instance.subjectId,
      'intervention_id': instance.interventionId,
      'task_id': instance.taskId,
      'result_type': instance.resultType,
      'result': instance.result.toJson(),
      'completed_at': ?instance.completedAt?.toIso8601String(),
    };

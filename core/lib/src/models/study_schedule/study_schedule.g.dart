// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudySchedule _$StudyScheduleFromJson(Map<String, dynamic> json) =>
    StudySchedule(sequenceCustom: json['sequenceCustom'] as String? ?? 'ABAB')
      ..numberOfCycles = (json['numberOfCycles'] as num).toInt()
      ..phaseDuration = (json['phaseDuration'] as num).toInt()
      ..includeBaseline = json['includeBaseline'] as bool
      ..sequence = $enumDecode(_$PhaseSequenceEnumMap, json['sequence']);

Map<String, dynamic> _$StudyScheduleToJson(StudySchedule instance) =>
    <String, dynamic>{
      'sequenceCustom': instance.sequenceCustom,
      'numberOfCycles': instance.numberOfCycles,
      'phaseDuration': instance.phaseDuration,
      'includeBaseline': instance.includeBaseline,
      'sequence': instance.sequence.toJson(),
    };

const _$PhaseSequenceEnumMap = {
  PhaseSequence.alternating: 'alternating',
  PhaseSequence.counterBalanced: 'counterBalanced',
  PhaseSequence.randomized: 'randomized',
  PhaseSequence.customized: 'customized',
};

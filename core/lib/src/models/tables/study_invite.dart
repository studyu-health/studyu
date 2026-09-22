import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/util/supabase_object.dart';

part 'study_invite.g.dart';

@JsonSerializable()
class StudyInvite(
  var String code,
  @JsonKey(name: 'study_id') var String studyId, {
  @JsonKey(name: 'preselected_intervention_ids')
  var List<String>? preselectedInterventionIds,
  @JsonKey(name: participantCountJsonKey, includeToJson: false)
  var int participantCount = 0,
}) extends SupabaseObjectFunctions<StudyInvite> {
  static const String tableName = 'study_invite';
  static const String participantCountJsonKey =
      'study_invite_participant_count';

  @override
  Map<String, Object> get primaryKeys => {'code': code};

  factory fromJson(Map<String, dynamic> json) => _$StudyInviteFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StudyInviteToJson(this);
}

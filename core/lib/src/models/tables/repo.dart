import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/util/supabase_object.dart';

part 'repo.g.dart';

enum GitProvider() {
  gitlab,
}

@JsonSerializable()
class Repo(
  @JsonKey(name: 'project_id') var String projectId,
  @JsonKey(name: 'user_id') var String userId,
  @JsonKey(name: 'study_id') var String studyId,
  var GitProvider provider,
  @JsonKey(name: 'web_url') var String? webUrl,
  @JsonKey(name: 'git_url') var String? gitUrl,
) extends SupabaseObjectFunctions<Repo> {
  static const String tableName = 'repo';

  @override
  Map<String, Object> get primaryKeys => {'project_id': projectId};

  factory fromJson(Map<String, dynamic> json) => _$RepoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RepoToJson(this);
}

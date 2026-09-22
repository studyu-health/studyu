import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/core.dart';

part 'user.g.dart';

enum DateFormatPreference(final String pattern) {
  @JsonValue('iso')
  iso('yyyy-MM-dd'),
  @JsonValue('european')
  european('dd/MM/yyyy'),
  @JsonValue('us')
  us('MM/dd/yyyy'),
  @JsonValue('german')
  german('dd.MM.yyyy'),
}

enum TimeFormatPreference(final String pattern) {
  @JsonValue('h24')
  h24('HH:mm'),
  @JsonValue('h12')
  h12('h:mm a'),
}

@JsonSerializable()
class StudyUUser({
  @JsonKey(name: 'id') required var String id,
  @JsonKey(name: 'email') required var String email,
  Preferences? preferences,
}) extends SupabaseObjectFunctions<StudyUUser> {
  static const String tableName = 'user';

  @override
  Map<String, Object> get primaryKeys => {'id': id};

  @JsonKey(name: 'preferences')
  Preferences preferences = preferences ?? Preferences();

  factory fromJson(Map<String, dynamic> json) => _$StudyUUserFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StudyUUserToJson(this);
}

@JsonSerializable()
class Preferences({
  @JsonKey(name: 'lang') var String language = '',
  @JsonKey(name: 'date_format') var DateFormatPreference? dateFormat,
  @JsonKey(name: 'time_format') var TimeFormatPreference? timeFormat,
  @JsonKey(name: 'pinned_studies') var Set<String> pinnedStudies = const {},
  @JsonKey(name: 'study_filtering')
  var Map<String, dynamic> studyFiltering = const {},
}) {
  // todo store preferred user language in database
  factory fromJson(Map<String, dynamic> json) => _$PreferencesFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$PreferencesToJson(this);
    // Remove empty fields from the JSON map
    json.removeWhere(
      (key, value) =>
          value == null ||
          value is String && value.isEmpty ||
          value is Set && value.isEmpty,
    );
    return json;
  }
}

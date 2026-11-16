import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase/supabase.dart';

part 'survey_template.g.dart';

/// Where a template originates from.
enum SurveyTemplateSource() {
  /// System-provided preset (FFQ, DHQ3, etc.)
  builtIn,

  /// Created by a researcher and saved for reuse.
  user;

  String toJson() => name;

  static SurveyTemplateSource fromJson(String json) => values.byName(json);
}

/// A descriptor for a survey template that researchers can apply to studies.
///
/// Sharing model mirrors [Study]:
/// - [userId] + [collaboratorEmails] for ownership/access
/// - [sharing] ([ResultSharing]) for data visibility
/// - [registryPublished] for public listing in the template registry
@JsonSerializable()
class SurveyTemplate({
  required final String id,
  required var String title,
  required var String description,

  /// Whether this is a built-in preset or a user-created template.
  final SurveyTemplateSource source = SurveyTemplateSource.builtIn,

  /// Visibility setting — reuses the existing [ResultSharing] enum.
  var ResultSharing sharing = ResultSharing.public,

  /// Whether this template is listed in the public template registry.
  @JsonKey(name: 'registry_published', defaultValue: false)
  var bool registryPublished = false,

  /// Owner of the template. Null for [SurveyTemplateSource.builtIn].
  @JsonKey(name: 'user_id') var String? userId,

  /// Emails of collaborators who can view/edit this template.
  @JsonKey(name: 'collaborator_emails', defaultValue: [])
  var List<String> collaboratorEmails = const [],
  @JsonKey(defaultValue: []) var List<String> tags = const [],

  /// Factory that creates a fresh [QuestionnaireTask].
  /// Used by built-in templates; excluded from serialization.
  @JsonKey(includeToJson: false, includeFromJson: false)
  final QuestionnaireTask Function()? createTask,

  /// Serialized task JSON for user-created templates.
  @JsonKey(name: 'task_json') var Map<String, dynamic>? taskJson,

  /// For multi-day templates (e.g. DHQ3 14-day), individual day entries.
  /// Excluded from auto-serialization; built-in day entries use factories.
  @JsonKey(name: 'day_entries') final List<SurveyTemplateDayEntry>? dayEntries,

  /// When the template was first created.
  @JsonKey(name: 'created_at') var DateTime? createdAt,

  /// When the template was last updated.
  @JsonKey(name: 'updated_at') var DateTime? updatedAt,
}) {
  factory fromJson(Map<String, dynamic> json) => _$SurveyTemplateFromJson(json);

  // --- Source & Sharing (aligned with Study) ---

  // --- Task content ---

  // --- Computed properties ---

  /// Whether this template has expandable day entries.
  bool get isMultiDay => dayEntries != null && dayEntries!.isNotEmpty;

  /// Whether this is a built-in system template.
  bool get isBuiltIn => source == SurveyTemplateSource.builtIn;

  /// Whether this is a user-created template.
  bool get isUserCreated => source == SurveyTemplateSource.user;

  // --- Permission helpers (mirror Study) ---

  /// Whether the given [user] is the owner of this template.
  bool isOwner(User? user) => user != null && userId == user.id;

  /// Whether the given [user] is a collaborator on this template.
  bool isEditor(User? user) =>
      user != null && collaboratorEmails.contains(user.email);

  /// Whether the given [user] can edit this template.
  bool canEdit(User? user) => !isBuiltIn && (isOwner(user) || isEditor(user));

  // --- Task creation ---

  /// Creates a [QuestionnaireTask] from this template.
  /// For built-in templates, uses [createTask] factory.
  /// For user templates, deserializes from [taskJson].
  QuestionnaireTask buildTask() {
    if (createTask != null) {
      return createTask!();
    }
    if (taskJson != null) {
      return QuestionnaireTask.fromJson(taskJson!);
    }
    throw StateError(
      'SurveyTemplate "$title" has neither createTask nor taskJson',
    );
  }

  Map<String, dynamic> toJson() => _$SurveyTemplateToJson(this);
}

/// A single day/section entry within a multi-day survey template.
@JsonSerializable()
class SurveyTemplateDayEntry({
  @JsonKey(name: 'day_index') required final int dayIndex,
  required final String title,

  /// Factory for built-in templates; excluded from serialization.
  @JsonKey(includeToJson: false, includeFromJson: false)
  final QuestionnaireTask Function(int dayIndex)? createTask,

  /// Serialized task JSON for user-created templates.
  @JsonKey(name: 'task_json') var Map<String, dynamic>? taskJson,
}) {
  factory fromJson(Map<String, dynamic> json) =>
      _$SurveyTemplateDayEntryFromJson(json);

  /// Creates a [QuestionnaireTask] from this entry.
  QuestionnaireTask buildTask() {
    if (createTask != null) {
      return createTask!(dayIndex);
    }
    if (taskJson != null) {
      return QuestionnaireTask.fromJson(taskJson!);
    }
    throw StateError(
      'SurveyTemplateDayEntry "$title" has neither createTask nor taskJson',
    );
  }

  Map<String, dynamic> toJson() => _$SurveyTemplateDayEntryToJson(this);
}

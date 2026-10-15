import 'package:studyu_core/core.dart';

/// Abstract interface for fetching and managing survey templates.
///
/// Implementations can source templates from different backends:
/// - [BuiltInSurveyTemplateRepository]: static system presets
/// - Future: SupabaseSurveyTemplateRepository for user-created/shared templates
abstract class SurveyTemplateRepository() {
  /// Get all available templates, optionally filtered by [source].
  Future<List<SurveyTemplate>> getTemplates({SurveyTemplateSource? source});

  /// Save a user-created template. Returns the saved template.
  Future<SurveyTemplate> saveTemplate(SurveyTemplate template);

  /// Delete a template by its [id].
  Future<void> deleteTemplate(String id);
}

/// Repository that returns only the built-in system templates.
/// Save and delete operations are not supported.
class BuiltInSurveyTemplateRepository() implements SurveyTemplateRepository {
  @override
  Future<List<SurveyTemplate>> getTemplates({
    SurveyTemplateSource? source,
  }) async {
    final all = SurveyTemplateRegistry.templates;
    if (source == null) return all;
    return all.where((t) => t.source == source).toList();
  }

  @override
  Future<SurveyTemplate> saveTemplate(SurveyTemplate template) {
    throw UnsupportedError(
      'Built-in template repository does not support saving templates',
    );
  }

  @override
  Future<void> deleteTemplate(String id) {
    throw UnsupportedError(
      'Built-in template repository does not support deleting templates',
    );
  }
}

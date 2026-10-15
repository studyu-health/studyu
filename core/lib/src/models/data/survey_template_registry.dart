import 'package:studyu_core/core.dart';

/// Static registry of all built-in survey templates.
///
/// This class holds system-provided presets only. User-created templates
/// are managed by a [SurveyTemplateRepository] implementation.
class SurveyTemplateRegistry._() {
  static final List<SurveyTemplate> templates = [
    _ffqTemplate(),
    _dhq3Template(),
  ];

  /// Find a built-in template by its ID.
  static SurveyTemplate? findById(String id) {
    for (final t in templates) {
      if (t.id == id) return t;
    }
    return null;
  }

  // --- Built-in Templates ---

  static SurveyTemplate _ffqTemplate() {
    return SurveyTemplate(
      id: 'ffq_26',
      title: 'Food Frequency Questionnaire (FFQ)',
      description:
          'Standardized 26-question dietary assessment covering food groups, '
          'beverages, and eating habits over the past year.',
      registryPublished: true,
      tags: ['nutrition', 'dietary', 'ffq'],
      createTask: FFQQuestions.createFFQTask,
    );
  }

  static SurveyTemplate _dhq3Template() {
    return SurveyTemplate(
      id: 'dhq3_14day',
      title: 'DHQ3 14-Day Diet History',
      description:
          'Comprehensive diet history questionnaire split across 14 daily '
          'surveys. Each day covers a different food/beverage category.',
      registryPublished: true,
      tags: ['nutrition', 'dietary', 'dhq3'],
      createTask: () => FFQQuestions.createFFQTaskForDay(0),
      dayEntries: List.generate(
        Dhq3Questions.surveyTitles.length,
        (i) => SurveyTemplateDayEntry(
          dayIndex: i,
          title: Dhq3Questions.surveyTitles[i],
          createTask: FFQQuestions.createFFQTaskForDay,
        ),
      ),
    );
  }
}

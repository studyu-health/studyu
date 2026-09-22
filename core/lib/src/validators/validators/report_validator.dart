import 'package:studyu_core/src/models/data/data_reference.dart';
import 'package:studyu_core/src/models/observations/tasks/questionnaire_task.dart';
import 'package:studyu_core/src/models/report/report_section.dart';
import 'package:studyu_core/src/models/report/sections/average_section.dart';
import 'package:studyu_core/src/models/report/sections/descriptive_stats_section.dart';
import 'package:studyu_core/src/models/report/sections/gauge_comparison_section.dart';
import 'package:studyu_core/src/models/report/sections/linear_regression_section.dart';
import 'package:studyu_core/src/models/report/sections/textual_summary_section.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

DataReference<dynamic>? _extractResultProperty(ReportSection section) {
  if (section is AverageSection) return section.resultProperty;
  if (section is LinearRegressionSection) return section.resultProperty;
  if (section is DescriptiveStatsSection) return section.resultProperty;
  if (section is GaugeComparisonSection) return section.resultProperty;
  if (section is TextualSummarySection) return section.resultProperty;
  return null;
}

bool _sectionHasResultPropertyField(ReportSection section) {
  return section is AverageSection ||
      section is LinearRegressionSection ||
      section is DescriptiveStatsSection ||
      section is GaugeComparisonSection ||
      section is TextualSummarySection;
}

ValidationResult _validateSection(
  ReportSection section,
  String path,
  Study study,
) {
  final errors = <ValidationError>[];

  // Fact 25 — section types that carry resultProperty must have it set
  if (_sectionHasResultPropertyField(section)) {
    final ref = _extractResultProperty(section);
    if (ref == null) {
      errors.add(
        ValidationError(
          code: 'report.missing_result_property',
          path: '$path.resultProperty',
          message: 'Report section has no resultProperty set',
          fixHint: 'Set resultProperty in the report section configuration.',
        ),
      );
      return ValidationResult(errors: errors, warnings: []);
    }

    // Fact 26 — resolve ref.task against observations AND intervention tasks
    final allTaskIds = {
      ...study.observations.map((o) => o.id),
      ...study.interventions.expand((iv) => iv.tasks.map((t) => t.id)),
    };

    if (!allTaskIds.contains(ref.task)) {
      errors.add(
        ValidationError(
          code: 'report.task_reference_missing',
          path: '$path.resultProperty.task',
          message:
              'Report section references task "${ref.task}" which does not exist in observations or intervention tasks',
          fixHint: 'Set resultProperty.task to an existing observation or intervention task id.',
        ),
      );
      return ValidationResult(errors: errors, warnings: []);
    }

    // Check property reference within QuestionnaireTask observations
    QuestionnaireTask? observation;
    for (final obs in study.observations) {
      if (obs is QuestionnaireTask && obs.id == ref.task) {
        observation = obs;
        break;
      }
    }

    if (observation != null) {
      final questionExists = observation.questions.questions.any(
        (q) => q.id == ref.property,
      );
      if (!questionExists) {
        errors.add(
          ValidationError(
            code: 'report.property_reference_missing',
            path: '$path.resultProperty.property',
            message:
                'Report section references question "${ref.property}" which does not exist in observation "${ref.task}"',
            fixHint: 'Set resultProperty.property to a question id within that observation',
          ),
        );
      }
    }
  }

  return ValidationResult(errors: errors, warnings: []);
}

ValidationResult validateReport(Study study, ValidationLevel level) {
  final sections = [
    if (study.reportSpecification.primary != null)
      study.reportSpecification.primary!,
    ...study.reportSpecification.secondary,
  ];

  final results = <ValidationResult>[];
  int secondaryIdx = 0;
  for (var i = 0; i < sections.length; i++) {
    final section = sections[i];
    final isPrimary = study.reportSpecification.primary == section;
    final path = isPrimary
        ? r'$.report_specification.primary'
        : r'$.report_specification.secondary' + '[${secondaryIdx++}]';
    results.add(_validateSection(section, path, study));
  }

  return ValidationResult.merge(results);
}

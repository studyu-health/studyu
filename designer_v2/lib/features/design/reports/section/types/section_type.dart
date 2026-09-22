import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

enum ReportSectionType() {
  average,
  linearRegression,
  textualSummary,
  gaugeComparison,
  descriptiveStats;

  static ReportSectionType of(ReportSection reportSection) {
    final typeMapping = {
      AverageSection.sectionType: ReportSectionType.average,
      LinearRegressionSection.sectionType: ReportSectionType.linearRegression,
      TextualSummarySection.sectionType: ReportSectionType.textualSummary,
      GaugeComparisonSection.sectionType: ReportSectionType.gaugeComparison,
      DescriptiveStatsSection.sectionType: ReportSectionType.descriptiveStats,
    };
    if (!typeMapping.containsKey(reportSection.type)) {
      throw UnimplementedError(
        "Missing ReportSectionType for reportSection of type: ${reportSection.type}",
      );
    }
    return typeMapping[reportSection.type]!;
  }

  String get string {
    switch (this) {
      case ReportSectionType.average:
        return tr.reportSection_type_average;
      case ReportSectionType.linearRegression:
        return tr.reportSection_type_linearRegression;
      case ReportSectionType.textualSummary:
        return tr.reportSection_type_textual_summary;
      case ReportSectionType.gaugeComparison:
        return tr.reportSection_type_gauge_comparison;
      case ReportSectionType.descriptiveStats:
        return tr.reportSection_type_descriptive_statistics;
    }
  }

  IconData? get icon {
    switch (this) {
      case ReportSectionType.average:
        return Icons.functions_rounded;
      case ReportSectionType.linearRegression:
        return Icons.insights_rounded;
      case ReportSectionType.textualSummary:
        return Icons.text_snippet_rounded;
      case ReportSectionType.gaugeComparison:
        return Icons.speed_rounded;
      case ReportSectionType.descriptiveStats:
        return Icons.stacked_line_chart_rounded;
    }
  }

  String toJson() => name;
  static ReportSectionType fromJson(String json) => values.byName(json);
}

// toJson and fromJson do not work on extensions to be used with jsonEncode.
// This is the reason for why the enums are encapsulated.
// todo make generic
class const TemporalAggregationFormatted(final TemporalAggregation _value) {
  static List<TemporalAggregationFormatted> get values => TemporalAggregation
      .values
      .map((e) => TemporalAggregationFormatted(e))
      .toList();
  TemporalAggregation get value => TemporalAggregation.values.byName(toJson());

  String get string {
    switch (value) {
      case TemporalAggregation.day:
        return tr.reportSection_type_temporalAggregation_day;
      case TemporalAggregation.phase:
        return tr.reportSection_type_temporalAggregation_phase;
      case TemporalAggregation.intervention:
        return tr.reportSection_type_temporalAggregation_intervention;
    }
  }

  IconData? get icon {
    switch (value) {
      case TemporalAggregation.day:
        return Icons.calendar_month_rounded;
      case TemporalAggregation.phase:
        return Icons.fast_forward_rounded;
      case TemporalAggregation.intervention:
        return Icons.task_alt_rounded;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemporalAggregationFormatted && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => toJson();

  String toJson() => _value.name;
  TemporalAggregationFormatted fromJson(String json) =>
      TemporalAggregationFormatted(TemporalAggregation.values.byName(json));
}

class const ImprovementDirectionFormatted(final ImprovementDirection _value) {
  static List<ImprovementDirectionFormatted> get values => ImprovementDirection
      .values
      .map((e) => ImprovementDirectionFormatted(e))
      .toList();
  ImprovementDirection get value =>
      ImprovementDirection.values.byName(toJson());

  String get string {
    switch (value) {
      case ImprovementDirection.positive:
        return tr.reportSection_type_improvementDirection_positive;
      case ImprovementDirection.negative:
        return tr.reportSection_type_improvementDirection_negative;
    }
  }

  IconData? get icon {
    switch (value) {
      case ImprovementDirection.positive:
        return Icons.arrow_upward_rounded;
      case ImprovementDirection.negative:
        return Icons.arrow_downward_rounded;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImprovementDirectionFormatted && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => toJson();

  String toJson() => _value.name;
  ImprovementDirectionFormatted fromJson(String json) =>
      ImprovementDirectionFormatted(ImprovementDirection.values.byName(json));
}

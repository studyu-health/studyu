import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'gauge_comparison_section.g.dart';

@JsonSerializable()
class GaugeComparisonSection extends ReportSection {
  static const String sectionType = 'gauge_comparison';

  DataReference<num>? resultProperty;

  new() : super(sectionType);

  new withId() : super.withId(sectionType);

  factory fromJson(Map<String, dynamic> json) =>
      _$GaugeComparisonSectionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GaugeComparisonSectionToJson(this);
}

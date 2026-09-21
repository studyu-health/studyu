import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'descriptive_stats_section.g.dart';

@JsonSerializable()
class DescriptiveStatsSection extends ReportSection {
  static const String sectionType = 'descriptive_stats';

  DataReference<num>? resultProperty;

  new() : super(sectionType);

  new withId() : super.withId(sectionType);

  factory fromJson(Map<String, dynamic> json) =>
      _$DescriptiveStatsSectionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DescriptiveStatsSectionToJson(this);
}

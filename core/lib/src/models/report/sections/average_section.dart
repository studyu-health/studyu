import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/data/data_reference.dart';
import 'package:studyu_core/src/models/report/report_section.dart';
import 'package:studyu_core/src/models/report/temporal_aggregation.dart';

part 'average_section.g.dart';

@JsonSerializable()
class AverageSection extends ReportSection {
  static const String sectionType = 'average';

  TemporalAggregation? aggregate;
  DataReference<num>? resultProperty;

  new() : super(sectionType);

  new withId() : super.withId(sectionType);

  factory fromJson(Map<String, dynamic> json) => _$AverageSectionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AverageSectionToJson(this);
}

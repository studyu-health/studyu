import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/report/report_section.dart';

part 'report_specification.g.dart';

@JsonSerializable()
class ReportSpecification() {
  ReportSection? primary;
  late List<ReportSection> secondary = [];

  factory fromJson(Map<String, dynamic> json) =>
      _$ReportSpecificationFromJson(json);
  Map<String, dynamic> toJson() => _$ReportSpecificationToJson(this);

  @override
  String toString() {
    return 'ReportSpecification{primary: $primary, secondary: $secondary}';
  }
}

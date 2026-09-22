import 'package:studyu_core/core.dart';
import 'package:uuid/uuid.dart';

typedef SectionParser = ReportSection Function(Map<String, dynamic> data);

abstract class ReportSection {
  static const String keyType = 'type';
  String type;
  late String id;
  String? title;
  String? description;

  new(this.type);

  new withId(this.type) : id = const Uuid().v4();

  factory fromJson(Map<String, dynamic> data) => switch (data[keyType]) {
    AverageSection.sectionType => AverageSection.fromJson(data),
    LinearRegressionSection.sectionType => LinearRegressionSection.fromJson(
      data,
    ),
    TextualSummarySection.sectionType => TextualSummarySection.fromJson(data),
    GaugeComparisonSection.sectionType => GaugeComparisonSection.fromJson(data),
    DescriptiveStatsSection.sectionType => DescriptiveStatsSection.fromJson(
      data,
    ),
    _ => throw UnknownJsonTypeError(data[keyType]),
  };
  Map<String, dynamic> toJson();

  @override
  String toString() => toJson().toString();
}

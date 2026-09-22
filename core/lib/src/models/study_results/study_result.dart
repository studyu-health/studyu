import 'package:studyu_core/src/models/study_results/results/results.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/models/tables/study_subject.dart';
import 'package:studyu_core/src/models/unknown_json_type_error.dart';
import 'package:uuid/uuid.dart';

typedef StudyResultParser = StudyResult Function(Map<String, dynamic> json);

abstract class StudyResult {
  static const String keyType = 'type';
  String type;

  late String id;
  String filename = 'results.csv';

  new(this.type);

  new withId(this.type) : id = const Uuid().v4();

  factory fromJson(Map<String, dynamic> data) => switch (data[keyType]) {
    InterventionResult.studyResultType => InterventionResult.fromJson(data),
    NumericResult.studyResultType => NumericResult.fromJson(data),
    _ => throw UnknownJsonTypeError(data[keyType]),
  };

  Map<String, dynamic> toJson();

  List<String> getHeaders(Study studySpec);

  List<dynamic> getValues(StudySubject subject);
}

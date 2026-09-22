import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/study_results/study_result.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/models/tables/study_subject.dart';

part 'intervention_result.g.dart';

@JsonSerializable()
class InterventionResult extends StudyResult {
  static const String studyResultType = 'intervention';

  new() : super(studyResultType);

  new withId() : super.withId(studyResultType);

  factory fromJson(Map<String, dynamic> json) =>
      _$InterventionResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$InterventionResultToJson(this);

  @override
  List<String> getHeaders(Study studySpec) {
    final schedule = studySpec.schedule;
    final numberOfDays = schedule.getNumberOfPhases() * schedule.phaseDuration;
    return Iterable<int>.generate(numberOfDays)
        .map((e) => e.toString())
        .toList();
  }

  @override
  List getValues(StudySubject subject) {
    return subject.interventionOrder
        .expand(
          (intervention) => List<String>.filled(
            subject.study.schedule.phaseDuration,
            intervention,
          ),
        )
        .toList();
  }
}

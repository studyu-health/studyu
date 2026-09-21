import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/interventions/intervention_task.dart';
import 'package:studyu_core/src/models/tables/subject_progress.dart';
import 'package:studyu_core/src/models/tasks/schedule.dart';

part 'checkmark_task.g.dart';

@JsonSerializable()
class CheckmarkTask extends InterventionTask {
  static const String taskType = 'checkmark';

  new() : super(taskType);

  new withId() : super.withId(taskType);

  factory fromJson(Map<String, dynamic> json) => _$CheckmarkTaskFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CheckmarkTaskToJson(this);

  @override
  Map<DateTime, T> extractPropertyResults<T>(
    String property,
    List<SubjectProgress> sourceResults,
  ) {
    throw ArgumentError(
      "$runtimeType does not have a property named '$property'.",
    );
  }

  @override
  Map<String, Type> getAvailableProperties() => {};

  @override
  String? getHumanReadablePropertyName(String property) => null;
}

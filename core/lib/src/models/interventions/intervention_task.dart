import 'package:studyu_core/src/models/interventions/tasks/checkmark_task.dart';
import 'package:studyu_core/src/models/tasks/task.dart';
import 'package:studyu_core/src/models/unknown_json_type_error.dart';

typedef InterventionTaskParser = InterventionTask Function(
  Map<String, dynamic> data,
);

abstract class InterventionTask extends Task {
  new(super.type);

  new withId(super.type) : super.withId();

  factory fromJson(Map<String, dynamic> data) => switch (data[Task.keyType]) {
    CheckmarkTask.taskType => CheckmarkTask.fromJson(data),
    _ => throw UnknownJsonTypeError(data[Task.keyType]),
  };
}

import 'package:studyu_core/src/models/observations/tasks/tasks.dart';
import 'package:studyu_core/src/models/tasks/task.dart';
import 'package:studyu_core/src/models/unknown_json_type_error.dart';

typedef ObservationTaskParser = Observation Function(Map<String, dynamic> data);

abstract class Observation extends Task {
  new(super.type);

  new withId(super.type) : super.withId();

  factory fromJson(Map<String, dynamic> data) => switch (data[Task.keyType]) {
    QuestionnaireTask.taskType => QuestionnaireTask.fromJson(data),
    _ => throw UnknownJsonTypeError(data[Task.keyType]),
  };
}

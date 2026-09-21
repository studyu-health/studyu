import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/models.dart';

part 'data_reference.g.dart';

@JsonSerializable()
class DataReference<T>(var String task, var String property) {
  factory fromJson(Map<String, dynamic> json) => _$DataReferenceFromJson(json);

  Map<String, dynamic> toJson() => _$DataReferenceToJson(this);

  @override
  String toString() => toJson().toString();

  Map<DateTime, T> retrieveFromResults(StudySubject subject) {
    final Task? sourceTask =
        subject.study.observations.firstWhereOrNull(
          (task) => task.id == this.task,
        ) ??
        subject.selectedInterventions
            .expand((i) => i.tasks)
            .firstWhereOrNull((task) => task.id == this.task);
    if (sourceTask == null) {
      throw ArgumentError("Could not find a task with the id '$task'.");
    }

    final List<SubjectProgress> sourceResults = subject.resultsFor(task);

    return sourceTask.extractPropertyResults<T>(property, sourceResults);
  }
}

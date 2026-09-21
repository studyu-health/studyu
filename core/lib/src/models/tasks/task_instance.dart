import 'package:studyu_core/core.dart';

class TaskInstance(final Task task, final String id) {
  this : assert(task.id != id);

  factory fromInstanceId(
    String taskInstanceId, {
    StudySubject? subject,
    Study? study,
    DateTime? date,
  }) {
    date ??= DateTime.now();
    final Task tempTask;
    if (subject != null) {
      tempTask = _taskFromSubject(taskInstanceId, subject, date);
    } else if (study != null) {
      tempTask = _taskFromStudy(taskInstanceId, study, date);
    } else {
      throw "Either subject or study need to be given to create TaskInstance";
    }
    assert(tempTask.id != taskInstanceId);
    return TaskInstance(tempTask, taskInstanceId);
  }

  static Task _taskFromStudy(
    String taskInstanceId,
    Study study,
    DateTime date,
  ) {
    final tasks = <Task>[
      ...study.observations,
      ...study.interventions
          .map((intervention) => intervention.tasks)
          .expand((element) => element),
    ];
    return tasks.firstWhere((task) {
      if (task.schedule.completionPeriods.any(
        (completionPeriod) => completionPeriod.id == taskInstanceId,
      )) {
        return true;
      }
      return false;
    });
  }

  static Task _taskFromSubject(
    String taskInstanceId,
    StudySubject subject,
    DateTime now,
  ) {
    return subject
        .scheduleFor(now)
        .firstWhere((element) => element.id == taskInstanceId)
        .task;
  }

  CompletionPeriod get completionPeriod =>
      task.schedule.completionPeriods.firstWhere((element) => element.id == id);
}

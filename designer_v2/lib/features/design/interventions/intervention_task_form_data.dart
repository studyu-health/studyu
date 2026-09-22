import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/domain/task.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class InterventionTaskFormData({
  required final TaskID taskId,
  required final String taskTitle,
  final String? taskDescription,
  required super.isTimeLocked,
  super.timeLockStart,
  super.timeLockEnd,
  required super.hasReminder,
  super.reminderTime,
  required super.instanceId,
}) extends IFormDataWithSchedule {
  static String get kDefaultTitle => tr.form_field_intervention_task_default;

  @override
  String get id => taskId;

  factory fromDomainModel(CheckmarkTask task) {
    return InterventionTaskFormData(
      taskId: task.id,
      taskTitle: task.title ?? '',
      taskDescription: task.header, // TODO figure out header vs footer here
      isTimeLocked: task.schedule.isTimeRestricted,
      timeLockStart: task.schedule.restrictedTimeStart,
      timeLockEnd: task.schedule.restrictedTimeEnd,
      hasReminder: task.schedule.hasReminder,
      reminderTime: task.schedule.reminderTime,
      instanceId: task.schedule.instanceId,
    );
  }

  CheckmarkTask toTask() {
    final task = CheckmarkTask();
    task.id = taskId;
    task.title = taskTitle;
    task.header = taskDescription; // TODO figure out header vs footer here
    task.schedule = toSchedule();
    return task;
  }

  @override
  InterventionTaskFormData copy() {
    return InterventionTaskFormData(
      taskId: const Uuid().v4(), // always regenerate id
      instanceId: const Uuid().v4(), // always regenerate id
      taskTitle: taskTitle.withDuplicateLabel(),
      taskDescription: taskDescription,
      isTimeLocked: isTimeLocked,
      timeLockStart: timeLockStart,
      timeLockEnd: timeLockEnd,
      hasReminder: hasReminder,
      reminderTime: reminderTime,
    );
  }
}

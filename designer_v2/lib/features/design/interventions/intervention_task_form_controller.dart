import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/task.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:uuid/uuid.dart';

class InterventionTaskFormViewModel({
  super.formData,
  super.delegate,
  super.validationSet = StudyFormValidationSet.draft,
}) extends ManagedFormViewModel<InterventionTaskFormData>
    with WithScheduleControls {
  this {
    runAsync(
      () => markAsCompletedControl.markAsDisabled(),
    ); // TODO not yet supported
  }

  // - Form fields

  final FormControl<TaskID> taskIdControl = FormControl(
    value: const Uuid().v4(),
  ); // hidden
  final FormControl<InstanceID> instanceIdControl = FormControl(
    value: const Uuid().v4(),
  ); // hidden
  final FormControl<String> taskTitleControl = FormControl(
    value: InterventionTaskFormData.kDefaultTitle,
  );
  final FormControl<String> taskDescriptionControl = FormControl();
  final FormControl<bool> markAsCompletedControl = FormControl(value: true);

  TaskID get taskId => taskIdControl.value!;
  TaskID get instanceId => instanceIdControl.value!;

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: [titleRequired],
    StudyFormValidationSet.publish: [titleRequired],
    StudyFormValidationSet.test: [titleRequired],
  };

  @override
  late final FormGroup form = FormGroup({
    'taskId': taskIdControl, // hidden
    'taskTitle': taskTitleControl,
    'taskDescription': taskDescriptionControl,
    'markAsCompleted': markAsCompletedControl,
    ...scheduleFormControls,
  });

  FormControlValidation get titleRequired => FormControlValidation(
    control: taskTitleControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (error) =>
          tr.form_field_intervention_task_title_required,
    },
  );

  @override
  void setControlsFrom(InterventionTaskFormData data) {
    taskIdControl.value = data.taskId;
    taskTitleControl.value = data.taskTitle;
    taskDescriptionControl.value = data.taskDescription;
    setScheduleControlsFrom(data);
  }

  @override
  InterventionTaskFormData buildFormData() {
    return InterventionTaskFormData(
      taskId: taskId,
      instanceId: instanceId,
      taskTitle: taskTitleControl.value!, // required
      taskDescription: taskDescriptionControl.value,
      isTimeLocked: isTimeRestrictedControl.value!, // required
      timeLockStart: restrictedTimeStartControl.value?.toStudyUTimeOfDay(),
      timeLockEnd: restrictedTimeEndControl.value?.toStudyUTimeOfDay(),
      hasReminder: hasReminderControl.value!, // required
      reminderTime: reminderTimeControl.value?.toStudyUTimeOfDay(),
    );
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: tr.form_intervention_task_create,
    FormMode.edit: tr.form_intervention_task_edit,
    FormMode.readonly: tr.form_intervention_task_readonly,
  };

  // - ManagedFormViewModel

  @override
  InterventionTaskFormViewModel createDuplicate() {
    return InterventionTaskFormViewModel(
      delegate: delegate,
      formData: formData?.copy(),
      validationSet: validationSet,
    );
  }
}

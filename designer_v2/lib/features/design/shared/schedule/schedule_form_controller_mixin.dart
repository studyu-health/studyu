import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/time_of_day.dart';

mixin WithScheduleControls {
  final FormControl<bool> isTimeRestrictedControl = FormControl(
    validators: [Validators.required],
    value: false,
  );
  final FormControl<String> instanceID = FormControl();
  final FormControl<Time> restrictedTimeStartControl = FormControl(
    value: const Time(hour: 0, minute: 0),
  );
  final FormControl<TimeOfDay> restrictedTimeStartPickerControl = FormControl();
  final FormControl<Time> restrictedTimeEndControl = FormControl(
    value: const Time(hour: 23, minute: 59),
  );
  final FormControl<TimeOfDay> restrictedTimeEndPickerControl = FormControl();

  final FormControl<bool> hasReminderControl = FormControl(
    validators: [Validators.required],
    value: false,
  );
  final FormControl<Time> reminderTimeControl = FormControl();
  final FormControl<TimeOfDay> reminderTimePickerControl = FormControl();

  late final Validator scheduleValidator = _ScheduleTimeValidator(this);

  bool get hasReminder => hasReminderControl.value!;
  bool get isTimeRestricted => isTimeRestrictedControl.value!;

  List<Time>? get timeRestriction =>
      (isTimeRestricted &&
          restrictedTimeStartControl.value != null &&
          restrictedTimeEndControl.value != null)
      ? [restrictedTimeStartControl.value!, restrictedTimeEndControl.value!]
      : null;

  StreamSubscription? _reminderControlStream;

  late final scheduleFormControls = {
    'isTimeRestricted': isTimeRestrictedControl,
    'restrictedTimeStart': restrictedTimeStartControl,
    'restrictedTimeEnd': restrictedTimeEndControl,
    'hasReminder': hasReminderControl,
    'reminderTime': reminderTimeControl,
  };

  void setScheduleControlsFrom(IFormDataWithSchedule data) {
    isTimeRestrictedControl.value = data.isTimeLocked;
    restrictedTimeStartControl.value = data.timeLockStart?.toTime();
    restrictedTimeEndControl.value = data.timeLockEnd?.toTime();
    hasReminderControl.value = data.hasReminder;
    reminderTimeControl.value = data.reminderTime?.toTime();
    _initReminderControl();
  }

  void _initReminderControl() {
    _reminderControlStream?.cancel();
    _reminderControlStream = hasReminderControl.valueChanges.listen((
      hasReminder,
    ) {
      if (hasReminder != null && !hasReminder) {
        reminderTimeControl.markAsDisabled();
      } else {
        reminderTimeControl.markAsEnabled();
      }
    });
  }
}

class _ScheduleTimeValidator(final WithScheduleControls controls)
    extends Validator<dynamic> {
  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    _requireTime(controls.reminderTimeControl, controls.hasReminder);
    _requireTime(
      controls.restrictedTimeStartControl,
      controls.isTimeRestricted,
    );
    _requireTime(controls.restrictedTimeEndControl, controls.isTimeRestricted);
    return null;
  }

  void _requireTime(FormControl<Time> control, bool required) {
    control.validationMessages = {
      ...control.validationMessages,
      ValidationMessage.required: (_) => tr.form_field_time_of_day_invalid,
    };
    if (required && control.enabled && control.value == null) {
      if (!control.hasError(ValidationMessage.required)) {
        control.setErrors({
          ...control.errors,
          ValidationMessage.required: true,
        }, markAsDirty: false);
      }
    } else if (control.hasError(ValidationMessage.required)) {
      control.removeError(ValidationMessage.required);
    }
  }
}

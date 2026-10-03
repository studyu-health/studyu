import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
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

  bool get hasReminder => hasReminderControl.value!;
  bool get isTimeRestricted => isTimeRestrictedControl.value!;

  List<Time>? get timeRestriction =>
      (isTimeRestricted &&
          restrictedTimeStartControl.value != null &&
          restrictedTimeEndControl.value != null)
      ? [restrictedTimeStartControl.value!, restrictedTimeEndControl.value!]
      : null;

  StreamSubscription? _reminderControlStream;
  bool _timePickerSynchronizationInitialized = false;

  late final scheduleFormControls = {
    'isTimeRestricted': isTimeRestrictedControl,
    'restrictedTimeStart': restrictedTimeStartControl,
    'restrictedTimeEnd': restrictedTimeEndControl,
    'hasReminder': hasReminderControl,
    'reminderTime': reminderTimeControl,
  };

  void ensureTimePickerSynchronization() {
    if (_timePickerSynchronizationInitialized) return;
    _timePickerSynchronizationInitialized = true;

    reminderTimePickerControl.valueChanges.listen((value) {
      if (value != null) reminderTimeControl.value = Time.fromTimeOfDay(value);
    });
    restrictedTimeStartPickerControl.valueChanges.listen((value) {
      if (value != null) {
        restrictedTimeStartControl.value = Time.fromTimeOfDay(value);
      }
    });
    restrictedTimeEndPickerControl.valueChanges.listen((value) {
      if (value != null) {
        restrictedTimeEndControl.value = Time.fromTimeOfDay(value);
      }
    });
  }

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

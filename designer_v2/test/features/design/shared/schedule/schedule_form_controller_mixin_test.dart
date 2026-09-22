import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_controller_mixin.dart';

void main() {
  test('time picker synchronization is initialized only once', () async {
    final controls = _ScheduleControlsHarness();
    var updates = 0;
    final subscription = controls.reminderTimeControl.valueChanges.listen(
      (_) => updates++,
    );
    addTearDown(subscription.cancel);

    controls
      ..ensureTimePickerSynchronization()
      ..ensureTimePickerSynchronization()
      ..ensureTimePickerSynchronization();
    controls.reminderTimePickerControl.value = const TimeOfDay(
      hour: 9,
      minute: 30,
    );
    await Future<void>.delayed(Duration.zero);

    expect(updates, 1);
    expect(controls.reminderTimeControl.value?.hour, 9);
    expect(controls.reminderTimeControl.value?.minute, 30);
  });
}

class _ScheduleControlsHarness() with WithScheduleControls;

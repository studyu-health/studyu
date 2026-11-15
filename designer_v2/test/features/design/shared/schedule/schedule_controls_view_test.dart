import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_controls_view.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/time_of_day.dart';

import '../../../../utils/designer_test_theme.dart';

class _TrackedControl<T>() extends FormControl<T> {
  int activeListeners = 0;

  @override
  Stream<T?> get valueChanges => Stream<T?>.multi((controller) {
    activeListeners++;
    final subscription = super.valueChanges.listen(
      controller.addSync,
      onError: controller.addErrorSync,
      onDone: controller.closeSync,
    );
    controller.onCancel = () {
      activeListeners--;
      subscription.cancel();
    };
  }, isBroadcast: true);
}

class _ScheduleControls() with WithScheduleControls {
  final _trackedPicker = _TrackedControl<TimeOfDay>();

  @override
  _TrackedControl<TimeOfDay> get reminderTimePickerControl => _trackedPicker;
}

Future<_ScheduleControls> pumpSchedule(
  WidgetTester tester, {
  bool restricted = false,
  _ScheduleControls? model,
}) async {
  final controls = model ?? _ScheduleControls();
  controls.hasReminderControl.value = true;
  controls.isTimeRestrictedControl.value = restricted;
  final form = FormGroup(
    controls.scheduleFormControls,
    validators: [controls.scheduleValidator],
  );
  addTearDown(form.dispose);
  addTearDown(controls.reminderTimePickerControl.dispose);
  addTearDown(controls.restrictedTimeStartPickerControl.dispose);
  addTearDown(controls.restrictedTimeEndPickerControl.dispose);
  AppTranslation.setForTesting(lookupAppLocalizations(const Locale('en')));
  await tester.pumpWidget(
    MaterialApp(
      theme: designerTestTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: ReactiveForm(
            formGroup: form,
            child: ScheduleControls(formViewModel: controls),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controls;
}

Future<void> openPicker(WidgetTester tester, int index) async {
  await tester.tap(find.byIcon(Icons.access_time).at(index));
  await tester.pumpAndSettle();
}

Future<void> confirmTime(
  WidgetTester tester,
  String hour,
  String minute,
) async {
  final inputs = find.descendant(
    of: find.byType(TimePickerDialog),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(inputs.at(0), hour);
  await tester.enterText(inputs.at(1), minute);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  expect(find.byType(TimePickerDialog), findsNothing);
}

void main() {
  testWidgets('time edits do not rebuild the scheduling layout', (
    tester,
  ) async {
    final controls = await pumpSchedule(tester);
    final unrelatedField = FormControl<String>();
    (controls.reminderTimeControl.parent! as FormGroup).addAll({
      'unrelated': unrelatedField,
    });
    await tester.pumpAndSettle();
    var layoutBuilds = 0;
    final previousCallback = debugOnRebuildDirtyWidget;
    debugOnRebuildDirtyWidget = (element, builtOnce) {
      previousCallback?.call(element, builtOnce);
      if (element.widget is FormTableLayout) layoutBuilds++;
    };
    addTearDown(() => debugOnRebuildDirtyWidget = previousCallback);

    for (final time in ['0', '06', '060', '0601']) {
      await tester.enterText(find.byType(TextField).first, time);
      await tester.pump();
    }
    unrelatedField.value = 'Updated survey title';
    await tester.pump();

    expect(find.text('06:01'), findsOneWidget);
    expect(layoutBuilds, 0);
  });

  testWidgets('schedule toggles still update the layout', (tester) async {
    final controls = await pumpSchedule(tester);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(controls.isTimeRestricted, isTrue);
    expect(find.byType(TextField), findsNWidgets(3));

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(controls.isTimeRestricted, isFalse);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(controls.hasReminder, isFalse);
    final opacity = tester.widget<Opacity>(
      find
          .ancestor(of: find.byType(TextField), matching: find.byType(Opacity))
          .first,
    );
    expect(opacity.opacity, lessThan(1));
  });

  testWidgets('reminder picker confirms a time when no time is saved', (
    tester,
  ) async {
    final controls = await pumpSchedule(tester);
    expect(controls.reminderTimeControl.value, isNull);
    await openPicker(tester, 0);
    await confirmTime(tester, '14', '35');
    expect(
      controls.reminderTimeControl.value,
      const Time(hour: 14, minute: 35),
    );
    expect(find.text('14:35'), findsOneWidget);
  });

  for (final field in ['reminder', 'restriction start', 'restriction end']) {
    final index = [
      'reminder',
      'restriction start',
      'restriction end',
    ].indexOf(field);

    FormControl<Time> controlFor(_ScheduleControls controls) => switch (index) {
      0 => controls.reminderTimeControl,
      1 => controls.restrictedTimeStartControl,
      _ => controls.restrictedTimeEndControl,
    };

    testWidgets(
      '$field rejects an incomplete time and accepts a picker correction',
      (tester) async {
        final controls = await pumpSchedule(tester, restricted: true);
        controls.reminderTimeControl.value = const Time(hour: 6, minute: 25);
        await tester.pumpAndSettle();
        final control = controlFor(controls);
        await tester.enterText(find.byType(TextField).at(index), '06:');
        await tester.pumpAndSettle();
        expect(control.value, isNull);
        expect(control.invalid, isTrue);
        expect(control.parent!.invalid, isTrue);
        await openPicker(tester, index);
        await confirmTime(tester, '00', '00');
        expect(control.value, const Time(hour: 0, minute: 0));
        expect(control.parent!.valid, isTrue);
      },
    );

    testWidgets('$field rejects times above 23:59', (tester) async {
      final controls = await pumpSchedule(tester, restricted: true);
      final fieldFinder = find.byType(TextField).at(index);
      await tester.enterText(fieldFinder, '15:40');
      await tester.pumpAndSettle();
      for (final invalid in ['24:00', '24:40', '23:60', '2400', '2360']) {
        await tester.enterText(fieldFinder, invalid);
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(fieldFinder).controller!.text, '15:40');
        expect(controlFor(controls).value, const Time(hour: 15, minute: 40));
      }
      await tester.enterText(fieldFinder, '23:59');
      await tester.pumpAndSettle();
      expect(controlFor(controls).value, const Time(hour: 23, minute: 59));
      await tester.enterText(fieldFinder, '00:00');
      await tester.pumpAndSettle();
      expect(controlFor(controls).value, const Time(hour: 0, minute: 0));
    });

    testWidgets('$field picker starts at the saved time', (tester) async {
      final controls = await pumpSchedule(tester, restricted: true);
      controlFor(controls).value = const Time(hour: 6, minute: 25);
      await tester.pumpAndSettle();
      await openPicker(tester, index);
      expect(
        tester
            .widget<TimePickerDialog>(find.byType(TimePickerDialog))
            .initialTime,
        const TimeOfDay(hour: 6, minute: 25),
      );
    });

    testWidgets(
      '$field confirmation applies a previous picker time after typing',
      (tester) async {
        final controls = await pumpSchedule(tester, restricted: true);
        final control = controlFor(controls);
        await openPicker(tester, index);
        await confirmTime(tester, '14', '35');
        expect(control.value, const Time(hour: 14, minute: 35));
        await tester.enterText(find.byType(TextField).at(index), '06:25');
        await tester.pumpAndSettle();
        expect(control.value, const Time(hour: 6, minute: 25));
        await openPicker(tester, index);
        await confirmTime(tester, '14', '35');
        expect(control.value, const Time(hour: 14, minute: 35));
        expect(
          tester
              .widget<TextField>(find.byType(TextField).at(index))
              .controller!
              .text,
          '14:35',
        );
      },
    );
  }

  testWidgets('enabled reminder rejects invalid text and accepts correction', (
    tester,
  ) async {
    final controls = await pumpSchedule(tester);
    final form = controls.reminderTimeControl.parent!;
    expect(form.invalid, isTrue);
    await tester.enterText(find.byType(TextField), '06:');
    await tester.pumpAndSettle();
    expect(controls.reminderTimeControl.value, isNull);
    expect(form.invalid, isTrue);
    expect(find.text('Enter a valid time (00:00–23:59).'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '23:59');
    await tester.pumpAndSettle();
    expect(
      controls.reminderTimeControl.value,
      const Time(hour: 23, minute: 59),
    );
    expect(form.valid, isTrue);
    expect(find.text('Enter a valid time (00:00–23:59).'), findsNothing);
  });

  testWidgets('disabled features do not require times', (tester) async {
    final controls = await pumpSchedule(tester, restricted: true);
    final form = controls.reminderTimeControl.parent!;
    controls.restrictedTimeStartControl.value = null;
    controls.restrictedTimeEndControl.value = null;
    await tester.pumpAndSettle();
    expect(controls.reminderTimeControl.invalid, isTrue);
    expect(controls.restrictedTimeStartControl.invalid, isTrue);
    expect(controls.restrictedTimeEndControl.invalid, isTrue);
    controls.hasReminderControl.value = false;
    controls.isTimeRestrictedControl.value = false;
    await tester.pumpAndSettle();
    expect(form.valid, isTrue);
    controls.hasReminderControl.value = true;
    await tester.pumpAndSettle();
    expect(controls.reminderTimeControl.invalid, isTrue);
    expect(controls.restrictedTimeStartControl.valid, isTrue);
    controls.reminderTimeControl.value = const Time(hour: 0, minute: 0);
    await tester.pumpAndSettle();
    expect(form.valid, isTrue);
    controls.isTimeRestrictedControl.value = true;
    await tester.pumpAndSettle();
    expect(controls.restrictedTimeStartControl.invalid, isTrue);
    expect(controls.restrictedTimeEndControl.invalid, isTrue);
  });

  testWidgets('typed time input rejects letters and limits its length', (
    tester,
  ) async {
    await pumpSchedule(tester);
    await tester.enterText(find.byType(TextField), 'ajsd@!*£y');
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    await tester.enterText(find.byType(TextField), '3123123123123123123');
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text.length,
      lessThanOrEqualTo(5),
    );
  });

  testWidgets('typing reminder digits supplies the colon and a valid time', (
    tester,
  ) async {
    final controls = await pumpSchedule(tester);
    await tester.enterText(find.byType(TextField), '0601');
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '06:01',
    );
    expect(controls.reminderTimeControl.value, const Time(hour: 6, minute: 1));
    expect(controls.reminderTimeControl.parent!.valid, isTrue);
    await tester.enterText(find.byType(TextField), '06012');
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '06:01',
    );
    expect(controls.reminderTimeControl.value, const Time(hour: 6, minute: 1));
  });

  testWidgets('editing the form does not accumulate picker listeners', (
    tester,
  ) async {
    final controls = await pumpSchedule(tester);
    final initial = controls.reminderTimePickerControl.activeListeners;
    for (var minute = 0; minute < 10; minute++) {
      controls.reminderTimeControl.value = Time(hour: 6, minute: minute);
      await tester.pumpAndSettle();
    }
    final afterEdits = controls.reminderTimePickerControl.activeListeners;
    expect(afterEdits, initial);
  });

  testWidgets('removing scheduling controls cancels picker listeners', (
    tester,
  ) async {
    final controls = await pumpSchedule(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(controls.reminderTimePickerControl.activeListeners, 0);
  });

  testWidgets('replacing the schedule model disconnects old picker listeners', (
    tester,
  ) async {
    final oldModel = await pumpSchedule(tester);
    oldModel.reminderTimeControl.value = const Time(hour: 7, minute: 15);
    await tester.pumpAndSettle();
    final nextModel = _ScheduleControls();
    await pumpSchedule(tester, model: nextModel);
    expect(oldModel.reminderTimePickerControl.activeListeners, 0);
    oldModel.reminderTimePickerControl.value = const TimeOfDay(
      hour: 21,
      minute: 0,
    );
    await tester.pumpAndSettle();
    expect(oldModel.reminderTimeControl.value, const Time(hour: 7, minute: 15));
    expect(nextModel.reminderTimeControl.value, isNull);
    nextModel.reminderTimePickerControl.value = const TimeOfDay(
      hour: 9,
      minute: 40,
    );
    await tester.pumpAndSettle();
    expect(
      nextModel.reminderTimeControl.value,
      const Time(hour: 9, minute: 40),
    );
  });

  for (final dismissal in ['cancel', 'outside', 'escape']) {
    testWidgets('$dismissal keeps the typed reminder time', (tester) async {
      final controls = await pumpSchedule(tester);
      await tester.enterText(find.byType(TextField), '06:25');
      await tester.pumpAndSettle();
      await openPicker(tester, 0);
      final inputs = find.descendant(
        of: find.byType(TimePickerDialog),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(inputs.at(0), '14');
      switch (dismissal) {
        case 'cancel':
          await tester.tap(find.text('Cancel'));
        case 'outside':
          await tester.tapAt(const Offset(5, 5));
        case 'escape':
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      }
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsNothing);
      expect(
        controls.reminderTimeControl.value,
        const Time(hour: 6, minute: 25),
      );
      expect(find.text('06:25'), findsOneWidget);
    });
  }
}

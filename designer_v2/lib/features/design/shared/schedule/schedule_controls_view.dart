import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/time_of_day.dart';

class const ScheduleControls({
  required final WithScheduleControls formViewModel,
  super.key,
}) extends StatefulWidget {
  @override
  State<ScheduleControls> createState() => _ScheduleControlsState();
}

class _ScheduleControlsState() extends State<ScheduleControls> {
  final List<StreamSubscription<TimeOfDay?>> _pickerSubscriptions = [];
  WithScheduleControls get formViewModel => widget.formViewModel;

  @override
  void initState() {
    super.initState();
    _bindPickers();
  }

  @override
  void didUpdateWidget(ScheduleControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.formViewModel, formViewModel)) {
      _unbindPickers();
      _bindPickers();
    }
  }

  void _bindPickers() {
    void bind(FormControl<TimeOfDay> picker, FormControl<Time> field) {
      _pickerSubscriptions.add(
        picker.valueChanges.listen((value) {
          if (value != null) field.value = Time.fromTimeOfDay(value);
        }),
      );
    }

    bind(
      formViewModel.reminderTimePickerControl,
      formViewModel.reminderTimeControl,
    );
    bind(
      formViewModel.restrictedTimeStartPickerControl,
      formViewModel.restrictedTimeStartControl,
    );
    bind(
      formViewModel.restrictedTimeEndPickerControl,
      formViewModel.restrictedTimeEndControl,
    );
  }

  void _unbindPickers() {
    for (final subscription in _pickerSubscriptions) {
      subscription.cancel();
    }
    _pickerSubscriptions.clear();
  }

  @override
  void dispose() {
    _unbindPickers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ReactiveValueListenableBuilder<bool>(
    key: ObjectKey(formViewModel),
    formControl: formViewModel.hasReminderControl,
    builder: (context, control, child) => ReactiveValueListenableBuilder<bool>(
      formControl: formViewModel.isTimeRestrictedControl,
      builder: (context, control, child) => _buildControls(context),
    ),
  );

  Widget _buildControls(BuildContext context) {
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionHeader(title: tr.form_section_scheduling),
          const SizedBox(height: 4.0),
          TextParagraph(text: tr.form_section_scheduling_description),
          const SizedBox(height: 16.0),
          FormTableLayout(
            rows: [
              FormTableRow(
                control: formViewModel.hasReminderControl,
                label: tr.form_field_has_reminder,
                labelHelpText: tr.form_field_has_reminder_tooltip,
                input: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ReactiveCheckbox(
                      formControl: formViewModel.hasReminderControl,
                    ),
                    const SizedBox(width: 3.0),
                    FormControlLabel(
                      formControl: formViewModel.hasReminderControl,
                      text: tr.form_field_has_reminder_label,
                    ),
                    const SizedBox(width: 8.0),
                    Opacity(
                      opacity: (formViewModel.hasReminder) ? 1 : 0.5,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IntrinsicWidth(
                            child: PointerInterceptor(
                              child: ReactiveTimePicker(
                                formControl:
                                    formViewModel.reminderTimePickerControl,
                                initialEntryMode: TimePickerEntryMode.input,
                                builder:
                                    (
                                      BuildContext context,
                                      ReactiveTimePickerDelegate picker,
                                      Widget? child,
                                    ) {
                                      return ReactiveTextField<Time>(
                                        formControl:
                                            formViewModel.reminderTimeControl,
                                        valueAccessor: TimeValueAccessor(),
                                        inputFormatters:
                                            TimeValueAccessor.inputFormatters,
                                        keyboardType: TextInputType.datetime,
                                        showErrors: (control) =>
                                            control.invalid,
                                        validationMessages: {
                                          ValidationMessage.required: (_) =>
                                              tr.form_field_time_of_day_invalid,
                                        },
                                        decoration: InputDecoration(
                                          hintText:
                                              tr.form_field_time_of_day_hint,
                                          suffixIcon: Material(
                                            color: Colors.transparent,
                                            child: IconButton(
                                              splashRadius: 18.0,
                                              onPressed: () {
                                                picker.control.updateValue(
                                                  formViewModel
                                                      .reminderTimeControl
                                                      .value,
                                                  emitEvent: false,
                                                );
                                                picker.showPicker();
                                              },
                                              icon: const Icon(
                                                Icons.access_time,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FormTableRow(
                control: formViewModel.isTimeRestrictedControl,
                label: tr.form_field_time_restriction,
                labelHelpText: tr.form_field_time_restriction_tooltip,
                input: ReactiveSwitch(
                  formControl: formViewModel.isTimeRestrictedControl,
                ),
              ),
              ..._conditionalTimeRestrictions(context),
            ],
          ),
        ],
      ),
    );
  }

  List<FormTableRow> _conditionalTimeRestrictions(BuildContext context) {
    if (!formViewModel.isTimeRestricted) {
      return [];
    }
    return [
      FormTableRow(
        control: formViewModel.restrictedTimeStartControl,
        label: " ",
        input: Row(
          children: [
            Flexible(
              child: PointerInterceptor(
                child: ReactiveTimePicker(
                  formControl: formViewModel.restrictedTimeStartPickerControl,
                  initialEntryMode: TimePickerEntryMode.input,
                  builder:
                      (
                        BuildContext context,
                        ReactiveTimePickerDelegate picker,
                        Widget? child,
                      ) {
                        return ReactiveTextField<Time>(
                          formControl: formViewModel.restrictedTimeStartControl,
                          valueAccessor: TimeValueAccessor(),
                          inputFormatters: TimeValueAccessor.inputFormatters,
                          keyboardType: TextInputType.datetime,
                          showErrors: (control) => control.invalid,
                          validationMessages: {
                            ValidationMessage.required: (_) =>
                                tr.form_field_time_of_day_invalid,
                          },
                          decoration:
                              (formViewModel.restrictedTimeStartControl.enabled)
                              ? InputDecoration(
                                  labelText:
                                      tr.form_field_time_restriction_start_hint,
                                  helperText: "",
                                  hintText: tr.form_field_time_of_day_hint,
                                  suffixIcon: Material(
                                    color: Colors.transparent,
                                    child: IconButton(
                                      splashRadius: 18.0,
                                      onPressed: () {
                                        picker.control.updateValue(
                                          formViewModel
                                              .restrictedTimeStartControl
                                              .value,
                                          emitEvent: false,
                                        );
                                        picker.showPicker();
                                      },
                                      icon: const Icon(Icons.access_time),
                                    ),
                                  ),
                                )
                              : const InputDecoration(),
                        );
                      },
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Flexible(
              child: PointerInterceptor(
                child: ReactiveTimePicker(
                  formControl: formViewModel.restrictedTimeEndPickerControl,
                  initialEntryMode: TimePickerEntryMode.input,
                  builder:
                      (
                        BuildContext context,
                        ReactiveTimePickerDelegate picker,
                        Widget? child,
                      ) {
                        return ReactiveTextField<Time>(
                          formControl: formViewModel.restrictedTimeEndControl,
                          valueAccessor: TimeValueAccessor(),
                          inputFormatters: TimeValueAccessor.inputFormatters,
                          keyboardType: TextInputType.datetime,
                          showErrors: (control) => control.invalid,
                          validationMessages: {
                            ValidationMessage.required: (_) =>
                                tr.form_field_time_of_day_invalid,
                          },
                          decoration:
                              (formViewModel.restrictedTimeEndControl.enabled)
                              ? InputDecoration(
                                  labelText:
                                      tr.form_field_time_restriction_end_hint,
                                  helperText: "",
                                  hintText: tr.form_field_time_of_day_hint,
                                  suffixIcon: Material(
                                    color: Colors.transparent,
                                    child: IconButton(
                                      splashRadius: 18.0,
                                      onPressed: () {
                                        picker.control.updateValue(
                                          formViewModel
                                              .restrictedTimeEndControl
                                              .value,
                                          emitEvent: false,
                                        );
                                        picker.showPicker();
                                      },
                                      icon: const Icon(Icons.access_time),
                                    ),
                                  ),
                                )
                              : const InputDecoration(),
                        );
                      },
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

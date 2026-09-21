import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/time_of_day.dart';

class const ScheduleControls({
  required final WithScheduleControls formViewModel,
  super.key,
}) extends FormConsumerWidget {
  @override
  Widget build(BuildContext context, FormGroup form) {
    formViewModel.reminderTimePickerControl.valueChanges.listen((event) {
      formViewModel.reminderTimeControl.value = Time.fromTimeOfDay(
        formViewModel.reminderTimePickerControl.value!,
      );
    });

    formViewModel.restrictedTimeStartPickerControl.valueChanges.listen((event) {
      formViewModel.restrictedTimeStartControl.value = Time.fromTimeOfDay(
        formViewModel.restrictedTimeStartPickerControl.value!,
      );
    });

    formViewModel.restrictedTimeEndPickerControl.valueChanges.listen((event) {
      formViewModel.restrictedTimeEndControl.value = Time.fromTimeOfDay(
        formViewModel.restrictedTimeEndPickerControl.value!,
      );
    });

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
                                        decoration: InputDecoration(
                                          hintText:
                                              tr.form_field_time_of_day_hint,
                                          suffixIcon: Material(
                                            color: Colors.transparent,
                                            child: IconButton(
                                              splashRadius: 18.0,
                                              onPressed: picker.showPicker,
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
                                      onPressed: picker.showPicker,
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
                                      onPressed: picker.showPicker,
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

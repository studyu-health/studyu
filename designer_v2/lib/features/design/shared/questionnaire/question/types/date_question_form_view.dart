import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const DateQuestionFormView({
  required final QuestionFormViewModel formViewModel,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;

    return ReactiveFormConsumer(
      builder: (context, formGroup, child) {
        final inputType =
            formViewModel.dateInputTypeControl.value ?? DateInputType.date;
        final defaultOption =
            formViewModel.dateDefaultOptionControl.value ??
            DefaultDateOption.none;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Input Type
            generateRow(
              label: localizations.date_input_type_label,
              labelHelpText: localizations.date_input_type_label_helper,
              input: ReactiveDropdownField<DateInputType>(
                formControl: formViewModel.dateInputTypeControl,
                items: DateInputType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getInputTypeLabel(type, localizations)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Step 3: Default Value
            generateRow(
              label: localizations.date_default_option_label,
              labelHelpText: localizations.date_default_option_label_helper,
              input: ReactiveDropdownField<DefaultDateOption>(
                formControl: formViewModel.dateDefaultOptionControl,
                items: _getDefaultOptionsForInputType(inputType, localizations)
                    .map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(
                          _getDefaultOptionLabel(option, localizations),
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Step 3b: Specific default date (if specific selected and date-related)
            if (defaultOption == DefaultDateOption.specific &&
                (inputType == DateInputType.date ||
                    inputType == DateInputType.dateTime)) ...[
              generateRow(
                label: localizations.date_default_specific_date_label,
                labelHelpText:
                    localizations.date_default_specific_date_label_helper,
                input: PointerInterceptor(
                  child: ReactiveDatePickerField(
                    formControl: formViewModel.dateDefaultSpecificDateControl,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    placeholder: localizations.date_picker_hint,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],

            // Step 3c: Specific default time (if specific selected and time-related)
            if (defaultOption == DefaultDateOption.specific &&
                (inputType == DateInputType.time ||
                    inputType == DateInputType.dateTime)) ...[
              generateRow(
                label: localizations.date_default_specific_time_label,
                labelHelpText:
                    localizations.date_default_specific_time_label_helper,
                input: ReactiveTimePickerField(
                  formControl: formViewModel.dateDefaultSpecificTimeControl,
                  placeholder: localizations.time_picker_hint,
                ),
              ),
              const SizedBox(height: 16.0),
            ],

            // Step 4: Min/Max constraints
            // Date range (if date or datetime)
            if (inputType == DateInputType.date ||
                inputType == DateInputType.dateTime) ...[
              generateRow(
                label: localizations.date_min_date_label,
                labelHelpText: localizations.date_min_date_label_helper,
                input: PointerInterceptor(
                  child: ReactiveDatePickerField(
                    formControl: formViewModel.dateMinControl,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    placeholder: localizations.date_picker_hint,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              generateRow(
                label: localizations.date_max_date_label,
                labelHelpText: localizations.date_max_date_label_helper,
                input: PointerInterceptor(
                  child: ReactiveDatePickerField(
                    formControl: formViewModel.dateMaxControl,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    placeholder: localizations.date_picker_hint,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],

            // Time range (if time or datetime)
            if (inputType == DateInputType.time ||
                inputType == DateInputType.dateTime) ...[
              generateRow(
                label: localizations.date_min_time_label,
                labelHelpText: localizations.date_min_time_label_helper,
                input: ReactiveTimePickerField(
                  formControl: formViewModel.dateMinTimeControl,
                  placeholder: localizations.time_picker_hint,
                ),
              ),
              const SizedBox(height: 16.0),
              generateRow(
                label: localizations.date_max_time_label,
                labelHelpText: localizations.date_max_time_label_helper,
                input: ReactiveTimePickerField(
                  formControl: formViewModel.dateMaxTimeControl,
                  placeholder: localizations.time_picker_hint,
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ],
        );
      },
    );
  }

  String _getInputTypeLabel(
    DateInputType type,
    AppLocalizations localizations,
  ) {
    switch (type) {
      case DateInputType.date:
        return localizations.date_input_type_date;
      case DateInputType.time:
        return localizations.date_input_type_time;
      case DateInputType.dateTime:
        return localizations.date_input_type_datetime;
    }
  }

  String _getDefaultOptionLabel(
    DefaultDateOption option,
    AppLocalizations localizations,
  ) {
    switch (option) {
      case DefaultDateOption.none:
        return localizations.date_default_option_none;
      case DefaultDateOption.today:
        return localizations.date_default_option_today;
      case DefaultDateOption.now:
        return localizations.date_default_option_now;
      case DefaultDateOption.specific:
        return localizations.date_default_option_specific;
    }
  }

  List<DefaultDateOption> _getDefaultOptionsForInputType(
    DateInputType inputType,
    AppLocalizations localizations,
  ) {
    switch (inputType) {
      case DateInputType.date:
        return [
          DefaultDateOption.none,
          DefaultDateOption.today,
          DefaultDateOption.specific,
        ];
      case DateInputType.time:
        return [
          DefaultDateOption.none,
          DefaultDateOption.now,
          DefaultDateOption.specific,
        ];
      case DateInputType.dateTime:
        return [
          DefaultDateOption.none,
          DefaultDateOption.today,
          DefaultDateOption.now,
          DefaultDateOption.specific,
        ];
    }
  }

  Widget generateRow({
    required String label,
    required String labelHelpText,
    required Widget input,
  }) {
    return Row(
      children: [
        Flexible(
          flex: 5,
          child: FormTableLayout(
            rowLayout: FormTableRowLayout.vertical,
            rows: [
              FormTableRow(
                label: label,
                labelHelpText: labelHelpText,
                input: input,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom reactive date picker field
class const ReactiveDatePickerField({
  required final FormControl<DateTime?> formControl,
  required final DateTime firstDate,
  required final DateTime lastDate,
  final String? placeholder,
  super.key,
}) extends ConsumerWidget {
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = formControl.value ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate)
          ? firstDate
          : initialDate.isAfter(lastDate)
          ? lastDate
          : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) => PointerInterceptor(child: child!),
    );

    if (pickedDate != null) {
      formControl.value = pickedDate;
    }
  }

  String _formatDate(
    BuildContext context,
    DateTime date,
    DateFormatPreference? preference,
  ) {
    return DateTimeFormat.formatDate(context, date, preference: preference);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(userStateProvider).value?.preferences;
    return ReactiveValueListenableBuilder<DateTime?>(
      formControl: formControl,
      builder: (context, control, child) {
        final value = control.value;

        return InkWell(
          onTap: () => _pickDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: placeholder,
              suffixIcon: value != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => formControl.value = null,
                    )
                  : const Icon(Icons.calendar_today),
            ),
            child: value != null
                ? Text(_formatDate(context, value, preference?.dateFormat))
                : Text(
                    placeholder ?? '',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
          ),
        );
      },
    );
  }
}

/// Custom reactive time picker field
class const ReactiveTimePickerField({
  required final FormControl<String?> formControl,
  final String? placeholder,
  super.key,
}) extends ConsumerWidget {
  Future<void> _pickTime(
    BuildContext context,
    TimeFormatPreference? preference,
  ) async {
    final now = TimeOfDay.now();
    final initialTime = formControl.value != null
        ? _parseTime(formControl.value!)
        : now;
    final platformUses24HourFormat = MediaQuery.of(context)
        .alwaysUse24HourFormat;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => PointerInterceptor(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: preference == null
                ? platformUses24HourFormat
                : preference == TimeFormatPreference.h24,
          ),
          child: child!,
        ),
      ),
    );

    if (pickedTime != null) {
      formControl.value =
          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeDisplay(
    BuildContext context,
    String? time,
    TimeFormatPreference? preference,
  ) {
    if (time == null) return '';
    return DateTimeFormat.formatTime(
      context,
      _parseTime(time),
      preference: preference,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(userStateProvider).value?.preferences;
    return ReactiveValueListenableBuilder<String?>(
      formControl: formControl,
      builder: (context, control, child) {
        final value = control.value;

        return InkWell(
          onTap: () => _pickTime(context, preference?.timeFormat),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: placeholder,
              suffixIcon: value != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => formControl.value = null,
                    )
                  : const Icon(Icons.access_time),
            ),
            child: value != null
                ? Text(
                    _formatTimeDisplay(context, value, preference?.timeFormat),
                  )
                : Text(
                    placeholder ?? '',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
          ),
        );
      },
    );
  }
}

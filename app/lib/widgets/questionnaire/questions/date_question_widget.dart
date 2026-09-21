import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/util/date_time_preferences.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const DateQuestionWidget({
  super.key,
  required final DateQuestion question,
  final Function(Answer)? onDone,
  final VoidCallback? onCleared,
  final Answer<DateTime>? initialAnswer,
}) extends QuestionWidget {
  @override
  State<DateQuestionWidget> createState() => _DateQuestionWidgetState();
}

class _DateQuestionWidgetState() extends State<DateQuestionWidget> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
  }

  void _initializeDefaults() {
    final initialValue = widget.initialAnswer?.response;
    final defaultValue = widget.question.getDefaultValue();
    final defaultTime = widget.question.getInitialTimeValue();

    if (initialValue != null) {
      if (widget.question.isDate) {
        _selectedDate = initialValue;
      }
      if (widget.question.isTime) {
        _selectedTime = TimeOfDay(
          hour: initialValue.hour,
          minute: initialValue.minute,
        );
      }
      return;
    }

    if (defaultValue != null && widget.question.isDate) {
      _selectedDate = defaultValue;
    }

    if (defaultTime != null) {
      final parts = defaultTime.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkCompleteAndSubmit();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;
    final firstDate = widget.question.minDate ?? DateTime(1900);
    // Use end of day for maxDate to include the full last day
    final maxDate = widget.question.maxDate;
    final lastDate = maxDate != null
        ? DateTime(maxDate.year, maxDate.month, maxDate.day, 23, 59, 59)
        : DateTime(2100);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate)
          ? firstDate
          : initialDate.isAfter(lastDate)
          ? lastDate
          : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: widget.question.prompt,
    );

    setState(() {
      _hasInteracted = true;
      if (pickedDate != null) _selectedDate = pickedDate;
    });
    if (pickedDate != null) {
      _checkCompleteAndSubmit();
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final initialTime = _selectedTime ?? now;

    final timeFormat = context.read<DateTimePreferences?>()?.timeFormat;
    final use24HourFormat = switch (timeFormat) {
      TimeFormatPreference.h12 => false,
      TimeFormatPreference.h24 => true,
      null => null,
    };
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: widget.question.prompt,
      builder: (context, child) {
        if (use24HourFormat == null) return child!;
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: use24HourFormat),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      // Validate time constraints
      if (!_isTimeValid(pickedTime)) {
        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.time_picker_validation_range)),
          );
        }
        return;
      }

      setState(() {
        _hasInteracted = true;
        _selectedTime = pickedTime;
      });

      // For datetime, if no date selected yet, default to today — but only
      // when today falls within any configured date range.
      if (widget.question.isDateTime && _selectedDate == null) {
        final today = DateTime.now();
        final minDate = widget.question.minDate;
        final maxDate = widget.question.maxDate;
        final todayIsInRange =
            (minDate == null || !today.isBefore(minDate)) &&
            (maxDate == null || !today.isAfter(maxDate));
        if (todayIsInRange) {
          setState(() {
            _selectedDate = today;
          });
        }
      }

      _checkCompleteAndSubmit();
    } else {
      setState(() {
        _hasInteracted = true;
      });
    }
  }

  bool _isTimeValid(TimeOfDay time) {
    if (widget.question.minTime != null) {
      final minParts = widget.question.minTime!.split(':');
      final minHour = int.parse(minParts[0]);
      final minMinute = int.parse(minParts[1]);
      final min = TimeOfDay(hour: minHour, minute: minMinute);

      if (time.hour < min.hour ||
          (time.hour == min.hour && time.minute < min.minute)) {
        return false;
      }
    }

    if (widget.question.maxTime != null) {
      final maxParts = widget.question.maxTime!.split(':');
      final maxHour = int.parse(maxParts[0]);
      final maxMinute = int.parse(maxParts[1]);
      final max = TimeOfDay(hour: maxHour, minute: maxMinute);

      if (time.hour > max.hour ||
          (time.hour == max.hour && time.minute > max.minute)) {
        return false;
      }
    }

    return true;
  }

  bool _isComplete() {
    switch (widget.question.inputType) {
      case DateInputType.date:
        return _selectedDate != null;
      case DateInputType.time:
        return _selectedTime != null;
      case DateInputType.dateTime:
        return _selectedDate != null && _selectedTime != null;
    }
  }

  void _checkCompleteAndSubmit() {
    if (_isComplete()) {
      _handleSubmit();
    }
  }

  void _clear() {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      // Keep _hasInteracted true so validation errors surface immediately
      // if the user tries to submit after clearing a required field.
      _hasInteracted = true;
    });
    widget.onCleared?.call();
  }

  void _handleSubmit() {
    DateTime? result;

    switch (widget.question.inputType) {
      case DateInputType.date:
        if (_selectedDate != null) {
          result = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
          );
        }
      case DateInputType.time:
        if (_selectedTime != null) {
          // Store time as a DateTime on epoch date for consistency
          result = DateTime(
            2000,
            1,
            1,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
        }
      case DateInputType.dateTime:
        if (_selectedDate != null && _selectedTime != null) {
          result = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
        }
    }

    if (result != null) {
      widget.onDone?.call(widget.question.constructAnswer(result));
    }
  }

  String? _getValidationError() {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return null;

    switch (widget.question.inputType) {
      case DateInputType.date:
        if (_selectedDate == null) {
          return localizations.date_picker_validation_required;
        }
      case DateInputType.time:
        if (_selectedTime == null) {
          return localizations.time_picker_validation_required;
        }
      case DateInputType.dateTime:
        if (_selectedDate == null || _selectedTime == null) {
          return localizations.datetime_picker_validation_required;
        }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final dateTimePreferences = context.watch<DateTimePreferences?>();
    final validationError = _hasInteracted ? _getValidationError() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date picker button (if date or datetime)
        if (widget.question.isDate) ...[
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _selectedDate != null
                  ? dateTimePreferences?.formatDate(context, _selectedDate!) ??
                        DateTimeFormat.formatDate(context, _selectedDate!)
                  : (widget.question.isDateTime
                        ? localizations.date_picker_button_label_datetime
                        : localizations.date_picker_button_label),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Time picker button (if time or datetime)
        if (widget.question.isTime) ...[
          OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.access_time),
            label: Text(
              _selectedTime != null
                  ? dateTimePreferences?.formatTime(context, _selectedTime!) ??
                        _selectedTime!.format(context)
                  : (widget.question.isDateTime
                        ? localizations.time_picker_button_label_datetime
                        : localizations.time_picker_button_label),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Validation error message
        if (validationError != null) ...[
          Text(
            validationError,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Time range hint (if time constraints set)
        if (widget.question.minTime != null ||
            widget.question.maxTime != null) ...[
          Text(
            _formatTimeRangeHint(localizations, dateTimePreferences),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
        ],

        // Clear button (only show if value is selected)
        if (_selectedDate != null || _selectedTime != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.clear),
              label: Text(localizations.date_picker_clear),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTimeRangeHint(
    AppLocalizations localizations,
    DateTimePreferences? preferences,
  ) {
    final minTime = widget.question.minTime;
    final maxTime = widget.question.maxTime;
    final formattedMinTime = minTime == null
        ? null
        : _formatTimeValue(minTime, preferences);
    final formattedMaxTime = maxTime == null
        ? null
        : _formatTimeValue(maxTime, preferences);

    if (formattedMinTime != null && formattedMaxTime != null) {
      return localizations.time_picker_range_hint(
        formattedMinTime,
        formattedMaxTime,
      );
    } else if (formattedMinTime != null) {
      return localizations.time_picker_min_hint(formattedMinTime);
    } else if (formattedMaxTime != null) {
      return localizations.time_picker_max_hint(formattedMaxTime);
    }
    return '';
  }

  String _formatTimeValue(String value, DateTimePreferences? preferences) {
    final parts = value.split(':');
    if (parts.length != 2) return value;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return value;

    final time = TimeOfDay(hour: hour, minute: minute);
    return preferences?.formatTime(context, time) ??
        DateTimeFormat.formatTime(context, time);
  }
}

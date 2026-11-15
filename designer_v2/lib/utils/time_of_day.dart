import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/utils/typings.dart';

/// JSON-encodable version of [TimeOfDay]
class Time extends TimeOfDay {
  const new({required super.hour, required super.minute});

  new fromTimeOfDay(TimeOfDay timeOfDay)
    : super(hour: timeOfDay.hour, minute: timeOfDay.minute);

  JsonMap toJson() => {"hour": super.hour, "minute": super.minute};
  Time fromJson(JsonMap json) => Time(
    hour: int.parse(json["hour"].toString()),
    minute: int.parse(json["minute"].toString()),
  );
}

/// Control value accessor that converts between data types [Time] and [String]
class TimeValueAccessor() extends ControlValueAccessor<Time, String> {
  static const inputFormatters = <TextInputFormatter>[_TimeInputFormatter()];
  static final _timePattern = RegExp(r'^[0-9]{1,2}:[0-9]{2}$');
  @override
  String modelToViewValue(Time? modelValue) {
    return modelValue == null
        ? ''
        : '${modelValue.hour}:${_addLeadingZeroIfNeeded(modelValue.minute)}';
  }

  @override
  Time? viewToModelValue(String? viewValue) {
    final text = viewValue?.trim();
    if (text == null || !_timePattern.hasMatch(text)) return null;
    final parts = text.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    if (hour >= TimeOfDay.hoursPerDay || minute >= TimeOfDay.minutesPerHour) {
      return null;
    }
    return Time(hour: hour, minute: minute);
  }

  String _addLeadingZeroIfNeeded(int value) =>
      (value < 10) ? '0$value' : value.toString();
}

class const _TimeInputFormatter() extends TextInputFormatter {
  static const _hourDigits = 2;
  static const _minuteDigits = 2;
  static const _separator = ':';
  static final _allowedCharacters = RegExp(r'^[0-9:]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;
    final text = newValue.text;
    if (!_allowedCharacters.hasMatch(text)) return oldValue;
    if (text.contains(_separator)) {
      final parts = text.split(_separator);
      if (parts.length != 2 ||
          parts.first.length > _hourDigits ||
          parts.last.length > _minuteDigits ||
          !_withinRange(text)) {
        return oldValue;
      }
      return newValue;
    }
    if (text.length > _hourDigits + _minuteDigits) return oldValue;
    final previousSeparator = oldValue.text.indexOf(_separator);
    final removedSeparator =
        previousSeparator >= 0 &&
        oldValue.text.replaceFirst(_separator, '') == text;
    final hourDigits = removedSeparator ? previousSeparator : _hourDigits;
    if (text.length <= hourDigits) {
      return _withinRange(text) ? newValue : oldValue;
    }
    final formatted =
        '${text.substring(0, hourDigits)}'
        '$_separator${text.substring(hourDigits)}';
    if (!_withinRange(formatted)) return oldValue;
    int selectionOffset(int offset) {
      if (offset < 0) return formatted.length;
      return offset > hourDigits ? offset + _separator.length : offset;
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection(
        baseOffset: selectionOffset(newValue.selection.baseOffset),
        extentOffset: selectionOffset(newValue.selection.extentOffset),
        affinity: newValue.selection.affinity,
        isDirectional: newValue.selection.isDirectional,
      ),
      composing: TextRange.empty,
    );
  }

  bool _withinRange(String text) {
    final parts = text.split(_separator);
    final hour = int.tryParse(parts.first);
    final minute = parts.length > 1 ? int.tryParse(parts.last) : null;
    return (hour == null || hour < TimeOfDay.hoursPerDay) &&
        (minute == null || minute < TimeOfDay.minutesPerHour);
  }
}

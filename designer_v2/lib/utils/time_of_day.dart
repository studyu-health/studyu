import 'package:flutter/material.dart';
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
  @override
  String modelToViewValue(Time? modelValue) {
    return modelValue == null
        ? ''
        : '${modelValue.hour}:${_addLeadingZeroIfNeeded(modelValue.minute)}';
  }

  @override
  Time? viewToModelValue(String? viewValue) {
    if (viewValue == null) {
      return null;
    }

    final parts = viewValue.split(':');
    if (parts.length != 2) {
      return null;
    }
    try {
      return Time(
        hour: int.parse(parts[0].trim()),
        minute: int.parse(parts[1].trim()),
      );
    } catch (e) {
      return null;
    }
  }

  String _addLeadingZeroIfNeeded(int value) =>
      (value < 10) ? '0$value' : value.toString();
}

import 'package:flutter/services.dart';

String normalizeStudySequenceInput(String value) =>
    value.replaceAll(RegExp(r'\s+'), '').toUpperCase();

class NumericalRangeFormatter({final int? min, final int? max})
    extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == '') {
      return newValue;
    } else if (min != null && int.parse(newValue.text) < min!) {
      final text = min.toString();
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } else {
      if (max != null && int.parse(newValue.text) > max!) {
        final text = max.toString();
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
      return newValue;
    }
  }
}

class StudySequenceFormatter() extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = normalizeStudySequenceInput(newValue.text);

    if (normalized.isNotEmpty && !RegExp(r'^[AB]+$').hasMatch(normalized)) {
      return oldValue;
    }

    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}

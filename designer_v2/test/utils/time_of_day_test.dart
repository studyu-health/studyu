import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/utils/time_of_day.dart';

void main() {
  final accessor = TimeValueAccessor();

  for (final sample in [
    (text: '0:00', hour: 0, minute: 0),
    (text: '00:00', hour: 0, minute: 0),
    (text: '6:25', hour: 6, minute: 25),
    (text: '06:25', hour: 6, minute: 25),
    (text: '23:59', hour: 23, minute: 59),
  ]) {
    test('parses ${sample.text}', () {
      expect(
        accessor.viewToModelValue(sample.text),
        Time(hour: sample.hour, minute: sample.minute),
      );
    });
  }

  for (final text in [
    '',
    '3123123123123123123',
    'ajsd@!*£y812y31892y3',
    '24:00',
    '23:60',
    '-1:00',
    '06:-1',
    '6:5',
    '6:025',
    '+6:25',
    '6 :25',
    '06:25:00',
  ]) {
    test('rejects invalid time "$text"', () {
      expect(accessor.viewToModelValue(text), isNull);
    });
  }
  group('time input formatting', () {
    TextEditingValue format(
      TextEditingValue oldValue,
      TextEditingValue newValue,
    ) {
      return TimeValueAccessor.inputFormatters.fold(
        newValue,
        (value, formatter) => formatter.formatEditUpdate(oldValue, value),
      );
    }

    TextEditingValue edit(String text, [int? offset]) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset ?? text.length),
    );

    test('typing digits inserts the colon before the minutes', () {
      var value = TextEditingValue.empty;
      for (final step in [
        (input: '0', expected: '0'),
        (input: '06', expected: '06'),
        (input: '060', expected: '06:0'),
        (input: '06:01', expected: '06:01'),
      ]) {
        value = format(value, edit(step.input));
        expect(value.text, step.expected);
        expect(value.selection.extentOffset, value.text.length);
      }
      expect(format(value, edit('06:012')), value);
    });

    test(
      'pasting digits formats the time and leaves the cursor at the end',
      () {
        final value = format(TextEditingValue.empty, edit('0601'));
        expect(value.text, '06:01');
        expect(value.selection, const TextSelection.collapsed(offset: 5));
      },
    );

    test('formatted paste retains its hour and minute groups', () {
      expect(format(TextEditingValue.empty, edit('6:25')).text, '6:25');
      expect(format(TextEditingValue.empty, edit('23:59')).text, '23:59');
    });

    test('backspace can remove a minute and the separator', () {
      final shortened = format(edit('06:0'), edit('06:'));
      expect(shortened.text, '06:');
      final hours = format(shortened, edit('06'));
      expect(hours.text, '06');
      expect(hours.selection.extentOffset, 2);
      expect(format(hours, edit('0')).text, '0');
    });

    test('deleting the separator in a complete time preserves minutes', () {
      final value = format(edit('06:12', 3), edit('0612', 2));
      expect(value.text, '06:12');
      expect(value.selection.extentOffset, 2);
    });

    test('deleting the separator in a single-digit hour preserves minutes', () {
      final value = format(edit('6:25', 2), edit('625', 1));
      expect(value.text, '6:25');
      expect(value.selection.extentOffset, 1);
    });

    for (final text in [
      '24',
      '24:00',
      '24:40',
      '99:99',
      '23:60',
      '2400',
      '2360',
    ]) {
      test(
        'rejects out-of-range edit $text without changing the saved time',
        () {
          final previous = edit('15:40');
          expect(format(previous, edit(text)), previous);
        },
      );
    }
    for (final text in ['00:00', '23:59']) {
      test('accepts boundary $text', () {
        expect(format(TextEditingValue.empty, edit(text)).text, text);
      });
    }
    test('a selected time can be replaced and cleared', () {
      final selected = edit('06:12').copyWith(
        selection: const TextSelection(baseOffset: 0, extentOffset: 5),
      );
      expect(format(selected, edit('1435')).text, '14:35');
      expect(format(selected, TextEditingValue.empty).text, isEmpty);
    });
  });
}

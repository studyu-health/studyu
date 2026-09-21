import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('migrates legacy date-time presets when inputType is missing', () {
    for (final preset in [
      'isoDateTime',
      'europeanDateTime',
      'usDateTimeAmPm',
    ]) {
      final json = DateQuestion.withId().toJson()
        ..remove('inputType')
        ..['dateFormatPreset'] = preset;

      expect(DateQuestion.fromJson(json).inputType, DateInputType.dateTime);
    }
  });

  test('migrates legacy date-only presets when inputType is missing', () {
    final json = DateQuestion.withId().toJson()
      ..remove('inputType')
      ..['dateFormatPreset'] = 'iso';

    expect(DateQuestion.fromJson(json).inputType, DateInputType.date);
  });
}

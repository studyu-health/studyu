import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('serializes date and time preferences', () {
    final preferences = Preferences(
      language: 'de',
      dateFormat: DateFormatPreference.german,
      timeFormat: TimeFormatPreference.h24,
    );

    final json = preferences.toJson();
    final restored = Preferences.fromJson(json);

    expect(json['date_format'], 'german');
    expect(json['time_format'], 'h24');
    expect(restored.dateFormat, DateFormatPreference.german);
    expect(restored.timeFormat, TimeFormatPreference.h24);
  });

  test('omits unset date and time preferences', () {
    final json = Preferences().toJson();

    expect(json, isNot(contains('date_format')));
    expect(json, isNot(contains('time_format')));
  });
}

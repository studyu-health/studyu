import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

void main() {
  setUpAll(() => initializeDateFormatting('en_US'));

  test('formats a date with explicit regional preferences', () {
    final dateTime = DateTime(2024, 12, 31, 14, 30);

    expect(
      dateTime.toLocalizedString(
        locale: 'en-US',
        showTime: false,
        datePreference: DateFormatPreference.iso,
      ),
      '2024-12-31',
    );
    expect(
      dateTime.toLocalizedString(
        locale: 'en-US',
        datePreference: DateFormatPreference.european,
        timePreference: TimeFormatPreference.h24,
      ),
      '31/12/2024 14:30',
    );
  });
}

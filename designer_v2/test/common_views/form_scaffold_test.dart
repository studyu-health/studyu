import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clean FormScaffold cancellation notifies the form view model', () {
    final source = File('lib/common_views/form_scaffold.dart')
        .readAsStringSync();
    final cleanPopStart = source.indexOf('if (!formViewModel.isDirty)');
    final cleanPopEnd = source.indexOf('return;', cleanPopStart);

    expect(cleanPopStart, isNonNegative);
    expect(cleanPopEnd, isNonNegative);

    final cleanPopSource = source.substring(cleanPopStart, cleanPopEnd);

    expect(
      cleanPopSource,
      contains('formViewModel.cancel()'),
      reason:
          'Default Cancel now enters FormScaffold through Navigator.maybePop(), '
          'so the clean-pop branch must still notify the form view model before '
          'closing.',
    );
  });
}

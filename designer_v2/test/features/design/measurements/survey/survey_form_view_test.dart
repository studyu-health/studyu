import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'survey question sidesheet Cancel asks before resetting dirty state',
    () {
      final source = File(
        'lib/features/design/measurements/survey/survey_form_view.dart',
      ).readAsStringSync();
      final questionButtonsStart = source.indexOf(
        'List<Widget> _buildQuestionFormButtons',
      );
      final questionButtonsEnd = source.indexOf(
        'ReactiveFormConsumer',
        questionButtonsStart,
      );

      expect(questionButtonsStart, isNonNegative);
      expect(questionButtonsEnd, isNonNegative);

      final questionCancelButtonSource = source.substring(
        questionButtonsStart,
        questionButtonsEnd,
      );
      final cancelIndex = questionCancelButtonSource.indexOf(
        'formViewModel.cancel()',
      );
      final dismissButtonIndex = questionCancelButtonSource.indexOf(
        'DismissButton',
      );

      expect(dismissButtonIndex, isNonNegative);
      expect(
        cancelIndex,
        isNegative,
        reason:
            'Custom Cancel must let the sidesheet PopEntry call '
            'formViewModel.cancel() after it checks dirty state and asks for '
            'discard confirmation.',
      );
    },
  );
}

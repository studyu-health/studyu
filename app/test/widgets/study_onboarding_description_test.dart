import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';

void main() {
  testWidgets('shows a consistent description with optional details', (
    tester,
  ) async {
    var actionPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StudyOnboardingDescription(
            text: 'Primary description.',
            actionLabel: 'Why?',
            onAction: () => actionPressed = true,
            supportingText: 'Supporting description.',
          ),
        ),
      ),
    );

    final description = find.byType(StudyOnboardingDescription);
    expect(tester.getSize(description).width, 800);

    final primaryTextFinder = find
        .descendant(of: description, matching: find.byType(Text))
        .first;
    final primaryText = tester.widget<Text>(primaryTextFinder);
    expect(primaryText.textAlign, TextAlign.start);
    final theme = Theme.of(tester.element(primaryTextFinder));
    expect(
      primaryText.textSpan!.style,
      theme.textTheme.bodyLarge!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );

    final supportingTextFinder = find.text('Supporting description.');
    final supportingText = tester.widget<Text>(supportingTextFinder);
    expect(supportingText.textAlign, TextAlign.start);
    expect(
      supportingText.style!.color,
      Theme.of(tester.element(supportingTextFinder))
          .colorScheme
          .onSurfaceVariant,
    );

    expect(
      tester.getSemantics(find.widgetWithText(TextButton, 'Why?')),
      isSemantics(label: 'Why?', isButton: true, hasTapAction: true),
    );
    await tester.tap(find.widgetWithText(TextButton, 'Why?'));
    expect(actionPressed, isTrue);
  });
}

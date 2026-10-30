import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/widgets/questionnaire/question_header.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('question description appears below the title in $brightness', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const Scaffold(
            body: QuestionHeader(
              prompt: '<p>Rate your average pain today.</p>',
              subtitle: 'Additional instructions',
              rationale:
                  '<p>Use the past 24 hours.</p> '
                  '<p>Include pain while resting.</p>',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final theme = Theme.of(tester.element(find.byType(QuestionHeader)));
      final prompt = tester.widget<RichText>(
        find.text('Rate your average pain today.', findRichText: true),
      );
      expect(
        prompt.text.style?.fontSize,
        theme.textTheme.titleMedium?.fontSize,
      );
      expect(
        prompt.text.style?.fontWeight,
        theme.textTheme.titleMedium?.fontWeight,
      );
      for (final text in [
        'Use the past 24 hours.',
        'Include pain while resting.',
      ]) {
        final supporting = tester.widget<RichText>(
          find.text(text, findRichText: true),
        );
        expect(
          supporting.text.style?.fontSize,
          theme.textTheme.bodyMedium?.fontSize,
        );
        expect(supporting.text.style?.fontWeight, FontWeight.normal);
        expect(
          supporting.text.style?.color,
          theme.colorScheme.onSurfaceVariant,
        );
      }
      final subtitle = tester.widget<Text>(
        find.text('Additional instructions'),
      );
      expect(subtitle.style?.color, theme.colorScheme.onSurfaceVariant);
      final headerRect = tester.getRect(find.byType(QuestionHeader));
      final promptRect = tester.getRect(
        find.text('Rate your average pain today.', findRichText: true),
      );
      final supportingRect = tester.getRect(
        find.text('Use the past 24 hours.', findRichText: true),
      );
      final lastParagraphRect = tester.getRect(
        find.text('Include pain while resting.', findRichText: true),
      );
      final subtitleRect = tester.getRect(find.text('Additional instructions'));
      expect(promptRect.top, closeTo(headerRect.top, 0.01));
      expect(subtitleRect.top - promptRect.bottom, closeTo(8, 0.01));
      expect(supportingRect.top - subtitleRect.bottom, closeTo(8, 0.01));
      expect(lastParagraphRect.top - supportingRect.bottom, closeTo(8, 0.01));
      expect(lastParagraphRect.bottom, closeTo(headerRect.bottom, 0.01));
      expect(find.byIcon(Icons.info_outline), findsNothing);
      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('description follows the title without a subtitle', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QuestionHeader(
            prompt: 'Question title',
            rationale: 'Question description',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final title = tester.getRect(
      find.text('Question title', findRichText: true),
    );
    final description = tester.getRect(
      find.text('Question description', findRichText: true),
    );
    expect(description.top - title.bottom, closeTo(8, 0.01));
  });

  testWidgets('empty descriptions add no space', (tester) async {
    for (final rationale in [null, '', ' \n ']) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionHeader(
              prompt: 'Question title',
              rationale: rationale,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final header = tester.getRect(find.byType(QuestionHeader));
      final title = tester.getRect(
        find.text('Question title', findRichText: true),
      );
      expect(header.bottom, closeTo(title.bottom, 0.01));
      expect(find.byType(IconButton), findsNothing);
    }
  });

  testWidgets('plain questions and authored HTML emphasis remain visible', (
    tester,
  ) async {
    for (final prompt in [
      'Rate your pain.',
      '<p>Rate your pain.</p><p>Include <strong>all</strong> activities.</p>',
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: QuestionHeader(prompt: prompt)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Rate your pain.', findRichText: true), findsOneWidget);
      if (prompt.contains('<strong>')) {
        final supporting = tester.widget<RichText>(
          find.text('Include all activities.', findRichText: true),
        );
        final theme = Theme.of(tester.element(find.byType(QuestionHeader)));
        expect(
          supporting.text.style?.fontSize,
          theme.textTheme.titleMedium?.fontSize,
        );
        expect(
          supporting.text.style?.fontWeight,
          theme.textTheme.titleMedium?.fontWeight,
        );
        final spans = <TextSpan>[];
        supporting.text.visitChildren((span) {
          if (span is TextSpan && span.text == 'all') spans.add(span);
          return true;
        });
        expect(spans.single.style?.fontWeight, FontWeight.bold);
      }
      expect(tester.takeException(), isNull);
    }
  });
}

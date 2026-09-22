import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/free_text_question_widget.dart';
import 'package:studyu_core/core.dart';

Widget setup(Widget child) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: false),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('Done button is shown before text entry', (tester) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.any,
      lengthRange: [1, 10],
    );

    await tester.pumpWidget(
      setup(FreeTextQuestionWidget(question: question, isLastQuestion: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Submit'), findsNothing);
  });

  testWidgets('onFieldSubmitted just unfocuses, does not call onDone', (
    tester,
  ) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.custom,
      lengthRange: [1, 10],
      customTypeExpression: r'\d+',
    );

    int onDoneCount = 0;

    await tester.pumpWidget(
      setup(
        FreeTextQuestionWidget(
          question: question,
          onDone: (_) => onDoneCount++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));

    expect(onDoneCount, equals(0));
  });

  testWidgets('Done validates empty text before calling onDone', (
    tester,
  ) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.any,
      lengthRange: [1, 10],
    );

    int onDoneCount = 0;

    await tester.pumpWidget(
      setup(
        FreeTextQuestionWidget(
          question: question,
          onDone: (_) => onDoneCount++,
          isLastQuestion: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(onDoneCount, equals(0));
    expect(find.text('Please enter at least 1 characters'), findsOneWidget);
  });

  testWidgets('Done submits valid text', (tester) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.custom,
      lengthRange: [1, 10],
      customTypeExpression: r'\d+',
    );

    Answer<String>? answer;

    await tester.pumpWidget(
      setup(
        FreeTextQuestionWidget(
          question: question,
          onDone: (value) => answer = value as Answer<String>,
          isLastQuestion: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 600));
    expect(answer?.response, equals('123'));
  });

  testWidgets('clearing a restored answer shows Done and min-length error', (
    tester,
  ) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.any,
      lengthRange: [2, 100],
    );

    await tester.pumpWidget(
      setup(
        FreeTextQuestionWidget(
          question: question,
          initialAnswer: question.constructAnswer('pasta'),
          onDone: (_) {},
          isLastQuestion: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsNothing);

    await tester.enterText(find.byType(TextFormField), '');
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Please enter at least 2 characters'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('Done button reappears after editing submitted last free text', (
    tester,
  ) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.any,
      lengthRange: [1, 100],
    );

    await tester.pumpWidget(
      setup(
        FreeTextQuestionWidget(
          question: question,
          onDone: (_) {},
          isLastQuestion: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'pasta');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsNothing);

    await tester.enterText(find.byType(TextFormField), 'pasta and salad');
    await tester.pump();

    expect(find.text('Done'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets(
    'Done button appears after editing submitted non-last free text',
    (tester) async {
      final question = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.any,
        lengthRange: [0, 100],
      );

      await tester.pumpWidget(
        setup(
          FreeTextQuestionWidget(
            question: question,
            initialAnswer: question.constructAnswer('0'),
            onDone: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsNothing);

      await tester.enterText(find.byType(TextFormField), '00');
      await tester.pump();

      expect(find.text('Done'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
    },
  );

  testWidgets('typing updates onDraftChanged but does not call onDone', (
    tester,
  ) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.custom,
      lengthRange: [1, 10],
      customTypeExpression: r'\d+',
    );

    int onDoneCount = 0;
    String? lastDraftId;
    String? lastDraftValue;

    await tester.pumpWidget(
      setup(
        FreeTextQuestionWidget(
          question: question,
          onDone: (_) => onDoneCount++,
          onDraftChanged: (id, value) {
            lastDraftId = id;
            lastDraftValue = value;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '42');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(lastDraftId, equals(question.id));
    expect(lastDraftValue, equals('42'));
    expect(onDoneCount, equals(0));
  });

  testWidgets('initial answer is restored as draft without calling onDone', (
    tester,
  ) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.custom,
      lengthRange: [1, 10],
      customTypeExpression: r'\d+',
    );

    int onDoneCount = 0;
    String? lastDraftValue;

    await tester.pumpWidget(
      setup(
        FreeTextQuestionWidget(
          question: question,
          initialAnswer: question.constructAnswer('99'),
          onDone: (_) => onDoneCount++,
          onDraftChanged: (id, value) => lastDraftValue = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(lastDraftValue, equals('99'));
    expect(onDoneCount, equals(0));
    expect(find.text('Submit'), findsNothing);
  });

  testWidgets(
    'restored invalid initial answer shows validation error immediately',
    (tester) async {
      final question = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.numeric,
        lengthRange: [1, 10],
      );

      // Simulates switching question trees and back: the widget is recreated
      // with a restored (invalid) value. The error must surface right away.
      await tester.pumpWidget(
        setup(
          FreeTextQuestionWidget(
            question: question,
            initialAnswer: question.constructAnswer('abc'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Please enter only numeric characters'), findsOneWidget);
    },
  );

  testWidgets('restored valid initial answer shows no validation error', (
    tester,
  ) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.numeric,
      lengthRange: [1, 10],
    );

    await tester.pumpWidget(
      setup(
        FreeTextQuestionWidget(
          question: question,
          initialAnswer: question.constructAnswer('123'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Please enter only numeric characters'), findsNothing);
  });
}

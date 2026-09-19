import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/medication_question_widget.dart';
import 'package:studyu_core/core.dart';

MedicationProductSnapshot snapshot() => const MedicationProductSnapshot(
  pzn: '03752864',
  officialName: 'Ibuprofen Test',
  activeIngredientCount: 1,
  dosageForm: MedicationDosageForm(patientFriendlyShort: 'Tablet'),
  components: [],
  source: MedicationSource(name: 'BfArM', releaseDate: '2026-09-15'),
);

Widget setup(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('looks up a PZN, accepts quantity, and submits a typed answer', (
    tester,
  ) async {
    final question = MedicationQuestion.withId();
    Answer<MedicationAnswer>? submitted;

    await tester.pumpWidget(
      setup(
        MedicationQuestionWidget(
          question: question,
          debounceDuration: Duration.zero,
          exactLookup: (pzn) async {
            expect(pzn, '03752864');
            return snapshot();
          },
          nameSearch: (_) async => [],
          onDone: (answer) => submitted = answer,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, '03752864');
    await tester.pump();
    await tester.pump();

    expect(find.text('Ibuprofen Test'), findsOneWidget);
    await tester.tap(find.text('Ibuprofen Test'));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('medication_quantity')),
      '0,5',
    );
    await tester.pump();
    await tester.tap(find.text('Use this medication'));
    await tester.pump();

    expect(submitted, isNotNull);
    expect(submitted!.response.medication.pzn, '03752864');
    expect(submitted!.response.quantity, 0.5);
  });

  testWidgets('shows search guidance and no-result states', (tester) async {
    await tester.pumpWidget(
      setup(
        MedicationQuestionWidget(
          question: MedicationQuestion.withId(),
          debounceDuration: Duration.zero,
          nameSearch: (_) async => [],
          onDone: (_) {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'i');
    await tester.pump();
    expect(find.text('Enter at least two characters.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'ibuprofen');
    await tester.pump();
    await tester.pump();
    expect(find.text('No medications found.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    expect(find.text('Enter at least two characters.'), findsNothing);
  });

  testWidgets('renders search results and resets quantity when reselecting', (
    tester,
  ) async {
    const first = MedicationProductSnapshot(
      pzn: '03752864',
      officialName: 'Ibuprofen Test',
      activeIngredientCount: 1,
      dosageForm: MedicationDosageForm(patientFriendlyShort: 'Tablet'),
      components: [],
      source: MedicationSource(name: 'BfArM', releaseDate: '2026-09-15'),
    );
    const second = MedicationProductSnapshot(
      pzn: '19100431',
      officialName: 'Second Medication',
      activeIngredientCount: 1,
      dosageForm: MedicationDosageForm(),
      components: [],
      source: MedicationSource(name: 'BfArM', releaseDate: '2026-09-15'),
    );

    await tester.pumpWidget(
      setup(
        MedicationQuestionWidget(
          question: MedicationQuestion.withId(),
          debounceDuration: Duration.zero,
          nameSearch: (_) async => [first, second],
          onDone: (_) {},
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'ibu');
    await tester.pump();
    await tester.pump();
    expect(find.text('Ibuprofen Test'), findsOneWidget);
    expect(find.text('Second Medication'), findsOneWidget);
    expect(find.text('Tablet\nPZN 03752864'), findsOneWidget);

    await tester.tap(find.text('Ibuprofen Test'));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('medication_quantity')),
      '2',
    );
    await tester.pump();
    await tester.tap(find.text('Choose another medication'));
    await tester.pump();
    expect(find.byKey(const ValueKey('medication_quantity')), findsNothing);
    expect(find.text('Second Medication'), findsNothing);
  });

  testWidgets('reports invalid quantity and accepts initial answers', (
    tester,
  ) async {
    final question = MedicationQuestion.withId();
    final initial = question.constructAnswer(
      MedicationAnswer(medication: snapshot(), quantity: 3),
    );
    Answer<MedicationAnswer>? submitted;

    await tester.pumpWidget(
      setup(
        MedicationQuestionWidget(
          question: question,
          initialAnswer: initial,
          onDone: (answer) => submitted = answer,
        ),
      ),
    );
    expect(find.text('Ibuprofen Test'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('medication_quantity')),
      '0',
    );
    await tester.pump();
    expect(find.text('Enter a quantity greater than zero.'), findsOneWidget);
    expect(submitted, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('medication_quantity')),
      '4',
    );
    await tester.pump();
    await tester.tap(find.text('Use this medication'));
    await tester.pump();
    expect(submitted?.response.quantity, 4);
  });

  testWidgets('handles stale requests, retry, and exact lookup errors', (
    tester,
  ) async {
    final firstRequest = Completer<List<MedicationProductSnapshot>>();
    final secondRequest = Completer<List<MedicationProductSnapshot>>();
    var requestCount = 0;
    await tester.pumpWidget(
      setup(
        MedicationQuestionWidget(
          question: MedicationQuestion.withId(),
          debounceDuration: Duration.zero,
          nameSearch: (_) {
            requestCount++;
            return requestCount == 1
                ? firstRequest.future
                : secondRequest.future;
          },
          exactLookup: (_) async => throw StateError('offline'),
          onDone: (_) {},
        ),
      ),
    );
    final search = find.byType(TextField).first;
    await tester.enterText(search, 'old');
    await tester.pump();
    await tester.enterText(search, 'new');
    await tester.pump();
    secondRequest.complete([snapshot()]);
    await tester.pump();
    await tester.pump();
    expect(find.text('Ibuprofen Test'), findsOneWidget);
    firstRequest.complete([]);
    await tester.pump();
    expect(find.text('Ibuprofen Test'), findsOneWidget);

    await tester.enterText(search, '03752864');
    await tester.pump();
    await tester.pump();
    expect(find.text('Medication search failed.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.text('Medication search failed.'), findsOneWidget);
  });

  testWidgets('handles invalid and failing barcode scans', (tester) async {
    var shouldThrow = false;
    await tester.pumpWidget(
      setup(
        MedicationQuestionWidget(
          question: MedicationQuestion.withId(),
          scanBarcode: () async {
            if (shouldThrow) throw StateError('camera');
            return const Barcode(
              format: BarcodeFormat.dataMatrix,
              rawValue: 'unsupported',
            );
          },
          onDone: (_) {},
        ),
      ),
    );
    await tester.tap(find.byTooltip('Scan medication barcode'));
    await tester.pump();
    expect(
      find.text('The barcode is not a supported medication barcode.'),
      findsOneWidget,
    );

    shouldThrow = true;
    await tester.tap(find.byTooltip('Scan medication barcode'));
    await tester.pump();
    expect(find.text('Medication search failed.'), findsOneWidget);
  });
}

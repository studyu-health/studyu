import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/terms.dart';
import 'package:studyu_core/core.dart';

void main() {
  test('pops terms when a selected study has a previous route', () {
    final state = AppState()..selectedStudy = Study('study-1', 'owner-1');

    expect(routeAfterTerms(state, canPop: true), isNull);
  });

  test('opens study overview when selected study terms cannot pop', () {
    final state = AppState()..selectedStudy = Study('study-1', 'owner-1');

    expect(
      routeAfterTerms(state, canPop: false),
      '/${RouteNames.studyOverview}',
    );
  });

  test('opens study selection without a selected study', () {
    expect(
      routeAfterTerms(AppState(), canPop: false),
      '/${RouteNames.studySelection}',
    );
  });

  testWidgets('aligns legal document content in one text column', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LegalSection(
            title: 'Terms',
            description: 'Description',
            acknowledgment: 'I agree',
            isChecked: false,
            onChanged: (_) {},
            icon: const Icon(Icons.description),
            pdfUrl: 'https://example.com',
            pdfUrlLabel: 'Read document',
          ),
        ),
      ),
    );

    final titleX = tester.getTopLeft(find.text('Terms')).dx;
    expect(
      tester.getTopLeft(find.text('Description')).dx,
      moreOrLessEquals(titleX),
    );
    expect(
      tester.getTopLeft(find.text('Read document')).dx,
      moreOrLessEquals(titleX),
    );
    expect(
      tester.getCenter(find.byIcon(Icons.description)).dx,
      lessThan(titleX),
    );
    final checkboxX = tester.getCenter(find.byType(Checkbox)).dx;
    expect(checkboxX, greaterThan(titleX));
    expect(checkboxX, lessThan(tester.getCenter(find.text('I agree')).dx));
  });

  testWidgets('toggles acceptance when the acknowledgment is tapped', (
    tester,
  ) async {
    var isChecked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LegalSection(
            title: 'Terms',
            description: 'Description',
            acknowledgment: 'I agree',
            isChecked: isChecked,
            onChanged: (value) => isChecked = value ?? false,
            icon: const Icon(Icons.description),
            pdfUrl: 'https://example.com',
            pdfUrlLabel: 'Read document',
          ),
        ),
      ),
    );

    await tester.tap(find.text('I agree'));

    expect(isChecked, isTrue);
  });
}

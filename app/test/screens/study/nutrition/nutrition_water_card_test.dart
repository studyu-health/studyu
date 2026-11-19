import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_water_card.dart';

void main() {
  testWidgets('cup size editor opens with preview-scoped localizations', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final localizations = nutritionWaterPreviewLocalizations();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Localizations.override(
              context: context,
              locale: localizations.locale,
              delegates: localizations.localizationsDelegates?.toList(),
              child: nutritionWaterCardPreview(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cup size · 250 mL'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '400');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Cup size · 400 mL'), findsOneWidget);
  });
}

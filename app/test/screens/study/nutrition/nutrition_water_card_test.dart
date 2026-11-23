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

    await tester.tap(find.byTooltip('Cup size'));
    await tester.pumpAndSettle();
    expect(find.text('250'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '400');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('500 mL'), findsOneWidget);
    await tester.tap(find.byTooltip('Add a cup of water'));
    await tester.pumpAndSettle();
    expect(find.text('900 mL'), findsOneWidget);
  });
}

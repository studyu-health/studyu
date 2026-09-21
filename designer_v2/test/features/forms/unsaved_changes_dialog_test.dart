import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/forms/unsaved_changes_dialog.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(AppLocalizationsEn());
  });

  testWidgets('shows stay before a destructive discard action', (tester) async {
    tester.view
      ..physicalSize = const Size(1200, 800)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: UnsavedChangesDialog()));

    final stayButton = find.ancestor(
      of: find.text('Stay'),
      matching: find.byType(OutlinedButton),
    );
    final discardButton = find.ancestor(
      of: find.text('Discard changes'),
      matching: find.byType(ElevatedButton),
    );

    expect(stayButton, findsOneWidget);
    expect(discardButton, findsOneWidget);
    expect(
      tester.getCenter(stayButton).dx,
      lessThan(tester.getCenter(discardButton).dx),
    );

    final button = tester.widget<ElevatedButton>(discardButton);
    final errorColor = Theme.of(tester.element(discardButton))
        .colorScheme
        .error;
    expect(button.style?.backgroundColor?.resolve({}), errorColor);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/study_delete_confirmation_dialog.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(AppLocalizationsEn());
  });

  testWidgets('study delete dialog requires acknowledgement and study name', (
    tester,
  ) async {
    final study = Study('study-id', 'owner-id')..title = 'Hypertension Study';

    await tester.pumpWidget(
      MaterialApp(
        home: StudyDeleteConfirmationDialog(
          study: study,
          confirmLabel: 'Delete',
          onDownloadBackup: () async {},
          onCloseInstead: () async {},
        ),
      ),
    );

    final deleteButtonFinder = find.ancestor(
      of: find.text('Delete'),
      matching: find.byType(ElevatedButton),
    );

    expect(find.text('Permanently delete?'), findsOneWidget);
    expect(
      find.textContaining('Before deleting, save a backup'),
      findsOneWidget,
    );
    expect(find.text('Download backup'), findsOneWidget);
    expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    expect(find.text('Review closing instead'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(
      find.byKey(const ValueKey('study_delete_data_checkbox')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('study_delete_participant_checkbox')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('study_delete_irreversible_checkbox')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('study_delete_name_confirmation_field')),
      findsOneWidget,
    );
    expect(deleteButtonFinder, findsOneWidget);
    expect(tester.widget<ElevatedButton>(deleteButtonFinder).onPressed, isNull);

    for (final key in [
      const ValueKey('study_delete_data_checkbox'),
      const ValueKey('study_delete_participant_checkbox'),
      const ValueKey('study_delete_irreversible_checkbox'),
    ]) {
      await tester.ensureVisible(find.byKey(key));
      await tester.tap(find.byKey(key), warnIfMissed: false);
      await tester.pump();
      expect(
        tester.widget<ElevatedButton>(deleteButtonFinder).onPressed,
        isNull,
      );
    }

    await tester.ensureVisible(
      find.byKey(const ValueKey('study_delete_name_confirmation_field')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('study_delete_name_confirmation_field')),
      'Wrong Study',
    );
    await tester.pump();
    expect(tester.widget<ElevatedButton>(deleteButtonFinder).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('study_delete_name_confirmation_field')),
      '  Hypertension Study  ',
    );
    await tester.pump();
    expect(
      tester.widget<ElevatedButton>(deleteButtonFinder).onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Permanently delete?'), findsNothing);
  });
}

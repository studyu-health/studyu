import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/dashboard/settings.dart';

void main() {
  for (final confirm in [false, true]) {
    testWidgets(
      'discarding unsynced answers requires a separate confirmation: $confirm',
      (tester) async {
        bool? result;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async =>
                      result = await confirmDiscardUnsyncedStudyData(context),
                  child: const Text('Leave'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Leave'));
        await tester.pumpAndSettle();
        expect(find.text('Leave without syncing?'), findsOneWidget);
        expect(
          find.textContaining(
            'permanently discard all answers saved only on this device',
          ),
          findsOneWidget,
        );
        expect(result, isNull);
        await tester.tap(
          find.text(confirm ? 'Continue without syncing' : 'Cancel'),
        );
        await tester.pumpAndSettle();
        expect(result, confirm);
        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/widgets/confirmation_dialog.dart';

void main() {
  testWidgets('only explicit confirmation returns true', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 480);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showConfirmationDialog(
                  context,
                  title: 'Gespeicherten Eintrag löschen?',
                  message: 'Dieser Eintrag wird aus der Bibliothek entfernt.',
                  cancelLabel: 'Abbrechen',
                  confirmLabel: 'Eintrag löschen',
                  isDestructive: true,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    final dismissals = <Future<void> Function()>[
      () => tester.tap(find.text('Abbrechen')),
      () => tester.binding.handlePopRoute(),
      () => tester.tapAt(const Offset(4, 4)),
      () => tester.tap(find.text('Eintrag löschen')),
    ];
    for (final (index, dismiss) in dismissals.indexed) {
      result = null;
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await dismiss();
      await tester.pumpAndSettle();
      expect(result, index == dismissals.length - 1);
    }
  });
}

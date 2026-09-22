import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(AppLocalizationsEn());
  });

  testWidgets('model action confirmation uses standard dialog design', (
    tester,
  ) async {
    final action = ModelAction<ModelActionType>(
      type: ModelActionType.delete,
      label: 'Delete',
      isDestructive: true,
      confirmation: ModelActionConfirmations.delete(subject: 'item'),
      onExecute: () {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => action.execute(context),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(StandardDialog), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Delete item?'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('destructive confirmation uses subtle cancel and filled delete', (
    tester,
  ) async {
    final action = ModelAction<ModelActionType>(
      type: ModelActionType.delete,
      label: 'Delete',
      isDestructive: true,
      confirmation: ModelActionConfirmations.delete(subject: 'item'),
      onExecute: () {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => action.execute(context),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      find.ancestor(
        of: find.text('Cancel'),
        matching: find.byType(OutlinedButton),
      ),
      findsOneWidget,
    );

    final deleteButtonFinder = find.ancestor(
      of: find.text('Delete'),
      matching: find.byType(ElevatedButton),
    );
    expect(deleteButtonFinder, findsOneWidget);

    final button = tester.widget<ElevatedButton>(deleteButtonFinder);
    final context = tester.element(find.byType(StandardDialog));
    final errorColor = Theme.of(context).colorScheme.error;

    expect(button.style?.backgroundColor?.resolve({}), errorColor);
    expect(button.style?.foregroundColor?.resolve({}), Colors.white);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(AppLocalizationsEn());
  });

  testWidgets('empty and selected icon picker states keep same size', (
    tester,
  ) async {
    const iconOption = IconOption('apple', Icons.apple);

    await tester.pumpWidget(
      _buildHarness(
        IconPickerField(
          iconOptions: const [iconOption],
          useSquareField: true,
          onSelect: (_) {},
        ),
      ),
    );
    final emptySize = tester.getSize(_reservedPickerSlot());

    await tester.pumpWidget(
      _buildHarness(
        IconPickerField(
          iconOptions: const [iconOption],
          selectedOption: iconOption,
          useSquareField: true,
          onSelect: (_) {},
        ),
      ),
    );
    final selectedSize = tester.getSize(_reservedPickerSlot());

    expect(emptySize, selectedSize);
    expect(emptySize.width, IconPickerField.controlSize);
    expect(emptySize.height, IconPickerField.controlSize);
  });

  testWidgets('square picker tooltip covers the full button', (tester) async {
    const iconOption = IconOption('apple', Icons.apple);

    await tester.pumpWidget(
      _buildHarness(
        IconPickerField(
          iconOptions: const [iconOption],
          useSquareField: true,
          onSelect: (_) {},
        ),
      ),
    );

    expect(
      find.ancestor(
        of: find.byType(OutlinedButton),
        matching: find.byTooltip(tr.iconpicker_empty_prompt),
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(
      _buildHarness(
        IconPickerField(
          iconOptions: const [iconOption],
          selectedOption: iconOption,
          useSquareField: true,
          onSelect: (_) {},
        ),
      ),
    );

    expect(
      find.ancestor(
        of: find.byType(OutlinedButton),
        matching: find.byTooltip(tr.iconpicker_nonempty_prompt),
      ),
      findsOneWidget,
    );
  });

  testWidgets('labeled square picker keeps same footprint', (tester) async {
    const iconOption = IconOption('apple', Icons.apple);
    const actionWidth = 144.0;

    await tester.pumpWidget(
      _buildHarness(
        IconPickerField(
          iconOptions: const [iconOption],
          useSquareField: true,
          showFieldLabel: true,
          labeledFieldWidth: actionWidth,
          onSelect: (_) {},
        ),
      ),
    );
    final emptySize = tester.getSize(_reservedLabeledPickerSlot(actionWidth));

    expect(find.text(tr.iconpicker_empty_prompt), findsOneWidget);

    await tester.pumpWidget(
      _buildHarness(
        IconPickerField(
          iconOptions: const [iconOption],
          selectedOption: iconOption,
          useSquareField: true,
          showFieldLabel: true,
          labeledFieldWidth: actionWidth,
          onSelect: (_) {},
        ),
      ),
    );
    final selectedSize = tester.getSize(
      _reservedLabeledPickerSlot(actionWidth),
    );

    expect(emptySize, selectedSize);
    expect(selectedSize.width, actionWidth);
    expect(selectedSize.height, IconPickerField.controlSize);
    expect(find.text(tr.iconpicker_nonempty_prompt), findsOneWidget);
  });

  testWidgets('disabled labeled icon picker disables whole action', (
    tester,
  ) async {
    const iconOption = IconOption('apple', Icons.apple);

    await tester.pumpWidget(
      _buildHarness(
        IconPickerField(
          iconOptions: const [iconOption],
          selectedOption: iconOption,
          useSquareField: true,
          showFieldLabel: true,
          isDisabled: true,
          onSelect: (_) {},
        ),
      ),
    );

    final changeButton = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton),
    );

    expect(changeButton.onPressed, isNull);
    expect(find.text(tr.iconpicker_nonempty_prompt), findsOneWidget);
  });

  testWidgets(
    'remove action in dialog returns empty icon and keeps size stable',
    (tester) async {
      IconOption? selectedOption = const IconOption('apple', Icons.apple);

      await tester.pumpWidget(
        _buildHarness(
          StatefulBuilder(
            builder: (context, setState) {
              return IconPickerField(
                iconOptions: const [IconOption('apple', Icons.apple)],
                selectedOption: selectedOption,
                useSquareField: true,
                onSelect: (iconOption) {
                  setState(() {
                    selectedOption = iconOption.isEmpty ? null : iconOption;
                  });
                },
              );
            },
          ),
        ),
      );
      final selectedSize = tester.getSize(_reservedPickerSlot());

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tr.iconpicker_remove_prompt));
      await tester.pumpAndSettle();

      expect(selectedOption, isNull);
      expect(find.text(tr.iconpicker_remove_prompt), findsNothing);
      expect(tester.getSize(_reservedPickerSlot()), selectedSize);
    },
  );

  testWidgets('disabled icon picker disables picker and clear actions', (
    tester,
  ) async {
    const iconOption = IconOption('apple', Icons.apple);

    await tester.pumpWidget(
      _buildHarness(
        IconPickerField(
          iconOptions: const [iconOption],
          selectedOption: iconOption,
          useSquareField: true,
          isDisabled: true,
          onSelect: (_) {},
        ),
      ),
    );

    final changeButton = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton),
    );

    expect(changeButton.onPressed, isNull);
  });

  testWidgets('reactive icon picker clears form control value', (tester) async {
    const iconOption = IconOption('apple', Icons.apple);
    final iconControl = FormControl<IconOption>(value: iconOption);
    final form = FormGroup({'icon': iconControl});

    await tester.pumpWidget(
      _buildHarness(
        ReactiveForm(
          formGroup: form,
          child: ReactiveIconPicker(
            formControl: iconControl,
            iconOptions: const [iconOption],
            useSquareField: true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tr.iconpicker_remove_prompt));
    await tester.pumpAndSettle();

    expect(iconControl.value, isNull);
    expect(
      tester.getSize(_reservedPickerSlot()).width,
      IconPickerField.controlSize,
    );
  });

  testWidgets('icon picker opens dialog and selects an icon', (tester) async {
    IconOption? selectedOption;
    const iconOption = IconOption('favorite', Icons.favorite);

    await tester.pumpWidget(
      _buildHarness(
        StatefulBuilder(
          builder: (context, setState) {
            return IconPickerField(
              iconOptions: const [iconOption],
              selectedOption: selectedOption,
              useSquareField: true,
              onSelect: (iconOption) {
                setState(() {
                  selectedOption = iconOption;
                });
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    expect(find.text(tr.iconpicker_dialog_title), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(selectedOption, iconOption);
    expect(find.text(tr.iconpicker_dialog_title), findsNothing);
  });

  testWidgets('icon picker search filters available icons', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        IconPickerField(
          iconOptions: const [
            IconOption('apple', Icons.apple),
            IconOption('favorite', Icons.favorite),
          ],
          useSquareField: true,
          onSelect: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.apple), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(SearchBar),
        matching: find.byType(EditableText),
      ),
      'fav',
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.apple), findsNothing);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}

Widget _buildHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

Finder _reservedPickerSlot() {
  return find.byWidgetPredicate((widget) {
    return widget is SizedBox &&
        widget.width == IconPickerField.controlSize &&
        widget.height == IconPickerField.controlSize;
  });
}

Finder _reservedLabeledPickerSlot(double width) {
  return find.byWidgetPredicate((widget) {
    return widget is SizedBox &&
        widget.width == width &&
        widget.height == IconPickerField.controlSize;
  });
}

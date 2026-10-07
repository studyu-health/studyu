import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/features/design/info/study_title_input_group.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

const _favoriteIcon = IconOption('favorite', Icons.favorite);

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(AppLocalizationsEn());
  });

  testWidgets('renders icon action after title field', (tester) async {
    final controls = _studyTitleControls();

    await tester.pumpWidget(_buildHarness(controls));

    final iconTopLeft = tester.getTopLeft(find.byType(ReactiveIconPicker));
    final fieldTopLeft = tester.getTopLeft(_titleFieldFinder());
    final iconSize = tester.getSize(find.byType(OutlinedButton));
    final fieldSize = tester.getSize(_titleFieldFinder());

    expect(fieldTopLeft.dx, lessThan(iconTopLeft.dx));
    expect(iconTopLeft.dy, fieldTopLeft.dy);
    expect(iconSize.width, StudyTitleInputGroup.iconActionWidth);
    expect(iconSize.height, StudyTitleInputGroup.controlHeight);
    expect(fieldSize.height, StudyTitleInputGroup.controlHeight);
    expect(find.text(tr.iconpicker_empty_prompt), findsOneWidget);
    expect(find.byType(ReactiveIconPicker), findsOneWidget);
    expect(_titleFieldFinder(), findsOneWidget);
  });

  testWidgets('selected icon state shows change label', (tester) async {
    final controls = _studyTitleControls(icon: _favoriteIcon);

    await tester.pumpWidget(_buildHarness(controls));

    expect(find.text(tr.iconpicker_nonempty_prompt), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('opens picker from icon selector and selects an icon', (
    tester,
  ) async {
    final controls = _studyTitleControls();

    await tester.pumpWidget(_buildHarness(controls));
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(SelectableText, tr.iconpicker_dialog_title),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(controls.iconControl.value, _favoriteIcon);
    expect(find.text(tr.iconpicker_nonempty_prompt), findsOneWidget);
  });

  testWidgets('removes icon from picker dialog', (tester) async {
    final controls = _studyTitleControls(icon: _favoriteIcon);

    await tester.pumpWidget(_buildHarness(controls));
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tr.iconpicker_remove_prompt));
    await tester.pumpAndSettle();

    expect(controls.iconControl.value, isNull);
  });

  testWidgets('title editing still updates title control', (tester) async {
    final controls = _studyTitleControls();

    await tester.pumpWidget(_buildHarness(controls));
    await tester.enterText(_titleFieldFinder(), 'SHAHRUKH STUDY');
    await tester.pump();

    expect(controls.titleControl.value, 'SHAHRUKH STUDY');
  });

  testWidgets('title validation still renders below fixed height field', (
    tester,
  ) async {
    const validationText = 'Title is required';
    final controls = (
      titleControl: FormControl<String>(validators: [Validators.required]),
      iconControl: FormControl<IconOption>(),
    );

    controls.titleControl.markAsTouched();
    await tester.pumpWidget(
      _buildHarness(
        controls,
        titleValidationMessages: {
          ValidationMessage.required: (_) => validationText,
        },
      ),
    );

    expect(find.text(validationText), findsOneWidget);
    expect(
      tester.getSize(find.byType(OutlinedButton)).height,
      StudyTitleInputGroup.controlHeight,
    );
    expect(
      tester.getSize(find.byType(OutlinedButton)).width,
      StudyTitleInputGroup.iconActionWidth,
    );
    expect(
      tester.getSize(_titleFieldFinder()).height,
      greaterThan(StudyTitleInputGroup.controlHeight),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('title field width stays stable when icon changes', (
    tester,
  ) async {
    final controls = _studyTitleControls();

    await tester.pumpWidget(_buildHarness(controls));
    final emptyFieldSize = tester.getSize(_titleFieldFinder());

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(tester.getSize(_titleFieldFinder()), emptyFieldSize);
    expect(
      tester.getSize(find.byType(OutlinedButton)).width,
      StudyTitleInputGroup.iconActionWidth,
    );
  });

  testWidgets('title input group remains usable at narrow width', (
    tester,
  ) async {
    final controls = _studyTitleControls();

    await tester.pumpWidget(
      _buildHarness(
        controls,
        width: StudyTitleInputGroup.iconActionWidth + 112,
      ),
    );

    expect(find.byType(ReactiveIconPicker), findsOneWidget);
    expect(_titleFieldFinder(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _buildHarness(
  ({FormControl<String> titleControl, FormControl<IconOption> iconControl})
  controls, {
  double? width,
  Map<String, ValidationMessageFunction>? titleValidationMessages,
}) {
  final form = FormGroup({
    'title': controls.titleControl,
    'icon': controls.iconControl,
  });

  final group = ReactiveForm(
    formGroup: form,
    child: StudyTitleInputGroup(
      titleControl: controls.titleControl,
      iconControl: controls.iconControl,
      iconOptions: const [_favoriteIcon],
      titleValidationMessages: titleValidationMessages,
    ),
  );

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: width == null ? group : SizedBox(width: width, child: group),
      ),
    ),
  );
}

Finder _titleFieldFinder() {
  return find.byKey(const ValueKey('study_title_text_field'));
}

({FormControl<String> titleControl, FormControl<IconOption> iconControl})
_studyTitleControls({IconOption? icon}) {
  return (
    titleControl: FormControl<String>(value: ''),
    iconControl: FormControl<IconOption>(value: icon),
  );
}

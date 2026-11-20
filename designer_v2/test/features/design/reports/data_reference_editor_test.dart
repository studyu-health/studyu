import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/data_reference_editor.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/data_reference_identifier.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('numeric reports can select nutrition data', (tester) async {
    final task = NutritionTask.withId()..title = 'Daily nutrition';
    final control = FormControl<DataReferenceIdentifier<num>>();
    final editor = DataReferenceEditor<num>(
      formControl: control,
      availableTasks: [task],
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: editor.buildReactiveDropdownField)),
    );

    await tester.tap(
      find.byWidgetPredicate((widget) => widget is DropdownButton),
    );
    await tester.pumpAndSettle();
    expect(find.text('Daily nutrition > Total Calories (kcal)'), findsWidgets);
    expect(find.text('Daily nutrition > Completion Time'), findsNothing);
    await tester.tap(find.text('Daily nutrition > Number of Meals').last);
    await tester.pumpAndSettle();
    expect(control.value?.task, task.id);
    expect(control.value?.property, 'mealCount');
  });
}

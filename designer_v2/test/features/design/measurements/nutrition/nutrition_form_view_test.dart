import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  test('allows an empty optional minimum meal count', () {
    final formViewModel = NutritionFormViewModel(
      study: Study.withId('study-1'),
      validationSet: StudyFormValidationSet.test,
    );

    expect(formViewModel.minimumMealsRequiredControl.valid, isTrue);

    formViewModel.minimumMealsRequiredControl.value = 0;

    expect(formViewModel.minimumMealsRequiredControl.valid, isFalse);
  });

  testWidgets('add meal type shows a new input', (tester) async {
    final formViewModel = NutritionFormViewModel(
      study: Study.withId('study-1'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReactiveForm(
              formGroup: formViewModel.form,
              child: NutritionFormView(formViewModel: formViewModel),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Require daily completion'), findsNothing);

    await tester.tap(find.text('Add meal type'));
    await tester.pump();

    expect(formViewModel.customMealTypesControl.controls, hasLength(1));
    expect(find.text('Meal type 1'), findsOneWidget);
    expect(find.byTooltip('Remove'), findsOneWidget);
  });

  testWidgets('the water tracking switch updates the saved nutrition task', (
    tester,
  ) async {
    final viewModel = NutritionFormViewModel(study: Study.withId('study-1'));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReactiveForm(
              formGroup: viewModel.form,
              child: NutritionFormView(formViewModel: viewModel),
            ),
          ),
        ),
      ),
    );

    expect(
      viewModel.buildFormData().toNutritionTask().trackWaterIntake,
      isFalse,
    );
    final waterSwitch = find.byWidgetPredicate(
      (widget) =>
          widget is ReactiveSwitch &&
          identical(widget.formControl, viewModel.trackWaterIntakeControl),
    );
    await tester.tap(waterSwitch);
    await tester.pump();
    expect(
      viewModel.buildFormData().toNutritionTask().trackWaterIntake,
      isTrue,
    );

    await tester.tap(waterSwitch);
    await tester.pump();
    expect(
      viewModel.buildFormData().toNutritionTask().trackWaterIntake,
      isFalse,
    );
  });

  testWidgets('removing a custom meal type preserves the next field', (
    tester,
  ) async {
    final viewModel = NutritionFormViewModel(study: Study.withId('study-1'));
    viewModel.customMealTypesControl.add(
      FormControl<String>(value: 'First meal'),
    );
    viewModel.customMealTypesControl.add(
      FormControl<String>(value: 'Second meal'),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReactiveForm(
              formGroup: viewModel.form,
              child: NutritionFormView(formViewModel: viewModel),
            ),
          ),
        ),
      ),
    );

    final firstRemove = find.byTooltip('Remove').first;
    await tester.ensureVisible(firstRemove);
    await tester.tap(firstRemove);
    await tester.pumpAndSettle();
    expect(find.text('Second meal'), findsOneWidget);
    expect(find.text('First meal'), findsNothing);

    final survivingField = find.ancestor(
      of: find.text('Second meal'),
      matching: find.byType(TextField),
    );
    await tester.enterText(survivingField, 'Updated meal');
    expect(viewModel.buildFormData().customMealTypes, ['Updated meal']);
  });
}

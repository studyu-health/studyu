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

  test('preserves the hidden legacy completion setting', () {
    final formViewModel = NutritionFormViewModel(
      study: Study.withId('study-1'),
    );
    formViewModel.requireDailyCompletionConfirmationControl.value = true;

    expect(
      formViewModel.buildFormData().requireDailyCompletionConfirmation,
      isTrue,
    );
    expect(
      formViewModel
          .buildFormData()
          .toNutritionTask()
          .requireDailyCompletionConfirmation,
      isTrue,
    );
  });

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
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_controls_view.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const NutritionFormView({
  required final NutritionFormViewModel formViewModel,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<NutritionFormView> createState() => _NutritionFormViewState();
}

class _NutritionFormViewState() extends ConsumerState<NutritionFormView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              control: widget.formViewModel.titleControl,
              label: tr.form_field_measurement_survey_title,
              input: ReactiveTextField(
                formControl: widget.formViewModel.titleControl,
                decoration: InputDecoration(
                  hintText: tr.form_field_nutrition_default_title,
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
                validationMessages:
                    widget.formViewModel.titleControl.validationMessages,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.instructionsControl,
              label: tr.form_field_nutrition_instructions,
              input: ReactiveTextField(
                formControl: widget.formViewModel.instructionsControl,
                decoration: InputDecoration(
                  hintText: tr.form_field_nutrition_instructions_hint,
                ),
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 5,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.collectMealContextControl,
              label: tr.form_field_nutrition_collect_meal_context,
              input: ReactiveSwitch(
                formControl: widget.formViewModel.collectMealContextControl,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.allowRecipesControl,
              label: tr.form_field_nutrition_allow_recipes,
              input: ReactiveSwitch(
                formControl: widget.formViewModel.allowRecipesControl,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.minimumMealsRequiredControl,
              label: tr.form_field_nutrition_minimum_meals_required,
              input: ReactiveTextField(
                formControl: widget.formViewModel.minimumMealsRequiredControl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: tr.form_field_nutrition_minimum_meals_hint,
                ),
                validationMessages: widget
                    .formViewModel
                    .minimumMealsRequiredControl
                    .validationMessages,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20.0),
        _CustomMealTypesSection(
          formViewModel: widget.formViewModel,
          isReadonly: widget.formViewModel.isReadonly,
        ),
        const SizedBox(height: 28.0),
        ScheduleControls(
          formViewModel: widget.formViewModel,
          isReadonly: widget.formViewModel.isReadonly,
        ),
      ],
    );
  }
}

class const _CustomMealTypesSection({
  required final NutritionFormViewModel formViewModel,
  required final bool isReadonly,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr.form_field_nutrition_custom_meal_types,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isReadonly)
              TextButton.icon(
                onPressed: () {
                  formViewModel.customMealTypesControl.add(
                    FormControl<String>(value: ''),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: Text(tr.form_field_nutrition_add_meal_type),
              ),
          ],
        ),
        if (formViewModel.customMealTypesControl.controls.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              tr.form_field_nutrition_custom_meal_types_hint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ReactiveFormArray<String>(
            formArray: formViewModel.customMealTypesControl,
            builder: (context, formArray, child) {
              return Column(
                children: List.generate(
                  formArray.controls.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ReactiveTextField<String>(
                            formControl:
                                formArray.controls[index]
                                    as FormControl<String>,
                            decoration: InputDecoration(
                              hintText:
                                  '${tr.form_field_nutrition_custom_meal_types} ${index + 1}',
                              isDense: true,
                            ),
                            readOnly: isReadonly,
                          ),
                        ),
                        if (!isReadonly)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 20,
                            ),
                            onPressed: () => formArray.removeAt(index),
                            tooltip: 'Remove',
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

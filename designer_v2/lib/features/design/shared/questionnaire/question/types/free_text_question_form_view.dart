import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/input_formatter.dart';

class const FreeTextQuestionFormView({
  required final QuestionFormViewModel formViewModel,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final minLength = formViewModel.freeTextLengthControl.value!.start.toInt();
    final maxLength = formViewModel.freeTextLengthControl.value!.end.toInt();
    final type = formViewModel.freeTextTypeControl.value!.string;
    formViewModel.freeTextLengthControl.onChanged(
      (_) => formViewModel.freeTextExampleTextControl.updateValueAndValidity(),
    );

    final isCustomType =
        formViewModel.freeTextTypeControl.value == FreeTextQuestionType.custom;

    return Column(
      children: [
        if (!isCustomType)
          generateRow(
            label: tr.free_text_range_label,
            labelHelpText: tr.free_text_range_label_helper,
            input: disableOnReadonly(
              child: Row(
                children: [
                  Expanded(
                    child: ReactiveTextField(
                      formControl:
                          formViewModel.freeTextLengthMin as FormControl<int>,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        NumericalRangeFormatter(
                          min: QuestionFormViewModel.kDefaultFreeTextMinLength,
                          max: QuestionFormViewModel.kDefaultFreeTextMaxLength,
                        ),
                      ],
                      onChanged: (_) {
                        final min = formViewModel.freeTextLengthMin.value;
                        final currentMax =
                            formViewModel.freeTextLengthMax.value;
                        if (min == null) return;

                        final newMin = min.clamp(
                          QuestionFormViewModel.kDefaultFreeTextMinLength,
                          QuestionFormViewModel.kDefaultFreeTextMaxLength,
                        );
                        var newMax = (currentMax ?? newMin).clamp(
                          QuestionFormViewModel.kDefaultFreeTextMinLength,
                          QuestionFormViewModel.kDefaultFreeTextMaxLength,
                        );

                        if (newMin > newMax) {
                          newMax = newMin;
                          formViewModel.freeTextLengthMax.value = newMax;
                        }

                        formViewModel.freeTextLengthControl.value = RangeValues(
                          newMin.toDouble(),
                          newMax.toDouble(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ReactiveTextField(
                      formControl:
                          formViewModel.freeTextLengthMax as FormControl<int>,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        NumericalRangeFormatter(
                          min: QuestionFormViewModel.kDefaultFreeTextMinLength,
                          max: QuestionFormViewModel.kDefaultFreeTextMaxLength,
                        ),
                      ],
                      onChanged: (_) {
                        final max = formViewModel.freeTextLengthMax.value;
                        final currentMin =
                            formViewModel.freeTextLengthMin.value;
                        if (max == null) return;

                        final newMax = max.clamp(
                          QuestionFormViewModel.kDefaultFreeTextMinLength,
                          QuestionFormViewModel.kDefaultFreeTextMaxLength,
                        );
                        var newMin = (currentMin ?? newMax).clamp(
                          QuestionFormViewModel.kDefaultFreeTextMinLength,
                          QuestionFormViewModel.kDefaultFreeTextMaxLength,
                        );

                        if (newMax < newMin) {
                          newMin = newMax;
                          formViewModel.freeTextLengthMin.value = newMin;
                        }

                        formViewModel.freeTextLengthControl.value = RangeValues(
                          newMin.toDouble(),
                          newMax.toDouble(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!isCustomType) const SizedBox(height: 16.0),
        generateRow(
          label: tr.free_text_type_label,
          labelHelpText: tr.free_text_type_label_helper,
          input: ReactiveDropdownField(
            formControl: formViewModel.freeTextTypeControl,
            items: FreeTextQuestionType.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.string)))
                .toList(),
            decoration: InputDecoration(
              helperText:
                  generateLabelHelpTextMap[formViewModel
                      .freeTextTypeControl
                      .value],
            ),
            onChanged: (_) {
              formViewModel.freeTextExampleTextControl.updateValueAndValidity();
            },
          ),
        ),
        const SizedBox(height: 16.0),
        // Show additional text field when custom is selected
        if (formViewModel.freeTextTypeControl.value ==
            FreeTextQuestionType.custom)
          Column(
            children: [
              generateRow(
                label: tr.free_text_type_custom_label,
                labelHelpText: tr.free_text_type_custom_label_helper,
                input: ReactiveTextField(
                  formControl: formViewModel.customRegexControl,
                  decoration: InputDecoration(
                    helperText: tr.free_text_type_custom_helper,
                    prefix: const Text('^'),
                    suffix: const Text('\$'),
                  ),
                  validationMessages: {
                    ValidationMessage.required: (error) =>
                        tr.form_field_required,
                    ValidationMessage.pattern: (error) =>
                        tr.free_text_validation_pattern,
                  },
                  onChanged: (_) {
                    formViewModel.freeTextExampleTextControl
                        .updateValueAndValidity();
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              TextParagraph(
                text: tr.free_text_type_custom_explanation,
                style: ThemeConfig.bodyTextMuted(theme),
              ),
            ],
          ),
        const SizedBox(height: 16.0),
        // generate line
        const Divider(thickness: 2.0),
        const SizedBox(height: 16.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            generateRow(
              label: tr.free_text_example_label,
              labelHelpText: tr.free_text_example_label_helper,
              input: Row(
                children: [
                  Expanded(
                    child: ReactiveValueListenableBuilder(
                      formControl: formViewModel.freeTextExampleTextControl,
                      builder: (context, formControl, child) {
                        final borderColor = (formControl.dirty)
                            ? Colors.green
                            : theme
                                      .inputDecorationTheme
                                      .enabledBorder
                                      ?.borderSide
                                      .color ??
                                  Colors.yellow;
                        return ReactiveTextField(
                          formControl: formViewModel.freeTextExampleTextControl,
                          maxLines: null,
                          decoration: InputDecoration(
                            helperText: (formControl.dirty && formControl.valid)
                                ? tr.free_text_example_valid
                                : tr.free_text_example_default_helper,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: borderColor),
                            ),
                          ),
                          showErrors: (control) =>
                              control.invalid && control.dirty,
                          validationMessages: {
                            ValidationMessage.minLength: (error) =>
                                tr.free_text_validation_min_length(minLength),
                            ValidationMessage.maxLength: (error) =>
                                tr.free_text_validation_max_length(maxLength),
                            ValidationMessage.pattern: (error) =>
                                tr.free_text_validation_pattern,
                            ValidationMessage.number: (error) =>
                                tr.free_text_validation_number,
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            ReactiveFormConsumer(
              builder: (context, formGroup, child) {
                return TextParagraph(
                  text: isCustomType
                      ? tr.free_text_example_explanation_custom(type)
                      : tr.free_text_example_explanation(
                          type,
                          minLength,
                          maxLength,
                        ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget disableOnReadonly({required Widget child}) {
    if (formViewModel.isReadonly) {
      return AbsorbPointer(child: child);
    } else {
      return child;
    }
  }

  Map<FreeTextQuestionType, String> get generateLabelHelpTextMap {
    return {
      FreeTextQuestionType.any: tr.free_text_question_type_any_explanation,
      FreeTextQuestionType.alphanumeric:
          tr.free_text_question_type_alphanumeric_explanation,
      FreeTextQuestionType.numeric:
          tr.free_text_question_type_numeric_explanation,
      FreeTextQuestionType.custom:
          tr.free_text_question_type_custom_explanation,
    };
  }

  Widget generateRow({
    required String label,
    required String labelHelpText,
    required Widget input,
  }) {
    return Row(
      children: [
        Flexible(
          flex: 5,
          child: FormTableLayout(
            rowLayout: FormTableRowLayout.vertical,
            rows: [
              FormTableRow(
                label: label,
                labelHelpText: labelHelpText,
                input: input,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_menu.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class const ChoiceQuestionFormView({
  required final QuestionFormViewModel formViewModel,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ReactiveValueListenableBuilder<bool>(
          formControl: formViewModel.isMultipleChoiceControl,
          builder: (context, control, _) => FormTableLayout(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            rows: [
              FormTableRow(
                label: tr.form_field_response_choice_multiple,
                labelHelpText: tr.form_field_response_choice_multiple_tooltip,
                input: ReactiveSwitch(
                  formControl: formViewModel.isMultipleChoiceControl,
                ),
              ),
              if (control.value == true)
                FormTableRow(
                  label: tr.form_field_response_choice_required,
                  labelHelpText: tr.form_field_response_choice_required_tooltip,
                  input: ReactiveSwitch(
                    formControl: formViewModel.isSelectionRequiredControl,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),
        ReactiveFormArray(
          formArray: formViewModel.answerOptionsArray,
          builder: (context, formArray, child) {
            return StandardTable<AbstractControl>(
              items: formViewModel.answerOptionsControls,
              columns: [
                StandardTableColumn(
                  label: '', // don't care (showTableHeader=false)
                  columnWidth: const FixedColumnWidth(32.0),
                ),
                StandardTableColumn(
                  label: '', // don't care (showTableHeader=false),),
                ),
              ],
              onSelectItem: (_) => {},
              // no-op
              buildCellsAt: (context, control, _, _) =>
                  buildChoiceOptionRow(context, control),
              trailingActionsAt: (control, _) =>
                  formViewModel.availableActions(control),
              cellSpacing: 0.0,
              rowSpacing: 8.0,
              minRowHeight: null,
              showTableHeader: false,
              rowStyle: StandardTableStyle.plain,
              trailingActionsMenuType: ActionMenuType.inline,
              disableRowInteractions: true,
              trailingWidget:
                  (formViewModel.isAddOptionButtonVisible &&
                      !formViewModel.isReadonly)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Opacity(
                        opacity: ThemeConfig.kMuteFadeFactor,
                        child: TextButton.icon(
                          onPressed: formViewModel.onNewItem,
                          icon: const Icon(Icons.add),
                          label: Text(
                            tr.form_array_response_options_choice_new,
                          ),
                        ),
                      ),
                    )
                  : null,
              trailingWidgetSpacing: 0,
            );
          },
        ),
      ],
    );
  }
}

/// Helper to build a single row in the table of bullet-style response options
List<Widget> buildChoiceOptionRow(
  BuildContext context,
  AbstractControl formControl,
) {
  final theme = Theme.of(context);
  return [
    Center(
      child: Icon(
        Icons.radio_button_off_outlined,
        color: theme.dividerTheme.color ?? theme.dividerColor,
        size: 12.0,
      ),
    ),
    if (formControl is FormControl<Choice>)
      ReactiveTextField<Choice>(
        formControl: formControl,
        valueAccessor: ChoiceValueAccessor(formControl),
        decoration: InputDecoration(
          hintText: tr.form_array_response_options_choice_hint,
        ),
      )
    else
      ReactiveTextField<String>(
        formControl: formControl as FormControl<String>,
        decoration: InputDecoration(
          hintText: tr.form_array_response_options_choice_hint,
        ),
      ),
  ];
}

class ChoiceValueAccessor([final FormControl<Choice>? _control])
    extends ControlValueAccessor<Choice, String> {
  @override
  String? modelToViewValue(Choice? modelValue) {
    return modelValue?.text;
  }

  @override
  Choice? viewToModelValue(String? viewValue) {
    return Choice.withText(id: _control?.value?.id, text: viewValue ?? '');
  }
}

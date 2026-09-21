import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/data_reference_editor.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/section_type.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class const LinearRegressionSectionFormView({
  required final ReportItemFormViewModel formViewModel,
  required final StudyID studyId,
  required final Map<int, TableColumnWidth> reportSectionColumnWidth,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final study = ref
        .watch(studyControllerProvider(studyId))
        .studyValueRequired;
    final availableTasks = <Task>[
      ...study.interventions.expand((intervention) => intervention.tasks),
      ...study.observations,
    ];
    return Column(
      children: [
        FormTableLayout(
          columnWidths: reportSectionColumnWidth,
          rows: [
            FormTableRow(
              label: tr.form_field_report_improvementDirection_title,
              labelHelpText: tr.form_field_report_improvementDirection_tooltip,
              // TODO: extract custom dropdown component with theme + focus fix
              input: Theme(
                data: theme.copyWith(
                  inputDecorationTheme:
                      ThemeConfig.dropdownInputDecorationTheme(theme),
                ),
                child: ReactiveDropdownField<ImprovementDirectionFormatted>(
                  formControl: formViewModel.improvementDirectionControl,
                  hint: Text(tr.form_field_report_improvementDirection_hint),
                  items: ReportItemFormViewModel
                      .improvementDirectionControlOptions
                      .map((option) {
                        final menuItemTheme = ThemeConfig.dropdownMenuItemTheme(
                          theme,
                        );
                        final iconTheme =
                            menuItemTheme.iconTheme ?? theme.iconTheme;
                        return DropdownMenuItem(
                          value: option.value,
                          child: Row(
                            children: [
                              if (option.value.icon != null)
                                Icon(
                                  option.value.icon,
                                  size: iconTheme.size,
                                  color: iconTheme.color,
                                  shadows: iconTheme.shadows,
                                )
                              else
                                const SizedBox.shrink(),
                              const SizedBox(width: 16.0),
                              Text(option.label),
                            ],
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            ),
            FormTableRow(
              control: formViewModel.alphaControl,
              label: tr.form_field_report_linearRegression_alpha_title,
              labelHelpText:
                  tr.form_field_report_linearRegression_alpha_tooltip,
              input: ReactiveTextField(
                formControl: formViewModel.alphaControl,
                validationMessages:
                    formViewModel.alphaControl.validationMessages,
                decoration: InputDecoration(
                  hintText: tr.form_field_report_linearRegression_alpha_hint,
                ),
              ),
            ),
            DataReferenceEditor<num>(
              formControl: formViewModel.dataReferenceControl,
              availableTasks: availableTasks,
            ).buildFormTableRow(theme),
          ],
        ),
      ],
    );
  }
}

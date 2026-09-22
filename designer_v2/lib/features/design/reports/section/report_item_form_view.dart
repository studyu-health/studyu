import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/average_section_form_view.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/descriptive_stats_section_form_view.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/gauge_comparison_section_form_view.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/linear_regression_section_form_view.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/section_type.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/textual_summary_section_form_view.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class const ReportItemFormView({
  required final ReportItemFormViewModel formViewModel,
  required final StudyID studyId,
  super.key,
}) extends StatelessWidget {
  Map<int, TableColumnWidth> get reportSectionColumnWidth => const {
    0: FixedColumnWidth(180.0),
    1: FlexColumnWidth(),
  };

  WidgetBuilder get sectionTypeBodyBuilder {
    final Map<ReportSectionType, WidgetBuilder> sectionTypeWidgets = {
      ReportSectionType.average: (_) => AverageSectionFormView(
        formViewModel: formViewModel,
        studyId: studyId,
        reportSectionColumnWidth: reportSectionColumnWidth,
      ),
      ReportSectionType.linearRegression: (_) =>
          LinearRegressionSectionFormView(
            formViewModel: formViewModel,
            studyId: studyId,
            reportSectionColumnWidth: reportSectionColumnWidth,
          ),
      ReportSectionType.textualSummary: (_) => TextualSummarySectionFormView(
        formViewModel: formViewModel,
        studyId: studyId,
        reportSectionColumnWidth: reportSectionColumnWidth,
      ),
      ReportSectionType.gaugeComparison: (_) => GaugeComparisonSectionFormView(
        formViewModel: formViewModel,
        studyId: studyId,
        reportSectionColumnWidth: reportSectionColumnWidth,
      ),
      ReportSectionType.descriptiveStats: (_) =>
          DescriptiveStatsSectionFormView(
            formViewModel: formViewModel,
            studyId: studyId,
            reportSectionColumnWidth: reportSectionColumnWidth,
          ),
    };
    final sectionType = formViewModel.sectionType;

    if (!sectionTypeWidgets.containsKey(sectionType)) {
      throw Exception(
        "Failed to build widget for ReportSectionType $sectionType "
        "because there is no registered WidgetBuilder",
      );
    }
    final builder = sectionTypeWidgets[sectionType]!;
    return builder;
  }

  @override
  Widget build(BuildContext context) => ReactiveFormConsumer(
    builder: (context, formGroup, child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionText(context),
        _buildSectionTypeHeader(context),
        sectionTypeBodyBuilder(context),
      ],
    ),
  );

  FormTableLayout _buildSectionText(BuildContext context) {
    return FormTableLayout(
      rowLayout: FormTableRowLayout.vertical,
      rows: [
        FormTableRow(
          control: formViewModel.titleControl,
          label: tr.form_field_report_title,
          labelHelpText: tr.form_field_report_title_tooltip,
          input: ReactiveTextField(
            formControl: formViewModel.titleControl,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
            validationMessages: formViewModel.titleControl.validationMessages,
            decoration: InputDecoration(
              hintText: tr.form_field_report_title_hint,
            ),
          ),
        ),
        FormTableRow(
          control: formViewModel.descriptionControl,
          label: tr.form_field_report_text,
          labelHelpText: tr.form_field_report_text_tooltip,
          input: ReactiveTextField(
            formControl: formViewModel.descriptionControl,
            inputFormatters: [LengthLimitingTextInputFormatter(10000)],
            validationMessages:
                formViewModel.descriptionControl.validationMessages,
            keyboardType: TextInputType.multiline,
            minLines: 10,
            maxLines: 30,
            decoration: InputDecoration(
              hintText: tr.form_field_report_text_hint,
            ),
          ),
        ),
      ],
    );
  }

  Column _buildSectionTypeHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 16.0),
        FormTableLayout(
          columnWidths: reportSectionColumnWidth,
          rows: [
            FormTableRow(
              label: tr.form_field_report_section_type,
              labelHelpText: tr.form_field_report_section_type_tooltip,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              // TODO: extract custom dropdown component with theme + focus fix
              input: Theme(
                data: theme.copyWith(
                  inputDecorationTheme:
                      ThemeConfig.dropdownInputDecorationTheme(theme),
                ),
                child: ReactiveDropdownField<ReportSectionType>(
                  formControl: formViewModel.sectionTypeControl,
                  items: ReportItemFormViewModel.sectionTypeControlOptions.map((
                    option,
                  ) {
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
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        FormTableLayout(
          columnWidths: reportSectionColumnWidth,
          rows: [
            FormTableRow(
              input: TextParagraph(
                text: tr.form_field_report_section_type_description,
                style: ThemeConfig.bodyTextMuted(theme),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}

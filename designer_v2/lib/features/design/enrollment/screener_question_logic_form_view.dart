import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/enrollment/screener_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/choice_question_form_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

abstract class IScreenerQuestionLogicFormViewModel() {
  bool get isDirtyOptionsBannerVisible;
}

class const ScreenerQuestionLogicFormView({
  required final ScreenerQuestionFormViewModel formViewModel,
  super.key,
}) extends FormConsumerWidget {
  @override
  Widget build(BuildContext context, FormGroup form) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextParagraph(
          text: tr.form_array_screener_question_logic_description,
          style: ThemeConfig.bodyTextMuted(theme),
        ),
        const SizedBox(height: 16.0),
        FormLabel(
          labelText: tr.form_array_screener_question_logic_title,
          labelTextStyle: const TextStyle(fontWeight: FontWeight.bold),
          helpText: tr.form_array_screener_question_logic_tooltip,
        ),
        _buildInfoBanner(context),
        const SizedBox(height: 12.0),
        _buildAnswerOptionsLogicControls(),
      ],
    );
  }

  SingleChildRenderObjectWidget _buildInfoBanner(BuildContext context) {
    return (!formViewModel.isReadonly &&
            formViewModel.isDirtyOptionsBannerVisible)
        ? Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: BannerBox(
              style: BannerStyle.info,
              body: TextParagraph(
                text: tr.form_array_screener_question_logic_dirty_banner,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 12.0,
              ),
              noPrefix: true,
              isDismissed: !formViewModel.isMidValuesClearedInfoVisible,
              dismissIconSize: Theme.of(context).iconTheme.size ?? 14.0,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildAnswerOptionsLogicControls() {
    if (formViewModel.questionType.name == FreeTextQuestion.questionType) {
      // todo logic might check if field has content
      // todo logic might need that field is equal to a certain value
      return Text(
        tr.free_text_question_logic_not_supported,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      );
    }

    return ReactiveFormArray(
      formArray: formViewModel.responseOptionsDisabledArray,
      builder: (context, formArray, child) {
        return StandardTable<AbstractControl>(
          items: formViewModel.responseOptionsDisabledControls,
          columns: [
            StandardTableColumn(
              label: '', // don't care (showTableHeader=false)
              columnWidth: const FixedColumnWidth(32.0),
            ),
            StandardTableColumn(
              label: '', // don't care (showTableHeader=false)
              columnWidth: const FlexColumnWidth(5),
            ),
            StandardTableColumn(
              label: '', // don't care (showTableHeader=false)
              columnWidth: const FlexColumnWidth(4),
            ),
          ],
          onSelectItem: (_) => {}, // no-op
          buildCellsAt: (context, item, rowIdx, _) {
            final optionControl = item as FormControl<dynamic>;
            final logicControl =
                formViewModel.responseOptionsLogicControls.controls[rowIdx]
                    as FormControl<bool>;
            return _buildOptionLogicRow(context, optionControl, logicControl);
          },
          cellSpacing: 4.0,
          rowSpacing: 2.0,
          minRowHeight: null,
          showTableHeader: false,
          rowStyle: StandardTableStyle.plain,
          disableRowInteractions: true,
        );
      },
    );
  }

  List<Widget> _buildOptionLogicRow(
    BuildContext context,
    FormControl<dynamic> optionControl,
    FormControl<bool> logicControl,
  ) {
    final theme = Theme.of(context);

    // Use a UniqueKey to prevent carry-over of control states to other
    // sidesheet tabs
    final optionCells = buildChoiceOptionRow(context, optionControl);
    final iconWidget = optionCells[0];
    final optionWidget = optionCells[1];
    final logicWidget = Theme(
      data: theme.copyWith(
        inputDecorationTheme: ThemeConfig.dropdownInputDecorationTheme(theme),
      ),
      child: ReactiveDropdownField<bool>(
        formControl: logicControl,
        items: formViewModel.logicControlOptions.map((option) {
          return DropdownMenuItem(
            value: option.value,
            child: Text(option.label),
          );
        }).toList(),
      ),
    );

    return [iconWidget, optionWidget, logicWidget];
  }
}

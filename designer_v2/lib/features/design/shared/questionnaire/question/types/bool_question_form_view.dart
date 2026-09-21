import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/choice_question_form_view.dart';

class const BoolQuestionFormView({
  required final QuestionFormViewModel formViewModel,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Opacity(
          opacity: 0.5,
          child: StandardTable<AbstractControl>(
            items: formViewModel.answerOptionsControls,
            columns: [
              StandardTableColumn(
                label: '', // don't care (showTableHeader=false)
                columnWidth: const FixedColumnWidth(32.0),
              ),
              StandardTableColumn(
                label: '', // don't care (showTableHeader=false)),
              ),
            ],
            onSelectItem: (_) => {}, // no-op
            buildCellsAt: (context, control, _, _) =>
                buildChoiceOptionRow(context, control),
            trailingActionsAt: (control, _) => [],
            cellSpacing: 0.0,
            rowSpacing: 8.0,
            minRowHeight: null,
            showTableHeader: false,
            rowStyle: StandardTableStyle.plain,
            disableRowInteractions: true,
            trailingWidgetSpacing: 0,
          ),
        ),
      ],
    );
  }
}

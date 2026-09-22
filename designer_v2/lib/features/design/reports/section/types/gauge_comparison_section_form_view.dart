import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/data_reference_editor.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';

class const GaugeComparisonSectionFormView({
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
        //TODO: description how might it look like in the app
        FormTableLayout(
          columnWidths: reportSectionColumnWidth,
          rows: [
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

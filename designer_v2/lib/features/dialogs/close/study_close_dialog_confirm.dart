import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/study_title_confirmation_dialog.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const CloseConfirmationDialog(super.studyId, {super.key})
    extends StudyPageWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(studyControllerProvider(studyId).notifier);
    final state = ref.watch(studyControllerProvider(studyId));

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (Study study) {
        return StudyTitleConfirmationDialog(
          study: study,
          title: tr.dialog_study_close_title,
          description: tr.dialog_study_close_description,
          instruction: tr.dialog_study_close_type_name_instruction(
            study.title ?? '',
          ),
          textFieldLabel: tr.dialog_study_close_type_name_label,
          confirmLabel: tr.dialog_close,
          destructive: true,
          confirmationCheckboxes: [
            StudyConfirmationCheckbox(
              key: const ValueKey('study_close_irreversible_checkbox'),
              label: Text(tr.dialog_study_close_irreversible_confirmation),
            ),
          ],
          onConfirmed: controller.closeStudy,
        );
      },
    );
  }
}

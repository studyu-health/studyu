import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dialogs/close/study_close_dialog_confirm.dart';
import 'package:studyu_designer_v2/features/dialogs/close/study_close_dialog_success.dart';
import 'package:studyu_designer_v2/features/dialogs/publish/study_publish_dialog_confirm.dart';
import 'package:studyu_designer_v2/features/dialogs/publish/study_publish_dialog_success.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/theme.dart';

enum StudyDialogType() {
  publish,
  close,
}

class const StudyDialog(
  final StudyDialogType dialogType,
  super.studyId, {
  super.key,
}) extends StudyPageWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));

    switch (dialogType) {
      case StudyDialogType.publish:
        return state.isPublished
            ? PublishSuccessDialog(studyId)
            : PublishConfirmationDialog(studyId);
      case StudyDialogType.close:
        return state.isClosed
            ? CloseSuccessDialog(studyId)
            : CloseConfirmationDialog(studyId);
    }
  }
}

Future showStudyDialog(
  BuildContext context,
  StudyID studyId,
  StudyDialogType dialogType,
) {
  final theme = Theme.of(context);
  return showDialog(
    context: context,
    barrierColor: ThemeConfig.modalBarrierColor(theme),
    builder: (context) => StudyDialog(dialogType, studyId),
  );
}

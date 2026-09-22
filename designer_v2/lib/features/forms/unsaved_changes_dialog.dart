import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/confirmation_dialog.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const UnsavedChangesDialog({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StandardConfirmationDialog(
      title: tr.dialog_unsaved_changes_title,
      message: tr.dialog_unsaved_changes_description,
      actions: [
        ConfirmationDialogAction(
          label: tr.dialog_action_unsaved_changes_stay,
          onPressed: () => Navigator.pop(context, false),
        ),
        ConfirmationDialogAction(
          label: tr.dialog_action_unsaved_changes_discard,
          isDestructive: true,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}

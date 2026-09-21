import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/study_title_confirmation_dialog.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const StudyDeleteConfirmationDialog({
  required final Study study,
  required final String confirmLabel,
  required final Future<void> Function() onDownloadBackup,
  required final Future<void> Function() onCloseInstead,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StudyTitleConfirmationDialog(
      study: study,
      title: tr.dialog_study_delete_title,
      description: tr.dialog_study_delete_description,
      additionalContent: [
        SelectableText(tr.dialog_study_delete_warning_intro),
        const SizedBox(height: 16.0),
        _InlineDeleteAction(
          icon: Icons.download_rounded,
          description: tr.dialog_study_delete_backup_step,
          actionLabel: tr.dialog_study_delete_download_backup,
          onPressed: onDownloadBackup,
        ),
        const SizedBox(height: 8.0),
        _InlineDeleteAction(
          icon: Icons.lock_rounded,
          description: tr.dialog_study_delete_close_step,
          actionLabel: tr.dialog_study_delete_close_instead,
          onPressed: onCloseInstead,
        ),
      ],
      instruction: tr.dialog_study_delete_type_name_instruction(
        study.title ?? '',
      ),
      textFieldLabel: tr.dialog_study_delete_type_name_label,
      textFieldKey: const ValueKey('study_delete_name_confirmation_field'),
      confirmLabel: confirmLabel,
      confirmationCheckboxes: [
        StudyConfirmationCheckbox(
          key: const ValueKey('study_delete_data_checkbox'),
          label: Text(tr.dialog_study_delete_data_confirmation),
        ),
        StudyConfirmationCheckbox(
          key: const ValueKey('study_delete_participant_checkbox'),
          label: Text(tr.dialog_study_delete_participant_confirmation),
        ),
        StudyConfirmationCheckbox(
          key: const ValueKey('study_delete_irreversible_checkbox'),
          label: Text(tr.dialog_study_delete_irreversible_confirmation),
        ),
      ],
      destructive: true,
      onConfirmed: () async => Navigator.of(context).pop(true),
    );
  }
}

class const _InlineDeleteAction({
  required final IconData icon,
  required final String description,
  required final String actionLabel,
  required final Future<void> Function() onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Icon(icon, color: colorScheme.primary, size: 20.0),
        ),
        const SizedBox(width: 12.0),
        Expanded(child: SelectableText(description)),
        const SizedBox(width: 12.0),
        OutlinedButton(onPressed: () => onPressed(), child: Text(actionLabel)),
      ],
    );
  }
}

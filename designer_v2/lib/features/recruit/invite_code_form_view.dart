import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/common_views/collapse.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/qr_code_preview_dialog.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/services/clipboard.dart';

class const InviteCodeFormView({
  required final InviteCodeFormViewModel formViewModel,
  super.key,
}) extends FormConsumerRefWidget {
  @override
  Widget build(BuildContext context, FormGroup form, WidgetRef ref) {
    final isEditableCodeField = formViewModel.formMode == FormMode.create;
    final theme = Theme.of(context);
    final code = formViewModel.codeControl.value?.trim().toLowerCase() ?? '';
    final inviteLink = env.generateAppDeepLink('invite/$code');
    final androidPackageName = env.androidPackageName;
    final iosAppStoreId = env.iosAppStoreId;
    final androidInstallLink =
        androidPackageName == null || androidPackageName.isEmpty
        ? null
        : 'https://play.google.com/store/apps/details?id=$androidPackageName&referrer=${Uri.encodeComponent("invite=$code")}';
    final iosInstallLink = iosAppStoreId == null || iosAppStoreId.isEmpty
        ? null
        : 'https://apps.apple.com/app/id$iosAppStoreId';
    final studyTitle =
        formViewModel.study.title ?? tr.form_field_study_title_default;
    final invitationMessage = [
      tr.invitation_message_intro(studyTitle),
      '',
      tr.invitation_message_install_app,
      if (androidInstallLink != null)
        tr.invitation_message_android(androidInstallLink),
      if (iosInstallLink != null) tr.invitation_message_ios(iosInstallLink),
      '',
      tr.invitation_message_open_link,
      inviteLink,
      '',
      tr.invitation_message_alternative,
      code,
    ].join('\n');

    Future<void> copyInviteCode() async {
      await ref
          .read(clipboardServiceProvider)
          .copy(formViewModel.codeControl.value?.trim().toLowerCase() ?? '');
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(tr.notification_invite_code_copied),
            showCloseIcon: true,
          ),
        );
    }

    Future<void> copyInvitation() async {
      await ref.read(clipboardServiceProvider).copy(invitationMessage);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(tr.notification_invitation_copied),
            showCloseIcon: true,
          ),
        );
    }

    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              label: tr.form_field_code,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              labelHelpText: tr.form_field_code_tooltip,
              control: formViewModel.codeControl,
              input: isEditableCodeField
                  ? ReactiveTextField(
                      formControl: formViewModel.codeControl,
                      validationMessages:
                          formViewModel.codeControl.validationMessages,
                      decoration: InputDecoration(
                        helperText: '',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Tooltip(
                                message: tr.action_copy_invite_code,
                                child: IconButton(
                                  splashRadius: 18.0,
                                  onPressed: copyInviteCode,
                                  icon: const Icon(Icons.copy_rounded),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Material(
                                color: Colors.transparent,
                                child: IconButton(
                                  splashRadius: 18.0,
                                  tooltip: tr.action_regenerate_invite_code,
                                  onPressed: formViewModel.regenerateCode,
                                  icon: const Icon(Icons.refresh_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Material(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        mouseCursor: SystemMouseCursors.click,
                        onTap: copyInviteCode,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  code,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Tooltip(
                                message: tr.action_copy_invite_code,
                                preferBelow: true,
                                child: Icon(
                                  Icons.copy_rounded,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            FormTableRow(
              label: tr.form_field_invite_link,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              labelHelpText: tr.form_field_invite_link_tooltip,
              input: InviteLinkPreview(data: inviteLink),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        QrCodePreview(
          data: inviteLink,
          showInviteLink: false,
          downloadFilename: 'studyu-invite-$code',
        ),
        const SizedBox(height: 24.0),
        Collapsible(
          title: tr.form_field_invitation_message,
          contentBuilder: (context, _) => SizedBox(
            width: double.infinity,
            child: Material(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                mouseCursor: SystemMouseCursors.click,
                onTap: copyInvitation,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          invitationMessage,
                          key: const ValueKey('invitation_message_preview'),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Tooltip(
                        message: tr.action_copy_invitation,
                        preferBelow: true,
                        child: Icon(
                          Icons.copy_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 48.0),
        FormTableLayout(
          rows: [
            FormTableRow(
              label: tr.form_field_is_preconfigured_schedule,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              input: ReactiveSwitch(
                formControl: formViewModel.isPreconfiguredScheduleControl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        TextParagraph(
          text: tr.form_field_is_preconfigured_schedule_description,
        ),
        if (formViewModel.isPreconfiguredSchedule) ...[
          const SizedBox(height: 24.0),
          FormTableLayout(rows: _conditionalInterventionRows(context)),
        ],
      ],
    );
  }

  List<FormTableRow> _conditionalInterventionRows(BuildContext context) {
    if (!formViewModel.isPreconfiguredSchedule) {
      return [];
    }

    return [
      FormTableRow(
        label: tr.form_field_preconfigured_schedule_type,
        input: ReactiveDropdownField<PhaseSequence>(
          formControl: formViewModel.preconfiguredScheduleTypeControl,
          //decoration: const NullHelperDecoration(),
          readOnly: true,
          items: formViewModel.preconfiguredScheduleTypeOptions
              .map(
                (option) => DropdownMenuItem(
                  value: option.value,
                  child: Text(option.label),
                ),
              )
              .toList(),
        ),
      ),
      FormTableRow(
        label: tr.form_field_preconfigured_schedule_intervention_a,
        input: ReactiveDropdownField<String>(
          formControl: formViewModel.interventionAControl,
          hint: Text(tr.form_field_preconfigured_schedule_intervention_hint),
          //decoration: const NullHelperDecoration(),
          items: formViewModel.interventionControlOptions
              .map(
                (option) => DropdownMenuItem(
                  value: option.value,
                  child: Text(option.label),
                ),
              )
              .toList(),
        ),
      ),
      FormTableRow(
        label: tr.form_field_preconfigured_schedule_intervention_b,
        input: ReactiveDropdownField<String>(
          formControl: formViewModel.interventionBControl,
          hint: Text(tr.form_field_preconfigured_schedule_intervention_hint),
          //decoration: const NullHelperDecoration(),
          items: formViewModel.interventionControlOptions
              .map(
                (option) => DropdownMenuItem(
                  value: option.value,
                  child: Text(option.label),
                ),
              )
              .toList(),
        ),
      ),
    ];
  }
}

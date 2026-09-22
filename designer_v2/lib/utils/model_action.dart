import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/confirmation_dialog.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

typedef ModelActionHandler = FutureOr<void> Function();
typedef ModelActionConfirmationDialogBuilder = Widget Function(
  BuildContext dialogContext,
  ModelAction action,
);

class const ModelActionConfirmation({
  required final String title,
  final String? message,
  final String? confirmLabel,
  final String? cancelLabel,
  final IconData? icon,
  final Widget? customContent,
  final ModelActionConfirmationDialogBuilder? dialogBuilder,
});

class ModelActionConfirmations() {
  static ModelActionConfirmation delete({
    required String subject,
    String? title,
    String? message,
    IconData? icon,
  }) {
    return ModelActionConfirmation(
      title: title ?? tr.dialog_delete_title(subject),
      message: message ?? tr.dialog_delete_description(subject),
      icon: icon,
    );
  }

  static ModelActionConfirmation remove({
    required String subject,
    String? title,
    String? message,
    IconData? icon,
  }) {
    return ModelActionConfirmation(
      title: title ?? tr.dialog_remove_title(subject),
      message: message ?? tr.dialog_remove_description(subject),
      icon: icon,
    );
  }
}

class ModelAction<T>({
  required final T type,
  required final String label,
  required final ModelActionHandler onExecute,
  final dynamic Function(BuildContext context)? onExecuteWithContext,
  final ModelActionConfirmation? confirmation,
  final bool isSeparator = false,
  final bool isHeader = false,
  final bool isAvailable = true,
  final bool isDestructive = false,
  var IconData? icon,
  final String? tooltip,
  final bool isChecked = false,
  final bool showBadge = false,
}) {
  static ModelAction addSeparator() {
    return ModelAction(
      type: null,
      label: '',
      onExecute: () {},
      isSeparator: true,
    );
  }

  static ModelAction addHeader(String label) {
    return ModelAction(
      type: null,
      label: label,
      onExecute: () {},
      isHeader: true,
    );
  }

  Future<void> execute(BuildContext context) async {
    if (confirmation != null) {
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final dialogBuilder = confirmation!.dialogBuilder;
          if (dialogBuilder != null) {
            return dialogBuilder(dialogContext, this);
          }

          return StandardConfirmationDialog(
            title: confirmation!.title,
            message: confirmation!.message,
            customContent: confirmation!.customContent,
            icon: confirmation!.icon,
            actions: [
              ConfirmationDialogAction(
                label: confirmation!.cancelLabel ?? tr.dialog_cancel,
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
              ConfirmationDialogAction(
                label: confirmation!.confirmLabel ?? label,
                isDestructive: isDestructive,
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
            ],
          );
        },
      );
      if (confirmed != true) {
        return;
      }
    }

    if (onExecuteWithContext != null) {
      await Future.sync(() => onExecuteWithContext!(context));
      return;
    }

    await Future.sync(onExecute);
  }
}

abstract class IModelActionProvider<V>() {
  List<ModelAction> availableActions(V model);
}

abstract class IListActionProvider<V>() extends IModelActionProvider<V> {
  void onSelectItem(V item);
  void onNewItem();
}

enum ModelActionType() {
  edit,
  delete,
  remove, // same semantics as delete
  duplicate,
  clipboard,
  copyLink,
  share,
  qrCodeShow,
  qrCodeDownload,
  primary, // ReportSection
}

/// Provides a human-readable translation of the model action type
extension ModelActionTypeFormatted on ModelActionType {
  String get string {
    switch (this) {
      case ModelActionType.edit:
        return tr.action_edit;
      case ModelActionType.delete:
        return tr.action_delete;
      case ModelActionType.remove:
        return tr.action_remove;
      case ModelActionType.duplicate:
        return tr.action_duplicate;
      case ModelActionType.clipboard:
        return tr.action_clipboard;
      case ModelActionType.copyLink:
        return tr.action_copy_link;
      case ModelActionType.share:
        return tr.action_share;
      case ModelActionType.qrCodeShow:
        return tr.action_qr_code_show;
      case ModelActionType.qrCodeDownload:
        return tr.action_qr_code_download;
      case ModelActionType.primary:
        return tr.action_reportPrimary;
    }
  }
}

Map<ModelActionType, IconData> modelActionIcons = {
  ModelActionType.edit: Icons.edit_rounded,
  ModelActionType.delete: Icons.delete_rounded,
  ModelActionType.remove: Icons.close_rounded,
  ModelActionType.duplicate: Icons.file_copy_rounded,
  ModelActionType.clipboard: Icons.copy_rounded,
  ModelActionType.copyLink: Icons.link_rounded,
  ModelActionType.share: Icons.ios_share_rounded,
  ModelActionType.qrCodeShow: Icons.qr_code_rounded,
  ModelActionType.qrCodeDownload: Icons.download_rounded,
  ModelActionType.primary: Icons.arrow_circle_up_rounded,
};

/// Decorates a list of [actions] with their corresponding icon
/// Helps us keep presentational data & business logic separate
List<ModelAction<T>> withIcons<T>(
  List<ModelAction<T>> actions,
  Map<T, IconData> iconMap,
) {
  for (final action in actions) {
    if (iconMap.containsKey(action.type)) {
      action.icon = iconMap[action.type];
    }
  }
  return actions;
}

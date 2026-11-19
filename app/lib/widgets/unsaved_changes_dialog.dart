import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/confirmation_dialog.dart';

enum UnsavedChangesAction() {
  discard,
}

Future<UnsavedChangesAction?> showUnsavedChangesDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String discardLabel,
  required String continueLabel,
}) async {
  final discard = await showConfirmationDialog(
    context,
    title: title,
    message: message,
    cancelLabel: continueLabel,
    confirmLabel: discardLabel,
    isDestructive: true,
  );
  return discard ? UnsavedChangesAction.discard : null;
}

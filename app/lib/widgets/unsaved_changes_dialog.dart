import 'package:flutter/material.dart';

enum UnsavedChangesAction() {
  discard,
}

Future<UnsavedChangesAction?> showUnsavedChangesDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String discardLabel,
  required String continueLabel,
}) => showDialog<UnsavedChangesAction>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext),
        child: Text(continueLabel),
      ),
      FilledButton(
        onPressed: () =>
            Navigator.pop(dialogContext, UnsavedChangesAction.discard),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(dialogContext).colorScheme.error,
          foregroundColor: Theme.of(dialogContext).colorScheme.onError,
        ),
        child: Text(discardLabel),
      ),
    ],
  ),
);

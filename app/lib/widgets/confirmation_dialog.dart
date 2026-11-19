import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  String? message,
  required String cancelLabel,
  required String confirmLabel,
  bool isDestructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colors = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        scrollable: true,
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: colors.onError,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}

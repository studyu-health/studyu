import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  String? message,
  required String cancelLabel,
  required String confirmLabel,
  bool isDestructive = false,
  bool sideBySideActions = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colors = Theme.of(dialogContext).colorScheme;
      const compactPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      final actions = [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          style: sideBySideActions
              ? TextButton.styleFrom(padding: compactPadding)
              : null,
          child: Text(
            cancelLabel,
            textAlign: sideBySideActions ? TextAlign.center : null,
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: isDestructive || sideBySideActions
              ? FilledButton.styleFrom(
                  backgroundColor: isDestructive ? colors.error : null,
                  foregroundColor: isDestructive ? colors.onError : null,
                  padding: sideBySideActions ? compactPadding : null,
                )
              : null,
          child: Text(
            confirmLabel,
            textAlign: sideBySideActions ? TextAlign.center : null,
          ),
        ),
      ];
      return AlertDialog(
        scrollable: true,
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: sideBySideActions
            ? [
                Row(
                  spacing: 8,
                  children: [
                    for (final action in actions) Expanded(child: action),
                  ],
                ),
              ]
            : actions,
      );
    },
  );
  return confirmed == true;
}

import 'package:flutter/material.dart';

class const NutritionSheetAction<T>({
  required final T value,
  required final String label,
  required final IconData icon,
  final bool isDestructive = false,
});

Future<T?> showNutritionActionSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<NutritionSheetAction<T>> actions,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (sheetContext) {
    final theme = Theme.of(sheetContext);
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            for (final action in actions) ...[
              if (action.isDestructive) const Divider(height: 1),
              ListTile(
                leading: Icon(action.icon),
                title: Text(action.label),
                iconColor: action.isDestructive
                    ? theme.colorScheme.error
                    : null,
                textColor: action.isDestructive
                    ? theme.colorScheme.error
                    : null,
                onTap: () => Navigator.pop(sheetContext, action.value),
              ),
            ],
          ],
        ),
      ),
    );
  },
);

import 'package:flutter/material.dart';

class const NutritionAddButton({
  required final String label,
  required final VoidCallback onPressed,
  final String? tooltip,
  final bool filled = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const icon = Icon(Icons.add);
    final text = Text(label);
    final button = filled
        ? FilledButton.icon(onPressed: onPressed, icon: icon, label: text)
        : TextButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: text,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
    if (tooltip case final message?) {
      return Tooltip(message: message, child: button);
    }
    return button;
  }
}

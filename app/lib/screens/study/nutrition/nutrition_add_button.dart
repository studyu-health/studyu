import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

enum FoodCreationAction() {
  food,
  meal,
}

Future<FoodCreationAction?> showFoodCreationSheet(
  BuildContext context, {
  required String mealLabel,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<FoodCreationAction>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.restaurant_outlined),
            title: Text(l10n.add_food_action),
            onTap: () => Navigator.pop(sheetContext, FoodCreationAction.food),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu_outlined),
            title: Text(mealLabel),
            onTap: () => Navigator.pop(sheetContext, FoodCreationAction.meal),
          ),
        ],
      ),
    ),
  );
}

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

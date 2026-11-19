import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

enum _FoodCreationAction() {
  food,
  meal,
}

class const FoodCreationButton({
  required final VoidCallback onCreateFood,
  final VoidCallback? onCreateMeal,
  final bool filled = false,
  super.key,
}) extends StatelessWidget {
  Future<void> _create(BuildContext context) async {
    final createMeal = onCreateMeal;
    if (createMeal == null) {
      onCreateFood();
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<_FoodCreationAction>(
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
              onTap: () =>
                  Navigator.pop(sheetContext, _FoodCreationAction.food),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu_outlined),
              title: Text(l10n.create_meal),
              onTap: () =>
                  Navigator.pop(sheetContext, _FoodCreationAction.meal),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;

    switch (action) {
      case _FoodCreationAction.food:
        onCreateFood();
      case _FoodCreationAction.meal:
        createMeal();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: NutritionAddButton(
        onPressed: () => _create(context),
        filled: filled,
        label: onCreateMeal == null ? l10n.add_food_action : l10n.create,
      ),
    );
  }
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

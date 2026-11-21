import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

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
    final trigger = context.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final anchor = MatrixUtils.transformRect(
      trigger.getTransformTo(overlay),
      Offset.zero & trigger.size,
    );
    final action = await showMenu<VoidCallback>(
      context: context,
      semanticLabel: l10n.create,
      position: RelativeRect.fromSize(
        Rect.fromLTRB(anchor.left, anchor.bottom, anchor.right, anchor.bottom),
        overlay.size,
      ),
      items: [
        _menuItem(
          onCreateFood,
          Icons.restaurant_outlined,
          l10n.add_food_action,
        ),
        _menuItem(createMeal, Icons.restaurant_menu_outlined, l10n.create_meal),
      ],
    );
    if (context.mounted) action?.call();
  }

  PopupMenuItem<VoidCallback> _menuItem(
    VoidCallback action,
    IconData icon,
    String label,
  ) => PopupMenuItem(
    value: action,
    child: Row(
      spacing: 8,
      children: [
        Icon(icon),
        Flexible(child: Text(label)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: NutritionAddButton(
        onPressed: () => _create(context),
        filled: filled && onCreateMeal != null,
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

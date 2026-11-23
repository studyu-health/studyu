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
      semanticLabel: l10n.nutrition_create_library_item,
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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.55,
        ),
        child: NutritionAddButton(
          onPressed: () => _create(context),
          filled: filled && onCreateMeal != null,
          icon: onCreateMeal == null ? Icons.add : Icons.library_books_outlined,
          opensMenu: onCreateMeal != null,
          label: onCreateMeal == null
              ? l10n.add_food_action
              : l10n.nutrition_create_library_item,
        ),
      ),
    );
  }
}

class const NutritionAddButton({
  required final String label,
  required final VoidCallback onPressed,
  required final IconData icon,
  final bool opensMenu = false,
  final bool filled = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final leading = Icon(icon);
    final labelText = Text(label, maxLines: 2, overflow: TextOverflow.ellipsis);
    final text = opensMenu
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: labelText),
              const Icon(Icons.expand_more),
            ],
          )
        : labelText;
    return filled
        ? FilledButton.icon(onPressed: onPressed, icon: leading, label: text)
        : TextButton.icon(
            onPressed: onPressed,
            icon: leading,
            label: text,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
  }
}

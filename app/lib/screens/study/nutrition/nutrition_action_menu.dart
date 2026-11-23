import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

class const NutritionActionMenu({
  required final PopupMenuItemBuilder<VoidCallback> itemBuilder,
  final bool enabled = true,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => PopupMenuButton<VoidCallback>(
    icon: const Icon(Icons.more_vert, size: 20),
    tooltip: AppLocalizations.of(context)!.more_options,
    position: PopupMenuPosition.under,
    enabled: enabled,
    onSelected: (action) => action(),
    itemBuilder: itemBuilder,
  );
}

PopupMenuItem<VoidCallback> nutritionActionMenuItem(
  String label,
  IconData icon,
  VoidCallback action, {
  Color? color,
}) => PopupMenuItem(
  value: action,
  child: Row(
    spacing: 8,
    children: [
      Icon(icon, color: color),
      Flexible(
        child: Text(
          label,
          style: color == null ? null : TextStyle(color: color),
        ),
      ),
    ],
  ),
);

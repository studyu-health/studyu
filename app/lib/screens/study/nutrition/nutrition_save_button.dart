import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

class const NutritionSaveButton({
  required final VoidCallback? onPressed,
  super.key,
}) extends StatelessWidget {
  static const double scrollClearance = 80;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: onPressed == null
          ? colors.onSurface.withValues(alpha: 0.12)
          : colors.primary,
      foregroundColor: onPressed == null
          ? colors.onSurface.withValues(alpha: 0.38)
          : colors.onPrimary,
      icon: const Icon(Icons.check),
      label: Text(AppLocalizations.of(context)!.save),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';

/// See also: [PrimaryButton]
class const SecondaryButton({
  /// The text displayed as the button label
  required final String text,

  /// The icon displayed to the left of the label
  final IconData? icon = Icons.add,

  /// If true, a loading indicator is displayed instead of the text
  final bool isLoading = false,

  /// Callback to be called when the button is pressed
  final VoidCallback? onPressed,
  final Color? foregroundColor,
  final Color? borderColor,
  final Size? minimumSize,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryStyle = OutlinedButton.styleFrom(
      foregroundColor: foregroundColor ?? theme.colorScheme.primary,
      side: BorderSide(color: borderColor ?? theme.colorScheme.primary),
      minimumSize: minimumSize,
    );

    if (icon != null) {
      return OutlinedButton.icon(
        style: secondaryStyle,
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
      );
    }
    return OutlinedButton(
      style: secondaryStyle,
      onPressed: onPressed,
      child: isLoading
          ? const CircularProgressIndicator()
          : Text(text, textAlign: TextAlign.center),
    );
  }
}

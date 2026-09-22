import 'package:flutter/material.dart';

class const SelectableButton({
  super.key,
  required final Widget child,
  final bool selected = false,
  final Function()? onTap,
}) extends StatelessWidget {
  Color _getFillColor(ThemeData theme) =>
      selected ? theme.primaryColor : theme.cardColor;

  Color _getTextColor(ThemeData theme) => selected ? Colors.white : Colors.blue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: _getTextColor(theme),
          backgroundColor: _getFillColor(theme),
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        onPressed: onTap,
        child: child,
      ),
    );
  }
}

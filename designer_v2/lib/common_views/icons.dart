import 'package:flutter/material.dart';

class const HelpIcon({final String? tooltipText, super.key})
    extends StatefulWidget {
  @override
  State<HelpIcon> createState() => _HelpIconState();
}

class _HelpIconState() extends State<HelpIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor =
        theme.iconTheme.color?.withValues(alpha: _hovered ? 0.6 : 0.35) ??
        theme.colorScheme.onSurface.withValues(alpha: 0.3);

    return Tooltip(
      message: widget.tooltipText,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Icon(
          Icons.help_outline_rounded,
          size: theme.textTheme.bodySmall!.fontSize! + 2.0,
          color: iconColor,
        ),
      ),
    );
  }
}

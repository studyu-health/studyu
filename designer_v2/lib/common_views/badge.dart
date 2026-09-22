import 'package:flutter/material.dart';

enum BadgeType() {
  filled,
  outlined,
  outlineFill,
  plain,
}

class const Badge({
  required final String label,
  final TextStyle? labelStyle,
  final IconData? icon = Icons.circle_rounded,
  final double? iconSize,
  final Color? color,
  final double borderRadius = 12.0,
  final EdgeInsets padding = const EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 4.0,
  ),
  final BadgeType type = BadgeType.plain,
  final bool center = true,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // solid background to paint over
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(theme),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            border: Border.all(color: _getBorderColor(theme)),
          ),
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: center
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: iconSize ?? ((theme.iconTheme.size ?? 14.0) * 0.8),
                    color: _getLabelColor(theme)?.withValues(alpha: 0.65),
                  )
                else
                  const SizedBox.shrink(),
                if (icon != null)
                  const SizedBox(width: 8.0)
                else
                  const SizedBox.shrink(),
                Expanded(
                  child: Text(
                    label,
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(
                          fontSize:
                              (theme.textTheme.bodySmall?.fontSize ?? 14.0) *
                              0.95,
                          color: _getLabelColor(theme),
                          fontWeight: FontWeight.bold,
                        )
                        .merge(labelStyle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color? _getBackgroundColor(ThemeData theme) {
    final actualColor = color ?? theme.colorScheme.primary;

    switch (type) {
      case BadgeType.filled:
        return actualColor;
      case BadgeType.outlineFill:
        return actualColor.withValues(alpha: 0.1);
      case BadgeType.outlined:
        return null;
      case BadgeType.plain:
        return null;
    }
  }

  Color _getBorderColor(ThemeData theme) {
    final actualColor = color ?? theme.colorScheme.secondary;

    switch (type) {
      case BadgeType.filled:
        return Colors.transparent;
      case BadgeType.outlineFill:
        return actualColor.withValues(alpha: 0.1);
      case BadgeType.outlined:
        return actualColor.withValues(alpha: 0.1);
      case BadgeType.plain:
        return Colors.transparent;
    }
  }

  Color? _getLabelColor(ThemeData theme) {
    final actualColor = color ?? theme.colorScheme.secondary;

    switch (type) {
      case BadgeType.filled:
        return theme.textTheme.labelLarge?.color?.withValues(alpha: 0.6);
      case BadgeType.outlineFill:
        return actualColor.withValues(alpha: 0.8);
      case BadgeType.outlined:
        return actualColor.withValues(alpha: 0.8);
      case BadgeType.plain:
        return actualColor.withValues(alpha: 0.8);
    }
  }
}

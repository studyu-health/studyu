import 'package:flutter/material.dart';

class const ReusableBanner({
  required final Widget body,
  final bool isDismissed = false,
  final Function()? onDismissed,
  final Color? backgroundColor,
  final Color? borderColor,
  final EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
  final EdgeInsetsGeometry margin = const EdgeInsets.all(8.0),
  final double borderRadius = 8.0,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (isDismissed) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border.all(
          color:
              borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          body,
          if (onDismissed != null)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: onDismissed,
                icon: const Icon(Icons.close),
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
        ],
      ),
    );
  }
}

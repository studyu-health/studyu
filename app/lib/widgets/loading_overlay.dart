import 'package:flutter/material.dart';

/// Blocking scrim with a spinner and a short description below it, shown on
/// top of the current page while a blocking operation runs.
///
/// Must be a direct child of a [Stack]: it fills the stack and absorbs all
/// pointers, so nothing underneath can be interacted with while visible.
class const LoadingOverlay({super.key, required final String message})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: theme.colorScheme.scrim.withValues(alpha: 0.5),
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(message, style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

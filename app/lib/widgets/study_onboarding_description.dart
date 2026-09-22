import 'package:flutter/material.dart';

class const StudyOnboardingDescription({
  required final String text,
  final String? actionLabel,
  final VoidCallback? onAction,
  final String? supportingText,
  super.key,
}) extends StatelessWidget {
  this
    : assert(
        (actionLabel == null) == (onAction == null),
        'actionLabel and onAction must be provided together',
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                style: primaryStyle,
                children: [
                  TextSpan(text: text),
                  if (actionLabel != null) ...[
                    const TextSpan(text: ' '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: TextButton(
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: primaryStyle,
                        ),
                        child: Text(actionLabel!),
                      ),
                    ),
                  ],
                ],
              ),
              textAlign: TextAlign.start,
            ),
            if (supportingText != null) ...[
              const SizedBox(height: 8),
              Text(
                supportingText!,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

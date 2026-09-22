import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const EnrolledBadge({required final int enrolledCount, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurface,
    );

    return Tooltip(
      message: tr.enrolled_count_tooltip(enrolledCount),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(enrolledCount.toString(), style: textStyle),
      ),
    );
  }
}

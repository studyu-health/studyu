import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const StudyUJobsToBeDone({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.zero,
            child: Text(
              tr.navlink_learn,
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.white.withValues(alpha: 1.5 * 0.04),
              ),
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 1 * 48.0),
            child: Text(
              tr.navlink_study_design,
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.white.withValues(alpha: 4 * 0.04),
              ),
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2 * 48.0),
            child: Text(
              tr.navlink_study_test,
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.white.withValues(alpha: 3 * 0.04),
              ),
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3 * 48.0),
            child: Text(
              tr.navlink_study_monitor,
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.white.withValues(alpha: 2 * 0.04),
              ),
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4 * 48.0),
            child: Text(
              tr.navlink_study_analyze,
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.white.withValues(alpha: 4 * 0.04),
              ),
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5 * 48.0),
            child: Text(
              tr.navlink_share,
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.white.withValues(alpha: 3 * 0.04),
              ),
              softWrap: false,
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/badge.dart' as study_badge;
import 'package:studyu_designer_v2/features/design/reports/reports_form_data.dart';

class const ReportBadge({
  required final ReportStatus? status,
  final study_badge.BadgeType type = study_badge.BadgeType.outlineFill,
  final bool showPrefixIcon = true,
  final bool showTooltip = true,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final prefixIcon = showPrefixIcon ? Icons.circle_rounded : null;

    final tooltipMessage = (status?.description ?? '').trim();

    Widget inTooltip(Widget child) {
      if (tooltipMessage.isNotEmpty && showTooltip) {
        return Tooltip(message: tooltipMessage, child: child);
      }
      return child;
    }

    switch (status) {
      case ReportStatus.primary:
        return inTooltip(
          study_badge.Badge(
            label: status!.string,
            color: colorScheme.primary,
            type: study_badge.BadgeType.outlineFill,
            icon: prefixIcon,
          ),
        );
      case ReportStatus.secondary:
        return inTooltip(
          study_badge.Badge(
            label: status!.string,
            color: colorScheme.secondary.withValues(alpha: 0.75),
            type: study_badge.BadgeType.outlineFill,
            icon: prefixIcon,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

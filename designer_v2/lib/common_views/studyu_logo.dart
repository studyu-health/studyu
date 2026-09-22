import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/assets.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';

class const StudyULogo({final VoidCallback? onTap, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MouseEventsRegion(
      builder: (context, states) {
        final isHovered = states.contains(WidgetState.hovered);
        final colorBlendFactor = isHovered ? 0.5 : 0.6;

        return Container(
          foregroundDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary
                .withValues(alpha: colorBlendFactor),
            backgroundBlendMode: BlendMode.color,
          ),
          child: Image.asset(Assets.logoWide, fit: BoxFit.scaleDown),
        );
      },
      onTap: onTap,
    );
  }
}

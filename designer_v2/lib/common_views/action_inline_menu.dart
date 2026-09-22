import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

class const ActionMenuInline({
  required final List<ModelAction> actions,
  final double? splashRadius = 18.0,
  final double? iconSize,
  final WidgetStateProperty<Color>? iconColor,
  final BoxConstraints? buttonConstraints,
  final VisualDensity? visualDensity,
  final bool visible = true,
  final double? paddingHorizontal = 2.0,
  final double? paddingVertical = 0.0,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty || !visible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    Color defaultIconColor(Set<WidgetState> states) {
      if (states.contains(WidgetState.hovered)) {
        return theme.colorScheme.secondary.withValues(alpha: 0.8);
      }
      return theme.colorScheme.secondary.withValues(alpha: 0.4);
    }

    final actionButtons = actions.map((ModelAction action) {
      return Tooltip(
        message: action.label,
        child: MouseEventsRegion(
          builder: (context, state) {
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: buttonConstraints,
              splashRadius: splashRadius,
              visualDensity: visualDensity,
              onPressed: () => action.execute(context),
              iconSize: iconSize ?? theme.iconTheme.size ?? 16.0,
              icon: Icon(
                action.icon,
                color:
                    iconColor?.resolve(state) ??
                    (action.isDestructive
                        ? Colors.red
                        : defaultIconColor(state)),
              ),
            );
          },
        ),
      );
    }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal ?? 0,
        vertical: paddingVertical ?? 0,
      ),
      child: Row(children: actionButtons),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

typedef ActionsProvider<T> = List<ModelAction> Function();
typedef ActionsProviderFor<T> = List<ModelAction> Function(T from);
typedef ActionsProviderAt<T> = List<ModelAction> Function(T from, int idx);

class const ActionPopUpMenuButton({
  required final List<ModelAction> actions,
  final Axis orientation = Axis.horizontal,
  final double? elevation = 5,
  final double? splashRadius = 24.0,
  final double triggerIconSize = 18.0,
  final PopupMenuPosition position = PopupMenuPosition.under,
  final IconData? triggerIcon,
  final Color? triggerIconColor,
  final Color? triggerIconColorHover,
  final bool disableSplashEffect = false,
  final bool hideOnEmpty = true,
  final bool enabled = true,
  final Widget? triggerBuilder,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return MouseEventsRegion(
      builder: (context, state) {
        Widget widget = _buildPopupMenu(context, state);

        if (disableSplashEffect) {
          final popupMenu = widget;
          widget = Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              // hoverColor: Colors.transparent,
            ),
            child: popupMenu,
          );
        }

        return widget;
      },
    );
  }

  Widget _buildPopupMenu(BuildContext context, Set<WidgetState> state) {
    final theme = Theme.of(context);
    final isHovered = state.contains(WidgetState.hovered);
    final iconColorDefault =
        triggerIconColor ?? theme.iconTheme.color!.withValues(alpha: 0.7);
    final iconColorHover =
        triggerIconColorHover ?? theme.iconTheme.color!.withValues(alpha: 0.7);
    final triggerIcon =
        this.triggerIcon ??
        ((orientation == Axis.vertical)
            ? Icons.more_vert_rounded
            : Icons.more_horiz_rounded);

    return PopupMenuButton<ModelAction>(
      key: key ?? ValueKey(actions),
      icon:
          triggerBuilder ??
          Icon(
            triggerIcon,
            size: triggerIconSize,
            color: isHovered ? iconColorHover : iconColorDefault,
          ),
      enabled: enabled,
      elevation: elevation,
      splashRadius: splashRadius,
      position: position,
      itemBuilder: (BuildContext itemContext) {
        final textTheme = theme.textTheme.labelMedium!;
        final List<PopupMenuEntry<ModelAction>> popupList = [];
        for (final action in actions) {
          if (action.isSeparator) {
            popupList.add(const PopupMenuDivider());
            continue;
          }
          if (action.isHeader) {
            popupList.add(
              PopupMenuItem<ModelAction>(
                enabled: false,
                height: 32, // Condensed header
                child: Text(
                  action.label,
                  style: textTheme.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Slightly smaller for headers if needed
                  ),
                ),
              ),
            );
            continue;
          }
          popupList.add(
            PopupMenuItem<ModelAction>(
              value: action,
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  unawaited(action.execute(context));
                });
              },
              child: (action.tooltip != null)
                  ? Tooltip(
                      message: action.tooltip,
                      child: _buildListTile(
                        theme,
                        action,
                        iconColorDefault,
                        textTheme,
                      ),
                    )
                  : _buildListTile(theme, action, iconColorDefault, textTheme),
            ),
          );
          continue;
        }
        return popupList;
      },
    );
  }

  Widget _buildListTile(
    ThemeData theme,
    ModelAction action,
    Color iconColorDefault,
    TextStyle textTheme,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      horizontalTitleGap: 4.0,
      leading: (action.icon == null)
          ? const SizedBox.shrink()
          : Badge(
              smallSize: 8,
              isLabelVisible: action.showBadge,
              child: Icon(
                action.icon,
                size: theme.iconTheme.size ?? 14.0,
                color: action.isDestructive
                    ? Colors.red
                    : (action.isChecked
                          ? theme.colorScheme.primary
                          : iconColorDefault),
              ),
            ),
      title: action.isDestructive
          ? Text(action.label, style: textTheme.copyWith(color: Colors.red))
          : Text(
              action.label,
              style: action.isChecked
                  ? textTheme.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    )
                  : textTheme,
            ),
      trailing: action.isChecked
          ? Icon(
              Icons.check_rounded,
              size: theme.iconTheme.size ?? 14.0,
              color: theme.colorScheme.primary,
            )
          : null,
    );
  }
}

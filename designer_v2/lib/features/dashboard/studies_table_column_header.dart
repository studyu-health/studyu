import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';

class const StudiesTableColumnHeader(
  final String title, {
  super.key,
  required final bool sortable,
  required final bool sortingActive,
  required final bool sortAscending,
  final void Function()? onSort,
  final bool center = false,
  final bool rightAlign = false,
}) extends StatefulWidget {
  @override
  State<StudiesTableColumnHeader> createState() =>
      _StudiesTableColumnHeaderState();
}

class _StudiesTableColumnHeaderState() extends State<StudiesTableColumnHeader> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseEventsRegion(
      key: ValueKey('studies_table_column_header_${widget.title}'),
      builder: (context, state) {
        final alignment = widget.center
            ? MainAxisAlignment.center
            : (widget.rightAlign
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start);
        final textAlign = widget.center
            ? TextAlign.center
            : (widget.rightAlign ? TextAlign.end : TextAlign.start);
        return Row(
          mainAxisAlignment: alignment,
          children: [
            Flexible(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                textAlign: textAlign,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
            if (widget.sortable)
              _getIcon() ?? const SizedBox.shrink()
            else
              const SizedBox.shrink(),
          ],
        );
      },
      onEnter: (event) => setState(() => isHovering = true),
      onExit: (event) => setState(() => isHovering = false),
      onTap: widget.sortable ? () => widget.onSort?.call() : null,
    );
  }

  Icon? _getIcon() {
    const ascendingIcon = Icon(MdiIcons.arrowUp);
    const descendingIcon = Icon(MdiIcons.arrowDown);
    const hoveredAscendingIcon = Icon(MdiIcons.arrowUp, color: Colors.grey);
    const hoveredDescendingIcon = Icon(MdiIcons.arrowDown, color: Colors.grey);

    if (!widget.sortable) {
      return null;
    }

    if (!widget.sortingActive) {
      return isHovering
          ? (widget.sortAscending
                ? hoveredAscendingIcon
                : hoveredDescendingIcon)
          : null;
    }

    return widget.sortAscending ? ascendingIcon : descendingIcon;
  }
}

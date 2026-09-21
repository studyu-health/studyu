import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class const Hyperlink({
  required final String text,
  final String? url,
  final VoidCallback? onClick,
  final Color linkColor = const Color(0xFF0000EE),
  final Color? hoverColor,
  final Color? visitedColor = const Color(0xFF551A8B),
  final TextStyle? style,
  final TextStyle? hoverStyle = const TextStyle(
    decoration: TextDecoration.none, // alternative: TextDecoration.underline
  ),
  final TextStyle? visitedStyle,
  final IconData? icon,
  final double? iconSize,
  super.key,
}) extends StatefulWidget {
  this
    : assert(
        (url != null && onClick == null) || (url == null && onClick != null),
        "Must provide either url or onClick handler",
      );

  @override
  State<Hyperlink> createState() => _HyperlinkState();
}

class _HyperlinkState() extends State<Hyperlink> {
  bool isVisited = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseEventsRegion(
      builder: (context, states) {
        final isHovered = states.contains(WidgetState.hovered);

        final visitedColor = widget.visitedColor ?? widget.linkColor;
        final visitedHoverColor =
            widget.hoverColor ??
            visitedColor.withValues(alpha: ThemeConfig.kHoverFadeFactor);
        final hoverColor =
            widget.hoverColor ??
            widget.linkColor.withValues(alpha: ThemeConfig.kHoverFadeFactor);

        final actualColor = isVisited
            ? (isHovered ? visitedHoverColor : visitedColor)
            : (isHovered ? hoverColor : widget.linkColor);

        final textTheme =
            theme.textTheme.titleSmall ?? theme.textTheme.bodyLarge;
        TextStyle? actualStyle = textTheme
            ?.copyWith(color: actualColor)
            .merge(widget.style);

        if (isVisited) {
          actualStyle = actualStyle?.merge(widget.visitedStyle);
        }
        if (isHovered) {
          actualStyle = actualStyle?.merge(widget.hoverStyle);
        }

        final textWidget = Text(widget.text, style: actualStyle);

        if (widget.icon != null) {
          return Row(
            children: [
              Icon(
                widget.icon,
                color: actualColor,
                size: widget.iconSize ?? (textTheme?.fontSize ?? 14.0) + 4.0,
              ),
              const SizedBox(width: 2.0),
              textWidget,
            ],
          );
        }

        return textWidget;
      },
      onTap: () async {
        if (widget.url != null) {
          await launchUrl(Uri.parse(widget.url!));
        }
        widget.onClick?.call();
        setState(() {
          isVisited = true;
        });
      },
    );
  }
}

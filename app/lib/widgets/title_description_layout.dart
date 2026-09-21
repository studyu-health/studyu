import 'package:flutter/material.dart';

class const TitleDescriptionLayout({
  super.key,
  final String title = '',
  final String description = '',
  final IconData? titleIcon,
  final Widget? descriptionWidget,
  required final Widget child,
  final Widget? bottomContent,
  final Widget? bottomNavigationBar,
  final double maxWidth = 700,
  final double descriptionBottomSpacing = 24,
  final EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(24, 0, 24, 16),
  final bool scrollable = true,
}) extends StatelessWidget {
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (titleIcon != null) ...[
                Icon(titleIcon, color: theme.primaryColor),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.headlineMedium!.copyWith(
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        if (descriptionWidget != null || description.isNotEmpty) ...[
          descriptionWidget ?? Text(description),
          SizedBox(height: descriptionBottomSpacing),
        ],
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: scrollable
                    ? SingleChildScrollView(
                        padding: padding,
                        child: _buildContent(context),
                      )
                    : SizedBox.expand(
                        child: Padding(
                          padding: padding,
                          child: _buildContent(context),
                        ),
                      ),
              ),
            ),
          ),
          if (bottomContent != null)
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: bottomContent,
              ),
            ),
          ?bottomNavigationBar,
        ],
      ),
    );
  }
}

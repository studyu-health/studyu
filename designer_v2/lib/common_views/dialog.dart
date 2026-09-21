import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/theme.dart';

class const StandardDialog({
  final Widget? title,
  final String? titleText,
  required final Widget body,
  final double? width,
  final double? height,
  final EdgeInsets padding = const EdgeInsets.fromLTRB(42.0, 36.0, 42.0, 36.0),
  final double minWidth = 400,
  final double minHeight = 300,
  final double? maxWidth,
  final double? maxHeight,
  final List<Widget> actionButtons = const [],
  final Color? backgroundColor,
  final double? borderRadius = 20.0,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dialogWidth = width ?? MediaQuery.of(context).size.width * 0.4;
    //final dialogHeight = height ?? MediaQuery.of(context).size.height * 0.4;

    final Widget? titleWidget =
        title ??
        ((titleText != null)
            ? SelectableText(
                titleText!,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              )
            : null);

    return Dialog(
      alignment: Alignment.center,
      child: PointerInterceptor(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor,
                blurRadius: 3,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: Container(
            constraints: BoxConstraints(
              minWidth: minWidth,
              maxWidth: maxWidth ?? double.infinity,
              minHeight: minHeight,
              maxHeight: maxHeight ?? double.infinity,
            ),
            decoration: BoxDecoration(
              color: backgroundColor ?? ThemeConfig.bodyBackgroundColor(theme),
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadius ?? 0),
              ),
            ),
            child: SizedBox(
              width: width ?? dialogWidth,
              height: height,
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    padding.top,
                    padding.right,
                    padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (titleWidget != null)
                        titleWidget
                      else
                        const SizedBox.shrink(),
                      if (titleWidget != null)
                        SizedBox(height: padding.top * 2 / 3)
                      else
                        const SizedBox.shrink(),
                      Expanded(child: SingleChildScrollView(child: body)),
                      SizedBox(height: padding.bottom),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: withSpacing(actionButtons, spacing: 8.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

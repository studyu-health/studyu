import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

typedef WidgetDecorator = Widget Function(Widget widget);

List<Widget> withSpacing(
  List<Widget> widgets, {
  required double spacing,
  double? paddingStart,
  double? paddingEnd,
}) {
  final List<Widget> results = [];
  if (paddingStart != null) {
    results.add(SizedBox(height: paddingStart, width: paddingStart));
  }
  for (var i = 0; i < widgets.length; i++) {
    final isTrailing = i == widgets.length - 1;
    results.add(widgets[i]);
    if (!isTrailing) {
      results.add(SizedBox(height: spacing, width: spacing));
    }
  }
  if (paddingEnd != null) {
    results.add(SizedBox(height: paddingEnd, width: paddingEnd));
  }
  return results;
}

/// Allows the wrapped [widget] to retain its preferred size & avoid
///  being stretched when placed into the [AppBar] actions
///  Note: [AppBar] places the actions in a [CrossAxisAlignment.stretched] row
Widget retainSizeInAppBar(Widget widget) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [widget],
  );
}

extension ColorX on Color {
  /// Returns a new color that matches this color with the alpha channel
  /// multiplied by [alphaScaleFactor] (ranging from 0 to 1).
  Color faded(double alphaScaleFactor) {
    assert(alphaScaleFactor >= 0.0 && alphaScaleFactor <= 1.0);
    return withAlpha((alphaScaleFactor * a).round());
  }
}

Widget interventionPrefix(int rowIdx, ThemeData theme) {
  return Row(
    children: [
      Text(
        ''.alphabetLetterFrom(rowIdx).toUpperCase(),
        style: TextStyle(
          color: ThemeConfig.dropdownMenuItemTheme(theme).iconTheme!.color,
        ),
      ),
      const SizedBox(width: 16.0),
    ],
  );
}

Widget versionText({TextStyle? textStyle}) {
  return FutureBuilder<PackageInfo>(
    future: _packageInfo,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox.shrink();
      }
      final packageInfo = snapshot.data;
      if (packageInfo == null) {
        return const SizedBox.shrink();
      }
      return SelectableText(
        'Version ${packageInfo.version}${packageInfo.buildNumber.isNotEmpty ? ' - ${packageInfo.buildNumber}' : ''}',
        style: textStyle,
      );
    },
  );
}

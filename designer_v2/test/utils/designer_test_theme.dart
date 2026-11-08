import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/theme.dart';

ThemeData designerTestTheme() {
  final settings = ValueNotifier(
    ThemeSettings(sourceColor: Colors.blue, themeMode: ThemeMode.light),
  );
  addTearDown(settings.dispose);
  return ThemeProvider(
    settings: settings,
    lightDynamic: null,
    darkDynamic: null,
    child: const SizedBox.shrink(),
  ).light();
}

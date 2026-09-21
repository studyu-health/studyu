import 'dart:js_interop';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/platform_locale/platform_locale_interface.dart';

@JS('navigator')
external JSObject get _navigator;

extension on JSObject {
  external String get language;
}

class PlatformLocaleWeb() implements PlatformLocale {
  @override
  Locale getPlatformLocale() {
    final platformLocaleName = _navigator.language;
    print("Platform Locale Name (WEB): $platformLocaleName");

    if (platformLocaleName.isEmpty) {
      return const Locale('en'); // Default fallback
    }

    final parts = platformLocaleName.split('-');

    if (parts.length == 1) {
      return Locale(parts[0]); // Language-only code
    }

    return Locale(parts[0], parts[1]); // Language + country code
  }
}

PlatformLocale getImplementation() => PlatformLocaleWeb();

import 'dart:io';
import 'dart:ui';

import 'package:studyu_designer_v2/localization/platform_locale/platform_locale_interface.dart';

class PlatformLocaleMobile() implements PlatformLocale {
  @override
  Locale getPlatformLocale() {
    final String platformLocaleName = Platform.localeName;
    print("Platform Locale Name (Mobile): $platformLocaleName");

    // Language code only
    if (platformLocaleName.length == 2) {
      return Locale.fromSubtags(languageCode: platformLocaleName);
    }

    // Language and country codes
    final String languageCode = platformLocaleName.substring(
      0,
      platformLocaleName.indexOf('_'),
    );
    final String countryCode = platformLocaleName.substring(
      platformLocaleName.indexOf('_') + 1,
    );

    return Locale.fromSubtags(
      languageCode: languageCode,
      countryCode: countryCode,
    );
  }
}

PlatformLocale getImplementation() => PlatformLocaleMobile();

import 'dart:ui';

import 'package:studyu_designer_v2/localization/platform_locale/platform_locale_stub.dart' // Stub implementation
    if (dart.library.io) 'platform_locale_mobile.dart' // dart:io implementation
    if (dart.library.html) 'platform_locale_web.dart'; // dart:html implementation

abstract class PlatformLocale {
  Locale getPlatformLocale();

  // Return the correct implementation
  factory() => getImplementation();
}

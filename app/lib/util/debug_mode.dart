import 'package:flutter/foundation.dart' show kDebugMode;

/// Enables debug-only behavior in debug builds unless explicitly disabled.
const bool isDebugMode =
    kDebugMode && bool.fromEnvironment('STUDYU_DEBUG_MODE', defaultValue: true);

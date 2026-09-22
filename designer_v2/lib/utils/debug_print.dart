import 'dart:developer';

import 'package:flutter/foundation.dart';

/// Attempts to print a message using Flutter's debugPrint (only available in widgets)
/// and falls back to Dart's built-in log
void debugLog(String message) {
  try {
    debugPrint(message);
  } catch (e) {
    log(message);
  }
}

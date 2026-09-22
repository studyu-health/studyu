import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clipboard.g.dart';

abstract class IClipboardService() {
  Future<String> copy(String text);
}

/// Simple wrapper around Flutter's [Clipboard]
class ClipboardService() implements IClipboardService {
  @override
  Future<String> copy(String text) {
    return Clipboard.setData(ClipboardData(text: text)).then((value) => text);
  }
}

@riverpod
IClipboardService clipboardService(Ref ref) {
  return ClipboardService();
}

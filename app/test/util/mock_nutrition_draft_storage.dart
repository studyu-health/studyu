import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void mockNutritionDraftStorage({void Function(MethodCall)? beforeCall}) {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final values = <String, String>{};
  messenger.setMockMethodCallHandler(channel, (call) async {
    beforeCall?.call(call);
    final arguments = call.arguments as Map<Object?, Object?>;
    final key = arguments['key'] as String?;
    if (key == null) throw ArgumentError.notNull('key');
    switch (call.method) {
      case 'read':
        return values[key];
      case 'write':
        final value = arguments['value'] as String?;
        if (value == null) throw ArgumentError.notNull('value');
        values[key] = value;
      case 'delete':
        values.remove(key);
      default:
        throw MissingPluginException(call.method);
    }
    return null;
  });
  addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
}

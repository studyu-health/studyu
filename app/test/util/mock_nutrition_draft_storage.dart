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
    final key = arguments['key'] as String;
    switch (call.method) {
      case 'read':
        return values[key];
      case 'write':
        values[key] = arguments['value'] as String;
      case 'delete':
        values.remove(key);
      default:
        throw MissingPluginException(call.method);
    }
    return null;
  });
  addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
}

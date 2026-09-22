import 'package:flutter_driver/driver_extension.dart';
import 'package:studyu_app/main.dart' as app_main;

Future<void> main() async {
  enableFlutterDriverExtension();
  await app_main.main();
}

import 'package:flutter_driver/driver_extension.dart';
import 'package:studyu_designer_v2/main.dart' as app_main;

Future<void> main() async {
  enableFlutterDriverExtension();
  await app_main.main();
}

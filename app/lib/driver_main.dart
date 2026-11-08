import 'package:flutter_driver/driver_extension.dart';
import 'package:studyu_app/main.dart' as app_main;
import 'package:studyu_app/studyu_driver_state.dart';

Future<void> main() async {
  enableFlutterDriverExtension(handler: StudyUDriverState.handleRequest);
  await app_main.main();
}

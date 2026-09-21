import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const AppRobot(final PatrolTester $) {
  Future<void> validateOnSplashScreen() async {
    await $(tr.loading_message).waitUntilVisible();
  }

  Future<void> validateOnLoginScreen() async {
    await $(tr.login_page_title).waitUntilVisible();
  }
}

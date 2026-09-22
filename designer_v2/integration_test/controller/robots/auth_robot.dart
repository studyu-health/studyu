import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const AuthRobot(final PatrolTester $) {
  Future<void> enterEmail(String email) async {
    await $(ReactiveTextField).containing(tr.form_field_email).enterText(email);
  }

  Future<void> enterPassword(String password) async {
    await $(ReactiveTextField)
        .containing(tr.form_field_password)
        .enterText(password);
  }

  Future<void> enterPasswordConfirmation(String confirmPassword) async {
    await $(ReactiveTextField)
        .containing(tr.form_field_password_confirm)
        .enterText(confirmPassword);
  }

  Future<void> tapTermsCheckbox() async {
    await $(ReactiveCheckbox).tap();
  }

  Future<void> tapSignInButton() async {
    await $(tr.action_button_login).tap();
  }

  Future<void> tapSignUpButton() async {
    await $(tr.action_button_signup).tap();
  }

  Future<void> navigateToSignUpScreen() async {
    await $(tr.link_signup).tap();
  }
}

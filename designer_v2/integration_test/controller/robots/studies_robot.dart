import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const StudiesRobot(final PatrolTester $) {
  Future<void> validateOnStudiesScreen() async {
    await $(tr.navlink_my_studies).waitUntilVisible();
  }

  Future<void> validateNoStudiesFound() async {
    await $(tr.studies_empty).waitUntilVisible();
  }

  Future<void> validateStudyDraftExists() async {
    await $(tr.study_status_draft).waitUntilVisible();
  }

  Future<void> validateStudyPublished() async {
    await $(tr.study_status_running).waitUntilVisible();
  }

  Future<void> tapNewStudyButton() async {
    await $(tr.action_button_new_study).tap();
  }

  Future<void> tapOnExistingStudy() async {
    await $(tr.study_status_draft).tap();
  }

  Future<void> tapSignOutButton() async {
    await $(tr.navlink_logout).tap();
  }
}

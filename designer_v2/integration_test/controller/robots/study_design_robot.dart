import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const StudyDesignRobot(final PatrolTester $) {
  Future<void> validateOnDesignScreen() async {
    await $(tr.navlink_study_design).waitUntilVisible();
  }

  Future<void> validateChangesSaved() async {
    await $(Icons.check_circle_rounded).waitUntilVisible();
  }

  Future<void> validateStudyPublished() async {
    await $(tr.study_status_running).waitUntilVisible();
  }

  Future<void> navigateToInfoScreen() async {
    await $(tr.navlink_study_design_info).tap();
  }

  Future<void> navigateToParticipationScreen() async {
    await $(tr.navlink_study_design_enrollment).tap();
  }

  Future<void> navigateToInterventionsScreen() async {
    await $(tr.navlink_study_design_interventions).tap();
  }

  Future<void> navigateToMeasurementsScreen() async {
    await $(tr.navlink_study_design_measurements).tap();
  }

  Future<void> tapLeftDrawerButton() async {
    await $(Icons.menu).tap();
  }

  Future<void> tapMyStudiesButton() async {
    await $(tr.navlink_my_studies).tap();
  }

  Future<void> selectStudyIcon() async {
    await $(const ValueKey('study_title_icon_picker')).tap();
    await $(tr.iconpicker_dialog_title).waitUntilVisible();

    final iconFinder = find.descendant(
      of: find.byType(IconPickerGallery),
      matching: find.byType(Icon),
    );
    await $.tester.tap(iconFinder.first);
    await $.pumpAndSettle();
  }

  Future<void> waitForPublishButtonEnabled() async {
    await $(PrimaryButton)
        .which<PrimaryButton>(
          (button) =>
              button.text == tr.action_button_study_launch &&
              !button.isDisabled,
        )
        .waitUntilVisible();
  }

  Future<void> waitForPublishConfirmationDialog() async {
    await $(tr.study_launch_title).waitUntilVisible();
  }

  Future<void> tapPublishButton() async {
    await $(tr.action_button_study_launch).tap();
  }

  Future<void> tapConfirmPublishButton() async {
    await $(tr.action_button_study_launch).tap();
  }

  Future<void> tapSkipForNowButton() async {
    await $(const ValueKey('post_publish_followup_skip')).tap();
  }
}

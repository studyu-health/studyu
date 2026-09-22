import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const StudyInfoRobot(final PatrolTester $) {
  Future<void> validateOnStudyInfoScreen() async {
    await $(tr.navlink_study_design).waitUntilVisible();
  }

  Future<void> enterStudyName(String studyName) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! == tr.form_field_study_title,
        )
        .scrollTo()
        .enterText(studyName);
  }

  Future<void> enterStudyDescription(String studyDescription) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! ==
                  tr.form_field_study_description_hint,
        )
        .scrollTo()
        .enterText(studyDescription);
  }

  Future<void> enterResponsibleOrg(String orgName) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! == tr.form_field_organization,
        )
        .scrollTo()
        .enterText(orgName);
  }

  Future<void> enterInstitutionalReviewBoard(String irbName) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! == tr.form_field_review_board,
        )
        .scrollTo()
        .enterText(irbName);
  }

  Future<void> enterIRBProtocolNumber(String irbNumber) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! == tr.form_field_review_board_number,
        )
        .scrollTo()
        .enterText(irbNumber);
  }

  Future<void> enterResponsiblePerson(String personName) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! == tr.form_field_researchers,
        )
        .scrollTo()
        .enterText(personName);
  }

  Future<void> enterWebsite(String website) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! == tr.form_field_website,
        )
        .scrollTo()
        .enterText(website);
  }

  Future<void> enterContactEmail(String emailAddress) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! == tr.form_field_contact_email,
        )
        .scrollTo()
        .enterText(emailAddress);
  }

  Future<void> enterContactPhone(String phoneNumber) async {
    await $(TextField)
        .which<TextField>(
          (widget) =>
              widget.decoration is InputDecoration &&
              widget.decoration!.hintText != null &&
              widget.decoration!.hintText! == tr.form_field_contact_phone,
        )
        .scrollTo()
        .enterText(phoneNumber);
  }
}

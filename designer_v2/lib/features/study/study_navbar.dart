import 'package:studyu_designer_v2/common_views/navbar_tabbed.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

abstract class IStudyNavViewModel() {
  bool get isEditTabEnabled;
  bool get isTestTabEnabled;
  bool get isRecruitTabEnabled;
  bool get isMonitorTabEnabled;
  bool get isAnalyzeTabEnabled;
  bool get isSettingsEnabled;
}

class StudyNav() {
  static List<NavbarTab> tabs(StudyID studyId, IStudyNavViewModel viewModel) =>
      <NavbarTab>[
        edit(studyId, enabled: viewModel.isEditTabEnabled),
        test(studyId, enabled: viewModel.isTestTabEnabled),
        recruit(studyId, enabled: viewModel.isRecruitTabEnabled),
        monitor(studyId, enabled: viewModel.isMonitorTabEnabled),
        analyze(studyId, enabled: viewModel.isAnalyzeTabEnabled),
      ];

  static NavbarTab edit(StudyID studyId, {bool enabled = true}) => NavbarTab(
    index: 0,
    title: tr.navlink_study_design,
    intent: RoutingIntents.studyEdit(studyId),
    enabled: enabled,
  );
  static NavbarTab test(StudyID studyId, {bool enabled = true}) => NavbarTab(
    index: 1,
    title: tr.navlink_study_test,
    intent: RoutingIntents.studyTest(studyId),
    enabled: enabled,
  );
  static NavbarTab recruit(StudyID studyId, {bool enabled = true}) => NavbarTab(
    index: 2,
    title: tr.navlink_study_recruit,
    intent: RoutingIntents.studyRecruit(studyId),
    enabled: enabled,
  );
  static NavbarTab monitor(StudyID studyId, {bool enabled = true}) => NavbarTab(
    index: 3,
    title: tr.navlink_study_monitor,
    intent: RoutingIntents.studyMonitor(studyId),
    enabled: enabled,
  );
  static NavbarTab analyze(StudyID studyId, {bool enabled = true}) => NavbarTab(
    index: 4,
    title: tr.navlink_study_analyze,
    intent: RoutingIntents.studyAnalyze(studyId),
    enabled: enabled,
  );
}

class StudyDesignNav() {
  static List<NavbarTab> tabs(StudyID studyId) => <NavbarTab>[
    info(studyId),
    enrollment(studyId),
    interventions(studyId),
    measurements(studyId),
    reports(studyId),
  ];

  static NavbarTab info(StudyID studyId) => NavbarTab(
    index: 0,
    title: tr.navlink_study_design_info,
    intent: RoutingIntents.studyEditInfo(studyId),
  );
  static NavbarTab enrollment(StudyID studyId) => NavbarTab(
    index: 1,
    title: tr.navlink_study_design_enrollment,
    intent: RoutingIntents.studyEditEnrollment(studyId),
  );
  static NavbarTab interventions(StudyID studyId) => NavbarTab(
    index: 2,
    title: tr.navlink_study_design_interventions,
    intent: RoutingIntents.studyEditInterventions(studyId),
  );
  static NavbarTab measurements(StudyID studyId) => NavbarTab(
    index: 3,
    title: tr.navlink_study_design_measurements,
    intent: RoutingIntents.studyEditMeasurements(studyId),
  );
  static NavbarTab reports(StudyID studyId) => NavbarTab(
    index: 4,
    title: tr.form_array_report_items_title,
    intent: RoutingIntents.studyEditReports(studyId),
  );
}

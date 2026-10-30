abstract final class StudyUDesignerKey {
  static const loginEmail = 'login_email';
  static const loginPassword = 'login_password';
  static const loginButton = 'login_button';
  static const signupEmail = 'signup_email';
  static const signupPassword = 'signup_password';
  static const signupButton = 'signup_button';
  static const newStudyButton = 'new_study_button';
  static const newStudyCompactButton = 'new_study_compact_button';
  static const studiesTableRows = 'studies_table_rows';
  static const filterToggleButton = 'filter_toggle_button';
  static const searchButton = 'search_button';
  static const navbarTabBar = 'navbar_tab_bar';
  static const formSaveButton = 'form_save_button';
  static const formCancelButton = 'form_cancel_button';

  static const all = [
    loginEmail,
    loginPassword,
    loginButton,
    signupEmail,
    signupPassword,
    signupButton,
    newStudyButton,
    newStudyCompactButton,
    studiesTableRows,
    filterToggleButton,
    searchButton,
    navbarTabBar,
    formSaveButton,
    formCancelButton,
  ];
}

abstract final class StudyUDesignerScreen {
  static const login = 'DesignerLoginScreen';
  static const studies = 'DesignerStudiesScreen';
  static const studyEditor = 'DesignerStudyEditorScreen';
}

String? inferStudyUDesignerScreen(Set<String> keys) {
  if (keys.contains(StudyUDesignerKey.loginEmail) ||
      keys.contains(StudyUDesignerKey.loginButton)) {
    return StudyUDesignerScreen.login;
  }
  if (keys.contains(StudyUDesignerKey.studiesTableRows) ||
      keys.contains(StudyUDesignerKey.newStudyButton) ||
      keys.contains(StudyUDesignerKey.newStudyCompactButton)) {
    return StudyUDesignerScreen.studies;
  }
  if (keys.contains(StudyUDesignerKey.navbarTabBar) ||
      keys.contains(StudyUDesignerKey.formSaveButton)) {
    return StudyUDesignerScreen.studyEditor;
  }
  return null;
}

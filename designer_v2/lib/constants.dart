class Config() {
  static const isDebugMode = false;

  static const defaultLocale = {'en', 'US'};

  static const supportedLocales = {'en': 'US', 'de': 'DE', 'ko': 'KR'};

  /// Default id for new studies that haven't been saved yet
  static const newStudyId = 'new';

  static const newModelId = 'new';

  /// Number of milliseconds the splash screen should be displayed at minimum
  /// Set to 0 to avoid displaying the splash screen any longer than necessary
  /// (may result in the splash screen not being shown at all)
  static const minSplashTime = 0;

  static const formAutosaveDebounce = 1000;

  static const participantDropoutDuration = 5;
  static const participantInactiveDuration = 3;
}

const kPathSeparator = '   /   ';

const String rootRouteName = 'root';
const String studiesRouteName = 'studies';
const String studyRouteName = 'study';
const String studyEditRouteName = 'studyEdit';
const String studyEditInfoRouteName = 'studyEditInfo';
const String studyEditEnrollmentRouteName = 'studyEditEnrollment';
const String studyEditInterventionsRouteName = 'studyEditInterventions';
const String studyEditInterventionRouteName = 'studyEditIntervention';
const String studyEditMeasurementsRouteName = 'studyEditMeasurements';
const String studyEditReportsRouteName = 'studyEditReports';
const String studyEditMeasurementRouteName = 'studyEditMeasurement';
const String studyTestRouteName = 'studyTest';
const String studyRecruitRouteName = 'studyRecruit';
const String studyMonitorRouteName = 'studyMonitor';
const String studyAnalyzeRouteName = 'studyAnalyze';
const String studySettingsRouteName = 'studySettings';
const String accountSettingsRouteName = 'accountSettings';
const String splashRouteName = 'splash';
const String loginRouteName = 'login';
const String signupRouteName = 'signup';
const String forgotPasswordRouteName = 'forgotPassword';
const String recoverPasswordRouteName = 'recoverPassword';
const String errorRouteName = 'error';

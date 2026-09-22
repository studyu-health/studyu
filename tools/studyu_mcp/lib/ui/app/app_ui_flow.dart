import 'package:studyu_mcp/ui/ui_driver.dart';

class StudyUAppUiFlow {
  const StudyUAppUiFlow({
    required StudyUWaitForKey waitForKey,
    required StudyUTapKey tapKey,
    StudyUReadScreen? readScreen,
    this.shortTimeout = const Duration(milliseconds: 800),
    this.routeTimeout = const Duration(seconds: 1),
    this.finalTimeout = const Duration(seconds: 10),
  }) : _waitForKey = waitForKey,
       _tapKey = tapKey,
       _readScreen = readScreen;

  final StudyUWaitForKey _waitForKey;
  final StudyUTapKey _tapKey;
  final StudyUReadScreen? _readScreen;
  final Duration shortTimeout;
  final Duration routeTimeout;
  final Duration finalTimeout;

  Future<void> openStudy(String studyId) async {
    await _tapKey('study_tile_$studyId');
    if (!await _waitForKey(
      StudyUAppKey.studyOverviewScreen,
      timeout: finalTimeout,
    )) {
      final current = await _readCurrentScreen();
      throw StateError(
        'Study overview did not become visible after opening "$studyId". Current screen: ${current.screen}. Visible keys: ${current.visibleKeys.join(', ')}',
      );
    }
  }

  Future<void> completeOnboardingToStudyList() async {
    final snapshot = await _readCurrentScreen();
    switch (snapshot.screen) {
      case StudyUAppScreen.studySelection:
        return;
      case StudyUAppScreen.studyOverview:
        throw StateError(
          'Already past StudySelectionScreen. Go back before completing onboarding.',
        );
    }

    if (snapshot.screen == StudyUAppScreen.unknown ||
        snapshot.screen == StudyUAppScreen.onboarding ||
        snapshot.hasKey(StudyUAppKey.onboardingNext) ||
        snapshot.hasKey(StudyUAppKey.onboardingDone)) {
      await _completeIntroPages();
    }

    if (!await _isOnStudySelection()) {
      await _tapIfPresent(StudyUAppKey.welcomeGetStarted);
    }
    if (!await _isOnStudySelection()) {
      await _tapIfPresent(StudyUAppKey.termsContinue);
    }
    if (!await _isOnStudySelection()) {
      await _acceptTerms();
    }

    final reachedStudyList = await _waitForKey(
      StudyUAppKey.studySelectionList,
      timeout: finalTimeout,
    );
    if (!reachedStudyList) {
      final current = await _readCurrentScreen();
      throw StateError(
        'Study selection list did not become visible. Current screen: ${current.screen}. Visible keys: ${current.visibleKeys.join(', ')}',
      );
    }
  }

  Future<void> _completeIntroPages() async {
    for (var i = 0; i < 4; i++) {
      await _tapIfPresent(StudyUAppKey.onboardingNext);
    }
    await _tapIfPresent(StudyUAppKey.onboardingDone);
  }

  Future<void> _acceptTerms() async {
    if (!await _waitForKey(
      StudyUAppKey.termsCheckboxChecked,
      timeout: shortTimeout,
    )) {
      await _tapIfPresent(StudyUAppKey.termsCheckbox);
    }
    if (!await _waitForKey(
      StudyUAppKey.privacyCheckboxChecked,
      timeout: shortTimeout,
    )) {
      await _tapIfPresent(StudyUAppKey.privacyCheckbox);
    }
    await _tapIfPresent(StudyUAppKey.termsContinue);
  }

  Future<bool> _isOnStudySelection() =>
      _waitForKey(StudyUAppKey.studySelectionList, timeout: routeTimeout);

  Future<StudyUIScreenSnapshot> _readCurrentScreen() async {
    final reader = _readScreen;
    if (reader == null) {
      return const StudyUIScreenSnapshot(
        screen: StudyUAppScreen.unknown,
        visibleKeys: {},
      );
    }
    return reader();
  }

  Future<void> _tapIfPresent(String key) async {
    if (await _waitForKey(key, timeout: shortTimeout)) {
      await _tapKey(key);
    }
  }
}

abstract final class StudyUAppKey {
  static const onboardingNext = 'onboarding_next';
  static const onboardingDone = 'onboarding_done';
  static const welcomeGetStarted = 'welcome_get_started';
  static const termsCheckbox = 'terms_checkbox';
  static const termsCheckboxChecked = 'terms_checkbox_checked';
  static const privacyCheckbox = 'privacy_checkbox';
  static const privacyCheckboxChecked = 'privacy_checkbox_checked';
  static const termsContinue = 'terms_continue';
  static const studySelectionList = 'study_selection_list';
  static const studySelectionInviteCode = 'study_selection_invite_code';
  static const studyOverviewScreen = 'study_overview_screen';
  static const studyOverviewNext = 'study_overview_next';
  static const eligibilityScreen = 'eligibility_screen';
  static const eligibilityContinue = 'eligibility_continue';
  static const interventionSelectionScreen = 'intervention_selection_screen';
  static const interventionSelectionContinue =
      'intervention_selection_continue';
  static const journeyOverviewScreen = 'journey_overview_screen';
  static const journeyOverviewNext = 'journey_overview_next';
  static const consentAccept = 'consent_accept';

  static const all = [
    onboardingNext,
    onboardingDone,
    welcomeGetStarted,
    termsCheckbox,
    termsCheckboxChecked,
    privacyCheckbox,
    privacyCheckboxChecked,
    termsContinue,
    studySelectionList,
    studySelectionInviteCode,
    studyOverviewScreen,
    studyOverviewNext,
    eligibilityScreen,
    eligibilityContinue,
    interventionSelectionScreen,
    interventionSelectionContinue,
    journeyOverviewScreen,
    journeyOverviewNext,
    consentAccept,
  ];
}

abstract final class StudyUAppScreen {
  static const unknown = 'unknown';
  static const onboarding = 'OnboardingScreen';
  static const welcome = 'WelcomeScreen';
  static const terms = 'TermsScreen';
  static const studySelection = 'StudySelectionScreen';
  static const studyOverview = 'StudyOverviewScreen';
  static const eligibility = 'EligibilityScreen';
  static const interventionSelection = 'InterventionSelectionScreen';
  static const journeyOverview = 'JourneyOverviewScreen';
  static const consent = 'ConsentScreen';
}

String inferStudyUAppScreen(Set<String> keys) {
  if (keys.contains(StudyUAppKey.studySelectionList)) {
    return StudyUAppScreen.studySelection;
  }
  if (keys.contains(StudyUAppKey.studyOverviewScreen)) {
    return StudyUAppScreen.studyOverview;
  }
  if (keys.contains(StudyUAppKey.eligibilityScreen)) {
    return StudyUAppScreen.eligibility;
  }
  if (keys.contains(StudyUAppKey.interventionSelectionScreen)) {
    return StudyUAppScreen.interventionSelection;
  }
  if (keys.contains(StudyUAppKey.journeyOverviewScreen)) {
    return StudyUAppScreen.journeyOverview;
  }
  if (keys.contains(StudyUAppKey.consentAccept)) {
    return StudyUAppScreen.consent;
  }
  if (keys.contains(StudyUAppKey.welcomeGetStarted)) {
    return StudyUAppScreen.welcome;
  }
  if (keys.contains(StudyUAppKey.termsContinue) ||
      keys.contains(StudyUAppKey.termsCheckbox)) {
    return StudyUAppScreen.terms;
  }
  if (keys.contains(StudyUAppKey.onboardingNext) ||
      keys.contains(StudyUAppKey.onboardingDone)) {
    return StudyUAppScreen.onboarding;
  }
  return StudyUAppScreen.unknown;
}

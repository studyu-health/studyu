import 'package:studyu_mcp/ui/app/app_ui_flow.dart';
import 'package:test/test.dart';

void main() {
  test('openStudy waits for the study overview destination', () async {
    final visibleKeys = {'study_tile_study-id'};

    await StudyUAppUiFlow(
      finalTimeout: Duration.zero,
      waitForKey: (key, {required timeout}) async => visibleKeys.contains(key),
      tapKey: (key) async {
        expect(key, 'study_tile_study-id');
        visibleKeys.add(StudyUAppKey.studyOverviewScreen);
      },
    ).openStudy('study-id');

    expect(visibleKeys, contains(StudyUAppKey.studyOverviewScreen));
  });

  test('openStudy fails when the destination never appears', () {
    expect(
      () => StudyUAppUiFlow(
        finalTimeout: Duration.zero,
        waitForKey: (_, {required timeout}) async => false,
        tapKey: (_) async {},
      ).openStudy('missing'),
      throwsStateError,
    );
  });

  test('completes onboarding and legal steps', () async {
    final visibleKeys = {StudyUAppKey.onboardingNext};
    var introPage = 0;
    var legalFormShown = false;

    await StudyUAppUiFlow(
      shortTimeout: Duration.zero,
      routeTimeout: Duration.zero,
      finalTimeout: Duration.zero,
      waitForKey: (key, {required timeout}) async => visibleKeys.contains(key),
      tapKey: (key) async {
        switch (key) {
          case StudyUAppKey.onboardingNext:
            if (++introPage == 4) {
              visibleKeys
                ..remove(key)
                ..add(StudyUAppKey.onboardingDone);
            }
          case StudyUAppKey.onboardingDone:
            visibleKeys
              ..remove(key)
              ..add(StudyUAppKey.welcomeGetStarted);
          case StudyUAppKey.welcomeGetStarted:
            visibleKeys
              ..remove(key)
              ..add(StudyUAppKey.termsContinue);
          case StudyUAppKey.termsContinue:
            if (legalFormShown &&
                visibleKeys.contains(StudyUAppKey.termsCheckboxChecked) &&
                visibleKeys.contains(StudyUAppKey.privacyCheckboxChecked)) {
              visibleKeys
                ..clear()
                ..add(StudyUAppKey.studySelectionList);
            } else {
              legalFormShown = true;
              visibleKeys.addAll({
                StudyUAppKey.termsCheckbox,
                StudyUAppKey.privacyCheckbox,
              });
            }
          case StudyUAppKey.termsCheckbox:
            visibleKeys.add(StudyUAppKey.termsCheckboxChecked);
          case StudyUAppKey.privacyCheckbox:
            visibleKeys.add(StudyUAppKey.privacyCheckboxChecked);
        }
      },
    ).completeOnboardingToStudyList();

    expect(visibleKeys, contains(StudyUAppKey.studySelectionList));
  });

  test('does not toggle already accepted legal checkboxes', () async {
    final visibleKeys = {
      StudyUAppKey.termsContinue,
      StudyUAppKey.termsCheckbox,
      StudyUAppKey.termsCheckboxChecked,
      StudyUAppKey.privacyCheckbox,
      StudyUAppKey.privacyCheckboxChecked,
    };
    final tappedKeys = <String>[];
    var continueTaps = 0;

    await StudyUAppUiFlow(
      shortTimeout: Duration.zero,
      routeTimeout: Duration.zero,
      finalTimeout: Duration.zero,
      waitForKey: (key, {required timeout}) async => visibleKeys.contains(key),
      tapKey: (key) async {
        tappedKeys.add(key);
        if (key == StudyUAppKey.termsContinue && ++continueTaps == 2) {
          visibleKeys
            ..clear()
            ..add(StudyUAppKey.studySelectionList);
        }
      },
    ).completeOnboardingToStudyList();

    expect(tappedKeys, isNot(contains(StudyUAppKey.termsCheckbox)));
    expect(tappedKeys, isNot(contains(StudyUAppKey.privacyCheckbox)));
    expect(visibleKeys, contains(StudyUAppKey.studySelectionList));
  });
}

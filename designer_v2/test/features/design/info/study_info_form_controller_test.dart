import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_controller.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_data.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(AppLocalizationsEn());
  });

  test('empty study icon initializes as no selected icon', () async {
    final study = _studyWithIcon('');
    final formViewModel = StudyInfoFormViewModel(
      study: study,
      autosave: false,
      formData: StudyInfoFormData.fromStudy(study),
    );
    await Future<void>.delayed(Duration.zero);

    expect(formViewModel.iconControl.value, isNull);
    expect(formViewModel.buildFormData().iconName, '');
  });

  test('unknown saved study icon name remains persisted', () async {
    final study = _studyWithIcon('legacyIcon');
    final formViewModel = StudyInfoFormViewModel(
      study: study,
      autosave: false,
      formData: StudyInfoFormData.fromStudy(study),
    );
    await Future<void>.delayed(Duration.zero);

    expect(formViewModel.iconControl.value?.name, 'legacyIcon');
    expect(formViewModel.buildFormData().iconName, 'legacyIcon');
  });
}

Study _studyWithIcon(String iconName) {
  return Study.withId('test-user')
    ..title = 'Study'
    ..iconName = iconName;
}

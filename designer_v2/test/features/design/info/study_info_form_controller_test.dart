import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_controller.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
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

  test(
    'publish requires an icon after removal and accepts reselection',
    () async {
      final study = _studyWithIcon('heartOutline');
      final formViewModel = StudyInfoFormViewModel(
        study: study,
        autosave: false,
        validationSet: StudyFormValidationSet.publish,
        formData: StudyInfoFormData.fromStudy(study),
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        formViewModel.iconControl.hasError(ValidationMessage.required),
        isFalse,
      );
      formViewModel.iconControl.value = null;
      expect(formViewModel.buildFormData().iconName, '');
      expect(
        formViewModel.iconControl.hasError(ValidationMessage.required),
        isTrue,
      );

      formViewModel.iconControl.value = IconPack.resolveIconByName(
        'heartOutline',
      );
      expect(
        formViewModel.iconControl.hasError(ValidationMessage.required),
        isFalse,
      );
      expect(formViewModel.buildFormData().iconName, 'heartOutline');
    },
  );

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

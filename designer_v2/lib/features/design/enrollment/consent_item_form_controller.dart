import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:uuid/uuid.dart';

class ConsentItemFormViewModel({
  super.formData,
  super.delegate,
  super.validationSet = StudyFormValidationSet.draft,
}) extends ManagedFormViewModel<ConsentItemFormData> {
  final FormControl<String> consentIdControl = FormControl(
    value: const Uuid().v4(),
  ); // hidden
  final FormControl<String> titleControl = FormControl();
  final FormControl<String> descriptionControl = FormControl();
  final FormControl<IconOption> iconControl = FormControl();

  String get consentId => consentIdControl.value!;

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: [titleRequired, descriptionRequired],
    StudyFormValidationSet.publish: [titleRequired, descriptionRequired],
    StudyFormValidationSet.test: [titleRequired, descriptionRequired],
  };

  FormControlValidation get titleRequired => FormControlValidation(
    control: titleControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (error) =>
          tr.form_field_consent_title_required,
    },
  );
  FormControlValidation get descriptionRequired => FormControlValidation(
    control: descriptionControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (error) =>
          tr.form_field_consent_text_required,
    },
  );

  @override
  late final FormGroup form = FormGroup({
    'consentId': consentIdControl, // hidden
    'title': titleControl,
    'description': descriptionControl,
    'icon': iconControl,
  });

  @override
  void setControlsFrom(ConsentItemFormData data) {
    consentIdControl.value = data.consentId;
    titleControl.value = data.title;
    descriptionControl.value = data.description;
    iconControl.value = IconOption(data.iconName ?? '');
  }

  @override
  ConsentItemFormData buildFormData() {
    return ConsentItemFormData(
      consentId: consentId,
      title: titleControl.value!, // required
      description: descriptionControl.value!, // required
      iconName: iconControl.value?.name,
    );
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: tr.form_consent_create,
    FormMode.edit: tr.form_consent_edit,
    FormMode.readonly: tr.form_consent_readonly,
  };

  // - ManagedFormViewModel

  @override
  ConsentItemFormViewModel createDuplicate() {
    return ConsentItemFormViewModel(
      delegate: delegate, // TODO
      formData: formData?.copy(),
      validationSet: validationSet,
    );
  }
}

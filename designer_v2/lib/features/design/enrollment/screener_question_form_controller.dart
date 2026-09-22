import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/enrollment/screener_question_logic_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class ScreenerQuestionFormViewModel({
  super.formData,
  super.delegate,
  super.validationSet = StudyFormValidationSet.draft,
  super.titles,
}) extends QuestionFormViewModel
    implements IScreenerQuestionLogicFormViewModel {
  this {
    // Make sure form is initialized with base controls override
    markFormGroupChanged();
  }

  static const defaultResponseOptionValidity = true;

  late final FormArray responseOptionsDisabledArray = FormArray(
    _copyFormControls(answerOptionsArray.controls),
    disabled: true,
  );
  late final FormArray<bool> responseOptionsLogicControls = FormArray(
    List.generate(
      answerOptionsArray.controls.length,
      (index) => FormControl(value: defaultResponseOptionValidity),
    ),
  );
  late final FormArray<String> responseOptionsLogicDescriptionControls =
      FormArray(
        List.generate(
          answerOptionsArray.controls.length,
          (index) => FormControl(),
        ),
      );

  List<AbstractControl> get responseOptionsDisabledControls =>
      responseOptionsDisabledArray.controls;

  List<FormControlOption<bool>> get logicControlOptions => [
    FormControlOption(true, tr.form_screener_question_logic_qualify),
    FormControlOption(false, tr.form_screener_question_logic_disqualify),
  ];

  late final _questionBaseControls = {
    ...super.questionBaseControls,
    'responseOptionLogic': responseOptionsLogicControls,
    'responseOptionLogicDescriptions': responseOptionsLogicDescriptionControls,
  };

  @override
  Map<String, AbstractControl> get questionBaseControls =>
      _questionBaseControls;

  List<AbstractControl> prevResponseOptionControls = [];
  late List<dynamic> prevResponseOptionValues = [];

  @override
  void onResponseOptionsChanged(List<AbstractControl> responseOptionControls) {
    if (formMode == FormMode.readonly) {
      return;
    }

    // Build new form arrays consolidated with previous values (if any)
    final newLogicControls = responseOptionControls.map((newControl) {
      // Consolidate with previous value (if any)
      final idx = prevResponseOptionControls
          .map((c) => c.value)
          .toList()
          .indexOf(newControl.value);
      final newValue = (idx != -1)
          ? responseOptionsLogicControls.controls[idx].value
          : defaultResponseOptionValidity;
      return FormControl<bool>(value: newValue);
    }).toList();
    final newLogicDescriptionControls = responseOptionControls.map((
      newControl,
    ) {
      // Consolidate with previous value (if any)
      final idx = prevResponseOptionControls
          .map((c) => c.value)
          .toList()
          .indexOf(newControl.value);
      final newValue = (idx != -1)
          ? responseOptionsLogicDescriptionControls.controls[idx].value
          : null;
      return FormControl<String>(value: newValue);
    }).toList();
    final newResponseOptionsControls = _copyFormControls(
      responseOptionControls,
    );

    // Keep disabled controls in sync with actual response option controls
    responseOptionsDisabledArray.clear();
    responseOptionsDisabledArray.addAll(newResponseOptionsControls);
    responseOptionsDisabledArray.markAsDisabled();

    // Reset logic controls to new consolidated ones
    prevResponseOptionValues = prevResponseOptionControls
        .map((c) => c.value)
        .toList();
    responseOptionsLogicControls.clear();
    responseOptionsLogicControls.addAll(newLogicControls);
    responseOptionsLogicDescriptionControls.clear();
    responseOptionsLogicDescriptionControls.addAll(newLogicDescriptionControls);

    prevResponseOptionControls = responseOptionControls;
  }

  @override
  void setControlsFrom(QuestionFormData data) {
    super.setControlsFrom(data);
    //prevResponseOptionControls = answerOptionsControls;
    onResponseOptionsChanged(answerOptionsControls);

    for (final entry in data.responseOptionsValidity.entries) {
      final responseOption = entry.key;
      final responseValidity = entry.value;
      final logicControl = _findAssociatedLogicControlFor(
        responseOption: responseOption,
      );
      if (logicControl != null) {
        logicControl.value = responseValidity;
      }
    }
  }

  @override
  QuestionFormData buildFormData() {
    final data = super.buildFormData();

    final Map<dynamic, bool> responseOptionsValidity = {};
    for (var i = 0; i < answerOptionsControls.length; i++) {
      final optionControl = answerOptionsControls[i];
      final logicControl = responseOptionsLogicControls.controls[i];
      responseOptionsValidity[optionControl.value] =
          logicControl.value ?? defaultResponseOptionValidity;
    }
    data.responseOptionsValidity = responseOptionsValidity;

    return data;
  }

  List<AbstractControl> _copyFormControls(List<AbstractControl> controls) {
    return controls.map((control) {
      final Object? value = control.value;
      if (value is Choice) {
        return FormControl<String>(
          value: value.text,
          disabled: control.disabled,
        );
      }
      return FormControl<String>(
        value: value?.toString() ?? '',
        disabled: control.disabled,
      );
    }).toList();
  }

  AbstractControl? _findAssociatedLogicControlFor({
    required dynamic responseOption,
  }) {
    return _findAssociatedControlFor(
      responseOption: responseOption,
      controls: responseOptionsLogicControls.controls,
    );
  }

  AbstractControl? _findAssociatedControlFor({
    required dynamic responseOption,
    required List<AbstractControl> controls,
  }) {
    for (var i = 0; i < controls.length; i++) {
      final optionControl = answerOptionsControls[i];
      final associatedControl = controls[i];
      if (optionControl.value == responseOption) {
        return associatedControl;
      }
    }
    return null;
  }

  @override
  ScreenerQuestionFormViewModel createDuplicate() {
    return ScreenerQuestionFormViewModel(
      delegate: delegate,
      formData: formData?.copy(),
      validationSet: validationSet,
    );
  }

  // - IScreenerQuestionLogicFormViewModel

  @override
  bool get isDirtyOptionsBannerVisible => !prevResponseOptionValues.equals(
    answerOptionsControls.map((c) => c.value).toList(),
  );
}

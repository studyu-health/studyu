import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection_actions.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';
import 'package:uuid/uuid.dart';

class MeasurementSurveyFormViewModel({
  required final Study study,
  super.delegate,
  super.formData,
  super.validationSet = StudyFormValidationSet.draft,
}) extends ManagedFormViewModel<MeasurementSurveyFormData>
    with WithQuestionnaireControls, WithScheduleControls
    implements
        IFormViewModelDelegate<QuestionFormViewModel>,
        IListActionProvider<QuestionFormViewModel>,
        IProviderArgsResolver<QuestionFormViewModel, QuestionFormRouteArgs> {
  // - Form fields

  final FormControl<MeasurementID> measurementIdControl = FormControl(
    value: const Uuid().v4(),
  ); // hidden
  final FormControl<MeasurementID> instanceIdControl = FormControl(
    value: const Uuid().v4(),
  ); // hidden
  final FormControl<String> surveyTitleControl = FormControl(
    value: MeasurementSurveyFormData.kDefaultTitle,
  );
  final FormControl<String> surveyIntroTextControl = FormControl(value: '');
  final FormControl<String> surveyOutroTextControl = FormControl(value: '');

  MeasurementID get measurementId => measurementIdControl.value!;
  MeasurementID get instanceId => instanceIdControl.value!;

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: [titleRequired, atLeastOneQuestion],
    StudyFormValidationSet.publish: [titleRequired, atLeastOneQuestion],
    StudyFormValidationSet.test: [titleRequired, atLeastOneQuestion],
  };

  FormControlValidation get titleRequired => FormControlValidation(
    control: surveyTitleControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (error) =>
          tr.form_field_measurement_survey_title_required,
    },
  );

  FormControlValidation get atLeastOneQuestion => FormControlValidation(
    control: questionsArray,
    validators: [Validators.minLength(1)],
    validationMessages: {
      ValidationMessage.minLength: (error) =>
          tr.form_array_measurement_survey_questions_minlength(
            (error as Map)['requiredLength'] as num,
          ),
    },
  );

  @override
  late final FormGroup form = FormGroup({
    'measurementId': measurementIdControl, // hidden
    'surveyTitle': surveyTitleControl,
    'surveyIntroText': surveyIntroTextControl,
    'surveyOutroText': surveyOutroTextControl,
    ...questionnaireControls,
    ...scheduleFormControls,
  });

  @override
  void setControlsFrom(MeasurementSurveyFormData data) {
    instanceIdControl.value = data.instanceId;
    measurementIdControl.value = data.measurementId;
    surveyTitleControl.value = data.title;
    surveyIntroTextControl.value = data.introText ?? '';
    surveyOutroTextControl.value = data.outroText ?? '';

    setQuestionnaireControlsFrom(data.questionnaireFormData);
    setScheduleControlsFrom(data);
  }

  @override
  MeasurementSurveyFormData buildFormData() {
    final data = MeasurementSurveyFormData(
      measurementId: measurementId, // required hidden
      instanceId: instanceId,
      title: surveyTitleControl.value!, // required
      introText: surveyIntroTextControl.value,
      outroText: surveyOutroTextControl.value,
      questionnaireFormData: buildQuestionnaireFormData(),
      isTimeLocked: isTimeRestrictedControl.value!, // required
      timeLockStart: restrictedTimeStartControl.value?.toStudyUTimeOfDay(),
      timeLockEnd: restrictedTimeEndControl.value?.toStudyUTimeOfDay(),
      hasReminder: hasReminderControl.value!, // required
      reminderTime: reminderTimeControl.value?.toStudyUTimeOfDay(),
    );
    return data;
  }

  String get breadcrumbsTitle {
    final components = [
      study.title,
      formData?.title ?? MeasurementSurveyFormData.kDefaultTitle,
    ];
    return components.join(kPathSeparator);
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: breadcrumbsTitle,
    FormMode.readonly: breadcrumbsTitle,
    FormMode.edit: breadcrumbsTitle,
  };

  // - IListActionProvider

  @override
  List<ModelAction> availableActions(QuestionFormViewModel model) {
    final actions = questionFormViewModels.availableActions(
      model,
      onEdit: onSelectItem,
      confirmationSubject: tr.dialog_subject_question,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availablePopupActions(QuestionFormViewModel model) {
    final actions = questionFormViewModels.availablePopupActions(
      model,
      confirmationSubject: tr.dialog_subject_question,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(QuestionFormViewModel model) {
    final actions = questionFormViewModels.availableInlineActions(
      model,
      confirmationSubject: tr.dialog_subject_question,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  @override
  void onSelectItem(QuestionFormViewModel item) {
    // TODO: open sidesheet programmatically
    print("select item");
  }

  @override
  void onNewItem() {
    // TODO: open sidesheet programmatically
    print("new item");
  }

  // TODO: get rid of this after refactoring sidesheet to route (inject from router)

  SurveyQuestionFormRouteArgs buildNewFormRouteArgs() {
    return SurveyQuestionFormRouteArgs(
      studyId: study.id,
      measurementId: measurementId,
      questionId: Config.newModelId,
    );
  }

  SurveyQuestionFormRouteArgs buildFormRouteArgs(QuestionFormViewModel model) {
    final args = SurveyQuestionFormRouteArgs(
      studyId: study.id,
      measurementId: measurementId,
      questionId: model.questionId,
    );
    return args;
  }

  // ManagedFormViewModel

  @override
  MeasurementSurveyFormViewModel createDuplicate() {
    return MeasurementSurveyFormViewModel(
      study: study,
      delegate: delegate,
      formData: formData?.copy(),
      validationSet: validationSet,
    );
  }
}

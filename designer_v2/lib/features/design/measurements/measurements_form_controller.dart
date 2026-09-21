import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection_actions.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';

class MeasurementsFormViewModel({
  required final Study study,
  required final GoRouter router,
  super.delegate,
  super.formData,
  super.autosave = true,
  super.validationSet = StudyFormValidationSet.draft,
}) extends FormViewModel<MeasurementsFormData>
    implements
        IFormViewModelDelegate<MeasurementSurveyFormViewModel>,
        IListActionProvider<MeasurementSurveyFormViewModel>,
        IProviderArgsResolver<
          MeasurementSurveyFormViewModel,
          MeasurementFormRouteArgs
        > {
  // - Form fields

  final FormArray measurementsArray = FormArray([]);
  late final surveyMeasurementFormViewModels =
      FormViewModelCollection<
        MeasurementSurveyFormViewModel,
        MeasurementSurveyFormData
      >([], measurementsArray);

  List<MeasurementSurveyFormViewModel> get measurementViewModels =>
      surveyMeasurementFormViewModels.formViewModels;

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: [],
    StudyFormValidationSet.publish: [measurementRequired],
    StudyFormValidationSet.test: [],
  };

  FormControlValidation get measurementRequired => FormControlValidation(
    control: measurementsArray,
    validators: [Validators.minLength(1)],
    validationMessages: {
      ValidationMessage.minLength: (error) =>
          tr.form_array_measurements_minlength(
            (error as Map)['requiredLength'] as num,
          ),
    },
  );

  @override
  late final FormGroup form = FormGroup({
    'surveyMeasurements': measurementsArray,
  });

  @override
  void read([MeasurementsFormData? formData]) {
    surveyMeasurementFormViewModels.read();
    super.read(formData);
  }

  @override
  void setControlsFrom(MeasurementsFormData data) {
    final viewModels = data.surveyMeasurements
        .map(
          (data) => MeasurementSurveyFormViewModel(
            study: study,
            formData: data,
            delegate: this,
            validationSet: validationSet,
          ),
        )
        .toList();
    surveyMeasurementFormViewModels.reset(viewModels);
  }

  @override
  MeasurementsFormData buildFormData() {
    return MeasurementsFormData(
      surveyMeasurements: surveyMeasurementFormViewModels.formData,
    );
  }

  @override
  // TODO: implement titles
  Map<FormMode, String> get titles => throw UnimplementedError();

  // - IListActionProvider

  @override
  List<ModelAction> availableActions(MeasurementSurveyFormViewModel model) {
    final actions = surveyMeasurementFormViewModels.availableActions(
      model,
      onEdit: onSelectItem,
      confirmationSubject: tr.dialog_subject_survey,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availablePopupActions(
    MeasurementSurveyFormViewModel model,
  ) {
    final actions = surveyMeasurementFormViewModels.availablePopupActions(
      model,
      confirmationSubject: tr.dialog_subject_survey,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(
    MeasurementSurveyFormViewModel model,
  ) {
    final actions = surveyMeasurementFormViewModels.availableInlineActions(
      model,
      confirmationSubject: tr.dialog_subject_survey,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  @override
  void onSelectItem(MeasurementSurveyFormViewModel item) {
    final studyId = study.id;
    final measurementId = item.measurementId;
    router.dispatch(
      RoutingIntents.studyEditMeasurement(studyId, measurementId),
    );
  }

  @override
  void onNewItem() {
    final viewModel = provide(
      MeasurementFormRouteArgs(
        studyId: study.id,
        measurementId: Config.newModelId,
      ),
    );
    router.dispatch(
      RoutingIntents.studyEditMeasurement(study.id, viewModel.measurementId),
    );
  }

  // - IProviderArgsResolver

  @override
  MeasurementSurveyFormViewModel provide(MeasurementFormRouteArgs args) {
    if (args.measurementId.isNewId) {
      final existingDraft = surveyMeasurementFormViewModels.findWhere(
        (viewModel) => viewModel.formMode == FormMode.create,
      );
      if (existingDraft != null) return existingDraft;

      final viewModel = MeasurementSurveyFormViewModel(
        study: study,
        delegate: this,
        validationSet: validationSet,
      );
      surveyMeasurementFormViewModels.add(viewModel);
      return viewModel;
    }

    final viewModel = surveyMeasurementFormViewModels.findWhere(
      (vm) => vm.measurementId == args.measurementId,
    );
    if (viewModel == null) {
      throw MeasurementNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }

  // - IFormViewModelDelegate

  @override
  void onCancel(
    MeasurementSurveyFormViewModel formViewModel,
    FormMode formMode,
  ) {
    if (formMode == FormMode.create) {
      surveyMeasurementFormViewModels.remove(formViewModel);
    }
  }

  @override
  Future onSave(
    MeasurementSurveyFormViewModel formViewModel,
    FormMode prevFormMode,
  ) async {
    final isNewMeasurement = prevFormMode == FormMode.create;

    if (prevFormMode == FormMode.create) {
      // Commit the managed viewmodel that was eagerly added in [provide]
      surveyMeasurementFormViewModels.commit(formViewModel);
    } else if (prevFormMode == FormMode.edit) {
      // nothing to do here
    }
    await super.save();

    if (isNewMeasurement) {
      router.dispatch(
        RoutingIntents.studyEditMeasurement(
          study.id,
          formViewModel.measurementId,
        ),
      );
    }
  }
}

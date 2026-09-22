import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_data.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_data.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection_actions.dart';
import 'package:studyu_designer_v2/features/study/study_test_app_routes.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';

class InterventionsFormViewModel({
  required final Study study,
  required final GoRouter router,
  super.delegate,
  super.formData,
  super.autosave = true,
  super.validationSet = StudyFormValidationSet.draft,
}) extends FormViewModel<InterventionsFormData>
    with StudyScheduleControls
    implements
        IFormViewModelDelegate<InterventionFormViewModel>,
        IListActionProvider<InterventionFormViewModel>,
        IProviderArgsResolver<
          InterventionFormViewModel,
          InterventionFormRouteArgs
        > {
  // - Form fields

  final FormArray interventionsArray = FormArray([]);
  late final interventionsCollection =
      FormViewModelCollection<InterventionFormViewModel, InterventionFormData>(
        [],
        interventionsArray,
      );

  @override
  late final FormGroup form = FormGroup({
    'interventions': interventionsArray,
    ...studyScheduleControls,
  });

  // - Validation

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: [
      ...studyScheduleValidationConfig[StudyFormValidationSet.draft]!,
    ],
    StudyFormValidationSet.publish: [
      ...studyScheduleValidationConfig[StudyFormValidationSet.publish]!,
      interventionsRequired,
    ],
    StudyFormValidationSet.test: [
      ...studyScheduleValidationConfig[StudyFormValidationSet.test]!,
      interventionsRequired,
    ],
  };

  FormControlValidation get interventionsRequired => FormControlValidation(
    control: interventionsArray,
    validators: [Validators.minLength(2)],
    validationMessages: {
      ValidationMessage.minLength: (error) =>
          tr.form_array_interventions_minlength(
            (error as Map)['requiredLength'] as num,
          ),
    },
  );

  @override
  void setControlsFrom(InterventionsFormData data) {
    final viewModels = data.interventionsData
        .map(
          (data) => InterventionFormViewModel(
            study: study,
            formData: data,
            delegate: this,
            validationSet: validationSet,
          ),
        )
        .toList();
    interventionsCollection.reset(viewModels);
    setStudyScheduleControlsFrom(data.studyScheduleData);
  }

  @override
  InterventionsFormData buildFormData() {
    return InterventionsFormData(
      interventionsData: interventionsCollection.formData,
      studyScheduleData: buildStudyScheduleFormData(),
    );
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError(); // no title

  @override
  void read([InterventionsFormData? formData]) {
    interventionsCollection.read();
    super.read(formData);
  }

  // - IListActionProvider

  @override
  List<ModelAction> availableActions(InterventionFormViewModel model) {
    final actions = interventionsCollection.availableActions(
      model,
      onEdit: onSelectItem,
      confirmationSubject: tr.dialog_subject_intervention,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availablePopupActions(InterventionFormViewModel model) {
    final actions = interventionsCollection.availablePopupActions(
      model,
      confirmationSubject: tr.dialog_subject_intervention,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(InterventionFormViewModel model) {
    final actions = interventionsCollection.availableInlineActions(
      model,
      confirmationSubject: tr.dialog_subject_intervention,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  @override
  void onSelectItem(InterventionFormViewModel item) {
    final studyId = study.id;
    final interventionId = item.interventionId;
    router.dispatch(
      RoutingIntents.studyEditIntervention(studyId, interventionId),
    );
  }

  @override
  void onNewItem() {
    final viewModel = provide(
      InterventionFormRouteArgs(
        studyId: study.id,
        interventionId: Config.newModelId,
      ),
    );
    router.dispatch(
      RoutingIntents.studyEditIntervention(study.id, viewModel.interventionId),
    );
  }

  // - IProviderArgsResolver

  // TODO: factor this out into FormViewModelCollection
  @override
  InterventionFormViewModel provide(InterventionFormRouteArgs args) {
    if (args.interventionId.isNewId) {
      final existingDraft = interventionsCollection.findWhere(
        (viewModel) => viewModel.formMode == FormMode.create,
      );
      if (existingDraft != null) return existingDraft;

      final viewModel = InterventionFormViewModel(
        study: study,
        delegate: this,
        validationSet: validationSet,
      );
      interventionsCollection.add(viewModel);
      return viewModel;
    }

    final viewModel = interventionsCollection.findWhere(
      (vm) => vm.interventionId == args.interventionId,
    );
    if (viewModel == null) {
      throw InterventionNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }

  // - IFormViewModelDelegate

  @override
  void onCancel(InterventionFormViewModel formViewModel, FormMode formMode) {
    if (formMode == FormMode.create) {
      interventionsCollection.remove(formViewModel);
    }
  }

  @override
  Future onSave(
    InterventionFormViewModel formViewModel,
    FormMode prevFormMode,
  ) async {
    if (prevFormMode == FormMode.create) {
      // Commit the managed viewmodel that was eagerly added in [provide]
      interventionsCollection.commit(formViewModel);
    } else if (prevFormMode == FormMode.edit) {
      // nothing to do here
    }
    await super.save();
  }

  void testStudySchedule() {
    router.dispatch(
      RoutingIntents.studyTest(study.id, appRoute: TestAppRoutes.journey),
    );
  }

  bool get canTestStudySchedule =>
      !interventionsArray.disabled && interventionsArray.value!.length >= 2;
}

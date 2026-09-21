import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/intervention.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_data.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection_actions.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';
import 'package:uuid/uuid.dart';

class InterventionFormViewModel({
  required final Study study,
  super.delegate,
  super.formData,
  super.validationSet = StudyFormValidationSet.draft,
}) extends ManagedFormViewModel<InterventionFormData>
    implements
        IFormViewModelDelegate<InterventionTaskFormViewModel>,
        IListActionProvider<InterventionTaskFormViewModel>,
        IProviderArgsResolver<
          InterventionTaskFormViewModel,
          InterventionTaskFormRouteArgs
        > {
  // - Form fields

  final FormControl<InterventionID> interventionIdControl = FormControl(
    value: const Uuid().v4(),
  ); // hidden
  final FormControl<String> interventionTitleControl = FormControl(
    value: InterventionFormData.kDefaultTitle,
  );
  final FormControl<IconOption> interventionIconControl = FormControl();
  final FormControl<String> interventionDescriptionControl = FormControl();

  final FormArray interventionTasksArray = FormArray([]);

  late final tasksCollection =
      FormViewModelCollection<
        InterventionTaskFormViewModel,
        InterventionTaskFormData
      >([], interventionTasksArray);

  InterventionID get interventionId => interventionIdControl.value!;

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: [titleRequired /*atLeastOneTask*/],
    StudyFormValidationSet.publish: [titleRequired /*atLeastOneTask*/],
    StudyFormValidationSet.test: [titleRequired /*atLeastOneTask*/],
  };

  FormControlValidation get titleRequired => FormControlValidation(
    control: interventionTitleControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (error) =>
          tr.form_field_intervention_title_required,
    },
  );

  FormControlValidation get atLeastOneTask => FormControlValidation(
    control: interventionTasksArray,
    validators: [Validators.minLength(1)],
    validationMessages: {
      ValidationMessage.minLength: (error) =>
          tr.form_array_intervention_tasks_minlength(
            (error as Map)['requiredLength'] as num,
          ),
    },
  );

  @override
  late final FormGroup form = FormGroup({
    'interventionId': interventionIdControl, // hidden
    'interventionTitle': interventionTitleControl,
    'interventionDescription': interventionDescriptionControl,
    'interventionTasks': interventionTasksArray,
    'interventionIcon': interventionIconControl,
  });

  @override
  void setControlsFrom(InterventionFormData data) {
    interventionIdControl.value = data.interventionId;
    interventionTitleControl.value = data.title;
    interventionDescriptionControl.value = data.description ?? '';
    interventionIconControl.value = IconOption(data.iconName ?? '');

    if (data.tasksData != null) {
      final viewModels = data.tasksData!
          .map(
            (data) => InterventionTaskFormViewModel(
              formData: data,
              delegate: this,
              validationSet: validationSet,
            ),
          )
          .toList();
      tasksCollection.reset(viewModels);
    }
  }

  @override
  InterventionFormData buildFormData() {
    final data = InterventionFormData(
      interventionId: interventionId, // required hidden
      title: interventionTitleControl.value!, // required
      description: interventionDescriptionControl.value,
      tasksData: tasksCollection.formData,
      iconName: interventionIconControl.value?.name,
    );
    return data;
  }

  String get breadcrumbsTitle {
    final components = [
      study.title,
      formData?.title ?? InterventionFormData.kDefaultTitle,
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
  List<ModelAction> availableActions(InterventionTaskFormViewModel model) {
    final actions = tasksCollection.availableActions(
      model,
      onEdit: onSelectItem,
      confirmationSubject: tr.dialog_subject_intervention_task,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availablePopupActions(InterventionTaskFormViewModel model) {
    final actions = tasksCollection.availablePopupActions(
      model,
      confirmationSubject: tr.dialog_subject_intervention_task,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(
    InterventionTaskFormViewModel model,
  ) {
    final actions = tasksCollection.availableInlineActions(
      model,
      confirmationSubject: tr.dialog_subject_intervention_task,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  @override
  void onSelectItem(InterventionTaskFormViewModel item) {
    // TODO: open sidesheet programmatically
    print("select item");
  }

  @override
  void onNewItem() {
    // TODO: open sidesheet programmatically
    print("new item");
  }

  // - IFormViewModelDelegate

  @override
  void onCancel(
    InterventionTaskFormViewModel formViewModel,
    FormMode prevFormMode,
  ) {
    return; // no-op
  }

  @override
  Future onSave(
    InterventionTaskFormViewModel formViewModel,
    FormMode prevFormMode,
  ) async {
    if (prevFormMode == FormMode.create) {
      // Save the managed viewmodel that was eagerly added in [provide]
      tasksCollection.commit(formViewModel);
    } else if (prevFormMode == FormMode.edit) {
      // nothing to do here
    }
  }

  // - IProviderArgsResolver

  @override
  InterventionTaskFormViewModel provide(InterventionTaskFormRouteArgs args) {
    if (args.taskId.isNewId) {
      // Eagerly add the managed viewmodel in case it needs to be [provide]d
      // to a child controller
      final viewModel = InterventionTaskFormViewModel(
        delegate: this,
        validationSet: validationSet,
      );
      tasksCollection.stage(viewModel);
      return viewModel;
    }

    final viewModel = tasksCollection.findWhere(
      (vm) => vm.taskId == args.taskId,
    );
    if (viewModel == null) {
      throw InterventionTaskNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }

  // TODO: get rid of this after refactoring sidesheet to route (inject from router)

  InterventionTaskFormRouteArgs buildNewFormRouteArgs() {
    return InterventionTaskFormRouteArgs(
      studyId: study.id,
      interventionId: interventionId,
      taskId: Config.newModelId,
    );
  }

  InterventionTaskFormRouteArgs buildFormRouteArgs(
    InterventionTaskFormViewModel model,
  ) {
    final args = InterventionTaskFormRouteArgs(
      studyId: study.id,
      interventionId: interventionId,
      taskId: model.taskId,
    );
    return args;
  }

  // ManagedFormViewModel

  @override
  InterventionFormViewModel createDuplicate() {
    return InterventionFormViewModel(
      study: study,
      delegate: delegate,
      formData: formData?.copy(),
      validationSet: validationSet,
    );
  }
}

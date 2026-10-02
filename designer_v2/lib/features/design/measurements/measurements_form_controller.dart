import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
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
        IFormViewModelDelegate<ManagedFormViewModel>,
        IListActionProvider<ManagedFormViewModel>,
        IProviderArgsResolver<dynamic, MeasurementFormRouteArgs> {
  // - Form fields

  final FormArray measurementsArray = FormArray([]);
  late final measurementViewModelsCollection =
      FormViewModelCollection<
        ManagedFormViewModel<IFormDataWithSchedule>,
        IFormDataWithSchedule
      >([], measurementsArray);

  List<ManagedFormViewModel<IFormDataWithSchedule>> get measurementViewModels =>
      measurementViewModelsCollection.formViewModels;

  bool get canAddMeasurement => study.status == StudyStatus.draft;

  bool get isNutritionEnabled =>
      measurementViewModels.any((vm) => vm is NutritionFormViewModel);

  set isNutritionEnabled(bool enabled) {
    if (enabled) {
      if (!isNutritionEnabled) {
        onNewNutrition();
      }
    } else {
      final nutritionVm = measurementViewModels
          .whereType<NutritionFormViewModel>()
          .firstOrNull;
      if (nutritionVm != null) {
        measurementViewModelsCollection.remove(nutritionVm);
      }
    }
  }

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
  late final FormGroup form = FormGroup({'measurements': measurementsArray});

  @override
  void read([MeasurementsFormData? formData]) {
    measurementViewModelsCollection.read();
    super.read(formData);
  }

  @override
  void setControlsFrom(MeasurementsFormData data) {
    final viewModels = data.measurements
        .map((data) {
          if (data is MeasurementSurveyFormData) {
            return MeasurementSurveyFormViewModel(
              study: study,
              formData: data,
              delegate: this,
              validationSet: validationSet,
            );
          } else if (data is NutritionFormData) {
            return NutritionFormViewModel(
              study: study,
              formData: data,
              delegate: this,
              validationSet: validationSet,
            );
          }
          throw UnimplementedError();
        })
        .cast<ManagedFormViewModel<IFormDataWithSchedule>>()
        .toList();
    measurementViewModelsCollection.reset(viewModels);
  }

  @override
  MeasurementsFormData buildFormData() {
    return MeasurementsFormData(
      measurements: measurementViewModelsCollection.formData,
    );
  }

  @override
  // TODO: implement titles
  Map<FormMode, String> get titles => throw UnimplementedError();

  // - IListActionProvider

  @override
  List<ModelAction> availableActions(ManagedFormViewModel model) {
    final actions = measurementViewModelsCollection.availableActions(
      model as ManagedFormViewModel<IFormDataWithSchedule>,
      onEdit: onSelectItem,
      confirmationSubject: tr.dialog_subject_survey,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availablePopupActions(ManagedFormViewModel model) {
    final actions = measurementViewModelsCollection.availablePopupActions(
      model as ManagedFormViewModel<IFormDataWithSchedule>,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(ManagedFormViewModel model) {
    final actions = measurementViewModelsCollection.availableInlineActions(
      model as ManagedFormViewModel<IFormDataWithSchedule>,
      isReadOnly: isReadonly,
    );
    return withIcons(actions, modelActionIcons);
  }

  @override
  void onSelectItem(ManagedFormViewModel item) {
    final studyId = study.id;
    final MeasurementID measurementId =
        (item as dynamic).measurementId as MeasurementID;
    router.dispatch(
      RoutingIntents.studyEditMeasurement(studyId, measurementId),
    );
  }

  @override
  void onNewItem() {
    onNewSurvey();
  }

  void onNewSurvey() {
    final viewModel = provideWithType(
      MeasurementFormRouteArgs(
        studyId: study.id,
        measurementId: Config.newModelId,
      ),
      null,
    );
    router.dispatch(
      RoutingIntents.studyEditMeasurement(
        study.id,
        (viewModel as dynamic).measurementId as MeasurementID,
      ),
    );
  }

  void onNewNutrition() {
    final viewModel = provideWithType(
      MeasurementFormRouteArgs(
        studyId: study.id,
        measurementId: Config.newModelId,
      ),
      'nutrition',
    );
    router.dispatch(
      RoutingIntents.studyEditMeasurement(
        study.id,
        (viewModel as dynamic).measurementId as MeasurementID,
        queryParameters: {'type': 'nutrition'},
      ),
    );
  }

  // --- Template survey support ---

  /// Check if a survey with the given [title] is already added.
  bool isSurveyWithTitleAdded(String title) {
    return measurementViewModels.any((vm) {
      if (vm is MeasurementSurveyFormViewModel) {
        return vm.formData?.title == title;
      }
      return false;
    });
  }

  /// Apply a single-task survey template (e.g. FFQ 26-question).
  void applyTemplate(SurveyTemplate template) {
    final task = template.buildTask();
    final formData = MeasurementSurveyFormData.fromDomainModel(task);
    final viewModel = MeasurementSurveyFormViewModel(
      study: study,
      formData: formData,
      delegate: this,
      validationSet: validationSet,
    );
    measurementViewModelsCollection.stage(viewModel);
    onSelectItem(viewModel);
  }

  /// Apply a single day entry from a multi-day template (e.g. DHQ3 day 3).
  MeasurementSurveyFormViewModel? applyTemplateDayEntry(
    SurveyTemplateDayEntry entry,
  ) {
    final task = entry.buildTask();
    if (isSurveyWithTitleAdded(task.title ?? '')) return null;
    final phaseDuration = study.schedule.phaseDuration;
    final baseDay = study.schedule.includeBaseline ? phaseDuration : 0;
    final dayIndex = entry.dayIndex;
    final studyDay = dayIndex < 7
        ? baseDay + dayIndex
        : baseDay + phaseDuration + (dayIndex - 7);
    task.scheduleRule = TaskScheduleRule.forSpecificDays([studyDay]);
    final formData = MeasurementSurveyFormData.fromDomainModel(task);
    final viewModel = MeasurementSurveyFormViewModel(
      study: study,
      formData: formData,
      delegate: this,
      validationSet: validationSet,
    );
    measurementViewModelsCollection.stage(viewModel);
    onSelectItem(viewModel);
    return viewModel;
  }

  // - IProviderArgsResolver

  @override
  dynamic provide(MeasurementFormRouteArgs args) => provideWithType(args, null);

  dynamic provideWithType(MeasurementFormRouteArgs args, String? type) {
    if (args.measurementId.isNewId) {
      final existingDraft = measurementViewModelsCollection.findWhere(
        (viewModel) =>
            viewModel.formMode == FormMode.create &&
            (type == 'nutrition'
                ? viewModel is NutritionFormViewModel
                : viewModel is MeasurementSurveyFormViewModel),
      );
      if (existingDraft != null) return existingDraft;

      return type == 'nutrition' ? _provideNewNutrition() : _provideNewSurvey();
    }

    final viewModel = measurementViewModelsCollection.findWhere(
      (vm) => (vm as dynamic).measurementId == args.measurementId,
    );
    if (viewModel != null) return viewModel;

    throw MeasurementNotFoundException();
  }

  MeasurementSurveyFormViewModel _provideNewSurvey() {
    final viewModel = MeasurementSurveyFormViewModel(
      study: study,
      delegate: this,
      validationSet: validationSet,
    );
    measurementViewModelsCollection.add(viewModel);
    return viewModel;
  }

  NutritionFormViewModel _provideNewNutrition() {
    final viewModel = NutritionFormViewModel(
      study: study,
      delegate: this,
      validationSet: validationSet,
    );
    measurementViewModelsCollection.add(viewModel);
    return viewModel;
  }

  // - IFormViewModelDelegate

  @override
  void onCancel(ManagedFormViewModel formViewModel, FormMode formMode) {
    if (formMode != FormMode.create) return;

    final typedVm =
        formViewModel as ManagedFormViewModel<IFormDataWithSchedule>;
    if (!measurementViewModelsCollection.unstage(typedVm)) {
      measurementViewModelsCollection.remove(typedVm);
    }
  }

  @override
  Future onSave(
    ManagedFormViewModel formViewModel,
    FormMode prevFormMode,
  ) async {
    final isNewMeasurement = prevFormMode == FormMode.create;
    final typedVm =
        formViewModel as ManagedFormViewModel<IFormDataWithSchedule>;
    final isStaged = measurementViewModelsCollection.stagedViewModels.contains(
      typedVm,
    );
    if (prevFormMode == FormMode.create || isStaged) {
      measurementViewModelsCollection.commit(typedVm);
    }
    await super.save();

    if (isNewMeasurement) {
      router.dispatch(
        RoutingIntents.studyEditMeasurement(
          study.id,
          (formViewModel as dynamic).measurementId as MeasurementID,
        ),
      );
    }
  }
}

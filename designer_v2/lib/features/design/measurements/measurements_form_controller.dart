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

  String measurementTitle(
    ManagedFormViewModel<IFormDataWithSchedule> viewModel,
  ) {
    if (viewModel is MeasurementSurveyFormViewModel) {
      return viewModel.surveyTitleControl.value ??
          viewModel.formData?.title ??
          '';
    }
    if (viewModel is NutritionFormViewModel) {
      return viewModel.titleControl.value ?? viewModel.formData?.title ?? '';
    }
    return '';
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
    var actions = measurementViewModelsCollection.availablePopupActions(
      model as ManagedFormViewModel<IFormDataWithSchedule>,
      isReadOnly: isReadonly,
    );
    if (model is NutritionFormViewModel) {
      actions = actions
          .where((action) => action.type != ModelActionType.duplicate)
          .toList();
    }
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
    return measurementViewModelsCollection.retrievableViewModels.any((vm) {
      if (vm is MeasurementSurveyFormViewModel) {
        return vm.formData?.title == title;
      }
      return false;
    });
  }

  /// Apply a single-task survey template (e.g. FFQ 26-question).
  MeasurementSurveyFormViewModel? applyTemplate(SurveyTemplate template) {
    final viewModel = _viewModelForTask(template.buildTask());
    if (viewModel == null) return null;
    measurementViewModelsCollection.stage(viewModel);
    onSelectItem(viewModel);
    return viewModel;
  }

  /// Apply a single day entry from a multi-day template (e.g. DHQ3 day 3).
  MeasurementSurveyFormViewModel? applyTemplateDayEntry(
    SurveyTemplateDayEntry entry,
  ) {
    final viewModel = _viewModelForDayEntry(entry);
    if (viewModel == null) return null;
    measurementViewModelsCollection.stage(viewModel);
    onSelectItem(viewModel);
    return viewModel;
  }

  Future<void> addPredefinedMeasurements({
    required bool includeNutrition,
    required Iterable<SurveyTemplate> templates,
    required Iterable<SurveyTemplateDayEntry> dayEntries,
  }) async {
    var changed = false;

    for (final template in templates) {
      final viewModel = _viewModelForTask(template.buildTask());
      if (viewModel == null) continue;
      measurementViewModelsCollection.add(viewModel);
      changed = true;
    }
    for (final entry in dayEntries) {
      final viewModel = _viewModelForDayEntry(entry);
      if (viewModel == null) continue;
      measurementViewModelsCollection.add(viewModel);
      changed = true;
    }
    if (includeNutrition && !isNutritionEnabled) {
      _provideNewNutrition();
      changed = true;
    }

    if (changed) await save();
  }

  MeasurementSurveyFormViewModel? _viewModelForDayEntry(
    SurveyTemplateDayEntry entry,
  ) {
    final task = entry.buildTask();
    final phaseDuration = study.schedule.phaseDuration;
    final baseDay = study.schedule.includeBaseline ? phaseDuration : 0;
    final dayIndex = entry.dayIndex;
    final studyDay = dayIndex < 7
        ? baseDay + dayIndex
        : baseDay + phaseDuration + (dayIndex - 7);
    task.scheduleRule = TaskScheduleRule.forSpecificDays([studyDay]);
    return _viewModelForTask(task);
  }

  MeasurementSurveyFormViewModel? _viewModelForTask(QuestionnaireTask task) {
    if (isSurveyWithTitleAdded(task.title ?? '')) return null;
    return MeasurementSurveyFormViewModel(
      study: study,
      formData: MeasurementSurveyFormData.fromDomainModel(task),
      delegate: this,
      validationSet: validationSet,
    );
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
    final typedVm =
        formViewModel as ManagedFormViewModel<IFormDataWithSchedule>;
    if (measurementViewModelsCollection.unstage(typedVm)) return;
    if (formMode == FormMode.create) {
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

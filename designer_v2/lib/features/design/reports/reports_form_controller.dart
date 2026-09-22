import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/reports/reports_form_data.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_data.dart';
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

class ReportsFormViewModel({
  required final Study study,
  required final GoRouter router,
  super.delegate,
  super.formData,
  super.autosave = true,
  super.validationSet = StudyFormValidationSet.draft,
}) extends FormViewModel<ReportsFormData>
    implements
        IFormViewModelDelegate<ReportItemFormViewModel>,
        IProviderArgsResolver<
          ReportItemFormViewModel,
          ReportItemFormRouteArgs
        > {
  late final reportItemDelegate = ReportFormItemDelegate(
    formViewModelCollection: reportItemFormViewModels,
    owner: this,
    validationSet: super.validationSet,
  );

  // - Form fields

  late final FormArray reportItemArray = FormArray([]);
  late final FormViewModelCollection<
    ReportItemFormViewModel,
    ReportItemFormData
  >
  reportItemFormViewModels = FormViewModelCollection([], reportItemArray);

  List<ReportItemFormViewModel> get reportItemModels =>
      reportItemFormViewModels.formViewModels;

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: [], // TODO
    StudyFormValidationSet.publish: [], // TODO
    StudyFormValidationSet.test: [], // TODO
  };

  @override
  late final FormGroup form = FormGroup({
    'report_specification': reportItemArray,
  });

  @override
  void setControlsFrom(ReportsFormData data) {
    final viewModels = data.reportItems
        .map(
          (data) => ReportItemFormViewModel(
            formData: data,
            delegate: reportItemDelegate,
          ),
        )
        .toList();
    reportItemFormViewModels.reset(viewModels);
  }

  @override
  ReportsFormData buildFormData() {
    return ReportsFormData(reportItems: reportItemFormViewModels.formData);
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError(); // no title

  @override
  void read([ReportsFormData? formData]) {
    reportItemFormViewModels.read();
    super.read(formData);
  }

  ReportItemFormRouteArgs buildNewReportItemFormRouteArgs() {
    return ReportItemFormRouteArgs(
      studyId: study.id,
      sectionId: Config.newModelId,
    );
  }

  ReportItemFormRouteArgs buildReportItemFormRouteArgs(
    ReportItemFormViewModel model,
  ) {
    return ReportItemFormRouteArgs(
      studyId: study.id,
      sectionId: model.sectionId,
    );
  }

  void testReport() {
    // todo
    router.dispatch(
      RoutingIntents.studyTest(study.id, appRoute: TestAppRoutes.consent),
    );
  }

  bool get canTestConsent =>
      !reportItemArray.disabled && (reportItemArray.value?.isNotEmpty ?? false);

  @override
  void onCancel(ReportItemFormViewModel formViewModel, FormMode prevFormMode) {
    throw UnimplementedError();
  }

  @override
  Future onSave(ReportItemFormViewModel formViewModel, FormMode prevFormMode) {
    throw UnimplementedError();
  }

  @override
  ReportItemFormViewModel provide(ReportItemFormRouteArgs args) {
    if (args.sectionId.isNewId) {
      final viewModel = ReportItemFormViewModel(
        formData: formData as ReportItemFormData?,
        delegate: this,
      );
      reportItemFormViewModels.stage(viewModel);
      return viewModel;
    }

    final viewModel = reportItemFormViewModels.findWhere(
      (vm) => vm.sectionId == args.sectionId,
    );
    if (viewModel == null) {
      print("ReportSection not found");
      throw ReportSectionNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }
}

class ReportFormItemDelegate({
  required final FormViewModelCollection<
    ReportItemFormViewModel,
    ReportItemFormData
  >
  formViewModelCollection,
  required final ReportsFormViewModel owner,
  final FormValidationSetEnum? validationSet,
  final bool propagateOnSave = true,
}) implements
    IFormViewModelDelegate<ReportItemFormViewModel>,
    IListActionProvider<ReportItemFormViewModel>,
    IProviderArgsResolver<ReportItemFormViewModel, ReportItemFormRouteArgs> {
  @override
  void onCancel(ReportItemFormViewModel formViewModel, FormMode prevFormMode) {
    return; // no-op
  }

  @override
  Future onSave(
    ReportItemFormViewModel formViewModel,
    FormMode prevFormMode,
  ) async {
    if (prevFormMode == FormMode.create) {
      // Save the managed viewmodel that was eagerly added in [provide]
      formViewModelCollection.commit(formViewModel);
    } else if (prevFormMode == FormMode.edit) {
      // Do nothing
    }
    if (propagateOnSave) {
      await owner.save();
    }
  }

  @override
  ReportItemFormViewModel provide(ReportItemFormRouteArgs args) {
    if (args.sectionId.isNewId) {
      final viewModel = ReportItemFormViewModel(
        delegate: this,
        validationSet: validationSet,
      );
      formViewModelCollection.stage(viewModel);
      return viewModel;
    }

    final viewModel = formViewModelCollection.findWhere(
      (vm) => vm.sectionId == args.sectionId,
    );
    if (viewModel == null) {
      throw ReportSectionNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }

  // - IListActionProvider

  @override
  List<ModelAction> availableActions(ReportItemFormViewModel model) {
    final actions = formViewModelCollection.availablePopupActions(
      model,
      confirmationSubject: tr.dialog_subject_report_section,
      isReadOnly: owner.isReadonly,
    );
    final modalAction = ModelAction(
      type: ModelActionType.primary,
      label: ModelActionType.primary.string,
      isAvailable: !owner.isReadonly,
      onExecute: () {
        for (final e in formViewModelCollection.formViewModels) {
          if (e.formData!.isPrimary) {
            e.formData!.isPrimary = false;
            e.buildFormData().isPrimary = false;
            formViewModelCollection.add(e);
            e.save();
          }
        }
        model.formData!.isPrimary = true;
        model.save();
      },
    );
    if (!owner.isReadonly) {
      actions.insert(0, modalAction);
    }

    return withIcons(actions, modelActionIcons);
  }

  @override
  void onNewItem() {
    // TODO: open sidesheet programmatically
  }

  @override
  void onSelectItem(ReportItemFormViewModel item) {
    // TODO: open sidesheet programmatically
  }
}

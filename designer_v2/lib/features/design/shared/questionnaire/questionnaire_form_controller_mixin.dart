import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';

mixin WithQuestionnaireControls<D, Q extends QuestionFormViewModel>
    on FormViewModel<D>
    implements
        IFormViewModelDelegate<Q>,
        IProviderArgsResolver<Q, QuestionFormRouteArgs> {
  late final FormArray questionsArray = FormArray([]);
  late final questionFormViewModels =
      FormViewModelCollection<Q, QuestionFormData>([], questionsArray);

  List<Q> get questionModels => questionFormViewModels.formViewModels;

  late final questionnaireControls = {'questions': questionsArray};

  void setQuestionnaireControlsFrom(QuestionnaireFormData data) {
    if (data.questionsData != null) {
      final viewModels = data.questionsData!
          .map((data) => provideQuestionFormViewModel(data))
          .toList();
      questionFormViewModels.reset(viewModels);

      _initializeAvailableQuestionsForConditionals(viewModels);
    }
  }

  void _initializeAvailableQuestionsForConditionals(
    List<Q> questionViewModels,
  ) {
    final questions = questionViewModels
        .map((vm) => vm.buildFormData().toQuestion())
        .toList();

    if (questions.isNotEmpty) {
      ConditionRowFormViewModel.availableQuestions = questions;

      for (final vm in questionViewModels) {
        if (vm.questionConditionalControl.value != null) {
          vm.initializeDeferredConditions();
        }
      }
    }
  }

  QuestionnaireFormData buildQuestionnaireFormData() {
    return QuestionnaireFormData(
      questionsData: questionFormViewModels.formData,
    );
  }

  /// May be overridden in subclasses to customize the title
  Map<FormMode, LocalizedStringResolver> get questionTitles => {};

  @override
  void read([D? formData]) {
    questionFormViewModels.read();
    super.read(formData);
  }

  // - IFormViewModelDelegate<QuestionFormViewModel>

  /// Flag indicating whether the [FormViewModel] implementing this mixin
  /// should be saved when one of the managed [QuestionFormViewModel]s is saved
  bool propagateOnSave = false;

  @override
  void onCancel(Q formViewModel, FormMode prevFormMode) {
    return; // no-op
  }

  @override
  Future onSave(Q formViewModel, FormMode prevFormMode) async {
    if (prevFormMode == FormMode.create) {
      // Save the managed viewmodel that was eagerly added in [provide]
      questionFormViewModels.commit(formViewModel);
    } else if (prevFormMode == FormMode.edit) {
      // nothing to do here
    }
    if (propagateOnSave) {
      await super.save();
    }
  }

  // IProviderArgsResolver

  @override
  Q provide(QuestionFormRouteArgs args) {
    if (args.questionId.isNewId) {
      // Eagerly add the managed viewmodel in case it needs to be [provide]d
      // to a child controller
      final viewModel = provideQuestionFormViewModel(null);
      questionFormViewModels.stage(viewModel);
      return viewModel;
    }

    final viewModel = questionFormViewModels.findWhere(
      (vm) => vm.questionId == args.questionId,
    );
    if (viewModel == null) {
      throw QuestionNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }

  Q provideQuestionFormViewModel(QuestionFormData? formData) {
    return QuestionFormViewModel(
      formData: formData,
      delegate: this,
      validationSet: validationSet,
      titles: questionTitles.isNotEmpty ? questionTitles : null,
    ) as Q;
  }
}

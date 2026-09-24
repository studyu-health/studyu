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

  List<Q> get questionModels {
    _ensureQuestionViewModelsInitialized();
    return questionFormViewModels.formViewModels;
  }

  late final questionnaireControls = {'questions': questionsArray};

  /// Raw question data stored for deferred VM creation.
  /// When non-null, the actual [QuestionFormViewModel]s have NOT been created
  /// yet — only lightweight placeholder [FormGroup]s sit in [questionsArray]
  /// so that validation counts (e.g. "at least one question") still work.
  List<QuestionFormData>? _deferredQuestionsData;

  /// Whether the full [QuestionFormViewModel]s have been materialized.
  bool _questionViewModelsInitialized = false;

  void setQuestionnaireControlsFrom(QuestionnaireFormData data) {
    if (data.questionsData != null && data.questionsData!.isNotEmpty) {
      // Store the raw data for deferred creation
      _deferredQuestionsData = data.questionsData;
      _questionViewModelsInitialized = false;

      // Add lightweight placeholder FormGroups to questionsArray so that
      // form validation (e.g. minLength) can count the number of questions
      // without incurring the cost of full QuestionFormViewModel creation.
      questionFormViewModels.formViewModels = [];
      questionsArray.clear();
      for (var i = 0; i < data.questionsData!.length; i++) {
        questionsArray.add(FormGroup({}));
      }
      questionsArray.updateValueAndValidity();
    }
  }

  /// Materializes the full [QuestionFormViewModel]s from the stored raw data.
  /// This is called lazily when the user navigates to edit the survey.
  void _ensureQuestionViewModelsInitialized() {
    if (_questionViewModelsInitialized) return;
    _questionViewModelsInitialized = true;

    if (_deferredQuestionsData == null || _deferredQuestionsData!.isEmpty) {
      return;
    }

    final data = _deferredQuestionsData!;
    _deferredQuestionsData = null; // clear to avoid re-initialization

    final viewModels = data
        .map((d) => provideQuestionFormViewModel(d))
        .toList();
    questionFormViewModels.reset(viewModels);

    _initializeAvailableQuestionsForConditionals(viewModels);
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
    // If VMs haven't been created yet, build directly from stored data
    if (!_questionViewModelsInitialized && _deferredQuestionsData != null) {
      return QuestionnaireFormData(questionsData: _deferredQuestionsData);
    }
    return QuestionnaireFormData(
      questionsData: questionFormViewModels.formData,
    );
  }

  /// May be overridden in subclasses to customize the title
  Map<FormMode, LocalizedStringResolver> get questionTitles => {};

  @override
  void read([D? formData]) {
    if (_questionViewModelsInitialized) {
      questionFormViewModels.read();
    }
    super.read(formData);
  }

  // - IFormViewModelDelegate<QuestionFormViewModel>

  /// Flag indicating whether the [FormViewModel] implementing this mixin
  /// should be saved when one of the managed [QuestionFormViewModel]s is saved
  bool propagateOnSave = false;

  @override
  void onCancel(Q formViewModel, FormMode prevFormMode) {
    questionFormViewModels.unstage(formViewModel);
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
    // Ensure VMs are materialized before providing
    _ensureQuestionViewModelsInitialized();

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

import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/features/design/fitbit/fitbit_credentials_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/color.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/validation.dart';
import 'package:uuid/uuid.dart';

// TODO: refactor break up into separate classes for each type
class QuestionFormViewModel({
  super.formData,
  super.delegate,
  super.validationSet = StudyFormValidationSet.draft,

  /// Customized titles (if any) depending on the context of use
  final Map<FormMode, String Function()>? _titles,
}) extends ManagedFormViewModel<QuestionFormData>
    implements
        IListActionProvider<FormControl<dynamic>>,
        IConditionalQuestionProperties {
  static const defaultQuestionType = SurveyQuestionType.choice;

  this {
    freeTextTypeControl.onChanged(
      (_) => _onFreeTextTypeChanged(freeTextTypeControl.value),
    );
    customRegexControl.setValidators([
      Validators.delegate(_validateCustomRegexExpression),
    ], emitEvent: false);
    customRegexControl.updateValueAndValidity(emitEvent: false);

    // Existing initializations
    boolResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    choiceResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    _scaleResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    imageResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    audioResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    freeTextResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    fitbitResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    painResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
    dateResponseOptionsArray.onChanged(
      (control) => onResponseOptionsChanged(control.controls),
    );
  }

  // - Form fields (any question type)

  final FormControl<QuestionID> questionIdControl = FormControl(
    value: const Uuid().v4(),
  ); // hidden
  late final FormControl<SurveyQuestionType> questionTypeControl =
      CustomFormControl(
        value: defaultQuestionType,
        onValueChanged: onQuestionTypeChanged,
      );
  final FormControl<String> questionTextControl = FormControl();
  final FormControl<String> questionInfoTextControl = FormControl();

  @override
  String get currentQuestionId => questionIdControl.value!;

  @override
  CompositeExpression? get compositeExpression =>
      conditionalProperties.compositeExpression;

  @override
  FormControl<LogicType> get logicTypeControl =>
      conditionalProperties.logicTypeControl;

  @override
  FormArray get conditionsArray => conditionalProperties.conditionsArray;

  @override
  Stream<void> get conditionsValueChanges =>
      conditionalProperties.conditionsValueChanges;

  @override
  void addCondition({Expression? initialExpression}) =>
      conditionalProperties.addCondition(initialExpression: initialExpression);

  @override
  void updateCondition() => conditionalProperties.updateCondition();

  @override
  List<ConditionRowFormViewModel> get conditionModels =>
      conditionalProperties.conditionModels;

  @override
  void removeCondition(int index) =>
      conditionalProperties.removeCondition(index);

  @override
  void cleanupInvalidConditions() =>
      conditionalProperties.cleanupInvalidConditions();

  @override
  void initializeDeferredConditions() =>
      conditionalProperties.initializeDeferredConditions();

  // Initialize from existing data
  /*void _initializeConditions(QuestionConditional<bool>? initialCondition) {
    conditionsArray.clear();
    if (initialCondition != null) {
      CompositeExpression initialComposite;
      initialComposite = initialCondition.condition;
      for (final expression in initialComposite.expressions) {
        addCondition(allQuestions: , initialExpression: expression);
      }
      logicTypeControl.value = initialComposite.logicType;
    }
  }*/

  QuestionID get questionId => questionIdControl.value!;

  SurveyQuestionType get questionType =>
      questionTypeControl.value ?? defaultQuestionType;

  List<FormControlOption<SurveyQuestionType>> get questionTypeControlOptions =>
      QuestionFormData.questionTypeFormDataFactories.keys
          .map(
            (questionType) =>
                FormControlOption(questionType, questionType.string),
          )
          .toList();

  @override
  final FormControl<QuestionConditional<dynamic>?> questionConditionalControl =
      FormControl<QuestionConditional<dynamic>?>();

  late final Map<String, AbstractControl> questionBaseControls = {
    'questionId': questionIdControl, // hidden
    'questionType': questionTypeControl,
    'questionText': questionTextControl,
    'questionInfoText': questionInfoTextControl,
    'questionConditional': questionConditionalControl,
  };

  // - Form fields (question type-specific)

  // Multiple Choice
  final FormControl<bool> isMultipleChoiceControl = FormControl(
    validators: [Validators.required],
    value: false,
  );
  final FormControl<bool> isSelectionRequiredControl = FormControl(
    validators: [Validators.required],
    value: false,
  );
  late final FormArray<Choice> choiceResponseOptionsArray = FormArray([
    for (int i = 0; i < customOptionsInitial; i++)
      FormControl(value: Choice.withId()),
  ]);
  final int customOptionsMin = 2;
  final int customOptionsMax = 10;
  final int customOptionsInitial = 2;

  FormArray get answerOptionsArray => {
    SurveyQuestionType.bool: boolResponseOptionsArray,
    SurveyQuestionType.choice: choiceResponseOptionsArray,
    SurveyQuestionType.scale: _scaleResponseOptionsArray,
    SurveyQuestionType.image: imageResponseOptionsArray,
    SurveyQuestionType.audio: audioResponseOptionsArray,
    SurveyQuestionType.freeText: freeTextResponseOptionsArray,
    SurveyQuestionType.fitbit: fitbitResponseOptionsArray,
    SurveyQuestionType.pain: painResponseOptionsArray,
    SurveyQuestionType.date: dateResponseOptionsArray,
  }[questionType]!;

  List<AbstractControl> get answerOptionsControls =>
      answerOptionsArray.controls;

  List<Choice> get validAnswerOptions {
    final List<Choice> options = [];
    for (final optionValue in answerOptionsArray.value ?? []) {
      if (optionValue != null) {
        options.add(optionValue as Choice);
      }
    }
    return options;
  }

  // Yes/no
  List<AbstractControl<String>> get boolOptions => BoolQuestionFormData
      .kResponseOptions
      .keys
      .map((e) => FormControl(value: e, disabled: true))
      .toList();
  late final FormArray<String> boolResponseOptionsArray = FormArray(
    boolOptions,
  );

  // Image
  List<AbstractControl<String>> get imageOptions => BoolQuestionFormData
      .kResponseOptions
      .keys
      .map((e) => FormControl(value: e, disabled: true))
      .toList();
  late final FormArray<String> imageResponseOptionsArray = FormArray(
    imageOptions,
  );

  //Pain
  List<AbstractControl<String>> get painOptions => PainQuestionFormData
      .kResponseOptions
      .keys
      .map((e) => FormControl(value: e, disabled: true))
      .toList();

  late final FormArray<String> painResponseOptionsArray = FormArray(
    painOptions,
  );

  // Date
  final FormControl<DateInputType> dateInputTypeControl =
      FormControl<DateInputType>(value: DateInputType.date);
  late final FormControl<DateTime?> dateMinControl =
      CustomFormControl<DateTime?>(
        onValueChanged: (_) => _onDateRangeChanged('dateMin'),
      );
  late final FormControl<DateTime?> dateMaxControl =
      CustomFormControl<DateTime?>(
        onValueChanged: (_) => _onDateRangeChanged('dateMax'),
      );
  final FormControl<String?> dateMinTimeControl = FormControl<String?>();
  final FormControl<String?> dateMaxTimeControl = FormControl<String?>();
  final FormControl<DateFormatPreset> dateFormatPresetControl =
      FormControl<DateFormatPreset>(value: DateFormatPreset.iso);
  final FormControl<TimeFormatPreset> timeFormatPresetControl =
      FormControl<TimeFormatPreset>(value: TimeFormatPreset.h24);
  final FormControl<DefaultDateOption> dateDefaultOptionControl =
      FormControl<DefaultDateOption>(value: DefaultDateOption.none);
  late final FormControl<DateTime?> dateDefaultSpecificDateControl =
      CustomFormControl<DateTime?>(
        onValueChanged: (_) =>
            dateDefaultOptionControl.updateValueAndValidity(),
      );
  final FormControl<String?> dateDefaultSpecificTimeControl =
      FormControl<String?>();

  late final FormArray dateResponseOptionsArray = FormArray([
    dateInputTypeControl,
    dateMinControl,
    dateMaxControl,
    dateMinTimeControl,
    dateMaxTimeControl,
    dateFormatPresetControl,
    timeFormatPresetControl,
    dateDefaultOptionControl,
    dateDefaultSpecificDateControl,
    dateDefaultSpecificTimeControl,
  ]);

  // Audio
  static const int kDefaultMaxRecordingDurationSeconds = 60;
  static const int kMaxRecordingDurationSeconds = 3600;
  List<AbstractControl<String>> get audioOptions => AudioQuestionFormData
      .kResponseOptions
      .keys
      .map((e) => FormControl(value: e, disabled: true))
      .toList();
  late final FormArray<String> audioResponseOptionsArray = FormArray(
    audioOptions,
  );
  final FormControl<int> maxRecordingDurationSecondsControl = FormControl(
    value: kDefaultMaxRecordingDurationSeconds,
    validators: [
      Validators.number(allowNegatives: false),
      Validators.min(1),
      Validators.max(kMaxRecordingDurationSeconds),
    ],
  );

  // Scale
  static const int kDefaultScaleMinValue = 0;
  static const int kDefaultScaleMaxValue = 10;
  static const int kNumMidValueControls = 10;
  static const int kMidValueDebounceMilliseconds = 350;

  late final FormControl<int> scaleMinValueControl = CustomFormControl(
    value: kDefaultScaleMinValue,
    onValueChanged: (_) => _onScaleRangeChanged(),
    onValueChangedDebounceTime: kMidValueDebounceMilliseconds,
  );
  late final FormControl<int> scaleMaxValueControl = CustomFormControl(
    value: kDefaultScaleMaxValue,
    onValueChanged: (_) => _onScaleRangeChanged(),
    onValueChangedDebounceTime: kMidValueDebounceMilliseconds,
  );
  late final FormControl<int> _scaleRangeControl = FormControl(
    value: scaleRange,
  ); // hidden
  final FormControl<String> scaleMinLabelControl = FormControl();
  final FormControl<String> scaleMaxLabelControl = FormControl();
  final FormArray<int> scaleMidValueControls = FormArray([]);
  final FormArray<String?> scaleMidLabelControls = FormArray([]);
  late final FormArray<int> _scaleResponseOptionsArray = FormArray([
    ...scaleAllValueControls,
  ]);

  final FormControl<SerializableColor> scaleMinColorControl = FormControl();
  final FormControl<SerializableColor> scaleMaxColorControl = FormControl();

  List<int?>? prevMidValues;

  int get scaleMinValue => scaleMinValueControl.value ?? kDefaultScaleMinValue;

  int get scaleMaxValue => scaleMaxValueControl.value ?? 0;

  int get scaleRange => scaleMaxValue - scaleMinValue;

  List<AbstractControl<int>> get scaleAllValueControls => [
    scaleMinValueControl,
    ...scaleMidValueControls.controls,
    scaleMaxValueControl,
  ];

  String? scaleMidLabelAt(int scaleMidValue) {
    final idx = scaleMidValueControls.value?.indexOf(scaleMidValue);
    if (idx == null || idx == -1) {
      return null;
    }
    return scaleMidLabelControls.value?[idx];
  }

  void _onScaleRangeChanged() {
    if (formMode == FormMode.readonly) {
      return; // prevent change listener from firing in readonly mode
    }
    _applyInputFormatters();
    _scaleRangeControl.value = scaleMaxValue - scaleMinValue;
    _updateScaleMidValueControls();
    _scaleResponseOptionsArray.clear();
    _scaleResponseOptionsArray.addAll(scaleAllValueControls);
  }

  void _applyInputFormatters() {
    // TODO refactor to FormControl extension or text field input formatters
    scaleMinValueControl.value ??= 0;
    scaleMaxValueControl.value ??= 0;
  }

  void _updateScaleMidValueControls() {
    final int midValueStepSize = max(
      (scaleMaxValue / kNumMidValueControls).ceil(),
      1,
    );
    final List<int> midValues = [];
    final List<String> midLabels = [];

    for (
      int midValue = scaleMinValue + kDefaultScaleMinValue + midValueStepSize;
      midValue < scaleMaxValue;
      midValue += midValueStepSize
    ) {
      final prevLabel = scaleMidLabelAt(midValue);
      midValues.add(midValue);
      midLabels.add(prevLabel ?? ''); // retain previous label at value if any
      if (midValues.length >= kNumMidValueControls) {
        break;
      }
    }

    // Reset controls to new values + labels
    prevMidValues = scaleMidValueControls.value;
    scaleMidValueControls.clear();
    scaleMidLabelControls.clear();
    scaleMidValueControls.value = midValues;
    scaleMidLabelControls.value = midLabels;

    // Prevent mid-value controls from being edited
    scaleMidValueControls.markAsDisabled();
  }

  // Free Text
  final FormControl<FreeTextQuestionType> freeTextTypeControl =
      FormControl<FreeTextQuestionType>(value: FreeTextQuestionType.any);

  final FormControl<String> customRegexControl = FormControl<String>();
  late final FormArray freeTextResponseOptionsArray = FormArray([
    freeTextLengthMin,
    freeTextLengthMax,
    freeTextTypeControl,
    customRegexControl,
  ]);
  late final AbstractControl<int> freeTextLengthMin = FormControl(
    value: freeTextLengthControl.value!.start.toInt(),
  );
  late final AbstractControl<int> freeTextLengthMax = FormControl(
    value: freeTextLengthControl.value!.end.toInt(),
  );
  late final FormControl<String> freeTextExampleTextControl =
      FormControl<String>(
        value: '',
        validators: [Validators.delegate(_validateFreeText)],
      );

  void _onFreeTextTypeChanged(FreeTextQuestionType? _) {
    customRegexControl.updateValueAndValidity();
    freeTextExampleTextControl.updateValueAndValidity();
  }

  String? _buildFullMatchRegexPattern(String? expression) {
    if (expression == null || expression.isEmpty) {
      return null;
    }

    final fullMatchPattern = '^(?:$expression)\$';
    try {
      RegExp(fullMatchPattern);
    } on FormatException {
      return null;
    }
    return fullMatchPattern;
  }

  Map<String, dynamic>? _validateCustomRegexExpression(
    AbstractControl<dynamic> control,
  ) {
    if (freeTextTypeControl.value != FreeTextQuestionType.custom) {
      return null;
    }

    final expression = control.value as String?;
    if (expression == null || expression.isEmpty) {
      return {ValidationMessage.required: true};
    }

    if (_buildFullMatchRegexPattern(expression) == null) {
      return {ValidationMessage.pattern: true};
    }

    return null;
  }

  Map<String, dynamic>? _validateFreeText(AbstractControl<dynamic> control) {
    final List<Validator> validators = [];

    if (freeTextTypeControl.value != FreeTextQuestionType.custom) {
      validators.add(Validators.minLength(freeTextLengthMin.value!));
      validators.add(Validators.maxLength(freeTextLengthMax.value!));
    }

    switch (freeTextTypeControl.value) {
      case FreeTextQuestionType.any:
        break;
      case FreeTextQuestionType.alphanumeric:
        validators.add(Validators.pattern(alphanumericPattern));
      case FreeTextQuestionType.numeric:
        validators.add(Validators.number(allowNegatives: false));
      case FreeTextQuestionType.custom:
        final pattern = _buildFullMatchRegexPattern(customRegexControl.value);
        if (pattern == null) {
          return {ValidationMessage.pattern: true};
        }
        validators.add(Validators.pattern(pattern));
      case null:
        return {'null': "freeTextTypeControl.value is null"};
    }

    return Validators.compose(validators)(control);
  }

  static const int kDefaultFreeTextMinLength = 0;
  static const int kDefaultFreeTextMaxLength = 1000;

  late final FormControl<RangeValues> freeTextLengthControl =
      CustomFormControl<RangeValues>(
        value: RangeValues(
          kDefaultFreeTextMinLength.toDouble(),
          kDefaultFreeTextMaxLength.toDouble() / 2,
        ),
        onValueChanged: (_) => _onFreeTextLengthChanged(),
      );

  void _onFreeTextLengthChanged() {
    if (formMode == FormMode.readonly) {
      return; // prevent change listener from firing in readonly mode
    }
    freeTextLengthMin.value = freeTextLengthControl.value!.start.toInt();
    freeTextLengthMax.value = freeTextLengthControl.value!.end.toInt();
  }

  // Date validation helpers
  bool _isRevalidatingDateRange = false;

  void _onDateRangeChanged([String? source]) {
    if (formMode == FormMode.readonly) return;
    if (_isRevalidatingDateRange) {
      return;
    }
    _isRevalidatingDateRange = true;
    Future.microtask(() {
      // emitEvent: false prevents valueChanges emissions that would trigger
      // downstream CustomFormControl.onValueChanged callbacks, breaking the loop
      dateMaxControl.updateValueAndValidity(emitEvent: false);
      dateDefaultOptionControl.updateValueAndValidity(emitEvent: false);
      _isRevalidatingDateRange = false;
    });
  }

  // Fitbit

  final Map<FitbitQuestionType, FormControl<bool>> fitbitQuestionTypesControl =
      Map.fromEntries(
        FitbitQuestionType.values.map(
          (e) => MapEntry(e, FormControl<bool>(value: false)),
        ),
      );

  late final FormArray fitbitResponseOptionsArray = FormArray(
    fitbitQuestionTypesControl.values.toList(),
  );

  FitbitCredentialsFormViewModel? _fitbitCredentialsFormViewModel;
  FitbitCredentialsFormViewModel? get fitbitCredentialsFormViewModel =>
      _fitbitCredentialsFormViewModel;

  // - Form fields (question type-specific) - end

  late final Map<SurveyQuestionType, FormGroup> _controlsByQuestionType = {
    SurveyQuestionType.bool: FormGroup({
      'boolOptionsArray': boolResponseOptionsArray,
    }),
    SurveyQuestionType.choice: FormGroup({
      'isMultipleChoice': isMultipleChoiceControl,
      'isSelectionRequired': isSelectionRequiredControl,
      'choiceOptionsArray': choiceResponseOptionsArray,
    }),
    SurveyQuestionType.scale: FormGroup({
      'scaleMinValue': scaleMinValueControl,
      'scaleMaxValue': scaleMaxValueControl,
      '_scaleRange': _scaleRangeControl, // hidden, included for validation
      'scaleMinLabel': scaleMinLabelControl,
      'scaleMaxLabel': scaleMaxLabelControl,
      'scaleMidValues': scaleMidValueControls,
      'scaleMidLabels': scaleMidLabelControls,
      'scaleMinColor': scaleMinColorControl,
      'scaleMaxColor': scaleMaxColorControl,
    }),
    SurveyQuestionType.image: FormGroup({
      'imageOptionsArray': imageResponseOptionsArray,
    }),
    SurveyQuestionType.audio: FormGroup({
      'audioOptionsArray': audioResponseOptionsArray,
      'maxRecordingDurationSeconds': maxRecordingDurationSecondsControl,
    }),
    SurveyQuestionType.freeText: FormGroup({
      'freeTextOptionsArray': freeTextResponseOptionsArray,
    }),
    SurveyQuestionType.fitbit: FormGroup({
      'fitbitOptionsArray': fitbitResponseOptionsArray,
    }),
    SurveyQuestionType.pain: FormGroup({
      'painOptionsArray': painResponseOptionsArray,
    }),
    SurveyQuestionType.date: FormGroup({
      'dateInputType': dateInputTypeControl,
      'dateMin': dateMinControl,
      'dateMax': dateMaxControl,
      'dateMinTime': dateMinTimeControl,
      'dateMaxTime': dateMaxTimeControl,
      'dateFormatPreset': dateFormatPresetControl,
      'timeFormatPreset': timeFormatPresetControl,
      'dateDefaultOption': dateDefaultOptionControl,
      'dateDefaultSpecificDate': dateDefaultSpecificDateControl,
      'dateDefaultSpecificTime': dateDefaultSpecificTimeControl,
    }),
  };

  late final FormValidationConfigSet _sharedValidationConfig = {
    StudyFormValidationSet.draft: [questionTextRequired],
    StudyFormValidationSet.publish: [questionTextRequired],
  };

  late final Map<SurveyQuestionType, FormValidationConfigSet>
  _validationConfigsByQuestionType = {
    SurveyQuestionType.choice: {
      StudyFormValidationSet.draft: [numValidChoiceOptions],
      StudyFormValidationSet.publish: [numValidChoiceOptions],
    },
    SurveyQuestionType.scale: {
      StudyFormValidationSet.draft: [scaleRangeValid],
      StudyFormValidationSet.publish: [scaleRangeValid],
    },
    SurveyQuestionType.audio: {
      StudyFormValidationSet.draft: [maxRecordingDurationValid],
      StudyFormValidationSet.publish: [maxRecordingDurationValid],
    },
    SurveyQuestionType.fitbit: {
      StudyFormValidationSet.draft: [
        fitbitTypeRequired,
        if (_fitbitCredentialsFormViewModel != null) fitbitClientIdRequired,
        if (_fitbitCredentialsFormViewModel != null) fitbitClientSecretRequired,
      ],
      StudyFormValidationSet.publish: [
        fitbitTypeRequired,
        if (_fitbitCredentialsFormViewModel != null) fitbitClientIdRequired,
        if (_fitbitCredentialsFormViewModel != null) fitbitClientSecretRequired,
      ],
    },
    SurveyQuestionType.date: {
      StudyFormValidationSet.draft: [dateRangeValid, dateDefaultValid],
      StudyFormValidationSet.publish: [dateRangeValid, dateDefaultValid],
    },
  };

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: _getValidationConfig(
      StudyFormValidationSet.draft,
    ),
    StudyFormValidationSet.publish: _getValidationConfig(
      StudyFormValidationSet.publish,
    ),
    StudyFormValidationSet.test: _getValidationConfig(
      StudyFormValidationSet.test,
    ),
  };

  List<FormControlValidation> _getValidationConfig(
    StudyFormValidationSet validationSet,
  ) {
    return [
      ..._sharedValidationConfig[validationSet] ?? [],
      ..._validationConfigsByQuestionType[questionType]?[validationSet] ?? [],
    ];
  }

  FormControlValidation get fitbitTypeRequired => FormControlValidation(
    control: fitbitResponseOptionsArray,
    validators: [
      CountWhereValidator<dynamic>(
        (dynamic value) => value == true,
        minCount: 1,
      ),
    ],
    validationMessages: {
      CountWhereValidator.kValidationMessageMinCount: (error) =>
          tr.fitbit_question_type_required,
    },
  );

  FormControlValidation get fitbitClientIdRequired => FormControlValidation(
    control: _fitbitCredentialsFormViewModel!.clientIdControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (_) => tr.fitbit_client_id_required,
    },
  );

  FormControlValidation get fitbitClientSecretRequired => FormControlValidation(
    control: _fitbitCredentialsFormViewModel!.clientSecretControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (_) => tr.fitbit_client_secret_required,
    },
  );

  FormControlValidation get questionTextRequired => FormControlValidation(
    control: questionTextControl,
    validators: [Validators.required, Validators.minLength(1)],
    validationMessages: {
      ValidationMessage.required: (error) => tr.form_field_question_required,
      ValidationMessage.minLength: (error) => tr.form_field_question_required,
    },
  );

  FormControlValidation get numValidChoiceOptions => FormControlValidation(
    control: choiceResponseOptionsArray,
    validators: [
      CountWhereValidator<dynamic>(
        (dynamic value) => value != null,
        minCount: customOptionsMin,
        maxCount: customOptionsMax,
      ),
    ],
    validationMessages: {
      CountWhereValidator.kValidationMessageMaxCount: (error) =>
          tr.form_array_response_options_choice_countmax(customOptionsMax),
      CountWhereValidator.kValidationMessageMinCount: (error) =>
          tr.form_array_response_options_choice_countmin(customOptionsMin),
    },
  );

  FormControlValidation get scaleRangeValid {
    const int scaleRangeValidMax = 1000;
    return FormControlValidation(
      control: _scaleRangeControl,
      validators: [Validators.min(1), Validators.max(scaleRangeValidMax)],
      validationMessages: {
        'min': (error) => tr.form_array_response_options_scale_rangevalid_min,
        'max': (error) => tr.form_array_response_options_scale_rangevalid_max(
          scaleRangeValidMax,
        ),
      },
    );
  }

  FormControlValidation get maxRecordingDurationValid {
    return FormControlValidation(
      control: maxRecordingDurationSecondsControl,
      validators: [
        Validators.number(allowNegatives: false),
        Validators.min(1),
        Validators.max(kMaxRecordingDurationSeconds),
      ],
      validationMessages: {
        ValidationMessage.min: (error) =>
            tr.audio_recording_max_duration_rangevalid_min,
        ValidationMessage.max: (error) =>
            tr.audio_recording_max_duration_rangevalid_max(
              QuestionFormViewModel.kMaxRecordingDurationSeconds,
            ),
        ValidationMessage.number: (error) => tr.free_text_validation_number,
      },
    );
  }

  FormControlValidation get dateRangeValid {
    return FormControlValidation(
      control: dateMaxControl,
      validators: [Validators.delegate(_validateDateRange)],
      validationMessages: {
        'minGreaterThanMax': (error) => tr.date_validation_min_greater_than_max,
      },
    );
  }

  Map<String, dynamic>? _validateDateRange(AbstractControl<dynamic> control) {
    final min = dateMinControl.value;
    final max = dateMaxControl.value;

    if (min != null && max != null) {
      final minNormalized = DateTime(min.year, min.month, min.day);
      final maxNormalized = DateTime(max.year, max.month, max.day);
      if (minNormalized.isAfter(maxNormalized)) {
        return {'minGreaterThanMax': true};
      }
    }

    return null;
  }

  FormControlValidation get dateDefaultValid {
    return FormControlValidation(
      control: dateDefaultOptionControl,
      validators: [Validators.delegate(_validateDateDefault)],
      validationMessages: {
        'todayBeforeMinDate': (error) =>
            tr.date_validation_default_today_before_min,
        'todayAfterMaxDate': (error) =>
            tr.date_validation_default_today_after_max,
        'specificBeforeMinDate': (error) =>
            tr.date_validation_default_specific_before_min,
        'specificAfterMaxDate': (error) =>
            tr.date_validation_default_specific_after_max,
      },
    );
  }

  Map<String, dynamic>? _validateDateDefault(AbstractControl<dynamic> control) {
    final defaultOption = dateDefaultOptionControl.value;
    final minDate = dateMinControl.value;
    final maxDate = dateMaxControl.value;
    final today = DateTime.now();

    if (defaultOption == null) return null;

    switch (defaultOption) {
      case DefaultDateOption.today:
        // Check if "today" is within the allowed date range
        if (minDate != null) {
          // Normalize to date only (ignore time)
          final todayDate = DateTime(today.year, today.month, today.day);
          final minDateNormalized = DateTime(
            minDate.year,
            minDate.month,
            minDate.day,
          );
          if (todayDate.isBefore(minDateNormalized)) {
            return {'todayBeforeMinDate': true};
          }
        }
        if (maxDate != null) {
          final todayDate = DateTime(today.year, today.month, today.day);
          final maxDateNormalized = DateTime(
            maxDate.year,
            maxDate.month,
            maxDate.day,
          );
          if (todayDate.isAfter(maxDateNormalized)) {
            return {'todayAfterMaxDate': true};
          }
        }
      case DefaultDateOption.specific:
        // Check if specific default date is within range
        final specificDate = dateDefaultSpecificDateControl.value;
        if (specificDate != null) {
          if (minDate != null) {
            final specificDateNormalized = DateTime(
              specificDate.year,
              specificDate.month,
              specificDate.day,
            );
            final minDateNormalized = DateTime(
              minDate.year,
              minDate.month,
              minDate.day,
            );
            if (specificDateNormalized.isBefore(minDateNormalized)) {
              return {'specificBeforeMinDate': true};
            }
          }
          if (maxDate != null) {
            final specificDateNormalized = DateTime(
              specificDate.year,
              specificDate.month,
              specificDate.day,
            );
            final maxDateNormalized = DateTime(
              maxDate.year,
              maxDate.month,
              maxDate.day,
            );
            if (specificDateNormalized.isAfter(maxDateNormalized)) {
              return {'specificAfterMaxDate': true};
            }
          }
        }
      default:
        // "now" for time and "none" don't need date validation
        break;
    }

    return null;
  }

  /// The form containing the controls for the currently selected
  /// [SurveyQuestionType]
  ///
  /// By default, contains all the controls shared among question types.
  /// Controls specific to the currently selected [questionType] are added /
  /// removed dynamically via the [_questionTypeChanges] subscription.
  @override
  late final FormGroup form = FormGroup({
    ...questionBaseControls,
    ..._controlsByQuestionType[questionType]!.controls,
    // Note: conditionalProperties.form.controls are excluded to prevent
    // transient conditional logic state from affecting isDirty checks
  });

  late final conditionalProperties = ConditionalQuestionFormViewModel(
    currentQuestionId: questionIdControl.value!,
    questionConditionalControl: questionConditionalControl,
  );

  void onQuestionTypeChanged(SurveyQuestionType? questionType) {
    _updateFormControls(questionType);
  }

  void onResponseOptionsChanged(List<AbstractControl> responseOptionControls) {
    return; // subclass responsibility
  }

  /// Dynamically updates the [form] based on the given [questionType]
  void _updateFormControls(SurveyQuestionType? questionType) {
    final subtypeFormControls = _controlsByQuestionType[questionType]!.controls;
    for (final controlName in form.controls.keys) {
      if (!questionBaseControls.containsKey(controlName)) {
        form.removeControl(controlName, emitEvent: false);
      }
    }
    form.addAll(subtypeFormControls);
    markFormGroupChanged();
    onResponseOptionsChanged(answerOptionsControls);
  }

  void attachFitbitCredentialsFormViewModel(
    FitbitCredentialsFormViewModel fitbitCredentialsFormViewModel,
  ) {
    if (identical(
      _fitbitCredentialsFormViewModel,
      fitbitCredentialsFormViewModel,
    )) {
      return;
    }
    _fitbitCredentialsFormViewModel = fitbitCredentialsFormViewModel;
    fitbitCredentialsFormViewModel.enableQuestionValidation();
    revalidate();
    form.updateValueAndValidity();
  }

  @override
  void initControls() {
    _updateScaleMidValueControls();
  }

  @override
  void setControlsFrom(QuestionFormData data) {
    // Shared controls
    questionIdControl.value = data.questionId;
    questionTextControl.value = data.questionText;
    questionTypeControl.value = data.questionType;
    questionInfoTextControl.value = data.questionInfoText ?? '';

    questionConditionalControl.value = data.conditional;
    conditionalProperties.setControlsFrom(
      null,
    ); // Will read from questionConditionalControl

    // Type-specific controls
    switch (data.questionType) {
      case SurveyQuestionType.bool:
        break;
      case SurveyQuestionType.image:
        break;
      case SurveyQuestionType.audio:
        maxRecordingDurationSecondsControl.value =
            (data as AudioQuestionFormData).maxRecordingDurationSeconds;
      case SurveyQuestionType.choice:
        isMultipleChoiceControl.value =
            (data as ChoiceQuestionFormData).isMultipleChoice;
        isSelectionRequiredControl.value = data.isSelectionRequired;
        // Unfortunately needed because of how [FormArray.updateValue] is implemented
        // Note: `formArray.value = []` does not remove any controls!
        answerOptionsArray.clear();
        answerOptionsArray.value = data.answerOptions;
      /*for (final option in data.answerOptions) {
          answerOptionsArray.add(FormControl<Choice>(value: option));
        }*/
      case SurveyQuestionType.scale:
        scaleMinValueControl.value = (data as ScaleQuestionFormData).minValue
            .toInt();
        scaleMaxValueControl.value = data.maxValue.toInt();
        scaleMinLabelControl.value = data.minLabel;
        scaleMaxLabelControl.value = data.maxLabel;
        scaleMidValueControls.clear();
        scaleMidValueControls.value = data.midValues
            .map((v) => v?.toInt())
            .toList();
        scaleMidLabelControls.clear();
        scaleMidLabelControls.value = data.midLabels;
        scaleMinColorControl.value = data.minColor != null
            ? SerializableColor(data.minColor!.toARGB32())
            : null;
        scaleMaxColorControl.value = data.maxColor != null
            ? SerializableColor(data.maxColor!.toARGB32())
            : null;
        _updateScaleMidValueControls();
      // TODO scaleInitialValueControl
      // TODO scaleStepSizeControl
      case SurveyQuestionType.freeText:
        freeTextLengthControl.value = RangeValues(
          (data as FreeTextQuestionFormData).textLengthRange.first.toDouble(),
          data.textLengthRange.last.toDouble(),
        );
        freeTextTypeControl.value = data.textType;
        customRegexControl.value = data.textTypeExpression;
      case SurveyQuestionType.fitbit:
        fitbitQuestionTypesControl.forEach((key, value) {
          value.value = (data as FitbitQuestionFormData).types.contains(key);
        });
      case SurveyQuestionType.pain:
        break;
      case SurveyQuestionType.date:
        dateInputTypeControl.value = (data as DateQuestionFormData).inputType;
        dateMinControl.value = data.minDate;
        dateMaxControl.value = data.maxDate;
        dateMinTimeControl.value = data.minTime;
        dateMaxTimeControl.value = data.maxTime;
        dateFormatPresetControl.value = data.dateFormatPreset;
        timeFormatPresetControl.value = data.timeFormatPreset;
        dateDefaultOptionControl.value = data.defaultOption;
        dateDefaultSpecificDateControl.value = data.defaultSpecificDate;
        dateDefaultSpecificTimeControl.value = data.defaultSpecificTime;
    }
  }

  @override
  QuestionFormData buildFormData() {
    switch (questionType) {
      case SurveyQuestionType.bool:
        return BoolQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
        );
      case SurveyQuestionType.choice:
        return ChoiceQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!,
          // required
          questionType: questionTypeControl.value!,
          // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
          isMultipleChoice: isMultipleChoiceControl.value!,
          isSelectionRequired:
              isMultipleChoiceControl.value! &&
              isSelectionRequiredControl.value!,
          // required
          answerOptions: validAnswerOptions,
        );
      case SurveyQuestionType.scale:
        return ScaleQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!,
          // required
          questionType: questionTypeControl.value!,
          // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
          minValue: scaleMinValueControl.value!.toDouble(),
          // non-empty formatter
          maxValue: scaleMaxValueControl.value!.toDouble(),
          // non-empty formatter
          minLabel: scaleMinLabelControl.value,
          maxLabel: scaleMaxLabelControl.value,
          midValues:
              scaleMidValueControls.value?.map((v) => v?.toDouble()).toList() ??
              [],
          midLabels: scaleMidLabelControls.value ?? [],
          minColor: scaleMinColorControl.value,
          maxColor: scaleMaxColorControl.value,
          // TODO scaleInitialValueControl
          // TODO scaleStepSizeControl
        );
      case SurveyQuestionType.freeText:
        return FreeTextQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
          textLengthRange: [
            freeTextLengthControl.value!.start.toInt(),
            freeTextLengthControl.value!.end.toInt(),
          ], // required
          textType: freeTextTypeControl.value!,
          textTypeExpression: customRegexControl.value,
        );
      case SurveyQuestionType.image:
        return ImageQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
        );
      case SurveyQuestionType.audio:
        return AudioQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
          maxRecordingDurationSeconds:
              maxRecordingDurationSecondsControl.value!,
        );
      case SurveyQuestionType.fitbit:
        return FitbitQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
          types: fitbitQuestionTypesControl.entries
              .where((e) => e.value.value!)
              .map((e) => e.key)
              .toList(),
        );
      case SurveyQuestionType.pain:
        return PainQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
        );
      case SurveyQuestionType.date:
        return DateQuestionFormData(
          questionId: questionId,
          questionText: questionTextControl.value!, // required
          questionType: questionTypeControl.value!, // required
          questionInfoText: questionInfoTextControl.value,
          conditional: questionConditionalControl.value,
          inputType: dateInputTypeControl.value ?? DateInputType.date,
          minDate: dateMinControl.value,
          maxDate: dateMaxControl.value,
          minTime: dateMinTimeControl.value,
          maxTime: dateMaxTimeControl.value,
          dateFormatPreset:
              dateFormatPresetControl.value ?? DateFormatPreset.iso,
          timeFormatPreset:
              timeFormatPresetControl.value ?? TimeFormatPreset.h24,
          defaultOption:
              dateDefaultOptionControl.value ?? DefaultDateOption.none,
          defaultSpecificDate: dateDefaultSpecificDateControl.value,
          defaultSpecificTime: dateDefaultSpecificTimeControl.value,
        );
    }
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create:
        _titles?[FormMode.create]?.call() ?? tr.form_question_create,
    FormMode.edit: _titles?[FormMode.edit]?.call() ?? tr.form_question_edit,
    FormMode.readonly:
        _titles?[FormMode.readonly]?.call() ?? tr.form_question_readonly,
  };

  @override
  List<ModelAction> availableActions(AbstractControl model) {
    final isNotReadonly = formMode != FormMode.readonly;

    final actions = [
      ModelAction(
        type: ModelActionType.remove,
        label: ModelActionType.remove.string,
        confirmation: ModelActionConfirmations.remove(
          subject: tr.dialog_subject_answer_option,
        ),
        onExecute: () {
          final controlIdx = answerOptionsArray.controls.indexOf(model);
          answerOptionsArray.removeAt(controlIdx);
        },
        isDestructive: true,
        isAvailable: isNotReadonly,
      ),
    ].where((action) => action.isAvailable).toList();

    return withIcons(actions, modelActionIcons);
  }

  @override
  void onNewItem() {
    answerOptionsArray.add(FormControl<Choice>());
  }

  @override
  void onSelectItem(FormControl<dynamic> item) {
    return; // no-op
  }

  @override
  Future save() {
    // Clear custom regex if not custom type
    if (freeTextTypeControl.value != FreeTextQuestionType.custom) {
      customRegexControl.value = null;
    }
    if (questionType != SurveyQuestionType.fitbit ||
        _fitbitCredentialsFormViewModel == null) {
      return super.save();
    }

    final fitbitCredentialsFormViewModel = _fitbitCredentialsFormViewModel!;
    fitbitCredentialsFormViewModel.revalidate();
    fitbitCredentialsFormViewModel.form.updateValueAndValidity();

    if (!fitbitCredentialsFormViewModel.form.valid) {
      throw FormInvalidException();
    }

    return fitbitCredentialsFormViewModel.save().then((_) => super.save());
  }

  @override
  bool get isDirty {
    // For date questions, we need to handle DateTime serialization
    if (questionType == SurveyQuestionType.date) {
      // Convert form values to JSON-serializable format
      final currentFormValue = _convertFormValueToJsonSerializable(form.value);
      final prevFormValueSerializable = _convertFormValueToJsonSerializable(
        prevFormValue,
      );
      final isEqual =
          jsonEncode(prevFormValueSerializable) == jsonEncode(currentFormValue);
      return !isEqual;
    }
    return super.isDirty;
  }

  /// Converts form values containing DateTime objects to JSON-serializable format
  Map<String, dynamic> _convertFormValueToJsonSerializable(
    Map<String, dynamic>? formValue,
  ) {
    if (formValue == null) return {};

    final result = <String, dynamic>{};
    for (final entry in formValue.entries) {
      final value = entry.value;
      if (value == null) {
        result[entry.key] = null;
      } else if (value is DateTime) {
        result[entry.key] = value.toIso8601String();
      } else if (value is Map) {
        result[entry.key] = _convertFormValueToJsonSerializable(
          Map<String, dynamic>.from(value),
        );
      } else if (value is List) {
        // Handle lists/arrays that might contain DateTime objects
        result[entry.key] = value.map((item) {
          if (item == null) {
            return null;
          } else if (item is DateTime) {
            return item.toIso8601String();
          } else if (item is Map) {
            return _convertFormValueToJsonSerializable(
              Map<String, dynamic>.from(item),
            );
          }
          return item;
        }).toList();
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }

  @override
  QuestionFormViewModel createDuplicate() {
    return QuestionFormViewModel(
      delegate: delegate,
      formData: formData?.copy(),
      validationSet: validationSet,
      titles: _titles,
    );
  }

  bool get isAddOptionButtonVisible =>
      choiceResponseOptionsArray.value != null &&
      choiceResponseOptionsArray.value!.length < customOptionsMax;

  // - IScaleQuestionFormViewModel

  bool get isMidValuesClearedInfoVisible =>
      prevMidValues != scaleMidValueControls.value;

  @override
  set formMode(FormMode mode) {
    super.formMode = mode;

    // Propagate form mode to conditional properties
    conditionalProperties.formMode = mode;
  }
}

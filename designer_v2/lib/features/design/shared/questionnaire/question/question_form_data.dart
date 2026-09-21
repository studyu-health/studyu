import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

typedef SurveyQuestionFormDataFactory = QuestionFormData Function(
  Question question,
  List<EligibilityCriterion> eligibilityCriteria,
);

abstract class QuestionFormData({
  required final QuestionID questionId,
  required final String questionText,
  required final SurveyQuestionType questionType,
  final String? questionInfoText,
  final QuestionConditional? conditional,
}) implements IFormData {
  static Map<SurveyQuestionType, SurveyQuestionFormDataFactory>
  questionTypeFormDataFactories = {
    SurveyQuestionType.scale: (question, eligibilityCriteria) {
      switch (question) {
        // First check for general scale which implements the other interfaces
        case final ScaleQuestion scaleQuestion:
          return ScaleQuestionFormData.fromDomainModel(
            scaleQuestion,
            eligibilityCriteria,
          );
        // Remain backward compatible with specialized scale types
        case final AnnotatedScaleQuestion annotatedScaleQuestion:
          return ScaleQuestionFormData.fromDomainModel(
            ScaleQuestion.fromAnnotatedScaleQuestion(annotatedScaleQuestion),
            eligibilityCriteria,
          );
        case final VisualAnalogueQuestion visualAnalogueQuestion:
          return ScaleQuestionFormData.fromDomainModel(
            ScaleQuestion.fromVisualAnalogueQuestion(visualAnalogueQuestion),
            eligibilityCriteria,
          );
      }
      return ScaleQuestionFormData.fromDomainModel(
        question as ScaleQuestion,
        eligibilityCriteria,
      );
    },
    SurveyQuestionType.bool: (question, eligibilityCriteria) =>
        BoolQuestionFormData.fromDomainModel(
          question as BooleanQuestion,
          eligibilityCriteria,
        ),
    SurveyQuestionType.choice: (question, eligibilityCriteria) =>
        ChoiceQuestionFormData.fromDomainModel(
          question as ChoiceQuestion,
          eligibilityCriteria,
        ),
    SurveyQuestionType.image: (question, eligibilityCriteria) =>
        ImageQuestionFormData.fromDomainModel(
          question as ImageCapturingQuestion,
          eligibilityCriteria,
        ),
    SurveyQuestionType.audio: (question, eligibilityCriteria) =>
        AudioQuestionFormData.fromDomainModel(
          question as AudioRecordingQuestion,
          eligibilityCriteria,
        ),
    SurveyQuestionType.freeText: (question, eligibilityCriteria) =>
        FreeTextQuestionFormData.fromDomainModel(
          question as FreeTextQuestion,
          eligibilityCriteria,
        ),
    SurveyQuestionType.fitbit: (question, eligibilityCriteria) {
      return FitbitQuestionFormData.fromDomainModel(
        question as FitbitQuestion,
        eligibilityCriteria,
      );
    },
    SurveyQuestionType.pain: (question, eligibilityCriteria) =>
        PainQuestionFormData.fromDomainModel(
          question as PainQuestion,
          eligibilityCriteria,
        ),
    SurveyQuestionType.date: (question, eligibilityCriteria) =>
        DateQuestionFormData.fromDomainModel(
          question as DateQuestion,
          eligibilityCriteria,
        ),
  };

  /// Mapping from response option => qualifying/disqualifying
  Map<dynamic, bool> responseOptionsValidity = {};

  List<dynamic> get responseOptions; // subclass responsibility

  @override
  String get id => questionId;

  factory fromDomainModel(
    Question question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final surveyQuestionType = SurveyQuestionType.of(question);
    if (!questionTypeFormDataFactories.containsKey(surveyQuestionType)) {
      throw Exception(
        "Failed to create SurveyQuestionFormData for unknown "
        "SurveyQuestionType: $surveyQuestionType",
      );
    }
    return questionTypeFormDataFactories[surveyQuestionType]!(
      question,
      eligibilityCriteria,
    );
  }

  Question toQuestion(); // subclass responsibility

  EligibilityCriterion? toEligibilityCriterion() {
    if (responseOptions.isEmpty) return null;

    final criterion = EligibilityCriterion.withId();
    // todo implement other expression types
    final expression = ChoiceExpression()..target = questionId;
    // Screener conditions are implemented as disqualifying by default in the
    // app (as of now), so we need to generate conditions for the qualifying
    // response options here
    for (final responseOption in responseOptions) {
      final isQualifying = responseOptionsValidity[responseOption] ?? true;
      if (isQualifying) {
        final answer = constructAnswerFor(responseOption);
        final selectedValue = answer.response;
        if (selectedValue is List) {
          expression.choices.addAll(selectedValue);
        } else {
          expression.choices.add(selectedValue);
        }
      }
    }
    criterion.condition = expression;
    return criterion;
  }

  Answer constructAnswerFor(dynamic responseOption);

  /// Determines the [responseOptionsValidity] in terms of qualify/disqualify
  /// by evaluating the given criteria for each response option on a new
  /// [QuestionnaireState] where the option is selected
  void setResponseOptionsValidityFrom(
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final Map<dynamic, bool> result = {};

    for (final responseOption in responseOptions) {
      final questionnaireState = QuestionnaireState();
      final answer = constructAnswerFor(responseOption);
      questionnaireState.answers[id] = answer;

      // Options are implemented as disqualifying by default in the app
      // (as of now) if no criterion evaluates to true
      bool responseOptionValidity = false;
      for (final criterion in eligibilityCriteria) {
        responseOptionValidity =
            responseOptionValidity ||
            (criterion.condition.evaluate(questionnaireState) ?? false);
      }
      result[responseOption] = responseOptionValidity;
    }

    responseOptionsValidity = result;
  }

  @override
  QuestionFormData copy(); // subclass responsibility
}

class ChoiceQuestionFormData({
  required super.questionId,
  required super.questionText,
  required super.questionType,
  super.questionInfoText,
  super.conditional,
  final bool isMultipleChoice = false,
  final bool isSelectionRequired = false,
  required final List<Choice> answerOptions,
}) extends QuestionFormData {
  @override
  List<Choice> get responseOptions => answerOptions;

  factory fromDomainModel(
    ChoiceQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = ChoiceQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.choice,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
      isMultipleChoice: question.multiple,
      isSelectionRequired: question.selectionRequired,
      answerOptions: question.choices,
      conditional: question.conditional,
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  Question toQuestion() {
    final question = ChoiceQuestion();
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    question.multiple = isMultipleChoice;
    question.selectionRequired = isSelectionRequired;
    question.choices = answerOptions;
    question.conditional = conditional == null
        ? null
        : QuestionConditional<List<String>>.withCondition(
            conditional!.condition,
            defaultValue: conditional?.defaultValue as List<String>?,
          );
    return question;
  }

  @override
  QuestionFormData copy() {
    final data = ChoiceQuestionFormData(
      questionId: const Uuid().v4(),
      // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      isMultipleChoice: isMultipleChoice,
      isSelectionRequired: isSelectionRequired,
      answerOptions: [...answerOptions],
      conditional: conditional?.deepCopy(),
    );
    data.responseOptionsValidity = {...responseOptionsValidity};
    return data;
  }

  @override
  Answer constructAnswerFor(dynamic responseOption) {
    final question = toQuestion() as ChoiceQuestion;
    final choice = responseOption as Choice;
    return question.constructAnswer([choice]);
  }
}

class BoolQuestionFormData({
  required super.questionId,
  required super.questionText,
  required super.questionType,
  super.questionInfoText,
  super.conditional,
}) extends QuestionFormData {
  static Map<String, bool> get kResponseOptions => {
    tr.form_array_response_options_bool_yes: true,
    tr.form_array_response_options_bool_no: false,
  };

  @override
  List<String> get responseOptions => kResponseOptions.keys.toList();

  factory fromDomainModel(
    BooleanQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = BoolQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.bool,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
      conditional: question.conditional,
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  Question toQuestion() {
    final question = BooleanQuestion();
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    question.conditional = conditional == null
        ? null
        : QuestionConditional<bool>.withCondition(
            conditional!.condition,
            defaultValue: conditional?.defaultValue as bool?,
          );
    return question;
  }

  @override
  BoolQuestionFormData copy() {
    final data = BoolQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      conditional: conditional?.deepCopy(),
    );
    data.responseOptionsValidity = {...responseOptionsValidity};
    return data;
  }

  @override
  Answer constructAnswerFor(dynamic responseOption) {
    final question = toQuestion() as BooleanQuestion;
    final value = kResponseOptions[responseOption]!;
    return question.constructAnswer(value);
  }
}

class ImageQuestionFormData({
  required super.questionId,
  required super.questionText,
  required super.questionType,
  super.conditional,
  super.questionInfoText,
}) extends QuestionFormData {
  static Map<String, FutureBlobFile> get kResponseOptions => {
    tr.form_field_response_image: FutureBlobFile("image", "image"),
  };

  @override
  List<String> get responseOptions => kResponseOptions.keys.toList();

  factory fromDomainModel(
    ImageCapturingQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = ImageQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.image,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
      conditional: question.conditional,
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  Question toQuestion() {
    final question = ImageCapturingQuestion();
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    question.conditional = conditional == null
        ? null
        : QuestionConditional<ImageCapturingQuestion>.withCondition(
            conditional!.condition,
            defaultValue: conditional?.defaultValue as ImageCapturingQuestion?,
          );
    return question;
  }

  @override
  ImageQuestionFormData copy() {
    final data = ImageQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      conditional: conditional?.deepCopy(),
    );
    data.responseOptionsValidity = {...responseOptionsValidity};
    return data;
  }

  @override
  Answer constructAnswerFor(dynamic responseOption) {
    final question = toQuestion() as ImageCapturingQuestion;
    final value = kResponseOptions[responseOption]!;
    return question.constructAnswer(value);
  }
}

class AudioQuestionFormData({
  required super.questionId,
  required super.questionText,
  required super.questionType,
  super.questionInfoText,
  super.conditional,
  required final int maxRecordingDurationSeconds,
}) extends QuestionFormData {
  static Map<String, FutureBlobFile> get kResponseOptions => {
    tr.form_field_response_audio: FutureBlobFile("audio", "audio"),
  };

  @override
  List<String> get responseOptions => kResponseOptions.keys.toList();

  factory fromDomainModel(
    AudioRecordingQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = AudioQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.audio,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
      conditional: question.conditional,
      maxRecordingDurationSeconds: question.maxRecordingDurationSeconds,
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  Question toQuestion() {
    final question = AudioRecordingQuestion(
      maxRecordingDurationSeconds: maxRecordingDurationSeconds,
    );
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    question.conditional = conditional == null
        ? null
        : QuestionConditional<AudioRecordingQuestion>.withCondition(
            conditional!.condition,
            defaultValue: conditional?.defaultValue as AudioRecordingQuestion?,
          );
    return question;
  }

  @override
  AudioQuestionFormData copy() {
    final data = AudioQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      conditional: conditional?.deepCopy(),
      maxRecordingDurationSeconds: maxRecordingDurationSeconds,
    );
    data.responseOptionsValidity = {...responseOptionsValidity};
    return data;
  }

  @override
  Answer constructAnswerFor(dynamic responseOption) {
    final question = toQuestion() as AudioRecordingQuestion;
    final value = kResponseOptions[responseOption]!;
    return question.constructAnswer(value);
  }
}

class ScaleQuestionFormData({
  required super.questionId,
  required super.questionText,
  required super.questionType,
  super.questionInfoText,
  super.conditional,
  required final double minValue,
  final String? minLabel,
  required final double maxValue,
  final String? maxLabel,
  required final List<double?> midValues,
  required final List<String?> midLabels,
  final double? initialValue,
  final double stepSize = 0,
  final Color? minColor,
  final Color? maxColor,
}) extends QuestionFormData {
  this
    : assert(
        midValues.length == midLabels.length,
        "midValues.length and midLabels.length must be equal",
      );

  @override
  List<double> get responseOptions => toQuestion().values;

  List<Annotation> get midAnnotations {
    final List<Annotation> midAnnotations = [];
    for (int i = 0; i < midValues.length; i++) {
      final value = midValues[i];
      final label = midLabels[i];
      if (value != null && label != null && label.isNotEmpty) {
        final midAnnotation = Annotation()
          ..value = value.toInt()
          ..annotation = label;
        midAnnotations.add(midAnnotation);
      }
    }
    return midAnnotations;
  }

  factory fromDomainModel(
    ScaleQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = ScaleQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.scale,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
      maxValue: question.maximum,
      minValue: question.minimum,
      minLabel: question.minLabel,
      maxLabel: question.maxLabel,
      midValues: question.midValues,
      midLabels: question.midLabels,
      stepSize: question.step,
      initialValue: question.initial,
      minColor: (question.minColor != null) ? Color(question.minColor!) : null,
      maxColor: (question.maxColor != null) ? Color(question.maxColor!) : null,
      conditional: question.conditional,
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  ScaleQuestion toQuestion() {
    final question = ScaleQuestion()
      ..id = questionId
      ..prompt = questionText
      ..rationale = questionInfoText
      ..minimum = minValue
      ..maximum = maxValue
      ..step = stepSize
      ..initial = initialValue
      ..minColor = minColor?.toARGB32()
      ..maxColor = maxColor?.toARGB32()
      ..midAnnotations = midAnnotations;

    if (minLabel != null) {
      question.minLabel = minLabel;
    }
    if (maxLabel != null) {
      question.maxLabel = maxLabel;
    }
    question.conditional = conditional == null
        ? null
        : QuestionConditional<double>.withCondition(
            conditional!.condition,
            defaultValue: conditional?.defaultValue as double?,
          );
    return question;
  }

  @override
  QuestionFormData copy() {
    final data = ScaleQuestionFormData(
      questionId: const Uuid().v4(),
      // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      minValue: minValue,
      minLabel: minLabel,
      maxValue: maxValue,
      maxLabel: maxLabel,
      stepSize: stepSize,
      initialValue: initialValue,
      minColor: minColor,
      maxColor: maxColor,
      midLabels: midLabels,
      midValues: midValues,
      conditional: conditional?.deepCopy(),
    );
    data.responseOptionsValidity = {...responseOptionsValidity};
    return data;
  }

  @override
  Answer constructAnswerFor(dynamic responseOption) {
    final question = toQuestion();
    return question.constructAnswer(responseOption as double);
  }
}

class FreeTextQuestionFormData({
  required super.questionId,
  required super.questionText,
  required super.questionType,
  super.questionInfoText,
  super.conditional,
  required var List<int> textLengthRange,
  required var FreeTextQuestionType textType,
  required var String? textTypeExpression,
}) extends QuestionFormData {
  @override
  List<String> get responseOptions => [];

  factory fromDomainModel(
    FreeTextQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = FreeTextQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.freeText,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
      textLengthRange: question.lengthRange,
      textType: question.textType,
      textTypeExpression: question.customTypeExpression,
      conditional: question.conditional,
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  Question toQuestion() {
    final question = FreeTextQuestion(
      textType: textType,
      lengthRange: textLengthRange,
      customTypeExpression: textTypeExpression,
    );
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    question.conditional = conditional == null
        ? null
        : QuestionConditional<String>.withCondition(
            conditional!.condition,
            defaultValue: conditional?.defaultValue as String?,
          );
    return question;
  }

  @override
  FreeTextQuestionFormData copy() {
    final data = FreeTextQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      textLengthRange: textLengthRange,
      textType: textType,
      textTypeExpression: textTypeExpression,
      conditional: conditional?.deepCopy(),
    );
    data.responseOptionsValidity = {...responseOptionsValidity};
    return data;
  }

  @override
  Answer constructAnswerFor(dynamic responseOption) {
    final question = toQuestion() as FreeTextQuestion;
    final value = responseOption as String;
    return question.constructAnswer(value);
  }
}

class FitbitQuestionFormData({
  required super.questionId,
  required super.questionText,
  required super.questionType,
  required var List<FitbitQuestionType> types,
  super.conditional,
  super.questionInfoText,
}) extends QuestionFormData {
  @override
  List<String> get responseOptions =>
      FitbitQuestionType.values.map((type) => type.toJson()).toList();

  factory fromDomainModel(
    FitbitQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = FitbitQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.fitbit,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
      types: question.types,
      conditional: question.conditional,
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  Question toQuestion() {
    final question = FitbitQuestion(types: types);
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    question.conditional = conditional == null
        ? null
        : QuestionConditional<FitbitQuestion>.withCondition(
            conditional!.condition,
            defaultValue: conditional?.defaultValue as FitbitQuestion,
          );
    return question;
  }

  @override
  FitbitQuestionFormData copy() {
    final data = FitbitQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      types: types,
      conditional: conditional?.deepCopy(),
    );
    data.responseOptionsValidity = {...responseOptionsValidity};
    return data;
  }

  List<FitbitData> _buildQuestionValue(String value) {
    final fitbitType = FitbitQuestionType.fromJson(value);

    switch (fitbitType) {
      case FitbitQuestionType.heartrate:
        return [FitbitHeartData(0, DateTime.now())];
      case FitbitQuestionType.steps:
        return [FitbitStepData(0, DateTime.now())];
      case FitbitQuestionType.sleep:
        return [FitbitSleepData('deep', DateTime.now(), DateTime.now())];
    }
  }

  @override
  Answer constructAnswerFor(dynamic responseOption) {
    final question = toQuestion() as FitbitQuestion;
    final fitbitData = _buildQuestionValue(responseOption as String);

    return question.constructAnswer(fitbitData);
  }
}

class PainQuestionFormData({
  required super.questionId,
  required super.questionText,
  required super.questionType,
  super.questionInfoText,
  super.conditional,
}) extends QuestionFormData {
  static Map<String, Body> get kResponseOptions => {
    tr.form_field_response_pain: const Body(),
  };

  @override
  List<String> get responseOptions => kResponseOptions.keys.toList();

  factory fromDomainModel(
    PainQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = PainQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.pain,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
      conditional: question.conditional,
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  Question toQuestion() {
    final question = PainQuestion();
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    question.conditional = conditional == null
        ? null
        : QuestionConditional<List<BodyPart>>.withCondition(
            conditional!.condition,
            defaultValue: conditional?.defaultValue as List<BodyPart>?,
          );
    return question;
  }

  @override
  PainQuestionFormData copy() {
    final data = PainQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      conditional: conditional?.deepCopy(),
    );
    data.responseOptionsValidity = {...responseOptionsValidity};
    return data;
  }

  @override
  Answer constructAnswerFor(dynamic responseOption) {
    final question = toQuestion() as PainQuestion;
    final value = kResponseOptions[responseOption];
    return question.constructAnswer(value!);
  }
}

class DateQuestionFormData({
  required super.questionId,
  required super.questionText,
  required super.questionType,
  super.questionInfoText,
  super.conditional,
  final DateInputType inputType = DateInputType.date,
  final DateTime? minDate,
  final DateTime? maxDate,
  final String? minTime,
  final String? maxTime,
  final DefaultDateOption defaultOption = DefaultDateOption.none,
  final DateTime? defaultSpecificDate,
  final String? defaultSpecificTime,
}) extends QuestionFormData {
  @override
  List<String> get responseOptions => []; // Date questions don't have fixed response options

  factory fromDomainModel(
    DateQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = DateQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.date,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
      inputType: question.inputType,
      minDate: question.minDate,
      maxDate: question.maxDate,
      minTime: question.minTime,
      maxTime: question.maxTime,
      defaultOption: question.defaultOption,
      defaultSpecificDate: question.defaultSpecificDate,
      defaultSpecificTime: question.defaultSpecificTime,
      conditional: question.conditional,
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  Question toQuestion() {
    final question = DateQuestion(
      inputType: inputType,
      minDate: minDate,
      maxDate: maxDate,
      minTime: minTime,
      maxTime: maxTime,
      defaultOption: defaultOption,
      defaultSpecificDate: defaultSpecificDate,
      defaultSpecificTime: defaultSpecificTime,
    );
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    question.conditional = conditional == null
        ? null
        : QuestionConditional<DateTime>.withCondition(
            conditional!.condition,
            defaultValue: conditional?.defaultValue as DateTime?,
          );
    return question;
  }

  @override
  DateQuestionFormData copy() {
    final data = DateQuestionFormData(
      questionId: const Uuid().v4(),
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      inputType: inputType,
      minDate: minDate,
      maxDate: maxDate,
      minTime: minTime,
      maxTime: maxTime,
      defaultOption: defaultOption,
      defaultSpecificDate: defaultSpecificDate,
      defaultSpecificTime: defaultSpecificTime,
      conditional: conditional?.deepCopy(),
    );
    data.responseOptionsValidity = responseOptionsValidity;
    return data;
  }

  @override
  Answer constructAnswerFor(dynamic responseOption) {
    final question = toQuestion() as DateQuestion;
    // For date questions, eligibility criteria aren't typically used
    // Return a default date for validation purposes
    return question.constructAnswer(DateTime.now());
  }

  /// Converts the date question form data to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'questionType': questionType.name,
      'questionInfoText': questionInfoText,
      'inputType': inputType.name,
      'minDate': minDate?.toIso8601String(),
      'maxDate': maxDate?.toIso8601String(),
      'minTime': minTime,
      'maxTime': maxTime,
      'defaultOption': defaultOption.name,
      'defaultSpecificDate': defaultSpecificDate?.toIso8601String(),
      'defaultSpecificTime': defaultSpecificTime,
      'conditional': conditional?.toString(),
      'responseOptions': responseOptions,
    };
  }
}

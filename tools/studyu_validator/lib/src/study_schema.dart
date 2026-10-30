// Authored Study JSON Schema. Keep serializer compatibility observable in tests.

import 'dart:convert';

// ---------------------------------------------------------------------------
// Schema building blocks
// ---------------------------------------------------------------------------

typedef Schema = Map<String, dynamic>;

Schema _ref(String defName) => {r'$ref': '#/definitions/$defName'};

Schema _type(String type) => {'type': type};

Schema _dateTime() => {'type': 'string', 'format': 'date-time'};

Schema _enumValues(List<String> values) => {'type': 'string', 'enum': values};

Schema _listOf(Schema items) => {'type': 'array', 'items': items};

/// A nullable field schema — Draft 7 allows null via `type` arrays:
/// `{"type": ["string", "null"]}`. Because the schema sets
/// `additionalProperties: false` everywhere, optional fields are simply
/// absent from `required`.
Schema _nullable(Schema inner) {
  final type = inner['type'];
  // For enum schemas, use anyOf to allow null alongside enum values.
  if (inner.containsKey('enum')) {
    return {
      'anyOf': [
        inner,
        {'type': 'null'},
      ],
    };
  }
  if (type is String) {
    return {
      ...inner,
      'type': [type, 'null'],
    };
  }
  if (type is List) {
    return {
      ...inner,
      'type': [...type, 'null'],
    };
  }
  // For $ref-based schemas, use anyOf to allow null without duplicating $ref.
  final ref = inner[r'$ref'];
  if (ref is String) {
    return {
      'anyOf': [
        {r'$ref': ref},
        {'type': 'null'},
      ],
    };
  }
  // Fallback: wrap with anyOf.
  return {
    'anyOf': [
      inner,
      {'type': 'null'},
    ],
  };
}

// ---------------------------------------------------------------------------
// Enum maps (from `const _$*EnumMap` in .g.dart)
// ---------------------------------------------------------------------------

const participationEnum = ['open', 'invite'];
const resultSharingEnum = ['public', 'private', 'organization'];
const studyStatusEnum = ['draft', 'running', 'closed'];
const phaseSequenceEnum = [
  'alternating',
  'counterBalanced',
  'randomized',
  'customized',
];
const logicTypeEnum = ['and', 'or'];
const numericComparatorEnum = ['=', '!=', '>', '<', '>=', '<='];
const textComparatorEnum = ['=', '!=', 'contains', 'does_not_contain'];
const dateInputTypeEnum = ['date', 'time', 'dateTime'];
const dateFormatPresetEnum = ['iso', 'european', 'us', 'german'];
const timeFormatPresetEnum = ['h24', 'h12'];
const defaultDateOptionEnum = ['none', 'today', 'now', 'specific'];
const fitbitQuestionTypeEnum = ['heartrate', 'sleep', 'steps'];
const freeTextQuestionTypeEnum = ['any', 'alphanumeric', 'numeric', 'custom'];
const temporalAggregationEnum = ['day', 'phase', 'intervention'];
const improvementDirectionEnum = ['positive', 'negative'];
const gitProviderEnum = ['gitlab'];

// ---------------------------------------------------------------------------
// Discriminator constants (from source .dart files)
// ---------------------------------------------------------------------------

const questionTypeEnum = [
  'boolean',
  'choice',
  'scale',
  'annotatedScale',
  'visualAnalogue',
  'ImageCapturingQuestion',
  'AudioRecordingQuestion',
  'date',
  'freeText',
  'FitbitQuestion',
  'pain',
];

// ---------------------------------------------------------------------------
// Definition builders
// ---------------------------------------------------------------------------

/// Common question base fields shared by all question subtypes.
Map<String, Schema> _questionBaseProperties() {
  return {
    'id': {'type': 'string'},
    'prompt': _nullable(_type('string')),
    'rationale': _nullable(_type('string')),
    'conditional': _nullable(_ref('QuestionConditional')),
  };
}

List<String> _questionBaseRequired() => ['id'];

void _addDefinitions(Map<String, Schema> definitions) {
  // ---- Study top-level -------------------------------------------------
  definitions['Study'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'id': {'type': 'string'},
      'title': _nullable(_type('string')),
      'description': _nullable(_type('string')),
      'user_id': {'type': 'string'},
      'participation': _enumValues(participationEnum),
      'result_sharing': _enumValues(resultSharingEnum),
      'contact': _ref('Contact'),
      'icon_name': {'type': 'string', 'default': 'accountHeart'},
      'published': {'type': 'boolean', 'default': false},
      'status': _enumValues(studyStatusEnum),
      'questionnaire': _listOf(_ref('Question')),
      'eligibility_criteria': _listOf(_ref('EligibilityCriterion')),
      'consent': _listOf(_ref('ConsentItem')),
      'interventions': _listOf(_ref('Intervention')),
      'observations': _listOf(_ref('Observation')),
      'schedule': _ref('StudySchedule'),
      'report_specification': _ref('ReportSpecification'),
      'results': _listOf(_ref('StudyResult')),
      'collaborator_emails': _listOf(_type('string')),
      'registry_published': {'type': 'boolean', 'default': false},
      // ---- runtime/join fields from Study.fromJson ----
      'study_fitbit_credentials': _nullable(_ref('StudyFitbitCredentials')),
      'repo': _nullable(_listOf(_ref('Repo'))),
      'study_invite': _nullable(_listOf(_ref('StudyInvite'))),
      'study_subject': _nullable(_listOf(_ref('StudySubject'))),
      'study_progress': _nullable(_listOf(_ref('SubjectProgress'))),
      'study_progress_export': _nullable(_listOf(_ref('SubjectProgress'))),
      'subject_progress': _nullable(_listOf(_ref('SubjectProgress'))),
      'study_participant_count': _nullable(_type('integer')),
      'study_ended_count': _nullable(_type('integer')),
      'active_subject_count': _nullable(_type('integer')),
      'study_missed_days': _nullable(_listOf(_type('integer'))),
      'created_at': _nullable(_dateTime()),
    },
    'required': ['id', 'user_id', 'participation', 'result_sharing', 'status'],
  };

  // ---- Contact --------------------------------------------------------
  definitions['Contact'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'organization': {'type': 'string'},
      'institutionalReviewBoard': _nullable(_type('string')),
      'institutionalReviewBoardNumber': _nullable(_type('string')),
      'researchers': _nullable(_type('string')),
      'email': {'type': 'string'},
      'website': {'type': 'string'},
      'phone': {'type': 'string'},
      'additionalInfo': _nullable(_type('string')),
    },
    'required': ['organization', 'email', 'website', 'phone'],
  };

  // ---- ConsentItem ----------------------------------------------------
  definitions['ConsentItem'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'id': {'type': 'string'},
      'title': _nullable(_type('string')),
      'description': _nullable(_type('string')),
      'iconName': {'type': 'string'},
    },
    'required': ['id', 'iconName'],
  };

  // ---- EligibilityCriterion -------------------------------------------
  definitions['EligibilityCriterion'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'id': {'type': 'string'},
      'reason': _nullable(_type('string')),
      'condition': _ref('Expression'),
    },
    'required': ['id', 'condition'],
  };

  // ---- Intervention ----------------------------------------------------
  definitions['Intervention'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'id': {'type': 'string'},
      'name': _nullable(_type('string')),
      'description': _nullable(_type('string')),
      'icon': {'type': 'string'},
      'tasks': _listOf(_ref('InterventionTask')),
    },
    'required': ['id', 'icon', 'tasks'],
  };

  // ---- InterventionTask (polymorphic) ---------------------------------
  definitions['InterventionTask'] = {
    'oneOf': [_checkmarkTaskSchema(definitions)],
  };

  // ---- CheckmarkTask ---------------------------------------------------
  definitions['CheckmarkTask'] = _checkmarkTaskSchema(definitions);

  // ---- Observation (polymorphic) -------------------------------------
  definitions['Observation'] = {
    'oneOf': [_questionnaireTaskSchema(definitions)],
  };

  // ---- QuestionnaireTask ----------------------------------------------
  definitions['QuestionnaireTask'] = _questionnaireTaskSchema(definitions);

  // ---- Schedule -------------------------------------------------------
  definitions['Schedule'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'completionPeriods': _listOf(_ref('CompletionPeriod')),
      'reminders': _listOf(_type('string')),
    },
    'required': ['completionPeriods', 'reminders'],
  };

  // ---- CompletionPeriod -----------------------------------------------
  definitions['CompletionPeriod'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'id': {'type': 'string'},
      'unlockTime': {'type': 'string'},
      'lockTime': {'type': 'string'},
    },
    'required': ['id', 'unlockTime', 'lockTime'],
  };

  // ---- StudySchedule --------------------------------------------------
  definitions['StudySchedule'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'numberOfCycles': {'type': 'integer'},
      'phaseDuration': {'type': 'integer'},
      'includeBaseline': {'type': 'boolean'},
      'sequence': _enumValues(phaseSequenceEnum),
      'sequenceCustom': {'type': 'string', 'default': 'ABAB'},
    },
    'required': [
      'numberOfCycles',
      'phaseDuration',
      'includeBaseline',
      'sequence',
    ],
  };

  // ---- ReportSpecification --------------------------------------------
  definitions['ReportSpecification'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'primary': _nullable(_ref('ReportSection')),
      'secondary': _listOf(_ref('ReportSection')),
    },
    'required': ['secondary'],
  };

  // ---- ReportSection (polymorphic) ------------------------------------
  definitions['ReportSection'] = {
    'oneOf': [
      _averageSectionSchema(),
      _linearRegressionSectionSchema(),
      _textualSummarySectionSchema(),
      _gaugeComparisonSectionSchema(),
      _descriptiveStatsSectionSchema(),
    ],
  };

  definitions['AverageSection'] = _averageSectionSchema();
  definitions['DescriptiveStatsSection'] = _descriptiveStatsSectionSchema();
  definitions['GaugeComparisonSection'] = _gaugeComparisonSectionSchema();
  definitions['LinearRegressionSection'] = _linearRegressionSectionSchema();
  definitions['TextualSummarySection'] = _textualSummarySectionSchema();

  // ---- StudyResult (polymorphic) --------------------------------------
  definitions['StudyResult'] = {
    'oneOf': [_interventionResultSchema(), _numericResultSchema()],
  };

  definitions['InterventionResult'] = _interventionResultSchema();
  definitions['NumericResult'] = _numericResultSchema();

  // ---- DataReference --------------------------------------------------
  definitions['DataReference'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'task': {'type': 'string'},
      'property': {'type': 'string'},
    },
    'required': ['task', 'property'],
  };

  // ---- StudyFitbitCredentials -----------------------------------------
  definitions['StudyFitbitCredentials'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'study_id': {'type': 'string'},
      'fitbit_credentials': _ref('FitbitAuthCredentials'),
    },
    'required': ['study_id', 'fitbit_credentials'],
  };

  definitions['FitbitAuthCredentials'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'clientId': {'type': 'string'},
      'clientSecret': {'type': 'string'},
    },
    'required': ['clientId', 'clientSecret'],
  };

  // ---- Repo ------------------------------------------------------------
  definitions['Repo'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'project_id': {'type': 'string'},
      'user_id': {'type': 'string'},
      'study_id': {'type': 'string'},
      'provider': _enumValues(gitProviderEnum),
      'web_url': _nullable(_type('string')),
      'git_url': _nullable(_type('string')),
    },
    'required': ['project_id', 'user_id', 'study_id', 'provider'],
  };

  // ---- StudyInvite ----------------------------------------------------
  definitions['StudyInvite'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'code': {'type': 'string'},
      'study_id': {'type': 'string'},
      'preselected_intervention_ids': _nullable(_listOf(_type('string'))),
    },
    'required': ['code', 'study_id'],
  };

  // ---- StudySubject ---------------------------------------------------
  definitions['StudySubject'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'id': {'type': 'string'},
      'study_id': {'type': 'string'},
      'user_id': {'type': 'string'},
      'started_at': _nullable(_dateTime()),
      'selected_intervention_ids': _listOf(_type('string')),
      'invite_code': _nullable(_type('string')),
      'is_deleted': {'type': 'boolean'},
    },
    'required': [
      'id',
      'study_id',
      'user_id',
      'selected_intervention_ids',
      'is_deleted',
    ],
  };

  // ---- SubjectProgress ------------------------------------------------
  definitions['SubjectProgress'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'subject_id': {'type': 'string'},
      'intervention_id': {'type': 'string'},
      'task_id': {'type': 'string'},
      'result_type': {'type': 'string'},
      'result': _ref('Result'),
      'completed_at': _nullable(_dateTime()),
      'started_at': _nullable(_dateTime()),
    },
    'required': [
      'subject_id',
      'intervention_id',
      'task_id',
      'result_type',
      'result',
    ],
  };

  // ---- Result ---------------------------------------------------------
  definitions['Result'] = {
    'oneOf': [
      _discriminated(
        constValue: 'QuestionnaireState',
        properties: {
          'periodId': _nullable(_type('string')),
          'result': _listOf(_type('object')),
        },
        required: ['result'],
      ),
      _discriminated(
        constValue: 'bool',
        properties: {
          'periodId': _nullable(_type('string')),
          'result': _type('boolean'),
        },
        required: ['result'],
      ),
    ],
  };

  // ---- QuestionConditional --------------------------------------------
  definitions['QuestionConditional'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {'condition': _ref('CompositeExpression')},
    'required': ['condition'],
  };

  // ---- Expression (polymorphic) --------------------------------------
  definitions['Expression'] = {
    'oneOf': [
      _booleanExpressionSchema(),
      _choiceExpressionSchema(),
      _notExpressionSchema(),
      _numericExpressionSchema(),
      _textExpressionSchema(),
    ],
  };

  definitions['BooleanExpression'] = _booleanExpressionSchema();
  definitions['ChoiceExpression'] = _choiceExpressionSchema();
  definitions['NotExpression'] = _notExpressionSchema();
  definitions['NumericExpression'] = _numericExpressionSchema();
  definitions['TextExpression'] = _textExpressionSchema();
  definitions['CompositeExpression'] = _compositeExpressionSchema();

  // ---- Question (polymorphic) ----------------------------------------
  final questionOneOf = <Schema>[];
  for (final qType in questionTypeEnum) {
    questionOneOf.add(_questionVariantSchema(qType));
  }
  definitions['Question'] = {'oneOf': questionOneOf};

  // ---- Annotation (used by scale questions) ---------------------------
  definitions['Annotation'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'value': {'type': 'integer'},
      'annotation': {'type': 'string'},
    },
    'required': ['value', 'annotation'],
  };

  // ---- Choice (used by ChoiceQuestion) -------------------------------
  definitions['Choice'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'id': {'type': 'string'},
      'text': {'type': 'string'},
    },
    'required': ['id', 'text'],
  };

  // ---- PainType -------------------------------------------------------
  definitions['PainType'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'name': {'type': 'string'},
    },
    'required': ['name'],
  };

  // ---- BodyPain --------------------------------------------------------
  definitions['BodyPain'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'painLevel': {'type': 'integer', 'default': 0},
      'type': _nullable(_ref('PainType')),
    },
    'required': ['painLevel'],
  };

  // ---- BodyPart -------------------------------------------------------
  definitions['BodyPart'] = {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'id': {'type': 'string'},
      'name': {'type': 'string'},
      'pain': _ref('BodyPain'),
      'children': _listOf(_ref('BodyPart')),
    },
    'required': ['id', 'name', 'pain', 'children'],
  };
}

// ---------------------------------------------------------------------------
// Polymorphic variant schemas (oneOf members)
// ---------------------------------------------------------------------------

Schema _discriminated({
  required String constValue,
  required Map<String, Schema> properties,
  required List<String> required,
}) {
  return {
    'type': 'object',
    'additionalProperties': false,
    'properties': {
      'type': {'type': 'string', 'const': constValue},
      ...properties,
    },
    'required': ['type', ...required],
  };
}

Schema _checkmarkTaskSchema(Map<String, Schema> definitions) {
  return _discriminated(
    constValue: 'checkmark',
    properties: {
      'id': {'type': 'string'},
      'title': _nullable(_type('string')),
      'header': _nullable(_type('string')),
      'footer': _nullable(_type('string')),
      'schedule': _ref('Schedule'),
    },
    required: ['id', 'schedule'],
  );
}

Schema _questionnaireTaskSchema(Map<String, Schema> definitions) {
  return _discriminated(
    constValue: 'questionnaire',
    properties: {
      'id': {'type': 'string'},
      'title': _nullable(_type('string')),
      'header': _nullable(_type('string')),
      'footer': _nullable(_type('string')),
      'schedule': _ref('Schedule'),
      'questions': _listOf(_ref('Question')),
    },
    required: ['id', 'schedule', 'questions'],
  );
}

Schema _averageSectionSchema() {
  return _discriminated(
    constValue: 'average',
    properties: {
      'id': {'type': 'string'},
      'title': _nullable(_type('string')),
      'description': _nullable(_type('string')),
      'aggregate': _nullable(_enumValues(temporalAggregationEnum)),
      'resultProperty': _nullable(_ref('DataReference')),
    },
    required: ['id'],
  );
}

Schema _descriptiveStatsSectionSchema() {
  return _discriminated(
    constValue: 'descriptive_stats',
    properties: {
      'id': {'type': 'string'},
      'title': _nullable(_type('string')),
      'description': _nullable(_type('string')),
      'resultProperty': _nullable(_ref('DataReference')),
    },
    required: ['id'],
  );
}

Schema _gaugeComparisonSectionSchema() {
  return _discriminated(
    constValue: 'gauge_comparison',
    properties: {
      'id': {'type': 'string'},
      'title': _nullable(_type('string')),
      'description': _nullable(_type('string')),
      'resultProperty': _nullable(_ref('DataReference')),
    },
    required: ['id'],
  );
}

Schema _linearRegressionSectionSchema() {
  return _discriminated(
    constValue: 'linearRegression',
    properties: {
      'id': {'type': 'string'},
      'title': _nullable(_type('string')),
      'description': _nullable(_type('string')),
      'resultProperty': _nullable(_ref('DataReference')),
      'alpha': {'type': 'number'},
      'improvement': _nullable(_enumValues(improvementDirectionEnum)),
    },
    required: ['id', 'alpha'],
  );
}

Schema _textualSummarySectionSchema() {
  return _discriminated(
    constValue: 'textual_summary',
    properties: {
      'id': {'type': 'string'},
      'title': _nullable(_type('string')),
      'description': _nullable(_type('string')),
      'resultProperty': _nullable(_ref('DataReference')),
    },
    required: ['id'],
  );
}

Schema _interventionResultSchema() {
  return _discriminated(
    constValue: 'intervention',
    properties: {
      'id': {'type': 'string'},
      'filename': {'type': 'string'},
    },
    required: ['id', 'filename'],
  );
}

Schema _numericResultSchema() {
  return _discriminated(
    constValue: 'numeric',
    properties: {
      'id': {'type': 'string'},
      'filename': {'type': 'string'},
      'resultProperty': _ref('DataReference'),
    },
    required: ['id', 'filename', 'resultProperty'],
  );
}

Schema _booleanExpressionSchema() {
  return _discriminated(
    constValue: 'boolean',
    properties: {'target': _nullable(_type('string'))},
    required: [],
  );
}

Schema _choiceExpressionSchema() {
  return _discriminated(
    constValue: 'choice',
    properties: {
      'target': _nullable(_type('string')),
      'choices': _listOf({'type': 'string'}),
    },
    required: ['choices'],
  );
}

Schema _notExpressionSchema() {
  return _discriminated(
    constValue: 'not',
    properties: {'expression': _ref('Expression')},
    required: ['expression'],
  );
}

Schema _numericExpressionSchema() {
  return _discriminated(
    constValue: 'numeric',
    properties: {
      'target': _nullable(_type('string')),
      'comparator': _enumValues(numericComparatorEnum),
      'value': {'type': 'number'},
    },
    required: ['comparator', 'value'],
  );
}

Schema _textExpressionSchema() {
  return _discriminated(
    constValue: 'text',
    properties: {
      'target': _nullable(_type('string')),
      'comparator': _enumValues(textComparatorEnum),
      'value': {'type': 'string'},
    },
    required: ['comparator', 'value'],
  );
}

Schema _compositeExpressionSchema() {
  return _discriminated(
    constValue: 'composite',
    properties: {
      'logicType': _enumValues(logicTypeEnum),
      'expressions': _listOf(_ref('Expression')),
    },
    required: ['logicType', 'expressions'],
  );
}

/// Builds the oneOf variant schema for a given question type const.
Schema _questionVariantSchema(String questionTypeConst) {
  switch (questionTypeConst) {
    case 'boolean':
      return _discriminated(
        constValue: questionTypeConst,
        properties: _questionBaseProperties(),
        required: _questionBaseRequired(),
      );
    case 'choice':
      return _discriminated(
        constValue: questionTypeConst,
        properties: {
          ..._questionBaseProperties(),
          'multiple': {'type': 'boolean'},
          'choices': _listOf(_ref('Choice')),
        },
        required: [..._questionBaseRequired(), 'multiple', 'choices'],
      );
    case 'scale':
      return _discriminated(
        constValue: questionTypeConst,
        properties: {
          ..._questionBaseProperties(),
          'minimum': {'type': 'number'},
          'maximum': {'type': 'number'},
          'initial': {'type': 'number'},
          'annotations': _listOf(_ref('Annotation')),
          'min_color': _nullable(_type('integer')),
          'max_color': _nullable(_type('integer')),
          'step': {'type': 'number'},
        },
        required: [
          ..._questionBaseRequired(),
          'minimum',
          'maximum',
          'initial',
          'annotations',
          'step',
        ],
      );
    case 'annotatedScale':
      return _discriminated(
        constValue: questionTypeConst,
        properties: {
          ..._questionBaseProperties(),
          'minimum': {'type': 'number'},
          'maximum': {'type': 'number'},
          'step': {'type': 'number'},
          'initial': {'type': 'number'},
          'annotations': _listOf(_ref('Annotation')),
        },
        required: [
          ..._questionBaseRequired(),
          'minimum',
          'maximum',
          'step',
          'initial',
          'annotations',
        ],
      );
    case 'visualAnalogue':
      return _discriminated(
        constValue: questionTypeConst,
        properties: {
          ..._questionBaseProperties(),
          'minimum': {'type': 'number'},
          'maximum': {'type': 'number'},
          'step': {'type': 'number'},
          'initial': {'type': 'number'},
          'minimumColor': {'type': 'integer'},
          'maximumColor': {'type': 'integer'},
          'minimumAnnotation': {'type': 'string'},
          'maximumAnnotation': {'type': 'string'},
        },
        required: [
          ..._questionBaseRequired(),
          'minimum',
          'maximum',
          'step',
          'initial',
          'minimumColor',
          'maximumColor',
          'minimumAnnotation',
          'maximumAnnotation',
        ],
      );
    case 'ImageCapturingQuestion':
      return _discriminated(
        constValue: questionTypeConst,
        properties: _questionBaseProperties(),
        required: _questionBaseRequired(),
      );
    case 'AudioRecordingQuestion':
      return _discriminated(
        constValue: questionTypeConst,
        properties: {
          ..._questionBaseProperties(),
          'maxRecordingDurationSeconds': {'type': 'integer'},
        },
        required: [..._questionBaseRequired(), 'maxRecordingDurationSeconds'],
      );
    case 'date':
      return _discriminated(
        constValue: questionTypeConst,
        properties: {
          ..._questionBaseProperties(),
          'inputType': _enumValues(dateInputTypeEnum),
          'minDate': _nullable(_dateTime()),
          'maxDate': _nullable(_dateTime()),
          'minTime': _nullable(_type('string')),
          'maxTime': _nullable(_type('string')),
          'dateFormatPreset': _enumValues(dateFormatPresetEnum),
          'timeFormatPreset': _enumValues(timeFormatPresetEnum),
          'defaultOption': _enumValues(defaultDateOptionEnum),
          'defaultSpecificDate': _nullable(_dateTime()),
          'defaultSpecificTime': _nullable(_type('string')),
        },
        required: [
          ..._questionBaseRequired(),
          'inputType',
          'dateFormatPreset',
          'timeFormatPreset',
          'defaultOption',
        ],
      );
    case 'freeText':
      return _discriminated(
        constValue: questionTypeConst,
        properties: {
          ..._questionBaseProperties(),
          'lengthRange': _listOf(_type('integer')),
          'textType': _enumValues(freeTextQuestionTypeEnum),
          'customTypeExpression': _nullable(_type('string')),
        },
        required: [..._questionBaseRequired(), 'lengthRange', 'textType'],
      );
    case 'FitbitQuestion':
      return _discriminated(
        constValue: questionTypeConst,
        properties: {
          ..._questionBaseProperties(),
          'types': _listOf(_enumValues(fitbitQuestionTypeEnum)),
        },
        required: [..._questionBaseRequired(), 'types'],
      );
    case 'pain':
      return _discriminated(
        constValue: questionTypeConst,
        properties: _questionBaseProperties(),
        required: _questionBaseRequired(),
      );
    default:
      throw ArgumentError('Unknown question type: $questionTypeConst');
  }
}

/// The authored Study JSON Schema used by the standalone validator.
Map<String, dynamic> buildStudySchema() {
  final definitions = <String, Schema>{};
  _addDefinitions(definitions);

  return <String, dynamic>{
    r'$schema': 'http://json-schema.org/draft-07/schema#',
    r'$id': 'https://studyu.health/schemas/study.schema.json',
    'title': 'Study',
    'type': 'object',
    'additionalProperties': false,
    'definitions': definitions,
    'properties': definitions['Study']!['properties'] as Map<String, dynamic>,
    'required': definitions['Study']!['required'] as List<String>,
  };
}

String studySchemaText() =>
    const JsonEncoder.withIndent('  ').convert(buildStudySchema());

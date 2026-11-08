import 'dart:convert';

import 'package:json_schema/json_schema.dart' hide ValidationError;
import 'package:studyu_core/core.dart';
import 'package:studyu_validator/src/study_schema.dart';

JsonSchema? _compiledSchema;

/// Parses Study JSON, validates its schema, then runs the typed core validators.
Map<String, dynamic> validateJson(
  String json, {
  String level = 'draft',
  String? section,
  bool schemaOnly = false,
}) {
  final data = _decodeObject(json);
  if (data case {'result': final Map<String, dynamic> result}) return result;

  final studyJson = data['data']! as Map<String, dynamic>;
  final schemaResult = _validateAgainstSchema(studyJson);
  if (!schemaResult.valid || schemaOnly) return schemaResult.toJson();

  final Study study;
  try {
    study = Study.fromJson(studyJson);
  } catch (error) {
    return _errorResult(
      code: 'DESERIALIZE_ERROR',
      message: 'Failed to deserialize Study: $error',
      fixHint: 'Ensure all required fields are present.',
    );
  }

  final validationLevel = switch (level) {
    'draft' => ValidationLevel.draft,
    'publish' => ValidationLevel.publish,
    _ => throw ArgumentError.value(level, 'level', 'must be draft or publish'),
  };

  final result = switch (section) {
    null => validateStudy(study, validationLevel),
    'study_info' => validateStudyInfo(study, validationLevel),
    'interventions' => validateInterventions(study, validationLevel),
    'questionnaire' => validateQuestionnaire(
      study.questionnaire,
      r'$.questionnaire',
      validationLevel,
    ),
    'schedule' => validateSchedule(study, validationLevel),
    'consent' => validateConsent(study, validationLevel),
    'observations' => validateObservations(study, validationLevel),
    'report' => validateReport(study, validationLevel),
    'eligibility' => validateEligibilityConsent(study, validationLevel),
    _ => throw ArgumentError.value(section, 'section', 'unknown section'),
  };
  return result.toJson();
}

/// Returns the standalone validator's authored JSON Schema.
String loadStudySchemaText() => studySchemaText();

/// Round-trips Study JSON through the core serializer.
String normalizeJson(String json) {
  final data = jsonDecode(json) as Map<String, dynamic>;
  return const JsonEncoder.withIndent(
    '  ',
  ).convert(Study.fromJson(data).toJson());
}

Map<String, dynamic> _decodeObject(String json) {
  try {
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The JSON root must be an object.');
    }
    return {'data': decoded};
  } catch (error) {
    return {
      'result': _errorResult(
        code: 'PARSE_ERROR',
        message: 'Invalid JSON: $error',
        fixHint: 'Provide a JSON object.',
      ),
    };
  }
}

ValidationResult _validateAgainstSchema(Map<String, dynamic> data) {
  final schema = _compiledSchema ??= JsonSchema.create(buildStudySchema());
  final result = schema.validate(data);
  if (result.isValid) return ValidationResult.empty();

  return ValidationResult(
    errors: result.errors
        .map(
          (error) => ValidationError(
            code: 'SCHEMA_ERROR',
            path: _instancePathToJsonPath(error.instancePath),
            message: error.message,
            fixHint: 'Update the JSON to satisfy the Study JSON Schema.',
          ),
        )
        .toList(),
    warnings: const [],
  );
}

Map<String, dynamic> _errorResult({
  required String code,
  required String message,
  required String fixHint,
}) => ValidationResult(
  errors: [
    ValidationError(code: code, path: r'$', message: message, fixHint: fixHint),
  ],
  warnings: const [],
).toJson();

String _instancePathToJsonPath(String instancePath) {
  if (instancePath.isEmpty) return r'$';
  final buffer = StringBuffer(r'$');
  for (final part in instancePath.split('/').skip(1)) {
    final decoded = part.replaceAll('~1', '/').replaceAll('~0', '~');
    if (int.tryParse(decoded) != null) {
      buffer.write('[$decoded]');
    } else if (RegExp(r'^[A-Za-z_$][A-Za-z0-9_$]*$').hasMatch(decoded)) {
      buffer.write('.$decoded');
    } else {
      buffer.write("['$decoded']");
    }
  }
  return buffer.toString();
}

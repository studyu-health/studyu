import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

// Contact requires organization, email, website, phone fields.
const validStudyJson = '''
{
  "id": "test-id",
  "user_id": "user-id",
  "title": "CLI Test Study",
  "status": "draft",
  "participation": "invite",
  "result_sharing": "private",
  "contact": {"organization": "Test Org", "email": "test@example.com", "website": "", "phone": ""},
  "icon_name": "accountHeart",
  "published": false,
  "questionnaire": [],
  "eligibility_criteria": [],
  "consent": [],
  "interventions": [],
  "observations": [],
  "schedule": {"phaseDuration": 7, "numberOfCycles": 2, "includeBaseline": false, "sequence": "alternating", "sequenceCustom": "ABAB"},
  "report_specification": {"secondary": []},
  "results": []
}
''';

const invalidStudyJson = '''
{
  "id": "test-id",
  "user_id": "user-id",
  "title": null,
  "status": "draft",
  "participation": "invite",
  "result_sharing": "private",
  "contact": {"organization": "Test Org", "email": "test@example.com", "website": "", "phone": ""},
  "icon_name": "",
  "published": false,
  "questionnaire": [],
  "eligibility_criteria": [],
  "consent": [],
  "interventions": [],
  "observations": [],
  "schedule": {"phaseDuration": 7, "numberOfCycles": 2, "includeBaseline": false, "sequence": "alternating", "sequenceCustom": "ABAB"},
  "report_specification": {"secondary": []},
  "results": []
}
''';

// Schema-invalid: unexpected root key. The JSON is otherwise valid study data,
// but the extra "unexpected" key violates additionalProperties: false.
const schemaInvalidJson = '''
{
  "id": "test-id",
  "user_id": "user-id",
  "title": "Schema Invalid Study",
  "status": "draft",
  "participation": "invite",
  "result_sharing": "private",
  "contact": {"organization": "Test Org", "email": "test@example.com", "website": "", "phone": ""},
  "icon_name": "accountHeart",
  "published": false,
  "questionnaire": [],
  "eligibility_criteria": [],
  "consent": [],
  "interventions": [],
  "observations": [],
  "schedule": {"phaseDuration": 7, "numberOfCycles": 2, "includeBaseline": false, "sequence": "alternating", "sequenceCustom": "ABAB"},
  "report_specification": {"secondary": []},
  "results": [],
  "unexpected": true
}
''';

String _workdir() => Directory.current.path.endsWith('studyu_validator')
    ? Directory.current.path
    : '${Directory.current.path}/tools/studyu_validator';

Future<ProcessResult> _runCli(List<String> args) => Process.run('dart', [
  'run',
  'bin/studyu_validator.dart',
  ...args,
], workingDirectory: _workdir());

void main() {
  test('validate subcommand exits 0 for valid study via temp file', () async {
    final tmp = await File('/tmp/test_study_valid.json').create();
    await tmp.writeAsString(validStudyJson);

    final result = await _runCli(['validate', tmp.path]);

    expect(result.exitCode, 0, reason: 'stderr: ${result.stderr}');
    final output = jsonDecode(result.stdout as String) as Map;
    expect(output['valid'], isTrue);
  });

  test('validate subcommand exits 1 for invalid study via temp file', () async {
    final tmp = await File('/tmp/test_study_invalid.json').create();
    await tmp.writeAsString(invalidStudyJson);

    final result = await _runCli(['validate', tmp.path]);

    expect(result.exitCode, 1, reason: 'stderr: ${result.stderr}');
    final output = jsonDecode(result.stdout as String) as Map;
    expect(output['valid'], isFalse);
  });

  test('validate --schema-only exits 0 for schema-valid fixture', () async {
    final tmp = await File('/tmp/test_study_schema_valid.json').create();
    await tmp.writeAsString(validStudyJson);

    final result = await _runCli(['validate', '--schema-only', tmp.path]);

    expect(result.exitCode, 0, reason: 'stderr: ${result.stderr}');
    final output = jsonDecode(result.stdout as String) as Map;
    expect(output['valid'], isTrue);
  });

  test('full validate exits 0 for schema-valid fixture', () async {
    final tmp = await File('/tmp/test_study_full_valid.json').create();
    await tmp.writeAsString(validStudyJson);

    final result = await _runCli(['validate', tmp.path]);

    expect(result.exitCode, 0, reason: 'stderr: ${result.stderr}');
    final output = jsonDecode(result.stdout as String) as Map;
    expect(output['valid'], isTrue);
  });

  test(
    'validate --schema-only exits 1 with SCHEMA_ERROR for schema-invalid json',
    () async {
      final tmp = await File('/tmp/test_study_schema_invalid.json').create();
      await tmp.writeAsString(schemaInvalidJson);

      final result = await _runCli(['validate', '--schema-only', tmp.path]);

      expect(result.exitCode, 1, reason: 'stderr: ${result.stderr}');
      final output = jsonDecode(result.stdout as String) as Map;
      expect(output['valid'], isFalse);
      final errors = output['errors'] as List;
      expect(errors.any((e) => (e as Map)['code'] == 'SCHEMA_ERROR'), isTrue);
      expect(
        errors.any(
          (e) =>
              (e as Map)['code'] != 'SCHEMA_ERROR' &&
              e['code'] != 'PARSE_ERROR',
        ),
        isFalse,
      );
    },
  );

  test(
    'full validate exits 1 with SCHEMA_ERROR for schema-invalid json (no DESERIALIZE_ERROR)',
    () async {
      final tmp = await File(
        '/tmp/test_study_full_schema_invalid.json',
      ).create();
      await tmp.writeAsString(schemaInvalidJson);

      final result = await _runCli(['validate', tmp.path]);

      expect(result.exitCode, 1, reason: 'stderr: ${result.stderr}');
      final output = jsonDecode(result.stdout as String) as Map;
      expect(output['valid'], isFalse);
      final errors = output['errors'] as List;
      expect(errors.any((e) => (e as Map)['code'] == 'SCHEMA_ERROR'), isTrue);
      expect(
        errors.any((e) => (e as Map)['code'] == 'DESERIALIZE_ERROR'),
        isFalse,
      );
    },
  );

  test(
    'validate --schema-only exits 0 for schema-valid but logic-invalid json',
    () async {
      final tmp = await File('/tmp/test_study_logic_invalid.json').create();
      await tmp.writeAsString(invalidStudyJson);

      final result = await _runCli(['validate', '--schema-only', tmp.path]);

      expect(result.exitCode, 0, reason: 'stderr: ${result.stderr}');
      final output = jsonDecode(result.stdout as String) as Map;
      expect(output['valid'], isTrue);
    },
  );

  test(
    'full validate exits 1 with logic error for schema-valid but logic-invalid json',
    () async {
      final tmp = await File(
        '/tmp/test_study_full_logic_invalid.json',
      ).create();
      await tmp.writeAsString(invalidStudyJson);

      final result = await _runCli(['validate', tmp.path]);

      expect(result.exitCode, 1, reason: 'stderr: ${result.stderr}');
      final output = jsonDecode(result.stdout as String) as Map;
      expect(output['valid'], isFalse);
      final errors = output['errors'] as List;
      expect(
        errors.any((e) => (e as Map)['code'] == 'study_info.title_required'),
        isTrue,
      );
    },
  );

  test(
    'schema subcommand stdout is valid JSON with Draft 7 \$schema',
    () async {
      final result = await _runCli(['schema']);

      expect(result.exitCode, 0, reason: 'stderr: ${result.stderr}');
      final output = jsonDecode(result.stdout as String) as Map;
      expect(output[r'$schema'], 'http://json-schema.org/draft-07/schema#');
    },
  );

  test('validate rejects conflicting flags before reading input', () async {
    final result = await _runCli([
      'validate',
      '--schema-only',
      '--section',
      'study_info',
    ]);

    expect(result.exitCode, 1);
    expect(result.stderr.toString(), contains('--schema-only'));
    expect(result.stderr.toString(), isNot(contains('Provide a file path')));
  });
}

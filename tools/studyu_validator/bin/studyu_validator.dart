import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'package:studyu_validator/studyu_validator.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help')
    ..addCommand('validate')
    ..addCommand('normalize')
    ..addCommand('schema');

  parser.commands['validate']!
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help')
    ..addFlag('stdin', help: 'Read study JSON from stdin')
    ..addFlag(
      'schema-only',
      negatable: false,
      help: 'Validate against the JSON Schema only',
    )
    ..addOption('level', defaultsTo: 'draft', allowed: ['draft', 'publish'])
    ..addOption(
      'section',
      allowed: const [
        'study_info',
        'interventions',
        'questionnaire',
        'schedule',
        'consent',
        'observations',
        'report',
        'eligibility',
      ],
    );
  parser.commands['normalize']!
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help')
    ..addFlag('stdin', help: 'Read study JSON from stdin');
  parser.commands['schema']!.addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Show this help',
  );

  final ArgResults results;
  try {
    results = parser.parse(args);
  } catch (error) {
    stderr.writeln('Error: $error');
    _printUsage(parser);
    exitCode = 1;
    return;
  }

  if (results['help'] as bool) {
    _printUsage(parser);
    return;
  }
  final command = results.command;
  if (command == null) {
    _printUsage(parser);
    exitCode = 1;
    return;
  }
  if (command['help'] as bool) {
    stdout.writeln('Usage: studyu_validator ${command.name} [options]');
    stdout.writeln(parser.commands[command.name!]!.usage);
    return;
  }

  switch (command.name) {
    case 'validate':
      _runValidate(command);
    case 'normalize':
      stdout.writeln(normalizeJson(_readInput(command)));
    case 'schema':
      stdout.writeln(loadStudySchemaText());
  }
}

void _runValidate(ArgResults command) {
  final section = command['section'] as String?;
  final schemaOnly = command['schema-only'] as bool;
  if (schemaOnly && section != null) {
    stderr.writeln('Error: --schema-only cannot be combined with --section');
    exitCode = 1;
    return;
  }

  final result = validateJson(
    _readInput(command),
    level: command['level'] as String,
    section: section,
    schemaOnly: schemaOnly,
  );
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(result));
  if (result['valid'] != true) exitCode = 1;
}

void _printUsage(ArgParser parser) {
  stdout.writeln(
    'Usage: studyu_validator <validate|normalize|schema> [options]',
  );
  stdout.writeln(parser.usage);
}

String _readInput(ArgResults command) {
  if (command['stdin'] as bool) {
    final lines = <String>[];
    String? line;
    while ((line = stdin.readLineSync(encoding: utf8)) != null) {
      lines.add(line!);
    }
    return lines.join('\n');
  }
  if (command.rest.isNotEmpty) {
    return File(command.rest.first).readAsStringSync();
  }
  stderr.writeln('Provide a file path or --stdin');
  exitCode = 1;
  return '';
}

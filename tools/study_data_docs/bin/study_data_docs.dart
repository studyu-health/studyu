/// Entry point for the study_data_docs CLI.
///
/// Usage:
///   dart run tools/study_data_docs/bin/study_data_docs.dart --write
///   dart run tools/study_data_docs/bin/study_data_docs.dart --check
///   dart run tools/study_data_docs/bin/study_data_docs.dart --write --root /path/to/repo
library;

import 'dart:io';

import 'package:args/args.dart';
import 'package:study_data_docs/src/cli.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'write',
      negatable: false,
      help: 'Generate/update the full docs tree.',
    )
    ..addFlag(
      'check',
      negatable: false,
      help: 'Exit non-zero if docs differ from what --write would produce.',
    )
    ..addOption(
      'root',
      help: 'Override repo root (default: git rev-parse --show-toplevel).',
    )
    ..addOption(
      'metadata',
      help:
          'Override metadata file path relative to repo root '
          '(default: core/docs/study-data/_metadata.yaml).',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print this help.');

  final ArgResults parsed;
  try {
    parsed = parser.parse(args);
  } on ArgParserException catch (e) {
    stderr.writeln('Error: ${e.message}');
    stderr.writeln(parser.usage);
    exit(1);
  }

  if (parsed['help'] as bool) {
    stdout.writeln(parser.usage);
    exit(0);
  }

  final wantWrite = parsed['write'] as bool;
  final wantCheck = parsed['check'] as bool;

  if (!wantWrite && !wantCheck) {
    stderr.writeln('Specify --write or --check.');
    stderr.writeln(parser.usage);
    exit(1);
  }

  try {
    final repoRoot = (parsed['root'] as String?) ?? await resolveRepoRoot();
    final metadataOverride = parsed['metadata'] as String?;

    if (wantWrite) {
      await runWrite(
        repoRoot: repoRoot,
        metadataPathOverride: metadataOverride,
      );
    }

    if (wantCheck) {
      await runCheck(
        repoRoot: repoRoot,
        metadataPathOverride: metadataOverride,
      );
    }
  } catch (error) {
    stderr.writeln('Error: $error');
    exit(1);
  }
}

/// Validates and merges package LCOV reports into a single SonarQube coverage
/// report.
///
/// Usage:
///   dart normalize_lcov.dart `<output-file>`
///   dart normalize_lcov.dart --check
library;

import 'dart:io';

const _packages = ['app', 'core', 'designer_v2', 'flutter_common'];

/// Prefixes of generated files to exclude from the merged coverage report.
/// Matches are performed after the path is normalized to a repository-relative
/// path.
const _excludedPrefixes = [
  'app/lib/l10n/app_localizations',
  'designer_v2/lib/localization/app_localizations',
];

/// Thrown when an LCOV record cannot be normalized because the source path is
/// invalid, outside the repository, or does not exist.
class CoverageSourceException(final String message) implements Exception {
  @override
  String toString() => message;
}

/// Thrown when an LCOV record is malformed or incomplete.
class CoverageFormatException(final String message) implements Exception {
  @override
  String toString() => message;
}

/// Returns the repository root (parent of the `scripts` directory).
String get repoRoot {
  final script = File(Platform.script.toFilePath());
  return script.parent.parent.path;
}

/// Returns `true` if [path] looks like an absolute path.
bool _isAbsolute(String path) {
  return path.startsWith('/') || (path.length > 1 && path[1] == ':');
}

/// Normalizes an LCOV source path to a repository-relative path.
///
/// Throws [CoverageSourceException] if the path is outside the repository,
/// does not exist, or attempts directory traversal/symlink escape.
///
/// Returns `null` only when the source file is excluded (generated code or
/// generated localization).
String? normalizeSourcePath(String rawSource, String package, String repoRoot) {
  // Normalize Windows-style separators to forward slashes.
  var source = rawSource.trim().replaceAll(r"\", '/');

  // Some tools emit the literal "SF:" prefix inside the source value.
  if (source.startsWith('SF:')) {
    source = source.substring(3);
  }

  final rootDir = Directory(repoRoot).absolute;

  // Resolve the source to an absolute path under the repository.
  late String absoluteSource;
  if (_isAbsolute(source)) {
    absoluteSource = source;
  } else if (!source.contains('/')) {
    // Bare file name; assume it belongs to the package.
    absoluteSource = '$repoRoot/$package/$source';
  } else {
    final firstSegment = source.split('/').first;
    if (firstSegment == package) {
      absoluteSource = '$repoRoot/$source';
    } else {
      absoluteSource = '$repoRoot/$package/$source';
    }
  }

  // Canonicalize and verify the path stays inside the repository.
  final resolved = File(absoluteSource).absolute;
  final String canonical;
  try {
    canonical = resolved.resolveSymbolicLinksSync();
  } on FileSystemException catch (e) {
    throw CoverageSourceException(
      'Coverage source cannot be resolved: $source (${e.path})',
    );
  }

  final rootCanonical = rootDir.resolveSymbolicLinksSync();
  if (canonical != rootCanonical && !canonical.startsWith('$rootCanonical/')) {
    throw CoverageSourceException(
      'Coverage source is outside the repository: $source',
    );
  }

  if (!File(canonical).existsSync()) {
    throw CoverageSourceException('Coverage source does not exist: $source');
  }

  final relative = canonical.substring(rootCanonical.length + 1);

  // Apply exclusions only for generated files.
  if (relative.endsWith('.g.dart')) {
    return null;
  }
  for (final prefix in _excludedPrefixes) {
    if (relative.startsWith(prefix)) {
      return null;
    }
  }

  return relative;
}

/// Parses an LCOV report and returns normalized, non-excluded records.
List<List<String>> parseLcovReport(
  String reportPath,
  String package,
  String repoRoot,
) {
  final file = File(reportPath);
  if (!file.existsSync()) {
    throw Exception('Missing coverage report: $reportPath');
  }

  final content = file.readAsStringSync();
  if (content.trim().isEmpty) {
    throw Exception('Empty coverage report: $reportPath');
  }

  final lines = content.split('\n');
  final records = <List<String>>[];
  List<String>? currentRecord;
  var hasData = false;

  for (final rawLine in lines) {
    final line = rawLine.replaceFirst(RegExp(r'\r$'), '');

    if (line.startsWith('SF:')) {
      if (currentRecord != null) {
        throw CoverageFormatException(
          'Incomplete LCOV record before SF: in $reportPath',
        );
      }
      currentRecord = <String>[line];
      hasData = false;
      continue;
    }

    if (currentRecord == null) {
      if (line == 'end_of_record') {
        throw CoverageFormatException(
          'Unexpected end_of_record before SF: in $reportPath',
        );
      }
      continue;
    }

    currentRecord.add(line);

    if (line == 'end_of_record') {
      if (!hasData) {
        throw CoverageFormatException('No data lines in record in $reportPath');
      }
      final rawSource = currentRecord.first.substring(3);
      final normalized = normalizeSourcePath(rawSource, package, repoRoot);
      if (normalized != null) {
        currentRecord[0] = 'SF:$normalized';
        records.add(currentRecord);
      }
      currentRecord = null;
      hasData = false;
      continue;
    }

    if (line.startsWith('DA:') || line.startsWith('BRDA:')) {
      hasData = true;
    }
  }

  if (currentRecord != null) {
    throw CoverageFormatException('Unterminated LCOV record in $reportPath');
  }

  if (records.isEmpty) {
    throw CoverageFormatException('No usable coverage records in $reportPath');
  }

  return records;
}

void normalizeCoverage({required String repoRoot, required String outputPath}) {
  final output = File(outputPath);
  output.parent.createSync(recursive: true);
  final buffer = StringBuffer();
  var recordCount = 0;

  for (final package in _packages) {
    final reportPath = '$repoRoot/$package/coverage/lcov.info';
    final reportFile = File(reportPath);

    if (!reportFile.existsSync()) {
      throw Exception('Missing coverage report for $package: $reportPath');
    }

    if (reportFile.lengthSync() == 0) {
      throw Exception('Empty coverage report for $package: $reportPath');
    }

    final records = parseLcovReport(reportPath, package, repoRoot);
    if (records.isEmpty) {
      throw Exception('Coverage report for $package has no usable records.');
    }

    for (final record in records) {
      for (final line in record) {
        buffer.writeln(line);
      }
      recordCount++;
    }
  }

  if (recordCount == 0) {
    throw Exception(
      'No analyzable coverage records found across all packages.',
    );
  }

  output.writeAsStringSync(buffer.toString());
  stdout.writeln(
    'Wrote merged coverage report to $outputPath ($recordCount records).',
  );
}

// ---------------------------------------------------------------------------
// Built-in regression checks (dart scripts/normalize_lcov.dart --check)
// ---------------------------------------------------------------------------

String _writeLcov(String repoRoot, String package, String content) {
  final dir = Directory('$repoRoot/$package/coverage');
  dir.createSync(recursive: true);
  final path = '$repoRoot/$package/coverage/lcov.info';
  File(path).writeAsStringSync(content);
  return path;
}

void _expect<T extends Exception>(void Function() f, String message) {
  try {
    f();
  } on T {
    return;
  }
  throw Exception(message);
}

void _runChecks() {
  final tempDir = Directory.systemTemp.createTempSync('normalize_lcov_test');
  final root = tempDir.path;

  try {
    // Set up a fake app package with source and generated files.
    Directory('$root/app').createSync(recursive: true);
    Directory('$root/app/lib').createSync(recursive: true);
    File('$root/app/lib/example.dart').writeAsStringSync('void main() {}');
    File('$root/app/lib/example.g.dart')
        .writeAsStringSync('class Generated {}');

    // Set up the other required packages so validation does not fail early.
    for (final pkg in _packages.where((p) => p != 'app')) {
      Directory('$root/$pkg/lib').createSync(recursive: true);
      File('$root/$pkg/lib/example.dart').writeAsStringSync('void main() {}');
    }

    // Valid record with a repo-relative path.
    _writeLcov(root, 'app', 'SF:lib/example.dart\nDA:1,1\nend_of_record\n');

    for (final pkg in _packages.where((p) => p != 'app')) {
      _writeLcov(root, pkg, 'SF:lib/example.dart\nDA:1,1\nend_of_record\n');
    }

    final outputPath = '$root/coverage/sonar/lcov.info';
    normalizeCoverage(repoRoot: root, outputPath: outputPath);

    final merged = File(outputPath).readAsStringSync();
    if (!merged.contains('SF:app/lib/example.dart')) {
      throw Exception('Expected app source in merged report.');
    }
    if (merged.contains('SF:app/lib/example.g.dart')) {
      throw Exception('Generated file was not excluded.');
    }

    // Check: generated exclusion with an actual generated file.
    final generatedReport = _writeLcov(
      root,
      'app',
      'SF:lib/example.g.dart\nDA:1,1\nend_of_record\n'
          'SF:lib/example.dart\nDA:1,1\nend_of_record\n',
    );
    final generatedRecords = parseLcovReport(generatedReport, 'app', root);
    if (generatedRecords.length != 1) {
      throw Exception('Generated record should have been excluded.');
    }

    // Check: absolute path inside the repository.
    final absoluteReport = _writeLcov(
      root,
      'app',
      'SF:$root/app/lib/example.dart\nDA:1,1\nend_of_record\n',
    );
    final absRecords = parseLcovReport(absoluteReport, 'app', root);
    if (absRecords.isEmpty) {
      throw Exception('Absolute path inside repo should be accepted.');
    }

    // Check: invalid source alongside a valid record.
    final invalidReport = _writeLcov(
      root,
      'core',
      'SF:lib/example.dart\nDA:1,1\nend_of_record\n'
          'SF:/outside/file.dart\nDA:1,1\nend_of_record\n',
    );
    _expect<CoverageSourceException>(
      () => parseLcovReport(invalidReport, 'core', root),
      'Should throw for source outside repository.',
    );

    // Check: traversal outside the repository.
    final traversalReport = _writeLcov(
      root,
      'core',
      'SF:lib/../../etc/passwd\nDA:1,1\nend_of_record\n',
    );
    _expect<CoverageSourceException>(
      () => parseLcovReport(traversalReport, 'core', root),
      'Should throw for traversal outside repository.',
    );

    // Check: no-data record.
    final noDataReport = _writeLcov(
      root,
      'core',
      'SF:lib/example.dart\nend_of_record\n',
    );
    _expect<CoverageFormatException>(
      () => parseLcovReport(noDataReport, 'core', root),
      'Should throw for record with no data lines.',
    );

    // Check: incomplete record missing end_of_record.
    final incompleteReport = _writeLcov(
      root,
      'core',
      'SF:lib/example.dart\nDA:1,1\n',
    );
    _expect<CoverageFormatException>(
      () => parseLcovReport(incompleteReport, 'core', root),
      'Should throw for unterminated record.',
    );

    // Check: missing report file.
    _expect<Exception>(
      () => parseLcovReport('$root/core/coverage/missing.info', 'core', root),
      'Should throw for missing report.',
    );

    stdout.writeln('normalize_lcov checks passed.');
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

void main(List<String> args) {
  if (args.length == 1 && args.first == '--check') {
    _runChecks();
    return;
  }

  if (args.length != 1) {
    stderr.writeln('Usage: dart normalize_lcov.dart <output-file>');
    stderr.writeln('       dart normalize_lcov.dart --check');
    exit(64);
  }

  final outputPath = args.first;
  final root = repoRoot;
  normalizeCoverage(repoRoot: root, outputPath: outputPath);
}

import 'dart:convert';
import 'dart:io';

const _catalogDirectories = ['app/lib/l10n', 'designer_v2/lib/localization'];

List<String> _checkCatalogs(String root) {
  final diagnostics = <String>[];
  for (final relativeDirectory in _catalogDirectories) {
    final directory = Directory('$root/$relativeDirectory');
    if (!directory.existsSync()) {
      diagnostics.add('$relativeDirectory: catalog directory does not exist');
      continue;
    }
    final files =
        directory
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.arb'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    final names = files.map((file) => file.path.substring(root.length + 1));
    if (!names.contains('$relativeDirectory/app_en.arb')) {
      diagnostics.add(
        '$relativeDirectory/app_en.arb: required English template is missing',
      );
    }
    if (files.length < 2) {
      diagnostics.add('$relativeDirectory: expected at least two ARB files');
    }

    final catalogs = <String, Set<String>>{};
    var invalidCatalog = false;
    for (final file in files) {
      final path = file.path.substring(root.length + 1);
      try {
        final decoded = jsonDecode(file.readAsStringSync());
        if (decoded is! Map<String, dynamic>) {
          diagnostics.add('$path: JSON root must be an object');
          invalidCatalog = true;
          continue;
        }
        final keys = decoded.keys.where((key) => !key.startsWith('@')).toSet();
        if (keys.isEmpty) {
          diagnostics.add('$path: catalog has no message keys');
          invalidCatalog = true;
          continue;
        }
        catalogs[path] = keys;
      } on FileSystemException catch (error) {
        diagnostics.add('$path: ${error.message}');
        invalidCatalog = true;
      } on FormatException catch (error) {
        diagnostics.add('$path: ${error.message}');
        invalidCatalog = true;
      }
    }
    if (invalidCatalog) continue;
    final union = catalogs.values.expand((keys) => keys).toSet();
    for (final entry in catalogs.entries) {
      final missing = union.difference(entry.value).toList()..sort();
      if (missing.isNotEmpty) {
        diagnostics.add(
          '${entry.key}: missing message keys: ${missing.join(', ')}',
        );
      }
    }
  }
  return diagnostics;
}

void _expect(bool condition, String message) {
  if (!condition) throw Exception(message);
}

void _writeFixture(String root, String path, String content) {
  (File('$root/$path')..createSync(recursive: true)).writeAsStringSync(content);
}

void _createFixtures(String root) {
  for (final directory in _catalogDirectories) {
    final dir = Directory('$root/$directory');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    final key = directory.startsWith('app/') ? 'hello' : 'save';
    for (final locale in ['en', 'de', 'ko']) {
      _writeFixture(
        root,
        '$directory/app_$locale.arb',
        jsonEncode({
          '@@locale': locale,
          key: locale == 'ko' ? '' : '$key-$locale',
          '@$key': {'description': 'metadata'},
          if (locale == 'de') '@___SECTION___': {'title': 'Section'},
        }),
      );
    }
  }
}

String _catalogBytes(String root) => _catalogDirectories
    .expand(
      (directory) => Directory('$root/$directory').listSync().whereType<File>(),
    )
    .where((file) => file.path.endsWith('.arb'))
    .map((file) => '${file.path}: ${file.readAsBytesSync()}')
    .join('\n');

void _runChecks() {
  final tempDir = Directory.systemTemp.createTempSync('arb_completeness_test');
  final root = tempDir.path;
  final app = _catalogDirectories.first;
  try {
    _createFixtures(root);
    _expect(
      _checkCatalogs(root).isEmpty,
      'Independent catalogs and metadata should pass.',
    );

    File('$root/$app/app_ko.arb')
        .writeAsStringSync(jsonEncode({'shared': '공유'}));
    File('$root/$app/app_en.arb')
        .writeAsStringSync(jsonEncode({'hello': 'Hello', 'shared': 'Shared'}));
    File(
      '$root/$app/app_de.arb',
    ).writeAsStringSync(jsonEncode({'hello': 'Hallo', 'shared': 'Gemeinsam'}));
    var diagnostics = _checkCatalogs(root);
    _expect(
      diagnostics.any(
        (d) => d.contains('app_ko.arb: missing message keys: hello'),
      ),
      'Missing shared key should identify Korean catalog.',
    );

    _createFixtures(root);
    File('$root/$app/app_de.arb').writeAsStringSync(
      jsonEncode({'hello': 'Hallo', 'german_only': 'Nur Deutsch'}),
    );
    diagnostics = _checkCatalogs(root);
    _expect(
      diagnostics
              .where((d) => d.contains('missing message keys: german_only'))
              .length ==
          2,
      'Locale-only key should be reported in each other locale.',
    );

    _createFixtures(root);
    _writeFixture(root, '$app/app_fr.arb', jsonEncode({'other': 'autre'}));
    diagnostics = _checkCatalogs(root);
    _expect(
      diagnostics.any(
        (d) => d.contains('app_fr.arb: missing message keys: hello'),
      ),
      'New locale should be discovered automatically.',
    );

    _createFixtures(root);
    _writeFixture(root, '$app/app_de.arb', '{');
    diagnostics = _checkCatalogs(root);
    _expect(
      diagnostics.any((d) => d.contains('app_de.arb:')),
      'Malformed JSON needs a file diagnostic.',
    );
    _writeFixture(root, '$app/app_de.arb', '[]');
    _expect(
      _checkCatalogs(root).any((d) => d.contains('app_de.arb: JSON root')),
      'Non-object JSON needs a file diagnostic.',
    );
    _writeFixture(root, '$app/app_de.arb', jsonEncode({'@hello': {}}));
    _expect(
      _checkCatalogs(root)
          .any((d) => d.contains('app_de.arb: catalog has no message keys')),
      'Metadata-only catalog needs a file diagnostic.',
    );

    _createFixtures(root);
    Directory('$root/${_catalogDirectories.last}').deleteSync(recursive: true);
    diagnostics = _checkCatalogs(root);
    _expect(
      diagnostics.any(
        (d) => d.contains('${_catalogDirectories.last}: catalog directory'),
      ),
      'Missing directory needs a path diagnostic.',
    );

    _createFixtures(root);
    File('$root/$app/app_en.arb').deleteSync();
    _expect(
      _checkCatalogs(root)
          .any((d) => d.contains('$app/app_en.arb: required English')),
      'Missing English template needs a path diagnostic.',
    );

    _createFixtures(root);
    File('$root/$app/app_de.arb').writeAsStringSync('{');
    File('$root/${_catalogDirectories.last}/app_ko.arb')
        .writeAsStringSync(jsonEncode({'different': '값'}));
    diagnostics = _checkCatalogs(root);
    _expect(
      diagnostics.any((d) => d.contains('app_de.arb:')) &&
          diagnostics.any(
            (d) => d.contains('app_ko.arb: missing message keys: save'),
          ),
      'Invalid App catalog must not prevent Designer checking.',
    );

    _createFixtures(root);
    final script = File(Platform.script.toFilePath()).absolute.path;
    var result = Process.runSync(Platform.resolvedExecutable, [
      script,
    ], workingDirectory: root);
    _expect(
      result.exitCode == 0 &&
          result.stdout.toString().contains('ARB message keys are complete.'),
      'Valid CLI fixture should exit zero and print success: ${result.stderr}',
    );
    File('$root/$app/app_ko.arb')
        .writeAsStringSync(jsonEncode({'different': '다름'}));
    result = Process.runSync(Platform.resolvedExecutable, [
      script,
    ], workingDirectory: root);
    _expect(
      result.exitCode == 1 && result.stderr.toString().contains('hello'),
      'Incomplete CLI should exit one and name missing key.',
    );
    result = Process.runSync(Platform.resolvedExecutable, [
      script,
      '--bad',
    ], workingDirectory: root);
    _expect(result.exitCode == 64, 'Invalid CLI argument should exit 64.');
    _createFixtures(root);
    final before = _catalogBytes(root);
    Process.runSync(Platform.resolvedExecutable, [
      script,
    ], workingDirectory: root);
    Process.runSync(Platform.resolvedExecutable, [
      script,
      '--bad',
    ], workingDirectory: root);
    _expect(_catalogBytes(root) == before, 'CLI must not modify catalogs.');
    stdout.writeln('ARB completeness checks passed.');
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

void _runChecksAtRoot(String root) {
  final diagnostics = _checkCatalogs(root);
  if (diagnostics.isNotEmpty) {
    stderr.writeln(diagnostics.join('\n'));
    exitCode = 1;
    return;
  }
  stdout.writeln('ARB message keys are complete.');
}

void main(List<String> args) {
  if (args.isNotEmpty && !(args.length == 1 && args.first == '--check')) {
    stderr.writeln('Usage: dart scripts/check_arb_completeness.dart [--check]');
    exitCode = 64;
    return;
  }
  if (args.isNotEmpty) {
    _runChecks();
    return;
  }
  _runChecksAtRoot(Directory.current.path);
}

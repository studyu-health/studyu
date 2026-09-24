/// Reports template-ARB localization keys that never occur as member
/// accesses in the owning package's Dart sources.
///
/// `gen-l10n` emits every ARB key as an `AppLocalizations` getter that can
/// only be reached through a `.key` member access, so a key absent from all
/// non-generated Dart files in the owning package (lib, tests, integration
/// tests) is unused. Scanning the whole package keeps keys that only test
/// code references out of the report, so every reported key can be deleted
/// without breaking compilation.
///
/// Exit codes: 0 = no unused keys, 1 = unused keys found, 2 = missing input.
///
/// Usage:
///   dart scripts/check_unused_l10n.dart
library;

import 'dart:convert';
import 'dart:io';

/// Template ARB file and the package source directories to scan: library,
/// unit tests, and integration tests. Other directories (build output,
/// `.dart_tool`) hold gitignored sources and are excluded so the scan only
/// sees tracked files. Missing scan directories are skipped.
const _targets = [
  ('app/lib/l10n/app_en.arb', ['app/lib', 'app/test', 'app/integration_test']),
  (
    'designer_v2/lib/localization/app_en.arb',
    ['designer_v2/lib', 'designer_v2/test', 'designer_v2/integration_test'],
  ),
];

final _memberAccess = RegExp(r'\.([A-Za-z_]\w*)');

/// Repository root derived from this script's location (`<root>/scripts/...`).
String get _repoRoot => File(Platform.script.toFilePath()).parent.parent.path;

/// Every `.<identifier>` occurring in a non-generated Dart file under
/// [packageDir]. Generated `app_localizations*.dart` files are skipped
/// because they declare every key and would mark all of them as used.
({Set<String> members, int files}) _accessedMembers(Directory packageDir) {
  final members = <String>{};
  var files = 0;
  for (final entity in packageDir.listSync(recursive: true)) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;
    if (!name.endsWith('.dart')) continue;
    if (name.startsWith('app_localizations')) continue;
    files++;
    for (final match in _memberAccess.allMatches(entity.readAsStringSync())) {
      members.add(match.group(1)!);
    }
  }
  return (members: members, files: files);
}

void main() {
  final root = _repoRoot;
  final stopwatch = Stopwatch()..start();
  final unused = <String>[];
  for (final (arbPath, scanPaths) in _targets) {
    final arbFile = File('$root/$arbPath');
    if (!arbFile.existsSync()) {
      stderr.writeln('missing ARB file: $arbPath');
      exit(2);
    }
    final package = arbPath.split('/').first;
    final arb = jsonDecode(arbFile.readAsStringSync()) as Map<String, dynamic>;
    final keys = arb.keys.where((key) => !key.startsWith('@')).toList();
    final members = <String>{};
    var files = 0;
    for (final scanPath in scanPaths) {
      final dir = Directory('$root/$scanPath');
      if (!dir.existsSync()) continue;
      final scanned = _accessedMembers(dir);
      members.addAll(scanned.members);
      files += scanned.files;
    }
    print('$package: ${keys.length} l10n keys in $files dart files');
    for (final key in keys) {
      if (!members.contains(key)) unused.add('$package/$key');
    }
  }
  final elapsed = stopwatch.elapsedMilliseconds;
  if (unused.isEmpty) {
    print('No unused l10n keys. ($elapsed ms)');
    return;
  }
  unused.sort();
  for (final hit in unused) {
    print('unused l10n key: $hit');
  }
  print('${unused.length} unused l10n keys found. ($elapsed ms)');
  exit(1);
}

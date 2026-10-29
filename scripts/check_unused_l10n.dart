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

/// [source] with comments removed, so comment text never counts as a member
/// access. String literals are skipped; when quote tracking gets confused by
/// interpolation the result only errs toward keeping text, which keeps the
/// scan conservative (a key is only ever reported when no code match remains).
String _stripComments(String source) {
  final out = StringBuffer();
  var i = 0;
  var block = 0;
  var quote = '';
  var raw = false;
  while (i < source.length) {
    final c = source[i];
    if (block > 0) {
      if (source.startsWith('/*', i)) {
        block++;
        i += 2;
      } else if (source.startsWith('*/', i)) {
        block--;
        i += 2;
      } else {
        i++;
      }
      continue;
    }
    if (quote.isNotEmpty) {
      out.write(c);
      if (!raw && c == r'\') {
        if (i + 1 < source.length) out.write(source[i + 1]);
        i += 2;
        continue;
      }
      if (source.startsWith(quote, i)) {
        i += quote.length;
        quote = '';
        continue;
      }
      i++;
      if (c == '\n' && quote.length < 3) quote = '';
      continue;
    }
    if (source.startsWith('//', i)) {
      while (i < source.length && source[i] != '\n') {
        i++;
      }
      continue;
    }
    if (source.startsWith('/*', i)) {
      block = 1;
      i += 2;
      continue;
    }
    if (c == "'" || c == '"') {
      final triple = source.startsWith(c * 3, i);
      quote = triple ? c * 3 : c;
      final prev = i > 0 ? source[i - 1] : '';
      final prevPrev = i > 1 ? source[i - 2] : '';
      raw =
          prev == 'r' &&
          !RegExp('[A-Za-z0-9_]').hasMatch(prevPrev.isEmpty ? ' ' : prevPrev);
      i += triple ? 3 : 1;
      out.write(quote);
      continue;
    }
    out.write(c);
    i++;
  }
  return out.toString();
}

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
    for (final match in _memberAccess.allMatches(
      _stripComments(entity.readAsStringSync()),
    )) {
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

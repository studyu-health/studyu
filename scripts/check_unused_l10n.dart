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

/// Template ARB file and package directory for each checked package.
const _targets = [
  ('app/lib/l10n/app_en.arb', 'app'),
  ('designer_v2/lib/localization/app_en.arb', 'designer_v2'),
];

final _memberAccess = RegExp(r'\.([A-Za-z_]\w*)');

/// Repository root derived from this script's location (`<root>/scripts/...`).
String get _repoRoot => File(Platform.script.toFilePath()).parent.parent.path;

/// Every `.<identifier>` occurring in a non-generated Dart file under
/// [packageDir]. Generated `app_localizations*.dart` files are skipped
/// because they declare every key and would mark all of them as used.
Set<String> _accessedMembers(Directory packageDir) {
  final members = <String>{};
  for (final entity in packageDir.listSync(recursive: true)) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;
    if (!name.endsWith('.dart')) continue;
    if (name.startsWith('app_localizations')) continue;
    for (final match in _memberAccess.allMatches(entity.readAsStringSync())) {
      members.add(match.group(1)!);
    }
  }
  return members;
}

void main() {
  final root = _repoRoot;
  final unused = <String>[];
  for (final (arbPath, libPath) in _targets) {
    final arbFile = File('$root/$arbPath');
    final libDir = Directory('$root/$libPath');
    if (!arbFile.existsSync()) {
      stderr.writeln('missing ARB file: $arbPath');
      exit(2);
    }
    if (!libDir.existsSync()) {
      stderr.writeln('missing package directory: $libPath');
      exit(2);
    }
    final package = libPath;
    final arb = jsonDecode(arbFile.readAsStringSync()) as Map<String, dynamic>;
    final members = _accessedMembers(libDir);
    for (final key in arb.keys) {
      if (key.startsWith('@')) continue;
      if (!members.contains(key)) unused.add('$package/$key');
    }
  }
  if (unused.isEmpty) {
    print('No unused l10n keys.');
    return;
  }
  unused.sort();
  for (final hit in unused) {
    print('unused l10n key: $hit');
  }
  exit(1);
}

/// Validates relative markdown links inside a docs tree.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

/// A single broken link found during checking.
class BrokenLink {
  final String sourceFile; // relative path of the file containing the link
  final String href; // the raw href value
  final String resolvedPath; // absolute path that was checked

  const BrokenLink({
    required this.sourceFile,
    required this.href,
    required this.resolvedPath,
  });

  @override
  String toString() => '$sourceFile: broken link "$href" → $resolvedPath';
}

/// Checks all relative markdown links inside [docsDir].
///
/// Returns a list of broken links. An empty list means all links resolve.
List<BrokenLink> checkLinks(String docsDir) {
  final brokenLinks = <BrokenLink>[];
  final dir = Directory(docsDir);
  if (!dir.existsSync()) return brokenLinks;

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.md')) continue;

    final content = entity.readAsStringSync();
    final links = _extractMarkdownLinks(content);

    for (final href in links) {
      // Only check relative links.
      if (href.startsWith('http://') ||
          href.startsWith('https://') ||
          href.startsWith('#')) {
        continue;
      }

      final parts = href.split('#');
      final bareHref = parts.first;
      final anchor = parts.length > 1 ? parts.sublist(1).join('#') : null;
      if (bareHref.isEmpty) continue;

      final resolved = p.normalize(p.join(p.dirname(entity.path), bareHref));
      final targetFile = _resolveMarkdownTarget(resolved);

      if (targetFile == null ||
          (anchor != null &&
              anchor.isNotEmpty &&
              !targetFile.readAsStringSync().containsMarkdownAnchor(anchor))) {
        brokenLinks.add(
          BrokenLink(
            sourceFile: entity.path,
            href: href,
            resolvedPath: resolved,
          ),
        );
      }
    }
  }

  return brokenLinks;
}

File? _resolveMarkdownTarget(String resolved) {
  final file = File(resolved);
  if (file.existsSync()) return file;

  final dir = Directory(resolved);
  if (!dir.existsSync()) return null;

  final index = File(p.join(resolved, 'index.md'));
  return index.existsSync() ? index : null;
}

/// Extracts all href values from `[text](href)` patterns.
List<String> _extractMarkdownLinks(String markdown) {
  final pattern = RegExp(r'\[(?:[^\]]*)\]\(([^)]+)\)');
  return pattern.allMatches(markdown).map((m) => m.group(1)!).toList();
}

extension on String {
  bool containsMarkdownAnchor(String anchor) {
    final anchors = <String>{};
    final headingCounts = <String, int>{};

    for (final line in split('\n')) {
      final heading = RegExp(r'^#{1,6}\s+(.+?)\s*#*\s*$').firstMatch(line);
      if (heading != null) {
        final baseSlug = _githubHeadingSlug(heading.group(1)!);
        final count = headingCounts[baseSlug] ?? 0;
        headingCounts[baseSlug] = count + 1;
        anchors.add(count == 0 ? baseSlug : '$baseSlug-$count');
      }

      anchors.addAll(
        RegExp(
          r'''<[^>]+\s(?:id|name)=["']([^"']+)["'][^>]*>''',
          caseSensitive: false,
        ).allMatches(line).map((match) => match.group(1)!),
      );
    }

    return anchors.contains(Uri.decodeComponent(anchor));
  }
}

String _githubHeadingSlug(String heading) {
  return heading
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('<[^>]*>'), '')
      .replaceAll(RegExp('[`*_~\\[\\](){}:;,.!?/\\\\"\']'), '')
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s-]', unicode: true), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp('-+'), '-');
}

/// Core CLI logic: orchestrates scanning, writing, and drift checking.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:study_data_docs/src/doc_metadata.dart';
import 'package:study_data_docs/src/generated_block.dart';
import 'package:study_data_docs/src/link_checker.dart';
import 'package:study_data_docs/src/markdown_writer.dart';
import 'package:study_data_docs/src/model_scanner.dart';
import 'package:study_data_docs/src/page_scope.dart';

const String _kDefaultMetadataFile = 'core/docs/study-data/_metadata.yaml';
const String _kDefaultDocsDir = 'core/docs/study-data';
const String _kModelsDir = 'core/lib/src/models';

/// Resolves the repo root using `git rev-parse --show-toplevel`.
Future<String> resolveRepoRoot() async {
  final result = await Process.run('git', ['rev-parse', '--show-toplevel']);
  if (result.exitCode != 0) {
    throw StateError('Cannot resolve repo root: ${result.stderr}');
  }

  final repoRoot = (result.stdout as String).trim();
  if (!Directory(repoRoot).existsSync()) {
    throw StateError('Resolved repo root does not exist: $repoRoot');
  }
  return repoRoot;
}

/// Runs `--write`: generates/updates the full docs tree.
Future<void> runWrite({
  required String repoRoot,
  String? metadataPathOverride,
  String? docsDirOverride,
}) async {
  final metadataPath = p.join(
    repoRoot,
    metadataPathOverride ?? _kDefaultMetadataFile,
  );
  final docsDir = p.join(repoRoot, docsDirOverride ?? _kDefaultDocsDir);
  final modelsDir = p.join(repoRoot, _kModelsDir);

  stdout.writeln('[write] Scanning models from $modelsDir …');
  final Map<String, ScannedClass> scannedClasses;
  try {
    scannedClasses = await scanModels(modelsDir: modelsDir, repoRoot: repoRoot);
  } catch (error) {
    stderr.writeln('[write] FAIL: $error');
    exit(1);
  }

  final meta = DocMetadata.load(metadataPath);

  var written = 0;
  for (final pagePath in allPagePaths) {
    final pageMeta = meta.page(pagePath);
    if (pageMeta == null) {
      stderr.writeln(
        '[write] WARNING: No metadata for page $pagePath — skipping.',
      );
      continue;
    }

    final entries = entriesForPage(pagePath);
    final classes = entries
        .map((e) => scannedClasses[e.className])
        .whereType<ScannedClass>()
        .toList();

    if (writePage(
      docsDir: docsDir,
      pagePath: pagePath,
      meta: pageMeta,
      classes: classes,
      allClasses: scannedClasses,
      typeLinks: meta.typeLinks,
    )) {
      written++;
    }
  }

  if (_writeIndexPage(docsDir: docsDir, meta: meta)) written++;
  stdout.writeln('[write] Done — $written page(s) changed.');
}

/// Runs `--check`: exits non-zero if docs drift from what `--write` would produce.
Future<void> runCheck({
  required String repoRoot,
  String? metadataPathOverride,
  String? docsDirOverride,
}) async {
  final metadataPath = p.join(
    repoRoot,
    metadataPathOverride ?? _kDefaultMetadataFile,
  );
  final docsDir = p.join(repoRoot, docsDirOverride ?? _kDefaultDocsDir);
  final modelsDir = p.join(repoRoot, _kModelsDir);

  final errors = <String>[];

  if (!File(metadataPath).existsSync()) {
    stderr.writeln('[check] FAIL: Metadata file not found: $metadataPath');
    exit(1);
  }

  final meta = DocMetadata.load(metadataPath);

  stdout.writeln('[check] Scanning models …');
  try {
    final scannedClasses = await scanModels(
      modelsDir: modelsDir,
      repoRoot: repoRoot,
    );

    // 1. Every canonical generated page must have a metadata entry.
    for (final pagePath in allPagePaths) {
      if (meta.page(pagePath) == null) {
        errors.add('Missing metadata entry for page: $pagePath');
      }
    }

    // 2. Every non-manual metadata page must exist in the canonical scope.
    for (final pagePath in meta.allPagePaths) {
      if (meta.manualPagePaths.contains(pagePath)) continue;
      if (!allPagePaths.contains(pagePath)) {
        errors.add(
          'Metadata has page "$pagePath" not in canonical scope — '
          'remove it, add it to page_scope.dart, or move it to manual_pages.',
        );
      }
    }

    // 3. Every metadata entry must list at least a title and useful field prose.
    for (final pageMeta in meta.allPages) {
      if (pageMeta.title.isEmpty) {
        errors.add('${pageMeta.path}: metadata is missing a title.');
      }

      for (final field in pageMeta.fields.values) {
        final weakProseError = _validateFieldDescription(pageMeta.path, field);
        if (weakProseError != null) errors.add(weakProseError);
      }
    }
    // 4. Per-page checks.
    for (final pagePath in meta.allPagePaths) {
      final pageMeta = meta.page(pagePath);
      if (pageMeta == null) continue;

      final absPath = p.join(docsDir, pagePath);
      final file = File(absPath);

      if (!file.existsSync()) {
        errors.add(
          'Docs page missing: $pagePath — run --write to generate it.',
        );
        continue;
      }

      final existing = file.readAsStringSync();
      final entries = entriesForPage(pagePath);
      final classes = entries
          .map((e) => scannedClasses[e.className])
          .whereType<ScannedClass>()
          .toList();

      // 4a. Page title must match metadata.
      final firstHeadingMatch = RegExp(
        r'^#\s+(.+)$',
        multiLine: true,
      ).firstMatch(existing);
      if (firstHeadingMatch != null) {
        final heading = firstHeadingMatch.group(1)!.trim();
        if (heading != pageMeta.title) {
          errors.add(
            '$pagePath: first heading "$heading" does not match '
            'metadata title "${pageMeta.title}".',
          );
        }
      } else {
        errors.add('$pagePath: no H1 heading found.');
      }

      // 4b. Description is human-owned prose and required on every page.
      final descriptionError = _validateDescriptionSection(existing, pagePath);
      if (descriptionError != null) {
        errors.add(descriptionError);
      }

      // 4b. FIELDS block drift.
      if (entries.any((entry) => entry.generatedFields)) {
        final expectedBlocks = buildExpectedFieldBlocks(
          scopeEntries: entries,
          classes: classes,
          meta: pageMeta,
          typeLinks: meta.typeLinks,
          currentPagePath: pagePath,
        );
        for (final entry in expectedBlocks.entries) {
          final expectedContent = buildFieldsTable(entry.value);
          final currentContent = extractBlock(existing, entry.key);

          if (currentContent == null) {
            errors.add('$pagePath: missing GENERATED:${entry.key} block.');
          } else if (currentContent.trim() != expectedContent.trim()) {
            errors.add(
              '$pagePath: GENERATED:${entry.key} block is out of date. Run --write.',
            );
          }
        }

        // 4c. Every serialisable field must have a description or be ignored.
        for (final cls in classes) {
          for (final field in cls.fields) {
            if (!field.includeInJson) continue;
            if (pageMeta.ignoredFields.contains(field.name) ||
                pageMeta.ignoredFields.contains(field.jsonKey)) {
              continue;
            }
            final hasMeta =
                pageMeta.fields.containsKey(field.name) ||
                pageMeta.fields.containsKey(field.jsonKey);
            if (!hasMeta) {
              errors.add(
                '$pagePath: field "${field.name}" (json: "${field.jsonKey}") '
                'has no description in _metadata.yaml and is not in ignoredFields.',
              );
            }
          }
        }

        // 4d. Metadata must not describe fields absent from source (unless virtual).
        final sourceFieldNames = {
          for (final cls in classes)
            for (final f in cls.fields) ...{f.name, f.jsonKey},
        };
        for (final fieldMeta in pageMeta.fields.values) {
          if (fieldMeta.virtual) continue;
          if (!sourceFieldNames.contains(fieldMeta.name)) {
            errors.add(
              '$pagePath: _metadata.yaml describes field "${fieldMeta.name}" '
              'which does not exist in source. Add virtual: true or remove it.',
            );
          }
        }
      } else if (extractBlock(existing, 'FIELDS') != null) {
        errors.add(
          '$pagePath: unexpected GENERATED:FIELDS block; page scope disables field generation.',
        );
      }

      // 4e. DISCRIMINATORS block drift.
      final discriminatorEntries = buildExpectedDiscriminatorEntries(
        scopeEntries: entries,
        classes: classes,
        allClasses: scannedClasses,
      );
      if (discriminatorEntries.isNotEmpty) {
        final expectedContent = buildDiscriminatorsBlock(discriminatorEntries);
        final currentContent = extractBlock(existing, 'DISCRIMINATORS');
        if (currentContent == null) {
          errors.add('$pagePath: missing GENERATED:DISCRIMINATORS block.');
        } else if (currentContent.trim() != expectedContent.trim()) {
          errors.add(
            '$pagePath: GENERATED:DISCRIMINATORS block is out of date. Run --write.',
          );
        }
      }

      // 4f. LINKS block drift.
      if (pageMeta.links.isNotEmpty) {
        final linkEntries = _buildExpectedLinkEntries(pageMeta.links, pagePath);
        final expectedContent = buildLinksBlock(linkEntries);
        final currentContent = extractBlock(existing, 'LINKS');
        if (currentContent == null) {
          errors.add('$pagePath: missing GENERATED:LINKS block.');
        } else if (currentContent.trim() != expectedContent.trim()) {
          errors.add(
            '$pagePath: GENERATED:LINKS block is out of date. Run --write.',
          );
        }
      }
    }

    // 5. No orphaned pages in the docs tree.
    final docsDirectory = Directory(docsDir);
    if (docsDirectory.existsSync()) {
      for (final entity in docsDirectory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.md')) continue;
        final rel = p.relative(entity.path, from: docsDir);
        if (rel == 'index.md') continue;
        if (!meta.allPagePaths.contains(rel)) {
          errors.add(
            'Orphaned page in docs tree: $rel — '
            'add to page_scope.dart or delete the file.',
          );
        }
      }
    }

    // 6. Generated root index must match the canonical page scope.
    final indexFile = File(p.join(docsDir, 'index.md'));
    final expectedIndex = _buildIndexPage(meta);
    if (!indexFile.existsSync()) {
      errors.add('Docs index missing: index.md — run --write to generate it.');
    } else if (indexFile.readAsStringSync().trim() != expectedIndex.trim()) {
      errors.add('index.md is out of date. Run --write.');
    }

    // 7. Broken relative links.
    final brokenLinks = checkLinks(docsDir);
    for (final link in brokenLinks) {
      errors.add(link.toString());
    }
  } catch (error) {
    errors.add('scan failed: $error');
  }

  if (errors.isEmpty) {
    stdout.writeln('[check] OK — no drift detected.');
    exit(0);
  } else {
    stderr.writeln('[check] FAIL — ${errors.length} issue(s):');
    for (final e in errors) {
      stderr.writeln('  • $e');
    }
    exit(1);
  }
}

String? _validateDescriptionSection(String markdown, String pagePath) {
  final lines = markdown.split('\n');
  final headingIndex = lines.indexWhere(
    (line) => line.trim() == '## Description',
  );
  if (headingIndex == -1) {
    return '$pagePath: missing required ## Description section.';
  }

  final bodyLines = <String>[];
  for (var i = headingIndex + 1; i < lines.length; i++) {
    final line = lines[i];
    if (line.startsWith('## ')) break;
    if (line.startsWith('<!-- GENERATED:')) break;
    bodyLines.add(line);
  }

  final body = bodyLines.join('\n').trim();
  if (body.isEmpty) {
    return '$pagePath: ## Description is empty.';
  }
  if (body.startsWith('TODO:')) {
    return '$pagePath: ## Description still contains TODO placeholder.';
  }

  return null;
}

String? _validateFieldDescription(String pagePath, FieldMeta field) {
  const weakDescriptions = {
    'Optional explanation.',
    'Optional description.',
    'The question text.',
  };

  if (weakDescriptions.contains(field.description.trim())) {
    return '$pagePath: field "${field.name}" has weak description "${field.description}".';
  }
  return null;
}

bool _writeIndexPage({required String docsDir, required DocMetadata meta}) {
  final absPath = p.join(docsDir, 'index.md');
  final next = _buildIndexPage(meta);
  final file = File(absPath);
  final previous = file.existsSync() ? file.readAsStringSync() : null;
  if (previous == next) return false;
  file.writeAsStringSync(next);
  return true;
}

String _buildIndexPage(DocMetadata meta) {
  final buf = StringBuffer();
  buf.writeln('# Study Data Reference');
  buf.writeln();
  buf.writeln('## Description');
  buf.writeln();
  buf.writeln(
    'Study data docs describe the JSON-serialisable models used to define, '
    'schedule, run, and report a StudyU study.',
  );
  buf.writeln();
  _writeMinimalStudyExample(buf);
  buf.writeln();
  buf.writeln('## Pages');
  buf.writeln();

  final sections = <String, List<String>>{};
  for (final pagePath in meta.allPagePaths) {
    final dir = p.posix.dirname(pagePath);
    sections.putIfAbsent(dir, () => []).add(pagePath);
  }

  for (final section in sections.keys.toList()..sort()) {
    buf.writeln('### $section');
    for (final path in sections[section]!..sort()) {
      final label = _pageLabelFromPath(path);
      buf.writeln('- [$label]($path)');
    }
    buf.writeln();
  }

  return buf.toString();
}

void _writeMinimalStudyExample(StringBuffer buf) {
  buf.writeln('## Minimal Study JSON');
  buf.writeln();
  buf.writeln(
    'This example defines one invite-only study with one consent item, one '
    'intervention arm, one scheduled questionnaire observation, one conditional '
    'question, one numeric result, and one report section.',
  );
  buf.writeln();
  buf.writeln('```json');
  buf.writeln(
    '''
{
  "id": "study-minimal",
  "title": "Minimal mood study",
  "description": "Daily mood tracking with one reminder window.",
  "user_id": "researcher-user-id",
  "participation": "invite",
  "result_sharing": "private",
  "contact": {"email": "researcher@example.org"},
  "status": "draft",
  "consent": [
    {
      "id": "consent-main",
      "title": "Consent",
      "description": "I agree to participate."
    }
  ],
  "interventions": [
    {
      "type": "intervention",
      "id": "arm-a",
      "name": "Daily reflection",
      "description": "Participants complete one short daily check-in.",
      "icon": "editNote",
      "tasks": [
        {
          "type": "checkmark",
          "id": "reflection-checkmark",
          "title": "Complete reflection",
          "schedule": {
            "completionPeriods": [
              {"id": "evening", "unlockTime": "18:00", "lockTime": "22:00"}
            ],
            "reminders": ["19:00"]
          }
        }
      ]
    }
  ],
  "observations": [
    {
      "type": "questionnaire",
      "id": "daily-mood-task",
      "title": "Daily mood",
      "schedule": {
        "completionPeriods": [
          {"id": "evening", "unlockTime": "18:00", "lockTime": "22:00"}
        ],
        "reminders": ["19:00"]
      },
      "questions": [
        {"type": "boolean", "id": "had-good-day", "prompt": "Did you have a good day?"},
        {
          "type": "scale",
          "id": "mood-score",
          "prompt": "How was your mood today?",
          "minimum": 1,
          "maximum": 5,
          "step": 1,
          "conditional": {
            "condition": {
              "type": "composite",
              "logicType": "and",
              "expressions": [{"type": "boolean", "target": "had-good-day"}]
            }
          }
        }
      ]
    }
  ],
  "schedule": {
    "numberOfCycles": 1,
    "phaseDuration": 7,
    "includeBaseline": false,
    "sequence": "alternating",
    "sequenceCustom": "ABAB"
  },
  "results": [
    {
      "type": "numeric",
      "id": "mood-result",
      "filename": "mood.csv",
      "resultProperty": {"task": "daily-mood-task", "property": "mood-score"}
    }
  ],
  "report_specification": {
    "primary": {
      "type": "average",
      "id": "mood-average",
      "title": "Average mood",
      "description": "Average mood by study day.",
      "aggregate": "day",
      "resultProperty": {"task": "daily-mood-task", "property": "mood-score"}
    },
    "secondary": []
  }
}
'''
        .trim(),
  );
  buf.writeln('```');
  buf.writeln();
  buf.writeln(
    '`DataReference.task` points to a task ID. `DataReference.property` points '
    'to a question ID inside that task.',
  );
}

List<LinkEntry> _buildExpectedLinkEntries(
  List<String> targetPaths,
  String currentPagePath,
) {
  return targetPaths.map((target) {
    final relHref = _relativeLink(currentPagePath, target);
    final label = _pageLabelFromPath(target);
    return LinkEntry(label: label, href: relHref);
  }).toList();
}

String _relativeLink(String from, String to) {
  final fromDir = p.dirname(from);
  return p.posix.relative(to, from: fromDir);
}

String _pageLabelFromPath(String pagePath) {
  final name = p.basenameWithoutExtension(pagePath);
  return name
      .split('-')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

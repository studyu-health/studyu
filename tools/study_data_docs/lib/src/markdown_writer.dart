/// Reads and writes markdown files, preserving human prose while replacing
/// generated blocks.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:study_data_docs/src/doc_metadata.dart';
import 'package:study_data_docs/src/generated_block.dart';
import 'package:study_data_docs/src/model_scanner.dart';
import 'package:study_data_docs/src/page_scope.dart';

/// Creates or updates a markdown page for the given [pagePath].
///
/// If the file does not exist, a skeleton is written. If it exists, only the
/// GENERATED:* blocks are updated; all other content is preserved.
bool writePage({
  required String docsDir,
  required String pagePath,
  required PageMeta meta,
  required List<ScannedClass> classes,
  required Map<String, ScannedClass> allClasses,
  required Map<String, String> typeLinks,
}) {
  final absPath = p.join(docsDir, pagePath);
  final file = File(absPath);

  Directory(p.dirname(absPath)).createSync(recursive: true);

  String existing = file.existsSync() ? file.readAsStringSync() : '';
  final original = existing;

  if (existing.isEmpty) {
    existing = _skeleton(meta);
  }

  // Remove the placeholder comment from previously generated files.
  existing = existing.replaceAll('\n<!-- Human prose goes here. -->\n', '\n');
  existing = existing.replaceAll('<!-- Human prose goes here. -->\n', '');

  final scopeEntries = entriesForPage(pagePath);
  final generatedFieldBlocks = buildExpectedFieldBlocks(
    scopeEntries: scopeEntries,
    classes: classes,
    meta: meta,
    typeLinks: typeLinks,
    currentPagePath: pagePath,
  );
  for (final entry in generatedFieldBlocks.entries) {
    existing = replaceBlock(
      existing: existing,
      kind: entry.key,
      newContent: buildFieldsTable(entry.value),
    );
  }

  // Build discriminator block. Dispatcher entries collect all subtype values;
  // concrete entries use their own discriminatorValues.
  final discriminators = _buildDiscriminatorEntries(
    scopeEntries: scopeEntries,
    classes: classes,
    allClasses: allClasses,
  );
  if (discriminators.isNotEmpty) {
    existing = replaceBlock(
      existing: existing,
      kind: 'DISCRIMINATORS',
      newContent: buildDiscriminatorsBlock(discriminators),
    );
  }

  if (meta.links.isNotEmpty) {
    final linkEntries = _buildLinkEntries(meta.links, pagePath);
    existing = replaceBlock(
      existing: existing,
      kind: 'LINKS',
      newContent: buildLinksBlock(linkEntries),
    );
  }

  if (existing == original) return false;
  file.writeAsStringSync(existing);
  return true;
}

/// Builds a skeleton for a new page with required human-owned prose.
String _skeleton(PageMeta meta) {
  final buf = StringBuffer();
  buf.writeln('# ${meta.title}');
  buf.writeln();
  buf.writeln('## Description');
  buf.writeln();
  buf.writeln('TODO: Describe this page.');
  buf.writeln();
  return buf.toString();
}

Map<String, List<FieldRow>> _buildFieldBlocks({
  required List<PageScopeEntry> scopeEntries,
  required List<ScannedClass> classes,
  required PageMeta meta,
  required Map<String, String> typeLinks,
  required String currentPagePath,
}) {
  final classesByName = {for (final cls in classes) cls.name: cls};
  final result = <String, List<FieldRow>>{};

  for (final entry in scopeEntries.where((entry) => entry.generatedFields)) {
    final cls = classesByName[entry.className];
    if (cls == null) continue;
    final rows = _buildFieldRows(
      cls,
      meta,
      typeLinks,
      currentPagePath,
      includeVirtualFields: entry.fieldsBlock == 'FIELDS',
    );
    result.putIfAbsent(entry.fieldsBlock, () => <FieldRow>[]).addAll(rows);
  }

  return result;
}

List<FieldRow> _buildFieldRows(
  ScannedClass cls,
  PageMeta meta,
  Map<String, String> typeLinks,
  String currentPagePath, {
  required bool includeVirtualFields,
}) {
  final rows = <FieldRow>[];
  final seen = <String>{};

  for (final field in cls.fields) {
    if (!field.includeInJson) continue;
    if (seen.contains(field.jsonKey)) continue;
    if (meta.ignoredFields.contains(field.name) ||
        meta.ignoredFields.contains(field.jsonKey)) {
      continue;
    }
    seen.add(field.jsonKey);

    final fieldMeta = meta.fields[field.name] ?? meta.fields[field.jsonKey];
    final description = fieldMeta?.description ?? '';

    rows.add(
      FieldRow(
        dartName: field.name,
        jsonKey: field.jsonKey,
        dartType: field.dartType,
        required: field.required,
        description: description,
        defaultValue: field.defaultValue,
        typeHref: _typeHref(field.dartType, typeLinks, currentPagePath),
      ),
    );
  }

  if (includeVirtualFields) {
    for (final fieldMeta in meta.fields.values) {
      if (!fieldMeta.virtual || seen.contains(fieldMeta.name)) continue;
      rows.add(
        FieldRow(
          dartName: fieldMeta.name,
          jsonKey: fieldMeta.name,
          dartType: fieldMeta.type ?? 'unknown',
          required: fieldMeta.required,
          description: fieldMeta.description,
          typeHref: _typeHref(
            fieldMeta.type ?? 'unknown',
            typeLinks,
            currentPagePath,
          ),
        ),
      );
    }
  }

  return rows;
}

String? _typeHref(
  String dartType,
  Map<String, String> typeLinks,
  String currentPagePath,
) {
  final combinedTypeLinks = {...inferredTypeLinks, ...typeLinks};
  for (final typeName in _candidateTypeNames(dartType)) {
    final target = combinedTypeLinks[typeName];
    if (target != null) return _relativeLink(currentPagePath, target);
  }
  return null;
}

Iterable<String> _candidateTypeNames(String dartType) sync* {
  final withoutNullability = dartType.replaceAll('?', '');
  yield withoutNullability;
  final genericMatch = RegExp(
    r'^([^<]+)<(.+)>$',
  ).firstMatch(withoutNullability);
  if (genericMatch != null) {
    yield genericMatch.group(1)!.trim();
    final inner = genericMatch.group(2)!.trim();
    yield inner;
    yield* _candidateTypeNames(inner);
  }
}

/// Builds the discriminator entries for the GENERATED:DISCRIMINATORS block.
///
/// For abstract dispatcher entries (those with [PageScopeEntry.dispatcherField]
/// set), collects all concrete subtype wire values from [allClasses].
///
/// For concrete entries, uses each class's own [ScannedClass.discriminatorValues].
///
/// Returns a `Map<String, Object>` where values are either `String` (concrete)
/// or `Set<String>` (dispatcher). See [buildDiscriminatorsBlock].
Map<String, Object> _buildDiscriminatorEntries({
  required List<PageScopeEntry> scopeEntries,
  required List<ScannedClass> classes,
  required Map<String, ScannedClass> allClasses,
}) {
  final result = <String, Object>{};

  for (final entry in scopeEntries) {
    if (entry.dispatcherField != null) {
      // Abstract dispatcher: collect wire values from concrete classes whose
      // page lives in the same directory subtree as this dispatcher's page.
      final dispatcherDir = p.posix.dirname(entry.pagePath);
      final field = entry.dispatcherField!;
      final values = <String>{};

      for (final cls in allClasses.values) {
        final wire = cls.discriminatorValues[field];
        if (wire == null || wire.isEmpty) continue;

        if (entry.excludedDispatcherValues.contains(wire)) continue;

        // Only include concrete classes whose doc page is under the same
        // directory (or any subdir) as the dispatcher page.
        final clsEntry = kPageScope
            .where((e) => e.className == cls.name)
            .firstOrNull;
        if (clsEntry == null) continue;
        final clsDir = p.posix.dirname(clsEntry.pagePath);
        if (clsDir == dispatcherDir || clsDir.startsWith('$dispatcherDir/')) {
          values.add(wire);
        }
      }

      if (values.isNotEmpty) {
        final existing = result[field];
        if (existing is Set<String>) {
          existing.addAll(values);
        } else {
          result[field] = values;
        }
      }
    }
  }

  // Add concrete discriminators from the scanned classes on this page.
  for (final cls in classes) {
    for (final e in cls.discriminatorValues.entries) {
      if (!result.containsKey(e.key)) {
        result[e.key] = e.value;
      }
    }
  }

  return result;
}

List<LinkEntry> _buildLinkEntries(
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

/// Helpers reused by [cli.dart] for drift checking.
Map<String, List<FieldRow>> buildExpectedFieldBlocks({
  required List<PageScopeEntry> scopeEntries,
  required List<ScannedClass> classes,
  required PageMeta meta,
  required Map<String, String> typeLinks,
  required String currentPagePath,
}) => _buildFieldBlocks(
  scopeEntries: scopeEntries,
  classes: classes,
  meta: meta,
  typeLinks: typeLinks,
  currentPagePath: currentPagePath,
);

Map<String, Object> buildExpectedDiscriminatorEntries({
  required List<PageScopeEntry> scopeEntries,
  required List<ScannedClass> classes,
  required Map<String, ScannedClass> allClasses,
}) => _buildDiscriminatorEntries(
  scopeEntries: scopeEntries,
  classes: classes,
  allClasses: allClasses,
);

/// Manages GENERATED:* block markers inside markdown files.
///
/// Block format:
///   <!-- GENERATED:FIELDS START -->
///   ...content...
///   <!-- GENERATED:FIELDS END -->
///
/// Content between markers is replaced on every `--write` run. Content
/// outside the markers is preserved unchanged.
library;

/// Returns the start marker for [kind].
String startMarker(String kind) => '<!-- GENERATED:$kind START -->';

/// Returns the end marker for [kind].
String endMarker(String kind) => '<!-- GENERATED:$kind END -->';

/// Replaces the content of a named generated block inside [existing] markdown.
///
/// If the block does not exist, it is appended at the end.
/// Returns the updated markdown string.
String replaceBlock({
  required String existing,
  required String kind,
  required String newContent,
}) {
  final start = startMarker(kind);
  final end = endMarker(kind);

  final startIdx = existing.indexOf(start);
  final endIdx = existing.indexOf(end);

  if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
    final before = existing.substring(0, startIdx + start.length);
    final after = existing.substring(endIdx);
    return '$before\n$newContent\n$after';
  }

  // Block absent: append it.
  final trimmed = existing.trimRight();
  return '$trimmed\n\n$start\n$newContent\n$end\n';
}

/// Extracts the raw content between markers for [kind] in [markdown].
///
/// Returns null if the block is absent.
String? extractBlock(String markdown, String kind) {
  final start = startMarker(kind);
  final end = endMarker(kind);

  final startIdx = markdown.indexOf(start);
  final endIdx = markdown.indexOf(end);

  if (startIdx == -1 || endIdx == -1 || endIdx <= startIdx) return null;
  return markdown.substring(startIdx + start.length, endIdx).trim();
}

/// Checks that [markdown] contains all required generated blocks for a page
/// that expects [kinds].
List<String> missingBlocks(String markdown, Iterable<String> kinds) =>
    kinds.where((k) => !markdown.contains(startMarker(k))).toList();

/// Builds a GENERATED:FIELDS block body.
///
/// The Field column shows `field` when the Dart name and JSON key are the same,
/// or `field (json_key)` when they differ — making the wire contract visible
/// without a separate column.
///
/// A Default column is included only when at least one row has a default value.
String buildFieldsTable(List<FieldRow> rows) {
  if (rows.isEmpty) {
    return '_No JSON-serialisable fields._';
  }

  final hasDefaults = rows.any((r) => r.defaultValue != null);

  final buf = StringBuffer();
  if (hasDefaults) {
    buf.writeln('| Field | Type | Required | Default | Description |');
    buf.writeln('|-------|------|----------|---------|-------------|');
  } else {
    buf.writeln('| Field | Type | Required | Description |');
    buf.writeln('|-------|------|----------|-------------|');
  }

  for (final row in rows) {
    final fieldLabel = row.fieldLabel;
    final req = row.required ? 'Yes' : 'No';
    if (hasDefaults) {
      final def = row.defaultValue != null ? '`${row.defaultValue}`' : '-';
      buf.writeln(
        '| `$fieldLabel` | ${row.typeLabel} | $req | $def | ${row.description} |',
      );
    } else {
      buf.writeln(
        '| `$fieldLabel` | ${row.typeLabel} | $req | ${row.description} |',
      );
    }
  }
  return buf.toString().trimRight();
}

/// Builds a GENERATED:DISCRIMINATORS block body.
///
/// For concrete classes: maps discriminator field → single wire value.
/// For abstract dispatcher pages: maps discriminator field → sorted set of
/// all known wire values from concrete subclasses.
String buildDiscriminatorsBlock(Map<String, Object> entries) {
  if (entries.isEmpty) return '_No discriminator values._';

  final buf = StringBuffer();
  buf.writeln('| Field | Value(s) |');
  buf.writeln('|-------|---------|');

  for (final entry in entries.entries) {
    final value = entry.value;
    if (value is String) {
      buf.writeln('| `${entry.key}` | `$value` |');
    } else if (value is Set<String>) {
      final sorted = value.toList()..sort();
      buf.writeln(
        '| `${entry.key}` | ${sorted.map((v) => '`$v`').join(', ')} |',
      );
    }
  }
  return buf.toString().trimRight();
}

/// Builds a GENERATED:LINKS block body.
String buildLinksBlock(List<LinkEntry> links) {
  if (links.isEmpty) return '_No cross-references._';

  final buf = StringBuffer();
  for (final link in links) {
    buf.writeln('- [${link.label}](${link.href})');
  }
  return buf.toString().trimRight();
}

class FieldRow {
  final String dartName; // Dart field name
  final String jsonKey; // wire JSON key
  final String dartType;
  final bool required;
  final String description;
  final String? defaultValue;
  final String? typeHref;

  const FieldRow({
    required this.dartName,
    required this.jsonKey,
    required this.dartType,
    required this.required,
    required this.description,
    this.defaultValue,
    this.typeHref,
  });

  /// Display label: `field` when names match, `field (json_key)` when they differ.
  String get fieldLabel =>
      dartName == jsonKey ? dartName : '$dartName ($jsonKey)';

  String get typeLabel {
    final escaped = _escapeType(dartType);
    if (typeHref == null) return '`$escaped`';
    return '[`$escaped`]($typeHref)';
  }
}

class LinkEntry {
  final String label;
  final String href;

  const LinkEntry({required this.label, required this.href});
}

String _escapeType(String type) => type.replaceAll('|', '\\|');

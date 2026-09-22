import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:study_data_docs/src/doc_metadata.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('doc_metadata_test_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  String writeMeta(String yaml) {
    final file = File(p.join(tmp.path, '_metadata.yaml'));
    file.writeAsStringSync(yaml);
    return file.path;
  }

  group('DocMetadata.empty', () {
    test('has no pages', () {
      final meta = DocMetadata.empty();
      expect(meta.allPagePaths, isEmpty);
    });
  });

  group('DocMetadata.load', () {
    test('returns empty when file missing', () {
      final meta = DocMetadata.load(p.join(tmp.path, 'nonexistent.yaml'));
      expect(meta.allPagePaths, isEmpty);
    });

    test('parses pages, titles, and fields', () {
      final path = writeMeta('''
pages:
  study/index.md:
    title: Study
    fields:
      id: Unique identifier.
      title: Display title.
''');
      final meta = DocMetadata.load(path);
      expect(meta.allPagePaths, contains('study/index.md'));
      final page = meta.page('study/index.md')!;
      expect(page.title, 'Study');
      expect(page.fields['id']!.description, 'Unique identifier.');
      expect(page.fields['title']!.description, 'Display title.');
    });

    test('parses ignoredFields', () {
      final path = writeMeta('''
pages:
  study/index.md:
    title: Study
    ignored_fields: [published, createdAt]
    fields: {}
''');
      final meta = DocMetadata.load(path);
      expect(
        meta.page('study/index.md')!.ignoredFields,
        containsAll(['published', 'createdAt']),
      );
    });

    test('parses links', () {
      final path = writeMeta('''
pages:
  study/index.md:
    title: Study
    links:
      - study/contact.md
    fields: {}
''');
      final meta = DocMetadata.load(path);
      expect(meta.page('study/index.md')!.links, contains('study/contact.md'));
    });

    test('parses type links', () {
      final path = writeMeta('''
type_links:
  QuestionConditional: shared/question-conditional.md
pages:
  study/index.md:
    title: Study
    fields: {}
''');
      final meta = DocMetadata.load(path);
      expect(
        meta.typeLinks['QuestionConditional'],
        'shared/question-conditional.md',
      );
    });

    test('parses virtual fields', () {
      final path = writeMeta('''
pages:
  shared/data-reference.md:
    title: Data Reference
    fields:
      task: Task ID.
      extra:
        description: Extra virtual field.
        virtual: true
        type: String
''');
      final meta = DocMetadata.load(path);
      final fields = meta.page('shared/data-reference.md')!.fields;
      expect(fields['task']!.virtual, isFalse);
      expect(fields['extra']!.virtual, isTrue);
      expect(fields['extra']!.type, 'String');
    });

    test('parses manual pages', () {
      final path = writeMeta('''
manual_pages:
  shared/enums.md:
    title: Enum Values
''');
      final meta = DocMetadata.load(path);
      expect(meta.manualPagePaths, contains('shared/enums.md'));
      expect(meta.page('shared/enums.md')!.manual, isTrue);
    });
  });

  group('writeMetadataStubs', () {
    test('preserves structured fields and manual pages', () {
      final path = writeMeta('''
type_links:
  DataReference: shared/data-reference.md
pages:
  shared/data-reference.md:
    title: Data Reference
    fields:
      extra:
        description: Extra virtual field.
        virtual: true
        type: String
        required: true
manual_pages:
  shared/enums.md:
    title: Enum Values
''');

      writeMetadataStubs(metadataPath: path, stubs: const []);

      final meta = DocMetadata.load(path);
      final extra = meta.page('shared/data-reference.md')!.fields['extra']!;
      expect(extra.description, 'Extra virtual field.');
      expect(extra.virtual, isTrue);
      expect(extra.type, 'String');
      expect(extra.required, isTrue);
      expect(meta.typeLinks['DataReference'], 'shared/data-reference.md');
      expect(meta.manualPagePaths, contains('shared/enums.md'));
    });
  });
}

import 'package:study_data_docs/src/doc_metadata.dart';
import 'package:study_data_docs/src/generated_block.dart';
import 'package:study_data_docs/src/markdown_writer.dart';
import 'package:study_data_docs/src/model_scanner.dart';
import 'package:study_data_docs/src/page_scope.dart';
import 'package:test/test.dart';

void main() {
  group('replaceBlock', () {
    test('replaces content between existing markers', () {
      final existing = [
        '# Title',
        '',
        '<!-- GENERATED:FIELDS START -->',
        'old content',
        '<!-- GENERATED:FIELDS END -->',
        '',
        'Some prose.',
        '',
      ].join('\n');

      final result = replaceBlock(
        existing: existing,
        kind: 'FIELDS',
        newContent: 'new content',
      );

      expect(result, contains('new content'));
      expect(result, isNot(contains('old content')));
      expect(result, contains('Some prose.'));
    });

    test('appends block when absent', () {
      const existing = '# Title\n\nSome prose.\n';
      final result = replaceBlock(
        existing: existing,
        kind: 'FIELDS',
        newContent: 'new content',
      );

      expect(result, contains('<!-- GENERATED:FIELDS START -->'));
      expect(result, contains('<!-- GENERATED:FIELDS END -->'));
      expect(result, contains('new content'));
      expect(result, contains('Some prose.'));
    });
  });

  group('extractBlock', () {
    test('extracts content between markers', () {
      final markdown = [
        '# Title',
        '',
        '<!-- GENERATED:FIELDS START -->',
        '| Field | Type |',
        '|-------|------|',
        '| id | String |',
        '<!-- GENERATED:FIELDS END -->',
        '',
      ].join('\n');

      final content = extractBlock(markdown, 'FIELDS');
      expect(content, isNotNull);
      expect(content, contains('| id | String |'));
    });

    test('returns null when block absent', () {
      const markdown = '# Title\n\nNo blocks here.\n';
      expect(extractBlock(markdown, 'FIELDS'), isNull);
    });
  });

  group('buildFieldsTable', () {
    test('emits markdown table rows', () {
      final rows = [
        const FieldRow(
          dartName: 'id',
          jsonKey: 'id',
          dartType: 'String',
          required: true,
          description: 'Unique identifier.',
        ),
        const FieldRow(
          dartName: 'title',
          jsonKey: 'title',
          dartType: 'String?',
          required: false,
          description: 'Display title.',
        ),
      ];
      final table = buildFieldsTable(rows);
      expect(table, contains('| `id` |'));
      expect(table, contains('| `title` |'));
      expect(table, contains('Yes'));
      expect(table, contains('No'));
    });

    test('links type labels when type href is present', () {
      const rows = [
        FieldRow(
          dartName: 'conditional',
          jsonKey: 'conditional',
          dartType: 'QuestionConditional<V>?',
          required: false,
          description: 'Optional display condition.',
          typeHref: '../shared/question-conditional.md',
        ),
      ];
      final table = buildFieldsTable(rows);
      expect(
        table,
        contains(
          '[`QuestionConditional<V>?`](../shared/question-conditional.md)',
        ),
      );
    });

    test('returns placeholder for empty rows', () {
      final table = buildFieldsTable([]);
      expect(table, contains('No JSON-serialisable fields'));
    });
  });

  group('FieldRow.fieldLabel', () {
    test('shows dart name only when names match', () {
      const row = FieldRow(
        dartName: 'userId',
        jsonKey: 'userId',
        dartType: 'String',
        required: true,
        description: '',
      );
      expect(row.fieldLabel, 'userId');
    });

    test('shows dart name and json key when they differ', () {
      const row = FieldRow(
        dartName: 'userId',
        jsonKey: 'user_id',
        dartType: 'String',
        required: true,
        description: '',
      );
      expect(row.fieldLabel, 'userId (user_id)');
    });
  });

  group('buildFieldsTable with defaults', () {
    test('includes Default column when any row has a default', () {
      final rows = [
        const FieldRow(
          dartName: 'count',
          jsonKey: 'count',
          dartType: 'int',
          required: false,
          description: 'Item count.',
          defaultValue: '0',
        ),
      ];
      final table = buildFieldsTable(rows);
      expect(table, contains('Default'));
      expect(table, contains('`0`'));
    });

    test('omits Default column when no row has a default', () {
      final rows = [
        const FieldRow(
          dartName: 'id',
          jsonKey: 'id',
          dartType: 'String',
          required: true,
          description: 'ID.',
        ),
      ];
      final table = buildFieldsTable(rows);
      expect(table, isNot(contains('Default')));
    });
  });

  group('buildExpectedFieldBlocks', () {
    test('keeps nested class fields in a class-specific block', () {
      const meta = PageMeta(
        path: 'schedules/task-schedule.md',
        title: 'Schedule',
        fields: {
          'completionPeriods': FieldMeta(
            name: 'completionPeriods',
            description: 'Completion windows.',
          ),
          'reminders': FieldMeta(
            name: 'reminders',
            description: 'Reminder times.',
          ),
          'id': FieldMeta(name: 'id', description: 'Period ID.'),
          'unlockTime': FieldMeta(
            name: 'unlockTime',
            description: 'Opening time.',
          ),
          'lockTime': FieldMeta(name: 'lockTime', description: 'Closing time.'),
        },
      );

      final blocks = buildExpectedFieldBlocks(
        scopeEntries: const [
          PageScopeEntry(
            className: 'Schedule',
            pagePath: 'schedules/task-schedule.md',
          ),
          PageScopeEntry(
            className: 'CompletionPeriod',
            pagePath: 'schedules/task-schedule.md',
            fieldsBlock: 'FIELDS:CompletionPeriod',
          ),
        ],
        classes: const [
          ScannedClass(
            name: 'Schedule',
            sourceFile: 'core/lib/src/models/tasks/schedule.dart',
            fields: [
              ScannedField(
                name: 'completionPeriods',
                dartType: 'List<CompletionPeriod>',
                jsonKey: 'completionPeriods',
                required: false,
                nullable: false,
              ),
              ScannedField(
                name: 'reminders',
                dartType: 'List<StudyUTimeOfDay>',
                jsonKey: 'reminders',
                required: false,
                nullable: false,
              ),
            ],
          ),
          ScannedClass(
            name: 'CompletionPeriod',
            sourceFile: 'core/lib/src/models/tasks/schedule.dart',
            fields: [
              ScannedField(
                name: 'id',
                dartType: 'String',
                jsonKey: 'id',
                required: true,
                nullable: false,
              ),
              ScannedField(
                name: 'unlockTime',
                dartType: 'StudyUTimeOfDay',
                jsonKey: 'unlockTime',
                required: true,
                nullable: false,
              ),
              ScannedField(
                name: 'lockTime',
                dartType: 'StudyUTimeOfDay',
                jsonKey: 'lockTime',
                required: true,
                nullable: false,
              ),
            ],
          ),
        ],
        meta: meta,
        typeLinks: const {},
        currentPagePath: 'schedules/task-schedule.md',
      );

      expect(blocks['FIELDS']!.map((row) => row.dartName), [
        'completionPeriods',
        'reminders',
      ]);
      expect(blocks['FIELDS:CompletionPeriod']!.map((row) => row.dartName), [
        'id',
        'unlockTime',
        'lockTime',
      ]);
    });

    test('keeps body pain shared class names in separate fields blocks', () {
      const meta = PageMeta(
        path: 'questionnaire/question-types/body-pain.md',
        title: 'Body Pain Models',
        fields: {
          'painLevel': FieldMeta(
            name: 'painLevel',
            description: 'Numeric pain intensity value for a body part.',
          ),
          'type': FieldMeta(
            name: 'type',
            description: 'Pain type identifier string.',
          ),
          'id': FieldMeta(name: 'id', description: 'Unique identifier.'),
          'name': FieldMeta(
            name: 'name',
            description: 'Display name of the body part or pain type.',
          ),
          'pain': FieldMeta(
            name: 'pain',
            description: 'Pain record associated with a body region.',
          ),
          'children': FieldMeta(
            name: 'children',
            description: 'Child body parts nested within this body region.',
          ),
          'parts': FieldMeta(
            name: 'parts',
            description: 'List of body parts making up this body model.',
          ),
        },
      );

      final blocks = buildExpectedFieldBlocks(
        scopeEntries: const [
          PageScopeEntry(
            className: 'BodyPain',
            pagePath: 'questionnaire/question-types/body-pain.md',
          ),
          PageScopeEntry(
            className: 'BodyPart',
            pagePath: 'questionnaire/question-types/body-pain.md',
            fieldsBlock: 'FIELDS:BodyPart',
          ),
          PageScopeEntry(
            className: 'Body',
            pagePath: 'questionnaire/question-types/body-pain.md',
            fieldsBlock: 'FIELDS:Body',
          ),
          PageScopeEntry(
            className: 'PainType',
            pagePath: 'questionnaire/question-types/body-pain.md',
            fieldsBlock: 'FIELDS:PainType',
          ),
        ],
        classes: const [
          ScannedClass(
            name: 'BodyPain',
            sourceFile: 'core/lib/src/models/questionnaire/body_pain.dart',
            fields: [
              ScannedField(
                name: 'painLevel',
                dartType: 'int',
                jsonKey: 'painLevel',
                required: true,
                nullable: false,
              ),
              ScannedField(
                name: 'type',
                dartType: 'PainType?',
                jsonKey: 'type',
                required: false,
                nullable: true,
              ),
            ],
          ),
          ScannedClass(
            name: 'BodyPart',
            sourceFile: 'core/lib/src/models/questionnaire/body_pain.dart',
            fields: [
              ScannedField(
                name: 'id',
                dartType: 'String',
                jsonKey: 'id',
                required: true,
                nullable: false,
              ),
              ScannedField(
                name: 'name',
                dartType: 'String',
                jsonKey: 'name',
                required: true,
                nullable: false,
              ),
              ScannedField(
                name: 'pain',
                dartType: 'BodyPain',
                jsonKey: 'pain',
                required: true,
                nullable: false,
              ),
              ScannedField(
                name: 'children',
                dartType: 'List<BodyPart>',
                jsonKey: 'children',
                required: true,
                nullable: false,
                defaultValue: 'const []',
              ),
            ],
          ),
          ScannedClass(
            name: 'Body',
            sourceFile: 'core/lib/src/models/questionnaire/body_pain.dart',
            fields: [
              ScannedField(
                name: 'parts',
                dartType: 'List<BodyPart>',
                jsonKey: 'parts',
                required: true,
                nullable: false,
                defaultValue: 'const []',
              ),
            ],
          ),
          ScannedClass(
            name: 'PainType',
            sourceFile: 'core/lib/src/models/questionnaire/body_pain.dart',
            fields: [
              ScannedField(
                name: 'name',
                dartType: 'String',
                jsonKey: 'name',
                required: true,
                nullable: false,
              ),
            ],
          ),
        ],
        meta: meta,
        typeLinks: const {},
        currentPagePath: 'questionnaire/question-types/body-pain.md',
      );

      expect(blocks['FIELDS']!.map((row) => row.dartName), [
        'painLevel',
        'type',
      ]);
      expect(blocks['FIELDS:BodyPart']!.map((row) => row.dartName), [
        'id',
        'name',
        'pain',
        'children',
      ]);
      expect(blocks['FIELDS:Body']!.map((row) => row.dartName), ['parts']);
      expect(blocks['FIELDS:PainType']!.map((row) => row.dartName), ['name']);
    });
  });

  group('buildDiscriminatorsBlock', () {
    test('emits discriminator table for concrete class', () {
      final block = buildDiscriminatorsBlock({'type': 'boolean'});
      expect(block, contains('| `type` | `boolean` |'));
    });

    test('emits sorted multi-value row for dispatcher page', () {
      final block = buildDiscriminatorsBlock({
        'type': {'scale', 'boolean', 'choice'},
      });
      expect(block, contains('`boolean`'));
      expect(block, contains('`choice`'));
      expect(block, contains('`scale`'));
      // Values appear in sorted order.
      final boolIdx = block.indexOf('`boolean`');
      final choiceIdx = block.indexOf('`choice`');
      final scaleIdx = block.indexOf('`scale`');
      expect(boolIdx, lessThan(choiceIdx));
      expect(choiceIdx, lessThan(scaleIdx));
    });

    test('returns placeholder for empty map', () {
      final block = buildDiscriminatorsBlock({});
      expect(block, contains('No discriminator'));
    });
  });

  group('buildLinksBlock', () {
    test('emits list of links', () {
      final block = buildLinksBlock([
        const LinkEntry(label: 'Study', href: '../study/index.md'),
      ]);
      expect(block, contains('[Study](../study/index.md)'));
    });

    test('returns placeholder for empty list', () {
      final block = buildLinksBlock([]);
      expect(block, contains('No cross-references'));
    });
  });
}

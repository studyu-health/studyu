import 'package:study_data_docs/src/generated_block.dart';
import 'package:study_data_docs/src/markdown_writer.dart';
import 'package:study_data_docs/src/model_scanner.dart';
import 'package:study_data_docs/src/page_scope.dart';
import 'package:test/test.dart';

void main() {
  group('scopeFor', () {
    test('returns entry for in-scope class', () {
      final entry = scopeFor('Study');
      expect(entry, isNotNull);
      expect(entry!.pagePath, equals('study/index.md'));
    });

    test('returns null for excluded class', () {
      expect(scopeFor('Task'), isNull);
      expect(scopeFor('TaskInstance'), isNull);
    });

    test('returns null for unknown class', () {
      expect(scopeFor('SomeRandomClass'), isNull);
    });
  });

  group('entriesForPage', () {
    test('returns all entries for a multi-class page', () {
      final entries = entriesForPage('shared/expressions.md');
      expect(entries.length, greaterThan(3));
      final names = entries.map((e) => e.className).toSet();
      expect(names, contains('Expression'));
      expect(names, contains('BooleanExpression'));
      expect(names, contains('CompositeExpression'));
    });

    test('questionnaire index includes container and dispatcher entries', () {
      final entries = entriesForPage('questionnaire/index.md');
      final names = entries.map((e) => e.className).toSet();
      expect(names, contains('StudyUQuestionnaire'));
      expect(names, contains('Question'));
    });

    test('returns single entry for single-class page', () {
      final entries = entriesForPage('study/index.md');
      expect(entries.length, equals(1));
      expect(entries.first.className, equals('Study'));
    });
  });

  group('allPagePaths', () {
    test('contains expected paths', () {
      final paths = allPagePaths;
      expect(paths, contains('study/index.md'));
      expect(paths, contains('questionnaire/question-types/scale.md'));
      expect(paths, contains('reports/sections/average.md'));
      expect(paths, contains('shared/expressions.md'));
      expect(paths, isNot(contains('questionnaire/question.md')));
    });

    test('does not contain excluded class pages', () {
      final paths = allPagePaths;
      for (final path in paths) {
        expect(path, isNot(contains('task_instance')));
      }
    });
  });

  group('inferredTypeLinks', () {
    test('contains generated classes and abstract aliases', () {
      expect(inferredTypeLinks['DataReference'], 'shared/data-reference.md');
      expect(
        inferredTypeLinks['InterventionTask'],
        'interventions/checkmark-task.md',
      );
      expect(
        inferredTypeLinks['ReportSection'],
        'reports/report-specification.md',
      );
    });
  });

  group('PageScopeEntry flags', () {
    test('StudyUQuestionnaire has generatedFields: false', () {
      final entry = scopeFor('StudyUQuestionnaire');
      expect(entry, isNotNull);
      expect(entry!.generatedFields, isFalse);
    });

    test('Question has dispatcherField set to type', () {
      final entry = scopeFor('Question');
      expect(entry, isNotNull);
      expect(entry!.dispatcherField, 'type');
    });

    test('Expression has dispatcherField set to type', () {
      final entry = scopeFor('Expression');
      expect(entry, isNotNull);
      expect(entry!.dispatcherField, 'type');
    });

    test('expression page owns its exceptional no-fields behavior', () {
      expect(
        entriesForPage(
          'shared/expressions.md',
        ).every((entry) => !entry.generatedFields),
        isTrue,
      );
    });

    test('Expression excludes composite from dispatcher docs', () {
      final entry = scopeFor('Expression');
      expect(entry, isNotNull);
      expect(entry!.excludedDispatcherValues, contains('composite'));
    });

    test('Expression dispatcher docs omit excluded composite value', () {
      final block = buildDiscriminatorsBlock(
        buildExpectedDiscriminatorEntries(
          scopeEntries: entriesForPage('shared/expressions.md'),
          classes: const [],
          allClasses: const {
            'BooleanExpression': ScannedClass(
              name: 'BooleanExpression',
              sourceFile:
                  'core/lib/src/models/expressions/types/boolean_expression.dart',
              fields: [],
              discriminatorValues: {'type': 'boolean'},
            ),
            'CompositeExpression': ScannedClass(
              name: 'CompositeExpression',
              sourceFile:
                  'core/lib/src/models/expressions/types/composite_expression.dart',
              fields: [],
              discriminatorValues: {'type': 'composite'},
            ),
          },
        ),
      );

      expect(block, contains('`boolean`'));
      expect(block, isNot(contains('`composite`')));
    });

    test('BooleanQuestion has no dispatcherField', () {
      final entry = scopeFor('BooleanQuestion');
      expect(entry, isNotNull);
      expect(entry!.dispatcherField, isNull);
    });

    test('CompletionPeriod uses a class-specific fields block', () {
      final entry = scopeFor('CompletionPeriod');
      expect(entry, isNotNull);
      expect(entry!.pagePath, 'schedules/task-schedule.md');
      expect(entry.fieldsBlock, 'FIELDS:CompletionPeriod');
    });
  });
}

import 'dart:io';

import 'package:study_data_docs/src/model_scanner.dart';
import 'package:test/test.dart';

void main() {
  group('buildDispatcherDiscriminators', () {
    final allClasses = {
      'BooleanQuestion': const ScannedClass(
        name: 'BooleanQuestion',
        sourceFile: 'core/lib/src/models/questionnaire/boolean_question.dart',
        fields: [],
        discriminatorValues: {'type': 'boolean'},
        superTypes: {'Question'},
      ),
      'ChoiceQuestion': const ScannedClass(
        name: 'ChoiceQuestion',
        sourceFile: 'core/lib/src/models/questionnaire/choice_question.dart',
        fields: [],
        discriminatorValues: {'type': 'choice'},
        superTypes: {'Question'},
      ),
      'ScaleQuestion': const ScannedClass(
        name: 'ScaleQuestion',
        sourceFile: 'core/lib/src/models/questionnaire/scale_question.dart',
        fields: [],
        discriminatorValues: {'type': 'scale'},
        superTypes: {'Question'},
      ),
      'CheckmarkTask': const ScannedClass(
        name: 'CheckmarkTask',
        sourceFile:
            'core/lib/src/models/interventions/tasks/checkmark_task.dart',
        fields: [],
        discriminatorValues: {'type': 'checkmark'},
        superTypes: {'Task', 'InterventionTask'},
      ),
      'Unrelated': const ScannedClass(
        name: 'Unrelated',
        sourceFile: 'core/lib/src/models/other/unrelated.dart',
        fields: [],
      ),
    };

    test('collects all wire values for the given field', () {
      final result = buildDispatcherDiscriminators(
        dispatcherClass: 'Question',
        fieldName: 'type',
        allClasses: allClasses,
      );
      expect(result, contains('type'));
      expect(result['type'], containsAll(['boolean', 'choice', 'scale']));
    });

    test('excludes classes with no discriminator for that field', () {
      final result = buildDispatcherDiscriminators(
        dispatcherClass: 'Question',
        fieldName: 'type',
        allClasses: allClasses,
      );
      expect(result['type'], hasLength(3));
    });

    test('filters discriminator values to the requested dispatcher family', () {
      final result = buildDispatcherDiscriminators(
        dispatcherClass: 'Question',
        fieldName: 'type',
        allClasses: allClasses,
      );
      expect(result['type'], containsAll(['boolean', 'choice', 'scale']));
      expect(result['type'], isNot(contains('checkmark')));
    });

    test('returns empty map when no classes have the field', () {
      final result = buildDispatcherDiscriminators(
        dispatcherClass: 'Question',
        fieldName: 'nonexistent',
        allClasses: allClasses,
      );
      expect(result, isEmpty);
    });

    test('returns empty map for empty allClasses', () {
      final result = buildDispatcherDiscriminators(
        dispatcherClass: 'Question',
        fieldName: 'type',
        allClasses: {},
      );
      expect(result, isEmpty);
    });
  });

  group('scanModels', () {
    test(
      'uses generated serializer keys and defaults for wire contract',
      () async {
        final temp = await Directory.systemTemp.createTemp(
          'study_data_docs_test_',
        );
        addTearDown(() => temp.deleteSync(recursive: true));

        final modelsDir = Directory('${temp.path}/models')..createSync();
        File('${modelsDir.path}/wire_model.dart').writeAsStringSync('''
class WireModel {
  String dartName = '';
  int count = 0;
}

class CascadeDefaults {
  List<String> tags = const [];
}

class ConstructorDefaults {
  final List<String> children;

  ConstructorDefaults({required this.children});
}
''');
        File('${modelsDir.path}/wire_model.g.dart').writeAsStringSync('''
WireModel _\$WireModelFromJson(Map<String, dynamic> json) => WireModel()
  ..dartName = json['wire_name'] as String
  ..count = (json['count'] as num?)?.toInt() ?? 7;

Map<String, dynamic> _\$WireModelToJson(WireModel instance) => <String, dynamic>{
  'wire_name': instance.dartName,
  'count': instance.count,
};

CascadeDefaults _\$CascadeDefaultsFromJson(Map<String, dynamic> json) => CascadeDefaults()
  ..tags = (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [];

Map<String, dynamic> _\$CascadeDefaultsToJson(CascadeDefaults instance) => <String, dynamic>{
  'tags': instance.tags,
};

ConstructorDefaults _\$ConstructorDefaultsFromJson(Map<String, dynamic> json) => ConstructorDefaults(
  children: (json['children'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
);

Map<String, dynamic> _\$ConstructorDefaultsToJson(ConstructorDefaults instance) => <String, dynamic>{
  'children': instance.children,
};
''');

        final scanned = await scanModels(
          modelsDir: modelsDir.path,
          repoRoot: temp.path,
        );

        final wireFields = {
          for (final field in scanned['WireModel']!.fields) field.name: field,
        };
        expect(wireFields['dartName']!.jsonKey, 'wire_name');
        expect(wireFields['count']!.defaultValue, '7');

        final cascadeFields = {
          for (final field in scanned['CascadeDefaults']!.fields)
            field.name: field,
        };
        expect(cascadeFields['tags']!.defaultValue, 'const []');

        final constructorFields = {
          for (final field in scanned['ConstructorDefaults']!.fields)
            field.name: field,
        };
        expect(constructorFields['children']!.defaultValue, 'const []');
      },
    );
  });

  group('ScannedField', () {
    test('stores all fields', () {
      const f = ScannedField(
        name: 'id',
        dartType: 'String',
        jsonKey: 'id',
        required: true,
        nullable: false,
      );
      expect(f.name, 'id');
      expect(f.required, isTrue);
      expect(f.includeInJson, isTrue);
      expect(f.defaultValue, isNull);
    });

    test('includeInJson defaults to true', () {
      const f = ScannedField(
        name: 'x',
        dartType: 'int',
        jsonKey: 'x',
        required: false,
        nullable: false,
      );
      expect(f.includeInJson, isTrue);
    });
  });

  group('ScannedClass', () {
    test('discriminatorValues defaults to empty', () {
      const cls = ScannedClass(
        name: 'Foo',
        sourceFile: 'core/lib/src/models/foo.dart',
        fields: [],
      );
      expect(cls.discriminatorValues, isEmpty);
    });
  });
}

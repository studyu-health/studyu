import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';

void main() {
  test('persisted filters retain valid conditions and skip unknown ones', () {
    final filter = SavedFilter.fromJson({
      'id': 'saved',
      'name': 'Saved filter',
      'root': {
        'type': 'group',
        'id': 'root',
        'logic': 'and',
        'children': [
          {
            'type': 'condition',
            'id': 'missed',
            'property': 'missedDays',
            'operator': 'greaterThan',
            'value': 2,
          },
          {
            'type': 'condition',
            'id': 'removed',
            'property': 'removedProperty',
            'operator': 'equals',
            'value': true,
          },
          {
            'type': 'condition',
            'id': 'title',
            'property': 'title',
            'operator': 'contains',
            'value': 'sleep',
          },
        ],
      },
    });

    expect(
      filter.root.children.whereType<FilterCondition>().map(
        (condition) => condition.property,
      ),
      [StudyProperty.missedDays, StudyProperty.title],
    );
  });
}

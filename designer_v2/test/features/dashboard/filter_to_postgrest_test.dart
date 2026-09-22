import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_to_postgrest.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

User _user({String id = 'u1', String? email = 'me@x.test'}) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: DateTime.utc(2024).toIso8601String(),
    email: email,
  );
}

void main() {
  group('buildPostgrestFilterExpression', () {
    test('returns null for empty group', () {
      final result = buildPostgrestFilterExpression(FilterGroup(), _user());
      expect(result, isNull);
    });

    test('renders a single equals condition without wrapping in logic', () {
      final group = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.status,
            operator: FilterOperator.equals,
            value: 'running',
          ),
        ],
      );
      expect(
        buildPostgrestFilterExpression(group, _user()),
        'status.eq."running"',
      );
    });

    test('renders AND group with multiple conditions', () {
      final group = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.status,
            operator: FilterOperator.equals,
            value: 'running',
          ),
          FilterCondition(
            property: StudyProperty.participantCount,
            operator: FilterOperator.greaterThan,
            value: 5,
          ),
        ],
      );
      expect(
        buildPostgrestFilterExpression(group, _user()),
        'and(status.eq."running",study_participant_count.gt.5)',
      );
    });

    test('renders OR group with logical-or wrapper', () {
      final group = FilterGroup(
        logic: FilterLogic.or,
        children: [
          FilterCondition(
            property: StudyProperty.registryPublished,
            operator: FilterOperator.equals,
            value: true,
          ),
          FilterCondition(
            property: StudyProperty.resultSharing,
            operator: FilterOperator.equals,
            value: 'public',
          ),
        ],
      );
      expect(
        buildPostgrestFilterExpression(group, _user()),
        'or(registry_published.eq.true,result_sharing.eq."public")',
      );
    });

    test('renders nested group with mixed logic', () {
      final group = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.status,
            operator: FilterOperator.equals,
            value: 'running',
          ),
          FilterGroup(
            logic: FilterLogic.or,
            children: [
              FilterCondition(
                property: StudyProperty.activeSubjectCount,
                operator: FilterOperator.lessThan,
                value: 2,
              ),
              FilterCondition(
                property: StudyProperty.participantCount,
                operator: FilterOperator.lessThan,
                value: 5,
              ),
            ],
          ),
        ],
      );
      expect(
        buildPostgrestFilterExpression(group, _user()),
        'and(status.eq."running",or(active_subject_count.lt.2,study_participant_count.lt.5))',
      );
    });

    test('enum notEquals uses neq', () {
      final group = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.status,
            operator: FilterOperator.notEquals,
            value: 'running',
          ),
        ],
      );
      expect(
        buildPostgrestFilterExpression(group, _user()),
        'status.neq."running"',
      );
    });

    test('title equals remains case-insensitive', () {
      final group = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.title,
            operator: FilterOperator.equals,
            value: 'Sleep Study',
          ),
        ],
      );
      expect(
        buildPostgrestFilterExpression(group, _user()),
        'title.ilike."Sleep Study"',
      );
    });

    test('title notEquals remains case-insensitive', () {
      final group = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.title,
            operator: FilterOperator.notEquals,
            value: 'Sleep Study',
          ),
        ],
      );
      expect(
        buildPostgrestFilterExpression(group, _user()),
        'title.not.ilike."Sleep Study"',
      );
    });

    test('contains becomes ilike with wildcards', () {
      final group = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.title,
            operator: FilterOperator.contains,
            value: 'sleep',
          ),
        ],
      );
      expect(
        buildPostgrestFilterExpression(group, _user()),
        'title.ilike."*sleep*"',
      );
    });

    test('contains escapes literal wildcards before adding wildcards', () {
      final group = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.title,
            operator: FilterOperator.contains,
            value: 'sleep*study',
          ),
        ],
      );
      expect(
        buildPostgrestFilterExpression(group, _user()),
        r'title.ilike."*sleep\*study*"',
      );
    });

    test('escapes backslashes before LIKE metacharacters', () {
      expect(escapePostgrestLikeLiteral(r'\*%_"'), r'\\\*\%\_\"');
    });

    test('startsWith and endsWith use anchored ilike patterns', () {
      final start = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.title,
            operator: FilterOperator.startsWith,
            value: 'pilot',
          ),
        ],
      );
      final end = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.title,
            operator: FilterOperator.endsWith,
            value: 'study',
          ),
        ],
      );
      expect(
        buildPostgrestFilterExpression(start, _user()),
        'title.ilike."pilot*"',
      );
      expect(
        buildPostgrestFilterExpression(end, _user()),
        'title.ilike."*study"',
      );
    });

    test('owner=true maps to user_id.eq.<currentUserId>', () {
      final group = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.owner,
            operator: FilterOperator.equals,
            value: true,
          ),
        ],
      );
      expect(
        buildPostgrestFilterExpression(group, _user(id: 'abc')),
        'user_id.eq.abc',
      );
    });

    test('editor=true maps to collaborator_emails.cs.{<email>}', () {
      final group = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.editor,
            operator: FilterOperator.equals,
            value: true,
          ),
        ],
      );
      expect(
        buildPostgrestFilterExpression(group, _user(email: 'alice@x.test')),
        'collaborator_emails.cs.{"alice@x.test"}',
      );
    });

    test('missedDays remains unsupported for server filtering', () {
      final group = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.missedDays,
            operator: FilterOperator.greaterThan,
            value: 2,
          ),
        ],
      );

      expect(
        () => buildPostgrestFilterExpression(group, _user()),
        throwsA(isA<UnsupportedFilterException>()),
      );
    });

    test('inLast becomes a gte ISO timestamp', () {
      final group = FilterGroup(
        children: [
          FilterCondition(
            property: StudyProperty.createdAt,
            operator: FilterOperator.inLast,
            value: 30,
          ),
        ],
      );
      final result = buildPostgrestFilterExpression(group, _user());
      expect(result, startsWith('created_at.gte.'));
      expect(result, contains('T'));
      expect(result, endsWith('Z'));
    });
  });
}

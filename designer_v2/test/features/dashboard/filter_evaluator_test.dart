import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_evaluator.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Mock User class
// ignore: avoid_implementing_value_types
class MockUser(@override final String id) extends Mock implements supabase.User;

void main() {
  group('FilterEvaluator', () {
    final user = MockUser('user-1');
    final study1 = Study.withId('user-1')
      ..title = 'Sleep Study'
      ..status = StudyStatus.running
      ..participantCount = 10
      ..resultSharing = ResultSharing.public
      ..registryPublished = true;

    final study2 = Study.withId('user-2')
      ..title = 'Nutrition Study'
      ..status = StudyStatus.draft
      ..participantCount = 5
      ..resultSharing = ResultSharing.private
      ..registryPublished = false;

    test('evaluates simple condition (equals)', () {
      final condition = FilterCondition(
        property: StudyProperty.title,
        operator: FilterOperator.equals,
        value: 'Sleep Study',
      );
      final group = FilterGroup(children: [condition]);

      expect(FilterEvaluator.evaluate(group, study1, user), isTrue);
      expect(FilterEvaluator.evaluate(group, study2, user), isFalse);
    });

    test('evaluates simple condition (contains)', () {
      final condition = FilterCondition(
        property: StudyProperty.title,
        operator: FilterOperator.contains,
        value: 'Study',
      );
      final group = FilterGroup(children: [condition]);

      expect(FilterEvaluator.evaluate(group, study1, user), isTrue);
      expect(FilterEvaluator.evaluate(group, study2, user), isTrue);
    });

    test('evaluates numeric condition (greaterThan)', () {
      final condition = FilterCondition(
        property: StudyProperty.participantCount,
        operator: FilterOperator.greaterThan,
        value: 8,
      );
      final group = FilterGroup(children: [condition]);

      expect(FilterEvaluator.evaluate(group, study1, user), isTrue);
      expect(FilterEvaluator.evaluate(group, study2, user), isFalse);
    });

    test('evaluates AND logic', () {
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

      expect(FilterEvaluator.evaluate(group, study1, user), isTrue);
      expect(FilterEvaluator.evaluate(group, study2, user), isFalse);
    });

    test('evaluates OR logic', () {
      final group = FilterGroup(
        logic: FilterLogic.or,
        children: [
          FilterCondition(
            property: StudyProperty.status,
            operator: FilterOperator.equals,
            value: 'running',
          ),
          FilterCondition(
            property: StudyProperty.status,
            operator: FilterOperator.equals,
            value: 'draft',
          ),
        ],
      );

      expect(FilterEvaluator.evaluate(group, study1, user), isTrue);
      expect(FilterEvaluator.evaluate(group, study2, user), isTrue);
    });

    test('evaluates nested groups', () {
      // (Title contains "Sleep" AND Status = running) OR (Title contains "Nutrition")
      final group = FilterGroup(
        logic: FilterLogic.or,
        children: [
          FilterGroup(
            children: [
              FilterCondition(
                property: StudyProperty.title,
                operator: FilterOperator.contains,
                value: 'Sleep',
              ),
              FilterCondition(
                property: StudyProperty.status,
                operator: FilterOperator.equals,
                value: 'running',
              ),
            ],
          ),
          FilterCondition(
            property: StudyProperty.title,
            operator: FilterOperator.contains,
            value: 'Nutrition',
          ),
        ],
      );

      expect(FilterEvaluator.evaluate(group, study1, user), isTrue);
      expect(FilterEvaluator.evaluate(group, study2, user), isTrue);
    });

    test('evaluates owner property', () {
      final condition = FilterCondition(
        property: StudyProperty.owner,
        operator: FilterOperator.equals,
        value: true,
      );
      final group = FilterGroup(children: [condition]);

      expect(
        FilterEvaluator.evaluate(group, study1, user),
        isTrue,
      ); // user-1 owns study1
      expect(
        FilterEvaluator.evaluate(group, study2, user),
        isFalse,
      ); // user-1 does not own study2
    });
  });
}

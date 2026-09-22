import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class FilterEvaluator() {
  static bool evaluate(FilterGroup group, Study study, supabase.User user) {
    if (group.children.isEmpty) return true;

    if (group.logic == FilterLogic.and) {
      return group.children.every(
        (child) => evaluateElement(child, study, user),
      );
    } else {
      return group.children.any((child) => evaluateElement(child, study, user));
    }
  }

  static bool evaluateElement(
    FilterElement element,
    Study study,
    supabase.User user,
  ) {
    if (element is FilterGroup) {
      return evaluate(element, study, user);
    } else if (element is FilterCondition) {
      return evaluateCondition(element, study, user);
    }
    return false;
  }

  static bool evaluateCondition(
    FilterCondition condition,
    Study study,
    supabase.User user,
  ) {
    final value = _getPropertyValue(study, condition.property, user);
    return _compare(value, condition.operator, condition.value);
  }

  static dynamic _getPropertyValue(
    Study study,
    StudyProperty property,
    supabase.User user,
  ) {
    switch (property) {
      case StudyProperty.title:
        return study.title;
      case StudyProperty.status:
        return study.status.name; // Compare as string or enum index
      case StudyProperty.participation:
        return study.participation.name;
      case StudyProperty.createdAt:
        return study.createdAt;
      case StudyProperty.participantCount:
        return study.participantCount;
      case StudyProperty.activeSubjectCount:
        return study.activeSubjectCount;
      case StudyProperty.endedCount:
        return study.endedCount;
      case StudyProperty.missedDays:
        return study.missedDays.fold(0, (sum, days) => sum + days);
      case StudyProperty.resultSharing:
        return study.resultSharing.name;
      case StudyProperty.registryPublished:
        return study.registryPublished;
      case StudyProperty.owner:
        return study.isOwner(user);
      case StudyProperty.editor:
        return study.isEditor(user);
    }
  }

  static bool _compare(dynamic actual, FilterOperator op, dynamic target) {
    if (actual == null) return false; // Or handle nulls specifically

    switch (op) {
      case FilterOperator.equals:
        return actual.toString().toLowerCase() ==
            target.toString().toLowerCase();
      case FilterOperator.notEquals:
        return actual.toString().toLowerCase() !=
            target.toString().toLowerCase();
      case FilterOperator.contains:
        return actual.toString().toLowerCase().contains(
          target.toString().toLowerCase(),
        );
      case FilterOperator.greaterThan:
        if (actual is num && target is num) return actual > target;
        if (actual is DateTime && target is DateTime) {
          return actual.isAfter(target);
        }
        return false;
      case FilterOperator.lessThan:
        if (actual is num && target is num) return actual < target;
        if (actual is DateTime && target is DateTime) {
          return actual.isBefore(target);
        }
        return false;
      case FilterOperator.greaterThanOrEqual:
        if (actual is num && target is num) return actual >= target;
        if (actual is DateTime && target is DateTime) {
          return actual.isAfter(target) || actual.isAtSameMomentAs(target);
        }
        return false;
      case FilterOperator.lessThanOrEqual:
        if (actual is num && target is num) return actual <= target;
        if (actual is DateTime && target is DateTime) {
          return actual.isBefore(target) || actual.isAtSameMomentAs(target);
        }
        return false;
      case FilterOperator.startsWith:
        return actual.toString().toLowerCase().startsWith(
          target.toString().toLowerCase(),
        );
      case FilterOperator.endsWith:
        return actual.toString().toLowerCase().endsWith(
          target.toString().toLowerCase(),
        );
      case FilterOperator.isEmpty:
        if (actual is String) return actual.isEmpty;
        if (actual is List) return actual.isEmpty;
        return false;
      case FilterOperator.isNotEmpty:
        if (actual is String) return actual.isNotEmpty;
        if (actual is List) return actual.isNotEmpty;
        return true;
      case FilterOperator.after:
        if (actual is DateTime && target is DateTime) {
          return actual.isAfter(target);
        }
        return false;
      case FilterOperator.before:
        if (actual is DateTime && target is DateTime) {
          return actual.isBefore(target);
        }
        return false;
      case FilterOperator.inLast:
        if (actual is DateTime && target is int) {
          final diff = DateTime.now().difference(actual).inDays;
          return diff <= target && diff >= 0;
        }
        return false;
    }
  }
}

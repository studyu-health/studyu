import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class const UnsupportedFilterException(final String reason)
    implements Exception {
  @override
  String toString() => 'UnsupportedFilterException: $reason';
}

String? buildPostgrestFilterExpression(FilterGroup group, User currentUser) {
  final rendered = _renderGroup(group, currentUser);
  return rendered;
}

String? _renderElement(FilterElement element, User currentUser) {
  if (element is FilterGroup) {
    return _renderGroup(element, currentUser);
  }
  if (element is FilterCondition) {
    return _renderCondition(element, currentUser);
  }
  return null;
}

String? _renderGroup(FilterGroup group, User currentUser) {
  if (group.children.isEmpty) return null;
  final parts = <String>[];
  for (final child in group.children) {
    final rendered = _renderElement(child, currentUser);
    if (rendered != null && rendered.isNotEmpty) parts.add(rendered);
  }
  if (parts.isEmpty) return null;
  if (parts.length == 1) return parts.first;
  final logic = group.logic == FilterLogic.or ? 'or' : 'and';
  return '$logic(${parts.join(',')})';
}

String _renderCondition(FilterCondition condition, User currentUser) {
  final property = condition.property;

  if (property == StudyProperty.missedDays) {
    throw const UnsupportedFilterException(
      'missedDays is computed from an array column and cannot be filtered '
      'server-side without a generated column or RPC.',
    );
  }

  if (property == StudyProperty.owner) {
    final isOwner = condition.value == true;
    final eqOp = condition.operator == FilterOperator.notEquals
        ? !isOwner
        : isOwner;
    return eqOp
        ? 'user_id.eq.${currentUser.id}'
        : 'user_id.neq.${currentUser.id}';
  }

  if (property == StudyProperty.editor) {
    final isEditor = condition.value == true;
    final eqOp = condition.operator == FilterOperator.notEquals
        ? !isEditor
        : isEditor;
    final email = currentUser.email ?? '';
    final emailLiteral = _formatScalar(email);
    return eqOp
        ? 'collaborator_emails.cs.{$emailLiteral}'
        : 'collaborator_emails.not.cs.{$emailLiteral}';
  }

  final column = _columnFor(property);
  final op = condition.operator;
  final value = condition.value;

  final supportsIlike = property == StudyProperty.title;

  switch (op) {
    case FilterOperator.equals:
      if (supportsIlike) {
        return '$column.ilike.${_formatLikePattern(value, exact: true)}';
      }
      return '$column.eq.${_formatValue(value)}';
    case FilterOperator.notEquals:
      if (supportsIlike) {
        return '$column.not.ilike.${_formatLikePattern(value, exact: true)}';
      }
      return '$column.neq.${_formatValue(value)}';
    case FilterOperator.contains:
      return '$column.ilike.${_formatLikePattern(value, contains: true)}';
    case FilterOperator.startsWith:
      return '$column.ilike.${_formatLikePattern(value, startsWith: true)}';
    case FilterOperator.endsWith:
      return '$column.ilike.${_formatLikePattern(value, endsWith: true)}';
    case FilterOperator.greaterThan:
      return '$column.gt.${_formatValue(value)}';
    case FilterOperator.lessThan:
      return '$column.lt.${_formatValue(value)}';
    case FilterOperator.greaterThanOrEqual:
      return '$column.gte.${_formatValue(value)}';
    case FilterOperator.lessThanOrEqual:
      return '$column.lte.${_formatValue(value)}';
    case FilterOperator.isEmpty:
      return 'or($column.is.null,$column.eq."")';
    case FilterOperator.isNotEmpty:
      return 'and($column.not.is.null,$column.neq."")';
    case FilterOperator.after:
      return '$column.gt.${_formatValue(value)}';
    case FilterOperator.before:
      return '$column.lt.${_formatValue(value)}';
    case FilterOperator.inLast:
      if (value is! num) {
        throw UnsupportedFilterException(
          'inLast requires a numeric (days) value, got: $value',
        );
      }
      final since = DateTime.now().toUtc().subtract(
        Duration(days: value.toInt()),
      );
      return '$column.gte.${since.toIso8601String()}';
  }
}

String _columnFor(StudyProperty property) {
  switch (property) {
    case StudyProperty.title:
      return 'title';
    case StudyProperty.status:
      return 'status';
    case StudyProperty.participation:
      return 'participation';
    case StudyProperty.createdAt:
      return 'created_at';
    case StudyProperty.participantCount:
      return 'study_participant_count';
    case StudyProperty.activeSubjectCount:
      return 'active_subject_count';
    case StudyProperty.endedCount:
      return 'study_ended_count';
    case StudyProperty.resultSharing:
      return 'result_sharing';
    case StudyProperty.registryPublished:
      return 'registry_published';
    case StudyProperty.missedDays:
    case StudyProperty.owner:
    case StudyProperty.editor:
      throw StateError('synthetic property: ${property.name}');
  }
}

String _formatValue(dynamic value) {
  if (value == null) return 'null';
  if (value is bool) return value.toString();
  if (value is num) return value.toString();
  if (value is DateTime) return value.toUtc().toIso8601String();
  return _formatScalar(value.toString());
}

String _formatScalar(String value) {
  final escaped = value.replaceAll('"', r'\"');
  return '"$escaped"';
}

String escapePostgrestLikeLiteral(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll('*', r'\*')
    .replaceAll('%', r'\%')
    .replaceAll('_', r'\_')
    .replaceAll('"', r'\"');

String _formatLikePattern(
  dynamic value, {
  bool exact = false,
  bool contains = false,
  bool startsWith = false,
  bool endsWith = false,
}) {
  final escaped = escapePostgrestLikeLiteral((value ?? '').toString());
  final pattern = exact
      ? escaped
      : contains
      ? '*$escaped*'
      : startsWith
      ? '$escaped*'
      : endsWith
      ? '*$escaped'
      : escaped;
  return '"$pattern"';
}

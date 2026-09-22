import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum FilterLogic() {
  and,
  or,
}

enum FilterOperator() {
  equals,
  notEquals,
  contains,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  startsWith,
  endsWith,
  isEmpty,
  isNotEmpty,
  // Date specific
  after,
  before,
  inLast, // e.g. in last 30 days
}

enum StudyProperty() {
  title,
  status,
  participation,
  createdAt,
  participantCount,
  activeSubjectCount,
  endedCount,
  missedDays,
  resultSharing,
  registryPublished,
  owner, // derived from isOwner
  editor, // derived from isEditor
}

abstract class const FilterElement() extends Equatable {
  String get id;

  Map<String, dynamic> toJson();

  factory fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'group') {
      return FilterGroup.fromJson(json);
    } else if (type == 'condition') {
      return FilterCondition.fromJson(json);
    }
    throw FormatException('Unknown FilterElement type: $type');
  }
}

// ignore: prefer_const_constructors_in_immutables
class FilterCondition({
  String? id,
  required final StudyProperty property,
  required final FilterOperator operator,
  final dynamic value,
}) extends FilterElement {
  @override
  final String id = id ?? const Uuid().v4();
  // String, num, DateTime, bool, etc.

  factory fromJson(Map<String, dynamic> json) {
    final propertyName = json['property'];
    final operatorName = json['operator'];
    final property = propertyName is String
        ? StudyProperty.values.asNameMap()[propertyName]
        : null;
    final operator = operatorName is String
        ? FilterOperator.values.asNameMap()[operatorName]
        : null;
    if (property == null || operator == null) {
      throw FormatException(
        'Unknown filter condition: $propertyName/$operatorName',
      );
    }
    dynamic value = json['value'];

    // Handle DateTime deserialization
    if (property == StudyProperty.createdAt && value is String) {
      value = DateTime.parse(value);
    }

    return FilterCondition(
      id: json['id'] as String?,
      property: property,
      operator: operator,
      value: value,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    dynamic serializedValue = value;
    if (value is DateTime) {
      serializedValue = (value as DateTime).toIso8601String();
    }

    return {
      'type': 'condition',
      'id': id,
      'property': property.name,
      'operator': operator.name,
      'value': serializedValue,
    };
  }

  FilterCondition copyWith({
    StudyProperty? property,
    FilterOperator? operator,
    dynamic value,
  }) {
    return FilterCondition(
      id: id,
      property: property ?? this.property,
      operator: operator ?? this.operator,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [id, property, operator, value];
}

// ignore: prefer_const_constructors_in_immutables
class FilterGroup({
  String? id,
  final FilterLogic logic = FilterLogic.and,
  List<FilterElement>? children,
}) extends FilterElement {
  @override
  final String id = id ?? const Uuid().v4();
  final List<FilterElement> children =
      children ?? []; // Can be FilterCondition or FilterGroup

  factory fromJson(Map<String, dynamic> json) {
    final children = <FilterElement>[];
    for (final child in json['children'] as List<dynamic>) {
      if (child is! Map<String, dynamic>) continue;
      try {
        children.add(FilterElement.fromJson(child));
      } on FormatException {
        // Persisted filters may contain removed conditions or invalid values.
        // Keep their still-valid siblings.
      }
    }
    return FilterGroup(
      id: json['id'] as String?,
      logic: FilterLogic.values.byName(json['logic'] as String),
      children: children,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'group',
      'id': id,
      'logic': logic.name,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }

  void add(FilterElement element) {
    children.add(element);
  }

  void remove(String id) {
    children.removeWhere((element) => element.id == id);
  }

  @override
  List<Object?> get props => [id, logic, children];
}

class SavedFilter({
  required final String id,
  required var String name,
  required var FilterGroup root,
  var String? sortColumn,
  var bool sortAscending = true,
  var bool isDefault = false,
  var IconData? icon,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  // Matches StudiesTableColumn enum name
  DateTime createdAt = createdAt ?? DateTime.now();
  DateTime updatedAt = updatedAt ?? DateTime.now();

  factory fromJson(Map<String, dynamic> json) {
    return SavedFilter(
      id: json['id'] as String,
      name: json['name'] as String,
      root: FilterGroup.fromJson(json['root'] as Map<String, dynamic>),
      sortColumn: json['sort_column'] as String?,
      sortAscending: json['sort_ascending'] as bool? ?? true,
      isDefault: json['is_default'] as bool? ?? false,
      // Icon is NOT serialized
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'root': root.toJson(),
      'sort_column': sortColumn,
      'sort_ascending': sortAscending,
      'is_default': isDefault,
      // Icon is NOT serialized
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class DefaultPresets() {
  static SavedFilter get myActiveStudies => SavedFilter(
    id: 'preset_my_active_studies',
    name: 'My Active Studies',
    isDefault: true,
    icon: Icons.star_border_rounded,
    root: FilterGroup(
      children: [
        // TODO: Only enable after we have added collaboration mode
        /*FilterCondition(
          property: StudyProperty.owner,
          operator: FilterOperator.equals,
          value: true,
        ),*/
        FilterCondition(
          property: StudyProperty.status,
          operator: FilterOperator.equals,
          value:
              'running', // Assuming 'running' matches StudyStatus.running.name
        ),
      ],
    ),
  );

  static SavedFilter get studiesNeedingAttention => SavedFilter(
    id: 'preset_needing_attention',
    name: 'Studies Needing Attention',
    isDefault: true,
    icon: Icons.error_outline_rounded,
    root: FilterGroup(
      children: [
        FilterCondition(
          property: StudyProperty.status,
          operator: FilterOperator.equals,
          value: 'running',
        ),
        // Simplistic logic: active subjects < 2 OR participant count < 5
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
    ),
  );

  static SavedFilter get recentlyCreated => SavedFilter(
    id: 'preset_recently_created',
    name: 'Recently Created',
    isDefault: true,
    icon: Icons.new_releases_outlined,
    root: FilterGroup(
      children: [
        FilterCondition(
          property: StudyProperty.createdAt,
          operator: FilterOperator.greaterThanOrEqual,
          value: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ],
    ),
  );

  static SavedFilter get publicStudies => SavedFilter(
    id: 'preset_public_studies',
    name: 'Public Studies',
    isDefault: true,
    icon: Icons.public_rounded,
    root: FilterGroup(
      logic: FilterLogic.or,
      children: [
        FilterCondition(
          property: StudyProperty.resultSharing,
          operator: FilterOperator.equals,
          value: 'public',
        ),
        FilterCondition(
          property: StudyProperty.registryPublished,
          operator: FilterOperator.equals,
          value: true,
        ),
      ],
    ),
  );

  static SavedFilter get draftStudies => SavedFilter(
    id: 'preset_draft_studies',
    name: 'Draft Studies',
    isDefault: true,
    icon: Icons.edit_note_rounded,
    root: FilterGroup(
      children: [
        FilterCondition(
          property: StudyProperty.status,
          operator: FilterOperator.equals,
          value: 'draft',
        ),
      ],
    ),
  );

  static List<SavedFilter> get all => [
    myActiveStudies,
    // TODO: Only enable after we have implemented metrics calculation
    // studiesNeedingAttention,
    recentlyCreated,
    publicStudies,
    draftStudies,
  ];
}

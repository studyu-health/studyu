import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';

extension NumericComparatorX on NumericComparator {
  String get stringSymbol {
    switch (this) {
      case NumericComparator.equal:
        return '=';
      case NumericComparator.notEqual:
        return '≠';
      case NumericComparator.greaterThan:
        return '>';
      case NumericComparator.lessThan:
        return '<';
      case NumericComparator.greaterThanOrEqual:
        return '≥';
      case NumericComparator.lessThanOrEqual:
        return '≤';
    }
  }
}

extension FilterOperatorX on FilterOperator {
  String? get stringSymbol {
    switch (this) {
      case FilterOperator.greaterThan:
        return '>';
      case FilterOperator.lessThan:
        return '<';
      case FilterOperator.greaterThanOrEqual:
        return '≥';
      case FilterOperator.lessThanOrEqual:
        return '≤';
      case FilterOperator.equals:
        return '=';
      case FilterOperator.notEquals:
        return '≠';
      default:
        return null;
    }
  }
}

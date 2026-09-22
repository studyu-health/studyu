import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class ConditionRowFormData({
  required final String? questionId,
  required final dynamic comparator,
  required final dynamic value,
}) extends IFormData {
  Expression? buildExpression() {
    if (questionId == null) return null;

    // Handle boolean questions
    if (comparator == 'is') {
      final baseExpression = BooleanExpression()..target = questionId;
      if (value == false) {
        return NotExpression()..expression = baseExpression;
      }
      return baseExpression;
    }

    // Handle choice questions
    if (comparator == '=' || comparator == '!=') {
      final baseExpression = ChoiceExpression()..target = questionId;

      // Handle different types of choice values
      if (value is List) {
        // For multiple choice questions - filter out null/empty values
        final List<dynamic> valueList = value as List<dynamic>;
        final validValues = valueList
            .where((v) => v != null && v.toString().isNotEmpty)
            .toList();
        if (validValues.isEmpty) return null;
        baseExpression.choices = validValues.map((v) => v.toString()).toSet();
      } else {
        // For single choice questions - check for null/empty values
        if (value == null || value.toString().isEmpty) return null;
        baseExpression.choices = {value.toString()};
      }

      if (comparator == '!=') {
        return NotExpression()..expression = baseExpression;
      }
      return baseExpression;
    }

    // Handle numeric questions
    if (comparator is NumericComparator) {
      final numValue = value is String
          ? num.tryParse(value as String)
          : (value as num?);
      if (numValue == null) return null;
      return NumericExpression(
        comparator: comparator as NumericComparator,
        value: numValue,
      )..target = questionId;
    }

    // Handle text questions
    if (comparator is TextComparator) {
      if (value == null) return null;
      final textValue = value.toString();
      if (_usesTextLengthComparator(comparator as TextComparator) &&
          int.tryParse(textValue) == null) {
        return null;
      }
      return TextExpression(
        comparator: comparator as TextComparator,
        value: textValue,
      )..target = questionId;
    }

    return null;
  }

  @override
  String toString() =>
      'ConditionRowFormData(questionId: $questionId, comparator: $comparator, value: $value)';

  @override
  IFormData copy() {
    return ConditionRowFormData(
      questionId: questionId,
      comparator: comparator,
      value: value,
    );
  }

  @override
  FormDataID get id => throw UnimplementedError();

  bool _usesTextLengthComparator(TextComparator comparator) {
    return switch (comparator) {
      TextComparator.lengthGreaterThan ||
      TextComparator.lengthLessThan ||
      TextComparator.lengthGreaterThanOrEqual ||
      TextComparator.lengthLessThanOrEqual ||
      TextComparator.lengthEqual ||
      TextComparator.lengthNotEqual => true,
      _ => false,
    };
  }
}

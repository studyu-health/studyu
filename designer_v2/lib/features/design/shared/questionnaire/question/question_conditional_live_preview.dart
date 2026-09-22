import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const LiveConditionPreview({
  super.key,
  required final CompositeExpression? compositeExpression,
  required final List<Question> allQuestions,
  required final String currentQuestionId,
}) extends StatelessWidget {
  String _getQuestionPreviewText(String questionId) {
    /*if (questionId == currentQuestionId) {
      // Use the specific question text from the ViewModel for clarity
      return tr.form_array_question_visibility_logic_this_question;
    }*/
    final question = allQuestions.firstWhereOrNull((q) => q.id == questionId);
    return question != null ? 'Q[${question.prompt}]' : 'Q[$questionId]';
  }

  String _formatExpressionForPreview(Expression expression) {
    if (expression is BooleanExpression) {
      return '${_getQuestionPreviewText(expression.target!)} ${tr.form_array_question_visibility_logic_is_true}';
    } else if (expression is NotExpression) {
      final innerExp = expression.expression;
      if (innerExp is BooleanExpression) {
        return '${_getQuestionPreviewText(innerExp.target!)} ${tr.form_array_question_visibility_logic_is_false}';
      } else if (innerExp is ChoiceExpression) {
        // Handle != for choice display
        return '${_getQuestionPreviewText(innerExp.target!)} != [${innerExp.choices.map((c) => _getChoiceText(innerExp.target!, c)).join(', ')}]';
      }
      return '${tr.form_array_question_visibility_logic_not} (${_formatExpressionForPreview(innerExp)})';
    } else if (expression is ChoiceExpression) {
      return '${_getQuestionPreviewText(expression.target!)} = [${expression.choices.map((c) => _getChoiceText(expression.target!, c)).join(', ')}]';
    } else if (expression is NumericExpression) {
      final String comparatorSymbol;
      switch (expression.comparator) {
        case NumericComparator.equal:
          comparatorSymbol = '=';
        case NumericComparator.notEqual:
          comparatorSymbol = '!=';
        case NumericComparator.greaterThan:
          comparatorSymbol = '>';
        case NumericComparator.lessThan:
          comparatorSymbol = '<';
        case NumericComparator.greaterThanOrEqual:
          comparatorSymbol = '>=';
        case NumericComparator.lessThanOrEqual:
          comparatorSymbol = '<=';
      }
      return '${_getQuestionPreviewText(expression.target!)} $comparatorSymbol ${expression.value}';
    } else if (expression is TextExpression) {
      final String comparatorText;
      final bool usesLengthComparison;
      switch (expression.comparator) {
        case TextComparator.equal:
          comparatorText = tr.form_array_question_visibility_logic_is;
          usesLengthComparison = false;
        case TextComparator.notEqual:
          comparatorText = tr.form_array_question_visibility_logic_is_not;
          usesLengthComparison = false;
        case TextComparator.contains:
          comparatorText = tr.form_array_question_visibility_logic_contains;
          usesLengthComparison = false;
        case TextComparator.doesNotContain:
          comparatorText =
              tr.form_array_question_visibility_logic_does_not_contain;
          usesLengthComparison = false;
        case TextComparator.lengthGreaterThan:
          comparatorText = tr.form_array_question_visibility_logic_longer_than;
          usesLengthComparison = true;
        case TextComparator.lengthLessThan:
          comparatorText = tr.form_array_question_visibility_logic_shorter_than;
          usesLengthComparison = true;
        case TextComparator.lengthGreaterThanOrEqual:
          comparatorText =
              tr.form_array_question_visibility_logic_longer_than_or_equal_to;
          usesLengthComparison = true;
        case TextComparator.lengthLessThanOrEqual:
          comparatorText =
              tr.form_array_question_visibility_logic_shorter_than_or_equal_to;
          usesLengthComparison = true;
        case TextComparator.lengthEqual:
          comparatorText =
              tr.form_array_question_visibility_logic_same_length_as;
          usesLengthComparison = true;
        case TextComparator.lengthNotEqual:
          comparatorText =
              tr.form_array_question_visibility_logic_different_length_as;
          usesLengthComparison = true;
      }
      final previewValue = usesLengthComparison
          ? expression.value
          : "'${expression.value}'";
      return '${_getQuestionPreviewText(expression.target!)} $comparatorText $previewValue';
    } else if (expression is CompositeExpression) {
      if (expression.expressions.isEmpty) {
        return tr.form_array_question_visibility_logic_always_true;
      }
      final innerParts = expression.expressions
          .map((e) => _formatExpressionForPreview(e))
          .toList();
      final innerJoiner = expression.logicType == LogicType.and
          ? ' ${tr.form_array_question_visibility_logic_grouping_and_title} '
          : ' ${tr.form_array_question_visibility_logic_grouping_or_title} ';
      return '(${innerParts.join(innerJoiner)})';
    }
    return tr.form_array_question_visibility_logic_unknown_expression;
  }

  String _getChoiceText(String questionId, dynamic choiceValue) {
    final question = allQuestions.firstWhereOrNull((q) => q.id == questionId);
    if (question is ChoiceQuestion) {
      final choice = question.choices.firstWhereOrNull(
        (c) => c.id == choiceValue,
      );
      return choice?.text ??
          choiceValue.toString(); // Return text or value if not found
    }
    return choiceValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    // print('Building LiveConditionPreview with ${compositeExpression.toJson()}');
    String previewText;
    if (compositeExpression == null ||
        compositeExpression!.expressions.isEmpty) {
      previewText =
          '${tr.form_array_question_visibility_logic_preview_description}\n\n(${tr.form_array_question_visibility_logic_always_true})';
    } else {
      final formattedConditions = _formatExpressionForPreview(
        compositeExpression!,
      );
      previewText =
          '${tr.form_array_question_visibility_logic_preview_description}\n\n$formattedConditions';
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SelectableText(
        previewText,
        style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      ),
    );
  }

  // Uncomment and implement the following methods if needed
  /*
  Widget _buildConditionsList() {
    // Implement the logic to display the list of conditions
  }

  Widget _buildAddConditionButton() {
    // Implement the logic to add a new condition
  }

  Widget _buildLivePreview(BuildContext context) {
    // Implement the logic to show a live preview of the conditions
  }
  */
}

import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

abstract class IConditionalQuestionProperties() {
  String get currentQuestionId;
  CompositeExpression? get compositeExpression;
  bool get isReadonly;

  FormControl<LogicType> get logicTypeControl;
  FormArray get conditionsArray;
  FormControl<QuestionConditional<dynamic>?> get questionConditionalControl;

  List<ConditionRowFormViewModel> get conditionModels;

  void addCondition({Expression? initialExpression});
  void updateCondition();
  void removeCondition(int index);
  void cleanupInvalidConditions();
  void initializeDeferredConditions();

  Stream<void> get conditionsValueChanges;
}

class ConditionalQuestionFormViewModel({
  @override required final String currentQuestionId,
  @override
  required final FormControl<QuestionConditional<dynamic>?>
  questionConditionalControl,
}) extends FormViewModel implements IConditionalQuestionProperties {
  /// Flag to prevent marking form as dirty during programmatic updates
  bool _isUpdatingProgrammatically = false;

  /// Debouncing timer to prevent excessive updates
  Timer? _updateDebounceTimer;
  static const Duration _updateDebounceDelay = Duration(milliseconds: 300);

  /// Cache the last serialized condition to avoid unnecessary updates
  String? _lastSerializedCondition;

  /// Flag to prevent recursive updates
  bool _isUpdatingCondition = false;

  @override
  FormControl<LogicType> logicTypeControl = FormControl<LogicType>(
    value: LogicType.and,
  );

  @override
  late final FormArray conditionsArray = FormArray([]);

  late final FormViewModelCollection<
    ConditionRowFormViewModel,
    ConditionRowFormData
  >
  conditionFormViewModels = FormViewModelCollection([], conditionsArray);

  @override
  List<ConditionRowFormViewModel> get conditionModels =>
      conditionFormViewModels.formViewModels;

  @override
  late final FormGroup form = FormGroup({
    'logicType': logicTypeControl,
    'conditions': conditionsArray,
  });

  Stream<void> _conditionsValueChangesStream = const Stream<void>.empty();
  StreamSubscription<void>? _conditionsValueChangesSubscription;

  @override
  Stream<void> get conditionsValueChanges =>
      _conditionsValueChangesStream.isBroadcast
      ? _conditionsValueChangesStream
      : _conditionsValueChangesStream.asBroadcastStream();

  @override
  CompositeExpression? get compositeExpression {
    final List<Expression> currentExpressions = [];
    for (final formViewModel in conditionFormViewModels.formViewModels) {
      final expression = formViewModel.buildExpression();
      if (expression != null) {
        currentExpressions.add(expression);
      }
    }
    if (currentExpressions.isEmpty) {
      return null;
    }
    return CompositeExpression(
      logicType: logicTypeControl.value ?? LogicType.and,
      expressions: currentExpressions,
    );
  }

  @override
  void addCondition({Expression? initialExpression}) {
    final conditionVm = ConditionRowFormViewModel(
      currentQuestionId: currentQuestionId,
      initialExpression: initialExpression,
    );

    // Set the form mode to match the parent form mode
    conditionVm.formMode = formMode;

    if (initialExpression != null) {
      final formData = ConditionRowFormData(
        questionId: conditionVm.extractQuestionId(initialExpression),
        comparator: conditionVm.extractComparator(initialExpression),
        value: conditionVm.extractValue(initialExpression),
      );
      conditionVm.setControlsFrom(formData);
    }

    // Add the view model to the collection
    conditionFormViewModels.add(conditionVm);

    // Update the value change streams
    _updateConditionsValueChangesStream();

    // Only update condition if this is a user-initiated add (not from initialization)
    if (initialExpression == null) {
      updateCondition();
    }

    // print('Added condition, now have ${conditionFormViewModels.formViewModels.length} conditions',);
    // print('Form array now has ${conditionsArray.controls.length} controls');
  }

  @override
  void removeCondition(int index) {
    conditionFormViewModels.remove(
      conditionFormViewModels.formViewModels[index],
    );
    _updateConditionsValueChangesStream();

    // Update the condition to reflect the removal
    updateCondition();
  }

  @override
  void read([dynamic formData]) {
    conditionFormViewModels.read();
    super.read(formData);
  }

  @override
  void updateCondition() {
    // Prevent recursive updates
    if (_isUpdatingCondition) {
      return;
    }

    // Cancel any pending debounced update
    _updateDebounceTimer?.cancel();

    // For programmatic updates (like initialization), update immediately
    if (_isUpdatingProgrammatically) {
      _updateConditionImmediate();
      return;
    }

    // For user-initiated updates, use debouncing
    _updateDebounceTimer = Timer(_updateDebounceDelay, () {
      _updateConditionImmediate();
    });
  }

  void _updateConditionImmediate() {
    if (_isUpdatingCondition) {
      return;
    }

    _isUpdatingCondition = true;
    try {
      final composite = compositeExpression;

      // Serialize the composite to check for actual changes
      final newSerializedCondition = composite?.toJson() != null
          ? jsonEncode(composite!.toJson())
          : null;

      // Skip update if the condition hasn't actually changed
      if (newSerializedCondition == _lastSerializedCondition) {
        return;
      }

      // Cache the new serialized condition
      _lastSerializedCondition = newSerializedCondition;

      // print('Updating condition with composite: ${composite?.toJson()}');

      // Check if we have any conditions to save
      if (composite != null && composite.expressions.isNotEmpty) {
        // Create a new QuestionConditional with the composite expression
        final conditional = QuestionConditional.withCondition(composite);

        // Check if the value is actually different to avoid unnecessary updates
        final currentValue = questionConditionalControl.value;
        final shouldUpdate =
            currentValue == null ||
            jsonEncode(currentValue.condition.toJson()) !=
                jsonEncode(conditional.condition.toJson());

        // print('updateCondition: shouldUpdate = $shouldUpdate, currentValue = ${currentValue?.toJson()}, _isUpdatingProgrammatically = $_isUpdatingProgrammatically, questionConditionalControl.value = ${questionConditionalControl.value?.toJson()}');

        if (shouldUpdate) {
          if (_isUpdatingProgrammatically) {
            // During programmatic updates (like initialization), use updateValue to avoid
            // triggering form dirty state
            questionConditionalControl.updateValue(
              conditional,
              emitEvent: false,
            );
          } else {
            // During user-initiated changes, use normal assignment to properly
            // trigger form change detection
            questionConditionalControl.value = conditional;
          }

          // print('Set questionConditionalControl.value: ${questionConditionalControl.value?.condition.toJson()}',);
        }
      } else {
        // No conditions, set to null
        final shouldUpdate = questionConditionalControl.value != null;

        if (shouldUpdate) {
          if (_isUpdatingProgrammatically) {
            questionConditionalControl.updateValue(null, emitEvent: false);
          } else {
            questionConditionalControl.value = null;
          }
          // print('Set questionConditionalControl.value to null');
        }
      }

      // Update the form controls to reflect the current state
      _syncFormControlsWithConditions();
    } finally {
      _isUpdatingCondition = false;
    }
  }

  /// Synchronizes the form controls with the current conditions state
  /// This ensures that form.value contains the correct serializable data
  void _syncFormControlsWithConditions() {
    // Update the logicType control to reflect current state
    logicTypeControl.updateValue(
      logicTypeControl.value ?? LogicType.and,
      emitEvent: false,
    );

    // Since the conditional form controls are no longer part of the main form,
    // we don't need to sync the conditionsArray as it doesn't affect isDirty
    // The questionConditionalControl is the single source of truth and is
    // already being updated in updateCondition()
  }

  void _updateConditionsValueChangesStream() {
    _conditionsValueChangesSubscription?.cancel();

    // Create streams for all view models' forms and the logic type control
    final List<Stream> streams = [];

    // Add the logic type control to the streams
    streams.add(logicTypeControl.valueChanges.distinct());

    // Listen to the form array changes
    streams.add(conditionsArray.valueChanges.distinct());

    for (final viewModel in conditionFormViewModels.formViewModels) {
      // Combine all control changes for this view model into a single stream
      // This reduces the number of individual streams and prevents cascading updates
      final combinedStream = StreamGroup.merge([
        viewModel.questionIdControl.valueChanges.distinct(),
        viewModel.comparatorControl.valueChanges.distinct(),
        viewModel.valueControl.valueChanges.distinct(),
      ]);

      streams.add(combinedStream);
    }

    if (streams.isEmpty) {
      _conditionsValueChangesStream = const Stream<void>.empty();
    } else {
      _conditionsValueChangesStream = StreamGroup.merge(streams)
          .distinct()
          .asBroadcastStream();

      _conditionsValueChangesSubscription = _conditionsValueChangesStream.listen(
        (_) {
          // print('Condition value changed, updating condition');
          // Use the debounced update method which will handle timing internally
          updateCondition();
        },
      );
    }
  }

  @override
  void dispose() {
    _updateDebounceTimer?.cancel();
    _conditionsValueChangesSubscription?.cancel();
    super.dispose();
  }

  @override
  set formMode(FormMode mode) {
    super.formMode = mode;

    // Propagate form mode to all condition row form controllers
    for (final conditionViewModel in conditionFormViewModels.formViewModels) {
      conditionViewModel.formMode = mode;
    }
  }

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: tr.form_mode_visibility_create,
    FormMode.edit: tr.form_mode_visibility_edit,
    FormMode.readonly: tr.form_mode_visibility_readonly,
  };

  @override
  void setControlsFrom(dynamic data) {
    // Set flag to indicate this is a programmatic update during initialization
    _isUpdatingProgrammatically = true;

    try {
      final conditional = questionConditionalControl.value;
      if (conditional != null) {
        final compositeExpression = conditional.condition;
        logicTypeControl.value = compositeExpression.logicType;

        conditionFormViewModels.reset(null);

        if (ConditionRowFormViewModel.availableQuestions.isEmpty) {
          _deferredExpressions = compositeExpression.expressions;
        } else {
          final validExpressions = _filterValidExpressions(
            compositeExpression.expressions,
          );

          for (final expression in validExpressions) {
            addCondition(initialExpression: expression);
          }
        }
        // Synchronously update the condition after initialization to ensure
        // the parent control reflects the correct state
        updateCondition();
      } else {
        logicTypeControl.value = LogicType.and;
        conditionFormViewModels.reset(null);

        // Also update when there are no conditions
        updateCondition();
      }
      _updateConditionsValueChangesStream();
    } finally {
      // Reset the flag
      _isUpdatingProgrammatically = false;
    }
  }

  List<Expression>? _deferredExpressions;

  @override
  void initializeDeferredConditions() {
    if (_deferredExpressions != null &&
        ConditionRowFormViewModel.availableQuestions.isNotEmpty) {
      _isUpdatingProgrammatically = true;
      try {
        conditionFormViewModels.reset(null);

        final validExpressions = _filterValidExpressions(_deferredExpressions!);
        for (final expression in validExpressions) {
          addCondition(initialExpression: expression);
        }

        _deferredExpressions = null; // Clear deferred expressions
        updateCondition();
        _updateConditionsValueChangesStream();
      } finally {
        _isUpdatingProgrammatically = false;
      }
    }
  }

  List<Expression> _filterValidExpressions(List<Expression> expressions) {
    final availableQuestionIds = ConditionRowFormViewModel.availableQuestions
        .map((q) => q.id)
        .toSet();

    return expressions.where((expression) {
      final questionId = _extractQuestionIdFromExpression(expression);
      return questionId != null && availableQuestionIds.contains(questionId);
    }).toList();
  }

  String? _extractQuestionIdFromExpression(Expression expression) {
    if (expression is ValueExpression) {
      return expression.target;
    } else if (expression is NotExpression &&
        expression.expression is ValueExpression) {
      return (expression.expression as ValueExpression).target;
    }
    return null;
  }

  @override
  void cleanupInvalidConditions() {
    final availableQuestionIds = ConditionRowFormViewModel.availableQuestions
        .map((q) => q.id)
        .toSet();

    final indicesToRemove = <int>[];

    for (int i = 0; i < conditionFormViewModels.formViewModels.length; i++) {
      final conditionVm = conditionFormViewModels.formViewModels[i];
      final questionId = conditionVm.questionIdControl.value;

      if (questionId == null || !availableQuestionIds.contains(questionId)) {
        indicesToRemove.add(i);
      }
    }

    for (int i = indicesToRemove.length - 1; i >= 0; i--) {
      removeCondition(indicesToRemove[i]);
    }

    if (indicesToRemove.isNotEmpty) {
      updateCondition();
    }
  }

  @override
  QuestionConditional buildFormData() {
    // print('Building QuestionConditional from form data');

    final composite =
        compositeExpression ??
        CompositeExpression(logicType: LogicType.and, expressions: []);
    return QuestionConditional.withCondition(composite);
  }
}

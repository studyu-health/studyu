import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/utils/debouncer.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:studyu_designer_v2/utils/tuple.dart';
import 'package:studyu_designer_v2/utils/typings.dart';

enum FormMode() {
  create,
  readonly,
  edit,
}

class FormInvalidException() implements Exception;

class FormConfigException([final String? message]) implements Exception;

abstract class IFormViewModelDelegate<T extends FormViewModel>() {
  Future onSave(T formViewModel, FormMode prevFormMode);
  void onCancel(T formViewModel, FormMode prevFormMode);
}

abstract class IFormGroupController() {
  FormGroup get form;
}

class const FormControlOption<T>(
  final T value,
  final String label, {
  final String? description,
}) extends Equatable {
  @override
  List<Object?> get props => [value, label, description];
}

typedef FormControlUpdateFutureBuilder = Future Function(
  AbstractControl control,
);

/// This class represents a form view model.
///
/// It provides methods and properties to manage the state of a form,
/// including validation, autosave, and form mode (create, edit, readonly).
/// It also provides methods to save and cancel changes to the form.
///
/// This class is designed to be extended by other classes that provide
/// specific implementations for different types of forms.
abstract class FormViewModel<T>({
  var T? _formData,
  final IFormViewModelDelegate<FormViewModel<dynamic>>? delegate,
  var FormValidationSetEnum? _validationSet,
  final bool autosave = false,
}) implements IFormGroupController {
  this {
    _setFormData(_formData);
    initControls();
    _restoreControlsFromFormData();
    _formModeUpdated();
    _applyValidationSet(_validationSet);
    Future.microtask(() {
      finalizeInitializationBaseline();
    });

    if (autosave) {
      // Push to event queue to avoid listening to update events
      // triggered synchronously during initialization
      runAsync(enableAutosave);
    }
  }

  void finalizeInitializationBaseline() {
    prevFormValue = _getFullFormValue();
    form.markAsPristine();
  }

  T? get formData => _formData;
  set formData(T? formData) => _setFormData(formData);
  FormMode get formMode => _formMode;
  set formMode(FormMode mode) {
    _formMode = mode;
    _formModeUpdated();
  }

  FormMode _formMode = (_formData != null) ? FormMode.edit : FormMode.create;

  bool get isReadonly => formMode == FormMode.readonly;

  /// Enum that determines which [FormValidationConfig] should be selected
  /// from the [sharedValidationConfig] and applied to the [form].
  ///
  /// If null, the [AbstractControl]s contained in the [form] will be validated
  /// using their default configuration. Otherwise, the default configuration
  /// is discarded and replaced by the respective [FormValidationConfig].
  FormValidationSetEnum? get validationSet => _validationSet;
  set validationSet(FormValidationSetEnum? validationSet) {
    _validationSet = validationSet;
    _applyValidationSet(validationSet);
  }

  final List<StreamSubscription> _immediateFormChildrenSubscriptions = [];
  Debouncer? _immediateFormChildrenListenerDebouncer;

  CancelableOperation? _autosaveOperation;

  /// Map that stores the default enabled/disabled state for each control in
  /// the [form]
  final Map<String, bool> _defaultControlStates = {};

  /// Map that stores the default [AbstractControl.validators] and
  /// [AbstractControl.asyncValidators] for each control in the [form]
  final Map<String, Tuple<List<Validator>, List<AsyncValidator>>>
  _defaultControlValidators = {};

  /// Flag indicating whether the current [form] data is different from
  /// the most recently set [formData]
  ///
  /// The comparison is based on the [form]'s JSON [form.value], including
  /// values from disabled controls (which is not the case by default) so
  /// that controls can be marked as disabled when needed for the UI
  /// without affecting the dirty status.
  ///
  /// Note: for the JSON-based comparison to work, all [FormControl] and
  /// [FormArray] types must be JSON-serializable
  ///
  /// Note: [AbstractControl.dirty] does not work reliably when the [form]'s
  /// values are initialized in [setControlsFrom] (controls that are set
  /// programmatically are incorrectly marked as dirty without any user input).
  bool get isDirty {
    if (prevFormValue == null) return false;

    final isEqual =
        jsonEncode(prevFormValue, toEncodable: _jsonEncodable) ==
        jsonEncode(_getFullFormValue(), toEncodable: _jsonEncodable);

    return !isEqual;
  }

  static Object? _jsonEncodable(Object? value) {
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Enum) {
      return value.name;
    }
    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        result[entry.key.toString()] = _jsonEncodable(entry.value);
      }
      return result;
    }
    if (value is Iterable) {
      return value.map(_jsonEncodable).toList();
    }
    if (value is num || value is bool || value is String) {
      return value;
    }
    return value?.toString();
  }

  /// The [form]'s JSON value after initializing the controls with [formData]
  JsonMap? prevFormValue;

  /// Key used internally for storing properties of the [form] itself
  static const _formKey = '__form';

  /// Sets the form data and updates the form controls.
  ///
  /// This method is used to set the form data (`_formData`) and then update the form controls
  /// to reflect the new data. It does this by calling the `setControlsFrom` method, which
  /// is responsible for updating the form controls based on the provided data.
  ///
  /// After updating the form controls, it also updates the `prevFormValue` property to store
  /// the current state of the form. This is used later to determine if the form is dirty
  /// (i.e., if the form data has changed since it was last set).
  ///
  /// Finally, it calls the `form.updateValueAndValidity` method to ensure that the form's
  /// value and validity state are correctly updated after the form controls have been changed.
  void _setFormData(T? formData) {
    _formData = formData;
    if (formData != null) {
      setControlsFrom(formData);
    }
    finalizeInitializationBaseline();
  }

  JsonMap _getFullFormValue() {
    _rememberDefaultControlStates();

    // 1. Temporarily enable all controls
    for (final control in form.controls.values) {
      control.markAsEnabled(emitEvent: false, updateParent: false);
    }
    // 2. CRITICAL: Force the FormGroup to rebuild its value cache!
    form.updateValueAndValidity(updateParent: false, emitEvent: false);

    // 3. Deep copy the full value
    final fullValue = jsonDecode(
      jsonEncode(form.value, toEncodable: _jsonEncodable),
    ) as JsonMap;

    // 4. Restore original states and rebuild the cache again
    _restoreControlStates(emitEvent: false, updateParent: false);
    form.updateValueAndValidity(updateParent: false, emitEvent: false);

    return fullValue;
  }

  void _rememberDefaultControlStates() {
    for (final entry in form.controls.entries) {
      final controlName = entry.key;
      final control = entry.value;
      if (!_defaultControlStates.containsKey(controlName)) {
        _defaultControlStates[controlName] = control.enabled;
      }
    }
  }

  void _rememberDefaultControlValidators() {
    for (final entry in form.controls.entries) {
      final controlName = entry.key;
      final control = entry.value;
      if (!_defaultControlValidators.containsKey(controlName)) {
        _defaultControlValidators[controlName] = Tuple(
          control.validators,
          control.asyncValidators,
        );
      }
    }
    if (!_defaultControlValidators.containsKey(_formKey)) {
      _defaultControlValidators[_formKey] = Tuple(
        form.validators,
        form.asyncValidators,
      );
    }
  }

  Tuple<List<Validator>, List<AsyncValidator>>? _getDefaultValidators(
    String controlName,
  ) {
    return _defaultControlValidators[controlName];
  }

  void _disableAllControls() {
    for (final control in form.controls.values) {
      control.markAsDisabled();
    }
    assert(form.allControlsDisabled());
  }

  /// Restores the enabled/disabled state of each form control.
  ///
  /// This method is used to restore the enabled/disabled state of each form control
  /// to its default state. It does this by iterating over each control in the form
  /// and checking the `_defaultControlStates` map, which stores the default state
  /// for each control.
  ///
  /// If a control's default state is enabled, it calls `control.markAsEnabled`.
  /// If a control's default state is disabled, it calls `control.markAsDisabled`.
  ///
  /// This method is typically called when the form mode changes. For example, when
  /// switching from edit mode to read-only mode, all controls are disabled. When
  /// switching back to edit mode, this method is used to restore the controls to
  /// their original states.
  ///
  /// The `emitEvent` and `updateParent` parameters are used to control whether
  /// changing the state of a control should emit an event and whether it should
  /// update the state of its parent control.
  void _restoreControlStates({
    bool emitEvent = true,
    bool updateParent = true,
  }) {
    for (final entry in form.controls.entries) {
      final controlName = entry.key;
      final control = entry.value;
      final isEnabledByDefault = _defaultControlStates[controlName] ?? true;
      if (isEnabledByDefault) {
        control.markAsEnabled(emitEvent: emitEvent, updateParent: updateParent);
      } else {
        control.markAsDisabled(
          emitEvent: emitEvent,
          updateParent: updateParent,
        );
      }
    }
  }

  void _formModeUpdated() {
    switch (formMode) {
      case FormMode.readonly:
        _rememberDefaultControlStates();
        _disableAllControls();
      case FormMode.create:
      case FormMode.edit:
        _restoreControlStates();
    }
  }

  void _restoreControlsFromFormData() {
    if (formData != null) {
      setControlsFrom(formData as T);
      form.updateValueAndValidity();
    }
  }

  void revalidate() {
    _applyValidationSet(validationSet);
  }

  /// Updates and re-evaluates [AbstractControl.validators] and
  /// [AbstractControl.asyncValidators] for all [FormControl]'s in the
  /// current [form] (or the [FormGroup] itself) with the validators of
  /// the [FormValidationConfig] corresponding to the given [validationSet]
  /// (as defined in [sharedValidationConfig])
  ///
  /// Note: this will only look at immediate child controls of the [form]
  /// and not walk the whole tree
  void _applyValidationSet(FormValidationSetEnum? validationSet) {
    if (validationSet == null) {
      return; // retain default form validators
    }
    final formValidationConfig = sharedValidationConfig[validationSet];
    if (formValidationConfig == null) {
      throw FormConfigException(
        "Failed to lookup FormValidationConfig for key: $validationSet",
      );
    }

    // Build mapping from control => merged config
    final Map<AbstractControl, FormControlValidation> controlConfigs = {};
    for (final controlValidationConfig in formValidationConfig) {
      final existingConfig = controlConfigs[controlValidationConfig.control];
      final mergedConfig = controlValidationConfig.merge(existingConfig);
      controlConfigs[controlValidationConfig.control] = mergedConfig;
    }

    // Store defaults for each control if it's not known yet
    // Will not override defaults when the control is already known
    _rememberDefaultControlValidators();

    // Helper function to reset & change the validators on a single control
    void resetAndUpdateControlValidators(
      String controlName,
      AbstractControl control,
    ) {
      // Reset the control validators to its cached defaults
      final defaultValidators = _getDefaultValidators(controlName);
      assert(defaultValidators?.first != null);
      assert(defaultValidators?.second != null);

      control.setValidators(defaultValidators?.first ?? [], emitEvent: false);
      control.setAsyncValidators(
        defaultValidators?.second ?? [],
        emitEvent: false,
      );

      // Apply control-specific config (if any)
      //
      // Note: if there is no config defined for this control, it will
      // be reset to its cached defaults (from the code section above)
      // as opposed to being cleared completely
      if (controlConfigs.containsKey(control)) {
        final controlConfig = controlConfigs[control]!;
        control.setValidators(controlConfig.validators, emitEvent: false);
        if (controlConfig.asyncValidators != null) {
          control.setAsyncValidators(
            controlConfig.asyncValidators!,
            emitEvent: false,
          );
        }
        control.validationMessages = controlConfig.validationMessages;
      }

      // Note: [FormGroup.updateValueAndValidity] does *not* revalidate
      // any child controls! Hence we need to revalidate them explicitly
      control.updateValueAndValidity(updateParent: false, emitEvent: false);
    }

    // Reset and update the validators of all direct child controls
    for (final entry in form.controls.entries) {
      final controlName = entry.key;
      final control = entry.value;
      resetAndUpdateControlValidators(controlName, control);
    }

    // Reset and update the validators of the form itself
    resetAndUpdateControlValidators(_formKey, form);
  }

  String get title => titles[formMode] ?? "[Missing title]";
  bool get isValid => form.valid;

  void read([T? formData]) {
    if (formData != null) {
      this.formData = formData;
    }
    formMode = FormMode.readonly;
  }

  Future save() async {
    if (!form.valid) {
      throw FormInvalidException();
    }

    // Note: order of operations is important here so that the delegate (if any)
    // sees the latest [data] but the previous [formMode]
    final prevFormMode = formMode;

    if (isDirty) {
      final currentFormData = buildFormData();
      // Reinitialize the viewmodel with the [form]'s current data, resulting
      // in an update to the [form] controls from calling [_setFormData]
      // and [setControlsFrom] internally
      formData = currentFormData;
    } else {
      // Do nothing - this is important!
      // Otherwise we may enter an infinite loop from calling [_setFormData]
      // and [setControlsFrom] internally. Calling [setControlsFrom] may result
      // in update events emitted by the reactive controls as their values are
      // re-initialized, which re-triggers the valueChanges stream subscription
      // used for auto-saving (entering the infinite loop)
    }
    await delegate?.onSave(this, prevFormMode);

    // Put form into edit mode with saved data
    if (prevFormMode == FormMode.create) {
      formMode = FormMode.edit;
    }
  }

  Future cancel() async {
    if (formMode != FormMode.readonly) {
      _restoreControlsFromFormData();
    }
    delegate?.onCancel(this, formMode);
  }

  /// Enables the auto-save functionality for the form.
  ///
  /// This method sets up the form to automatically save its data whenever any changes are made to the form controls.
  /// It does this by setting up a listener for each form control's `valueChanges` stream and initiating a save operation
  /// whenever a form control's value changes.
  ///
  /// The `debounce` parameter is used to specify the delay (in milliseconds) before the save operation is triggered
  /// after the last change to the form controls. This is useful to prevent excessive save operations if the form controls
  /// are being updated frequently.
  ///
  /// The `onlyValid` parameter is not used in the current implementation.
  ///
  /// If there are any existing subscriptions to the form control's value changes (i.e., if auto-save has already been enabled),
  /// this method returns immediately to avoid setting up auto-save multiple times.
  ///
  /// The save operation is wrapped in a `CancelableOperation` to allow it to be cancelled if necessary.
  void enableAutosave({
    int debounce = Config.formAutosaveDebounce,
    bool onlyValid = true,
  }) {
    if (_immediateFormChildrenSubscriptions.isNotEmpty) {
      return;
    }
    listenToImmediateFormChildren((control) {
      final saveFuture = save();
      _autosaveOperation = CancelableOperation.fromFuture(saveFuture);
      return saveFuture;
    }, debounce: debounce);
  }

  void listenToImmediateFormChildren(
    FormControlUpdateFutureBuilder futureBuilder, {
    int debounce = 1500,
  }) {
    // Initialize debounce helper if needed
    if (debounce != 0) {
      _immediateFormChildrenListenerDebouncer ??= Debouncer(
        milliseconds: debounce,
        leading: false,
      );
    }

    for (final control in form.controls.values) {
      void boundListener(event) {
        if (debounce == 0) {
          futureBuilder(control);
        } else {
          _immediateFormChildrenListenerDebouncer!(
            futureBuilder: () => futureBuilder(control),
          );
        }
      }

      if (control is FormGroup) {
        continue; // don't listen to nested descendants
      } else if (control is FormArray) {
        // We do not listen to FormArray changes. Instead the study is getting
        // saved directly through the respective menu action.
        // There seems to be a bug related to control.collectionChanges because
        // it triggers on first load, even though the length of the array has not changed
        continue;
        /* final collectionChanges =
            control.collectionChanges.listen(boundListener);
        // don't subscribe to control.valueChanges
        _immediateFormChildrenSubscriptions.add(collectionChanges);*/
      } else if (control is FormControl) {
        final valueChanges = control.valueChanges.listen(boundListener);
        _immediateFormChildrenSubscriptions.add(valueChanges);
      }
    }
  }

  /// Call after changing / adding / removing the child controls in [form]
  /// to perform necessary housekeeping
  void markFormGroupChanged() {
    revalidate();
    _formModeUpdated();
    form.updateValueAndValidity();
  }

  void dispose() {
    _immediateFormChildrenListenerDebouncer?.dispose();
    _autosaveOperation?.cancel();
    /*for (final subscription in _immediateFormChildrenSubscriptions) {
      subscription.pause();
    }*/
  }

  // - Subclass responsibility

  Map<FormMode, String> get titles;

  /// The available set of validation configurations for the [form] managed
  /// by this view model.
  ///
  /// One of the [FormValidationConfig]s is chosen at runtime based on the
  /// current [validationSet] and applied to the [form].
  FormValidationConfigSet get sharedValidationConfig => {};

  /// Initialize the values of all [FormControl]s in the [form]
  void setControlsFrom(T data);
  T buildFormData();

  void initControls() {
    // subclass responsibility (optional)
  }
}

import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/utils/tuple.dart';

/// Interface to be implemented by an enum that is used for indexing into
/// a [FormValidationConfigSet]
abstract class FormValidationSetEnum();

/// Validator configuration that is applied to the given [control] at runtime
class const FormControlValidation({
  required final AbstractControl<dynamic> control,
  required final List<Validator> validators,
  final List<AsyncValidator>? asyncValidators,
  required final Map<String, ValidationMessageFunction> validationMessages,
}) {
  FormControlValidation merge(FormControlValidation? other) {
    if (other == null) {
      return this;
    }
    if (control != other.control) {
      throw Exception(
        "Cannot merge FormControlValidationConfig for different controls.",
      );
    }
    return FormControlValidation(
      control: control,
      validators: [...validators, ...other.validators],
      asyncValidators: [
        ...asyncValidators ?? [],
        ...other.asyncValidators ?? [],
      ],
      validationMessages: {...validationMessages, ...other.validationMessages},
    );
  }
}

typedef FormValidationConfig = List<FormControlValidation>;

/// Signature for a set of validator configurations indexed by a
/// [FormValidationSetEnum] which is used to look up the validator configuration
/// to be applied based on the [FormViewModel]'s current
/// [FormViewModel.validationSet].
typedef FormValidationConfigSet =
    Map<FormValidationSetEnum, List<FormControlValidation>>;

/// Extension to get/set control-specific validation messages from the
/// [AbstractControl] object itself
extension AbstractControlX on AbstractControl {
  static final Map<AbstractControl, Map<String, ValidationMessageFunction>>
  _controlValidationMessages = {};

  Map<String, ValidationMessageFunction> get validationMessages =>
      _controlValidationMessages[this] ?? {};
  set validationMessages(
    Map<String, ValidationMessageFunction> validationMessages,
  ) => _controlValidationMessages[this] = validationMessages;
}

List<Tuple<AbstractControl, String>> _collectValidationErrorMessages(
  AbstractControl control,
) {
  final List<Tuple<AbstractControl, String>> allValidationErrorMessages = [];

  if (!control.enabled || !control.hasErrors) {
    return [];
  }

  for (final error in control.errors.entries) {
    // Only collect errors at the control that generated it & has a
    // corresponding validation message registered
    //
    // Note: this is needed as the [AbstractControl.errors] object is a
    // nested JSON with the same structure as [AbstractControl.value].
    // If the given [control] is not a leaf in the form control tree structure
    // (i.e. a [FormGroup]), we want to skip these intermediary path
    // descriptors & collect the error at the child control instead where we
    // can resolve its validation error message correctly.
    if (control is FormGroup) {
      final isChildError = control.controls.containsKey(error.key);
      if (isChildError) {
        continue;
      }
    }

    final validationMessageFunc = control.validationMessages[error.key];
    final String validationMessage =
        validationMessageFunc?.call(error.value as Object) ?? '[${error.key}]';
    allValidationErrorMessages.add(Tuple(control, validationMessage));
  }

  return allValidationErrorMessages;
}

List<Tuple<AbstractControl, String>>? _getControlErrorMessages(
  AbstractControl control,
) {
  List<Tuple<AbstractControl, String>>? errorMessages;
  // Typecasting needed as a workaround because dynamic dispatch
  // is not working properly with extension methods
  if (control is FormControl) {
    errorMessages = control.validationErrorMessages;
  }
  if (control is FormArray) {
    errorMessages = control.validationErrorMessages;
  }
  if (control is FormGroup) {
    errorMessages = control.validationErrorMessages;
  }
  return errorMessages;
}

extension FormControlXX on FormControl {
  List<Tuple<AbstractControl, String>> get validationErrorMessages {
    return _collectValidationErrorMessages(this);
  }
}

extension FormArrayX on FormArray {
  List<Tuple<AbstractControl, String>> get validationErrorMessages {
    final List<Tuple<AbstractControl, String>> allValidationErrorMessages =
        _collectValidationErrorMessages(this);

    for (final control in controls) {
      if (control.enabled && control.hasErrors) {
        final errorMessages = _getControlErrorMessages(control);
        if (errorMessages != null) {
          allValidationErrorMessages.addAll(errorMessages);
        }
      }
    }

    return allValidationErrorMessages;
  }
}

extension FormGroupX on FormGroup {
  List<Tuple<AbstractControl, String>> get validationErrorMessages {
    final List<Tuple<AbstractControl, String>> allValidationErrorMessages =
        _collectValidationErrorMessages(this);

    controls.forEach((_, control) {
      if (control.enabled && control.hasErrors) {
        final errorMessages = _getControlErrorMessages(control);
        if (errorMessages != null) {
          allValidationErrorMessages.addAll(errorMessages);
        }
      }
    });

    return allValidationErrorMessages;
  }

  List<String> get formattedErrorMessages =>
      validationErrorMessages.map((t) => t.second).toList();

  String get validationErrorSummary => getValidationErrorSummary();

  String getValidationErrorSummary({bool uniqueErrors = true}) {
    final errorMessages =
        (uniqueErrors
                ? {...formattedErrorMessages}.toList()
                : formattedErrorMessages)
            .map((message) => message.trim())
            .where((message) => message.isNotEmpty)
            .toList();
    if (errorMessages.isEmpty) {
      return '';
    }
    return "- ${errorMessages.join("\n- ")}";
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';

void main() {
  test('validation summary omits form array index errors', () {
    final minimumMeals =
        FormControl<int>(value: 0, validators: [Validators.min(1)])
          ..validationMessages = {
            ValidationMessage.min: (_) => 'Must be at least 1',
          };
    final form = FormGroup({
      'measurements': FormArray<int>([minimumMeals]),
    });

    expect(form.validationErrorSummary, '- Must be at least 1');
  });
}

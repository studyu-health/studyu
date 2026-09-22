import 'dart:async';

import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection_actions.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:test/test.dart';

class _TestFormData({
  @override required final String id,
  required final String value,
}) implements IFormData {
  @override
  _TestFormData copy() => _TestFormData(id: '${id}_copy', value: value);
}

class _TestFormViewModel({
  super.formData,
  super.delegate,
  final _TestFormViewModel? duplicate,
}) extends ManagedFormViewModel<_TestFormData> {
  final FormControl<String> valueControl = FormControl<String>(value: '');
  int saveCount = 0;

  @override
  late final FormGroup form = FormGroup({'value': valueControl});

  @override
  Map<FormMode, String> get titles => {};

  @override
  void setControlsFrom(_TestFormData data) {
    valueControl.value = data.value;
  }

  @override
  _TestFormData buildFormData() {
    return _TestFormData(id: formData?.id ?? 'new', value: valueControl.value!);
  }

  @override
  _TestFormViewModel createDuplicate() {
    return duplicate ?? _TestFormViewModel(formData: formData?.copy());
  }

  @override
  Future save() {
    saveCount += 1;
    return super.save();
  }
}

class _TestDelegate() implements IFormViewModelDelegate<_TestFormViewModel> {
  final saveCompleter = Completer<void>();

  @override
  void onCancel(_TestFormViewModel formViewModel, FormMode prevFormMode) {}

  @override
  Future<void> onSave(
    _TestFormViewModel formViewModel,
    FormMode prevFormMode,
  ) => saveCompleter.future;
}

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(AppLocalizationsEn());
  });

  test('save waits for its delegate', () async {
    final delegate = _TestDelegate();
    final viewModel = _TestFormViewModel(delegate: delegate);

    var completed = false;
    final save = viewModel.save().then((_) => completed = true);
    await Future<void>.delayed(Duration.zero);

    expect(completed, isFalse);
    delegate.saveCompleter.complete();
    await save;
    expect(completed, isTrue);
  });

  test('duplicate action saves the duplicated view model', () async {
    final formArray = FormArray([]);
    final duplicate = _TestFormViewModel(
      formData: _TestFormData(id: 'duplicate', value: 'Question copy'),
    );
    final original = _TestFormViewModel(
      formData: _TestFormData(id: 'original', value: 'Question'),
      duplicate: duplicate,
    );
    final collection =
        FormViewModelCollection<_TestFormViewModel, _TestFormData>([
          original,
        ], formArray);
    formArray.add(original.form);

    final duplicateAction = collection
        .availableActions(original)
        .singleWhere((action) => action.type == ModelActionType.duplicate);

    duplicateAction.onExecute();
    await Future<void>.delayed(Duration.zero);

    expect(collection.formViewModels, [original, duplicate]);
    expect(original.saveCount, 0);
    expect(duplicate.saveCount, 1);
  });

  test(
    'question data can be copied before response validity is initialized',
    () {
      final data = BoolQuestionFormData(
        questionId: 'question-1',
        questionText: 'Temporary duplicate test',
        questionType: SurveyQuestionType.bool,
      );

      final duplicate = data.copy();

      expect(duplicate.questionId, isNot(data.questionId));
      expect(duplicate.questionText, 'Temporary duplicate test (Copy)');
      expect(duplicate.responseOptionsValidity, isEmpty);
    },
  );
}

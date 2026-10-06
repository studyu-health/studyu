import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class const StudyTitleInputGroup({
  required final FormControl<String> titleControl,
  required final FormControl<IconOption> iconControl,
  final Map<String, ValidationMessageFunction>? titleValidationMessages,
  final Map<String, ValidationMessageFunction>? iconValidationMessages,
  final List<IconOption>? iconOptions,
  super.key,
}) extends StatelessWidget {
  static const double controlSpacing = 16.0;
  static const double controlHeight = IconPickerField.controlSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReactiveIconPicker(
          key: const ValueKey('study_title_icon_picker'),
          formControl: iconControl,
          iconOptions: iconOptions ?? IconPack.material,
          squareFieldSize: controlHeight,
          useSquareField: true,
          selectedIconSize: 24.0,
          validationMessages: iconValidationMessages,
        ),
        const SizedBox(width: controlSpacing),
        Expanded(
          child: ReactiveTextField(
            key: const ValueKey('study_title_text_field'),
            formControl: titleControl,
            decoration: InputDecoration(
              hintText: tr.form_field_study_title,
              constraints: const BoxConstraints(minHeight: controlHeight),
              isDense: true,
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
            validationMessages: titleValidationMessages,
          ),
        ),
      ],
    );
  }
}

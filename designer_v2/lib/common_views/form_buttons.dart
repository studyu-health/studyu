import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/secondary_button.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

/// A cancel / dismiss button for use with [FormScaffold] [showFormSideSheet)
/// Heavily inspired by [CloseButton]
class const DismissButton({
  final String? text,

  /// An override callback to perform instead of the default behavior which is
  /// to pop the [Navigator].
  ///
  /// It can, for instance, be used to pop the platform's navigation stack
  /// via [SystemNavigator] instead of Flutter's [Navigator] in add-to-app
  /// situations.
  ///
  /// Defaults to null.
  final VoidCallback? onPressed,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (key) {
        if (key.logicalKey.keyLabel == "Escape") {
          Navigator.maybePop(context);
        }
      },
      child: SecondaryButton(
        key: const ValueKey('form_dismiss_button'),
        text: text ?? tr.dialog_cancel,
        icon: null,
        //tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        onPressed: () {
          if (onPressed != null) {
            onPressed!();
          } else {
            Navigator.maybePop(context);
          }
        },
      ),
    );
  }
}

List<Widget> buildFormButtons(FormViewModel formViewModel, FormMode formMode) {
  final modifyActionButtons = [
    ReactiveFormConsumer(
      // enable re-rendering based on form validation status
      builder: (context, form, child) {
        return retainSizeInAppBar(
          DismissButton(
            key: const ValueKey('form_cancel_button'),
            onPressed: () => Navigator.maybePop(context),
          ),
        );
      },
    ),
    ReactiveFormConsumer(
      // enable re-rendering based on form validation status
      builder: (context, form, child) {
        return retainSizeInAppBar(
          PrimaryButton(
            key: const ValueKey('form_save_button'),
            text: tr.dialog_save,
            tooltipDisabled:
                "${tr.form_invalid_prompt}\n\n${formViewModel.form.validationErrorSummary}",
            icon: null,
            enabled: formViewModel.isValid,
            onPressedFuture: (formViewModel.isValid)
                ? () => formViewModel.save().then(
                    // Close the form (side sheet or scaffold route) if future
                    // completed successfully
                    (value) {
                      if (context.mounted) Navigator.maybePop(context);
                    },
                  )
                : null,
          ),
        );
      },
    ),
  ];
  final readonlyActionButtons = [
    ReactiveFormConsumer(
      // enable re-rendering based on form validation status
      builder: (context, form, child) {
        return retainSizeInAppBar(
          DismissButton(
            key: const ValueKey('form_close_button'),
            text: tr.dialog_close,
            onPressed: () => Navigator.maybePop(context),
          ),
        );
      },
    ),
  ];

  final defaultActionButtons =
      {
        FormMode.create: modifyActionButtons,
        FormMode.edit: modifyActionButtons,
        FormMode.readonly: readonlyActionButtons,
      }[formViewModel.formMode] ??
      modifyActionButtons;

  return defaultActionButtons;
}

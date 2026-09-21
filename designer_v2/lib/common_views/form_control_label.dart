import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';

typedef FormControlVoidCallback<T> = void Function(
  AbstractControl<T> formControl,
);

class const FormControlLabel({
  required final AbstractControl<dynamic> formControl,
  required final String text,
  final TextStyle? textStyle,
  final bool isClickable = true,
  final FormControlVoidCallback? onClick,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateColorStyle = (formControl.disabled)
        ? TextStyle(color: theme.disabledColor)
        : null;

    return MouseEventsRegion(
      builder: (context, states) {
        return Text(
          text,
          style: theme.textTheme.bodySmall
              ?.merge(textStyle)
              .merge(stateColorStyle),
          overflow: TextOverflow.clip,
        );
      },
      onTap: (!isClickable || formControl.disabled)
          ? null
          : () {
              if (onClick != null) {
                onClick!(formControl);
              } else {
                if (formControl is AbstractControl<bool>) {
                  // Auto-toggle boolean controls
                  formControl.value =
                      formControl.value == null || !(formControl.value as bool);
                  formControl.markAsDirty();
                } else {
                  // Otherwise just focus the control
                  formControl.focus();
                }
              }
            },
    );
  }
}

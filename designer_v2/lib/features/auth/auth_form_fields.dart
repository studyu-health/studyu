import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

// ignore: prefer_const_constructors_in_immutables
class EmailTextField({
  final String? formControlName,
  final FormControl? formControl,
  String? labelText,
  String? hintText,
  super.key,
}) extends StatefulWidget {
  this
    : assert(
        (formControlName != null && formControl == null) ||
            (formControlName == null && formControl != null),
        "Must provide either formControlName or formControl",
      );

  final String labelText = labelText ?? tr.form_field_email;
  final String? hintText = hintText ?? tr.form_field_email_hint;
  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState() extends State<EmailTextField> {
  @override
  Widget build(BuildContext context) {
    return FormTableLayout(
      rowLayout: FormTableRowLayout.vertical,
      rows: [
        FormTableRow(
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          input: ReactiveTextField(
            key: const ValueKey('auth_email_field'),
            formControl: widget.formControl,
            formControlName: widget.formControlName,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: prefer_const_constructors_in_immutables
class PasswordTextField({
  final String? formControlName,
  final FormControl? formControl,
  final Function(FormControl control)? onSubmitted,
  String? labelText,
  String? hintText,
  super.key,
}) extends StatefulWidget {
  this
    : assert(
        (formControlName != null && formControl == null) ||
            (formControlName == null && formControl != null),
        "Must provide either formControlName or formControl",
      );

  final String labelText = labelText ?? tr.form_field_password;
  final String? hintText = hintText ?? tr.form_field_password_hint;
  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState() extends State<PasswordTextField> {
  late bool passwordVisibility = false;

  @override
  Widget build(BuildContext context) {
    return FormTableLayout(
      rowLayout: FormTableRowLayout.vertical,
      rows: [
        FormTableRow(
          input: ReactiveTextField(
            key: const ValueKey('auth_password_field'),
            formControl: widget.formControl,
            formControlName: widget.formControlName,
            obscureText: !passwordVisibility,
            onSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              suffixIcon: InkWell(
                key: const ValueKey('auth_password_visibility_toggle'),
                onTap: () =>
                    setState(() => passwordVisibility = !passwordVisibility),
                focusNode: FocusNode(skipTraversal: true),
                child: Icon(
                  passwordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

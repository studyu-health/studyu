import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_fields.dart';
import 'package:studyu_designer_v2/features/auth/auth_inline_prompt_action.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class const PasswordRecoveryForm({super.key}) extends FormConsumerRefWidget {
  @override
  Widget build(BuildContext context, FormGroup form, WidgetRef ref) {
    const formKey = AuthFormKey.passwordRecovery;

    final state = ref.watch(authFormControllerProvider(formKey));
    final controller = ref.watch(authFormControllerProvider(formKey).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PasswordTextField(
          formControl: controller.getPasswordControl(),
          labelText: tr.form_field_password_new,
          hintText: tr.form_field_password_new_hint,
        ),
        const SizedBox(height: 12.0),
        PasswordTextField(
          formControl: controller.getPasswordConfirmationControl(),
          labelText: tr.form_field_password_new_confirm,
          hintText: tr.form_field_password_new_confirm_hint,
          onSubmitted: (_) => form.valid
              ? ref
                    .read(authFormControllerProvider(formKey).notifier)
                    .recoverPassword()
              : null,
        ),
        const SizedBox(height: 24.0),
        ReactiveFormConsumer(
          builder: (context, form, child) {
            return SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                icon: null,
                text: tr.action_button_password_reset,
                isLoading: state.isLoading,
                enabled: form.valid,
                onPressedFuture: () => ref
                    .read(authFormControllerProvider(formKey).notifier)
                    .recoverPassword(),
                tooltipDisabled: tr.form_invalid_prompt,
                innerPadding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 10.0,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24.0),
        const Divider(height: 1),
        const SizedBox(height: 12.0),
        AuthInlinePromptAction(
          promptText: tr.link_login_description2,
          actionText: tr.link_login,
          onPressed: () =>
              ref.read(routerProvider).dispatch(RoutingIntents.login),
        ),
      ],
    );
  }
}

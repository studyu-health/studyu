import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_fields.dart';
import 'package:studyu_designer_v2/features/auth/auth_inline_prompt_action.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

class const LoginForm({super.key}) extends FormConsumerRefWidget {
  @override
  Widget build(BuildContext context, FormGroup form, WidgetRef ref) {
    const formKey = AuthFormKey.login;

    final theme = Theme.of(context);
    final state = ref.watch(authFormControllerProvider(formKey));
    final controller = ref.watch(authFormControllerProvider(formKey).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmailTextField(
          key: const ValueKey('login_email'),
          formControl: controller.getEmailControl(),
        ),
        const SizedBox(height: 4.0),
        PasswordTextField(
          key: const ValueKey('login_password'),
          formControl: controller.getPasswordControl(),
          onSubmitted: (_) => form.valid
              ? ref.read(authFormControllerProvider(formKey).notifier).signIn()
              : null,
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Hyperlink(
              key: const ValueKey('forgot_password_link'),
              text: tr.link_forgot_password,
              style: TextStyle(fontSize: theme.textTheme.bodySmall!.fontSize),
              onClick: () => ref
                  .read(routerProvider)
                  .dispatch(RoutingIntents.passwordForgot),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        ReactiveFormConsumer(
          builder: (context, form, child) {
            return SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                key: const ValueKey('login_button'),
                icon: Icons.login,
                text: tr.action_button_login,
                isLoading: state.isLoading,
                enabled: form.valid,
                onPressedFuture: () => ref
                    .read(authFormControllerProvider(formKey).notifier)
                    .signIn(),
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
          key: const ValueKey('signup_link'),
          promptText: tr.link_signup_description,
          actionText: tr.link_signup,
          onPressed: () =>
              ref.read(routerProvider).dispatch(RoutingIntents.signup),
        ),
      ],
    );
  }
}

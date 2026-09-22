import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_fields.dart';
import 'package:studyu_designer_v2/features/auth/auth_inline_prompt_action.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/repositories/app_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:url_launcher/url_launcher.dart';

class const SignupForm({super.key}) extends FormConsumerRefWidget {
  @override
  Widget build(BuildContext context, FormGroup form, WidgetRef ref) {
    const formKey = AuthFormKey.signup;

    final theme = Theme.of(context);
    final state = ref.watch(authFormControllerProvider(formKey));
    final controller = ref.watch(authFormControllerProvider(formKey).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmailTextField(
          key: const ValueKey('signup_email'),
          formControl: controller.getEmailControl(),
        ),
        //const SizedBox(height: 12.0),
        const SizedBox(height: 4.0),
        PasswordTextField(
          key: const ValueKey('signup_password'),
          formControl: controller.getPasswordControl(),
        ),
        //const SizedBox(height: 12.0),
        const SizedBox(height: 4.0),
        PasswordTextField(
          key: const ValueKey('signup_password_confirm'),
          formControl: controller.getPasswordConfirmationControl(),
          labelText: tr.form_field_password_confirm,
          hintText: tr.form_field_password_confirm_hint,
          onSubmitted: (_) => form.valid
              ? ref.read(authFormControllerProvider(formKey).notifier).signUp()
              : null,
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: ReactiveCheckbox(
                key: ObjectKey(controller.getTermsOfServiceControl()),
                formControl: controller.getTermsOfServiceControl(),
              ),
            ),
            const SizedBox(width: 6.0),
            Flexible(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FormControlLabel(
                    formControl: controller.getTermsOfServiceControl(),
                    text: tr.signup_tos_intro,
                  ),
                  Hyperlink(
                    text: tr.signup_tos_terms_of_service,
                    onClick: () => _onClickTermsOfUse(ref),
                    style: TextStyle(
                      fontSize: theme.textTheme.bodySmall!.fontSize,
                      height: theme.textTheme.bodySmall!.height,
                    ),
                  ),
                  FormControlLabel(
                    formControl: controller.getTermsOfServiceControl(),
                    text: tr.signup_tos_and,
                  ),
                  Hyperlink(
                    text: tr.signup_tos_privacy_policy,
                    onClick: () => _onClickPrivacyPolicy(ref),
                    style: TextStyle(
                      fontSize: theme.textTheme.bodySmall!.fontSize,
                      height: theme.textTheme.bodySmall!.height,
                    ),
                  ),
                  FormControlLabel(
                    formControl: controller.getTermsOfServiceControl(),
                    text: tr.signup_tos_outro,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        ReactiveFormConsumer(
          builder: (context, form, child) {
            return SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                key: const ValueKey('signup_button'),
                text: tr.action_button_signup,
                isLoading: state.isLoading,
                enabled: form.valid,
                onPressedFuture: () => ref
                    .read(authFormControllerProvider(formKey).notifier)
                    .signUp(),
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
          key: const ValueKey('login_link'),
          promptText: tr.link_login_description,
          actionText: tr.link_login,
          onPressed: () =>
              ref.read(routerProvider).dispatch(RoutingIntents.login),
        ),
      ],
    );
  }

  void _onClickTermsOfUse(WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);
    final locale = ref.watch(localeProvider);

    launchUrl(
      appConfig.maybeWhen(
        data: (value) =>
            Uri.parse(value.designerTerms[locale.languageCode] ?? ""),
        orElse: () => Uri.parse(''),
      ),
    );
  }

  void _onClickPrivacyPolicy(WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);
    final locale = ref.watch(localeProvider);

    launchUrl(
      appConfig.maybeWhen(
        data: (value) =>
            Uri.parse(value.designerPrivacy[locale.languageCode] ?? ""),
        orElse: () => Uri.parse(''),
      ),
    );
  }
}

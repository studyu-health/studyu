import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/secondary_button.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/features/account/study_import.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_fields.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/language_picker.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';

class const AccountSettingsDialog({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<AccountSettingsDialog> createState() =>
      _AccountSettingsDialogState();
}

class _AccountSettingsDialogState()
    extends ConsumerState<AccountSettingsDialog> {
  bool _isImported = false;

  Widget _buildDateTimePreferences(StudyUUser user) {
    final container = ProviderScope.containerOf(context);
    final repository = container.read(userRepositoryProvider);
    return FormTableLayout(
      rowSpacing: 24.0,
      rows: [
        FormTableRow(
          label: tr.date_format,
          input: Align(
            alignment: Alignment.centerRight,
            child: DropdownButton<DateFormatPreference?>(
              value: user.preferences.dateFormat,
              items: [
                DropdownMenuItem<DateFormatPreference?>(child: Text(tr.system)),
                ...DateFormatPreference.values.map(
                  (format) => DropdownMenuItem(
                    value: format,
                    child: Text(_dateFormatLabel(format)),
                  ),
                ),
              ],
              onChanged: (value) async {
                final currentContext = context;
                try {
                  final savedUser = await repository.updateDateFormat(value);
                  container.read(userStateProvider.notifier).setUser(savedUser);
                } catch (error) {
                  debugPrint('Could not save date format preference: $error');
                  if (!currentContext.mounted) return;
                  ScaffoldMessenger.of(currentContext)
                      .showSnackBar(SnackBar(content: Text(tr.sync_failed)));
                }
              },
            ),
          ),
        ),
        FormTableRow(
          label: tr.time_format,
          input: Align(
            alignment: Alignment.centerRight,
            child: DropdownButton<TimeFormatPreference?>(
              value: user.preferences.timeFormat,
              items: [
                DropdownMenuItem<TimeFormatPreference?>(child: Text(tr.system)),
                ...TimeFormatPreference.values.map(
                  (format) => DropdownMenuItem(
                    value: format,
                    child: Text(_timeFormatLabel(format)),
                  ),
                ),
              ],
              onChanged: (value) async {
                final currentContext = context;
                try {
                  final savedUser = await repository.updateTimeFormat(value);
                  container.read(userStateProvider.notifier).setUser(savedUser);
                } catch (error) {
                  debugPrint('Could not save time format preference: $error');
                  if (!currentContext.mounted) return;
                  ScaffoldMessenger.of(currentContext)
                      .showSnackBar(SnackBar(content: Text(tr.sync_failed)));
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String _dateFormatLabel(DateFormatPreference format) {
    return switch (format) {
      DateFormatPreference.iso => tr.date_format_iso,
      DateFormatPreference.european => tr.date_format_european,
      DateFormatPreference.us => tr.date_format_us,
      DateFormatPreference.german => tr.date_format_german,
    };
  }

  String _timeFormatLabel(TimeFormatPreference format) {
    return switch (format) {
      TimeFormatPreference.h12 => tr.time_format_12_hour,
      TimeFormatPreference.h24 => tr.time_format_24_hour,
    };
  }

  @override
  Widget build(BuildContext context) {
    const formKey = AuthFormKey.passwordReset;
    final state = ref.watch(authFormControllerProvider(formKey));
    final controller = ref.watch(authFormControllerProvider(formKey).notifier);
    final userState = ref.watch(userStateProvider);

    return PointerInterceptor(
      child: SelectionArea(
        child: StandardDialog(
          titleText: tr.navlink_account_settings,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              FormTableLayout(
                rowSpacing: 24.0,
                rows: [
                  FormTableRow(
                    label: tr.language,
                    input: const Align(
                      alignment: Alignment.centerRight,
                      child: LanguagePicker(),
                    ),
                  ),
                  FormTableRow(
                    label: tr.study_import_title,
                    labelHelpText: tr.study_import_description,
                    input: Align(
                      alignment: Alignment.centerRight,
                      child: SecondaryButton(
                        text: _isImported
                            ? tr.study_import_success
                            : tr.study_import_button,
                        icon: _isImported ? Icons.check : Icons.upload_file,
                        onPressed: _isImported
                            ? () {}
                            : () async {
                                final success = await StudyImport.importStudy(
                                  ref,
                                );
                                if (success) {
                                  setState(() {
                                    _isImported = true;
                                  });
                                }
                              },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              userState.when(
                data: _buildDateTimePreferences,
                error: (error, stackTrace) => Text(tr.sync_failed),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 16.0),
              ReactiveFormConfig(
                validationMessages: AuthFormController.authValidationMessages,
                child: ReactiveForm(
                  formGroup: controller.getForm()!,
                  child: Column(
                    children: [
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(tr.change_password),
                        childrenPadding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          bottom: 16.0,
                        ),
                        children: [
                          PasswordTextField(
                            formControl: controller.getOldPasswordControl(),
                            labelText: tr.form_field_password_current,
                            hintText: tr.form_field_password_current_hint,
                          ),
                          const SizedBox(height: 12.0),
                          PasswordTextField(
                            formControl: controller.getPasswordControl(),
                            labelText: tr.form_field_password_new,
                            hintText: tr.form_field_password_new_hint,
                          ),
                          PasswordTextField(
                            formControl: controller
                                .getPasswordConfirmationControl(),
                            labelText: tr.form_field_password_new_confirm,
                            hintText: tr.form_field_password_new_confirm_hint,
                          ),
                          const SizedBox(height: 16.0),
                          ReactiveFormConsumer(
                            builder: (context, form, child) {
                              return SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  text: tr.form_field_reset_password,
                                  icon: Icons.lock_reset,
                                  enabled: form.valid,
                                  isLoading: state.isLoading,
                                  onPressedFuture: () async {
                                    final controller = ref.read(
                                      authFormControllerProvider(formKey)
                                          .notifier,
                                    );

                                    final result = await controller
                                        .resetPassword();

                                    if (!context.mounted) return;

                                    Navigator.maybePop(context);

                                    final notificationService = ref.read(
                                      notificationServiceProvider,
                                    );

                                    notificationService.show(
                                      result
                                          ? Notifications.passwordResetSuccess
                                          : Notifications.credentialsInvalid,
                                    );
                                  },
                                  tooltipDisabled: tr.form_invalid_prompt,
                                  innerPadding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                    vertical: 10.0,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      const Divider(),
                      const SizedBox(height: 16.0),
                      versionText(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actionButtons: [DismissButton(text: tr.dialog_close)],
          minWidth: 650,
          maxWidth: 750,
          minHeight: 450,
        ),
      ),
    );
  }
}

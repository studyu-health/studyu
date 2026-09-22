import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/layout_two_column.dart';
import 'package:studyu_designer_v2/common_views/studyu_logo.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_controller.dart';
import 'package:studyu_designer_v2/features/auth/studyu_jtbd.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/language_picker.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/repositories/app_repository.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class const AuthScaffold({
  required final Widget body,
  required final AuthFormKey formKey,
  final double leftContentMinWidth = 424.0,
  final double leftPanelMinWidth = 500.0,
  final EdgeInsets leftPanelPadding = const EdgeInsets.fromLTRB(
    88.0,
    54.0,
    88.0,
    40.0,
  ),
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState() extends ConsumerState<AuthScaffold> {
  AuthFormKey get formKey => widget.formKey;
  static const double _compactBreakpoint = 1000.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.watch(authFormControllerProvider(formKey).notifier);
    final appConfig = ref.watch(appConfigProvider).value;

    return Scaffold(
      key: RouterKeys.authKey,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < _compactBreakpoint;

          if (isCompact) {
            return _buildCompactLayout(
              context: context,
              theme: theme,
              controller: controller,
              appConfig: appConfig,
            );
          }

          return _buildWideLayout(
            theme: theme,
            controller: controller,
            appConfig: appConfig,
          );
        },
      ),
    );
  }

  Widget _buildWideLayout({
    required ThemeData theme,
    required AuthFormController controller,
    required AppConfig? appConfig,
  }) {
    return TwoColumnLayout(
      flexLeft: 6,
      flexRight: 7,
      leftWidget: _buildWidePanel(
        theme: theme,
        controller: controller,
        appConfig: appConfig,
      ),
      rightWidget: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: Center(child: StudyUJobsToBeDone()))],
      ),
      backgroundColorLeft: theme.colorScheme.surface,
      backgroundColorRight: theme.colorScheme.primary,
      constraintsLeft: BoxConstraints(minWidth: widget.leftPanelMinWidth),
      scrollLeft: false,
      scrollRight: false,
      stretchHeight: true,
      paddingLeft: widget.leftPanelPadding,
    );
  }

  Widget _buildWidePanel({
    required ThemeData theme,
    required AuthFormController controller,
    required AppConfig? appConfig,
  }) {
    return ReactiveFormConfig(
      validationMessages: AuthFormController.authValidationMessages,
      child: ReactiveForm(
        formGroup: controller.getForm()!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.leftContentMinWidth,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxHeight: 88.0),
                          child: const StudyULogo(),
                        ),
                        const SizedBox(height: 20.0),
                        SelectableText(
                          formKey.title,
                          style: theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8.0),
                        if (formKey.description != null)
                          TextParagraph(
                            text: formKey.description,
                            style: ThemeConfig.bodyTextMuted(theme),
                          )
                        else
                          const SizedBox.shrink(),
                        const SizedBox(height: 24.0),
                        widget.body,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: widget.leftContentMinWidth,
                ),
                child: _buildFooter(
                  theme: theme,
                  appConfig: appConfig,
                  isCompact: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLayout({
    required BuildContext context,
    required ThemeData theme,
    required AuthFormController controller,
    required AppConfig? appConfig,
  }) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520.0),
              child: ReactiveFormConfig(
                validationMessages: AuthFormController.authValidationMessages,
                child: ReactiveForm(
                  formGroup: controller.getForm()!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16.0),
                      const Center(
                        child: SizedBox(height: 72.0, child: StudyULogo()),
                      ),
                      const SizedBox(height: 20.0),
                      SelectableText(
                        formKey.title,
                        style: theme.textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      if (formKey.description != null)
                        SelectableText(
                          formKey.description!,
                          style: ThemeConfig.bodyTextMuted(theme),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 24.0),
                      widget.body,
                      const SizedBox(height: 32.0),
                      _buildFooter(
                        theme: theme,
                        appConfig: appConfig,
                        isCompact: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter({
    required ThemeData theme,
    required AppConfig? appConfig,
    required bool isCompact,
  }) {
    final footerTextStyle = ThemeConfig.bodyTextBackground(theme);
    final textColor = footerTextStyle.color;

    final legalNoticeLink = Hyperlink(
      text: tr.imprint,
      onClick: () => _onClickImprint(appConfig),
      linkColor: textColor ?? Colors.black,
    );

    final languageSwitcher = LanguagePicker(
      languagePickerType: LanguagePickerType.icon,
      iconColor: textColor,
      offset: const Offset(0, -60),
    );

    final versionLabel = versionText(
      textStyle: TextStyle(
        color: textColor,
        fontSize: theme.textTheme.bodySmall!.fontSize,
      ),
    );

    if (isCompact) {
      return Column(
        children: [
          SelectableText(
            "© HPI Digital Health Cluster ${DateTime.now().year}",
            style: footerTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.0,
            runSpacing: 12.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [languageSwitcher, legalNoticeLink],
          ),
          const SizedBox(height: 16.0),
          Center(child: versionLabel),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SelectableText(
                "© HPI Digital Health Cluster ${DateTime.now().year}",
                style: footerTextStyle,
              ),
            ),
            Wrap(
              spacing: 12.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [languageSwitcher, legalNoticeLink],
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Align(alignment: Alignment.centerRight, child: versionLabel),
      ],
    );
  }

  Future<bool?> _onClickImprint(AppConfig? appConfig) {
    final locale = ref.watch(localeProvider);
    if (appConfig != null) {
      final imprintUri = appConfig.imprint[locale.languageCode];
      if (imprintUri != null) {
        return launchUrl(Uri.parse(imprintUri));
      }
    }
    return Future.value(false);
  }
}

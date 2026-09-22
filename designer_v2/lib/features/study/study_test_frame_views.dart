import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

enum PreviewOverlayStage() {
  healthChecking,
  connecting,
  appLoading,
  error,
  none,
}

class const WebFrame(final String previewSrc, final String studyId, {super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // todo make dynamic width should be half the size of height or height double the width
    // final height = MediaQuery.of(context).size.height;
    // final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    return PhoneContainer(
      innerContent: HtmlElementView(key: key, viewType: '$studyId$key'),
      borderColor: theme.colorScheme.secondary.withValues(alpha: 0.4),
      innerContentBackgroundColor: theme.colorScheme.secondary.withValues(
        alpha: 0.025,
      ),
    );
  }
}

class const DisabledFrame({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneContainer(
      innerContent: const Center(
        child: Opacity(
          opacity: 0.3,
          child: EmptyBody(
            icon: Icons.visibility_off_rounded,
            title: "",
            description: "",
          ),
        ),
      ),
      borderColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
      innerContentBackgroundColor: theme.colorScheme.secondary.withValues(
        alpha: 0.03,
      ),
    );
  }
}

class const PreviewStatusFrame({
  required final IconData icon,
  required final String title,
  required final String description,
  final Widget? action,
  final Color? borderColor,
  final Color? innerContentBackgroundColor,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneContainer(
      innerContent: Padding(
        padding: const EdgeInsets.all(18.0),
        child: EmptyBody(
          icon: icon,
          title: title,
          description: description,
          button: action,
        ),
      ),
      borderColor:
          borderColor ?? theme.colorScheme.secondary.withValues(alpha: 0.35),
      innerContentBackgroundColor:
          innerContentBackgroundColor ??
          theme.colorScheme.secondary.withValues(alpha: 0.08),
    );
  }
}

class const LoadingFrame({
  required final String configuredUrl,
  required final bool isLocalDevelopment,
  required final PreviewOverlayStage stage,
  final String? message,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = tr;
    final title = switch (stage) {
      PreviewOverlayStage.healthChecking =>
        l10n.preview_overlay_health_checking_title,
      PreviewOverlayStage.connecting => l10n.preview_overlay_connecting_title,
      PreviewOverlayStage.appLoading => l10n.preview_overlay_loading_title,
      PreviewOverlayStage.error || PreviewOverlayStage.none => '',
    };
    final description =
        message ??
        switch (stage) {
          PreviewOverlayStage.healthChecking =>
            isLocalDevelopment
                ? l10n.preview_overlay_health_checking_description_local(
                    configuredUrl,
                  )
                : l10n.preview_overlay_health_checking_description_remote(
                    configuredUrl,
                  ),
          PreviewOverlayStage.connecting =>
            isLocalDevelopment
                ? l10n.preview_overlay_connecting_description_local
                : l10n.preview_overlay_connecting_description_remote,
          PreviewOverlayStage.appLoading =>
            isLocalDevelopment
                ? l10n.preview_overlay_loading_description_local
                : l10n.preview_overlay_loading_description_remote,
          PreviewOverlayStage.error || PreviewOverlayStage.none => '',
        };

    return PreviewStatusFrame(
      icon: Icons.sync_rounded,
      title: title,
      description: description,
      action: const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
      innerContentBackgroundColor: Colors.white,
    );
  }
}

class const ErrorFrame({
  required final String title,
  required final String message,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PreviewStatusFrame(
      icon: Icons.warning_amber_rounded,
      title: title,
      description: message,
      innerContentBackgroundColor: Colors.white,
    );
  }
}

class const PhoneContainer({
  required final Widget innerContent,
  final double width = PhoneContainer.defaultWidth,
  final double height = PhoneContainer.defaultHeight,
  final Color borderColor = Colors.black,
  final double borderWidth = 8.0,
  final double borderRadius = 25.0,
  final Color? innerContentBackgroundColor = Colors.white,
  super.key,
}) extends StatelessWidget {
  static const double minWidth = 260.0;
  static const double defaultWidth = 360.0;
  static const double defaultHeight = 720.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: <Widget>[
          Stack(
            children: [
              // Not working https://github.com/flutter/flutter/issues/91191
              // Workaround with increased borderWidth
              /* ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                child: */
              Padding(
                padding: EdgeInsets.all(borderWidth),
                child: Stack(
                  children: [
                    Container(color: innerContentBackgroundColor),
                    innerContent,
                  ],
                ),
              ),
              // ),
              ClipRRect(
                // opaque border so that we can draw on top with other colors
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(borderRadius),
                    ),
                    border: Border.all(width: borderWidth, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              border: Border.all(width: borderWidth, color: borderColor),
            ),
          ),
        ],
      ),
    );
  }
}

class const MobileFrame({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: SizedBox(height: 600, width: 300));
  }
}

class const DesktopFrame({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: SizedBox(height: 600, width: 300));
  }
}

Widget? previewBanner(WidgetRef ref, String studyId) {
  final formViewModel = ref.watch(studyTestValidatorProvider(studyId));

  if (!formViewModel.form.hasErrors) {
    return null;
  }
  return BannerBox(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextParagraph(
          text: tr.banner_study_preview_unavailable,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ReactiveForm(
          formGroup: formViewModel.form,
          child: ReactiveFormConsumer(
            builder: (context, form, child) {
              return TextParagraph(text: form.validationErrorSummary);
            },
          ),
        ),
      ],
    ),
    style: BannerStyle.warning,
  );
}

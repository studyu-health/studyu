import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/onboarding_progress.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/onboarding_shell.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';
import 'package:studyu_app/widgets/title_description_layout.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

typedef TermsContinuation = Future<void> Function(BuildContext context);

class const TermsScreenArguments({required final TermsContinuation onAccepted});

class const TermsScreen({
  final bool? isPushed,
  final TermsContinuation? onAccepted,
  super.key,
}) extends StatefulWidget {
  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

@visibleForTesting
String? routeAfterTerms(AppState state, {required bool canPop}) {
  if (state.selectedStudy == null) return '/${RouteNames.studySelection}';
  return canPop ? null : '/${RouteNames.studyOverview}';
}

class _TermsScreenState() extends State<TermsScreen> {
  bool _acceptedTerms = kDebugMode;
  bool _acceptedPrivacy = kDebugMode;
  bool _participantReady = false;

  bool userCanContinue() {
    return _acceptedTerms && _acceptedPrivacy;
  }

  bool _hasParentRoute(BuildContext context) {
    return widget.isPushed ?? context.canPop();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final nav = _buildNavigation();
    final navNotifier = OnboardingNavNotifier.maybeOf(context);
    navNotifier?.register(
      this,
      '/${RouteNames.terms}',
      OnboardingNavConfig.fromNav(nav),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(localizations.legal_documents),
      ),
      body: TitleDescriptionLayout(
        descriptionWidget: StudyOnboardingDescription(
          text: localizations.legal_documents_description,
        ),
        descriptionBottomSpacing: 0,
        child: RetryFutureBuilder<AppConfig>(
          tryFunction: AppConfig.getAppConfig,
          trackConnectionStatus: true,
          successBuilder: (BuildContext context, AppConfig? appConfig) =>
              legalSection(context, appConfig),
        ),
      ),
      bottomNavigationBar: navNotifier != null ? null : nav,
    );
  }

  Widget legalSection(BuildContext context, AppConfig? appConfig) {
    final appLocale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LegalSection(
          title: AppLocalizations.of(context)!.terms,
          description: AppLocalizations.of(context)!.terms_content,
          acknowledgment: AppLocalizations.of(context)!.terms_agree,
          isChecked: _acceptedTerms,
          onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
          icon: const Icon(MdiIcons.fileDocumentEdit),
          pdfUrl: appConfig!.appTerms[appLocale.languageCode],
          pdfUrlLabel: AppLocalizations.of(context)!.terms_read,
        ),
        const SizedBox(height: 12),
        LegalSection(
          title: AppLocalizations.of(context)!.privacy,
          description: AppLocalizations.of(context)!.privacy_content,
          acknowledgment: AppLocalizations.of(context)!.privacy_agree,
          isChecked: _acceptedPrivacy,
          onChanged: (val) => setState(() => _acceptedPrivacy = val ?? false),
          icon: const Icon(MdiIcons.shieldLock),
          pdfUrl: appConfig.appPrivacy[appLocale.languageCode],
          pdfUrlLabel: AppLocalizations.of(context)!.privacy_read,
        ),
        const SizedBox(height: 12),
        LegalSection(
          title: AppLocalizations.of(context)!.legal_notice,
          description: AppLocalizations.of(context)!.legal_notice_content,
          icon: const Icon(MdiIcons.scaleBalance),
          pdfUrl: appConfig.imprint[appLocale.languageCode],
          pdfUrlLabel: AppLocalizations.of(context)!.imprint_read,
        ),
      ],
    );
  }

  BottomOnboardingNavigation _buildNavigation() {
    return BottomOnboardingNavigation(
      backButtonKey: const ValueKey('terms_back'),
      onBack: () {
        if (_hasParentRoute(context)) {
          context.pop();
        } else {
          context.go('/${RouteNames.welcome}');
        }
      },
      nextButtonKey: const ValueKey('terms_continue'),
      onNext: userCanContinue()
          ? () async {
              if (!_participantReady) {
                final success = await ensureParticipantSignedIn();
                if (!success || !mounted) return;
                _participantReady = true;
              }
              if (widget.onAccepted != null) {
                await widget.onAccepted!(context);
                return;
              }
              final route = routeAfterTerms(
                context.read<AppState>(),
                canPop: _hasParentRoute(context),
              );
              if (route == null) {
                context.pop(true);
              } else {
                context.go(route);
              }
            }
          : null,
      progress: OnboardingProgress.forPage(
        context.read<AppState>(),
        OnboardingStep.terms,
      ),
    );
  }
}

class const LegalSection({
  super.key,
  final String? title,
  final String? description,
  final Icon? icon,
  final String? pdfUrl,
  final String? pdfUrlLabel,
  final String? acknowledgment,
  final bool? isChecked,
  final ValueChanged<bool?>? onChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 40,
                  child: IconTheme(
                    data: IconThemeData(color: theme.primaryColor, size: 40),
                    child: icon!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 40),
                        ),
                        onPressed: () async {
                          final uri = Uri.parse(pdfUrl!);
                          if (await canLaunchUrl(uri)) {
                            launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(pdfUrlLabel!),
                            const SizedBox(width: 6),
                            const Icon(Icons.open_in_new, size: 16),
                          ],
                        ),
                      ),
                      if (acknowledgment != null) ...[
                        const Divider(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 48,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Checkbox(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: isChecked,
                                  onChanged: onChanged,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: onChanged == null
                                    ? null
                                    : () => onChanged!(!(isChecked ?? false)),
                                child: Text(
                                  acknowledgment!,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

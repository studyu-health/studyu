import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/onboarding_progress.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_app/services/study_start_service.dart';
import 'package:studyu_app/util/save_pdf.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_app/widgets/loading_overlay.dart';
import 'package:studyu_app/widgets/onboarding_shell.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';
import 'package:studyu_app/widgets/title_description_layout.dart';
import 'package:studyu_app/widgets/why_dialog.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const ConsentScreen({super.key}) extends StatefulWidget {
  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState() extends State<ConsentScreen> {
  StudySubject? subject;
  late List<bool> boxLogic;
  late List<ConsentItem> consentList;
  bool _isStarting = false;

  void onBoxTapped(int index) {
    setState(() {
      boxLogic[index] = true;
    });
  }

  // Accepting consent starts the study in place: this screen shows the
  // loading state while the subject is created, then navigates directly to
  // the next screen. It deliberately does not pop back to the journey
  // screen first, so no pop-then-push route animation plays.
  Future<void> _acceptConsent() async {
    setState(() => _isStarting = true);
    final started = await StudyStartService.startStudy(context, subject!);
    if (started || !mounted) return;
    setState(() => _isStarting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.error)),
    );
  }

  Future<void> _declineConsent() async {
    final appState = context.read<AppState>();
    appState.activeSubject = null;
    appState.onboardingPhase = null;
    context.go('/${RouteNames.welcome}');
    await PendingDeepLinkService.clear(appState);
  }

  @override
  void initState() {
    super.initState();
    // todo fix subject is null if page gets reloaded in all files (same solution as in dashboard)
    subject = context.read<AppState>().activeSubject;
    consentList = subject!.study.consent;
    boxLogic = List.filled(consentList.length, false);
  }

  Future<List<pw.Widget>> generatePdfContent() async {
    final ttf = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    return consentList
        .map(
          (consentItem) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                consentItem.title ?? '',
                textScaleFactor: 2,
                style: pw.TextStyle(font: ttf),
              ),
            ),
            pw.Paragraph(
              text: consentItem.description ?? '',
              style: pw.TextStyle(font: ttf),
            ),
          ],
        )
        .expand((element) => element)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final nav = BottomOnboardingNavigation(
      backLabel: AppLocalizations.of(context)!.decline,
      showBackIcon: false,
      onBack: _declineConsent,
      nextLabel: AppLocalizations.of(context)!.accept,
      showNextIcon: false,
      onNext: boxLogic.every((element) => element) || kDebugMode
          ? _acceptConsent
          : null,
      progress: OnboardingProgress.forPage(appState, OnboardingStep.consent),
    );

    final navNotifier = OnboardingNavNotifier.maybeOf(context);
    navNotifier?.register(
      this,
      '/${RouteNames.consent}',
      OnboardingNavConfig.fromNav(
        nav,
        loadingMessage: _isStarting
            ? AppLocalizations.of(context)!.starting_study
            : null,
      ),
    );

    final scaffold = Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.consent),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (kIsWeb) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    elevation: 24,
                    title: Text(
                      AppLocalizations.of(context)!.save_not_supported,
                    ),
                    content: Text(
                      AppLocalizations.of(context)!
                          .save_not_supported_description,
                    ),
                  ),
                );
              }
              final pdfContent = await generatePdfContent();
              if (!context.mounted) return;
              final savedFilePath = await savePDF(
                context,
                '${subject!.study.title}_consent',
                pdfContent,
              );
              if (savedFilePath != null) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${AppLocalizations.of(context)!.was_saved_to}$savedFilePath.',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: TitleDescriptionLayout(
        descriptionWidget: StudyOnboardingDescription(
          text: AppLocalizations.of(context)!.please_give_consent,
          actionLabel: AppLocalizations.of(context)!.please_give_consent_why,
          onAction: () => showDialog(
            context: context,
            builder: (context) => WhyDialog(
              content: AppLocalizations.of(context)!.please_give_consent_reason,
            ),
          ),
        ),
        descriptionBottomSpacing: 0,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: consentList.length,
          itemBuilder: (context, index) => ConsentCard(
            consent: consentList[index],
            isChecked: boxLogic[index],
            index: index,
            onTapped: onBoxTapped,
          ),
        ),
      ),
      bottomNavigationBar: navNotifier != null ? null : nav,
    );

    // In shell mode the loading overlay is rendered by OnboardingShell so it
    // covers the full screen including the persistent bottom nav.
    if (navNotifier != null) return scaffold;

    return Stack(
      children: [
        scaffold,
        if (_isStarting)
          LoadingOverlay(message: AppLocalizations.of(context)!.starting_study),
      ],
    );
  }
}

class const ConsentCard({
  super.key,
  final ConsentItem? consent,
  final int? index,
  required final Function(int) onTapped,
  final bool? isChecked,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: isChecked! ? Colors.blue[100] : Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.primaryColor),
      ),
      child: InkWell(
        splashColor: theme.colorScheme.secondary.withAlpha(100),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  if (consent!.iconName.isNotEmpty)
                    Icon(
                      MdiIconsHelper.fromString(consent!.iconName),
                      color: theme.primaryColor,
                    )
                  else
                    const SizedBox.shrink(),
                  if (consent!.iconName.isNotEmpty)
                    const SizedBox(width: 8)
                  else
                    const SizedBox.shrink(),
                  Expanded(child: Text(consent!.title!)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              content: HtmlText(consent!.description),
            ),
          );
          onTapped(index!);
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (consent!.iconName.isNotEmpty)
                Icon(
                  MdiIconsHelper.fromString(consent!.iconName),
                  size: 60,
                  color: Colors.blue,
                )
              else
                const SizedBox.shrink(),
              if (consent!.iconName.isNotEmpty)
                const SizedBox(height: 10)
              else
                const SizedBox.shrink(),
              Flexible(
                child: Text(
                  consent!.title!,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConsentElement(
  final String title,
  final String descriptionText,
  final String acknowledgmentText,
  final IconData icon,
);

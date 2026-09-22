import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/collapse.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/fitbit/fitbit_credentials_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class const FitbitCredentialsSection({
  required final FitbitCredentialsFormViewModel formViewModel,
  super.key,
}) extends StatelessWidget {
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Collapsible(
          title: AppLocalizations.of(context)!.fitbit_credentials_how_to_obtain,
          maintainState: false,
          contentBuilder: (context, isCollapsed) =>
              FitbitCredentialsHelpContent(onLaunchUrl: _launchURL),
        ),
        const SizedBox(height: 16.0),
        FormTableLayout(
          rows: [
            FormTableRow(
              control: formViewModel.clientIdControl,
              label: AppLocalizations.of(context)!.client_id,
              labelHelpText: AppLocalizations.of(context)!.client_id_label_help,
              input: ReactiveTextField<String>(
                formControl: formViewModel.clientIdControl,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.client_id_hint,
                ),
              ),
            ),
            FormTableRow(
              control: formViewModel.clientSecretControl,
              label: AppLocalizations.of(context)!.client_secret,
              labelHelpText: AppLocalizations.of(context)!
                  .client_secret_label_help,
              input: ReactiveTextField<String>(
                formControl: formViewModel.clientSecretControl,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.client_secret_hint,
                ),
              ),
            ),
          ],
          columnWidths: const {0: FlexColumnWidth()},
        ),
      ],
    );
  }
}

class const FitbitCredentialsHelpContent({
  required final Future<void> Function(String url) onLaunchUrl,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12.0),
        TextParagraph(
          text: AppLocalizations.of(context)!.fitbit_credentials_instruction,
        ),
        const SizedBox(height: 12.0),
        InkWell(
          onTap: () => onLaunchUrl('https://dev.fitbit.com/'),
          child: Text(
            AppLocalizations.of(context)!.fitbit_credentials_step1,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        InkWell(
          onTap: () => onLaunchUrl('https://accounts.fitbit.com/login'),
          child: Text(
            AppLocalizations.of(context)!.fitbit_credentials_step2,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        TextParagraph(
          text: AppLocalizations.of(context)!.fitbit_credentials_step3,
        ),
        TextParagraph(
          text: AppLocalizations.of(context)!.fitbit_credentials_step4,
        ),
        TextParagraph(
          text: AppLocalizations.of(context)!.fitbit_credentials_step5,
        ),
        TextParagraph(
          text: AppLocalizations.of(context)!.fitbit_credentials_step6,
        ),
        InkWell(
          onTap: () =>
              onLaunchUrl('https://fitbit.google/enterprise/researchers-faqs/'),
          child: Text(
            AppLocalizations.of(context)!.fitbit_credentials_step7,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        TextParagraph(
          text: AppLocalizations.of(context)!.fitbit_credentials_step8,
        ),
        const SizedBox(height: 12.0),
        const FitbitCredentialsScreenshotsSection(),
        const SizedBox(height: 16.0),
        const FitbitSingleParticipantInstructions(),
        const SizedBox(height: 24.0),
      ],
    );
  }
}

class const FitbitSingleParticipantInstructions({super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8.0),
                Text(
                  AppLocalizations.of(context)!.fitbit_only_participant_title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              AppLocalizations.of(context)!.fitbit_only_participant_subtitle,
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.fitbit_only_participant_step_1,
                ),
                const SizedBox(height: 4.0),
                Text(
                  AppLocalizations.of(context)!.fitbit_only_participant_step_2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class const FitbitCredentialsScreenshotsSection({super.key})
    extends StatefulWidget {
  @override
  State<FitbitCredentialsScreenshotsSection> createState() =>
      _FitbitCredentialsScreenshotsSectionState();
}

class _FitbitCredentialsScreenshotsSectionState()
    extends State<FitbitCredentialsScreenshotsSection> {
  late final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _scrollBy(double amount) {
    scrollController.animateTo(
      scrollController.offset + amount,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        Text(
          AppLocalizations.of(context)!.screenshots_for_guidance,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        Stack(
          children: [
            SizedBox(
              height: 200.0,
              child: ListView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                children: [
                  _buildScreenshot(
                    context,
                    'assets/images/step1.png',
                    AppLocalizations.of(context)!
                        .fitbit_credentials_screenshot_step1,
                  ),
                  _buildScreenshot(
                    context,
                    'assets/images/step2.png',
                    AppLocalizations.of(context)!
                        .fitbit_credentials_screenshot_step2,
                  ),
                  _buildScreenshot(
                    context,
                    'assets/images/step3.png',
                    AppLocalizations.of(context)!
                        .fitbit_credentials_screenshot_step3,
                  ),
                  _buildScreenshot(
                    context,
                    'assets/images/step4.png',
                    AppLocalizations.of(context)!
                        .fitbit_credentials_screenshot_step4,
                  ),
                  _buildScreenshot(
                    context,
                    'assets/images/step5.png',
                    AppLocalizations.of(context)!
                        .fitbit_credentials_screenshot_step5,
                  ),
                  _buildScreenshot(
                    context,
                    'assets/images/step6.png',
                    AppLocalizations.of(context)!
                        .fitbit_credentials_screenshot_step6,
                  ),
                  _buildScreenshot(
                    context,
                    'assets/images/step7.png',
                    AppLocalizations.of(context)!
                        .fitbit_credentials_screenshot_step7,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 80,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => _scrollBy(-200.0),
              ),
            ),
            Positioned(
              right: 0,
              top: 80,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () => _scrollBy(200.0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScreenshot(
    BuildContext context,
    String assetPath,
    String caption,
  ) {
    return Container(
      width: 180.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Expanded(child: Image.asset(assetPath, fit: BoxFit.contain)),
          const SizedBox(height: 8.0),
          Text(
            caption,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

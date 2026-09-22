import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';
import 'package:studyu_app/widgets/title_description_layout.dart';
import 'package:studyu_core/core.dart';
import 'package:url_launcher/url_launcher.dart';

typedef _InformationItem = ({IconData icon, String label, String value});

class const StudyInformationScreen({super.key}) extends StatefulWidget {
  @override
  State<StudyInformationScreen> createState() => _StudyInformationScreenState();
}

class _StudyInformationScreenState() extends State<StudyInformationScreen> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appState = context.watch<AppState>();
    final subject = appState.activeSubject!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.study_information)),
      body: FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (context, snapshot) {
          final information = _buildInformation(
            context,
            subject,
            snapshot.data,
            appState.isPreview,
          );
          final contactEmail = subject.study.contact.email.trim();

          return TitleDescriptionLayout(
            descriptionWidget: StudyOnboardingDescription(
              text: l10n.study_information_description,
            ),
            descriptionBottomSpacing: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _copyAll(information),
                          icon: const Icon(Icons.copy_all_outlined),
                          label: Text(l10n.copy_all_information),
                        ),
                      ),
                      const Divider(height: 1),
                      for (
                        var index = 0;
                        index < information.length;
                        index++
                      ) ...[
                        _InformationTile(item: information[index]),
                        if (index < information.length - 1)
                          const Divider(height: 1, indent: 72),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: contactEmail.isEmpty
                        ? null
                        : () => _sendEmail(
                            recipient: contactEmail,
                            subjectId: subject.id,
                            information: information,
                          ),
                    icon: const Icon(Icons.email_outlined),
                    label: Text(l10n.email_study_team),
                  ),
                ),
                if (contactEmail.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.study_team_email_unavailable,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<_InformationItem> _buildInformation(
    BuildContext context,
    StudySubject subject,
    PackageInfo? packageInfo,
    bool isPreview,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final title = subject.study.title?.trim();
    final startedAt = subject.startedAt;

    return [
      (
        icon: Icons.science_outlined,
        label: l10n.study_name,
        value: title?.isNotEmpty == true ? title! : l10n.not_available,
      ),
      (icon: Icons.fingerprint, label: l10n.study_id, value: subject.study.id),
      (icon: Icons.badge_outlined, label: l10n.subject_id, value: subject.id),
      (
        icon: Icons.calendar_today_outlined,
        label: l10n.study_start_date,
        value: startedAt == null
            ? l10n.not_available
            : MaterialLocalizations.of(context)
                  .formatFullDate(startedAt.toLocal()),
      ),
      (
        icon: Icons.phone_android_outlined,
        label: l10n.app_version,
        value: packageInfo == null
            ? l10n.not_available
            : '${packageInfo.version} (${packageInfo.buildNumber})',
      ),
      (
        icon: Icons.devices_outlined,
        label: l10n.platform,
        value: kIsWeb ? 'web' : defaultTargetPlatform.name,
      ),
      (
        icon: Icons.preview_outlined,
        label: l10n.preview_mode,
        value: isPreview ? l10n.yes : l10n.no,
      ),
    ];
  }

  Future<void> _copyAll(List<_InformationItem> information) async {
    await Clipboard.setData(ClipboardData(text: _informationText(information)));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.all_information_copied),
      ),
    );
  }

  Future<void> _sendEmail({
    required String recipient,
    required String subjectId,
    required List<_InformationItem> information,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final subject =
        '${l10n.participant_information_email_subject} - $subjectId';
    final body =
        '${l10n.participant_information_email_intro}\n\n'
        '${_informationText(information)}';
    final uri = Uri(
      scheme: 'mailto',
      path: recipient,
      query:
          'subject=${Uri.encodeComponent(subject)}'
          '&body=${Uri.encodeComponent(body)}',
    );

    if (!await launchUrl(uri) && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.email_app_unavailable)));
    }
  }

  String _informationText(List<_InformationItem> information) =>
      information.map((item) => '${item.label}: ${item.value}').join('\n');
}

class const _InformationTile({required final _InformationItem item})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.label),
      subtitle: SelectableText(item.value),
    );
  }
}

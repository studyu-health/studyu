import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppErrorReason() {
  loading,
  deletedStudy,
}

class const AppErrorScreenArguments({
  final String? selectedSubjectId,
  final AppErrorReason reason = AppErrorReason.loading,
});

class const AppErrorScreen({
  super.key,
  final String? selectedSubjectId,
  final AppErrorReason reason = AppErrorReason.loading,
}) extends StatefulWidget {
  @override
  State<AppErrorScreen> createState() => _AppErrorScreenState();
}

class _AppErrorScreenState() extends State<AppErrorScreen> {
  String? cachedUserData;
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadCachedUserData();
  }

  Future<void> _loadCachedUserData() async {
    try {
      final data = await Cache.getCachedUserData();
      setState(() {
        cachedUserData = data;
        isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        cachedUserData = 'Error loading cached data: $e';
        isLoadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                const Image(
                  image: AssetImage('assets/icon/logo.png'),
                  height: 200,
                ),
                const SizedBox(height: 20),
                Text(
                  switch (widget.reason) {
                    AppErrorReason.loading => loc.loading_error_title,
                    AppErrorReason.deletedStudy =>
                      loc.deleted_study_error_title,
                  },
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  switch (widget.reason) {
                    AppErrorReason.loading => loc.loading_error_description,
                    AppErrorReason.deletedStudy =>
                      loc.deleted_study_error_description,
                  },
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                // Debug information section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(MdiIcons.informationOutline),
                            const SizedBox(width: 8),
                            Text(
                              'Debug Information',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (isLoadingData)
                          const Center(child: CircularProgressIndicator())
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              cachedUserData ?? 'No data available',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(MdiIcons.emailOutline),
                        onPressed: () => _contactStudyTeam(context),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                        label: Text(loc.email_study_team),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(MdiIcons.deleteOutline),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () => _showDeleteDataDialog(context),
                        label: Text(loc.delete_data),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _contactStudyTeam(BuildContext context) async {
    StudyULogger.info(
      "User chose to contact the study team from AppErrorScreen",
    );
    final loc = AppLocalizations.of(context)!;

    final emailSubject = switch (widget.reason) {
      AppErrorReason.loading => loc.support_email_subject_loading_error,
      AppErrorReason.deletedStudy => loc.support_email_subject_deleted_study,
    };

    // Get the base email body from localization
    String emailBody = switch (widget.reason) {
      AppErrorReason.loading => loc.support_email_body(
        widget.selectedSubjectId ?? '',
      ),
      AppErrorReason.deletedStudy => loc.deleted_study_support_email_body(
        widget.selectedSubjectId ?? '',
      ),
    };

    // Append cached user data to the email body
    if (cachedUserData != null && cachedUserData!.isNotEmpty) {
      emailBody += '\n\n--- Debug Information ---\n$cachedUserData';
    } else {
      emailBody += '\n\n--- Debug Information ---\nNo cached data available';
    }

    String contactEmail = '';
    try {
      final cachedSubject = await Cache.loadSubject();
      if (cachedSubject.id != widget.selectedSubjectId) {
        throw StateError('Cached subject does not match selected subject');
      }
      contactEmail = cachedSubject.study.contact.email.trim();
    } catch (e) {
      StudyULogger.warning('Failed to load study team contact email: $e');
    }

    if (contactEmail.isEmpty) {
      StudyULogger.error('No study team contact email available.');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.study_team_email_unavailable)));
      return;
    }

    final uriString =
        'mailto:$contactEmail?subject=${Uri.encodeComponent(emailSubject)}&body=${Uri.encodeComponent(emailBody)}';
    final emailUri = Uri.parse(uriString);
    bool didLaunch = false;
    try {
      didLaunch = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      StudyULogger.warning('Failed to launch study team email URI: $e');
    }

    if (!didLaunch) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.study_team_email_unavailable)));
      return;
    }

    // Let users dismiss the confirmation after the email app was opened.
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.support_email_sent),
          content: Text(loc.support_email_sent_description),
          actions: [
            TextButton(onPressed: () => context.pop(), child: Text(loc.ok)),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDataDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.delete_all_data),
          content: Text(
            AppLocalizations.of(context)!.delete_all_data_description,
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => context.pop(true),
              child: Text(AppLocalizations.of(context)!.reset_app),
            ),
          ],
        );
      },
    );

    if (result == true) {
      if (!context.mounted) return;
      await cancelNotifications(context);

      if (widget.reason == AppErrorReason.deletedStudy) {
        StudyULogger.info("Clearing active study reference");
        await deleteActiveStudyReference();
        StudyULogger.info("Active study reference cleared");
      } else {
        StudyULogger.info("Deleting all secure storage data");
        await SecureStorage.deleteAll();
        StudyULogger.info("Secure storage data deleted");
      }

      if (!context.mounted) return;
      context.goNamed(RouteNames.welcome);
      return;
    }

    StudyULogger.info("User chose not to delete secure storage data.");
  }
}

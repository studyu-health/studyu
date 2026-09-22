import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/debug_mode.dart';
import 'package:studyu_app/util/notifications.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

class DebugScreen() {
  static Future<void> showDebugScreen(BuildContext context) async {
    final studyNotifications = context.read<AppState>().studyNotifications;

    final pendingNotifications = studyNotifications != null
        ? studyNotifications.flutterLocalNotificationsPlugin
              .pendingNotificationRequests()
        : Future.value([]);

    final pendingNotificationsPlugin = studyNotifications != null
        ? FlutterLocalNotificationsPlugin().pendingNotificationRequests()
        : Future.value(<PendingNotificationRequest>[]);

    final packageInfo = await PackageInfo.fromPlatform();
    final versionString =
        'Version: ${packageInfo.version} - ${packageInfo.buildNumber}';
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => _DebugDialog(
        studyNotifications: studyNotifications,
        pendingNotifications: pendingNotifications,
        pendingNotificationsPlugin: pendingNotificationsPlugin,
        versionString: versionString,
      ),
    );
  }

  static Future<void> testNotification(BuildContext context) async {
    final studyNotifications = context.read<AppState>().studyNotifications;
    if (studyNotifications == null) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.debug_notifications_not_initialized,
          ),
        ),
      );
      return;
    }
    await studyNotifications.flutterLocalNotificationsPlugin.show(
      id: 99,
      title: AppLocalizations.of(context)!.debug_test_notification_title,
      body: AppLocalizations.of(context)!.debug_test_notification_body,
      notificationDetails: notificationDetails,
    );
  }

  static Future<bool> receivePermission() async {
    return await Permission.ignoreBatteryOptimizations.request().isGranted;
  }

  static Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  static Future<void> _deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();
    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  static Future<void> resetApp(BuildContext context) async {
    try {
      await _deleteCacheDir();
      await _deleteAppDir();
      await SecureStorage.deleteAll();
      if (context.mounted) {
        context.pop();
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.debug_reset_success),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    } catch (e) {
      StudyULogger.error(e);
      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.debug_reset_error),
          ),
        );
      }
    }
  }
}

class const _DebugDialog({
  required final StudyNotifications? studyNotifications,
  required final Future<List> pendingNotifications,
  required final Future<List<PendingNotificationRequest>>
  pendingNotificationsPlugin,
  required final String versionString,
}) extends StatefulWidget {
  @override
  State<_DebugDialog> createState() => __DebugDialogState();
}

class __DebugDialogState() extends State<_DebugDialog> {
  bool? ignoreBatteryOptimizations;
  int? pendingNotificationCount;
  int? pendingNotificationsPluginCount;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SelectableText(AppLocalizations.of(context)!.debug_screen_title),
      content: Column(
        children: [
          _buildVersionInfo(),
          const SizedBox(height: 16),
          _buildEmailButton(),
          const SizedBox(height: 8),
          _buildTestNotificationButton(),
          const SizedBox(height: 8),
          _buildResetAppButton(),
          if (isDebugMode) ...[
            const SizedBox(height: 8),
            _buildShowOnboardingButton(),
          ],
          const SizedBox(height: 16),
          _buildPreviewModeSwitch(),
          const SizedBox(height: 16),
          _buildBatteryOptimizationInfo(),
          const SizedBox(height: 8),
          _buildPendingNotificationsInfo(),
          const SizedBox(height: 8),
          _buildPendingNotificationsPluginInfo(),
          const SizedBox(height: 16),
          _buildScheduledNotificationsInfo(),
          const SizedBox(height: 16),
          _buildReferrerDebugInfo(),
        ],
      ),
      scrollable: true,
    );
  }

  Widget _buildVersionInfo() {
    return Text(widget.versionString);
  }

  Widget _buildEmailButton() {
    return ElevatedButton(
      onPressed: () => _sendDebugEmail(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: Text(
        AppLocalizations.of(context)!.debug_send_information_via_email,
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    if (context.read<AppState>().studyNotifications == null) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: () => DebugScreen.testNotification(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      child: Text(
        AppLocalizations.of(context)!.debug_receive_test_notification,
      ),
    );
  }

  Widget _buildResetAppButton() {
    return ElevatedButton(
      onPressed: () => _showResetConfirmationDialog(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
      child: Text(AppLocalizations.of(context)!.reset_app),
    );
  }

  Widget _buildShowOnboardingButton() {
    return TextButton.icon(
      key: const ValueKey('debug_show_onboarding'),
      style: TextButton.styleFrom(foregroundColor: Colors.orange),
      icon: const Icon(Icons.bug_report),
      onPressed: () => context.go('/${RouteNames.onboarding}'),
      label: Text(AppLocalizations.of(context)!.debug_show_onboarding),
    );
  }

  Widget _buildBatteryOptimizationInfo() {
    return FutureBuilder<bool>(
      future: DebugScreen.receivePermission(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          ignoreBatteryOptimizations = snapshot.data;
          return Text("ignoreBatteryOptimizations: ${snapshot.data}");
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildPendingNotificationsInfo() {
    return FutureBuilder<List>(
      future: widget.pendingNotifications,
      builder: (context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          pendingNotificationCount = snapshot.data!.length;
          return Text(
            'Number of Pending Notifications: $pendingNotificationCount',
          );
        } else if (snapshot.hasError) {
          return Text('Pending Notifications: Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildPendingNotificationsPluginInfo() {
    return FutureBuilder<List<PendingNotificationRequest>>(
      future: widget.pendingNotificationsPlugin,
      builder: (context, AsyncSnapshot<List<PendingNotificationRequest>> snapshot) {
        if (snapshot.hasData) {
          pendingNotificationsPluginCount = snapshot.data!.length;
          return Text(
            'Local Notifications Plugin Number of Pending Notifications: $pendingNotificationsPluginCount',
          );
        } else if (snapshot.hasError) {
          return Text('Pending Notifications Plugin: Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildScheduledNotificationsInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Scheduled Notifications:"),
        SelectableText(
          StudyNotifications.scheduledNotificationsDebug ?? 'No data',
        ),
      ],
    );
  }

  Widget _buildReferrerDebugInfo() {
    return FutureBuilder<String?>(
      future: SecureStorage.read('debug_install_referrer'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Last Install Referrer (Debug):",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SelectableText(snapshot.data ?? 'None'),
          ],
        );
      },
    );
  }

  Widget _buildPreviewModeSwitch() {
    return SwitchListTile(
      title: const Text('Preview Mode'),
      value: context.read<AppState>().isPreview,
      onChanged: (value) {
        // Update the preview mode state using the proper method
        context.read<AppState>().updatePreviewMode(value);

        // Close the debug dialog and navigate back to dashboard
        context.pop(); // Close debug dialog

        // If we're in settings, also close the settings screen to get back to dashboard
        // This will ensure we get back to the main dashboard which uses showNextDay
        while (context.canPop()) {
          context.pop();
        }
        print('Preview mode is now ${value ? 'active' : 'inactive'}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<AppState>().isPreview
                  ? AppLocalizations.of(context)!.preview_mode_active_state
                  : AppLocalizations.of(context)!.preview_mode_inactive_state,
            ),
          ),
        );
      },
    );
  }

  void _sendDebugEmail() {
    AppConfig.getAppContact().then((value) {
      final debugInfo = _buildDebugInfoString();
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: value.email,
        queryParameters: {
          'subject': '[StudyU] Debug Information',
          'body': debugInfo,
        },
      );
      launchUrl(emailLaunchUri);
    });
  }

  String _buildDebugInfoString() {
    final buffer = StringBuffer();
    buffer.writeln('Version: ${widget.versionString}');
    buffer.writeln(
      'Ignore Battery Optimizations: ${ignoreBatteryOptimizations ?? 'null'}',
    );
    buffer.writeln(
      'Pending Notifications Number: ${pendingNotificationCount ?? 'null'}',
    );
    buffer.writeln(
      'Pending Notifications Plugin Number: ${pendingNotificationsPluginCount ?? 'null'}',
    );
    buffer.writeln('Preview Mode: ${context.read<AppState>().isPreview}');
    buffer.writeln('Scheduled Notifications Debug:');
    buffer.write(StudyNotifications.scheduledNotificationsDebug ?? 'No data');

    return buffer.toString();
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset App?'),
        content: const Text('This will delete all data and reset the app.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => DebugScreen.resetApp(context),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

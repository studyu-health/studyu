import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/main.dart';
import 'package:studyu_core/core.dart';

class NotificationValidators(
  var bool didNotificationLaunchApp,
  // do not launch notification action twice if user subscribes to a new study
  var bool wasNotificationActionHandled,
  var bool wasNotificationActionCompleted,
);

class StudyNotifications._create(
  var StudySubject? subject,
  var BuildContext context,
) {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final StreamController<ReceivedNotification>
  didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  static final NotificationValidators validator = NotificationValidators(
    false,
    false,
    false,
  );

  static const bool debug = kDebugMode; //kDebugMode;
  static String? scheduledNotificationsDebug;

  /// Private constructor
  this {
    _initNotificationsPlugin();
    _requestPermissions();
    _isAndroidPermissionGranted();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  /// Public factory
  static Future<StudyNotifications> create(
    StudySubject? activeSubject,
    BuildContext context,
  ) async {
    final notifications = StudyNotifications._create(activeSubject, context);
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        !kIsWeb && Platform.isLinux
        ? null
        : await notifications.flutterLocalNotificationsPlugin
              .getNotificationAppLaunchDetails();
    StudyNotifications.validator.didNotificationLaunchApp =
        notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
    if (StudyNotifications.validator.didNotificationLaunchApp &&
        !StudyNotifications.validator.wasNotificationActionHandled) {
      StudyNotifications.validator.wasNotificationActionHandled = true;
      final selectedNotificationPayload =
          notificationAppLaunchDetails!.notificationResponse!.payload!;
      notifications.handleNotificationResponse(selectedNotificationPayload);
    }
    return notifications;
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      //final bool granted =
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!
          .areNotificationsEnabled();
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      // todo look into this further if notifications are not received on Android
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      /*final bool granted =*/
      await androidImplementation?.requestNotificationsPermission();

      final status = await Permission.ignoreBatteryOptimizations.status;
      if (status.isDenied) {
        if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
          // print("Ignore battery optimization Permission is granted");
        } else {
          // print("Ignore battery optimization Permission is denied.");
        }
      }
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream.listen((
      ReceivedNotification receivedNotification,
    ) async {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: receivedNotification.title != null
                ? Text(receivedNotification.title!)
                : null,
            content: receivedNotification.body != null
                ? Text(receivedNotification.body!)
                : null,
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () async {
                  context.pop();
                  await context.push('/${RouteNames.dashboard}');
                },
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        );
      }
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) {
      handleNotificationResponse(payload!);
    });
  }

  void _initNotificationsPlugin() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
        );
    flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
            if (notificationResponse.notificationResponseType ==
                NotificationResponseType.selectedNotification) {
              selectNotificationStream.add(notificationResponse.payload);
            }
          },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future handleNotificationResponse(String taskInstanceId) async {
    final nowDt = DateTime.now();
    final taskToRun = TaskInstance.fromInstanceId(
      taskInstanceId,
      subject: subject,
    );

    final completed = subject!.completedTaskInstanceForDay(
      taskToRun.task.id,
      taskToRun.completionPeriod,
      nowDt,
    );

    final isInsidePeriod = taskToRun.completionPeriod.contains(
      StudyUTimeOfDay.now(),
    );
    if (!completed && isInsidePeriod) {
      await navigatorKey.currentContext!.push(
        '/${RouteNames.task}',
        extra: taskToRun,
      );
      navigatorKey.currentContext!.go('/${RouteNames.loading}');
    } else {
      final errorMessage = completed
          ? AppLocalizations.of(context)!.task_already_completed
          : isInsidePeriod
          ? AppLocalizations.of(context)!.task_cannot_be_completed
          : AppLocalizations.of(context)!.task_outside_period;

      navigatorKey.currentContext!.go(
        '/${RouteNames.dashboard}',
        extra: errorMessage,
      );
    }
  }
}

class ReceivedNotification({
  final int? id,
  final String? title,
  final String? body,
  final String? payload,
});

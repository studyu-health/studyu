import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:studyu_app/app.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/util/debug_mode.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase/supabase.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey(
  debugLabel: 'Main Navigator',
);

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is AssertionError &&
          details.exception.toString().contains('_debugDuringDeviceUpdate')) {
        debugPrint('Mouse tracker assertion suppressed: ${details.exception}');
        return;
      }
      FlutterError.presentError(details);
    };
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  try {
    await loadEnv();
  } catch (error) {
    // device could be offline
    debugPrint('Error loading env: $error');
  }
  await _configureLocalTimeZone();
  await _storeE2eParticipantCredentials();
  final queryParameters = Uri.base.queryParameters;
  // Turn off the # in the URLs on the web
  usePathUrlStrategy();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  AppConfig? appConfig;
  final platformInitialRoute =
      WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  String initialRoute = initialRouteFromPlatformRoute(platformInitialRoute);
  try {
    appConfig = await AppConfig.getAppConfig();
  } on PostgrestException catch (e) {
    debugPrint('Postgres exception: $e');
    if (e.code == 'PGRST301') {
      // Unauthorized - likely due to wrong supabase environment variables
      initialRoute = '/${RouteNames.appErrorScreen}';
    }
  } catch (error) {
    // device could be offline
    debugPrint('Error fetching app config: $error');
  }

  if (appConfig != null && await isAppOutdated(appConfig)) {
    initialRoute = '/${RouteNames.appOutdated}';
  }

  // This application uses Provider rather than Riverpod, so it does not need a ProviderScope.
  // ignore: riverpod_lint/missing_provider_scope
  runApp(MyApp(queryParameters, appConfig, initialRoute: initialRoute));

  AppLifecycleListener(
    onResume: () async {
      try {
        final context = navigatorKey.currentContext;
        if (context == null) return;

        // Get the current location from the GoRouter
        final router = GoRouter.of(context);
        final currentLocation =
            router.routerDelegate.currentConfiguration.uri.path;
        if (currentLocation == '/${RouteNames.appOutdated}') return;

        final appConfig = await AppConfig.getAppConfig();
        if (await isAppOutdated(appConfig)) {
          if (context.mounted) {
            context.go('/${RouteNames.appOutdated}');
          }
        }
      } catch (error) {
        // device could be offline
        debugPrint('Error fetching app config: $error');
      }
    },
  );
}

/// Checks major and minor version of the app against the minimum version required by the backend
/// Returns true if the app is outdated
Future<bool> isAppOutdated(AppConfig appConfig) async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final appVersion = packageInfo.version;
  final appVersionParts = appVersion.split('.');
  final minVersionParts = appConfig.appMinVersion.split('.');

  final appVersionMajor = int.parse(appVersionParts[0]);
  final appVersionMinor = int.parse(appVersionParts[1]);

  final minVersionMajor = int.parse(minVersionParts[0]);
  final minVersionMinor = int.parse(minVersionParts[1]);

  return appVersionMajor < minVersionMajor ||
      (appVersionMajor == minVersionMajor && appVersionMinor < minVersionMinor);
}

/// This is needed for flutter_local_notifications
/// Stores local-only fixture credentials before production startup for a
/// browser E2E run. LoadingScreen then signs in through signInParticipant.
Future<void> _storeE2eParticipantCredentials() async {
  const email = String.fromEnvironment('STUDYU_E2E_PARTICIPANT_EMAIL');
  const password = String.fromEnvironment('STUDYU_E2E_PARTICIPANT_PASSWORD');

  if (!isDebugMode || email.isEmpty || password.isEmpty) return;

  await storeFakeUserEmailAndPassword(email, password);
}

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import 'test_log.dart';
import 'tests/test_1.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final originalFlutterErrorHandler = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    markTestStep(
      'flutter-error',
      details.context?.toDescription() ?? 'FlutterError.onError',
      error: details.exception,
      stackTrace: details.stack,
    );
    originalFlutterErrorHandler?.call(details);
  };

  final originalTestExceptionReporter = reportTestException;
  reportTestException = (FlutterErrorDetails details, String testDescription) {
    markTestStep(
      'test-framework-error',
      testDescription,
      error: details.exception,
      stackTrace: details.stack,
    );
    originalTestExceptionReporter(details, testDescription);
  };
  WidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadEnv();
    await runAsync(prefetchEmojiFont);
    // Turn off the # in the URLs on the web
    usePathUrlStrategy();
    await SecureStorage.deleteAll();
  });

  group('Test all', () {
    patrolWidgetTest(
      'Create study',
      config: const PatrolTesterConfig(printLogs: true),
      (PatrolTester $) async {
        print("GO!");
        try {
          await Test1.go($).init();
        } catch (error, stackTrace) {
          markTestStep(
            'failure',
            'Create study',
            error: error,
            stackTrace: stackTrace,
          );
          final details = 'Create study failed: $error\n$stackTrace';
          print(details);
          fail(details);
        }
      },
    );
  });
}

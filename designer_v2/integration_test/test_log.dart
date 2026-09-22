import 'package:integration_test/integration_test.dart';

final List<Map<String, Object?>> testStepLog = [];
DateTime? _lastTestStepTimestamp;

void markTestStep(
  String status,
  String step, {
  Object? error,
  StackTrace? stackTrace,
}) {
  final now = DateTime.now();
  final elapsedMs = _lastTestStepTimestamp == null
      ? 0
      : now.difference(_lastTestStepTimestamp!).inMilliseconds;
  _lastTestStepTimestamp = now;

  final entry = <String, Object?>{
    'timestamp': now.toIso8601String(),
    'status': status,
    'step': step,
    'elapsedMsSincePreviousLog': elapsedMs,
    if (error != null) 'error': error.toString(),
    if (stackTrace != null) 'stackTrace': stackTrace.toString(),
  };
  testStepLog.add(entry);

  IntegrationTestWidgetsFlutterBinding.instance.reportData = <String, dynamic>{
    'lastStep': step,
    'lastStatus': status,
    'stepLog': testStepLog,
  };

  print('[${entry['timestamp']}] [$status] $step (+${elapsedMs}ms)');
  if (error != null) {
    print('[${entry['timestamp']}] [error] $error');
  }
}

Future<T> runLoggedStep<T>(String step, Future<T> Function() action) async {
  markTestStep('start', step);
  try {
    final result = await action();
    markTestStep('success', step);
    return result;
  } catch (error, stackTrace) {
    markTestStep('failure', step, error: error, stackTrace: stackTrace);
    rethrow;
  }
}

void markTestStopped(String step) => markTestStep('stopped', step);

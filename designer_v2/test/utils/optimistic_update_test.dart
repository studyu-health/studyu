import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/utils/optimistic_update.dart';

void main() {
  test('optimistic update rolls back async failure', () async {
    var appliedOptimistically = false;
    var rolledBack = false;
    Object? capturedError;

    final update = OptimisticUpdate(
      applyOptimistic: () => appliedOptimistically = true,
      apply: () {
        throw StateError('delete failed');
      },
      rollback: () => rolledBack = true,
      onError: (error, _) => capturedError = error,
    );

    await runZonedGuarded(() async {
      await update.execute();
      await Future<void>.delayed(Duration.zero);
    }, (_, _) {});

    expect(appliedOptimistically, isTrue);
    expect(rolledBack, isTrue);
    expect(capturedError, isA<StateError>());
  });
}

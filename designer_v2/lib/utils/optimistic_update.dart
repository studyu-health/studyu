import 'dart:async';

import 'package:studyu_designer_v2/utils/performance.dart';

typedef VoidCallback = void Function();
typedef VoidFutureCallback = Future<void> Function();
typedef ErrorCallback = void Function(Object error, StackTrace? stackTrace);

/// Helper class to encapsulate optimistic operations that are rolled back
/// on error
class OptimisticUpdate({
  required final VoidCallback applyOptimistic,
  required final VoidFutureCallback apply,
  required final VoidCallback rollback,

  /// Callback that is always called after [apply] and [rollback]
  final VoidCallback? onUpdate,
  final ErrorCallback? onError,
  final bool rethrowErrors = false,

  /// Flag indicating whether the optimistic update should be run
  final bool runOptimistically = true,
  final bool completeFutureOptimistically = true,
}) {
  Future<void> execute() async {
    if (runOptimistically) {
      applyOptimistic();
    }
    _runUpdateHandlerIfAny();
    if (completeFutureOptimistically) {
      unawaited(_applyAndHandleErrors(rethrowSynchronously: false));
      return;
    }

    await _applyAndHandleErrors(rethrowSynchronously: true);
  }

  Future<void> _applyAndHandleErrors({
    required bool rethrowSynchronously,
  }) async {
    try {
      await runAsync(apply);
      _runUpdateHandlerIfAny();
    } catch (e, stackTrace) {
      onError?.call(e, stackTrace);
      rollback();
      _runUpdateHandlerIfAny();
      if (!rethrowErrors) {
        return;
      }
      if (rethrowSynchronously) {
        rethrow;
      }
      Zone.current.handleUncaughtError(e, stackTrace);
    }
  }

  void _runUpdateHandlerIfAny() {
    onUpdate?.call();
  }
}

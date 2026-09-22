import 'dart:async';

import 'package:rxdart/subjects.dart';

/// A BehaviorSubject that suppresses its initial event.
///
/// This class wraps a [BehaviorSubject] and suppresses the initial event
/// that is emitted upon subscription. All subsequent events are emitted
/// as usual.
class SuppressedBehaviorSubject<T>(final BehaviorSubject<T> subject) {
  bool didSuppressInitialEvent = false;

  late final StreamController<T> _controller = _buildDerivedController();

  StreamController<T> _buildDerivedController() {
    final StreamController<T> controller = StreamController.broadcast();
    final subjectSubscription = subject.listen((event) {
      if (!didSuppressInitialEvent) {
        didSuppressInitialEvent = true;
        return;
      }
      if (!subject.isClosed) {
        controller.add(event);
      }
    });
    controller.onCancel = () {
      subjectSubscription.cancel();
      controller.close();
    };
    return controller;
  }

  void close() {
    _controller.close();
  }
}

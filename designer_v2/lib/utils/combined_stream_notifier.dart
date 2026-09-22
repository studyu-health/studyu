import 'dart:async';

import 'package:flutter/material.dart';

/// A [ChangeNotifier] that reacts to events from multiple streams.
///
/// Inspired by [GoRouterRefreshStream]
/// This class can be used to make [GoRouter]'s `refreshListenable` react to
/// to events from multiple source streams.
class CombinedStreamNotifier(List<Stream<dynamic>> streams)
    extends ChangeNotifier {
  late final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Creates a [CombinedStreamNotifier].
  ///
  /// Every time any of the [streams] receives an event, the
  /// [CombinedStreamNotifier] will notify its listeners
  this {
    notifyListeners();
    for (final stream in streams) {
      final subscription = stream.asBroadcastStream().listen(
        (dynamic _) => notifyListeners(),
      );
      _subscriptions.add(subscription);
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}

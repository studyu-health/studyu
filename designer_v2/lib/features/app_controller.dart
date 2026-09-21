import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/app_controller_state.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

part 'app_controller.g.dart';

/// Interface for implementation by any resources that want to bind themselves
/// to the application lifecycle
abstract class IAppDelegate() {
  Future<bool> onAppStart();
}

/// Main controller that's bound to the top-level application widget's state
@riverpod
class AppController() extends _$AppController {
  @override
  Stream<AppControllerState> build() {
    state = const AsyncValue<AppControllerState>.data(AppControllerState());
    _appDelegates = [
      /// Register [IAppDelegate]s here for invocation of app lifecycle methods
      ref.watch(authRepositoryProvider),
    ];
    ref.onDispose(() {
      _stateController.close();
    });
    _initDelegates();
    return _stateController.stream;
  }

  Future<void> _initDelegates() async {
    // Forward onAppStart to all registered delegates so that they can
    // e.g. read some data from local storage for initialization
    await _callDelegates(
      (delegate) => delegate.onAppStart(),
      withMinDelay: true,
    );
    _stateController.add(
      const AppControllerState(status: AppStatus.initialized),
    );
  }

  Stream getStream() {
    return _stateController.stream;
  }

  final StreamController<AppControllerState> _stateController =
      StreamController<AppControllerState>.broadcast();

  bool isInitialized() {
    return state.value?.status == AppStatus.initialized;
  }

  /// List of listeners for app lifecycle events registered via Riverpod
  late final List<IAppDelegate> _appDelegates;

  /// A dummy [Future] used for setting a lower bound on app initialization
  /// (so that the splash screen is shown during this time)
  late final _delayedFuture = Future.delayed(
    // ignore: avoid_redundant_argument_values, use_named_constants
    const Duration(milliseconds: Config.minSplashTime),
    () => true,
  );

  /// Executes the given callback for all registered delegates concurrently
  Future<bool> _callDelegates(
    Future<bool> Function(IAppDelegate) function, {
    bool withMinDelay = false,
  }) async {
    final List<Future<bool>> delegateFutures = [];
    // Collect all delegated futures
    for (final delegate in _appDelegates) {
      final future = function(delegate);
      delegateFutures.add(future);
    }
    // Optionally add a delay
    if (withMinDelay) {
      delegateFutures.add(_delayedFuture);
    }
    // Wait for all futures to be completed while executing concurrently
    final List<bool> results = await Future.wait(delegateFutures);
    return !results.contains(false);
  }
}

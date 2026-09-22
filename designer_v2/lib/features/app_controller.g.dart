// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Main controller that's bound to the top-level application widget's state

@ProviderFor(AppController)
final appControllerProvider = AppControllerProvider._();

/// Main controller that's bound to the top-level application widget's state
final class AppControllerProvider
    extends $StreamNotifierProvider<AppController, AppControllerState> {
  /// Main controller that's bound to the top-level application widget's state
  AppControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appControllerHash();

  @$internal
  @override
  AppController create() => AppController();
}

String _$appControllerHash() => r'28c4d377d855d7c8f7fd54954fec7f2ea86514ce';

/// Main controller that's bound to the top-level application widget's state

abstract class _$AppController extends $StreamNotifier<AppControllerState> {
  Stream<AppControllerState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AppControllerState>, AppControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppControllerState>, AppControllerState>,
              AsyncValue<AppControllerState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

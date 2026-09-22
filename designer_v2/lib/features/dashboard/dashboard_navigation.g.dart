// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_navigation.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Indirection between the dashboard controller and the app router.
///
/// The dashboard controller depends on this provider rather than the full
/// `routerProvider`, so importing the dashboard does not transitively pull in
/// every routed feature (some of which import web-only libraries that break
/// VM-target test compilation). The default body throws — production must
/// override it (see `main.dart`), and tests override it with a no-op.

@ProviderFor(dashboardDispatch)
final dashboardDispatchProvider = DashboardDispatchProvider._();

/// Indirection between the dashboard controller and the app router.
///
/// The dashboard controller depends on this provider rather than the full
/// `routerProvider`, so importing the dashboard does not transitively pull in
/// every routed feature (some of which import web-only libraries that break
/// VM-target test compilation). The default body throws — production must
/// override it (see `main.dart`), and tests override it with a no-op.

final class DashboardDispatchProvider
    extends
        $FunctionalProvider<
          DashboardDispatch,
          DashboardDispatch,
          DashboardDispatch
        >
    with $Provider<DashboardDispatch> {
  /// Indirection between the dashboard controller and the app router.
  ///
  /// The dashboard controller depends on this provider rather than the full
  /// `routerProvider`, so importing the dashboard does not transitively pull in
  /// every routed feature (some of which import web-only libraries that break
  /// VM-target test compilation). The default body throws — production must
  /// override it (see `main.dart`), and tests override it with a no-op.
  DashboardDispatchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardDispatchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardDispatchHash();

  @$internal
  @override
  $ProviderElement<DashboardDispatch> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DashboardDispatch create(Ref ref) {
    return dashboardDispatch(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardDispatch value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardDispatch>(value),
    );
  }
}

String _$dashboardDispatchHash() => r'122c53248779409958b8e02528465067a7c9b4c9';

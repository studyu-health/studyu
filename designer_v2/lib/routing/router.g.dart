// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How to create a new page & use it for navigation:
///
/// 1. Add the [GoRoute] in router_config.dart and register it as
/// a [RouterConf.topLevelRoute] (most likely it should be a top-level
/// route, unless you know what you are doing with subroutes)
///
/// 2. To navigate to the new route from your code, specify one or more
/// [RoutingIntent]s in router_intent.dart. These intents correspond to
/// route changes in the app. See router_intent.dart for more details.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// How to create a new page & use it for navigation:
///
/// 1. Add the [GoRoute] in router_config.dart and register it as
/// a [RouterConf.topLevelRoute] (most likely it should be a top-level
/// route, unless you know what you are doing with subroutes)
///
/// 2. To navigate to the new route from your code, specify one or more
/// [RoutingIntent]s in router_intent.dart. These intents correspond to
/// route changes in the app. See router_intent.dart for more details.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// How to create a new page & use it for navigation:
  ///
  /// 1. Add the [GoRoute] in router_config.dart and register it as
  /// a [RouterConf.topLevelRoute] (most likely it should be a top-level
  /// route, unless you know what you are doing with subroutes)
  ///
  /// 2. To navigate to the new route from your code, specify one or more
  /// [RoutingIntent]s in router_intent.dart. These intents correspond to
  /// route changes in the app. See router_intent.dart for more details.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'dea90ea7ef7550959bbddbb70ed2cc457fe1367d';

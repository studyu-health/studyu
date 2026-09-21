// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocaleStateNotifier)
final localeStateProvider = LocaleStateNotifierProvider._();

final class LocaleStateNotifierProvider
    extends $NotifierProvider<LocaleStateNotifier, LocaleState> {
  LocaleStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeStateNotifierHash();

  @$internal
  @override
  LocaleStateNotifier create() => LocaleStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocaleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocaleState>(value),
    );
  }
}

String _$localeStateNotifierHash() =>
    r'0cd93339bf835b002d16c31eb876ef3fa52ee0b0';

abstract class _$LocaleStateNotifier extends $Notifier<LocaleState> {
  LocaleState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LocaleState, LocaleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LocaleState, LocaleState>,
              LocaleState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

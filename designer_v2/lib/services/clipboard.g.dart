// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clipboard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clipboardService)
final clipboardServiceProvider = ClipboardServiceProvider._();

final class ClipboardServiceProvider
    extends
        $FunctionalProvider<
          IClipboardService,
          IClipboardService,
          IClipboardService
        >
    with $Provider<IClipboardService> {
  ClipboardServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clipboardServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clipboardServiceHash();

  @$internal
  @override
  $ProviderElement<IClipboardService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IClipboardService create(Ref ref) {
    return clipboardService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IClipboardService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IClipboardService>(value),
    );
  }
}

String _$clipboardServiceHash() => r'fadcaa4f90d729c5e9b6ac021497e814bc150fff';

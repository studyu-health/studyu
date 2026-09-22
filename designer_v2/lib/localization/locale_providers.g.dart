// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Platform Locale Provider
/// Returns the locale of the Platform.localeName

@ProviderFor(platformLocale)
final platformLocaleProvider = PlatformLocaleProvider._();

/// Platform Locale Provider
/// Returns the locale of the Platform.localeName

final class PlatformLocaleProvider
    extends $FunctionalProvider<Locale, Locale, Locale>
    with $Provider<Locale> {
  /// Platform Locale Provider
  /// Returns the locale of the Platform.localeName
  PlatformLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformLocaleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformLocaleHash();

  @$internal
  @override
  $ProviderElement<Locale> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Locale create(Ref ref) {
    return platformLocale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$platformLocaleHash() => r'e490bf2439a27d6a6ca15f4029f5b198fd6817ba';

/// Supported Locales Provider

@ProviderFor(supportedLocales)
final supportedLocalesProvider = SupportedLocalesProvider._();

/// Supported Locales Provider

final class SupportedLocalesProvider
    extends $FunctionalProvider<List<Locale>, List<Locale>, List<Locale>>
    with $Provider<List<Locale>> {
  /// Supported Locales Provider
  SupportedLocalesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportedLocalesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportedLocalesHash();

  @$internal
  @override
  $ProviderElement<List<Locale>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Locale> create(Ref ref) {
    return supportedLocales(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Locale> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Locale>>(value),
    );
  }
}

String _$supportedLocalesHash() => r'9cd4634b71b66c5e97b66ecbfd966d91eecfcc64';

/// Locale Provider
/// Provides the current locale, and automatically updates when the locale changes.

@ProviderFor(locale)
final localeProvider = LocaleProvider._();

/// Locale Provider
/// Provides the current locale, and automatically updates when the locale changes.

final class LocaleProvider extends $FunctionalProvider<Locale, Locale, Locale>
    with $Provider<Locale> {
  /// Locale Provider
  /// Provides the current locale, and automatically updates when the locale changes.
  LocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeHash();

  @$internal
  @override
  $ProviderElement<Locale> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Locale create(Ref ref) {
    return locale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$localeHash() => r'83740ea99a0e1028ccb6d1d8119dc1448888164e';

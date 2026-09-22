// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

final class ApiClientProvider
    extends
        $FunctionalProvider<StudyUApiClient, StudyUApiClient, StudyUApiClient>
    with $Provider<StudyUApiClient> {
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<StudyUApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StudyUApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyUApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyUApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'743dbf00a2e1812c940839d579edd2cc43e0366f';

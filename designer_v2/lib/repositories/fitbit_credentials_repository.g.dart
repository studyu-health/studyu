// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitbit_credentials_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fitbitCredentialsRepository)
final fitbitCredentialsRepositoryProvider =
    FitbitCredentialsRepositoryFamily._();

final class FitbitCredentialsRepositoryProvider
    extends
        $FunctionalProvider<
          FitbitCredentialsRepository,
          FitbitCredentialsRepository,
          FitbitCredentialsRepository
        >
    with $Provider<FitbitCredentialsRepository> {
  FitbitCredentialsRepositoryProvider._({
    required FitbitCredentialsRepositoryFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'fitbitCredentialsRepositoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fitbitCredentialsRepositoryHash();

  @override
  String toString() {
    return r'fitbitCredentialsRepositoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<FitbitCredentialsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FitbitCredentialsRepository create(Ref ref) {
    final argument = this.argument as StudyID;
    return fitbitCredentialsRepository(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FitbitCredentialsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FitbitCredentialsRepository>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FitbitCredentialsRepositoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fitbitCredentialsRepositoryHash() =>
    r'b8531fc750bbd629e6b2ad8feab93da7082b0ca7';

final class FitbitCredentialsRepositoryFamily extends $Family
    with $FunctionalFamilyOverride<FitbitCredentialsRepository, StudyID> {
  FitbitCredentialsRepositoryFamily._()
    : super(
        retry: null,
        name: r'fitbitCredentialsRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FitbitCredentialsRepositoryProvider call(StudyID studyId) =>
      FitbitCredentialsRepositoryProvider._(argument: studyId, from: this);

  @override
  String toString() => r'fitbitCredentialsRepositoryProvider';
}

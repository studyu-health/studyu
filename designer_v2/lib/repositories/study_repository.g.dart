// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studyRepository)
final studyRepositoryProvider = StudyRepositoryProvider._();

final class StudyRepositoryProvider
    extends
        $FunctionalProvider<StudyRepository, StudyRepository, StudyRepository>
    with $Provider<StudyRepository> {
  StudyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyRepositoryHash();

  @$internal
  @override
  $ProviderElement<StudyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StudyRepository create(Ref ref) {
    return studyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyRepository>(value),
    );
  }
}

String _$studyRepositoryHash() => r'686459ebf3de467b6c2be2ad7e181eb7a5ed4fd6';

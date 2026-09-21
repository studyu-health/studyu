// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userRepository)
final userRepositoryProvider = UserRepositoryProvider._();

final class UserRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'ea3e6cdf902e456a28c46b3b01eb5bc2b591f02f';

@ProviderFor(UserState)
final userStateProvider = UserStateProvider._();

final class UserStateProvider
    extends $AsyncNotifierProvider<UserState, StudyUUser> {
  UserStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userStateHash();

  @$internal
  @override
  UserState create() => UserState();
}

String _$userStateHash() => r'8debda214e3dd6cb53468cc4d477df8adb482932';

abstract class _$UserState extends $AsyncNotifier<StudyUUser> {
  FutureOr<StudyUUser> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<StudyUUser>, StudyUUser>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<StudyUUser>, StudyUUser>,
              AsyncValue<StudyUUser>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

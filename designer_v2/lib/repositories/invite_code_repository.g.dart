// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_code_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inviteCodeRepository)
final inviteCodeRepositoryProvider = InviteCodeRepositoryFamily._();

final class InviteCodeRepositoryProvider
    extends
        $FunctionalProvider<
          InviteCodeRepository,
          InviteCodeRepository,
          InviteCodeRepository
        >
    with $Provider<InviteCodeRepository> {
  InviteCodeRepositoryProvider._({
    required InviteCodeRepositoryFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'inviteCodeRepositoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inviteCodeRepositoryHash();

  @override
  String toString() {
    return r'inviteCodeRepositoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<InviteCodeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InviteCodeRepository create(Ref ref) {
    final argument = this.argument as StudyID;
    return inviteCodeRepository(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InviteCodeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InviteCodeRepository>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InviteCodeRepositoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inviteCodeRepositoryHash() =>
    r'a9fb04158c1a28ab43e7db764875569151b7ad34';

final class InviteCodeRepositoryFamily extends $Family
    with $FunctionalFamilyOverride<InviteCodeRepository, StudyID> {
  InviteCodeRepositoryFamily._()
    : super(
        retry: null,
        name: r'inviteCodeRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InviteCodeRepositoryProvider call(StudyID studyId) =>
      InviteCodeRepositoryProvider._(argument: studyId, from: this);

  @override
  String toString() => r'inviteCodeRepositoryProvider';
}

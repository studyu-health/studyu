// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_test_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudyTestController)
final studyTestControllerProvider = StudyTestControllerFamily._();

final class StudyTestControllerProvider
    extends $NotifierProvider<StudyTestController, StudyTestControllerState> {
  StudyTestControllerProvider._({
    required StudyTestControllerFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'studyTestControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyTestControllerHash();

  @override
  String toString() {
    return r'studyTestControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StudyTestController create() => StudyTestController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyTestControllerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyTestControllerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudyTestControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyTestControllerHash() =>
    r'9a0cf27813e58fff60d1652f2ee4044c40763736';

final class StudyTestControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StudyTestController,
          StudyTestControllerState,
          StudyTestControllerState,
          StudyTestControllerState,
          StudyID
        > {
  StudyTestControllerFamily._()
    : super(
        retry: null,
        name: r'studyTestControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudyTestControllerProvider call(StudyID studyId) =>
      StudyTestControllerProvider._(argument: studyId, from: this);

  @override
  String toString() => r'studyTestControllerProvider';
}

abstract class _$StudyTestController
    extends $Notifier<StudyTestControllerState> {
  late final _$args = ref.$arg as StudyID;
  StudyID get studyId => _$args;

  StudyTestControllerState build(StudyID studyId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<StudyTestControllerState, StudyTestControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StudyTestControllerState, StudyTestControllerState>,
              StudyTestControllerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Provide a controller parametrized by [StudyID]

@ProviderFor(studyTestPlatformController)
final studyTestPlatformControllerProvider =
    StudyTestPlatformControllerFamily._();

/// Provide a controller parametrized by [StudyID]

final class StudyTestPlatformControllerProvider
    extends
        $FunctionalProvider<
          PlatformController,
          PlatformController,
          PlatformController
        >
    with $Provider<PlatformController> {
  /// Provide a controller parametrized by [StudyID]
  StudyTestPlatformControllerProvider._({
    required StudyTestPlatformControllerFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'studyTestPlatformControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyTestPlatformControllerHash();

  @override
  String toString() {
    return r'studyTestPlatformControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<PlatformController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlatformController create(Ref ref) {
    final argument = this.argument as StudyID;
    return studyTestPlatformController(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlatformController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlatformController>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudyTestPlatformControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyTestPlatformControllerHash() =>
    r'1c9fb9e71895b8be7542eafd6185641c2b31766e';

/// Provide a controller parametrized by [StudyID]

final class StudyTestPlatformControllerFamily extends $Family
    with $FunctionalFamilyOverride<PlatformController, StudyID> {
  StudyTestPlatformControllerFamily._()
    : super(
        retry: null,
        name: r'studyTestPlatformControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provide a controller parametrized by [StudyID]

  StudyTestPlatformControllerProvider call(StudyID studyId) =>
      StudyTestPlatformControllerProvider._(argument: studyId, from: this);

  @override
  String toString() => r'studyTestPlatformControllerProvider';
}

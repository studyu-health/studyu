// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudyController)
final studyControllerProvider = StudyControllerFamily._();

final class StudyControllerProvider
    extends $NotifierProvider<StudyController, StudyControllerState> {
  StudyControllerProvider._({
    required StudyControllerFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'studyControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyControllerHash();

  @override
  String toString() {
    return r'studyControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StudyController create() => StudyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyControllerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyControllerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudyControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyControllerHash() => r'82a17ea3572d46aa96ef53bb39c06588a8926bc2';

final class StudyControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StudyController,
          StudyControllerState,
          StudyControllerState,
          StudyControllerState,
          StudyID
        > {
  StudyControllerFamily._()
    : super(
        retry: null,
        name: r'studyControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudyControllerProvider call(StudyID studyId) =>
      StudyControllerProvider._(argument: studyId, from: this);

  @override
  String toString() => r'studyControllerProvider';
}

abstract class _$StudyController extends $Notifier<StudyControllerState> {
  late final _$args = ref.$arg as StudyID;
  StudyID get studyId => _$args;

  StudyControllerState build(StudyID studyId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StudyControllerState, StudyControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StudyControllerState, StudyControllerState>,
              StudyControllerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

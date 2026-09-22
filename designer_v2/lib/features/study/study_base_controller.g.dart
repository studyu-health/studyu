// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_base_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudyBaseController)
final studyBaseControllerProvider = StudyBaseControllerFamily._();

final class StudyBaseControllerProvider<T extends StudyControllerBaseState>
    extends
        $NotifierProvider<StudyBaseController<T>, StudyControllerBaseState> {
  StudyBaseControllerProvider._({
    required StudyBaseControllerFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'studyBaseControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyBaseControllerHash();

  @override
  String toString() {
    return r'studyBaseControllerProvider'
        '<${T}>'
        '($argument)';
  }

  @$internal
  @override
  StudyBaseController<T> create() => StudyBaseController<T>();

  $R _captureGenerics<$R>(
    $R Function<T extends StudyControllerBaseState>() cb,
  ) {
    return cb<T>();
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyControllerBaseState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyControllerBaseState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudyBaseControllerProvider &&
        other.runtimeType == runtimeType &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, argument);
  }
}

String _$studyBaseControllerHash() =>
    r'5440172703363f8c16a51b78e152f8ff563cb89c';

final class StudyBaseControllerFamily extends $Family {
  StudyBaseControllerFamily._()
    : super(
        retry: null,
        name: r'studyBaseControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudyBaseControllerProvider<T> call<T extends StudyControllerBaseState>(
    StudyID studyId,
  ) => StudyBaseControllerProvider<T>._(argument: studyId, from: this);

  @override
  String toString() => r'studyBaseControllerProvider';

  /// {@macro riverpod.override_with}
  Override overrideWith(
    StudyBaseController<T> Function<T extends StudyControllerBaseState>()
    create,
  ) => $FamilyOverride(
    from: this,
    createElement: (pointer) {
      final provider = pointer.origin as StudyBaseControllerProvider;
      return provider._captureGenerics(<T extends StudyControllerBaseState>() {
        provider as StudyBaseControllerProvider<T>;
        return provider.$view(create: create<T>).$createElement(pointer);
      });
    },
  );

  /// {@macro riverpod.override_with_build}
  Override overrideWithBuild(
    StudyControllerBaseState Function<T extends StudyControllerBaseState>(
      Ref ref,
      StudyBaseController<T> notifier,
    )
    build,
  ) => $FamilyOverride(
    from: this,
    createElement: (pointer) {
      final provider = pointer.origin as StudyBaseControllerProvider;
      return provider._captureGenerics(<T extends StudyControllerBaseState>() {
        provider as StudyBaseControllerProvider<T>;
        return provider
            .$view(runNotifierBuildOverride: build<T>)
            .$createElement(pointer);
      });
    },
  );
}

abstract class _$StudyBaseController<T extends StudyControllerBaseState>
    extends $Notifier<StudyControllerBaseState> {
  late final _$args = ref.$arg as StudyID;
  StudyID get studyId => _$args;

  StudyControllerBaseState build(StudyID studyId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<StudyControllerBaseState, StudyControllerBaseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StudyControllerBaseState, StudyControllerBaseState>,
              StudyControllerBaseState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

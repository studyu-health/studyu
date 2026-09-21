// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_analyze_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudyAnalyzeController)
final studyAnalyzeControllerProvider = StudyAnalyzeControllerFamily._();

final class StudyAnalyzeControllerProvider
    extends
        $NotifierProvider<StudyAnalyzeController, StudyAnalyzeControllerState> {
  StudyAnalyzeControllerProvider._({
    required StudyAnalyzeControllerFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'studyAnalyzeControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyAnalyzeControllerHash();

  @override
  String toString() {
    return r'studyAnalyzeControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StudyAnalyzeController create() => StudyAnalyzeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyAnalyzeControllerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyAnalyzeControllerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudyAnalyzeControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyAnalyzeControllerHash() =>
    r'f96f24e6ac63585165fddf098b2856a248527b90';

final class StudyAnalyzeControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StudyAnalyzeController,
          StudyAnalyzeControllerState,
          StudyAnalyzeControllerState,
          StudyAnalyzeControllerState,
          StudyID
        > {
  StudyAnalyzeControllerFamily._()
    : super(
        retry: null,
        name: r'studyAnalyzeControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudyAnalyzeControllerProvider call(StudyID studyId) =>
      StudyAnalyzeControllerProvider._(argument: studyId, from: this);

  @override
  String toString() => r'studyAnalyzeControllerProvider';
}

abstract class _$StudyAnalyzeController
    extends $Notifier<StudyAnalyzeControllerState> {
  late final _$args = ref.$arg as StudyID;
  StudyID get studyId => _$args;

  StudyAnalyzeControllerState build(StudyID studyId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<StudyAnalyzeControllerState, StudyAnalyzeControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                StudyAnalyzeControllerState,
                StudyAnalyzeControllerState
              >,
              StudyAnalyzeControllerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

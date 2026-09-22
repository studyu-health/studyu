// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [FormViewModel] that is responsible for displaying and
/// editing the study design form.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])

@ProviderFor(studyFormViewModel)
final studyFormViewModelProvider = StudyFormViewModelFamily._();

/// Provides the [FormViewModel] that is responsible for displaying and
/// editing the study design form.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])

final class StudyFormViewModelProvider
    extends
        $FunctionalProvider<
          StudyFormViewModel,
          StudyFormViewModel,
          StudyFormViewModel
        >
    with $Provider<StudyFormViewModel> {
  /// Provides the [FormViewModel] that is responsible for displaying and
  /// editing the study design form.
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
  StudyFormViewModelProvider._({
    required StudyFormViewModelFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'studyFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyFormViewModelHash();

  @override
  String toString() {
    return r'studyFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<StudyFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StudyFormViewModel create(Ref ref) {
    final argument = this.argument as StudyID;
    return studyFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyFormViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudyFormViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyFormViewModelHash() =>
    r'a01564a7663f92d4351bc24971f769e6f87cf9b2';

/// Provides the [FormViewModel] that is responsible for displaying and
/// editing the study design form.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])

final class StudyFormViewModelFamily extends $Family
    with $FunctionalFamilyOverride<StudyFormViewModel, StudyID> {
  StudyFormViewModelFamily._()
    : super(
        retry: null,
        name: r'studyFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides the [FormViewModel] that is responsible for displaying and
  /// editing the study design form.
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])

  StudyFormViewModelProvider call(StudyID studyId) =>
      StudyFormViewModelProvider._(argument: studyId, from: this);

  @override
  String toString() => r'studyFormViewModelProvider';
}

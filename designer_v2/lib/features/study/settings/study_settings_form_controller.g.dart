// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_settings_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [FormViewModel] responsible for managing the study settings.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])

@ProviderFor(studySettingsFormViewModel)
final studySettingsFormViewModelProvider = StudySettingsFormViewModelFamily._();

/// Provides the [FormViewModel] responsible for managing the study settings.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])

final class StudySettingsFormViewModelProvider
    extends
        $FunctionalProvider<
          StudySettingsFormViewModel,
          StudySettingsFormViewModel,
          StudySettingsFormViewModel
        >
    with $Provider<StudySettingsFormViewModel> {
  /// Provides the [FormViewModel] responsible for managing the study settings.
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
  StudySettingsFormViewModelProvider._({
    required StudySettingsFormViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studySettingsFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studySettingsFormViewModelHash();

  @override
  String toString() {
    return r'studySettingsFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<StudySettingsFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StudySettingsFormViewModel create(Ref ref) {
    final argument = this.argument as String;
    return studySettingsFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudySettingsFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudySettingsFormViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudySettingsFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studySettingsFormViewModelHash() =>
    r'55e809cbdc32d665203afa436e11046be1b6acd6';

/// Provides the [FormViewModel] responsible for managing the study settings.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])

final class StudySettingsFormViewModelFamily extends $Family
    with $FunctionalFamilyOverride<StudySettingsFormViewModel, String> {
  StudySettingsFormViewModelFamily._()
    : super(
        retry: null,
        name: r'studySettingsFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides the [FormViewModel] responsible for managing the study settings.
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])

  StudySettingsFormViewModelProvider call(String studyId) =>
      StudySettingsFormViewModelProvider._(argument: studyId, from: this);

  @override
  String toString() => r'studySettingsFormViewModelProvider';
}

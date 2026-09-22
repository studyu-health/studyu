// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitbit_credentials_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fitbitCredentialsFormViewModel)
final fitbitCredentialsFormViewModelProvider =
    FitbitCredentialsFormViewModelFamily._();

final class FitbitCredentialsFormViewModelProvider
    extends
        $FunctionalProvider<
          FitbitCredentialsFormViewModel,
          FitbitCredentialsFormViewModel,
          FitbitCredentialsFormViewModel
        >
    with $Provider<FitbitCredentialsFormViewModel> {
  FitbitCredentialsFormViewModelProvider._({
    required FitbitCredentialsFormViewModelFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'fitbitCredentialsFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fitbitCredentialsFormViewModelHash();

  @override
  String toString() {
    return r'fitbitCredentialsFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<FitbitCredentialsFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FitbitCredentialsFormViewModel create(Ref ref) {
    final argument = this.argument as StudyID;
    return fitbitCredentialsFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FitbitCredentialsFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FitbitCredentialsFormViewModel>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FitbitCredentialsFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fitbitCredentialsFormViewModelHash() =>
    r'dd4d4a74b099d59056da3a49b9d6554603f430ad';

final class FitbitCredentialsFormViewModelFamily extends $Family
    with $FunctionalFamilyOverride<FitbitCredentialsFormViewModel, StudyID> {
  FitbitCredentialsFormViewModelFamily._()
    : super(
        retry: null,
        name: r'fitbitCredentialsFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FitbitCredentialsFormViewModelProvider call(StudyID studyId) =>
      FitbitCredentialsFormViewModelProvider._(argument: studyId, from: this);

  @override
  String toString() => r'fitbitCredentialsFormViewModelProvider';
}

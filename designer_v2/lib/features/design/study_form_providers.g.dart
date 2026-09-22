// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_form_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studyInfoFormViewModel)
final studyInfoFormViewModelProvider = StudyInfoFormViewModelFamily._();

final class StudyInfoFormViewModelProvider
    extends
        $FunctionalProvider<
          StudyInfoFormViewModel,
          StudyInfoFormViewModel,
          StudyInfoFormViewModel
        >
    with $Provider<StudyInfoFormViewModel> {
  StudyInfoFormViewModelProvider._({
    required StudyInfoFormViewModelFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'studyInfoFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyInfoFormViewModelHash();

  @override
  String toString() {
    return r'studyInfoFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<StudyInfoFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StudyInfoFormViewModel create(Ref ref) {
    final argument = this.argument as StudyID;
    return studyInfoFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyInfoFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyInfoFormViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudyInfoFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyInfoFormViewModelHash() =>
    r'5c8e15ba88d7868835fab650519ae93111c380aa';

final class StudyInfoFormViewModelFamily extends $Family
    with $FunctionalFamilyOverride<StudyInfoFormViewModel, StudyID> {
  StudyInfoFormViewModelFamily._()
    : super(
        retry: null,
        name: r'studyInfoFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudyInfoFormViewModelProvider call(StudyID studyId) =>
      StudyInfoFormViewModelProvider._(argument: studyId, from: this);

  @override
  String toString() => r'studyInfoFormViewModelProvider';
}

@ProviderFor(enrollmentFormViewModel)
final enrollmentFormViewModelProvider = EnrollmentFormViewModelFamily._();

final class EnrollmentFormViewModelProvider
    extends
        $FunctionalProvider<
          EnrollmentFormViewModel,
          EnrollmentFormViewModel,
          EnrollmentFormViewModel
        >
    with $Provider<EnrollmentFormViewModel> {
  EnrollmentFormViewModelProvider._({
    required EnrollmentFormViewModelFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'enrollmentFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$enrollmentFormViewModelHash();

  @override
  String toString() {
    return r'enrollmentFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EnrollmentFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EnrollmentFormViewModel create(Ref ref) {
    final argument = this.argument as StudyID;
    return enrollmentFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnrollmentFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnrollmentFormViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EnrollmentFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$enrollmentFormViewModelHash() =>
    r'd41cdb067044c6a683bb9e3cbf7260561a681657';

final class EnrollmentFormViewModelFamily extends $Family
    with $FunctionalFamilyOverride<EnrollmentFormViewModel, StudyID> {
  EnrollmentFormViewModelFamily._()
    : super(
        retry: null,
        name: r'enrollmentFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EnrollmentFormViewModelProvider call(StudyID studyId) =>
      EnrollmentFormViewModelProvider._(argument: studyId, from: this);

  @override
  String toString() => r'enrollmentFormViewModelProvider';
}

@ProviderFor(screenerQuestionFormViewModel)
final screenerQuestionFormViewModelProvider =
    ScreenerQuestionFormViewModelFamily._();

final class ScreenerQuestionFormViewModelProvider
    extends
        $FunctionalProvider<
          ScreenerQuestionFormViewModel,
          ScreenerQuestionFormViewModel,
          ScreenerQuestionFormViewModel
        >
    with $Provider<ScreenerQuestionFormViewModel> {
  ScreenerQuestionFormViewModelProvider._({
    required ScreenerQuestionFormViewModelFamily super.from,
    required ScreenerQuestionFormRouteArgs super.argument,
  }) : super(
         retry: null,
         name: r'screenerQuestionFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$screenerQuestionFormViewModelHash();

  @override
  String toString() {
    return r'screenerQuestionFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ScreenerQuestionFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScreenerQuestionFormViewModel create(Ref ref) {
    final argument = this.argument as ScreenerQuestionFormRouteArgs;
    return screenerQuestionFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScreenerQuestionFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScreenerQuestionFormViewModel>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ScreenerQuestionFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$screenerQuestionFormViewModelHash() =>
    r'59315db1776e5f6fcc23580a90b137c08d5e6b7f';

final class ScreenerQuestionFormViewModelFamily extends $Family
    with
        $FunctionalFamilyOverride<
          ScreenerQuestionFormViewModel,
          ScreenerQuestionFormRouteArgs
        > {
  ScreenerQuestionFormViewModelFamily._()
    : super(
        retry: null,
        name: r'screenerQuestionFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ScreenerQuestionFormViewModelProvider call(
    ScreenerQuestionFormRouteArgs args,
  ) => ScreenerQuestionFormViewModelProvider._(argument: args, from: this);

  @override
  String toString() => r'screenerQuestionFormViewModelProvider';
}

@ProviderFor(consentItemFormViewModel)
final consentItemFormViewModelProvider = ConsentItemFormViewModelFamily._();

final class ConsentItemFormViewModelProvider
    extends
        $FunctionalProvider<
          ConsentItemFormViewModel,
          ConsentItemFormViewModel,
          ConsentItemFormViewModel
        >
    with $Provider<ConsentItemFormViewModel> {
  ConsentItemFormViewModelProvider._({
    required ConsentItemFormViewModelFamily super.from,
    required ConsentItemFormRouteArgs super.argument,
  }) : super(
         retry: null,
         name: r'consentItemFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$consentItemFormViewModelHash();

  @override
  String toString() {
    return r'consentItemFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ConsentItemFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConsentItemFormViewModel create(Ref ref) {
    final argument = this.argument as ConsentItemFormRouteArgs;
    return consentItemFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConsentItemFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConsentItemFormViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConsentItemFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$consentItemFormViewModelHash() =>
    r'2e27c1f83cafe5e2e578b9f5421915d299540c1f';

final class ConsentItemFormViewModelFamily extends $Family
    with
        $FunctionalFamilyOverride<
          ConsentItemFormViewModel,
          ConsentItemFormRouteArgs
        > {
  ConsentItemFormViewModelFamily._()
    : super(
        retry: null,
        name: r'consentItemFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConsentItemFormViewModelProvider call(ConsentItemFormRouteArgs args) =>
      ConsentItemFormViewModelProvider._(argument: args, from: this);

  @override
  String toString() => r'consentItemFormViewModelProvider';
}

@ProviderFor(interventionsFormViewModel)
final interventionsFormViewModelProvider = InterventionsFormViewModelFamily._();

final class InterventionsFormViewModelProvider
    extends
        $FunctionalProvider<
          InterventionsFormViewModel,
          InterventionsFormViewModel,
          InterventionsFormViewModel
        >
    with $Provider<InterventionsFormViewModel> {
  InterventionsFormViewModelProvider._({
    required InterventionsFormViewModelFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'interventionsFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$interventionsFormViewModelHash();

  @override
  String toString() {
    return r'interventionsFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<InterventionsFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InterventionsFormViewModel create(Ref ref) {
    final argument = this.argument as StudyID;
    return interventionsFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InterventionsFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InterventionsFormViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InterventionsFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$interventionsFormViewModelHash() =>
    r'65e18dc8fa37860c31726352b99ac6c9b5de4bdb';

final class InterventionsFormViewModelFamily extends $Family
    with $FunctionalFamilyOverride<InterventionsFormViewModel, StudyID> {
  InterventionsFormViewModelFamily._()
    : super(
        retry: null,
        name: r'interventionsFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InterventionsFormViewModelProvider call(StudyID studyId) =>
      InterventionsFormViewModelProvider._(argument: studyId, from: this);

  @override
  String toString() => r'interventionsFormViewModelProvider';
}

@ProviderFor(interventionFormViewModel)
final interventionFormViewModelProvider = InterventionFormViewModelFamily._();

final class InterventionFormViewModelProvider
    extends
        $FunctionalProvider<
          InterventionFormViewModel,
          InterventionFormViewModel,
          InterventionFormViewModel
        >
    with $Provider<InterventionFormViewModel> {
  InterventionFormViewModelProvider._({
    required InterventionFormViewModelFamily super.from,
    required InterventionFormRouteArgs super.argument,
  }) : super(
         retry: null,
         name: r'interventionFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$interventionFormViewModelHash();

  @override
  String toString() {
    return r'interventionFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<InterventionFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InterventionFormViewModel create(Ref ref) {
    final argument = this.argument as InterventionFormRouteArgs;
    return interventionFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InterventionFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InterventionFormViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InterventionFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$interventionFormViewModelHash() =>
    r'1f661e24b1bfeee6e51a68cb156789bbd0b6fc9c';

final class InterventionFormViewModelFamily extends $Family
    with
        $FunctionalFamilyOverride<
          InterventionFormViewModel,
          InterventionFormRouteArgs
        > {
  InterventionFormViewModelFamily._()
    : super(
        retry: null,
        name: r'interventionFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InterventionFormViewModelProvider call(InterventionFormRouteArgs args) =>
      InterventionFormViewModelProvider._(argument: args, from: this);

  @override
  String toString() => r'interventionFormViewModelProvider';
}

@ProviderFor(interventionTaskFormViewModel)
final interventionTaskFormViewModelProvider =
    InterventionTaskFormViewModelFamily._();

final class InterventionTaskFormViewModelProvider
    extends
        $FunctionalProvider<
          InterventionTaskFormViewModel,
          InterventionTaskFormViewModel,
          InterventionTaskFormViewModel
        >
    with $Provider<InterventionTaskFormViewModel> {
  InterventionTaskFormViewModelProvider._({
    required InterventionTaskFormViewModelFamily super.from,
    required InterventionTaskFormRouteArgs super.argument,
  }) : super(
         retry: null,
         name: r'interventionTaskFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$interventionTaskFormViewModelHash();

  @override
  String toString() {
    return r'interventionTaskFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<InterventionTaskFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InterventionTaskFormViewModel create(Ref ref) {
    final argument = this.argument as InterventionTaskFormRouteArgs;
    return interventionTaskFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InterventionTaskFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InterventionTaskFormViewModel>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InterventionTaskFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$interventionTaskFormViewModelHash() =>
    r'1b6cdb9b40dcb77121ec70113867a8f4ab2628a8';

final class InterventionTaskFormViewModelFamily extends $Family
    with
        $FunctionalFamilyOverride<
          InterventionTaskFormViewModel,
          InterventionTaskFormRouteArgs
        > {
  InterventionTaskFormViewModelFamily._()
    : super(
        retry: null,
        name: r'interventionTaskFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InterventionTaskFormViewModelProvider call(
    InterventionTaskFormRouteArgs args,
  ) => InterventionTaskFormViewModelProvider._(argument: args, from: this);

  @override
  String toString() => r'interventionTaskFormViewModelProvider';
}

@ProviderFor(measurementsFormViewModel)
final measurementsFormViewModelProvider = MeasurementsFormViewModelFamily._();

final class MeasurementsFormViewModelProvider
    extends
        $FunctionalProvider<
          MeasurementsFormViewModel,
          MeasurementsFormViewModel,
          MeasurementsFormViewModel
        >
    with $Provider<MeasurementsFormViewModel> {
  MeasurementsFormViewModelProvider._({
    required MeasurementsFormViewModelFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'measurementsFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$measurementsFormViewModelHash();

  @override
  String toString() {
    return r'measurementsFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<MeasurementsFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MeasurementsFormViewModel create(Ref ref) {
    final argument = this.argument as StudyID;
    return measurementsFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MeasurementsFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MeasurementsFormViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MeasurementsFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$measurementsFormViewModelHash() =>
    r'a92c30b523d67c47db86b09bee1d176d8fccc2a5';

final class MeasurementsFormViewModelFamily extends $Family
    with $FunctionalFamilyOverride<MeasurementsFormViewModel, StudyID> {
  MeasurementsFormViewModelFamily._()
    : super(
        retry: null,
        name: r'measurementsFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MeasurementsFormViewModelProvider call(StudyID studyId) =>
      MeasurementsFormViewModelProvider._(argument: studyId, from: this);

  @override
  String toString() => r'measurementsFormViewModelProvider';
}

@ProviderFor(surveyFormViewModel)
final surveyFormViewModelProvider = SurveyFormViewModelFamily._();

final class SurveyFormViewModelProvider
    extends
        $FunctionalProvider<
          MeasurementSurveyFormViewModel,
          MeasurementSurveyFormViewModel,
          MeasurementSurveyFormViewModel
        >
    with $Provider<MeasurementSurveyFormViewModel> {
  SurveyFormViewModelProvider._({
    required SurveyFormViewModelFamily super.from,
    required MeasurementFormRouteArgs super.argument,
  }) : super(
         retry: null,
         name: r'surveyFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$surveyFormViewModelHash();

  @override
  String toString() {
    return r'surveyFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<MeasurementSurveyFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MeasurementSurveyFormViewModel create(Ref ref) {
    final argument = this.argument as MeasurementFormRouteArgs;
    return surveyFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MeasurementSurveyFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MeasurementSurveyFormViewModel>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SurveyFormViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$surveyFormViewModelHash() =>
    r'2cc4aef41c732ff379675a5ce4d5969a04c737ad';

final class SurveyFormViewModelFamily extends $Family
    with
        $FunctionalFamilyOverride<
          MeasurementSurveyFormViewModel,
          MeasurementFormRouteArgs
        > {
  SurveyFormViewModelFamily._()
    : super(
        retry: null,
        name: r'surveyFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SurveyFormViewModelProvider call(MeasurementFormRouteArgs args) =>
      SurveyFormViewModelProvider._(argument: args, from: this);

  @override
  String toString() => r'surveyFormViewModelProvider';
}

@ProviderFor(surveyQuestionFormViewModel)
final surveyQuestionFormViewModelProvider =
    SurveyQuestionFormViewModelFamily._();

final class SurveyQuestionFormViewModelProvider
    extends
        $FunctionalProvider<
          QuestionFormViewModel,
          QuestionFormViewModel,
          QuestionFormViewModel
        >
    with $Provider<QuestionFormViewModel> {
  SurveyQuestionFormViewModelProvider._({
    required SurveyQuestionFormViewModelFamily super.from,
    required SurveyQuestionFormRouteArgs super.argument,
  }) : super(
         retry: null,
         name: r'surveyQuestionFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$surveyQuestionFormViewModelHash();

  @override
  String toString() {
    return r'surveyQuestionFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<QuestionFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuestionFormViewModel create(Ref ref) {
    final argument = this.argument as SurveyQuestionFormRouteArgs;
    return surveyQuestionFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestionFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestionFormViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SurveyQuestionFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$surveyQuestionFormViewModelHash() =>
    r'd2b779f1b025110501edde497b421a479b1e059d';

final class SurveyQuestionFormViewModelFamily extends $Family
    with
        $FunctionalFamilyOverride<
          QuestionFormViewModel,
          SurveyQuestionFormRouteArgs
        > {
  SurveyQuestionFormViewModelFamily._()
    : super(
        retry: null,
        name: r'surveyQuestionFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SurveyQuestionFormViewModelProvider call(SurveyQuestionFormRouteArgs args) =>
      SurveyQuestionFormViewModelProvider._(argument: args, from: this);

  @override
  String toString() => r'surveyQuestionFormViewModelProvider';
}

@ProviderFor(reportsFormViewModel)
final reportsFormViewModelProvider = ReportsFormViewModelFamily._();

final class ReportsFormViewModelProvider
    extends
        $FunctionalProvider<
          ReportsFormViewModel,
          ReportsFormViewModel,
          ReportsFormViewModel
        >
    with $Provider<ReportsFormViewModel> {
  ReportsFormViewModelProvider._({
    required ReportsFormViewModelFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'reportsFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reportsFormViewModelHash();

  @override
  String toString() {
    return r'reportsFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ReportsFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReportsFormViewModel create(Ref ref) {
    final argument = this.argument as StudyID;
    return reportsFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportsFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportsFormViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReportsFormViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reportsFormViewModelHash() =>
    r'570680561e1f2f5cc5c740b221ef2a0d8405bc6f';

final class ReportsFormViewModelFamily extends $Family
    with $FunctionalFamilyOverride<ReportsFormViewModel, StudyID> {
  ReportsFormViewModelFamily._()
    : super(
        retry: null,
        name: r'reportsFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReportsFormViewModelProvider call(StudyID studyId) =>
      ReportsFormViewModelProvider._(argument: studyId, from: this);

  @override
  String toString() => r'reportsFormViewModelProvider';
}

@ProviderFor(reportItemFormViewModel)
final reportItemFormViewModelProvider = ReportItemFormViewModelFamily._();

final class ReportItemFormViewModelProvider
    extends
        $FunctionalProvider<
          ReportItemFormViewModel,
          ReportItemFormViewModel,
          ReportItemFormViewModel
        >
    with $Provider<ReportItemFormViewModel> {
  ReportItemFormViewModelProvider._({
    required ReportItemFormViewModelFamily super.from,
    required ReportItemFormRouteArgs super.argument,
  }) : super(
         retry: null,
         name: r'reportItemFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reportItemFormViewModelHash();

  @override
  String toString() {
    return r'reportItemFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ReportItemFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReportItemFormViewModel create(Ref ref) {
    final argument = this.argument as ReportItemFormRouteArgs;
    return reportItemFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportItemFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportItemFormViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReportItemFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reportItemFormViewModelHash() =>
    r'34aad4103b63c267100cf7465127254feef5b90f';

final class ReportItemFormViewModelFamily extends $Family
    with
        $FunctionalFamilyOverride<
          ReportItemFormViewModel,
          ReportItemFormRouteArgs
        > {
  ReportItemFormViewModelFamily._()
    : super(
        retry: null,
        name: r'reportItemFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReportItemFormViewModelProvider call(ReportItemFormRouteArgs args) =>
      ReportItemFormViewModelProvider._(argument: args, from: this);

  @override
  String toString() => r'reportItemFormViewModelProvider';
}

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.publish]

@ProviderFor(studyPublishValidator)
final studyPublishValidatorProvider = StudyPublishValidatorFamily._();

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.publish]

final class StudyPublishValidatorProvider
    extends
        $FunctionalProvider<
          StudyFormViewModel,
          StudyFormViewModel,
          StudyFormViewModel
        >
    with $Provider<StudyFormViewModel> {
  /// Provides the [StudyFormViewModel] for validation purposes with
  /// a [StudyFormValidationSet.publish]
  StudyPublishValidatorProvider._({
    required StudyPublishValidatorFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'studyPublishValidatorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyPublishValidatorHash();

  @override
  String toString() {
    return r'studyPublishValidatorProvider'
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
    return studyPublishValidator(ref, argument);
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
    return other is StudyPublishValidatorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyPublishValidatorHash() =>
    r'1d5f1448a789bcfd7391dd63f6055d7fb137f29c';

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.publish]

final class StudyPublishValidatorFamily extends $Family
    with $FunctionalFamilyOverride<StudyFormViewModel, StudyID> {
  StudyPublishValidatorFamily._()
    : super(
        retry: null,
        name: r'studyPublishValidatorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides the [StudyFormViewModel] for validation purposes with
  /// a [StudyFormValidationSet.publish]

  StudyPublishValidatorProvider call(StudyID studyId) =>
      StudyPublishValidatorProvider._(argument: studyId, from: this);

  @override
  String toString() => r'studyPublishValidatorProvider';
}

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.test]

@ProviderFor(studyTestValidator)
final studyTestValidatorProvider = StudyTestValidatorFamily._();

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.test]

final class StudyTestValidatorProvider
    extends
        $FunctionalProvider<
          StudyFormViewModel,
          StudyFormViewModel,
          StudyFormViewModel
        >
    with $Provider<StudyFormViewModel> {
  /// Provides the [StudyFormViewModel] for validation purposes with
  /// a [StudyFormValidationSet.test]
  StudyTestValidatorProvider._({
    required StudyTestValidatorFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'studyTestValidatorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyTestValidatorHash();

  @override
  String toString() {
    return r'studyTestValidatorProvider'
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
    return studyTestValidator(ref, argument);
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
    return other is StudyTestValidatorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyTestValidatorHash() =>
    r'c7c697b8302808a287fab879a7e6b3f2878829e7';

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.test]

final class StudyTestValidatorFamily extends $Family
    with $FunctionalFamilyOverride<StudyFormViewModel, StudyID> {
  StudyTestValidatorFamily._()
    : super(
        retry: null,
        name: r'studyTestValidatorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides the [StudyFormViewModel] for validation purposes with
  /// a [StudyFormValidationSet.test]

  StudyTestValidatorProvider call(StudyID studyId) =>
      StudyTestValidatorProvider._(argument: studyId, from: this);

  @override
  String toString() => r'studyTestValidatorProvider';
}

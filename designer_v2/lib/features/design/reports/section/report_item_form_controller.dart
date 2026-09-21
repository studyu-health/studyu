import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/section.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_data.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/data_reference_identifier.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/section_type.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:uuid/uuid.dart';

class ReportItemFormViewModel({
  super.formData,
  super.delegate,
  super.validationSet = StudyFormValidationSet.draft,
}) extends ManagedFormViewModel<ReportItemFormData> {
  static const defaultSectionType = ReportSectionType.average;

  // - Form fields (any section type)

  String get sectionId => sectionIdControl.value!;
  final FormControl<SectionID> sectionIdControl = FormControl(
    value: const Uuid().v4(),
  ); // hidden
  late final FormControl<ReportSectionType> sectionTypeControl =
      CustomFormControl(
        value: defaultSectionType,
        onValueChanged: onSectionTypeChanged,
      );
  final FormControl<String> titleControl = FormControl();
  final FormControl<String> descriptionControl = FormControl();

  final FormControl<ReportSection> sectionControl = CustomFormControl(
    value: AverageSection.withId(),
  );

  ReportSectionType get sectionType =>
      sectionTypeControl.value ?? defaultSectionType;

  static List<FormControlOption<ReportSectionType>>
  get sectionTypeControlOptions => ReportSectionType.values
      .map((e) => FormControlOption(e, e.string))
      .toList();

  // DataReference might need to be section specific in the future
  final FormControl<DataReferenceIdentifier<num>> dataReferenceControl =
      FormControl();

  // - Form fields (section type-specific)

  // -- Average
  static List<FormControlOption<TemporalAggregationFormatted>>
  get temporalAggregationControlOptions => TemporalAggregationFormatted.values
      .map((e) => FormControlOption(e, e.string))
      .toList();
  final FormControl<TemporalAggregationFormatted> temporalAggregationControl =
      FormControl();

  // -- LinearRegression
  static List<FormControlOption<ImprovementDirectionFormatted>>
  get improvementDirectionControlOptions => ImprovementDirectionFormatted.values
      .map((e) => FormControlOption(e, e.string))
      .toList();
  final FormControl<ImprovementDirectionFormatted> improvementDirectionControl =
      FormControl();
  final FormControl<double> alphaControl = FormControl();

  @override
  Map<FormMode, String> get titles => {
    FormMode.create: tr.form_report_create,
    FormMode.edit: tr.form_report_edit,
    FormMode.readonly: tr.form_report_readonly,
  };

  late final Map<ReportSectionType, FormGroup> _controlsBySectionType = {
    ReportSectionType.average: FormGroup({
      'temporalAggregation': temporalAggregationControl,
    }),
    ReportSectionType.linearRegression: FormGroup({
      'improvementDirection': improvementDirectionControl,
      'alphaControl': alphaControl,
    }),
    ReportSectionType.textualSummary: FormGroup({}),
    ReportSectionType.gaugeComparison: FormGroup({}),
    ReportSectionType.descriptiveStats: FormGroup({}),
  };

  late final FormValidationConfigSet _sharedValidationConfig = {
    StudyFormValidationSet.draft: [
      titleRequired,
      descriptionRequired,
      dataReferenceRequired,
    ],
    StudyFormValidationSet.publish: [
      titleRequired,
      descriptionRequired,
      dataReferenceRequired,
    ],
    StudyFormValidationSet.test: [
      titleRequired,
      descriptionRequired,
      dataReferenceRequired,
    ],
  };

  late final Map<ReportSectionType, FormValidationConfigSet>
  _validationConfigsBySectionType = {
    ReportSectionType.average: {
      StudyFormValidationSet.draft: [aggregationRequired],
      StudyFormValidationSet.publish: [aggregationRequired],
      StudyFormValidationSet.test: [aggregationRequired],
    },
    ReportSectionType.linearRegression: {
      StudyFormValidationSet.draft: [
        improvementDirectionRequired,
        alphaConfidenceRequired,
      ],
      StudyFormValidationSet.publish: [
        improvementDirectionRequired,
        alphaConfidenceRequired,
      ],
      StudyFormValidationSet.test: [
        improvementDirectionRequired,
        alphaConfidenceRequired,
      ],
    },
    ReportSectionType.textualSummary: {
      StudyFormValidationSet.draft: [],
      StudyFormValidationSet.publish: [],
      StudyFormValidationSet.test: [],
    },
    ReportSectionType.gaugeComparison: {
      StudyFormValidationSet.draft: [],
      StudyFormValidationSet.publish: [],
      StudyFormValidationSet.test: [],
    },
    ReportSectionType.descriptiveStats: {
      StudyFormValidationSet.draft: [],
      StudyFormValidationSet.publish: [],
      StudyFormValidationSet.test: [],
    },
  };

  @override
  FormValidationConfigSet get sharedValidationConfig => {
    StudyFormValidationSet.draft: _getValidationConfig(
      StudyFormValidationSet.draft,
    ),
    StudyFormValidationSet.publish: _getValidationConfig(
      StudyFormValidationSet.publish,
    ),
    StudyFormValidationSet.test: _getValidationConfig(
      StudyFormValidationSet.test,
    ),
  };

  List<FormControlValidation> _getValidationConfig(
    StudyFormValidationSet validationSet,
  ) {
    return [
      ..._sharedValidationConfig[validationSet] ?? [],
      ..._validationConfigsBySectionType[sectionType]?[validationSet] ?? [],
    ];
  }

  FormControlValidation get titleRequired => FormControlValidation(
    control: titleControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (error) =>
          tr.form_field_report_title_required,
    },
  );
  FormControlValidation get descriptionRequired => FormControlValidation(
    control: descriptionControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (error) => tr.form_field_report_text_required,
    },
  );

  FormControlValidation get dataReferenceRequired => FormControlValidation(
    control: dataReferenceControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (error) =>
          tr.form_field_report_data_source_required,
    },
  );

  // -- Average
  FormControlValidation get aggregationRequired => FormControlValidation(
    control: temporalAggregationControl,
    validators: [Validators.required],
    validationMessages: {
      ValidationMessage.required: (error) =>
          tr.form_field_report_temporalAggregation_required,
    },
  );

  // -- LinearRegression
  FormControlValidation get improvementDirectionRequired =>
      FormControlValidation(
        control: improvementDirectionControl,
        validators: [Validators.required],
        validationMessages: {
          ValidationMessage.required: (error) =>
              tr.form_field_report_improvementDirection_required,
        },
      );
  FormControlValidation get alphaConfidenceRequired => FormControlValidation(
    control: alphaControl,
    validators: [
      Validators.required, // todo numeric but also support decimal numbers e.g. 0.2 or 0,2
    ],
    validationMessages: {
      ValidationMessage.number: (error) =>
          tr.form_field_report_alphaConfidence_number,
    },
  );

  late final Map<String, AbstractControl> sectionBaseControls = {
    'sectionId': sectionIdControl, // hidden
    'section': sectionControl,
    'sectionType': sectionTypeControl,
    'description': descriptionControl,
    'title': titleControl,
    'dataReference': dataReferenceControl,
  };

  @override
  ReportItemFormData buildFormData() {
    ReportSection buildSectionSpecific(ReportSectionType sectionType) {
      switch (sectionType) {
        case ReportSectionType.average:
          final AverageSection averageSection = AverageSection();
          averageSection.aggregate = temporalAggregationControl.value!.value;
          averageSection.resultProperty = dataReferenceControl.value;
          return averageSection;
        case ReportSectionType.linearRegression:
          final LinearRegressionSection linearSection =
              LinearRegressionSection();
          linearSection.improvement = improvementDirectionControl.value!.value;
          linearSection.alpha = alphaControl.value!;
          linearSection.resultProperty = dataReferenceControl.value;
          return linearSection;
        case ReportSectionType.textualSummary:
          final TextualSummarySection textualSummarySection =
              TextualSummarySection();
          textualSummarySection.resultProperty = dataReferenceControl.value;
          return textualSummarySection;
        case ReportSectionType.gaugeComparison:
          final GaugeComparisonSection gaugeComparisonSection =
              GaugeComparisonSection();
          gaugeComparisonSection.resultProperty = dataReferenceControl.value;
          return gaugeComparisonSection;
        case ReportSectionType.descriptiveStats:
          final DescriptiveStatsSection descriptiveStatsSection =
              DescriptiveStatsSection();
          descriptiveStatsSection.resultProperty = dataReferenceControl.value;
          return descriptiveStatsSection;
      }
    }

    final sectionType = sectionTypeControl.value!;
    final ReportSection section = buildSectionSpecific(sectionType);

    section.id = sectionId;
    section.title = titleControl.value;
    section.description = descriptionControl.value;

    bool primaryStatus = false;
    if (formData != null) {
      primaryStatus = formData!.isPrimary;
    }
    return ReportItemFormData(isPrimary: primaryStatus, section: section);
  }

  // - ManagedFormViewModel
  @override
  ReportItemFormViewModel createDuplicate() {
    return ReportItemFormViewModel(
      formData: formData?.copy(),
      delegate: delegate,
      validationSet: validationSet,
    );
  }

  @override
  late final FormGroup form = FormGroup({
    ...sectionBaseControls,
    ..._controlsBySectionType[sectionType]!.controls,
  });

  void onSectionTypeChanged(ReportSectionType? sectionType) {
    _updateFormControls(sectionType);
  }

  /// Dynamically updates the [form] based on the given [sectionType]
  void _updateFormControls(ReportSectionType? sectionType) {
    final subtypeFormControls = _controlsBySectionType[sectionType]!.controls;
    for (final controlName in form.controls.keys) {
      if (!sectionBaseControls.containsKey(controlName)) {
        form.removeControl(controlName, emitEvent: false);
      }
    }
    form.addAll(subtypeFormControls);
    markFormGroupChanged();
  }

  @override
  void setControlsFrom(ReportItemFormData data) {
    final sectionType = ReportSectionType.of(data.section);
    // Shared Controls
    sectionIdControl.value = data.section.id;
    sectionTypeControl.value = sectionType;
    sectionControl.value = data.section;

    titleControl.value = data.section.title;
    descriptionControl.value = data.section.description;

    // Type-specific controls
    switch (sectionType) {
      case ReportSectionType.average:
        final AverageSection averageSection = data.section as AverageSection;
        temporalAggregationControl.value = TemporalAggregationFormatted(
          averageSection.aggregate!,
        );
        dataReferenceControl.value = DataReferenceIdentifier(
          averageSection.resultProperty!.task,
          averageSection.resultProperty!.property,
        );
      case ReportSectionType.linearRegression:
        final LinearRegressionSection linearRegressionSection =
            data.section as LinearRegressionSection;
        improvementDirectionControl.value = ImprovementDirectionFormatted(
          linearRegressionSection.improvement!,
        );
        alphaControl.value = linearRegressionSection.alpha;
        dataReferenceControl.value = DataReferenceIdentifier(
          linearRegressionSection.resultProperty!.task,
          linearRegressionSection.resultProperty!.property,
        );
      case ReportSectionType.textualSummary:
        final TextualSummarySection textualSummarySection =
            data.section as TextualSummarySection;

        dataReferenceControl.value = DataReferenceIdentifier(
          textualSummarySection.resultProperty!.task,
          textualSummarySection.resultProperty!.property,
        );
      case ReportSectionType.gaugeComparison:
        final GaugeComparisonSection gaugeComparisonSection =
            data.section as GaugeComparisonSection;

        dataReferenceControl.value = DataReferenceIdentifier(
          gaugeComparisonSection.resultProperty!.task,
          gaugeComparisonSection.resultProperty!.property,
        );
      case ReportSectionType.descriptiveStats:
        final DescriptiveStatsSection descriptiveStatsSection =
            data.section as DescriptiveStatsSection;

        dataReferenceControl.value = DataReferenceIdentifier(
          descriptiveStatsSection.resultProperty!.task,
          descriptiveStatsSection.resultProperty!.property,
        );
    }
  }
}

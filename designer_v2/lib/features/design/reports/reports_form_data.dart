import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class ReportsFormData({required final List<ReportItemFormData> reportItems})
    implements IStudyFormData {
  factory fromStudy(Study study) {
    return ReportsFormData(
      reportItems: ReportItemFormData.fromDomainModel(
        study.reportSpecification,
      ),
    );
  }

  @override
  Study apply(Study study) {
    study.reportSpecification.secondary = [];
    for (final ReportItemFormData itemFormData in reportItems) {
      if (itemFormData.isPrimary) {
        study.reportSpecification.primary = itemFormData.section;
      } else {
        study.reportSpecification.secondary.add(itemFormData.section);
      }
    }

    if (!reportItems.any((element) => element.isPrimary)) {
      study.reportSpecification.primary = null;
    }

    return study;
  }

  @override
  String get id => throw UnimplementedError(); // not needed for top-level form data

  @override
  ReportsFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }
}

enum ReportStatus() {
  primary,
  secondary;

  String toJson() => name;
  static ReportStatus fromJson(String json) => values.byName(json);
}

extension ReportStatusFormatted on ReportStatus {
  String get string {
    switch (this) {
      case ReportStatus.primary:
        return tr.report_status_primary;
      case ReportStatus.secondary:
        return tr.report_status_secondary;
    }
  }

  String get description {
    switch (this) {
      case ReportStatus.primary:
        return tr.report_status_primary_description;
      case ReportStatus.secondary:
        return tr.report_status_secondary_description;
    }
  }
}

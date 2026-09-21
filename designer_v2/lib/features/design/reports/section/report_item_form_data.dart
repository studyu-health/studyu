import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:uuid/uuid.dart';

class ReportItemFormData({
  required var bool isPrimary,
  required final ReportSection section,
}) extends IFormData {
  @override
  String get id => section.id;

  static List<ReportItemFormData> fromDomainModel(
    ReportSpecification reportSpecification,
  ) {
    final List<ReportItemFormData> reportsFormData = [];
    if (reportSpecification.primary != null) {
      reportsFormData.add(
        ReportItemFormData(
          isPrimary: true,
          section: reportSpecification.primary!,
        ),
      );
    }
    for (final ReportSection reportSection in reportSpecification.secondary) {
      reportsFormData.add(
        ReportItemFormData(isPrimary: false, section: reportSection),
      );
    }
    return reportsFormData;
  }

  @override
  ReportItemFormData copy() {
    final copy = ReportItemFormData(isPrimary: false, section: section);
    copy.section.id = const Uuid().v4(); // always regenerate id
    return copy;
  }
}

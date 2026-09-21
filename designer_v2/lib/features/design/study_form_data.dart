import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

abstract class IStudyFormData implements IFormData {
  factory fromStudy() {
    throw UnimplementedError("Subclass responsibility");
  }

  /// Applies the data stored in [IStudyFormData] to the given [study]
  /// by mapping the form's schema to the [Study] schema
  Study apply(Study study);
}

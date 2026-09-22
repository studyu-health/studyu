import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

ValidationResult validateConsent(Study study, ValidationLevel level) {
  final errors = <ValidationError>[];
  final warnings = <ValidationError>[];

  // Fact 21 — empty consent at publish is an error
  if (level == ValidationLevel.publish && study.consent.isEmpty) {
    errors.add(
      const ValidationError(
        code: 'consent.no_items',
        path: r'$.consent',
        message: 'No consent items defined — participants will not be shown consent terms in the app',
        fixHint: 'Add a consent item in the Enrollment section of the Designer, or leave empty if consent is obtained externally.',
      ),
    );
  }

  for (var i = 0; i < study.consent.length; i++) {
    final item = study.consent[i];

    // Fact 22
    if (item.title == null || item.title!.trim().isEmpty) {
      errors.add(
        ValidationError(
          code: 'consent.item_title_required',
          path: '\$.consent[$i].title',
          message: 'Consent item at index $i has no title',
          fixHint: 'Set a non-empty title for the consent item.',
        ),
      );
    }

    // Fact 23
    if (item.description == null || item.description!.trim().isEmpty) {
      errors.add(
        ValidationError(
          code: 'consent.item_description_required',
          path: '\$.consent[$i].description',
          message: 'Consent item at index $i has no description',
          fixHint: 'Set a non-empty description for the consent item.',
        ),
      );
    }
  }

  return ValidationResult(errors: errors, warnings: warnings);
}

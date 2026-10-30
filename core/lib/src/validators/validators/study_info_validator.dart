import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

ValidationResult validateStudyInfo(Study study, ValidationLevel level) {
  final errors = <ValidationError>[];

  if (study.title == null || study.title!.trim().isEmpty) {
    errors.add(
      const ValidationError(
        code: 'study_info.title_required',
        path: r'$.title',
        message: 'Study title is required',
        fixHint: 'Set a non-empty title',
      ),
    );
  }

  if (level == ValidationLevel.publish) {
    if (study.description == null || study.description!.trim().isEmpty) {
      errors.add(
        const ValidationError(
          code: 'study_info.description_required',
          path: r'$.description',
          message: 'Study description is required for publishing',
          fixHint: 'Add a description',
        ),
      );
    }
    if (study.iconName.trim().isEmpty) {
      errors.add(
        const ValidationError(
          code: 'study_info.icon_required',
          path: r'$.icon_name',
          message: 'Study icon is required for publishing',
          fixHint: 'Select an icon',
        ),
      );
    }
    if (study.contact.organization.trim().isEmpty) {
      errors.add(
        const ValidationError(
          code: 'study_info.organization_required',
          path: r'$.contact.organization',
          message: 'Organization is required for publishing',
          fixHint: 'Set the organization name',
        ),
      );
    }
    if (study.contact.institutionalReviewBoard == null ||
        study.contact.institutionalReviewBoard!.trim().isEmpty) {
      errors.add(
        const ValidationError(
          code: 'study_info.review_board_required',
          path: r'$.contact.institutionalReviewBoard',
          message: 'Institutional review board is required for publishing',
          fixHint: 'Set the review board name',
        ),
      );
    }
    if (study.contact.institutionalReviewBoardNumber == null ||
        study.contact.institutionalReviewBoardNumber!.trim().isEmpty) {
      errors.add(
        const ValidationError(
          code: 'study_info.review_board_number_required',
          path: r'$.contact.institutionalReviewBoardNumber',
          message: 'IRB number is required for publishing',
          fixHint: 'Set the IRB number',
        ),
      );
    }
    if (study.contact.researchers == null ||
        study.contact.researchers!.trim().isEmpty) {
      errors.add(
        const ValidationError(
          code: 'study_info.researchers_required',
          path: r'$.contact.researchers',
          message: 'Researcher names are required for publishing',
          fixHint: 'Set the researchers field',
        ),
      );
    }
    if (study.contact.email.trim().isEmpty) {
      errors.add(
        const ValidationError(
          code: 'study_info.email_required',
          path: r'$.contact.email',
          message: 'Contact email is required for publishing',
          fixHint: 'Set a contact email',
        ),
      );
    } else if (!study.contact.email.contains('@')) {
      // Fact 29 — basic email format check
      errors.add(
        ValidationError(
          code: 'study_info.email_invalid_format',
          path: r'$.contact.email',
          message:
              'Contact email "${study.contact.email}" does not contain "@"',
          fixHint: 'Set a valid email address containing "@".',
        ),
      );
    }
    if (study.contact.phone.trim().isEmpty) {
      errors.add(
        const ValidationError(
          code: 'study_info.phone_required',
          path: r'$.contact.phone',
          message: 'Contact phone is required for publishing',
          fixHint: 'Set a contact phone number',
        ),
      );
    }
  }

  return ValidationResult(errors: errors, warnings: []);
}

import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';

class StudyInfoFormData({
  required final String title,
  final String? description,
  required final StudyContactInfoFormData contactInfoFormData,
  required final String iconName,
}) implements IStudyFormData {
  factory fromStudy(Study study) {
    return StudyInfoFormData(
      title: study.title ?? '',
      description: study.description ?? '',
      iconName: study.iconName,
      contactInfoFormData: StudyContactInfoFormData.fromStudy(study),
    );
  }

  @override
  Study apply(Study study) {
    study.title = title;
    study.description = description;
    study.iconName = iconName;
    contactInfoFormData.apply(study);
    return study;
  }

  @override
  String get id => throw UnimplementedError(); // not needed for top-level form data

  @override
  StudyInfoFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }
}

class StudyContactInfoFormData({
  final String? organization,
  final String? institutionalReviewBoard,
  final String? institutionalReviewBoardNumber,
  final String? researchers,
  final String? email,
  final String? website,
  final String? phone,
  final String? additionalInfo,
}) implements IStudyFormData {
  factory fromStudy(Study study) {
    final contact = study.contact;
    return StudyContactInfoFormData(
      organization: contact.organization,
      institutionalReviewBoard: contact.institutionalReviewBoard ?? '',
      institutionalReviewBoardNumber:
          contact.institutionalReviewBoardNumber ?? '',
      researchers: contact.researchers ?? '',
      email: contact.email,
      website: contact.website,
      phone: contact.phone,
      additionalInfo: contact.additionalInfo,
    );
  }

  @override
  Study apply(Study study) {
    final contact = Contact();
    contact.organization = organization ?? '';
    contact.institutionalReviewBoard = institutionalReviewBoard;
    contact.institutionalReviewBoardNumber = institutionalReviewBoardNumber;
    contact.researchers = researchers;
    contact.email = email ?? '';
    contact.website = website ?? '';
    contact.phone = phone ?? '';
    contact.additionalInfo = (additionalInfo == null || additionalInfo!.isEmpty)
        ? null
        : additionalInfo;
    study.contact = contact;
    return study;
  }

  @override
  String get id => throw UnimplementedError(); // not needed for top-level form data

  @override
  StudyInfoFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }
}

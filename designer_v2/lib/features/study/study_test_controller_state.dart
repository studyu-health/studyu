import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

class const StudyTestControllerState({
  required super.studyId,
  required super.studyRepository,
  required super.router,
  required super.currentUser,
  required super.studyWithMetadata,
  final bool hasSession = false,
  final String languageCode = 'en',
}) extends StudyControllerBaseState {
  bool get canTest => hasSession;

  String get appUrl {
    if (!canTest || studyValue == null) return '';
    return buildPreviewAppUrl(
      baseUrl: env.appUrl ?? '',
      studyId: studyId,
      languageCode: languageCode,
    );
  }

  @override
  StudyTestControllerState copyWith({
    WrappedModel<Study>? studyWithMetadata,
    bool? hasSession,
    String? languageCode,
  }) {
    return StudyTestControllerState(
      studyId: studyId,
      studyRepository: studyRepository,
      router: router,
      currentUser: currentUser,
      studyWithMetadata: studyWithMetadata ?? super.studyWithMetadata,
      hasSession: hasSession ?? this.hasSession,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  // - Equatable

  @override
  List<Object?> get props => [...super.props, hasSession, languageCode];
}

String buildPreviewAppUrl({
  required String baseUrl,
  required String studyId,
  required String languageCode,
}) {
  if (baseUrl.isEmpty) return '';
  return '$baseUrl/preview?studyid=${Uri.encodeQueryComponent(studyId)}'
      '&languageCode=${Uri.encodeQueryComponent(languageCode)}';
}

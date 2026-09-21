import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/sync_indicator.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_actions.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/features/study/study_scaffold.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

class const StudyControllerState({
  required super.studyId,
  required super.studyRepository,
  required super.router,
  required super.currentUser,
  super.studyWithMetadata,
  @override final bool isDirty = false,
  @override final AsyncValue syncState = const AsyncValue<void>.data(null),
  @override final DateTime? lastSynced,
}) extends StudyControllerBaseState
    implements IStudyAppBarViewModel, ISyncIndicatorViewModel {
  bool get isPublished => studyValue?.status == StudyStatus.running;

  bool get isClosed => studyValue?.status == StudyStatus.closed;

  List<ModelAction> get studyActions {
    final studyVal = studyValue;
    if (studyVal == null) {
      return [];
    }
    // filter out edit action since we are already editing the study
    return withIcons(
      studyRepository
          .availableActions(studyVal)
          .where((action) => action.type != StudyActionType.edit)
          .toList(),
      studyActionIcons,
    );
  }

  // - ISyncIndicatorViewModel

  // - IStudyNavViewModel

  @override
  bool get isEditTabEnabled {
    final studyVal = studyValue;
    if (studyVal == null) {
      return true;
    }
    return studyVal.canEdit(super.currentUser) ||
        studyVal.publishedToRegistry ||
        studyVal.publishedToRegistryResults;
  }

  @override
  bool get isTestTabEnabled => isEditTabEnabled;

  @override
  bool get isRecruitTabEnabled {
    final studyVal = studyValue;
    if (studyVal == null) {
      return true;
    }
    return studyVal.canEdit(super.currentUser);
  }

  @override
  bool get isMonitorTabEnabled => isAnalyzeTabEnabled;

  @override
  bool get isAnalyzeTabEnabled {
    final studyVal = studyValue;
    if (studyVal == null) {
      return true;
    }
    return studyVal.canEdit(super.currentUser) ||
        studyVal.publishedToRegistryResults;
  }

  @override
  bool get isSettingsEnabled =>
      studyValue?.canChangeSettings(super.currentUser!) ?? false;

  // - IStudyAppBarViewModel

  @override
  bool get isStatusBadgeVisible =>
      studyStatus != null && studyStatus != StudyStatus.draft;

  @override
  bool get isSyncIndicatorVisible =>
      studyStatus != null && studyStatus == StudyStatus.draft;

  @override
  bool get isPublishVisible =>
      studyWithMetadata?.model.status == StudyStatus.draft;

  @override
  bool get isClosedVisible =>
      studyWithMetadata?.model.status == StudyStatus.running &&
      studyWithMetadata!.model.canEdit(super.currentUser);

  @override
  StudyStatus? get studyStatus => studyValue?.status;

  @override
  Participation? get studyParticipation => studyValue?.participation;

  // - Equatable

  @override
  List<Object?> get props => [...super.props, syncState, isDirty, lastSynced];

  @override
  StudyControllerState copyWith({
    WrappedModel<Study>? studyWithMetadata,
    bool? isDirty,
    AsyncValue? syncState,
    DateTime? lastSynced,
  }) {
    return StudyControllerState(
      studyId: studyId,
      studyRepository: studyRepository,
      router: router,
      currentUser: currentUser,
      studyWithMetadata: studyWithMetadata ?? super.studyWithMetadata,
      isDirty: isDirty ?? this.isDirty,
      syncState: syncState ?? this.syncState,
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }
}

extension StudyControllerStateUnsafeProps on StudyControllerState {
  /// Make sure to only access these in an [AsyncWidget] so that [studyValue]
  /// is available
  String get titleText => studyValueRequired.title ?? "";
}

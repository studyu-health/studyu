import 'package:studyu_core/core.dart' as core;
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:uuid/uuid.dart';

enum StudyActionType() {
  pin,
  pinoff,
  edit,
  duplicate,
  duplicateDraft,
  addCollaborator,
  export,
  exportDefinition,
  close,
  delete,
}

/// Provides a human-readable translation of the model action type
extension StudyActionTypeFormatted on StudyActionType {
  String get string {
    switch (this) {
      case StudyActionType.pin:
        return tr.action_pin;
      case StudyActionType.pinoff:
        return tr.action_unpin;
      case StudyActionType.edit:
        return tr.action_edit;
      case StudyActionType.close:
        return tr.action_button_study_close;
      case StudyActionType.delete:
        return tr.action_delete;
      case StudyActionType.duplicate:
        return tr.action_duplicate;
      case StudyActionType.duplicateDraft:
        return tr.action_study_duplicate_draft;
      case StudyActionType.addCollaborator:
        return "[StudyActionType.addCollaborator]"; // todo not implemented yet
      case StudyActionType.export:
        return tr.action_study_export_results;
      case StudyActionType.exportDefinition:
        return tr.action_export_study_definition;
    }
  }
}

typedef StudyID = String;
typedef MeasurementID = String;
typedef InstanceID = String;

typedef InterventionProvider = Intervention? Function(String id);

extension StudyHelpers on core.Study {
  Intervention? getIntervention(String id) {
    if (id == Study.baselineID) {
      return Intervention(Study.baselineID, 'Baseline'.hardcoded);
    }
    return interventions.firstWhereOrNull((i) => i.id == id);
  }
}

/// Provides a human-readable translation of the study status
extension StudyStatusFormatted on StudyStatus {
  String get string {
    switch (this) {
      case StudyStatus.draft:
        return tr.study_status_draft;
      case StudyStatus.running:
        return tr.study_status_running;
      case StudyStatus.closed:
        return tr.study_status_closed;
    }
  }

  String get description {
    switch (this) {
      case StudyStatus.draft:
        return tr.study_status_draft_description;
      case StudyStatus.running:
        return tr.study_status_running_description;
      case StudyStatus.closed:
        return tr.study_status_closed_description;
    }
  }
}

extension StudyInviteCodeX on Study {
  StudyInvite? getInvite(String code) {
    if (invites == null || invites!.isEmpty) {
      return null;
    }
    return invites!.firstWhere((invite) => invite.code == code);
  }
}

extension StudyDuplicateX on Study {
  Study exactDuplicate() {
    final copy = Study.fromJson(toJson());
    copy.copyJsonIgnoredAttributes(from: this, createdAt: true);
    return copy;
  }

  /// Creates a clean copy of the given [study] only containing the
  /// study protocol / editor data model
  Study duplicateAsDraft(String userId) {
    final copy = Study.fromJson(toJson());
    copy.resetJsonIgnoredAttributes();
    copy.title = (copy.title ?? '').withDuplicateLabel();
    copy.userId = userId;
    copy.status = StudyStatus.draft;
    copy.resultSharing = ResultSharing.private;
    copy.registryPublished = false;
    copy.results = [];
    copy.collaboratorEmails = [];
    copy.fitbitCredentials = null;
    copy.createdAt = DateTime.now();

    // Generate a new random UUIDs
    const uuid = Uuid();
    copy.id = uuid.v4();
    for (final intervention in copy.interventions) {
      intervention.id = uuid.v4();
    }

    final Map<String, String> oldObservationIdToNew = {};
    for (final observation in copy.observations) {
      final String newId = uuid.v4();
      oldObservationIdToNew[observation.id] = newId;
      observation.id = newId;
    }

    for (final report in [
      copy.reportSpecification.primary,
      ...copy.reportSpecification.secondary,
    ]) {
      report?.id = uuid.v4();

      if (report is core.AverageSection) {
        if (oldObservationIdToNew.containsKey(report.resultProperty?.task)) {
          report.resultProperty?.task =
              oldObservationIdToNew[report.resultProperty?.task]!;
        }
      } else if (report is core.LinearRegressionSection) {
        if (oldObservationIdToNew.containsKey(report.resultProperty?.task)) {
          report.resultProperty?.task =
              oldObservationIdToNew[report.resultProperty?.task]!;
        }
      } else if (report is core.TextualSummarySection) {
        if (oldObservationIdToNew.containsKey(report.resultProperty?.task)) {
          report.resultProperty?.task =
              oldObservationIdToNew[report.resultProperty?.task]!;
        }
      } else if (report is core.GaugeComparisonSection) {
        if (oldObservationIdToNew.containsKey(report.resultProperty?.task)) {
          report.resultProperty?.task =
              oldObservationIdToNew[report.resultProperty?.task]!;
        }
      } else if (report is core.DescriptiveStatsSection) {
        if (oldObservationIdToNew.containsKey(report.resultProperty?.task)) {
          report.resultProperty?.task =
              oldObservationIdToNew[report.resultProperty?.task]!;
        }
      }
    }

    return copy;
  }

  Study asNewlyPublished() {
    final copy = Study.fromJson(toJson());
    copy.copyJsonIgnoredAttributes(from: this, createdAt: true);
    copy.resetParticipantData();
    copy.status = StudyStatus.running;
    return copy;
  }

  Study copyJsonIgnoredAttributes({
    required Study from,
    bool createdAt = false,
  }) {
    participantCount = from.participantCount;
    activeSubjectCount = from.activeSubjectCount;
    endedCount = from.endedCount;
    missedDays = from.missedDays;
    repo = from.repo;
    invites = from.invites;
    participants = from.participants;
    participantsProgress = from.participantsProgress;
    if (createdAt) {
      this.createdAt = from.createdAt;
    }
    return this;
  }

  Study resetJsonIgnoredAttributes() {
    participantCount = 0;
    activeSubjectCount = 0;
    endedCount = 0;
    missedDays = [];
    repo = null;
    invites = [];
    participants = [];
    participantsProgress = [];
    createdAt = null;
    return this;
  }

  Study resetParticipantData() {
    participantCount = 0;
    activeSubjectCount = 0;
    endedCount = 0;
    missedDays = [];
    results = [];
    participants = [];
    participantsProgress = [];
    return this;
  }
}

extension StudyRegistryX on Study {
  bool get publishedToRegistry => registryPublished;
  bool get publishedToRegistryResults => resultSharing == ResultSharing.public;
}

class StudyTemplates() {
  static String get kUnnamedStudyTitle => tr.form_field_study_title_default;

  static Study emptyDraft(String userId) {
    final newDraft = Study.withId(userId);
    newDraft.title = StudyTemplates.kUnnamedStudyTitle;
    newDraft.iconName = '';
    return newDraft;
  }
}

extension StudyParticipantCountX on Study {
  int getParticipantCountForInvite(StudyInvite invite) {
    if (participants?.isEmpty ?? true) {
      return 0;
    }
    int count = 0;
    for (final participant in participants!) {
      if (!participant.isDeleted && participant.inviteCode == invite.code) {
        count += 1;
      }
    }
    return count;
  }
}

extension StudyPermissionsX on Study {
  bool canEditDraft(sb.User user) {
    return status == StudyStatus.draft && canEdit(user);
  }

  bool canCopy(sb.User user) {
    return canEdit(user) || registryPublished;
  }

  bool canDelete(sb.User user) {
    return isOwner(user);
  }

  bool canClose(sb.User user) {
    return isOwner(user);
  }

  bool canChangeSettings(sb.User user) {
    return isOwner(user);
  }
}

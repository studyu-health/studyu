import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:studyu_designer_v2/utils/input_formatter.dart';

class StudyScheduleFormData({
  required final PhaseSequence sequenceType,
  required final String sequenceTypeCustom,
  required final int numCycles,
  required final int phaseDuration,
  required final bool includeBaseline,
}) implements IStudyFormData {
  factory fromDomainModel(StudySchedule schedule) {
    return StudyScheduleFormData(
      sequenceType: schedule.sequence,
      sequenceTypeCustom: schedule.sequenceCustom,
      numCycles: schedule.numberOfCycles,
      phaseDuration: schedule.phaseDuration,
      includeBaseline: schedule.includeBaseline,
    );
  }

  StudySchedule toStudySchedule() {
    final schedule = StudySchedule();
    schedule.sequence = sequenceType;
    schedule.sequenceCustom = normalizeStudySequenceInput(sequenceTypeCustom);
    schedule.numberOfCycles = numCycles;
    schedule.phaseDuration = phaseDuration;
    schedule.includeBaseline = includeBaseline;
    return schedule;
  }

  @override
  Study apply(Study study) {
    study.schedule = toStudySchedule();
    return study;
  }

  @override
  StudyScheduleFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }

  @override
  FormDataID get id => throw UnimplementedError(); // not needed for top-level form data
}

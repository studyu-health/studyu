import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_data.dart';

void main() {
  group('StudyScheduleFormData', () {
    test(
      'normalizes custom sequence before applying it to the domain model',
      () {
        final data = StudyScheduleFormData(
          sequenceType: PhaseSequence.customized,
          sequenceTypeCustom: ' a b B a ',
          numCycles: 2,
          phaseDuration: 7,
          includeBaseline: true,
        );

        expect(data.toStudySchedule().sequenceCustom, 'ABBA');
      },
    );
  });
}

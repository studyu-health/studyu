import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('uses calendar dates for study days and intervention indexes', () {
    final start = DateTime(2025, 1, 1, 1);
    final nextCalendarDate = DateTime(2025, 1, 2);
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = start
      ..study = (Study('study', 'user')
        ..schedule = (StudySchedule()..phaseDuration = 1));

    expect(nextCalendarDate.difference(start).inHours, lessThan(24));
    expect(subject.getDayOfStudyFor(start), 0);
    expect(subject.getDayOfStudyFor(nextCalendarDate), 1);
    expect(subject.getInterventionIndexForDate(nextCalendarDate), 1);
  });
}

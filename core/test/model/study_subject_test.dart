import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('advances an untracked preview without saving to the server', () async {
    final startedAt = DateTime.utc(2025, 1, 2);
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = startedAt;

    await subject.setStartDateBackBy(days: 1, persist: false);

    expect(subject.startedAt, DateTime.utc(2025));
  });

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

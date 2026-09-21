import 'package:studyu_core/src/models/interventions/intervention.dart';
import 'package:studyu_core/src/models/interventions/tasks/checkmark_task.dart';
import 'package:studyu_core/src/models/study_schedule/study_schedule.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/interventions_validator.dart';
import 'package:test/test.dart';

Study _studyWith(
  List<Intervention> interventions, {
  PhaseSequence sequence = PhaseSequence.alternating,
}) {
  final s = Study('id', 'user');
  s.interventions = interventions;
  s.schedule.sequence = sequence;
  return s;
}

Intervention _namedIntervention(String name, {bool withTask = false}) {
  final i = Intervention.withId();
  i.name = name;
  if (withTask) {
    i.tasks = [CheckmarkTask.withId()];
  }
  return i;
}

void main() {
  group('validateInterventions - draft', () {
    test('passes with zero interventions', () {
      final r = validateInterventions(_studyWith([]), ValidationLevel.draft);
      expect(r.valid, isTrue);
    });
  });

  group('validateInterventions - publish', () {
    test('fails with zero interventions', () {
      final r = validateInterventions(_studyWith([]), ValidationLevel.publish);
      expect(r.valid, isFalse);
      expect(r.errors.first.code, 'interventions.at_least_one_required');
    });

    test('fails when intervention has no name', () {
      final i = Intervention.withId(); // name is null
      i.tasks = [CheckmarkTask.withId()];
      final r = validateInterventions(
        _studyWith([i, _namedIntervention('B', withTask: true)]),
        ValidationLevel.publish,
      );
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'interventions.name_required'),
        isTrue,
      );
    });

    test(
      'duplicate intervention IDs -> interventions.duplicate_intervention_id',
      () {
        final iA = _namedIntervention('A', withTask: true);
        final iB = _namedIntervention('B', withTask: true);
        iB.id = iA.id; // force duplicate
        final r = validateInterventions(
          _studyWith([iA, iB]),
          ValidationLevel.publish,
        );
        expect(r.valid, isFalse);
        expect(
          r.errors.any(
            (e) => e.code == 'interventions.duplicate_intervention_id',
          ),
          isTrue,
        );
      },
    );

    test('duplicate task IDs across interventions -> interventions.duplicate_task_id', () {
      final task = CheckmarkTask.withId();
      final iA = Intervention.withId()
        ..name = 'A'
        ..tasks = [task];
      final dupTask = CheckmarkTask.withId();
      dupTask.id = task.id; // same ID
      final iB = Intervention.withId()
        ..name = 'B'
        ..tasks = [dupTask];
      final r = validateInterventions(
        _studyWith([iA, iB]),
        ValidationLevel.publish,
      );
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'interventions.duplicate_task_id'),
        isTrue,
      );
    });

    test('two interventions, alternating sequence at publish -> passes', () {
      final r = validateInterventions(
        _studyWith([
          _namedIntervention('A', withTask: true),
          _namedIntervention('B', withTask: true),
        ]),
        ValidationLevel.publish,
      );
      expect(
        r.errors.where(
          (e) => e.code == 'interventions.count_must_be_two_for_sequence',
        ),
        isEmpty,
      );
    });

    test('one intervention, alternating sequence at publish -> no count error (count enforced at enrolment)', () {
      final r = validateInterventions(
        _studyWith([_namedIntervention('A', withTask: true)]),
        ValidationLevel.publish,
      );
      expect(
        r.errors.where(
          (e) => e.code == 'interventions.count_must_be_two_for_sequence',
        ),
        isEmpty,
      );
    });

    test('three interventions, customized sequence at publish -> passes', () {
      final r = validateInterventions(
        _studyWith([
          _namedIntervention('A', withTask: true),
          _namedIntervention('B', withTask: true),
          _namedIntervention('C', withTask: true),
        ], sequence: PhaseSequence.customized),
        ValidationLevel.publish,
      );
      expect(
        r.errors.where(
          (e) => e.code == 'interventions.count_must_be_two_for_sequence',
        ),
        isEmpty,
      );
    });

    test('intervention with empty tasks at publish -> interventions.no_tasks warning', () {
      final iA = _namedIntervention('A'); // no tasks
      final iB = _namedIntervention('B', withTask: true);
      final r = validateInterventions(
        _studyWith([iA, iB]),
        ValidationLevel.publish,
      );
      expect(r.valid, isTrue);
      expect(r.warnings.any((w) => w.code == 'interventions.no_tasks'), isTrue);
    });

    test('intervention with empty tasks at draft -> passes', () {
      final iA = _namedIntervention('A'); // no tasks
      final r = validateInterventions(_studyWith([iA]), ValidationLevel.draft);
      expect(
        r.errors.where((e) => e.code == 'interventions.no_tasks'),
        isEmpty,
      );
    });
  });
}

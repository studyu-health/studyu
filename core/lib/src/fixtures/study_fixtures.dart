import 'package:studyu_core/src/models/consent/consent_item.dart';
import 'package:studyu_core/src/models/eligibility/eligibility_criterion.dart';
import 'package:studyu_core/src/models/expressions/types/boolean_expression.dart';
import 'package:studyu_core/src/models/expressions/types/choice_expression.dart';
import 'package:studyu_core/src/models/interventions/intervention.dart';
import 'package:studyu_core/src/models/interventions/tasks/checkmark_task.dart';
import 'package:studyu_core/src/models/questionnaire/questions/boolean_question.dart';
import 'package:studyu_core/src/models/study_schedule/study_schedule.dart';
import 'package:studyu_core/src/models/tables/study.dart';

class StudyFixtures {
  StudyFixtures._();

  /// A minimal valid draft study.
  static Study minimal() {
    final s = Study('fixture-minimal', 'fixture-user');
    s.title = 'Minimal Study';
    return s;
  }

  /// A fully populated valid study ready to publish.
  static Study fullValid() {
    final s = Study('fixture-full', 'fixture-user');
    s.title = 'Full Valid Study';
    s.description = 'A complete study for testing';
    s.iconName = 'accountHeart';
    s.contact.email = 'test@studyu.health';
    s.contact.organization = 'Test Org';
    s.contact.institutionalReviewBoard = 'Test IRB';
    s.contact.institutionalReviewBoardNumber = 'IRB-001';
    s.contact.researchers = 'Alice, Bob';
    s.contact.phone = '+1234567890';
    s.contact.website = 'https://studyu.health';

    final taskA = CheckmarkTask.withId();
    final interventionA = Intervention.withId();
    interventionA.name = 'Treatment A';
    interventionA.tasks = [taskA];

    final taskB = CheckmarkTask.withId();
    final interventionB = Intervention.withId();
    interventionB.name = 'Treatment B';
    interventionB.tasks = [taskB];

    s.interventions = [interventionA, interventionB];

    s.schedule.phaseDuration = 7;
    s.schedule.numberOfCycles = 2;
    s.schedule.sequence = PhaseSequence.alternating;

    final consent = ConsentItem.withId();
    consent.title = 'Data Privacy';
    consent.description = 'Your data will be anonymised.';
    s.consent = [consent];

    return s;
  }

  /// An invalid study missing title (triggers study_info.title_required).
  static Study invalidMissingTitle() {
    final s = Study('fixture-no-title', 'fixture-user');
    // title intentionally left null
    return s;
  }

  /// An invalid study with a broken eligibility criterion reference.
  static Study invalidBrokenEligibilityRef() {
    final s = Study('fixture-broken-ref', 'fixture-user');
    s.title = 'Broken Ref Study';

    // Screener question
    final q = BooleanQuestion.withId();
    s.questionnaire.questions = [q];

    // Criterion that references a non-existent question id
    final criterion = EligibilityCriterion.withId();
    final expr = ChoiceExpression();
    expr.target = 'non-existent-uuid';
    criterion.condition = expr;
    s.eligibilityCriteria = [criterion];

    return s;
  }

  /// Triggers: consent.no_items
  static Study invalidNoConsentItems() {
    final s = fullValid();
    s.consent = [];
    return s;
  }

  /// Triggers: interventions.no_tasks
  static Study invalidInterventionNoTasks() {
    final s = fullValid();
    s.interventions.first.tasks = [];
    return s;
  }

  /// Triggers: interventions.duplicate_intervention_id
  static Study invalidDuplicateInterventionId() {
    final s = fullValid();
    s.interventions[1].id = s.interventions[0].id;
    return s;
  }

  /// Triggers: interventions.count_must_be_two_for_sequence
  static Study invalidThreeInterventionsAlternating() {
    final s = fullValid();
    final extra = Intervention.withId();
    extra.name = 'Treatment C';
    extra.tasks = [CheckmarkTask.withId()];
    s.interventions = [...s.interventions, extra];
    return s;
  }

  /// Triggers: schedule.custom_sequence_invalid_chars
  static Study invalidCustomSequenceBadChars() {
    final s = fullValid();
    s.schedule.sequence = PhaseSequence.customized;
    s.schedule.sequenceCustom = 'ABXYZ';
    return s;
  }

  /// Triggers: study_info.email_invalid_format
  static Study invalidBadEmailFormat() {
    final s = fullValid();
    s.contact.email = 'not-an-email';
    return s;
  }

  /// Triggers: eligibility.condition_always_true (warning)
  static Study warningAlwaysTrueEligibility() {
    final s = fullValid();
    final criterion = EligibilityCriterion.withId();
    // Default BooleanExpression has no target -> always true
    criterion.condition = BooleanExpression();
    s.eligibilityCriteria = [criterion];
    return s;
  }
}

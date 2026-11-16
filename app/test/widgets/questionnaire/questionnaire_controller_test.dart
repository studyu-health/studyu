import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_controller.dart';
import 'package:studyu_core/core.dart';

BooleanQuestion boolQuestion(String id, String prompt) =>
    BooleanQuestion.withId()
      ..id = id
      ..prompt = prompt;

FreeTextQuestion freeTextQuestion(String id, String prompt) =>
    FreeTextQuestion.withId(
        textType: FreeTextQuestionType.any,
        lengthRange: [1, 100],
      )
      ..id = id
      ..prompt = prompt;

FreeTextQuestion numericFreeTextQuestion(String id, String prompt) =>
    FreeTextQuestion.withId(
        textType: FreeTextQuestionType.numeric,
        lengthRange: [1, 100],
      )
      ..id = id
      ..prompt = prompt;

QuestionConditional<T> shownWhenQ1True<T>() =>
    QuestionConditional<T>.withCondition(
      CompositeExpression(
        logicType: LogicType.and,
        expressions: [BooleanExpression()..target = 'q1'],
      ),
    );

void main() {
  group('QuestionnaireController', () {
    // ── Test 1: visibleQuestions derived from committed answers ──

    test('visibleQuestions reflects committed answer state', () {
      final q1 = boolQuestion('q1', 'Show follow-up?');
      final q2 = freeTextQuestion('q2', 'Enter text')
        ..conditional = shownWhenQ1True<String>();

      final controller = QuestionnaireController([q1, q2]);

      // Initially: q1 visible (no conditional), q2 hidden (q1 unanswered)
      expect(controller.visibleQuestions.length, equals(1));
      expect(controller.visibleQuestions.first.id, equals('q1'));

      // After submitting q1 = true, q2 becomes visible
      controller.submitAnswer(q1.constructAnswer(true));
      expect(controller.visibleQuestions.length, equals(2));
      expect(
        controller.visibleQuestions.map((q) => q.id),
        containsAll(['q1', 'q2']),
      );

      // After submitting q1 = false, q2 hides again
      controller.submitAnswer(q1.constructAnswer(false));
      expect(controller.visibleQuestions.length, equals(1));
      expect(controller.visibleQuestions.first.id, equals('q1'));
    });

    test('empty optional choice answers drive choice visibility', () {
      final q1 = ChoiceQuestion.withId()
        ..id = 'q1'
        ..prompt = 'Select any'
        ..multiple = true
        ..choices = [Choice.withText(id: 'a', text: 'A')];
      final q2 = boolQuestion('q2', 'Shown when A is selected')
        ..conditional = QuestionConditional<bool>.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [
              ChoiceExpression()
                ..target = q1.id
                ..choices = {'a'},
            ],
          ),
        );
      final q3 = boolQuestion('q3', 'Shown when A is not selected')
        ..conditional = QuestionConditional<bool>.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [
              NotExpression()
                ..expression = (ChoiceExpression()
                  ..target = q1.id
                  ..choices = {'a'}),
            ],
          ),
        );
      final controller = QuestionnaireController([q1, q2, q3]);

      expect(controller.visibleQuestions.map((q) => q.id), ['q1']);

      controller.submitAnswer(q1.constructAnswer([]));

      expect(controller.visibleQuestions.map((q) => q.id), ['q1', 'q3']);
    });

    // ── Test 2: hidden answers stored but excluded from payload ──

    test('hidden answers remain cached but excluded from payload', () {
      final q1 = boolQuestion('q1', 'Show follow-up?');
      final q2 = freeTextQuestion('q2', 'Enter text')
        ..conditional = shownWhenQ1True<String>();

      final controller = QuestionnaireController([q1, q2]);

      // q1 true → q2 visible → submit q2 answer
      controller.submitAnswer(q1.constructAnswer(true));
      controller.submitAnswer(q2.constructAnswer('cached'));

      // q1 false → q2 hidden
      controller.submitAnswer(q1.constructAnswer(false));

      // q2 answer still accessible via answerFor
      final a2 = controller.answerFor('q2')! as Answer<String>;
      expect(a2.response, equals('cached'));

      // payload excludes hidden q2
      final payload = controller.buildVisiblePayload();
      expect(payload.answers.containsKey('q1'), isTrue);
      expect(payload.answers.containsKey('q2'), isFalse);

      // q1 true again → answerFor q2 still cached
      final a2b = controller.answerFor('q2')! as Answer<String>;
      expect(a2b.response, equals('cached'));
    });

    test('hidden cached answers do not drive downstream visibility', () {
      final q1 = boolQuestion('q1', 'Show q2?');
      final q2 = boolQuestion('q2', 'Show q3?')
        ..conditional = QuestionConditional<bool>.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );
      final q3 = boolQuestion('q3', 'Downstream question')
        ..conditional = QuestionConditional<bool>.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q2'],
          ),
        );

      final controller = QuestionnaireController([q1, q2, q3]);

      controller.submitAnswer(q1.constructAnswer(true));
      controller.submitAnswer(q2.constructAnswer(true));
      controller.submitAnswer(q3.constructAnswer(true));
      expect(controller.visibleQuestions.map((q) => q.id), ['q1', 'q2', 'q3']);

      controller.submitAnswer(q1.constructAnswer(false));

      expect(controller.answerFor('q2'), isNotNull);
      expect(controller.answerFor('q3'), isNotNull);
      expect(controller.visibleQuestions.map((q) => q.id), ['q1']);
      expect(
        controller.buildVisiblePayload().answers.containsKey('q2'),
        isFalse,
      );
      expect(
        controller.buildVisiblePayload().answers.containsKey('q3'),
        isFalse,
      );
    });

    // ── Test 3: answers getter is defensive ──

    test('answers getter returns defensive copy', () {
      final q1 = boolQuestion('q1', 'Test question');
      final controller = QuestionnaireController([q1]);
      controller.submitAnswer(q1.constructAnswer(true));

      // Get answers copy
      final answersCopy = controller.answers;
      expect(answersCopy.answers.containsKey('q1'), isTrue);

      // Mutate the copy
      answersCopy.answers.clear();

      // Controller's internal state should be unaffected
      final a1 = controller.answerFor('q1')! as Answer<bool>;
      expect(a1.response, isTrue);
    });

    // ── Test 4: visibleQuestions getter is pure ──

    test('visibleQuestions getter is pure (no side effects)', () {
      final q1 = boolQuestion('q1', 'Parent question');
      final q2 = boolQuestion('q2', 'Hidden with default')
        ..conditional = QuestionConditional<bool>.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
          defaultValue: true,
        );

      final controller = QuestionnaireController([q1, q2]);

      // q2 default not yet applied
      expect(controller.answerFor('q2'), isNull);

      // visibleQuestions should not apply defaults
      final visible = controller.visibleQuestions;
      expect(visible.length, equals(1));
      expect(visible.first.id, equals('q1'));

      // q2 default should STILL not be applied after calling getter
      expect(controller.answerFor('q2'), isNull);

      // After submitting q1=false (makes q2 hidden), defaults get applied
      controller.submitAnswer(q1.constructAnswer(false));
      // q2 is hidden now, so its default should be applied
      final a2 = controller.answerFor('q2')! as Answer<bool>;
      expect(a2.response, isTrue);
    });

    // ── Test 5: null condition target stays hidden ──

    test('null condition target stays hidden until dependency answered', () {
      final q1 = boolQuestion('q1', 'Show follow-up?');
      final q2 = freeTextQuestion('q2', 'Enter text')
        ..conditional = shownWhenQ1True<String>();

      final controller = QuestionnaireController([q1, q2]);

      // No answer for q1 → condition evaluates to null → q2 hidden
      expect(controller.visibleQuestions.length, equals(1));
      expect(controller.visibleQuestions.first.id, equals('q1'));

      // Submit q1 = false → condition evaluates to false → q2 hidden
      controller.submitAnswer(q1.constructAnswer(false));
      expect(controller.visibleQuestions.length, equals(1));

      // Submit q1 = true → condition evaluates to true → q2 visible
      controller.submitAnswer(q1.constructAnswer(true));
      expect(controller.visibleQuestions.length, equals(2));
      expect(controller.visibleQuestions.map((q) => q.id), contains('q2'));
    });

    test('free text length conditional detects entered text', () {
      final q1 = freeTextQuestion('q1', 'Enter text');
      final q2 = boolQuestion('q2', 'Shown when text entered')
        ..conditional = QuestionConditional<bool>.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [
              TextExpression(
                comparator: TextComparator.lengthGreaterThan,
                value: '0',
              )..target = 'q1',
            ],
          ),
        );

      final controller = QuestionnaireController([q1, q2]);

      expect(controller.visibleQuestions.map((q) => q.id), ['q1']);

      controller.submitAnswer(q1.constructAnswer(''));
      expect(controller.visibleQuestions.map((q) => q.id), ['q1']);

      controller.submitAnswer(q1.constructAnswer('x'));
      expect(controller.visibleQuestions.map((q) => q.id), ['q1', 'q2']);
    });

    test('free text same length conditional compares character length', () {
      final q1 = freeTextQuestion('q1', 'Enter text');
      final q2 = boolQuestion('q2', 'Shown when same length')
        ..conditional = QuestionConditional<bool>.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [
              TextExpression(comparator: TextComparator.lengthEqual, value: '4')
                ..target = 'q1',
            ],
          ),
        );

      final controller = QuestionnaireController([q1, q2]);

      controller.submitAnswer(q1.constructAnswer('abc'));
      expect(controller.visibleQuestions.map((q) => q.id), ['q1']);

      controller.submitAnswer(q1.constructAnswer('abcd'));
      expect(controller.visibleQuestions.map((q) => q.id), ['q1', 'q2']);
    });

    test(
      'numeric free text numeric expression compares numeric answer value',
      () {
        final q1 = numericFreeTextQuestion('q1', 'Enter number');
        final q2 = boolQuestion('q2', 'Shown when value > 5')
          ..conditional = QuestionConditional<bool>.withCondition(
            CompositeExpression(
              logicType: LogicType.and,
              expressions: [
                NumericExpression(
                  comparator: NumericComparator.greaterThan,
                  value: 5,
                )..target = 'q1',
              ],
            ),
          );

        final controller = QuestionnaireController([q1, q2]);

        controller.submitAnswer(q1.constructAnswer('3'));
        expect(controller.visibleQuestions.map((q) => q.id), ['q1']);

        controller.submitAnswer(q1.constructAnswer('12'));
        expect(controller.visibleQuestions.map((q) => q.id), ['q1', 'q2']);
      },
    );

    // ── Test 6: no-op draft update does not notify listeners ──

    test('no-op draft update does not notify listeners', () {
      final q1 = freeTextQuestion('q1', 'Enter text');
      final controller = QuestionnaireController([q1]);

      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.updateFreeTextDraft('q1', '');
      expect(controller.hasDraft('q1'), isFalse);
      expect(notifyCount, equals(0));

      controller.updateFreeTextDraft('q1', 'hello');
      expect(notifyCount, equals(1));

      // Same value → no notification
      controller.updateFreeTextDraft('q1', 'hello');
      expect(notifyCount, equals(1));

      // Different value → notification
      controller.updateFreeTextDraft('q1', 'world');
      expect(notifyCount, equals(2));
    });

    test('clearing a committed free-text answer preserves an empty draft', () {
      final q1 = freeTextQuestion('q1', 'Enter text');
      final controller = QuestionnaireController([q1]);
      controller.submitAnswer(q1.constructAnswer('hello'));

      controller.updateFreeTextDraft('q1', '');

      expect(controller.hasDraft('q1'), isTrue);
      expect(controller.draftFor('q1'), isEmpty);
      expect(controller.answerFor('q1')?.response, 'hello');
      expect(controller.hasInvalidDraftAmong([q1]), isTrue);
      expect(controller.ctaModeFor([q1]), QuestionnaireCtaMode.hidden);
    });

    // ── Test 7: hidden default answers excluded from buildVisiblePayload ──

    test('hidden default answers are excluded from buildVisiblePayload', () {
      final q1 = boolQuestion('q1', 'Show q2?');
      final q2 = boolQuestion('q2', 'Hidden follow-up')
        ..conditional = QuestionConditional<bool>.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
          defaultValue: false,
        );

      final controller = QuestionnaireController([q1, q2]);

      // submit q1=false → q2 hidden → default (false) applied internally
      controller.submitAnswer(q1.constructAnswer(false));

      // answerFor returns the default
      final a2 = controller.answerFor('q2')! as Answer<bool>;
      expect(a2.response, isFalse);

      // buildVisiblePayload excludes hidden q2
      final payload = controller.buildVisiblePayload();
      expect(payload.answers.containsKey('q1'), isTrue);
      expect(payload.answers.containsKey('q2'), isFalse);
    });

    // ── Test 8: free-text drafts do not change visibility until committed ──

    test('free-text drafts do not change visibility until committed', () {
      final q1 = freeTextQuestion('q1', 'Type "show" to reveal q2');
      final q2 = boolQuestion('q2', 'Are you visible?')
        ..conditional = QuestionConditional<bool>.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [
              TextExpression(comparator: TextComparator.equal, value: 'show')
                ..target = 'q1',
            ],
          ),
        );

      final controller = QuestionnaireController([q1, q2]);

      // Initially: only q1 visible
      expect(controller.visibleQuestions.length, equals(1));
      expect(controller.visibleQuestions.first.id, equals('q1'));

      // updateFreeTextDraft does NOT reveal q2
      controller.updateFreeTextDraft('q1', 'show');
      expect(controller.visibleQuestions.length, equals(1));
      expect(controller.visibleQuestions.first.id, equals('q1'));

      // commitFreeTextDraft reveals q2
      controller.commitFreeTextDraft(q1);
      expect(controller.visibleQuestions.length, equals(2));
      expect(
        controller.visibleQuestions.map((q) => q.id),
        containsAll(['q1', 'q2']),
      );
    });
    // ── Test 9: allVisibleQuestionsAnswered detects incomplete visible questions ──

    test(
      'allVisibleQuestionsAnswered detects incomplete visible questions',
      () {
        final q1 = boolQuestion('q1', 'First');
        final q2 = boolQuestion('q2', 'Second');
        final controller = QuestionnaireController([q1, q2]);

        expect(controller.allVisibleQuestionsAnswered, isFalse);

        controller.submitAnswer(q1.constructAnswer(true));
        expect(controller.allVisibleQuestionsAnswered, isFalse);

        controller.submitAnswer(q2.constructAnswer(false));
        expect(controller.allVisibleQuestionsAnswered, isTrue);
      },
    );

    // ── Test 10: hasConditionalDependents handles nested expressions ──

    test('hasConditionalDependents handles nested expressions', () {
      final notExp = NotExpression()
        ..expression = (BooleanExpression()..target = 'q1');
      final q1 = boolQuestion('q1', 'Trigger');
      final q2 = freeTextQuestion('q2', 'Follow-up')
        ..conditional = QuestionConditional<String>.withCondition(
          CompositeExpression(logicType: LogicType.and, expressions: [notExp]),
        );
      final q3 = boolQuestion('q3', 'Unrelated');

      final controller = QuestionnaireController([q1, q2, q3]);

      // q1 is targeted by q2's nested expression tree
      expect(controller.hasConditionalDependents('q1'), isTrue);
      // q3 is not targeted by any conditional
      expect(controller.hasConditionalDependents('q3'), isFalse);
      // unknown id returns false
      expect(controller.hasConditionalDependents('nonexistent'), isFalse);
    });

    // ── Test 11: progressiveVisibleQuestions ──

    group('progressiveVisibleQuestions', () {
      test('reveals through already answered questions, excludes unanswered break point after first', () {
        final q1 = boolQuestion('q1', 'First');
        final q2 = boolQuestion('q2', 'Second');
        final q3 = boolQuestion('q3', 'Third');
        final controller = QuestionnaireController([q1, q2, q3]);

        // First question always included even unanswered
        expect(controller.progressiveVisibleQuestions.map((q) => q.id), ['q1']);

        controller.submitAnswer(q1.constructAnswer(true));
        // q1 answered, q2 unanswered → q2 excluded from progressive
        expect(controller.progressiveVisibleQuestions.map((q) => q.id), ['q1']);

        controller.submitAnswer(q2.constructAnswer(true));
        // q1+q2 answered, q3 unanswered → q3 excluded
        expect(controller.progressiveVisibleQuestions.map((q) => q.id), [
          'q1',
          'q2',
        ]);
      });

      test('skips hidden questions with conditionals', () {
        final q1 = boolQuestion('q1', 'Show q2?');
        final q2 = boolQuestion('q2', 'Conditional on q1')
          ..conditional = shownWhenQ1True<bool>();
        final q3 = boolQuestion('q3', 'Always visible');
        final controller = QuestionnaireController([q1, q2, q3]);

        // q1 not yet answered → q2 hidden
        expect(controller.progressiveVisibleQuestions.map((q) => q.id), ['q1']);

        // q1=true → q2 visible but unanswered → not in progressive
        controller.submitAnswer(q1.constructAnswer(true));
        expect(controller.progressiveVisibleQuestions.map((q) => q.id), ['q1']);

        // q2=true → q3 also visible but unanswered → not in progressive
        controller.submitAnswer(q2.constructAnswer(true));
        expect(controller.progressiveVisibleQuestions.map((q) => q.id), [
          'q1',
          'q2',
        ]);
      });

      test('hidden default drives progressive reveal of downstream question', () {
        final q1 = boolQuestion('q1', 'Hide default branch?');
        final q2 = boolQuestion('q2', 'Hidden default source')
          ..conditional = QuestionConditional<bool>.withCondition(
            CompositeExpression(
              logicType: LogicType.and,
              expressions: [BooleanExpression()..target = 'q1'],
            ),
            defaultValue: true,
          );
        final q3 = boolQuestion('q3', 'Revealed by default')
          ..conditional = QuestionConditional<bool>.withCondition(
            CompositeExpression(
              logicType: LogicType.and,
              expressions: [BooleanExpression()..target = 'q2'],
            ),
          );
        final controller = QuestionnaireController([q1, q2, q3]);

        // Answer q1=false → q2 hidden (default=true applied), q3 visible
        // but q3 is unanswered → excluded from progressive (not a break point)
        controller.submitAnswer(q1.constructAnswer(false));
        expect(controller.progressiveVisibleQuestions.map((q) => q.id), ['q1']);
        // q2 default does not appear in progressive (it's hidden)
        expect(
          controller.progressiveVisibleQuestions.map((q) => q.id),
          isNot(contains('q2')),
        );
      });
    });

    // ── Test 12: removeAnswer ──

    group('removeAnswer', () {
      test('removes existing answer and notifies listeners', () {
        final q1 = boolQuestion('q1', 'Test');
        final controller = QuestionnaireController([q1]);
        controller.submitAnswer(q1.constructAnswer(true));

        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.removeAnswer('q1');
        expect(controller.answerFor('q1'), isNull);
        expect(notifyCount, equals(1));
      });

      test('does not notify when answer does not exist', () {
        final q1 = boolQuestion('q1', 'Test');
        final controller = QuestionnaireController([q1]);

        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.removeAnswer('q1');
        expect(notifyCount, equals(0));
      });

      test('removes answer but keeps draft intact', () {
        final q1 = freeTextQuestion('q1', 'Enter text');
        final controller = QuestionnaireController([q1]);
        controller.submitAnswer(q1.constructAnswer('hello'));
        controller.updateFreeTextDraft('q1', 'draft text');

        controller.removeAnswer('q1');
        expect(controller.answerFor('q1'), isNull);
        expect(controller.draftFor('q1'), equals('draft text'));
      });
    });

    // ── Test 13: commitFreeTextDraftsFor applies hidden defaults ──

    test('commitFreeTextDraftsFor applies hidden defaults for cascade visibility', () {
      // q1: free-text. Typing "show" makes q2 visible; anything else hides it.
      final q1 = freeTextQuestion('q1', 'Type "show" to reveal q2');
      // q2: hidden when q1 != "show". Has default=true applied when hidden.
      final q2 = boolQuestion('q2', 'Hidden with default')
        ..conditional = QuestionConditional<bool>.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [
              TextExpression(comparator: TextComparator.equal, value: 'show')
                ..target = 'q1',
            ],
          ),
          defaultValue: true,
        );
      // q3: visible only when q2 = true, i.e. from q2's hidden default.
      final q3 = boolQuestion('q3', 'Revealed by hidden default cascade')
        ..conditional = QuestionConditional<bool>.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q2'],
          ),
        );
      final controller = QuestionnaireController([q1, q2, q3]);

      // Initially: only q1 visible (q2 hidden, q3 hidden)
      expect(controller.visibleQuestions.length, equals(1));
      expect(controller.visibleQuestions.first.id, equals('q1'));

      // Draft q1 with "hide" → will keep q2 hidden → q2 default should apply
      controller.updateFreeTextDraft('q1', 'hide');

      // Batch-commit the draft
      final error = controller.commitFreeTextDraftsFor([q1]);
      expect(error, isNull);

      // q2 default (true) must be applied since q2 is hidden
      final a2 = controller.answerFor('q2')! as Answer<bool>;
      expect(a2.response, isTrue);

      // q3 must become visible because q2 default (true) drives its condition
      expect(controller.visibleQuestions.map((q) => q.id), contains('q3'));

      // Draft should be cleared after commit
      expect(controller.draftFor('q1'), isEmpty);
    });

    test('batch free-text commit invalidates dependents and notifies once', () {
      final q1 = freeTextQuestion('q1', 'Earlier answer');
      final q2 = boolQuestion('q2', 'Later answer');
      final controller = QuestionnaireController([q1, q2]);

      controller.submitAnswer(q1.constructAnswer('old'));
      controller.submitAnswer(q2.constructAnswer(true));
      controller.updateFreeTextDraft('q1', 'new');

      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      expect(controller.commitFreeTextDraftsFor([q1]), isNull);

      expect(controller.answerFor('q1')?.response, 'new');
      expect(controller.needsReview('q2'), isTrue);
      expect(notifyCount, 1);
    });

    // ── Test 14: ctaMode and hasPendingBranchChange ──

    group('ctaMode', () {
      test('hidden when no visible question has input', () {
        final q1 = boolQuestion('q1', 'Yes/No?');
        final controller = QuestionnaireController([q1]);
        expect(controller.ctaMode, QuestionnaireCtaMode.hidden);
      });

      test('complete when all visible questions have answers', () {
        final q1 = boolQuestion('q1', 'Yes/No?');
        final q2 = boolQuestion('q2', 'Second');
        final controller = QuestionnaireController([q1, q2]);
        controller.submitAnswer(q1.constructAnswer(true));
        controller.submitAnswer(q2.constructAnswer(false));
        expect(controller.ctaMode, QuestionnaireCtaMode.complete);
      });

      test('hidden when visible free-text draft has pending branch change', () {
        final q1 = freeTextQuestion('q1', 'Branch text');
        final q2 = boolQuestion('q2', 'Follow-up')
          ..conditional = QuestionConditional<bool>.withCondition(
            CompositeExpression(
              logicType: LogicType.and,
              expressions: [
                TextExpression(comparator: TextComparator.equal, value: 'show')
                  ..target = 'q1',
              ],
            ),
          );
        final controller = QuestionnaireController([q1, q2]);
        controller.updateFreeTextDraft('q1', 'show');
        expect(controller.ctaMode, QuestionnaireCtaMode.hidden);
        expect(controller.hasPendingBranchChange, isTrue);
      });

      test('hidden when free-text has draft but no conditional dependents', () {
        final q1 = freeTextQuestion('q1', 'Final text');
        final controller = QuestionnaireController([q1]);
        controller.updateFreeTextDraft('q1', 'done');
        expect(controller.ctaMode, QuestionnaireCtaMode.hidden);
        expect(controller.hasPendingBranchChange, isFalse);
      });

      test('hidden when free-text draft differs from committed answer', () {
        final q1 = freeTextQuestion('q1', 'Branch text');
        final q2 = boolQuestion('q2', 'Follow-up')
          ..conditional = QuestionConditional<bool>.withCondition(
            CompositeExpression(
              logicType: LogicType.and,
              expressions: [
                TextExpression(comparator: TextComparator.equal, value: 'show')
                  ..target = 'q1',
              ],
            ),
          );
        final controller = QuestionnaireController([q1, q2]);
        controller.submitAnswer(q1.constructAnswer('hide'));
        controller.updateFreeTextDraft('q1', 'show');
        expect(controller.ctaMode, QuestionnaireCtaMode.hidden);
        expect(controller.hasPendingBranchChange, isTrue);
      });

      test('complete after draft committed and no more branch changes', () {
        final q1 = freeTextQuestion('q1', 'Branch text');
        final q2 = boolQuestion('q2', 'Follow-up')
          ..conditional = QuestionConditional<bool>.withCondition(
            CompositeExpression(
              logicType: LogicType.and,
              expressions: [
                TextExpression(comparator: TextComparator.equal, value: 'show')
                  ..target = 'q1',
              ],
            ),
          );
        final controller = QuestionnaireController([q1, q2]);
        controller.updateFreeTextDraft('q1', 'show');
        controller.commitFreeTextDraft(q1);
        controller.submitAnswer(q2.constructAnswer(true));
        expect(controller.ctaMode, QuestionnaireCtaMode.complete);
        expect(controller.hasPendingBranchChange, isFalse);
      });

      test(
        'progressive shows complete when later unrevealed questions exist',
        () {
          final q1 = boolQuestion('q1', 'First');
          final q2 = boolQuestion('q2', 'Second');
          final controller = QuestionnaireController([q1, q2]);
          controller.submitAnswer(q1.constructAnswer(true));
          // q2 unanswered → progressiveVisibleQuestions stops at q1.
          // ctaMode (based on progressive) sees all progressive questions answered.
          expect(controller.ctaMode, QuestionnaireCtaMode.complete);
        },
      );

      test('hidden when shown free-text draft would reveal hidden branch', () {
        final q1 = boolQuestion('q1', 'Show text?');
        final q2 = freeTextQuestion('q2', 'Type "show"')
          ..conditional = shownWhenQ1True<String>();
        final q3 = boolQuestion('q3', 'Revealed by text')
          ..conditional = QuestionConditional<bool>.withCondition(
            CompositeExpression(
              logicType: LogicType.and,
              expressions: [
                TextExpression(comparator: TextComparator.equal, value: 'show')
                  ..target = 'q2',
              ],
            ),
          );
        final controller = QuestionnaireController([q1, q2, q3]);

        controller.submitAnswer(q1.constructAnswer(true));
        expect(controller.progressiveVisibleQuestions.map((q) => q.id), ['q1']);

        controller.updateFreeTextDraft('q2', 'show');

        expect(controller.ctaModeFor([q1, q2]), QuestionnaireCtaMode.hidden);
      });

      test('restored free-text draft equal to committed answer does not force '
          'continue when a later question is unanswered', () {
        // q1 bool, q2 free-text (restored), q3 unanswered (e.g. choice).
        final q1 = boolQuestion('q1', 'Show follow-ups?');
        final q2 = freeTextQuestion('q2', 'Free text')
          ..conditional = shownWhenQ1True<String>();
        final q3 = boolQuestion('q3', 'Choice')
          ..conditional = shownWhenQ1True<bool>();
        final controller = QuestionnaireController([q1, q2, q3]);

        controller.submitAnswer(q1.constructAnswer(true));
        // q2 was previously answered; on re-show its widget restores the
        // value as BOTH a committed answer and a mirror draft.
        controller.submitAnswer(q2.constructAnswer('4534'));
        controller.updateFreeTextDraft('q2', '4534');

        // q3 is unanswered. The mirror draft must not force a Continue CTA.
        expect(
          controller.ctaModeFor([q1, q2, q3]),
          QuestionnaireCtaMode.hidden,
        );
      });

      test('hidden while a shown free-text draft is invalid', () {
        final q1 = FreeTextQuestion.withId(
          textType: FreeTextQuestionType.numeric,
          lengthRange: [1, 100],
        )..id = 'q1';
        final controller = QuestionnaireController([q1]);

        // Invalid numeric draft → CTA suppressed.
        controller.updateFreeTextDraft('q1', 'abc');
        expect(controller.hasInvalidDraftAmong([q1]), isTrue);
        expect(controller.ctaModeFor([q1]), QuestionnaireCtaMode.hidden);

        // Correcting the draft removes the validation error, but the inline
        // Done button still owns free-text commits.
        controller.updateFreeTextDraft('q1', '123');
        expect(controller.hasInvalidDraftAmong([q1]), isFalse);
        expect(controller.ctaModeFor([q1]), QuestionnaireCtaMode.hidden);
      });

      group('restored answer review metadata', () {
        test(
          'later cached answer needs review after earlier answer changes',
          () {
            final q1 = boolQuestion('q1', 'Did you take medication?');
            final q2 = boolQuestion('q2', 'Which medications?')
              ..conditional = shownWhenQ1True<bool>();
            final q3 = freeTextQuestion('q3', 'What did you eat?');
            final controller = QuestionnaireController([q1, q2, q3]);

            controller.submitAnswer(q1.constructAnswer(true));
            controller.submitAnswer(q2.constructAnswer(true));
            controller.submitAnswer(q3.constructAnswer('toast'));
            final visibleBefore = controller.visibleQuestions
                .map((question) => question.id)
                .toSet();

            controller.submitAnswer(q1.constructAnswer(false));
            controller.markRestoredVisibleAnswersNeedingReview(visibleBefore);

            expect(controller.answerFor('q3'), isNotNull);
            expect(controller.needsReview('q3'), isTrue);
            expect(
              controller
                  .buildVisiblePayload()
                  .answerMetadata['q3']
                  ?.needsReview,
              isTrue,
            );
          },
        );

        test('later free text answer needs review after meal changes', () {
          final q1 = ChoiceQuestion.withId()
            ..id = 'q1'
            ..prompt = 'Which meal are you reporting?'
            ..multiple = false
            ..choices = [
              Choice.withText(text: 'Breakfast'),
              Choice.withText(text: 'Lunch'),
              Choice.withText(text: 'Dinner'),
            ];
          final q2 = freeTextQuestion('q2', 'What did you eat?');
          final controller = QuestionnaireController([q1, q2]);

          controller.submitAnswer(q1.constructAnswer([q1.choices.first]));
          controller.submitAnswer(q2.constructAnswer('toast and eggs'));
          controller.submitAnswer(q1.constructAnswer([q1.choices.last]));

          expect(controller.answerFor('q2')?.response, 'toast and eggs');
          expect(controller.needsReview('q2'), isTrue);
        });

        test(
          'unsubmitted free text draft keeps original meal review context',
          () {
            final q1 = ChoiceQuestion.withId()
              ..id = 'q1'
              ..prompt = 'Which meal are you reporting?'
              ..multiple = false
              ..choices = [
                Choice.withText(text: 'Breakfast'),
                Choice.withText(text: 'Lunch'),
                Choice.withText(text: 'Dinner'),
              ];
            final q2 = freeTextQuestion('q2', 'What did you eat?');
            final controller = QuestionnaireController([q1, q2]);

            controller.submitAnswer(q1.constructAnswer([q1.choices.first]));
            controller.updateFreeTextDraft('q2', 'porridge');

            controller.submitAnswer(q1.constructAnswer([q1.choices.last]));
            expect(controller.needsReview('q2'), isTrue);

            controller.submitAnswer(q1.constructAnswer([q1.choices[1]]));
            expect(controller.needsReview('q2'), isTrue);

            controller.submitAnswer(q1.constructAnswer([q1.choices.first]));
            expect(controller.needsReview('q2'), isFalse);

            controller.submitAnswer(q1.constructAnswer([q1.choices.last]));
            expect(controller.needsReview('q2'), isTrue);
          },
        );

        test('dependent visible answer needs review after context changes', () {
          final q0 = boolQuestion('q0', 'Keep follow-up visible?');
          final q1 = boolQuestion('q1', 'Breakfast?');
          final q2 = freeTextQuestion('q2', 'What did you eat?')
            ..conditional = QuestionConditional<String>.withCondition(
              CompositeExpression(
                logicType: LogicType.or,
                expressions: [
                  BooleanExpression()..target = 'q0',
                  BooleanExpression()..target = 'q1',
                ],
              ),
            );
          final controller = QuestionnaireController([q0, q1, q2]);

          controller.submitAnswer(q0.constructAnswer(true));
          controller.submitAnswer(q1.constructAnswer(true));
          controller.submitAnswer(q2.constructAnswer('toast and eggs'));

          controller.submitAnswer(q1.constructAnswer(false));
          controller.submitAnswer(q1.constructAnswer(true));
          controller.submitAnswer(q1.constructAnswer(false));

          final metadata = controller.metadataFor('q2');
          expect(metadata?.restoredFromCache, isTrue);
          expect(metadata?.needsReview, isTrue);
          expect(controller.visibleAnswersNeedReview(), isTrue);
        });

        test('dependent answer is valid when restored under same context', () {
          final q1 = ScaleQuestion.withId()
            ..id = 'q1'
            ..prompt = 'Rate your pain'
            ..minimum = 0
            ..maximum = 10
            ..step = 1;
          final q2 = boolQuestion('q2', 'Have you taken painkillers?')
            ..conditional = QuestionConditional<bool>.withCondition(
              CompositeExpression(
                logicType: LogicType.and,
                expressions: [
                  NumericExpression(
                    comparator: NumericComparator.greaterThan,
                    value: 5,
                  )..target = 'q1',
                ],
              ),
            );
          final controller = QuestionnaireController([q1, q2]);

          controller.submitAnswer(q1.constructAnswer(6));
          controller.submitAnswer(q2.constructAnswer(true));
          controller.submitAnswer(q1.constructAnswer(2));
          final visibleBeforeRestore = controller.visibleQuestions
              .map((question) => question.id)
              .toSet();
          controller.submitAnswer(q1.constructAnswer(6));
          controller.markRestoredVisibleAnswersNeedingReview(
            visibleBeforeRestore,
          );

          expect(controller.answerFor('q2')?.response, isTrue);
          expect(controller.needsReview('q2'), isFalse);
        });

        test('dependent answer needs review when visible context changes', () {
          final q1 = ScaleQuestion.withId()
            ..id = 'q1'
            ..prompt = 'Rate your pain'
            ..minimum = 0
            ..maximum = 10
            ..step = 1;
          final q2 = boolQuestion('q2', 'Have you taken painkillers?')
            ..conditional = QuestionConditional<bool>.withCondition(
              CompositeExpression(
                logicType: LogicType.and,
                expressions: [
                  NumericExpression(
                    comparator: NumericComparator.greaterThan,
                    value: 5,
                  )..target = 'q1',
                ],
              ),
            );
          final controller = QuestionnaireController([q1, q2]);

          controller.submitAnswer(q1.constructAnswer(6));
          controller.submitAnswer(q2.constructAnswer(true));
          controller.submitAnswer(q1.constructAnswer(7));

          expect(controller.answerFor('q2')?.response, isTrue);
          expect(controller.needsReview('q2'), isTrue);
        });

        test(
          'dependent review clears when context returns to original value',
          () {
            final q1 = ScaleQuestion.withId()
              ..id = 'q1'
              ..prompt = 'Rate your pain'
              ..minimum = 0
              ..maximum = 10
              ..step = 1;
            final q2 = boolQuestion('q2', 'Have you taken painkillers?')
              ..conditional = QuestionConditional<bool>.withCondition(
                CompositeExpression(
                  logicType: LogicType.and,
                  expressions: [
                    NumericExpression(
                      comparator: NumericComparator.greaterThan,
                      value: 5,
                    )..target = 'q1',
                  ],
                ),
              );
            final controller = QuestionnaireController([q1, q2]);

            controller.submitAnswer(q1.constructAnswer(6));
            controller.submitAnswer(q2.constructAnswer(true));
            controller.submitAnswer(q1.constructAnswer(7));
            expect(controller.needsReview('q2'), isTrue);

            controller.submitAnswer(q1.constructAnswer(6));

            expect(controller.answerFor('q2')?.response, isTrue);
            expect(controller.needsReview('q2'), isFalse);
          },
        );

        test('markVisibleAnswersReviewed clears all visible flags once', () {
          final q1 = ScaleQuestion.withId()
            ..id = 'q1'
            ..prompt = 'Rate your pain'
            ..minimum = 0
            ..maximum = 10
            ..step = 1;
          final q2 = boolQuestion('q2', 'Have you taken painkillers?');
          final q3 = boolQuestion('q3', 'Any other symptoms?');
          final controller = QuestionnaireController([q1, q2, q3]);
          var notifyCount = 0;
          controller.addListener(() => notifyCount++);

          controller.submitAnswer(q1.constructAnswer(6));
          controller.submitAnswer(q2.constructAnswer(true));
          controller.submitAnswer(q3.constructAnswer(true));
          controller.submitAnswer(q1.constructAnswer(7));
          notifyCount = 0;

          expect(controller.needsReview('q2'), isTrue);
          expect(controller.needsReview('q3'), isTrue);
          controller.markVisibleAnswersReviewed();

          expect(controller.needsReview('q2'), isFalse);
          expect(notifyCount, 1);
        });

        test(
          'markVisibleAnswersReviewed leaves hidden review metadata intact',
          () {
            final q0 = ScaleQuestion.withId()
              ..id = 'q0'
              ..prompt = 'Rate your pain'
              ..minimum = 0
              ..maximum = 10
              ..step = 1;
            final q1 = boolQuestion('q1', 'Show follow-up?');
            final q2 = boolQuestion('q2', 'Follow-up')
              ..conditional = shownWhenQ1True<bool>();
            final q3 = boolQuestion('q3', 'Always visible');
            final controller = QuestionnaireController([q0, q1, q2, q3]);

            controller.submitAnswer(q0.constructAnswer(6));
            controller.submitAnswer(q1.constructAnswer(true));
            controller.submitAnswer(q2.constructAnswer(true));
            controller.submitAnswer(q3.constructAnswer(true));
            controller.submitAnswer(q0.constructAnswer(7));
            controller.submitAnswer(q1.constructAnswer(false));

            expect(controller.needsReview('q2'), isTrue);
            expect(controller.needsReview('q3'), isTrue);
            controller.markVisibleAnswersReviewed();

            expect(controller.needsReview('q2'), isTrue);
            expect(controller.needsReview('q3'), isFalse);
          },
        );

        test(
          'earlier answer edits can require review again after clearing',
          () {
            final q1 = ScaleQuestion.withId()
              ..id = 'q1'
              ..prompt = 'Rate your pain'
              ..minimum = 0
              ..maximum = 10
              ..step = 1;
            final q2 = boolQuestion('q2', 'Have you taken painkillers?');
            final controller = QuestionnaireController([q1, q2]);

            controller.submitAnswer(q1.constructAnswer(6));
            controller.submitAnswer(q2.constructAnswer(true));
            controller.submitAnswer(q1.constructAnswer(7));
            expect(controller.needsReview('q2'), isTrue);

            controller.markVisibleAnswersReviewed();
            expect(controller.needsReview('q2'), isFalse);

            controller.submitAnswer(q1.constructAnswer(8));
            expect(controller.needsReview('q2'), isTrue);
          },
        );

        test('reviewing restored answer clears needsReview', () {
          final q1 = boolQuestion('q1', 'Breakfast?');
          final q2 = freeTextQuestion('q2', 'What did you eat?')
            ..conditional = shownWhenQ1True<String>();
          final controller = QuestionnaireController([q1, q2]);

          controller.submitAnswer(q1.constructAnswer(true));
          controller.submitAnswer(q2.constructAnswer('toast'));
          controller.submitAnswer(q1.constructAnswer(false));
          final visibleBefore = controller.visibleQuestions
              .map((question) => question.id)
              .toSet();
          controller.submitAnswer(q1.constructAnswer(true));
          controller.markRestoredVisibleAnswersNeedingReview(visibleBefore);

          controller.markReviewed('q2');

          expect(controller.needsReview('q2'), isFalse);
          expect(controller.visibleAnswersNeedReview(), isFalse);
        });

        test('hidden answers needing review do not block visible payload', () {
          final q1 = boolQuestion('q1', 'Breakfast?');
          final q2 = freeTextQuestion('q2', 'What did you eat?')
            ..conditional = shownWhenQ1True<String>();
          final controller = QuestionnaireController([q1, q2]);

          controller.submitAnswer(q1.constructAnswer(true));
          controller.submitAnswer(q2.constructAnswer('toast'));
          controller.submitAnswer(q1.constructAnswer(false));

          expect(controller.visibleAnswersNeedReview(), isFalse);
          expect(
            controller.buildVisiblePayload().answers.containsKey('q2'),
            isFalse,
          );
        });
      });
    });
  });
}

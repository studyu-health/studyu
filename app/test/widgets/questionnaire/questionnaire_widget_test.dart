import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/custom_slider.dart';
import 'package:studyu_app/widgets/questionnaire/image_capturing_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/question_container.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/date_question_widget.dart';
import 'package:studyu_app/widgets/selectable_button.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

/// Snapshot of answer responses at callback time.
/// Using a Map copy avoids holding a reference to the mutable QuestionnaireState.
Map<String, Object?>? _snapshot(QuestionnaireState? state) {
  if (state == null) return null;
  return state.answers.map((key, value) => MapEntry(key, value.response));
}

void _expectSelectableButtonSelected(Finder childFinder) {
  final buttonFinder = find.ancestor(
    of: childFinder,
    matching: find.byType(SelectableButton),
  );
  expect(buttonFinder, findsOneWidget);
  expect(testerWidget<SelectableButton>(buttonFinder).selected, isTrue);
}

T testerWidget<T extends Widget>(Finder finder) {
  final element = finder.evaluate().single;
  return element.widget as T;
}

Widget setup(Widget child) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: false),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

BooleanQuestion _boolQuestion(String id, String prompt) {
  return BooleanQuestion.withId()
    ..id = id
    ..prompt = prompt;
}

ChoiceQuestion _singleChoiceQuestion(String id, String prompt) {
  return ChoiceQuestion.withId()
    ..choices = [Choice.withId()..text = 'A', Choice.withId()..text = 'B']
    ..multiple = false
    ..id = id
    ..prompt = prompt;
}

ChoiceQuestion _multiChoiceQuestion(String id, String prompt) {
  return ChoiceQuestion.withId()
    ..choices = [Choice.withId()..text = 'A', Choice.withId()..text = 'B']
    ..multiple = true
    ..id = id
    ..prompt = prompt;
}

class RequiresBoolAnswerExpression({
  required final String target,
  required final bool expected,
}) extends Expression {
  this : super('test-requires-bool-answer');

  final List<bool?> observedValues = [];

  @override
  bool? evaluate(QuestionnaireState state) {
    final hasAnswer = state.hasAnswer<bool>(target);
    final value = hasAnswer ? state.getAnswer<bool>(target) : null;
    observedValues.add(value);
    return value == expected;
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'type': type};
}

class RequiresDateAnswerExpression({required String target})
    extends ValueExpression<DateTime> {
  this : super('test-requires-date-answer') {
    this.target = target;
  }

  @override
  bool checkValue(DateTime value) => true;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'type': type};
}

void main() {
  testWidgets(
    'hidden conditional answers are excluded while hidden and restored when shown again',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show follow-up?');
      final q2 = _singleChoiceQuestion('q2', 'Pick one')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );
      final q2ChoiceAId = q2.choices.first.id;

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], isTrue);
      expect(firstCompletion['q2'], [q2ChoiceAId]);

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();

      _expectSelectableButtonSelected(find.text('no'));
      expect(find.text('A'), findsNothing);
      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final hiddenCompletion = snapshots.where((s) => s != null).last!;
      expect(hiddenCompletion['q1'], isFalse);
      expect(hiddenCompletion.containsKey('q2'), isFalse);

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final restoredCompletion = snapshots.where((s) => s != null).last!;
      expect(restoredCompletion['q2'], [q2ChoiceAId]);
      expect(restoredCompletion['q1'], isTrue);
      expect(find.text('A'), findsOneWidget);
      _expectSelectableButtonSelected(find.text('yes'));
      _expectSelectableButtonSelected(find.text('A'));
    },
  );

  testWidgets(
    'hidden image answer is not restored as complete when shown again',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show image upload?');
      final q2 = ImageCapturingQuestion.withId()
        ..id = 'q2'
        ..prompt = 'Capture image'
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );
      final imageFile = FutureBlobFile('/tmp/photo.jpg', 'future-photo');

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      expect(find.byType(ImageCapturingQuestionWidget), findsOneWidget);

      final widget = tester.widget<ImageCapturingQuestionWidget>(
        find.byType(ImageCapturingQuestionWidget),
      );
      widget.onDone!(q2.constructAnswer(imageFile));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], isTrue);
      expect(firstCompletion['q2'], same(imageFile));

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();

      expect(find.byType(ImageCapturingQuestionWidget), findsNothing);
      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final hiddenCompletion = snapshots.where((s) => s != null).last!;
      expect(hiddenCompletion['q1'], isFalse);
      expect(hiddenCompletion.containsKey('q2'), isFalse);

      final nonNullCompletionCountBeforeReshow = snapshots
          .where((s) => s != null)
          .length;

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(ImageCapturingQuestionWidget), findsOneWidget);
      expect(snapshots.last, isNull);
      expect(
        snapshots.where((s) => s != null).length,
        nonNullCompletionCountBeforeReshow,
      );
    },
  );

  testWidgets(
    'conditional reset runs before shouldContinue stops questionnaire',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show follow-up before stop?');
      final q2 = _singleChoiceQuestion('q2', 'Pick before stop')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );
      final q2ChoiceAId = q2.choices.first.id;

      final List<Map<String, Object?>?> snapshots = [];
      final List<Map<String, Object?>?> predicateSnapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            shouldContinue: (state) {
              predicateSnapshots.add(_snapshot(state));
              return state.answers['q1']?.response != false;
            },
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], isTrue);
      expect(firstCompletion['q2'], [q2ChoiceAId]);

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsNothing);
      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final stoppedCompletion = snapshots.where((s) => s != null).last!;
      expect(stoppedCompletion['q1'], isFalse);
      expect(stoppedCompletion.containsKey('q2'), isFalse);

      final stoppedPredicate = predicateSnapshots.last!;
      expect(stoppedPredicate['q1'], isFalse);
      expect(stoppedPredicate.containsKey('q2'), isFalse);
    },
  );

  testWidgets(
    'restored empty multi-choice answer remains confirmed when shown again',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show empty multi-choice?');
      final q2 = _multiChoiceQuestion('q2', 'Pick zero or more')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm selection'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], isTrue);
      expect(firstCompletion['q2'], isEmpty);

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();
      expect(find.text('Pick zero or more'), findsNothing);

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final restoredCompletion = snapshots.where((s) => s != null).last!;
      expect(restoredCompletion['q1'], isTrue);
      expect(restoredCompletion['q2'], isEmpty);
      expect(find.text('Confirm selection'), findsNothing);
    },
  );

  testWidgets(
    'multiple restored conditional answers are included when shown again',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show follow-ups?');
      final q2 = _singleChoiceQuestion('q2', 'Pick q2')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );
      final q3 = _singleChoiceQuestion('q3', 'Pick q3')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );
      final q2ChoiceAId = q2.choices.first.id;
      final q3ChoiceBId = q3.choices.last.id;

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2, q3],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('B').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], isTrue);
      expect(firstCompletion['q2'], [q2ChoiceAId]);
      expect(firstCompletion['q3'], [q3ChoiceBId]);

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final hiddenCompletion = snapshots.where((s) => s != null).last!;
      expect(hiddenCompletion['q1'], isFalse);
      expect(hiddenCompletion.containsKey('q2'), isFalse);
      expect(hiddenCompletion.containsKey('q3'), isFalse);

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final restoredCompletion = snapshots.where((s) => s != null).last!;
      expect(restoredCompletion['q1'], isTrue);
      expect(restoredCompletion['q2'], [q2ChoiceAId]);
      expect(restoredCompletion['q3'], [q3ChoiceBId]);
      _expectSelectableButtonSelected(find.text('yes'));
      _expectSelectableButtonSelected(find.text('A').first);
      _expectSelectableButtonSelected(find.text('B').last);
    },
  );

  testWidgets(
    'hidden default answer drives later condition but stays out of payload',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show skipped question?');
      final q2 = _boolQuestion('q2', 'Skipped default source')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
          defaultValue: true,
        );
      final q3 = _singleChoiceQuestion('q3', 'Shown by q2 default')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q2'],
          ),
        );
      final q3ChoiceAId = q3.choices.first.id;

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2, q3],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final completion = snapshots.where((s) => s != null).last!;
      expect(completion['q1'], isFalse);
      expect(completion.containsKey('q2'), isFalse);
      expect(completion['q3'], [q3ChoiceAId]);
    },
  );

  testWidgets(
    'hidden default false submits manually when no later questions stay visible',
    (tester) async {
      final q0 = _boolQuestion('q0', 'Show skipped question?');
      final q1 = _boolQuestion('q1', 'Last visible question');
      final q2 = _boolQuestion('q2', 'Skipped default source')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q0'],
          ),
          defaultValue: false,
        );
      final q3 = _singleChoiceQuestion('q3', 'Hidden by q2 default')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q2'],
          ),
        );

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q0, q1, q2, q3],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();
      expect(snapshots.where((s) => s != null), isEmpty);

      await tester.tap(find.text('no').last);
      await tester.pumpAndSettle();

      expect(find.text('Skipped default source'), findsNothing);
      expect(find.text('Hidden by q2 default'), findsNothing);
      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final completion = snapshots.where((s) => s != null).lastOrNull;
      expect(completion, isNotNull);
      expect(completion!['q0'], isFalse);
      expect(completion['q1'], isFalse);
      expect(completion.containsKey('q2'), isFalse);
      expect(completion.containsKey('q3'), isFalse);
    },
  );

  testWidgets(
    'normal progression applies hidden default before deciding completion',
    (tester) async {
      final q0 = _boolQuestion('q0', 'Hide default branch?');
      final q1 = _singleChoiceQuestion('q1', 'Visible bridge question')
        ..choices[0].text = 'Bridge A'
        ..choices[1].text = 'Bridge B';
      final q2 = _boolQuestion('q2', 'Hidden default source')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q0'],
          ),
          defaultValue: true,
        );
      final q3Expression = RequiresBoolAnswerExpression(
        target: 'q2',
        expected: true,
      );
      final q3 = _singleChoiceQuestion('q3', 'Shown by hidden default')
        ..choices[0].text = 'Follow A'
        ..choices[1].text = 'Follow B'
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [q3Expression],
          ),
        );
      final q1ChoiceAId = q1.choices.first.id;
      final q3ChoiceBId = q3.choices.last.id;

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q0, q1, q2, q3],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();
      expect(snapshots.where((s) => s != null), isEmpty);
      expect(find.text('Bridge A'), findsOneWidget);

      await tester.tap(find.text('Bridge A'));
      await tester.pumpAndSettle();

      expect(snapshots.where((s) => s != null), isEmpty);
      expect(find.text('Hidden default source'), findsNothing);
      expect(find.text('Follow B'), findsOneWidget);
      expect(q3Expression.observedValues.contains(true), isTrue);

      await tester.tap(find.text('Follow B'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final completion = snapshots.where((s) => s != null).last!;
      expect(completion['q0'], isFalse);
      expect(completion['q1'], [q1ChoiceAId]);
      expect(completion.containsKey('q2'), isFalse);
      expect(completion['q3'], [q3ChoiceBId]);
    },
  );

  testWidgets(
    'shouldContinue stops before newly visible conditional follow-up is shown',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Reveal follow-up but stop?');
      final q2 = _singleChoiceQuestion('q2', 'Should stay hidden')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            shouldContinue: (_) => false,
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();

      expect(find.text('Should stay hidden'), findsNothing);
      expect(find.text('A'), findsNothing);
      expect(snapshots.last, isNull);
    },
  );

  testWidgets(
    'hidden answered question keeps user answer when re-shown, not default',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show follow-up?');
      final q2 = _boolQuestion('q2', 'Default false question')
        ..conditional = QuestionConditional<bool>.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
          defaultValue: false,
        );

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Show q2 by answering q1 = yes.
      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // q2 appears: two QuestionContainers, four button texts (yes/no × 2).
      expect(find.byType(QuestionContainer), findsNWidgets(2));
      expect(find.text('yes'), findsNWidgets(2));
      expect(find.text('no'), findsNWidgets(2));

      // Answer q2 = yes (non-default, default is false).
      await tester.tap(find.text('yes').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], isTrue);
      expect(firstCompletion['q2'], isTrue);

      // Hide q2 by answering q1 = no.
      await tester.tap(find.text('no').first);
      await tester.pumpAndSettle();

      // q2 hidden: one QuestionContainer, one yes/no button pair.
      expect(find.byType(QuestionContainer), findsOneWidget);
      expect(find.text('yes'), findsOneWidget);
      expect(find.text('no'), findsOneWidget);
      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final hiddenCompletion = snapshots.where((s) => s != null).last!;
      expect(hiddenCompletion['q1'], isFalse);
      expect(hiddenCompletion.containsKey('q2'), isFalse);

      // Re-show q2 by answering q1 = yes again.
      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final restoredCompletion = snapshots.where((s) => s != null).last!;
      expect(restoredCompletion['q1'], isTrue);
      // User's non-default answer (true) must be preserved, not overwritten
      // by the conditional default (false).
      expect(restoredCompletion['q2'], isTrue);
      // q2 re-shown: two QuestionContainers, two yes/no button pairs.
      expect(find.byType(QuestionContainer), findsNWidgets(2));
      expect(find.text('yes'), findsNWidgets(2));
      expect(find.text('no'), findsNWidgets(2));
      _expectSelectableButtonSelected(find.text('yes').first);
      _expectSelectableButtonSelected(find.text('yes').last);
    },
  );

  // ── Free-text + CTA tests ──

  testWidgets('free-text draft restores after hide and reshow before CTA', (
    tester,
  ) async {
    final q1 = _boolQuestion('q1', 'Show free text?');
    final q2 =
        FreeTextQuestion.withId(
            textType: FreeTextQuestionType.any,
            lengthRange: [1, 100],
          )
          ..id = 'q2'
          ..prompt = 'Draft text'
          ..conditional = QuestionConditional<String>.withCondition(
            CompositeExpression(
              logicType: LogicType.and,
              expressions: [BooleanExpression()..target = 'q1'],
            ),
          );

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(setup(QuestionnaireWidget([q1, q2])));
    await tester.pumpAndSettle();

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'cached draft');
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('no'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('cached draft'), findsOneWidget);
    expect(find.text('Submit'), findsNothing);
  });

  testWidgets('free-text committed answer restores after hide and reshow', (
    tester,
  ) async {
    final q1 = _boolQuestion('q1', 'Show free text?');
    final q2 =
        FreeTextQuestion.withId(
            textType: FreeTextQuestionType.any,
            lengthRange: [1, 100],
          )
          ..id = 'q2'
          ..prompt = 'Committed text'
          ..conditional = QuestionConditional<String>.withCondition(
            CompositeExpression(
              logicType: LogicType.and,
              expressions: [BooleanExpression()..target = 'q1'],
            ),
          );

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(setup(QuestionnaireWidget([q1, q2])));
    await tester.pumpAndSettle();

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'committed text');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('no'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
    final controller = tester
        .widget<TextFormField>(find.byType(TextFormField))
        .controller;
    expect(controller?.text, equals('committed text'));
    expect(find.text('Submit'), findsNothing);
  });

  testWidgets('inline Done commits free-text draft and reveals next question', (
    tester,
  ) async {
    final q1 =
        FreeTextQuestion.withId(
            textType: FreeTextQuestionType.custom,
            lengthRange: [1, 100],
            customTypeExpression: r'\d+',
          )
          ..id = 'q1'
          ..prompt = 'Digits';
    final q2 = _singleChoiceQuestion('q2', 'Second question');

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final key = GlobalKey<QuestionnaireWidgetState>();

    await tester.pumpWidget(setup(QuestionnaireWidget([q1, q2], key: key)));
    await tester.pumpAndSettle();

    // Only q1 shown initially
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Second question'), findsNothing);
    // No Submit button since free-text has no per-field Submit
    expect(find.text('Submit'), findsNothing);

    // Type valid text. Free-text uses its inline Done button to commit.
    await tester.enterText(find.byType(TextFormField), '42');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);

    // Tap Done → draft committed, q2 revealed
    await tester.tap(find.text('Done'));
    await tester.pump();
    expect(key.currentState!.shownQuestions.length, 2);
    await tester.pumpAndSettle();

    // q2 is now in the widget tree (check by choice button text, not HtmlText prompt)
    expect(find.byType(QuestionContainer), findsNWidgets(2));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Complete task'), findsNothing);
    expect(find.text('Continue'), findsNothing);
  });

  testWidgets(
    'free-text draft uses inline Done when commit should reveal next question',
    (tester) async {
      final q1 =
          FreeTextQuestion.withId(
              textType: FreeTextQuestionType.any,
              lengthRange: [1, 100],
            )
            ..id = 'q1'
            ..prompt = 'First text';
      final q2 = _boolQuestion('q2', 'Second question');

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final snapshots = <Map<String, Object?>?>[];

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget([
            q1,
            q2,
          ], onComplete: (state) => snapshots.add(_snapshot(state))),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Second question'), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'hello');
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Submit'), findsNothing);
      expect(find.text('Continue'), findsNothing);
      expect(find.text('Complete task'), findsNothing);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(snapshots.where((snapshot) => snapshot == null).length, 0);
      expect(find.text('yes'), findsOneWidget);
      expect(find.text('no'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
      expect(find.text('Complete task'), findsNothing);
    },
  );

  testWidgets(
    'inline Done replaces Continue for pending branch change before Complete',
    (tester) async {
      final q1 =
          FreeTextQuestion.withId(
              textType: FreeTextQuestionType.any,
              lengthRange: [1, 100],
            )
            ..id = 'q1'
            ..prompt = 'Branch text';
      final q2 = _boolQuestion('q2', 'Follow-up')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [
              TextExpression(comparator: TextComparator.equal, value: 'show')
                ..target = 'q1',
            ],
          ),
        );

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Type 'show' → pending branch change, then inline Done commits it.
      await tester.enterText(find.byType(TextFormField), 'show');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);

      // Tap Done → q2 revealed, no completion yet
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(snapshots.where((s) => s == null).length, 1);
      // q2 visible: boolean question shows yes/no buttons (q1 is free-text)
      expect(find.text('yes'), findsOneWidget);
      expect(find.text('no'), findsOneWidget);
      // q2 visible but unanswered, q1 already committed → CTA hidden
      expect(find.text('Continue'), findsNothing);
      expect(find.text('Complete task'), findsNothing);

      // Answer q2 → button question commits; Complete submits manually.
      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final completion = snapshots.where((s) => s != null).last!;
      expect(completion['q1'], 'show');
      expect(completion['q2'], isTrue);
    },
  );

  testWidgets(
    'validate sync payload uses latest visible free text edits via CTA',
    (tester) async {
      final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();
      final q1 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [1, 100],
        customTypeExpression: r'\d+',
      )..id = 'q1';
      final q2 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.any,
        lengthRange: [1, 100],
      )..id = 'q2';

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(QuestionnaireWidget([q1, q2], key: questionnaireKey)),
      );
      await tester.pumpAndSettle();

      // Type in q1, tap Done to reveal q2
      await tester.enterText(find.byType(TextFormField).first, '2');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Type in q2, tap Done, then Complete.
      await tester.enterText(find.byType(TextFormField).last, 'later');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      // Now edit q1. Draft updated. validateSyncAndBuildPayload commits it.
      await tester.enterText(find.byType(TextFormField).first, '23');
      await tester.pump();

      final blockedPayload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      await tester.pumpAndSettle();

      expect(blockedPayload, isNull);
      expect(find.text('Review your answers'), findsOneWidget);
      await tester.tap(find.text("I reviewed my answers"));
      await tester.pumpAndSettle();

      final payload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      expect(payload, isNotNull);
      expect(payload!.answers.keys, unorderedEquals(['q1', 'q2']));
      expect(payload.answers['q1']!.response, '23');
      expect(payload.answers['q2']!.response, 'later');
      await tester.pump(const Duration(milliseconds: 500));
    },
  );

  testWidgets(
    'validate sync payload returns null and shows error for invalid free text',
    (tester) async {
      final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();
      final q1 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [1, 100],
        customTypeExpression: r'\d+',
      )..id = 'q1';
      final q2 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.any,
        lengthRange: [1, 100],
      )..id = 'q2';

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            key: questionnaireKey,
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Submit q1 and q2 via inline Done buttons.
      await tester.enterText(find.byType(TextFormField).first, '2');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).last, 'later');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final validCompletion = snapshots.where((s) => s != null).last!;
      expect(validCompletion['q1'], '2');
      expect(validCompletion['q2'], 'later');
      final snapshotCountBeforeInvalidComplete = snapshots.length;

      // Make q1 invalid
      await tester.enterText(find.byType(TextFormField).first, 'bad');
      await tester.pump();

      final payload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      await tester.pumpAndSettle();

      expect(payload, isNull);
      expect(snapshots.length, snapshotCountBeforeInvalidComplete);
      expect(
        find.text('Please enter a value in the required format'),
        findsOneWidget,
      );

      // Correct q1. Its changed context requires the later answer to be reviewed.
      await tester.enterText(find.byType(TextFormField).first, '3');
      await tester.pump();
      final blockedCorrectedPayload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      await tester.pumpAndSettle();
      expect(blockedCorrectedPayload, isNull);
      await tester.tap(find.text("I reviewed my answers"));
      await tester.pumpAndSettle();

      final correctedPayload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      expect(correctedPayload, isNotNull);
      expect(correctedPayload!.answers['q1']!.response, '3');
      expect(correctedPayload.answers['q2']!.response, 'later');
      await tester.pump(const Duration(milliseconds: 500));
    },
  );

  testWidgets(
    'validate sync payload is atomic when one visible free text is invalid',
    (tester) async {
      final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();
      final q1 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [1, 100],
        customTypeExpression: r'\d+',
      )..id = 'q1';
      final q2 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.any,
        lengthRange: [1, 100],
      )..id = 'q2';

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            key: questionnaireKey,
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Submit q1 via inline Done to reveal q2
      await tester.enterText(find.byType(TextFormField).first, '1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).last, 'old q2');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final validCompletion = snapshots.where((s) => s != null).last!;
      expect(validCompletion['q1'], '1');
      expect(validCompletion['q2'], 'old q2');
      final snapshotCountBeforeInvalidComplete = snapshots.length;

      // Make q1 invalid, edit q2 to new value
      await tester.enterText(find.byType(TextFormField).first, 'bad');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).last, 'new q2');
      await tester.pump();

      final payload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      await tester.pumpAndSettle();

      expect(payload, isNull);
      expect(snapshots.length, snapshotCountBeforeInvalidComplete);

      // Correct q1. Batch commit remains atomic and flags the later answer.
      await tester.enterText(find.byType(TextFormField).first, '2');
      await tester.pump();
      final blockedCorrectedPayload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      await tester.pumpAndSettle();
      expect(blockedCorrectedPayload, isNull);
      await tester.tap(find.text("I reviewed my answers"));
      await tester.pumpAndSettle();

      final correctedPayload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      expect(correctedPayload, isNotNull);
      expect(correctedPayload!.answers['q1']!.response, '2');
      expect(correctedPayload.answers['q2']!.response, 'new q2');
      await tester.pump(const Duration(milliseconds: 500));
    },
  );

  testWidgets('inline Done commits conditional free-text branch changes', (
    tester,
  ) async {
    final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();
    final q1 = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.any,
      lengthRange: [1, 100],
    )..id = 'q1';
    final q2 =
        FreeTextQuestion.withId(
            textType: FreeTextQuestionType.any,
            lengthRange: [1, 100],
          )
          ..id = 'q2'
          ..conditional = QuestionConditional.withCondition(
            CompositeExpression(
              logicType: LogicType.and,
              expressions: [
                TextExpression(comparator: TextComparator.equal, value: 'show')
                  ..target = 'q1',
              ],
            ),
          );

    final List<Map<String, Object?>?> snapshots = [];

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(
        QuestionnaireWidget(
          [q1, q2],
          key: questionnaireKey,
          onComplete: (state) {
            snapshots.add(_snapshot(state));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Type 'show' → inline Done commits the pending branch change.
    await tester.enterText(find.byType(TextFormField), 'show');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);

    // Tap Done → q2 revealed, null callback emitted
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(snapshots.where((s) => s == null).length, 1);
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Fill q2, inline Done commits it, then Complete submits.
    await tester.enterText(find.byType(TextFormField).last, 'dependent');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Complete task'), findsNothing);

    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    expect(find.text('Complete task'), findsOneWidget);

    await tester.tap(find.text('Complete task'));
    await tester.pumpAndSettle();

    final validCompletion = snapshots.where((s) => s != null).last!;
    expect(validCompletion['q1'], 'show');
    expect(validCompletion['q2'], 'dependent');

    // Editing an earlier answer shows Done beside that field, not Continue.
    await tester.enterText(find.byType(TextFormField).first, 'hide');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);

    // Inline Done commits the edit and rebuilds visibility.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // validateSyncAndBuildPayload commits all drafts (including conditional edits)
    final payload = questionnaireKey.currentState!
        .validateSyncAndBuildPayload();

    expect(payload, isNotNull);
    expect(payload!.answers['q1']!.response, 'hide');
    // q2 is now hidden (condition evaluates 'hide' != 'show')
    expect(payload.answers.containsKey('q2'), isFalse);

    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('free-text edits do not auto-sync; inline Done commits edits', (
    tester,
  ) async {
    final q1 = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.custom,
      lengthRange: [1, 100],
      customTypeExpression: r'\d+',
    )..id = 'q1';
    final q2 = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.any,
      lengthRange: [1, 100],
    )..id = 'q2';

    final List<Map<String, Object?>?> snapshots = [];

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(
        QuestionnaireWidget(
          [q1, q2],
          onComplete: (state) {
            snapshots.add(_snapshot(state));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Type in q1, inline Done reveals q2.
    await tester.enterText(find.byType(TextFormField).first, '2');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Type in q2, inline Done commits it, then Complete finishes.
    await tester.enterText(find.byType(TextFormField).last, 'later');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete task'));
    await tester.pumpAndSettle();

    final firstCompletion = snapshots.where((s) => s != null).last!;
    expect(firstCompletion['q1'], '2');
    expect(firstCompletion['q2'], 'later');
    expect(find.text('Done'), findsNothing);

    // Edit q1 valid-to-valid: no auto-debounce sync, no invalidation
    await tester.enterText(find.byType(TextFormField).first, '23');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    // No null snapshot from free-text reveal; no new callbacks from typing.
    expect(snapshots.where((s) => s == null).length, 0);
    // Still only one completion (the first full completion)
    expect(snapshots.where((s) => s != null).length, 1);

    // Both questions still visible
    expect(find.byType(TextFormField), findsNWidgets(2));

    // No Submit or global Continue button anywhere. The edited q1 owns Done.
    expect(find.text('Submit'), findsNothing);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Complete task'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Review your answers'), findsOneWidget);
    await tester.tap(find.text("I reviewed my answers"));
    await tester.pumpAndSettle();

    final syncedPayload = _snapshot(
      tester
          .state<QuestionnaireWidgetState>(find.byType(QuestionnaireWidget))
          .validateSyncAndBuildPayload(),
    );
    expect(syncedPayload!['q1'], '23');
    expect(syncedPayload['q2'], 'later');

    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('free-text edits do not churn branches until CTA pressed', (
    tester,
  ) async {
    final q1 = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.any,
      lengthRange: [1, 100],
    )..id = 'q1';
    final q2 =
        FreeTextQuestion.withId(
            textType: FreeTextQuestionType.any,
            lengthRange: [1, 100],
          )
          ..id = 'q2'
          ..conditional = QuestionConditional.withCondition(
            CompositeExpression(
              logicType: LogicType.and,
              expressions: [
                TextExpression(comparator: TextComparator.equal, value: 'show')
                  ..target = 'q1',
              ],
            ),
          );

    final List<Map<String, Object?>?> snapshots = [];

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(
        QuestionnaireWidget(
          [q1, q2],
          onComplete: (state) {
            snapshots.add(_snapshot(state));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Submit 'show' via inline Done, reveal q2.
    await tester.enterText(find.byType(TextFormField), 'show');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Submit q2.
    await tester.enterText(find.byType(TextFormField).last, 'dependent');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete task'));
    await tester.pumpAndSettle();

    final firstCompletion = snapshots.where((s) => s != null).last!;
    expect(firstCompletion['q1'], 'show');
    expect(firstCompletion['q2'], 'dependent');

    // Edit q1 to 'hide'. No auto-branch-change. Q2 stays visible.
    await tester.enterText(find.byType(TextFormField).first, 'hide');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    // Q2 still visible (branch not churned)
    expect(find.text('dependent'), findsOneWidget);
    // q1 owns an inline Done button while its draft is pending.
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Complete task'), findsNothing);

    // No auto-complete
    final completions = snapshots.where((s) => s != null).toList();
    expect(completions.length, 1);

    // Tap inline Done → branch change applies.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Q2 hidden now
    expect(find.text('dependent'), findsNothing);
    // Q1 still visible
    expect(find.byType(TextFormField), findsOneWidget);

    // CTA now Complete → press to submit
    expect(find.text('Complete task'), findsOneWidget);
    await tester.tap(find.text('Complete task'));
    await tester.pumpAndSettle();

    // Final completion fires (q1='hide', q2 hidden)
    final finalCompletion = snapshots.where((s) => s != null).last!;
    expect(finalCompletion['q1'], 'hide');
    expect(finalCompletion.containsKey('q2'), isFalse);
  });

  testWidgets('free-text answer reveals conditional follow-up question', (
    tester,
  ) async {
    final key = GlobalKey<QuestionnaireWidgetState>();
    final q1 =
        FreeTextQuestion.withId(
            textType: FreeTextQuestionType.any,
            lengthRange: [0, 100],
          )
          ..id = 'q1'
          ..prompt = 'Question 1';
    final q2 = _boolQuestion('q2', 'Question 2')
      ..conditional = QuestionConditional.withCondition(
        CompositeExpression(
          logicType: LogicType.and,
          expressions: [
            TextExpression(comparator: TextComparator.lengthEqual, value: '4')
              ..target = 'q1',
          ],
        ),
      );

    final List<Map<String, Object?>?> snapshots = [];

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(
        QuestionnaireWidget(
          key: key,
          [q1, q2],
          onComplete: (state) {
            snapshots.add(_snapshot(state));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('yes'), findsNothing);

    await tester.enterText(find.byType(TextFormField), 'abcd');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(key.currentState!.shownQuestions.length, 2);
    expect(find.text('yes'), findsOneWidget);
    expect(find.text('no'), findsOneWidget);
    expect(snapshots.where((snapshot) => snapshot == null).length, 1);
    expect(snapshots.where((snapshot) => snapshot != null), isEmpty);
  });

  testWidgets(
    'answered choice then free-text length condition reveals follow-up',
    (tester) async {
      final q0 = _boolQuestion('q0', 'Previous question');
      final q1 =
          FreeTextQuestion.withId(
              textType: FreeTextQuestionType.any,
              lengthRange: [0, 500],
            )
            ..id = 'q1'
            ..prompt = 'Question 1';
      final q2 = _boolQuestion('q2', 'Question 2')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [
              TextExpression(comparator: TextComparator.lengthEqual, value: '8')
                ..target = 'q1',
            ],
          ),
        );

      await tester.pumpWidget(setup(QuestionnaireWidget([q0, q1, q2])));
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Complete'), findsNothing);

      await tester.enterText(find.byType(TextFormField), '12345678');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('yes'), findsNWidgets(2));
      expect(find.text('no'), findsNWidgets(2));
    },
  );

  testWidgets(
    'branch-changing free text requires newly shown unanswered question',
    (tester) async {
      final q1 =
          FreeTextQuestion.withId(
              textType: FreeTextQuestionType.numeric,
              lengthRange: [1, 500],
            )
            ..id = 'q1'
            ..prompt = 'Q1';
      final q2 = _singleChoiceQuestion('q2', 'Q2')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [
              TextExpression(comparator: TextComparator.contains, value: '5')
                ..target = 'q1',
            ],
          ),
        );
      final q3 =
          FreeTextQuestion.withId(
              textType: FreeTextQuestionType.any,
              lengthRange: [1, 500],
            )
            ..id = 'q3'
            ..prompt = 'Q3';

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();
      await tester.pumpWidget(
        setup(QuestionnaireWidget([q1, q2, q3], key: questionnaireKey)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '1');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('A'), findsNothing);

      await tester.enterText(find.byType(TextFormField).first, '5');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done').first);
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '4');
      await tester.pumpAndSettle();

      final blockedPayload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      await tester.pumpAndSettle();

      expect(blockedPayload, isNull);
      expect(find.text('A'), findsNothing);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Complete task'), findsNothing);

      await tester.enterText(find.byType(TextFormField).last, 'answered');
      await tester.tap(find.text('Done').last);
      await tester.pumpAndSettle();

      expect(find.text('Complete task'), findsOneWidget);
      final payload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      expect(payload, isNotNull);
      expect(payload!.answers.keys, unorderedEquals(['q1', 'q3']));
      expect(payload.answers['q1']!.response, '4');
      expect(payload.answers['q3']!.response, 'answered');
      await tester.pump(const Duration(milliseconds: 600));
    },
  );

  testWidgets(
    'clearing committed free text blocks completion with min-length error',
    (tester) async {
      final question =
          FreeTextQuestion.withId(
              textType: FreeTextQuestionType.any,
              lengthRange: [2, 20],
            )
            ..id = 'q1'
            ..prompt = 'Q1';
      final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();

      await tester.pumpWidget(
        setup(QuestionnaireWidget([question], key: questionnaireKey)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'valid');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Complete task'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '');
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Complete task'), findsNothing);
      expect(find.text('Please enter at least 2 characters'), findsOneWidget);
      expect(
        questionnaireKey.currentState!.validateSyncAndBuildPayload(),
        isNull,
      );
      await tester.pump(const Duration(milliseconds: 600));
    },
  );

  testWidgets(
    'invalidation removes stale answer; re-shown question starts fresh',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show free-text?');
      final q2 =
          FreeTextQuestion.withId(
              textType: FreeTextQuestionType.custom,
              lengthRange: [1, 100],
              customTypeExpression: r'\d+',
            )
            ..id = 'q2'
            ..prompt = 'Digits only'
            ..conditional = QuestionConditional.withCondition(
              CompositeExpression(
                logicType: LogicType.and,
                expressions: [BooleanExpression()..target = 'q1'],
              ),
            );

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Answer Q1=yes → Q2 appears
      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Type '123' in q2, tap inline Done, then Complete.
      await tester.enterText(find.byType(TextFormField), '123');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], isTrue);
      expect(firstCompletion['q2'], '123');

      // Type invalid text 'abc' — no auto-invalidation, just shows error
      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // No null callback from mere typing (no auto-invalidation)
      // Hide Q2 by answering Q1=no
      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();

      // Q2 hidden
      expect(find.byType(QuestionContainer), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();

      final hiddenCompletion = snapshots.where((s) => s != null).last!;
      expect(hiddenCompletion['q1'], isFalse);
      expect(hiddenCompletion.containsKey('q2'), isFalse);

      // Re-show Q2
      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Q2 re-shown. Draft 'abc' is restored before the next CTA commit,
      // because free-text edits are draft-based in the global-CTA model.
      expect(find.byType(QuestionContainer), findsNWidgets(2));
      expect(find.byType(TextFormField), findsOneWidget);
      final controller = tester
          .widget<TextFormField>(find.byType(TextFormField).last)
          .controller;
      expect(controller?.text, equals('abc'));
    },
  );

  testWidgets('date question default today submits manually', (tester) async {
    final dateQ = DateQuestion.withId()
      ..id = 'dq'
      ..prompt = 'Pick date'
      ..defaultOption = DefaultDateOption.today;

    final List<Map<String, Object?>?> snapshots = [];

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(
        QuestionnaireWidget(
          [dateQ],
          onComplete: (state) {
            snapshots.add(_snapshot(state));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete task'));
    await tester.pumpAndSettle();

    final completion = snapshots.where((s) => s != null).last;
    expect(completion!['dq'], isA<DateTime>());
  });

  testWidgets('formats date question time range using the system time format', (
    tester,
  ) async {
    final dateQ = DateQuestion.withId()
      ..id = 'dq'
      ..prompt = 'Pick time'
      ..minTime = '14:30'
      ..maxTime = '16:45';

    await tester.pumpWidget(
      setup(
        MediaQuery(
          data: const MediaQueryData(),
          child: DateQuestionWidget(question: dateQ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Select a time between 2:30 PM and 4:45 PM'),
      findsOneWidget,
    );
  });

  testWidgets('clearing a date answer invalidates questionnaire completion', (
    tester,
  ) async {
    final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();
    final dateQ = DateQuestion.withId()
      ..id = 'dq'
      ..prompt = 'Pick date';

    final List<Map<String, Object?>?> snapshots = [];

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(
        QuestionnaireWidget(
          [dateQ],
          key: questionnaireKey,
          onComplete: (state) {
            snapshots.add(_snapshot(state));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dateWidget = tester.widget<DateQuestionWidget>(
      find.byType(DateQuestionWidget),
    );
    dateWidget.onDone!(dateQ.constructAnswer(DateTime(2025, 6)));
    await tester.pumpAndSettle();

    final beforeClear = snapshots.where((s) => s != null).length;

    final updatedDateWidget = tester.widget<DateQuestionWidget>(
      find.byType(DateQuestionWidget),
    );
    updatedDateWidget.onCleared!();
    await tester.pumpAndSettle();

    expect(snapshots.last, isNull);
    expect(snapshots.where((s) => s != null).length, beforeClear);
    expect(
      questionnaireKey.currentState!.validateSyncAndBuildPayload(),
      isNull,
    );
  });

  testWidgets('clearing a date answer hides conditional follow-up', (
    tester,
  ) async {
    final dateQ = DateQuestion.withId()
      ..id = 'dq'
      ..prompt = 'Pick date';
    final followUp = _singleChoiceQuestion('q2', 'Follow-up after date')
      ..choices[0].text = 'Date follow-up choice'
      ..conditional = QuestionConditional.withCondition(
        CompositeExpression(
          logicType: LogicType.and,
          expressions: [RequiresDateAnswerExpression(target: 'dq')],
        ),
      );

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(setup(QuestionnaireWidget([dateQ, followUp])));
    await tester.pumpAndSettle();

    final dateWidget = tester.widget<DateQuestionWidget>(
      find.byType(DateQuestionWidget),
    );
    dateWidget.onDone!(dateQ.constructAnswer(DateTime(2025, 6)));
    await tester.pumpAndSettle();

    expect(find.text('Date follow-up choice'), findsOneWidget);

    final updatedDateWidget = tester.widget<DateQuestionWidget>(
      find.byType(DateQuestionWidget),
    );
    updatedDateWidget.onCleared!();
    await tester.pumpAndSettle();

    expect(find.text('Date follow-up choice'), findsNothing);
  });

  testWidgets(
    'conditional date question restores previous answer when re-shown',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show date picker?');
      final dateQ = DateQuestion.withId()
        ..id = 'dq'
        ..prompt = 'Pick date'
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(setup(QuestionnaireWidget([q1, dateQ])));
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final dateWidget = tester.widget<DateQuestionWidget>(
        find.byType(DateQuestionWidget),
      );
      dateWidget.onDone!(dateQ.constructAnswer(DateTime(2025, 6, 15)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('no').first);
      await tester.pumpAndSettle();
      expect(find.byType(DateQuestionWidget), findsNothing);

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(DateQuestionWidget), findsOneWidget);
      expect(
        find.text(
          DateFormat(
            DateTimeFormat.defaultDateFormat(const Locale('en')).pattern,
          ).format(DateTime(2025, 6, 15)),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('dependent visible answer blocks submit until reviewed', (
    tester,
  ) async {
    final q0 = _boolQuestion('q0', 'Keep follow-up visible?');
    final q1 = _boolQuestion('q1', 'Meal context?');
    final q2 = _singleChoiceQuestion('q2', 'What did you eat?')
      ..conditional = QuestionConditional.withCondition(
        CompositeExpression(
          logicType: LogicType.or,
          expressions: [
            BooleanExpression()..target = 'q0',
            BooleanExpression()..target = 'q1',
          ],
        ),
      );
    final q2ChoiceBId = q2.choices.last.id;

    final List<QuestionnaireState?> completions = [];

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(QuestionnaireWidget([q0, q1, q2], onComplete: completions.add)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('yes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('no').last);
    await tester.pumpAndSettle();

    expect(find.text('Review your answers'), findsOneWidget);
    expect(
      find.text(
        'You changed an earlier answer. Review your later answers before you complete the questionnaire.',
      ),
      findsOneWidget,
    );
    final completeButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Complete task'),
    );
    expect(completeButton.onPressed, isNull);
    expect(
      completeButton.style?.backgroundColor?.resolve({WidgetState.disabled}),
      isNot(Colors.green),
    );
    expect(completions.last, isNull);

    // Editing the flagged later answer must not dismiss the aggregate review.
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('Review your answers'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Complete task'),
          )
          .onPressed,
      isNull,
    );

    final completionCountBeforeBlockedSubmit = completions
        .whereType<QuestionnaireState>()
        .length;
    await tester.tap(find.text('Complete task'));
    await tester.pumpAndSettle();

    expect(
      completions.whereType<QuestionnaireState>().length,
      completionCountBeforeBlockedSubmit,
    );
    expect(find.text('Review your answers'), findsOneWidget);

    final markReviewedButton = find.widgetWithText(
      FilledButton,
      "I reviewed my answers",
    );
    expect(markReviewedButton, findsOneWidget);

    await tester.tap(markReviewedButton);
    await tester.pumpAndSettle();
    expect(find.text('Review your answers'), findsNothing);
    expect(
      find.text(
        'You changed an earlier answer. Review your later answers before you complete the questionnaire.',
      ),
      findsNothing,
    );
    final enabledCompleteButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Complete task'),
    );
    expect(enabledCompleteButton.onPressed, isNotNull);
    expect(enabledCompleteButton.focusNode?.hasFocus, isTrue);

    await tester.tap(find.text('Complete task'));
    await tester.pumpAndSettle();

    final reviewedCompletion = completions.whereType<QuestionnaireState>().last;
    expect(reviewedCompletion.answers['q2']?.response, [q2ChoiceBId]);
    expect(reviewedCompletion.answerMetadata['q2']?.needsReview, isFalse);
  });

  testWidgets('manual completion is blocked by visible review flag', (
    tester,
  ) async {
    final q0 = _boolQuestion('q0', 'Keep follow-up visible?');
    final q1 = _boolQuestion('q1', 'Meal context?');
    final q2 = _singleChoiceQuestion('q2', 'Context dependent answer')
      ..conditional = QuestionConditional.withCondition(
        CompositeExpression(
          logicType: LogicType.or,
          expressions: [
            BooleanExpression()..target = 'q0',
            BooleanExpression()..target = 'q1',
          ],
        ),
      );

    final List<QuestionnaireState?> completions = [];

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(QuestionnaireWidget([q0, q1, q2], onComplete: completions.add)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('yes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    final completedBeforeContextChange = completions
        .whereType<QuestionnaireState>()
        .length;

    await tester.tap(find.text('no').last);
    await tester.pumpAndSettle();

    expect(find.text('Review your answers'), findsOneWidget);
    expect(
      completions.whereType<QuestionnaireState>().length,
      completedBeforeContextChange,
    );
    expect(completions.last, isNull);
  });

  testWidgets('shouldContinue stop is blocked by visible review flag', (
    tester,
  ) async {
    final q0 = _boolQuestion('q0', 'Keep follow-up visible?');
    final q1 = _boolQuestion('q1', 'Meal context?');
    final q2 = _singleChoiceQuestion('q2', 'Context dependent answer')
      ..conditional = QuestionConditional.withCondition(
        CompositeExpression(
          logicType: LogicType.or,
          expressions: [
            BooleanExpression()..target = 'q0',
            BooleanExpression()..target = 'q1',
          ],
        ),
      );

    final List<QuestionnaireState?> completions = [];

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(
        QuestionnaireWidget(
          [q0, q1, q2],
          shouldContinue: (state) => state.answers['q1']?.response != false,
          onComplete: completions.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('yes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    final completedBeforeContextChange = completions
        .whereType<QuestionnaireState>()
        .length;

    await tester.tap(find.text('no').last);
    await tester.pumpAndSettle();

    expect(find.text('Review your answers'), findsOneWidget);
    expect(
      completions.whereType<QuestionnaireState>().length,
      completedBeforeContextChange,
    );
    expect(completions.last, isNull);
  });

  testWidgets('hidden flagged answer is excluded from shown review state', (
    tester,
  ) async {
    final q0 = _boolQuestion('q0', 'Keep meal answer visible?');
    final q1 = DateQuestion.withId()
      ..id = 'q1'
      ..prompt = 'Meal date';
    final q2 = _singleChoiceQuestion('q2', 'What did you eat?')
      ..conditional = QuestionConditional.withCondition(
        CompositeExpression(
          logicType: LogicType.or,
          expressions: [
            BooleanExpression()..target = 'q0',
            RequiresDateAnswerExpression(target: 'q1'),
          ],
        ),
      );

    final completions = <QuestionnaireState?>[];

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(QuestionnaireWidget([q0, q1, q2], onComplete: completions.add)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();
    final dateWidget = tester.widget<DateQuestionWidget>(
      find.byType(DateQuestionWidget),
    );
    dateWidget.onDone!(q1.constructAnswer(DateTime(2025, 6)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    // Change the earlier context while q2 stays technically visible.
    final updatedDateWidget = tester.widget<DateQuestionWidget>(
      find.byType(DateQuestionWidget),
    );
    updatedDateWidget.onDone!(q1.constructAnswer(DateTime(2025, 6, 2)));
    await tester.pumpAndSettle();

    // Clear q1. It is now the unanswered shown question, so q2 is removed
    // from shownQuestions even though its flagged answer remains cached.
    final clearedDateWidget = tester.widget<DateQuestionWidget>(
      find.byType(DateQuestionWidget),
    );
    clearedDateWidget.onCleared!();
    await tester.pumpAndSettle();
    expect(find.text('What did you eat?'), findsNothing);
    expect(
      find.byKey(const ValueKey('questionnaire_review_card')),
      findsNothing,
    );

    // Re-answer q0 to rebuild the progressive UI, then answer q1 naturally.
    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();
    final reshownDateWidget = tester.widget<DateQuestionWidget>(
      find.byType(DateQuestionWidget),
    );
    reshownDateWidget.onDone!(q1.constructAnswer(DateTime(2025, 6, 3)));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('questionnaire_review_card')),
      findsOneWidget,
    );
  });

  testWidgets(
    'auto-complete pauses for aggregate review and completes after confirmation',
    (tester) async {
      final q0 = _boolQuestion('q0', 'Keep the dependent answer visible?');
      final q1 = _boolQuestion('q1', 'Change the context?');
      final q2 = _singleChoiceQuestion('q2', 'Dependent answer')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.or,
            expressions: [
              BooleanExpression()..target = 'q0',
              BooleanExpression()..target = 'q1',
            ],
          ),
        );
      final completions = <QuestionnaireState?>[];

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q0, q1, q2],
            autoComplete: true,
            onComplete: completions.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('yes').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(completions.whereType<QuestionnaireState>(), hasLength(1));

      // q0 keeps q2 visible while changing the earlier q1 answer.
      await tester.tap(find.text('no').last);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('questionnaire_review_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('questionnaire_review_confirm')),
        findsOneWidget,
      );
      expect(completions.whereType<QuestionnaireState>(), hasLength(1));

      final confirmation = find.byKey(
        const ValueKey('questionnaire_review_confirm'),
      );
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(confirmation);
      await tester.pumpAndSettle();

      expect(completions.whereType<QuestionnaireState>(), hasLength(2));
    },
  );

  testWidgets(
    'editing an answered slider without a new question does not auto-scroll',
    (tester) async {
      final q0 = _boolQuestion('q0', 'Keep the later question visible?');
      final q1 = ScaleQuestion.withId()
        ..id = 'q1'
        ..prompt = 'Earlier slider'
        ..minimum = 0
        ..maximum = 10
        ..step = 1;
      final q2 = _boolQuestion('q2', 'Later question')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q0'],
          ),
        );

      tester.view.physicalSize = const Size(320, 320);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(setup(QuestionnaireWidget([q0, q1, q2])));
      await tester.pumpAndSettle();
      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CustomSlider));
      await tester.pumpAndSettle();
      await tester.tap(find.text('yes').last);
      await tester.pumpAndSettle();

      final scrollables = find
          .byType(Scrollable)
          .evaluate()
          .whereType<StatefulElement>()
          .map((element) => element.state)
          .whereType<ScrollableState>()
          .toSet()
          .toList();
      final scrollable = scrollables.reduce(
        (first, second) =>
            first.position.maxScrollExtent >= second.position.maxScrollExtent
            ? first
            : second,
      );
      final before = scrollable.position.pixels;
      final slider = find.byType(CustomSlider).first;
      await tester.tapAt(tester.getCenter(slider));
      await tester.pumpAndSettle();

      expect(scrollable.position.pixels, closeTo(before, 0.1));
    },
  );

  testWidgets('progressive reveal scrolls to a genuinely new question', (
    tester,
  ) async {
    final q1 = _boolQuestion('q1', 'Reveal the next question?');
    final q2 =
        FreeTextQuestion.withId(
            textType: FreeTextQuestionType.any,
            lengthRange: [0, 100],
          )
          ..id = 'q2'
          ..prompt = 'Newly revealed question';

    tester.view.physicalSize = const Size(320, 260);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(setup(QuestionnaireWidget([q1, q2])));
    await tester.pumpAndSettle();
    final scrollables = find
        .byType(Scrollable)
        .evaluate()
        .whereType<StatefulElement>()
        .map((element) => element.state)
        .whereType<ScrollableState>()
        .toSet()
        .toList();
    final scrollable = scrollables.reduce(
      (first, second) =>
          first.position.maxScrollExtent >= second.position.maxScrollExtent
          ? first
          : second,
    );
    expect(scrollable.position.pixels, 0);

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
    expect(scrollable.position.pixels, greaterThan(0));
  });
}

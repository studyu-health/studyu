import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/theme.dart' as studyu;
import 'package:studyu_app/widgets/questionnaire/custom_slider.dart';
import 'package:studyu_app/widgets/questionnaire/question_container.dart';
import 'package:studyu_app/widgets/questionnaire/questions/annotated_scale_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/scale_question_widget.dart';
import 'package:studyu_core/core.dart';

Annotation annotation(int value, String label) => Annotation()
  ..value = value
  ..annotation = label;

ScaleQuestion scale() => ScaleQuestion.withId()
  ..minimum = 0
  ..maximum = 10
  ..step = 1
  ..initial = 4
  ..annotations = [
    annotation(0, 'No pain'),
    annotation(10, 'Worst pain imaginable'),
  ];

void expectSelected(WidgetTester tester, String text) {
  final readout = tester.widget<Text>(
    find.byKey(const ValueKey('slider_selected_value')),
  );
  expect(readout.data, text);
}

class RecordingTrackShape() extends GappedSliderTrackShape {
  Offset? thumbCenterOnScreen;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    thumbCenterOnScreen = parentBox.localToGlobal(thumbCenter - offset);
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
    );
  }
}

Widget setup(
  Widget child, {
  double width = 320,
  double textScale = 1,
  Locale locale = const Locale('en'),
  TextDirection direction = TextDirection.ltr,
  SliderTrackShape? trackShape,
}) => MaterialApp(
  theme: ThemeData(sliderTheme: SliderThemeData(trackShape: trackShape)),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: locale,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: Directionality(textDirection: direction, child: child!),
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: width,
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  ),
);

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(360, 800),
    const Size(378, 751),
    const Size(390, 844),
    const Size(412, 915),
    const Size(430, 932),
    const Size(844, 390),
  ]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets('question card fits $size at text scale $textScale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final question = scale()
          ..prompt =
              '<p>Rate your average pain today on a scale of 0 to 10.</p> '
              '<p>Consider how pain affected your usual activities.</p>'
          ..rationale = 'Use your average pain during the past 24 hours.'
          ..annotations = [
            annotation(0, 'No pain or discomfort at any time today'),
            annotation(
              4,
              'Pain that sometimes interferes with daily activities',
            ),
            annotation(10, 'The worst pain that I can imagine experiencing'),
          ];
        await tester.pumpWidget(
          MaterialApp(
            theme: studyu.theme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: QuestionContainer(
                  question: question,
                  index: 0,
                  onDone: (_, _) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(Slider));
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byType(Slider)).height,
          greaterThanOrEqualTo(48),
        );
        for (final label in question.annotations) {
          final rect = tester.getRect(
            label.value == question.initial
                ? find.byKey(const ValueKey('slider_selected_value'))
                : find.text(label.annotation),
          );
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
        }
        final selected = find.byKey(const ValueKey('slider_selected_value'));
        expect(
          tester.getTopLeft(find.byType(Slider)).dy -
              tester.getBottomLeft(selected).dy,
          closeTo(8, 0.01),
        );
        await tester.ensureVisible(find.byTooltip('About this scale'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('About this scale'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('full endpoint labels appear below the native slider', (
    tester,
  ) async {
    await tester.pumpWidget(
      setup(ScaleQuestionWidget(question: scale(), onDone: (_) {})),
    );
    await tester.pumpAndSettle();

    final slider = find.byType(Slider);
    expectSelected(tester, '4/10');
    for (final label in ['No pain', 'Worst pain imaginable']) {
      expect(find.text(label), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(label)).dy,
        greaterThan(tester.getBottomLeft(slider).dy),
      );
    }
    expect(find.byTooltip('About this scale'), findsNothing);
    expect(tester.widget<Slider>(slider).divisions, 10);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected description uses neutral text close to the slider', (
    tester,
  ) async {
    final question = scale()..annotations.add(annotation(4, 'Moderate pain'));
    await tester.pumpWidget(
      setup(ScaleQuestionWidget(question: question, onDone: (_) {})),
    );
    await tester.pumpAndSettle();

    final selected = find.byKey(const ValueKey('slider_selected_value'));
    final theme = Theme.of(tester.element(selected));
    final selectedText = tester.widget<Text>(selected);
    expect(selectedText.style?.color, theme.colorScheme.onSurface);
    expect(selectedText.style?.color, isNot(theme.colorScheme.primary));
    expect(
      tester.getTopLeft(find.byType(Slider)).dy -
          tester.getBottomLeft(selected).dy,
      closeTo(8, 0.01),
    );
    for (final label in ['No pain', 'Worst pain imaginable']) {
      expect(
        tester.getTopLeft(find.text(label)).dy -
            tester.getBottomLeft(find.text('0')).dy,
        closeTo(8, 0.01),
      );
      expect(
        tester.widget<Text>(find.text(label)).style?.color,
        theme.colorScheme.onSurfaceVariant,
      );
    }
    expect(tester.takeException(), isNull);
  });

  for (final labels in [
    ['😞', '🙁', '😐', '🙂', '😄'],
    ['A', 'B', 'C', 'D', 'E'],
    ['1', '2', '3', '4', '5'],
    ['Low', 'Mid', 'Top'],
    ['👩🏽‍⚕️', '🙂', '👨‍👩‍👧', '😄', '❤️'],
  ]) {
    testWidgets('compact labels stay complete and visible: $labels', (
      tester,
    ) async {
      final question = scale()
        ..minimum = 1
        ..maximum = labels.length.toDouble()
        ..initial = 3
        ..annotations = [
          for (var i = 0; i < labels.length; i++) annotation(i + 1, labels[i]),
        ];
      await tester.pumpWidget(
        setup(
          ScaleQuestionWidget(question: question, onDone: (_) {}),
          width: 430,
        ),
      );
      await tester.pumpAndSettle();

      final bounds = tester.getRect(find.byType(CustomSlider));
      for (final label in labels) {
        expect(find.text(label), findsOneWidget);
        final rect = tester.getRect(find.text(label));
        expect(rect.left, greaterThanOrEqualTo(bounds.left));
        expect(rect.right, lessThanOrEqualTo(bounds.right));
      }
      for (var i = 1; i < labels.length; i++) {
        expect(
          tester.getRect(find.text(labels[i])).left,
          greaterThan(tester.getRect(find.text(labels[i - 1])).right),
        );
      }
      expect(find.byTooltip('About this scale'), findsNothing);
      expect(find.byKey(const ValueKey('slider_selected_value')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('crowded short labels use help when text size increases', (
    tester,
  ) async {
    final question = scale()
      ..minimum = 1
      ..maximum = 5
      ..initial = 3
      ..annotations = [for (var i = 1; i <= 5; i++) annotation(i, '$i$i')];
    for (final textScale in [1.0, 2.0]) {
      await tester.pumpWidget(
        setup(
          ScaleQuestionWidget(question: question, onDone: (_) {}),
          textScale: textScale,
        ),
      );
      await tester.pumpAndSettle();
      if (textScale == 1) {
        expect(find.text('22'), findsOneWidget);
        expect(find.byTooltip('About this scale'), findsNothing);
      } else {
        expect(find.text('22'), findsNothing);
        await tester.tap(find.byTooltip('About this scale'));
        await tester.pumpAndSettle();
        for (var i = 1; i <= 5; i++) {
          expect(find.text('$i: $i$i'), findsOneWidget);
        }
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('sparse labels retain numeric endpoints', (tester) async {
    final question = scale()..annotations = [annotation(4, 'OK')];
    await tester.pumpWidget(
      setup(ScaleQuestionWidget(question: question, onDone: (_) {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.byTooltip('About this scale'), findsNothing);
    expect(find.byKey(const ValueKey('slider_selected_value')), findsNothing);

    final slider = find.byType(Slider);
    final bounds = tester.getRect(slider);
    await tester.tap(slider);
    await tester.pumpAndSettle();
    expectSelected(tester, '5');
    expect(tester.getRect(slider), bounds);

    await tester.drag(slider, Offset(-bounds.width, 0));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('slider_selected_value')), findsNothing);
    expect(tester.getRect(slider), bounds);
  });

  testWidgets('numeric annotations do not repeat the selected number', (
    tester,
  ) async {
    final question = scale()
      ..minimum = 1
      ..maximum = 5
      ..initial = 3
      ..annotations = [for (var i = 1; i <= 5; i++) annotation(i, '$i')];
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      setup(ScaleQuestionWidget(question: question, onDone: (_) {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
    expect(find.byKey(const ValueKey('slider_selected_value')), findsNothing);
    expect(find.semantics.byValue('3'), findsOneWidget);
    expect(find.semantics.byValue('3, 3'), findsNothing);
    semantics.dispose();
  });

  testWidgets(
    'scale help appears below the endpoints apart from question rationale',
    (tester) async {
      final question = scale()
        ..prompt = 'Rate your pain'
        ..rationale = 'This question measures pain.'
        ..annotations.add(annotation(4, 'Moderate pain'));
      final answers = <Answer>[];
      await tester.pumpWidget(
        setup(
          QuestionContainer(
            question: question,
            index: 0,
            onDone: (answer, _) => answers.add(answer),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final scaleHelp = find.byKey(const ValueKey('slider_scale_labels'));
      expect(
        tester.getTopLeft(scaleHelp).dy,
        greaterThanOrEqualTo(
          tester.getBottomLeft(find.text('Worst pain imaginable')).dy,
        ),
      );
      expect(find.text('About this scale'), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(find.text('Information'), findsOneWidget);
      expect(
        find.text('This question measures pain.', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('4: Moderate pain'), findsNothing);
      Navigator.of(tester.element(find.byType(AlertDialog))).pop();
      await tester.pumpAndSettle();

      await tester.tap(scaleHelp);
      await tester.pumpAndSettle();
      expect(find.text('4: Moderate pain'), findsOneWidget);
      expect(find.text('Information'), findsNothing);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(answers, isEmpty);
    },
  );

  testWidgets('selected endpoint descriptions appear only once', (
    tester,
  ) async {
    final question = scale()..annotations.add(annotation(4, 'Moderate pain'));
    await tester.pumpWidget(
      setup(ScaleQuestionWidget(question: question, onDone: (_) {})),
    );
    await tester.pumpAndSettle();
    final slider = find.byType(Slider);
    final bounds = tester.getRect(slider);
    expectSelected(tester, '4/10 · Moderate pain');

    for (final endpoint in [
      (offset: -bounds.width, text: 'No pain'),
      (offset: bounds.width, text: 'Worst pain imaginable'),
    ]) {
      await tester.drag(slider, Offset(endpoint.offset, 0));
      await tester.pumpAndSettle();
      expect(find.text(endpoint.text), findsOneWidget);
      expectSelected(tester, endpoint.offset < 0 ? '0/10' : '10/10');
      expect(tester.getRect(slider), bounds);
    }
  });

  for (final direction in TextDirection.values) {
    testWidgets('endpoint labels align with the painted thumb in $direction', (
      tester,
    ) async {
      final track = RecordingTrackShape();
      await tester.pumpWidget(
        setup(
          ScaleQuestionWidget(question: scale(), onDone: (_) {}),
          direction: direction,
          trackShape: track,
        ),
      );
      await tester.pumpAndSettle();
      final slider = find.byType(Slider);
      final bounds = tester.getRect(slider);
      await tester.drag(slider, Offset(-bounds.width, 0));
      await tester.pumpAndSettle();
      final leftValue = direction == TextDirection.ltr ? '0' : '10';
      expect(
        tester.getCenter(find.text(leftValue)).dx,
        closeTo(track.thumbCenterOnScreen!.dx, 0.01),
      );
      await tester.drag(slider, Offset(bounds.width, 0));
      await tester.pumpAndSettle();
      final rightValue = direction == TextDirection.ltr ? '10' : '0';
      expect(
        tester.getCenter(find.text(rightValue)).dx,
        closeTo(track.thumbCenterOnScreen!.dx, 0.01),
      );
    });
  }

  testWidgets('a wrapping selected answer does not move the slider', (
    tester,
  ) async {
    final question = scale()
      ..annotations.addAll([
        annotation(4, 'Moderate pain'),
        annotation(5, 'Pain that sometimes interferes with daily activities'),
      ]);
    await tester.pumpWidget(
      setup(ScaleQuestionWidget(question: question, onDone: (_) {})),
    );
    await tester.pumpAndSettle();
    final slider = find.byType(Slider);
    final bounds = tester.getRect(slider);
    final readout = find.byKey(const ValueKey('slider_selected_value'));
    final initialHeight = tester.getSize(readout).height;
    await tester.tap(slider);
    await tester.pumpAndSettle();

    expectSelected(
      tester,
      '5/10 · Pain that sometimes interferes with daily activities',
    );
    expect(tester.getSize(readout).height, greaterThan(initialHeight));
    expect(tester.getRect(slider), bounds);
    expect(tester.takeException(), isNull);
  });

  for (final width in [248.0, 320.0, 378.0, 430.0]) {
    testWidgets('long labels fit width $width at 200 percent text', (
      tester,
    ) async {
      final question = scale()
        ..annotations = [
          annotation(0, 'No pain or discomfort at any time today'),
          annotation(4, 'Pain that sometimes interferes with daily activities'),
          annotation(10, 'The worst pain that I can imagine experiencing'),
        ];
      await tester.pumpWidget(
        setup(
          ScaleQuestionWidget(question: question, onDone: (_) {}),
          width: width,
          textScale: 2,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final bounds = tester.getRect(find.byType(CustomSlider));
      for (final label in question.annotations) {
        final rect = tester.getRect(
          label.value == question.initial
              ? find.byKey(const ValueKey('slider_selected_value'))
              : find.text(label.annotation),
        );
        expect(rect.left, greaterThanOrEqualTo(bounds.left));
        expect(rect.right, lessThanOrEqualTo(bounds.right));
      }
      final buttonSize = tester.getSize(
        find.byKey(const ValueKey('slider_scale_labels')),
      );
      expect(buttonSize.width, greaterThanOrEqualTo(48));
      expect(buttonSize.height, greaterThanOrEqualTo(48));
    });
  }

  testWidgets('help lists sorted full labels and does not submit an answer', (
    tester,
  ) async {
    final question = scale()
      ..annotations = [
        annotation(10, 'Worst pain imaginable'),
        annotation(4, 'Moderate pain'),
        annotation(0, 'No pain'),
        annotation(7, '  '),
      ];
    final answers = <Answer>[];
    await tester.pumpWidget(
      setup(ScaleQuestionWidget(question: question, onDone: answers.add)),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('About this scale'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('About this scale'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    final labels = [
      '0: No pain',
      '4: Moderate pain',
      '10: Worst pain imaginable',
    ];
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
    expect(
      tester.getTopLeft(find.text(labels.first)).dy,
      lessThan(tester.getTopLeft(find.text(labels.last)).dy),
    );
    expect(find.text('7:   '), findsNothing);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expectSelected(tester, '4/10 · Moderate pain');
    expect(answers, isEmpty);
  });

  testWidgets('many long help labels scroll at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final question = scale()
      ..annotations = [
        for (var i = 0; i <= 10; i++)
          annotation(i, 'A full description for the configured value $i'),
      ];
    await tester.pumpWidget(
      setup(
        ScaleQuestionWidget(question: question, onDone: (_) {}),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('About this scale'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('About this scale'));
    await tester.pumpAndSettle();
    final scrollable = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(SingleChildScrollView),
    );
    await tester.drag(scrollable, const Offset(0, -1600));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.text('10: A full description for the configured value 10'),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  for (final range in [
    (min: -10.0, max: 10.0, step: 2.0, initial: -4.0, text: '-4'),
    (min: 100.0, max: 1000.0, step: 100.0, initial: 400.0, text: '400'),
    (min: 0.0, max: 2.0, step: 0.5, initial: 0.5, text: '0.5'),
  ]) {
    testWidgets('numeric range ${range.min} to ${range.max} keeps its step', (
      tester,
    ) async {
      final question = scale()
        ..minimum = range.min
        ..maximum = range.max
        ..step = range.step
        ..initial = range.initial
        ..annotations = [];
      final answers = <Answer>[];
      await tester.pumpWidget(
        setup(ScaleQuestionWidget(question: question, onDone: answers.add)),
      );
      await tester.pumpAndSettle();
      expectSelected(tester, range.text);
      expect(find.byKey(const ValueKey('slider_scale_labels')), findsNothing);
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, range.min);
      expect(slider.max, range.max);
      expect(slider.divisions, (range.max - range.min) ~/ range.step);

      await tester.tap(find.byType(Slider));
      await tester.pumpAndSettle();
      expect(answers, hasLength(1));
      final response = answers.single.response as num;
      expect((response - range.min) % range.step, closeTo(0, 0.000001));
    });
  }

  testWidgets('drag updates the readout and submits only on release', (
    tester,
  ) async {
    final answers = <Answer>[];
    await tester.pumpWidget(
      setup(ScaleQuestionWidget(question: scale(), onDone: answers.add)),
    );
    await tester.pumpAndSettle();
    final slider = find.byType(Slider);
    final gesture = await tester.startGesture(tester.getCenter(slider));
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();
    final current = tester.widget<Slider>(slider).value;
    expect(current, greaterThan(4));
    expectSelected(tester, '${current.toInt()}/10');
    expect(answers, isEmpty);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(answers, hasLength(1));
    expect(answers.single.response, current);
  });

  testWidgets(
    'restored annotated answer has full semantics and keyboard input',
    (tester) async {
      final question = AnnotatedScaleQuestion.withId()
        ..minimum = 0
        ..maximum = 10
        ..step = 2
        ..initial = 0
        ..annotations = [
          annotation(4, 'Moderate pain'),
          annotation(6, 'Severe pain'),
        ];
      final answers = <Answer>[];
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        setup(
          AnnotatedScaleQuestionWidget(
            question: question,
            initialAnswer: question.constructAnswer(4),
            onDone: answers.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expectSelected(tester, '4/10 · Moderate pain');
      expect(
        find.semantics.byValue('4, Moderate pain').evaluate().single,
        matchesSemantics(
          value: '4, Moderate pain',
          increasedValue: '6, Severe pain',
          decreasedValue: '2',
          isSlider: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
          hasFocusAction: true,
        ),
      );
      final sliderBounds = tester.getRect(find.byType(Slider));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expectSelected(tester, '6/10 · Severe pain');
      expect(answers.single.response, closeTo(6, 1e-9));
      expect(find.text('Moderate pain'), findsNothing);
      expect(tester.getRect(find.byType(Slider)), sliderBounds);
      semantics.dispose();
    },
  );

  for (final locale in ['de', 'ko']) {
    testWidgets('slider controls use the $locale translation', (tester) async {
      final question = scale()
        ..annotations.add(
          annotation(4, 'A full description for the configured value'),
        );
      await tester.pumpWidget(
        setup(
          ScaleQuestionWidget(question: question, onDone: (_) {}),
          locale: Locale(locale),
        ),
      );
      await tester.pumpAndSettle();
      expectSelected(
        tester,
        '4/10 · A full description for the configured value',
      );
      expect(
        find.byTooltip(locale == 'de' ? 'Über diese Skala' : '이 척도 정보'),
        findsOneWidget,
      );
    });
  }

  for (final direction in TextDirection.values) {
    testWidgets('colored scale paints and responds in $direction', (
      tester,
    ) async {
      final question = scale()
        ..minColor = Colors.green.toARGB32()
        ..maxColor = Colors.red.toARGB32();
      await tester.pumpWidget(
        setup(
          ScaleQuestionWidget(question: question, onDone: (_) {}),
          direction: direction,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Slider));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.widget<Slider>(find.byType(Slider)).value, 5);
      final minX = tester.getCenter(find.text('0')).dx;
      final maxX = tester.getCenter(find.text('10')).dx;
      expect(minX < maxX, direction == TextDirection.ltr);
    });
  }
}

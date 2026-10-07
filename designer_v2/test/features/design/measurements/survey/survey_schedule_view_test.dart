@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_view.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets(
    'schedule summary lists localized study days and occurrence count',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final survey =
          MeasurementSurveyFormViewModel(study: Study.withId('study-1'))
            ..isScheduledControl.value = true
            ..specificDaysControl.value = [0, 4];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ReactiveForm(
                  formGroup: survey.form,
                  child: MeasurementSurveyFormView(formViewModel: survey),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Schedule summary'), findsOneWidget);
      expect(find.text('Appears on: Day 1, Day 5'), findsOneWidget);
      expect(
        find.text('2 occurrences across ${survey.studyLength} study days'),
        findsOneWidget,
      );
      expect(
        find.text(
          'When occurrence scheduling is off, the survey appears every study '
          'day. Built-in food-frequency questionnaires appear once by '
          'default. Choose one pattern. Selecting another pattern replaces '
          'the current one.',
        ),
        findsOneWidget,
      );

      expect(
        find.byTooltip('Occurrence controls which study days show the survey.'),
        findsOneWidget,
      );

      final schedulingHeader = find.text('Scheduling and Compliance');
      final occurrenceSchedule = find.text('Occurrence schedule');
      expect(schedulingHeader, findsOneWidget);
      expect(occurrenceSchedule, findsOneWidget);
      expect(
        tester.getTopLeft(occurrenceSchedule).dy,
        greaterThan(tester.getTopLeft(schedulingHeader).dy),
      );
      expect(
        find.ancestor(of: occurrenceSchedule, matching: find.byType(Card)),
        findsNothing,
      );
    },
  );

  testWidgets('disabled occurrence schedule explains the default schedule', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final survey = MeasurementSurveyFormViewModel(
      study: Study.withId('study-1'),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReactiveForm(
                formGroup: survey.form,
                child: MeasurementSurveyFormView(formViewModel: survey),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(survey.isScheduledControl.value, isFalse);
    const schedulingDescription =
        'Restrict daily access times and set reminder notifications to support '
        'timely task completion.';
    expect(find.text(schedulingDescription), findsOneWidget);
    final descriptionParagraph = find.byWidgetPredicate(
      (widget) =>
          widget is TextParagraph && widget.text == schedulingDescription,
    );
    expect(descriptionParagraph, findsOneWidget);
    final descriptionWidget = tester.widget<TextParagraph>(
      descriptionParagraph,
    );
    final descriptionColumn = tester
        .element(descriptionParagraph)
        .findAncestorWidgetOfExactType<Column>()!;
    final descriptionIndex = descriptionColumn.children.indexOf(
      descriptionWidget,
    );
    expect(descriptionColumn.crossAxisAlignment, CrossAxisAlignment.start);
    expect(
      descriptionColumn.children[descriptionIndex + 1],
      isA<SizedBox>().having((space) => space.height, 'height', 16.0),
    );
    expect(find.text('Schedule summary'), findsNothing);
    expect(
      find.byTooltip('Occurrence controls which study days show the survey.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('When occurrence scheduling is off'),
      findsNothing,
    );
  });

  testWidgets(
    'time restriction explains its default window only when enabled',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final survey = MeasurementSurveyFormViewModel(
        study: Study.withId('study-1'),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ReactiveForm(
                  formGroup: survey.form,
                  child: MeasurementSurveyFormView(formViewModel: survey),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      const description =
          'Tasks are available from 00:00 to 23:59 by default; set a narrower '
          'window if needed.';
      expect(find.text(description), findsNothing);
      expect(
        find.byTooltip(
          'Time restriction controls the daily window when participants can '
          'complete the task.',
        ),
        findsOneWidget,
      );

      survey.isTimeRestrictedControl.value = true;
      await tester.pumpAndSettle();

      final timeRestrictionDescription = find.text(description);
      expect(timeRestrictionDescription, findsOneWidget);
      final descriptionColumn = tester
          .element(timeRestrictionDescription)
          .findAncestorWidgetOfExactType<Column>()!;
      expect(descriptionColumn.crossAxisAlignment, CrossAxisAlignment.start);
      expect(
        descriptionColumn.children[1],
        isA<SizedBox>().having((space) => space.height, 'height', 16.0),
      );
      expect(descriptionColumn.children[2], isA<Row>());
      expect(survey.restrictedTimeStartControl.value?.hour, 0);
      expect(survey.restrictedTimeStartControl.value?.minute, 0);
      expect(survey.restrictedTimeEndControl.value?.hour, 23);
      expect(survey.restrictedTimeEndControl.value?.minute, 59);
    },
  );
}

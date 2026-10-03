@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurement_picker_dialog.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('returns the custom survey creation path', (tester) async {
    MeasurementSelection? result;
    await _pumpPicker(
      tester,
      _measurements(),
      onResult: (value) => result = value,
    );

    await tester.tap(
      find.byKey(const ValueKey('measurement-picker-create-survey')),
    );
    await tester.pumpAndSettle();

    expect(result, MeasurementSelection.blankSurvey);
    expect(find.byType(StandardDialog), findsNothing);
  });

  testWidgets('adds selected nutrition and survey measurements together', (
    tester,
  ) async {
    final measurements = _measurements();
    await _pumpPicker(tester, measurements);

    await tester.tap(
      find.byKey(const ValueKey('measurement-picker-nutrition')),
    );
    await tester.tap(
      find.byKey(const ValueKey('measurement-picker-template-ffq_26')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('measurement-picker-submit')));
    await tester.pumpAndSettle();

    final viewModels =
        measurements.measurementViewModelsCollection.retrievableViewModels;
    expect(viewModels.whereType<NutritionFormViewModel>(), hasLength(1));
    expect(
      viewModels.whereType<MeasurementSurveyFormViewModel>(),
      hasLength(1),
    );
    expect(find.byType(StandardDialog), findsNothing);
  });

  testWidgets('adds only the selected day from a multi-day measurement', (
    tester,
  ) async {
    final measurements = _measurements();
    final template = SurveyTemplateRegistry.findById('dhq3_14day')!;
    final entry = template.dayEntries!.first;
    await _pumpPicker(tester, measurements);

    final expandButton = find.byKey(
      const ValueKey('measurement-picker-expand-dhq3_14day'),
    );
    expect(expandButton, findsOneWidget);
    await tester.ensureVisible(expandButton);
    await tester.pump();
    await tester.tap(expandButton);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(ValueKey('measurement-picker-day-${entry.dayIndex}')),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.byKey(ValueKey('measurement-picker-day-${entry.dayIndex}')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(ValueKey('measurement-picker-day-${entry.dayIndex}')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('measurement-picker-submit')));
    await tester.pumpAndSettle();

    final surveys = measurements
        .measurementViewModelsCollection
        .retrievableViewModels
        .whereType<MeasurementSurveyFormViewModel>()
        .toList();
    expect(surveys, hasLength(1));
    expect(surveys.single.buildFormData().title, entry.title);
  });
}

Future<void> _pumpPicker(
  WidgetTester tester,
  MeasurementsFormViewModel measurements, {
  bool canAddNutrition = true,
  ValueChanged<MeasurementSelection?>? onResult,
}) async {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              key: const ValueKey('open-picker'),
              onPressed: () async {
                final result = await showDialog<MeasurementSelection>(
                  context: context,
                  builder: (_) => MeasurementPickerDialog(
                    formViewModel: measurements,
                    canAddNutrition: canAddNutrition,
                  ),
                );
                onResult?.call(result);
              },
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const ValueKey('open-picker')));
  await tester.pumpAndSettle();
}

MeasurementsFormViewModel _measurements() {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
      GoRoute(
        path: '/studies/:studyId/edit/measurements/:measurementId',
        name: studyEditMeasurementRouteName,
        builder: (_, _) => const SizedBox.shrink(),
      ),
    ],
  );
  addTearDown(router.dispose);
  return MeasurementsFormViewModel(
    study: Study.withId('study-1'),
    router: router,
    formData: MeasurementsFormData(measurements: []),
  );
}

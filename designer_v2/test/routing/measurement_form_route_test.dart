@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class _MockStudyRepository() extends Mock implements IStudyRepository;

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('same-session untouched survey draft resolves from its URL', (
    tester,
  ) async {
    final fixture = _fixture();
    addTearDown(fixture.router.dispose);

    await tester.pumpWidget(
      ProviderScope(overrides: fixture.overrides.cast(), child: fixture.app),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('New survey'));
    await tester.pumpAndSettle();

    final draft = fixture.measurements.measurementViewModels.single;
    expect(draft, isA<MeasurementSurveyFormViewModel>());
    expect(
      fixture.router.routeInformationProvider.value.uri.pathSegments.last,
      (draft as MeasurementSurveyFormViewModel).measurementId,
    );
    expect(find.text('Survey draft resolved'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stale direct survey URL returns to Measurements', (
    tester,
  ) async {
    final fixture = _fixture(initialMeasurementId: 'missing-survey');
    addTearDown(fixture.router.dispose);

    await tester.pumpWidget(
      ProviderScope(overrides: fixture.overrides.cast(), child: fixture.app),
    );
    await tester.pumpAndSettle();

    final exception = tester.takeException();
    expect(exception, isNull, reason: exception.toString());
    expect(
      fixture.router.routeInformationProvider.value.uri.path,
      endsWith('/edit/measurements'),
    );
    expect(find.text('Measurements'), findsOneWidget);
  });
}

({
  Widget app,
  List<dynamic> overrides,
  MeasurementsFormViewModel measurements,
  GoRouter router,
})
_fixture({String? initialMeasurementId}) {
  final study = Study.withId('study-1');
  late final MeasurementsFormViewModel measurements;
  late final GoRouter router;
  router = GoRouter(
    initialLocation: initialMeasurementId == null
        ? '/studies/${study.id}/edit/measurements'
        : '/studies/${study.id}/edit/measurements/$initialMeasurementId',
    routes: [
      GoRoute(
        path: '/studies/:studyId/edit/measurements',
        name: studyEditMeasurementsRouteName,
        builder: (_, _) => Scaffold(
          body: Column(
            children: [
              const Text('Measurements'),
              TextButton(
                onPressed: measurements.onNewSurvey,
                child: const Text('New survey'),
              ),
            ],
          ),
        ),
        routes: [
          GoRoute(
            path: ':measurementId',
            name: studyEditMeasurementRouteName,
            builder: (_, state) {
              final args = MeasurementFormRouteArgs(
                studyId: state.pathParameters['studyId']!,
                measurementId: state.pathParameters['measurementId']!,
              );
              if (initialMeasurementId != null) {
                return MeasurementFormRouteView(routeArgs: args);
              }
              return Consumer(
                builder: (_, ref, _) {
                  final draft = ref.watch(
                    measurementFormViewModelProvider(args),
                  );
                  return Text(
                    draft is MeasurementSurveyFormViewModel
                        ? 'Survey draft resolved'
                        : 'Survey draft missing',
                  );
                },
              );
            },
          ),
        ],
      ),
    ],
  );
  measurements = MeasurementsFormViewModel(
    study: study,
    router: router,
    formData: MeasurementsFormData(measurements: []),
  );
  final state = StudyControllerState(
    studyId: study.id,
    studyRepository: _MockStudyRepository(),
    router: router,
    currentUser: null,
    studyWithMetadata: WrappedModel(study),
  );

  return (
    app: MaterialApp.router(routerConfig: router),
    overrides: [
      studyControllerProvider(study.id).overrideWithValue(state),
      measurementsFormViewModelProvider(study.id)
          .overrideWithValue(measurements),
    ],
    measurements: measurements,
    router: router,
  );
}

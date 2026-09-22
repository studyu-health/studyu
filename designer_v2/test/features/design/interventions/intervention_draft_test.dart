@TestOn('browser')
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_data.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  test('new intervention is included until cancelled', () async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/studies/:studyId/edit/interventions/:interventionId',
          name: studyEditInterventionRouteName,
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);
    final study = Study.withId('test-user')
      ..interventions = [Intervention('intervention-1', 'Intervention 1')];
    final interventions = InterventionsFormViewModel(
      study: study,
      router: router,
      formData: InterventionsFormData.fromStudy(study),
    );
    await Future<void>.delayed(Duration.zero);

    interventions.onNewItem();
    await Future<void>.delayed(Duration.zero);

    expect(interventions.interventionsArray.controls, hasLength(2));
    final draft = interventions.interventionsCollection.formViewModels.last;
    expect(
      router.routeInformationProvider.value.uri.pathSegments.last,
      draft.interventionId,
    );

    await draft.cancel();

    expect(interventions.interventionsArray.controls, hasLength(1));
  });
}

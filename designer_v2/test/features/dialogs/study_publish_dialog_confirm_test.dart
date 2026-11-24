@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dialogs/publish/study_publish_dialog_confirm.dart';
import 'package:studyu_designer_v2/features/study/settings/study_settings_form_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/study_repository_interface.dart';

class _Repository() extends Mock implements IStudyRepository;

class _Controller(final StudyControllerState initialState)
    extends StudyController {
  @override
  StudyControllerState build(String studyId) => initialState;
}

class const _State(
  final Study savedStudy,
  IStudyRepository repository,
  GoRouter router,
  String studyId,
) extends StudyControllerState {
  this
    : super(
        studyId: studyId,
        studyRepository: repository,
        router: router,
        currentUser: null,
      );
  @override
  Study get studyValue => savedStudy;
}

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  for (final published in [false, true]) {
    testWidgets('Launch preserves saved publication $published on rebuild', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final study = Study('study', 'owner')
        ..participation = Participation.invite
        ..registryPublished = published
        ..resultSharing = published
            ? ResultSharing.public
            : ResultSharing.private;
      final repository = _Repository();
      final router = GoRouter(routes: []);
      addTearDown(router.dispose);
      final form = StudySettingsFormViewModel(
        studyRepository: repository,
        initialStudy: study,
      );
      final container = ProviderContainer(
        overrides: [
          studyControllerProvider(study.id).overrideWith(
            () => _Controller(_State(study, repository, router, study.id)),
          ),
          studySettingsFormViewModelProvider(study.id)
              .overrideWith((ref) => form),
        ],
      );
      addTearDown(container.dispose);

      Future<void> showDialog() => tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            key: UniqueKey(),
            home: Scaffold(body: PublishConfirmationDialog(study.id)),
          ),
        ),
      );

      await showDialog();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, published);
      expect(form.isPublishedToRegistryResultsControl.value, published);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await showDialog();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, !published);
      expect(study.registryPublished, published);
      await tester.pumpAndSettle();
    });
  }
}

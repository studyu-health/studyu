import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';

part 'study_test_controller.g.dart';

@riverpod
class StudyTestController() extends _$StudyTestController {
  @override
  StudyTestControllerState build(StudyID studyId) {
    final studyRepo = ref.watch(studyRepositoryProvider);
    ref.onDispose(() {
      // Reload the study after disposing the test controller so that any
      // data changes resulting from testing are reflected in the study for
      // other parts of the app (e.g. test data that was generated)
      //
      // Ideally, we would stream changes from the backend/database directly,
      // but this is a sufficient workaround for now.
      Future.delayed(
        const Duration(milliseconds: 100),
        () => studyRepo.fetch(studyId),
      );
      print('StudyTestController.dispose');
    });
    return StudyTestControllerState(
      studyId: studyId,
      studyRepository: ref.watch(studyRepositoryProvider),
      studyWithMetadata: ref
          .watch(studyControllerProvider(studyId))
          .studyWithMetadata,
      router: ref.watch(routerProvider),
      currentUser: ref.watch(authRepositoryProvider).currentUser,
      hasSession:
          ref.watch(authRepositoryProvider).serializedSession?.isNotEmpty ??
          false,
      languageCode: ref.watch(localeProvider).languageCode,
    );
  }
}

/// Provide a controller parametrized by [StudyID]
@riverpod
PlatformController studyTestPlatformController(Ref ref, StudyID studyId) {
  final state = ref.watch(studyTestControllerProvider(studyId));
  PlatformController platformController;
  if (!kIsWeb) {
    // Mobile could be built with the webview_flutter package
    throw Exception(
      "The StudyU designer only support the web platform".hardcoded,
    );
  } else {
    // Desktop and Web
    platformController = WebController(
      state.appUrl,
      studyId,
      ref.watch(authRepositoryProvider).serializedSession ?? '',
    );
  }
  ref.onDispose(platformController.dispose);
  return platformController;
}

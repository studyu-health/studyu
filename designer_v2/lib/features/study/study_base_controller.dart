import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_base_state.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

part 'study_base_controller.g.dart';

@riverpod
class StudyBaseController<T extends StudyControllerBaseState>()
    extends _$StudyBaseController<T> {
  @override
  StudyControllerBaseState build(StudyID studyId) {
    state = StudyControllerBaseState(
      studyId: studyId,
      studyRepository: ref.watch(studyRepositoryProvider),
      router: ref.watch(routerProvider),
      currentUser: ref.watch(authRepositoryProvider).currentUser,
      studyWithMetadata: null,
    );
    ref.onDispose(() => _studySubscription?.cancel());
    subscribeStudy(studyId);
    return state;
  }

  StreamSubscription<WrappedModel<Study>>? _studySubscription;

  void subscribeStudy(StudyID studyId) {
    if (_studySubscription != null) {
      _studySubscription!.cancel();
    }

    // Force fresh fetch by removing from cache before subscribing
    final studyRepository = state.studyRepository;
    final existingStudy = studyRepository.get(studyId);
    if (existingStudy != null) {
      studyRepository.markForRefresh(studyId);
    }

    _studySubscription = studyRepository
        .watch(studyId, fetchOnSubscribe: true)
        .listen(onStudySubscriptionUpdate, onError: onStudySubscriptionError);
  }

  void onStudySubscriptionUpdate(WrappedModel<Study> wrappedModel) {
    final studyId = wrappedModel.model.id;
    _redirectNewToActualStudyID(studyId);
    state = StudyControllerBaseState(
      studyId: wrappedModel.model.id,
      studyRepository: state.studyRepository,
      router: state.router,
      currentUser: state.currentUser,
      studyWithMetadata: wrappedModel,
    );
  }

  void onStudySubscriptionError(Object error) {
    // TODO: improve error handling
    if (error is StudyNotFoundException) {
      /* TODO: figure out a way to resolve data dependencies for the current page
           during app initialization so that we don't need to render the loading state
           if the study doesn't exist
      */
      state.router.dispatch(RoutingIntents.error(error));
    }
  }

  /// Redirect to the study-specific URL to avoid disposing a dirty controller
  /// when building subroutes
  void _redirectNewToActualStudyID(StudyID actualStudyId) {
    if (state.studyId == Config.newModelId) {
      state.router.dispatch(RoutingIntents.study(actualStudyId));
    }
  }
}

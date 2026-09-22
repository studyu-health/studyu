import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/clipboard.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/optimistic_update.dart';

part 'fitbit_credentials_repository.g.dart';

abstract class IFitbitCredentialsRepository()
    implements ModelRepository<StudyFitbitCredentials>;

class FitbitCredentialsRepository({
  /// The [Study] this repository operates on
  required final StudyID studyId,
  required final StudyUApi apiClient,
  required final IAuthRepository authRepository,
  required final IStudyRepository studyRepository,

  /// Reference to Riverpod's context to resolve dependencies in callbacks
  required final Ref ref,
}) extends ModelRepository<StudyFitbitCredentials>
    implements IFitbitCredentialsRepository {
  this
    : super(
        FitbitCredentialsRepositoryDelegate(
          study: studyRepository.get(studyId)!.model,
          apiClient: apiClient,
          studyRepository: studyRepository,
        ),
      );

  Study get study => studyRepository.get(studyId)!.model;

  @override
  ModelID getKey(StudyFitbitCredentials model) {
    return model.studyId;
  }

  @override
  List<ModelAction> availableActions(StudyFitbitCredentials model) {
    final actions = [
      ModelAction(
        type: ModelActionType.clipboard,
        label: ModelActionType.clipboard.string,
        onExecute: () => {
          ref
              .read(clipboardServiceProvider)
              .copy(model.studyId)
              .then(
                (value) => ref
                    .read(notificationServiceProvider)
                    .show(Notifications.inviteCodeClipped),
              ),
        },
      ),
      ModelAction(
        type: ModelActionType.delete,
        label: ModelActionType.delete.string,
        confirmation: ModelActionConfirmations.delete(
          subject: tr.dialog_subject_fitbit_credentials,
        ),
        onExecute: () async {
          return await delete(getKey(model))
              .then(
                (value) => ref
                    .read(routerProvider)
                    .dispatch(RoutingIntents.studyRecruit(model.studyId)),
              )
              .then(
                (value) => Future.delayed(
                  const Duration(milliseconds: 200),
                  () => ref
                      .read(notificationServiceProvider)
                      .show(Notifications.inviteCodeDeleted),
                ),
              );
        },
        isAvailable: study.isOwner(authRepository.currentUser),
        isDestructive: true,
      ),
    ];

    return actions.where((action) => action.isAvailable).toList();
  }

  @override
  void emitUpdate() {
    print("FitbitCredentialsRepository.emitUpdate");
    super.emitUpdate();
  }
}

class FitbitCredentialsRepositoryDelegate({
  required final Study study,
  required final StudyUApi apiClient,
  required final IStudyRepository studyRepository,
}) extends IModelRepositoryDelegate<StudyFitbitCredentials> {
  @override
  Future<StudyFitbitCredentials> fetch(ModelID modelId) {
    // Read directly from the study instead of fetching from the network
    return Future.value(study.fitbitCredentials);
  }

  @override
  Future<StudyFitbitCredentials> save(StudyFitbitCredentials model) {
    final prevCredentials = study.fitbitCredentials;

    final saveOperation = OptimisticUpdate(
      applyOptimistic: () {
        study.fitbitCredentials = model;
        studyRepository.upsertLocally(study);
      },
      apply: () async {
        await studyRepository.ensurePersisted(model.studyId);
        await apiClient.saveStudyFitbitCredentials(model);
      },
      rollback: () {
        study.fitbitCredentials = prevCredentials;
        studyRepository.upsertLocally(study);
      },
      onUpdate: () {
        print("saveOperation: studyRepository.emitUpdate()");
        studyRepository.emitUpdate();
      },
      rethrowErrors: true,
    );

    return saveOperation.execute().then((_) => model);
  }

  @override
  Future<void> delete(StudyFitbitCredentials model) {
    final prevCredentials = study.fitbitCredentials;

    final deleteOperation = OptimisticUpdate(
      applyOptimistic: () {
        study.fitbitCredentials = null;
        studyRepository.upsertLocally(study);
      },
      apply: () => apiClient.deleteStudyFitbitCredentials(model),
      rollback: () {
        study.fitbitCredentials = prevCredentials;
        studyRepository.upsertLocally(study);
      },
      onUpdate: studyRepository.emitUpdate,
      rethrowErrors: true,
    );

    return deleteOperation.execute();
  }

  @override
  void onError(Object error, StackTrace? stackTrace) {
    return; // TODO
  }

  @override
  StudyFitbitCredentials createDuplicate(StudyFitbitCredentials model) {
    throw UnimplementedError(); // not available
  }

  @override
  StudyFitbitCredentials createNewInstance() {
    throw UnimplementedError(); // not available
  }

  @override
  Future<List<StudyFitbitCredentials>> fetchAll() {
    throw UnimplementedError();
  }
}

@riverpod
FitbitCredentialsRepository fitbitCredentialsRepository(
  Ref ref,
  StudyID studyId,
) {
  // print("fitbitCredentialsRepositoryProvider($studyId");
  // Initialize repository for a given study
  final repository = FitbitCredentialsRepository(
    studyId: studyId,
    apiClient: ref.watch(apiClientProvider),
    authRepository: ref.watch(authRepositoryProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    ref: ref,
  );
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    // print("fitbitCredentialsRepositoryProvider($studyId.DISPOSE");
    repository.dispose();
  });
  return repository;
}

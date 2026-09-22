import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/study_delete_confirmation_dialog.dart';
import 'package:studyu_designer_v2/common_views/study_title_confirmation_dialog.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/features/analyze/study_export_zip.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dialogs/study_dialogs.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository_interface.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/optimistic_update.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'study_repository_interface.dart';

part 'study_repository.g.dart';

class StudyRepository({
  final VoidCallback? sortCallback,

  /// Reference to the StudyU API injected via Riverpod
  required final StudyUApi apiClient,

  /// Reference to the auth repository injected via Riverpod
  required final IAuthRepository authRepository,

  /// Reference to Riverpod's context to resolve dependencies in callbacks
  required final Ref ref,
}) extends ModelRepository<Study> implements IStudyRepository {
  this
    : super(
        StudyRepositoryDelegate(
          apiClient: apiClient,
          authRepository: authRepository,
        ),
      );

  @override
  ModelID getKey(Study model) {
    return model.id;
  }

  @override
  Future<void> deleteParticipants(Study study) {
    final wrappedModel = get(study.id);
    if (wrappedModel == null) {
      throw ModelNotFoundException();
    }

    final List<StudySubject> participants = [...study.participants ?? []];

    final deleteParticipantsOperation = OptimisticUpdate(
      applyOptimistic: () => study.participants = [],
      apply: () async {
        await apiClient.deleteParticipants(study, participants);
        upsertLocally(study);
      },
      rollback: () => study.participants = participants,
      onUpdate: () => emitUpdate(),
      onError: (e, stackTrace) {
        get(study.id)?.markWithError(e);
        emitError(modelStreamControllers[study.id], e, stackTrace);
      },
      rethrowErrors: true,
    );

    return deleteParticipantsOperation.execute();
  }

  @override
  Future<void> launch(Study study) {
    final wrappedModel = get(study.id);
    if (wrappedModel == null) {
      throw ModelNotFoundException();
    }

    final publishedCopy = study.asNewlyPublished();

    final publishOperation = OptimisticUpdate(
      applyOptimistic: () => {}, // nothing to do here
      apply: () => save(publishedCopy, runOptimistically: false),
      rollback: () {}, // nothing to do here
      onUpdate: () => emitUpdate(),
      onError: (e, stackTrace) {
        emitError(modelStreamControllers[study.id], e, stackTrace);
      },
    );

    deleteParticipants(study);
    return publishOperation.execute();
  }

  /// This method fetches the full study object, duplicates it and saves it as a draft.
  /// Since the Study object in the dashboard is fetched with limited columns (no intervention or measurement data),
  /// we need to fetch the full columns in order to duplicate it correctly.
  @override
  Future<void> duplicateAndSave(Study model) async {
    final Study completeModel = await apiClient.fetchStudy(model.id);
    final duplicate = completeModel.duplicateAsDraft(
      authRepository.currentUser!.id,
    );
    await save(duplicate, runOptimistically: false);
  }

  @override
  Future<void> close(Study study) async {
    if (get(study.id) == null) {
      throw ModelNotFoundException();
    }

    final closedStudy = study.exactDuplicate()..status = StudyStatus.closed;
    await save(closedStudy, runOptimistically: false);
  }

  @override
  Future<StudiesPage> fetchPage({
    required int offset,
    required int limit,
    required StudiesTableColumn sortBy,
    required bool ascending,
    required StudiesFilter preset,
    required User currentUser,
    String? searchQuery,
    FilterGroup? advancedFilter,
    List<String> excludeIds = const [],
  }) async {
    final page = await apiClient.getUserStudiesPage(
      offset: offset,
      limit: limit,
      sortBy: sortBy,
      ascending: ascending,
      preset: preset,
      currentUser: currentUser,
      searchQuery: searchQuery,
      advancedFilter: advancedFilter,
      excludeIds: excludeIds,
    );
    final wrappedStudies = upsertAllLocally(page.studies);
    for (final wrappedStudy in wrappedStudies) {
      wrappedStudy.markAsFetched();
    }
    return page;
  }

  @override
  Future<List<Study>> fetchPinned(Set<String> pinnedIds) async {
    final studies = await apiClient.getPinnedUserStudies(pinnedIds: pinnedIds);
    final wrappedStudies = upsertAllLocally(studies);
    for (final wrappedStudy in wrappedStudies) {
      wrappedStudy.markAsFetched();
    }
    return studies;
  }

  @override
  List<ModelAction> availableActions(Study model) {
    Future<void> onDeleteCallback() async {
      final router = ref.read(routerProvider);
      bool isDashboard() =>
          router.routeInformationProvider.value.uri.path ==
          RoutingIntents.studies.route.path;

      try {
        await delete(model.id, runOptimistically: false);
      } catch (_) {
        if (isDashboard()) rethrow;
        ref.read(notificationServiceProvider).showMessage(tr.sync_failed);
        return;
      }

      if (!isDashboard()) router.dispatch(RoutingIntents.studies);
      ref.read(notificationServiceProvider).show(Notifications.studyDeleted);
    }

    final currentUser = authRepository.currentUser;
    if (currentUser == null) return [];

    // TODO: review Postgres policies to match [ModelAction.isAvailable]
    final actions = [
      ModelAction(
        type: StudyActionType.edit,
        label: StudyActionType.edit.string,
        onExecute: () {
          ref.read(routerProvider).dispatch(RoutingIntents.studyEdit(model.id));
        },
        isAvailable: model.canEditDraft(currentUser),
      ),
      ModelAction(
        // same as "Copy" but for non-drafts
        type: StudyActionType.duplicateDraft,
        label: StudyActionType.duplicateDraft.string,
        onExecute: () => duplicateAndSave(model),
        isAvailable:
            model.status != StudyStatus.draft && model.canCopy(currentUser),
      ),
      ModelAction(
        type: StudyActionType.duplicate,
        label: StudyActionType.duplicate.string,
        onExecute: () => duplicateAndSave(model),
        isAvailable:
            model.status == StudyStatus.draft && model.canCopy(currentUser),
      ),
      ModelAction(
        type: StudyActionType.exportDefinition,
        label: StudyActionType.exportDefinition.string,
        onExecute: () {
          model.downloadDefinition();
        },
        isAvailable: model.canCopy(currentUser),
      ),
      /*
      TODO re-implement this properly
      ModelAction(
        type: StudyActionType.addCollaborator,
        label: "Add collaborator".hardcoded,
        onExecute: () {
          print("Adding collaborator: ${study.title ?? ''}");
        },
        isAvailable: study.isOwner(authRepository.currentUser!),
      ),
       */
      ModelAction(
        type: StudyActionType.export,
        label: StudyActionType.export.string,
        onExecute: () {
          runAsync(() => model.exportData.downloadAsZip());
        },
        isAvailable: model.canExport(currentUser),
      ),
      if (model.canDelete(currentUser)) ModelAction.addSeparator(),
      ModelAction(
        type: StudyActionType.close,
        label: StudyActionType.close.string,
        onExecute: () => close(model),
        confirmation: ModelActionConfirmation(
          title: tr.dialog_study_close_title,
          message: tr.dialog_study_close_description,
          dialogBuilder: (dialogContext, action) =>
              StudyTitleConfirmationDialog(
                study: model,
                title: tr.dialog_study_close_title,
                description: tr.dialog_study_close_description,
                instruction: tr.dialog_study_close_type_name_instruction(
                  model.title ?? '',
                ),
                textFieldLabel: tr.dialog_study_close_type_name_label,
                confirmLabel: action.label,
                confirmationCheckboxes: [
                  StudyConfirmationCheckbox(
                    key: const ValueKey('study_close_irreversible_checkbox'),
                    label: Text(
                      tr.dialog_study_close_irreversible_confirmation,
                    ),
                  ),
                ],
                destructive: true,
                onConfirmed: () async => Navigator.of(dialogContext).pop(true),
              ),
        ),
        isAvailable:
            model.status == StudyStatus.running && model.canClose(currentUser),
      ),
      ModelAction(
        type: StudyActionType.delete,
        label: StudyActionType.delete.string,
        onExecute: onDeleteCallback,
        confirmation: ModelActionConfirmation(
          title: tr.dialog_study_delete_title,
          message: tr.dialog_study_delete_description,
          dialogBuilder: (dialogContext, action) =>
              StudyDeleteConfirmationDialog(
                study: model,
                confirmLabel: action.label,
                onDownloadBackup: () async {
                  model.downloadDefinition();
                  await model.exportData.downloadAsZip();
                },
                onCloseInstead: () async {
                  Navigator.of(dialogContext).pop(false);
                  await Future<void>.delayed(Duration.zero);
                  if (dialogContext.mounted) {
                    await showStudyDialog(
                      dialogContext,
                      model.id,
                      StudyDialogType.close,
                    );
                  }
                },
              ),
        ),
        isAvailable: model.canDelete(currentUser),
        isDestructive: true,
      ),
    ];

    return actions.where((action) => action.isAvailable).toList();
  }
}

class StudyRepositoryDelegate({
  required final StudyUApi apiClient,
  required final IAuthRepository authRepository,
}) extends IModelRepositoryDelegate<Study> {
  @override
  Future<List<Study>> fetchAll() {
    return apiClient.getUserStudies(forDashboardDisplay: true);
  }

  @override
  Future<Study> fetch(ModelID modelId) {
    return apiClient.fetchStudy(modelId);
  }

  @override
  Future<Study> save(Study model) {
    return apiClient.saveStudy(model);
  }

  @override
  Future<void> delete(Study model) {
    return apiClient.deleteStudy(model);
  }

  @override
  void onError(Object error, StackTrace? stackTrace) {
    return; // TODO
  }

  @override
  Study createNewInstance() {
    return StudyTemplates.emptyDraft(authRepository.currentUser!.id);
  }

  @override
  Study createDuplicate(Study model) {
    return model.duplicateAsDraft(authRepository.currentUser!.id);
  }
}

@riverpod
StudyRepository studyRepository(Ref ref) => StudyRepository(
  apiClient: ref.watch(apiClientProvider),
  authRepository: ref.watch(authRepositoryProvider),
  ref: ref,
);

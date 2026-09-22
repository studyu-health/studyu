import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/common_views/qr_code_preview_dialog.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_repository.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/clipboard.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/optimistic_update.dart';

part 'invite_code_repository.g.dart';

const int defaultInviteCodePageSize = 15;
const _copyInviteLinkActionValue = 'copy_link';
const _showQrCodeActionValue = 'qr_code';
const _rowMenuItemHorizontalPadding = 8.0;
const _rowMenuItemHorizontalTitleGap = 4.0;
const _rowMenuIconFallbackSize = 14.0;
const _shareMenuElevation = 5.0;

abstract class IInviteCodeRepository() implements ModelRepository<StudyInvite> {
  Future<bool> isCodeAlreadyUsed(String code);

  Future<List<StudyInvite>> fetchPage({
    required int offset,
    required int limit,
    String? query,
    InviteCodesSortColumn sortBy = InviteCodesSortColumn.code,
    bool ascending = true,
  });

  Future<int> count({String? query});
}

class InviteCodeRepository({
  /// The [Study] this repository operates on
  required final StudyID studyId,
  required final StudyUApi apiClient,
  required final IAuthRepository authRepository,
  required final IStudyRepository studyRepository,

  /// Reference to Riverpod's context to resolve dependencies in callbacks
  required final Ref ref,
}) extends ModelRepository<StudyInvite>
    implements IInviteCodeRepository, InviteCodeFormRepository {
  this
    : super(
        InviteCodeRepositoryDelegate(
          study: studyRepository.get(studyId)!.model,
          apiClient: apiClient,
          studyRepository: studyRepository,
        ),
      );

  Study get study => studyRepository.get(studyId)!.model;

  final Map<ModelID, WrappedModel<StudyInvite>> _pageCache = {};
  int _pageFetchToken = 0;

  @override
  Map<ModelID, WrappedModel<StudyInvite>> get modelCache => _pageCache;

  @override
  ModelID getKey(StudyInvite model) {
    return model.code;
  }

  @override
  Future<bool> isCodeAlreadyUsed(String code) async {
    try {
      await apiClient.fetchStudyFromInvite(code);
    } on StudyInviteNotFoundException {
      return false;
    } catch (e) {
      rethrow;
    }
    return true;
  }

  /// Generate the deep link URL for an invite code
  String generateInviteDeepLink(String code) {
    return env.generateAppDeepLink('invite/${Uri.encodeComponent(code)}');
  }

  @override
  Future<List<StudyInvite>> fetchPage({
    required int offset,
    required int limit,
    String? query,
    InviteCodesSortColumn sortBy = InviteCodesSortColumn.code,
    bool ascending = true,
  }) async {
    final fetchToken = ++_pageFetchToken;
    final invites = await apiClient.fetchStudyInvitesPage(
      studyId,
      offset: offset,
      limit: limit,
      query: query,
      sortBy: sortBy,
      ascending: ascending,
    );
    if (fetchToken != _pageFetchToken) {
      return invites;
    }

    final pageIds = invites.map(getKey).toSet();
    modelCache.removeWhere(
      (modelId, wrappedModel) =>
          !pageIds.contains(modelId) &&
          !modelStreamControllers.containsKey(modelId) &&
          !wrappedModel.isDirty &&
          !wrappedModel.isLocalOnly,
    );
    for (final invite in invites) {
      final wrappedInvite = upsertLocally(invite);
      wrappedInvite.markAsFetched();
    }
    emitUpdate();
    return invites;
  }

  @override
  Future<int> count({String? query}) {
    return apiClient.countStudyInvites(studyId, query: query);
  }

  @override
  List<ModelAction> availableActions(StudyInvite model) {
    final deepLink = generateInviteDeepLink(model.code);
    final List<ModelAction> actions = [
      ModelAction(
        type: ModelActionType.clipboard,
        label: tr.action_copy_invite_code,
        onExecute: () => _copy(model.code, Notifications.inviteCodeCopied),
      ),
      ModelAction(
        type: ModelActionType.share,
        label: ModelActionType.share.string,
        onExecute: () {},
        onExecuteWithContext: (context) {
          _showSharePopup(context, deepLink, model.code);
        },
      ),
      ModelAction(
        type: ModelActionType.copyLink,
        label: tr.action_copy_invite_link,
        onExecute: () => _copy(deepLink, Notifications.inviteLinkCopied),
      ),
      ModelAction(
        type: ModelActionType.qrCodeShow,
        label: ModelActionType.qrCodeShow.string,
        onExecute: () {},
        onExecuteWithContext: (context) {
          _showQrCode(context, deepLink, model.code, inviteCode: model.code);
        },
      ),
    ];

    if (study.isOwner(authRepository.currentUser)) {
      actions.add(
        ModelAction(
          type: ModelActionType.delete,
          label: tr.action_delete_code,
          confirmation: ModelActionConfirmation(
            title: tr.dialog_delete_invite_code_title,
            message: tr.dialog_delete_invite_code_message(model.code),
            confirmLabel: tr.action_delete_code,
          ),
          onExecute: () async {
            await delete(getKey(model), runOptimistically: false);
            ref
                .read(routerProvider)
                .dispatch(RoutingIntents.studyRecruit(model.studyId));
            await Future.delayed(
              const Duration(milliseconds: 200),
              () => ref
                  .read(notificationServiceProvider)
                  .show(Notifications.inviteCodeDeleted),
            );
          },
          isDestructive: true,
        ),
      );
    }

    return actions;
  }

  Future<void> _copy(String value, SnackbarIntent notification) async {
    await ref.read(clipboardServiceProvider).copy(value);
    ref.read(notificationServiceProvider).show(notification);
  }

  void _showSharePopup(BuildContext context, String deepLink, String filename) {
    final effectiveContext = context;

    // Determine where to render the popup based on the clicked element
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final theme = Theme.of(context);
    final textTheme = theme.textTheme.labelMedium!;
    final iconColorDefault =
        theme.iconTheme.color?.withValues(alpha: 0.7) ?? Colors.grey;

    showMenu<String>(
      context: context,
      position: position,
      elevation: _shareMenuElevation,
      items: [
        PopupMenuItem<String>(
          value: _copyInviteLinkActionValue,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _rowMenuItemHorizontalPadding,
            ),
            horizontalTitleGap: _rowMenuItemHorizontalTitleGap,
            leading: Icon(
              Icons.link_rounded,
              size: theme.iconTheme.size ?? _rowMenuIconFallbackSize,
              color: iconColorDefault,
            ),
            title: Text(tr.action_copy_invite_link, style: textTheme),
          ),
        ),
        PopupMenuItem<String>(
          value: _showQrCodeActionValue,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _rowMenuItemHorizontalPadding,
            ),
            horizontalTitleGap: _rowMenuItemHorizontalTitleGap,
            leading: Icon(
              Icons.qr_code_rounded,
              size: theme.iconTheme.size ?? _rowMenuIconFallbackSize,
              color: iconColorDefault,
            ),
            title: Text(ModelActionType.qrCodeShow.string, style: textTheme),
          ),
        ),
      ],
    ).then((value) {
      if (value == _copyInviteLinkActionValue) {
        _copy(deepLink, Notifications.inviteLinkCopied);
      } else if (value == _showQrCodeActionValue && effectiveContext.mounted) {
        _showQrCode(effectiveContext, deepLink, filename, inviteCode: filename);
      }
    });
  }

  void _showQrCode(
    BuildContext context,
    String deepLink,
    String filename, {
    String? inviteCode,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => QrCodePreviewDialog(
        data: deepLink,
        filename: filename,
        inviteCode: inviteCode,
      ),
    );
  }
}

class InviteCodeRepositoryDelegate({
  required final Study study,
  required final StudyUApi apiClient,
  required final IStudyRepository studyRepository,
}) extends IModelRepositoryDelegate<StudyInvite> {
  @override
  Future<StudyInvite> fetch(ModelID modelId) {
    return apiClient.fetchStudyInvite(modelId);
  }

  @override
  Future<List<StudyInvite>> fetchAll() {
    return apiClient.fetchStudyInvitesPage(
      study.id,
      offset: 0,
      limit: defaultInviteCodePageSize,
    );
  }

  @override
  Future<StudyInvite> save(StudyInvite model) {
    final prevInvites = [...?study.invites];
    final saveOperation = OptimisticUpdate(
      applyOptimistic: () {},
      apply: () async {
        await studyRepository.ensurePersisted(model.studyId);
        await apiClient.saveStudyInvite(model);
      },
      rollback: () {
        study.invites = prevInvites;
        studyRepository.upsertLocally(study);
      },
      onUpdate: studyRepository.emitUpdate,
      rethrowErrors: true,
      completeFutureOptimistically: false,
    );

    return saveOperation.execute().then((_) => model);
  }

  @override
  Future<void> delete(StudyInvite model) {
    return apiClient.deleteStudyInvite(model);
  }

  @override
  void onError(Object error, StackTrace? stackTrace) {
    return; // TODO
  }

  @override
  StudyInvite createDuplicate(StudyInvite model) {
    throw UnimplementedError(); // not available
  }

  @override
  StudyInvite createNewInstance() {
    throw UnimplementedError(); // not available
  }
}

@riverpod
InviteCodeRepository inviteCodeRepository(Ref ref, StudyID studyId) {
  // Initialize repository for a given study
  final repository = InviteCodeRepository(
    studyId: studyId,
    apiClient: ref.watch(apiClientProvider),
    authRepository: ref.watch(authRepositoryProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
    ref: ref,
  );
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    repository.dispose();
  });
  return repository;
}

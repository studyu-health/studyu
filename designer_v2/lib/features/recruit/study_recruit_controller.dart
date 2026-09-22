import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_pagination.dart';
import 'package:studyu_designer_v2/features/recruit/study_recruit_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository_events.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

part 'study_recruit_controller.g.dart';

@riverpod
class StudyRecruitController()
    extends _$StudyRecruitController
    implements IModelActionProvider<StudyInvite> {
  static const _searchDebounceDuration = Duration(milliseconds: 300);

  /// [inviteCodeRepository] Reference to the repository for invite codes (resolved dynamically via Riverpod when the [state.study] becomes available)
  @override
  StudyRecruitControllerState build(StudyID studyId) {
    final inviteCodeRepository = ref.watch(
      inviteCodeRepositoryProvider(studyId),
    );
    state = StudyRecruitControllerState(
      studyId: studyId,
      studyRepository: ref.watch(studyRepositoryProvider),
      studyWithMetadata: ref
          .watch(studyControllerProvider(studyId))
          .studyWithMetadata,
      router: ref.watch(routerProvider),
      currentUser: ref.watch(authRepositoryProvider).currentUser,
      inviteCodeRepository: inviteCodeRepository,
    );
    _inviteCodeChangesSubscription?.cancel();
    _inviteCodeChangesSubscription = inviteCodeRepository
        .watchAllChanges()
        .where(
          (event) =>
              event is IsSaved<StudyInvite> || event is IsDeleted<StudyInvite>,
        )
        .listen((_) => _schedulePageRefresh());
    ref.onDispose(() {
      print("StudyRecruitController.dispose");
      _searchDebounce?.cancel();
      _refreshTimer?.cancel();
      _inviteCodeChangesSubscription?.cancel();
    });
    Future.microtask(() => loadInviteCodePage(0));
    return state;
  }

  Timer? _searchDebounce;
  Timer? _refreshTimer;
  StreamSubscription<ModelEvent<StudyInvite>>? _inviteCodeChangesSubscription;
  int _fetchToken = 0;

  Future<void> loadInviteCodePage(
    int pageIndex, {
    bool showLoading = true,
  }) async {
    if (pageIndex < 0) return;
    final token = ++_fetchToken;
    final hasVisibleInvites =
        state.invites is AsyncData<List<StudyInvite>?> &&
        ((state.invites as AsyncData<List<StudyInvite>?>).value?.isNotEmpty ??
            false);
    if (showLoading) {
      if (hasVisibleInvites) {
        state = state.copyWith(
          paginationStatus: InviteCodePaginationStatus.loading,
          pendingInviteCodePageIndex: pageIndex,
          clearPaginationError: true,
        );
      } else {
        state = state.copyWith(
          invites: const AsyncValue.loading(),
          paginationStatus: InviteCodePaginationStatus.idle,
          clearPendingInviteCodePageIndex: true,
          clearPaginationError: true,
        );
      }
    } else {
      state = state.copyWith(
        paginationStatus: InviteCodePaginationStatus.loading,
        pendingInviteCodePageIndex: pageIndex,
        clearPaginationError: true,
      );
    }

    final trimmedQuery = state.inviteCodeSearchQuery.trim();
    final query = trimmedQuery.isEmpty ? null : trimmedQuery;
    final offset = pageIndex * state.inviteCodePageSize;

    try {
      final inviteCount = await state.inviteCodeRepository.count(query: query);

      if (token != _fetchToken) return;

      if (inviteCount == 0) {
        state = state.copyWith(
          invites: const AsyncValue.data(<StudyInvite>[]),
          inviteCodePageIndex: 0,
          inviteCodeCount: 0,
          hasNextInviteCodePage: false,
          isSearchPending: false,
          paginationStatus: InviteCodePaginationStatus.idle,
          clearPendingInviteCodePageIndex: true,
          clearPaginationError: true,
        );
        return;
      }

      final invites = await state.inviteCodeRepository.fetchPage(
        offset: offset,
        limit: state.inviteCodePageSize,
        query: query,
        sortBy: state.inviteCodeSortColumn,
        ascending: state.inviteCodeSortAscending,
      );

      if (token != _fetchToken) return;

      final clampedPageIndex = clampInviteCodePageIndex(
        requestedPageIndex: pageIndex,
        totalCount: inviteCount,
        pageSize: state.inviteCodePageSize,
      );

      if (clampedPageIndex != pageIndex) {
        await loadInviteCodePage(clampedPageIndex, showLoading: false);
        return;
      }

      state = state.copyWith(
        invites: AsyncValue.data(invites),
        inviteCodePageIndex: pageIndex,
        inviteCodeCount: inviteCount,
        hasNextInviteCodePage: offset + invites.length < inviteCount,
        isSearchPending: false,
        paginationStatus: InviteCodePaginationStatus.idle,
        clearPendingInviteCodePageIndex: true,
        clearPaginationError: true,
      );
    } catch (error, stackTrace) {
      if (token != _fetchToken) return;
      if (hasVisibleInvites) {
        state = state.copyWith(
          paginationStatus: InviteCodePaginationStatus.error,
          pendingInviteCodePageIndex: pageIndex,
          isSearchPending: false,
          paginationError: error,
        );
      } else {
        state = state.copyWith(
          invites: AsyncValue.error(error, stackTrace),
          inviteCodeCount: 0,
          hasNextInviteCodePage: false,
          isSearchPending: false,
          paginationStatus: InviteCodePaginationStatus.idle,
          clearPendingInviteCodePageIndex: true,
          clearPaginationError: true,
        );
      }
    }
  }

  Future<void> setInviteCodeSearchQuery(String query) async {
    if (query == state.inviteCodeSearchQuery) return;
    _fetchToken++;
    state = state.copyWith(inviteCodeSearchQuery: query, isSearchPending: true);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      unawaited(loadInviteCodePage(0));
    });
  }

  Future<void> setInviteCodeSorting(InviteCodesSortColumn column) async {
    final isSameColumn = state.inviteCodeSortColumn == column;
    final ascending = !isSameColumn || !state.inviteCodeSortAscending;
    state = state.copyWith(
      inviteCodeSortColumn: column,
      inviteCodeSortAscending: ascending,
    );
    await loadInviteCodePage(0);
  }

  Future<void> setInviteCodePageSize(int pageSize) async {
    if (pageSize == state.inviteCodePageSize) return;
    state = state.copyWith(inviteCodePageSize: pageSize);
    await loadInviteCodePage(0);
  }

  Future<void> loadPreviousInviteCodePage() async {
    if (!state.hasPreviousInviteCodePage) return;
    await loadInviteCodePage(state.inviteCodePageIndex - 1);
  }

  Future<void> loadNextInviteCodePage() async {
    if (!state.hasComputedNextInviteCodePage) return;
    await loadInviteCodePage(state.inviteCodePageIndex + 1);
  }

  Future<void> retryInviteCodePageLoad() async {
    final pendingPageIndex =
        state.pendingInviteCodePageIndex ?? state.inviteCodePageIndex;
    await loadInviteCodePage(pendingPageIndex);
  }

  Future<void> showCreatedInviteCode(StudyInvite invite) async {
    _searchDebounce?.cancel();
    final currentInvites = state.invites is AsyncData<List<StudyInvite>?>
        ? (state.invites as AsyncData<List<StudyInvite>?>).value ??
              const <StudyInvite>[]
        : const <StudyInvite>[];
    final query = state.inviteCodeSearchQuery.trim().toLowerCase();
    final matchesCurrentQuery =
        query.isEmpty || invite.code.toLowerCase().contains(query);

    if (state.inviteCodePageIndex == 0 && matchesCurrentQuery) {
      final updatedInvites = [
        invite,
        ...currentInvites.where((item) => item.code != invite.code),
      ];
      state = state.copyWith(
        invites: AsyncValue.data(
          updatedInvites.take(state.inviteCodePageSize).toList(),
        ),
        inviteCodeCount: state.inviteCodeCount + 1,
        hasNextInviteCodePage: updatedInvites.length > state.inviteCodePageSize,
        paginationStatus: InviteCodePaginationStatus.idle,
        clearPendingInviteCodePageIndex: true,
        clearPaginationError: true,
      );
    } else if (query.isEmpty) {
      state = state.copyWith(inviteCodeCount: state.inviteCodeCount + 1);
    }

    _schedulePageRefresh();
  }

  Intervention? getIntervention(String interventionId) {
    return state.studyValueRequired.getIntervention(interventionId);
  }

  int getParticipantCountForInvite(StudyInvite invite) {
    return invite.participantCount;
  }

  // - IModelActionProvider

  @override
  List<ModelAction> availableActions(StudyInvite model) {
    final actions = state.inviteCodeRepository
        .availableActions(model)
        .where((action) => action.type != ModelActionType.share)
        .where((action) => action.type != ModelActionType.clipboard)
        .where((action) => action.type != ModelActionType.copyLink)
        .where((action) => action.type != ModelActionType.qrCodeShow)
        .map(_withPageRefresh)
        .toList();
    return withIcons(actions, modelActionIcons);
  }

  List<ModelAction> availableInlineActions(StudyInvite model) {
    final actions = state.inviteCodeRepository
        .availableActions(model)
        .where(
          (action) =>
              action.type == ModelActionType.copyLink ||
              action.type == ModelActionType.share,
        )
        .toList();
    return withIcons(actions, modelActionIcons);
  }

  ModelAction _withPageRefresh(ModelAction action) {
    if (action.type != ModelActionType.delete) {
      return action;
    }
    return ModelAction(
      type: action.type,
      label: action.label,
      tooltip: action.tooltip,
      isAvailable: action.isAvailable,
      isDestructive: action.isDestructive,
      isChecked: action.isChecked,
      showBadge: action.showBadge,
      confirmation: action.confirmation,
      onExecute: () async {
        await action.onExecute();
        _schedulePageRefresh();
      },
      onExecuteWithContext: action.onExecuteWithContext,
    );
  }

  void _schedulePageRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(const Duration(milliseconds: 300), () {
      unawaited(
        loadInviteCodePage(state.inviteCodePageIndex, showLoading: false),
      );
    });
  }
}

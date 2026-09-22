// Pagination controller tests must run on the browser platform: the
// dashboard controller transitively imports `lib/features/account/study_import.dart`
// (via study_repository.dart's action callbacks) which uses `dart:js_interop`.
// Run with: `flutter test --platform chrome test/features/dashboard/dashboard_controller_pagination_test.dart`.
@TestOn('browser')
library;

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/search.dart'
    as dashboard_search;
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_navigation.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_to_postgrest.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'dashboard_controller_pagination_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<StudyRepository>(),
  MockSpec<AuthRepository>(),
  MockSpec<UserRepository>(),
  MockSpec<sb.User>(),
])
Study _study(String id, {String? title}) {
  return Study.withId(id)
    ..id = id
    ..title = title ?? 'Study $id'
    ..status = StudyStatus.draft
    ..participation = Participation.invite
    ..resultSharing = ResultSharing.private
    ..registryPublished = false
    ..participantCount = 0
    ..activeSubjectCount = 0
    ..endedCount = 0;
}

class _Harness({
  Set<String> pinnedIds = const {},
  StudiesPage? initialPage,
  List<Study> initialPinned = const [],
  Object? pinnedError,
  ({String? sortColumn, bool? sortAscending}) activeSort = (
    sortColumn: null,
    sortAscending: null,
  ),
  StudiesFilter? initialFilter,
}) {
  this {
    studyRepo = MockStudyRepository();
    authRepo = MockAuthRepository();
    userRepo = MockUserRepository();
    user = MockUser();
    when(user.id).thenReturn('me');
    when(user.email).thenReturn('me@x.test');
    studyUUser = StudyUUser(
      id: 'me',
      email: 'me@x.test',
      preferences: Preferences(pinnedStudies: pinnedIds),
    );

    when(authRepo.currentUser).thenReturn(user);
    when(userRepo.fetchUser()).thenAnswer((_) async => studyUUser);
    when(userRepo.user).thenReturn(studyUUser);
    when(userRepo.getCustomPresets()).thenReturn(const []);
    when(userRepo.getActiveFilter(any))
        .thenReturn((presetId: null, filterGroup: null));
    when(userRepo.getActiveSort(any)).thenReturn(activeSort);

    final defaultPage =
        initialPage ?? const StudiesPage(studies: [], totalCount: 0);
    when(
      studyRepo.fetchPage(
        offset: anyNamed('offset'),
        limit: anyNamed('limit'),
        sortBy: anyNamed('sortBy'),
        ascending: anyNamed('ascending'),
        preset: anyNamed('preset'),
        currentUser: anyNamed('currentUser'),
        searchQuery: anyNamed('searchQuery'),
        advancedFilter: anyNamed('advancedFilter'),
        excludeIds: anyNamed('excludeIds'),
      ),
    ).thenAnswer((_) async => defaultPage);

    if (pinnedError == null) {
      when(studyRepo.fetchPinned(any)).thenAnswer((_) async => initialPinned);
    } else {
      when(studyRepo.fetchPinned(any)).thenThrow(pinnedError);
    }

    container = ProviderContainer(
      overrides: [
        studyRepositoryProvider.overrideWithValue(studyRepo),
        authRepositoryProvider.overrideWithValue(authRepo),
        userRepositoryProvider.overrideWithValue(userRepo),
        dashboardDispatchProvider.overrideWithValue((_) {}),
      ],
    );
    addTearDown(container.dispose);

    container.listen(
      dashboardControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    // Mirror DashboardScreen.initState — the widget always kicks off a
    // setStudiesFilter call (with widget.filter, possibly null) after build.
    // The controller itself no longer drives an initial fetch from build();
    // setStudiesFilter is the single load path.
    container
        .read(dashboardControllerProvider.notifier)
        .setStudiesFilter(initialFilter);
  }

  late final MockStudyRepository studyRepo;
  late final MockAuthRepository authRepo;
  late final MockUserRepository userRepo;
  late final MockUser user;
  late final StudyUUser studyUUser;
  late final ProviderContainer container;

  DashboardController get controller =>
      container.read(dashboardControllerProvider.notifier);

  DashboardState get state => container.read(dashboardControllerProvider);

  Completer<StudiesPage> holdPage() {
    final completer = Completer<StudiesPage>();
    when(
      studyRepo.fetchPage(
        offset: anyNamed('offset'),
        limit: anyNamed('limit'),
        sortBy: anyNamed('sortBy'),
        ascending: anyNamed('ascending'),
        preset: anyNamed('preset'),
        currentUser: anyNamed('currentUser'),
        searchQuery: anyNamed('searchQuery'),
        advancedFilter: anyNamed('advancedFilter'),
        excludeIds: anyNamed('excludeIds'),
      ),
    ).thenAnswer((_) => completer.future);
    return completer;
  }

  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }
}

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  group('DashboardController pagination', () {
    test('initial fetch requests page 0 with default params', () async {
      final h = _Harness(
        initialPage: StudiesPage(
          studies: List.generate(25, (i) => _study('s$i')),
          totalCount: 60,
        ),
      );
      await h.settle();

      verify(
        h.studyRepo.fetchPage(
          offset: 0,
          limit: DashboardState.pageSize,
          sortBy: StudiesTableColumn.createdAt,
          ascending: false,
          preset: StudiesFilter.owned,
          currentUser: h.user,
          searchQuery: '',
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).called(greaterThanOrEqualTo(1));

      expect(h.state.loadedStudies, hasLength(25));
      expect(h.state.totalCount, 60);
      expect(h.state.hasMore, isTrue);
      expect(h.state.isLoadingInitial, isFalse);
    });

    test('keeps the initial count loading until the total is known', () async {
      final h = _Harness();
      final pageCompleter = Completer<StudiesPage>();
      final totalCompleter = Completer<StudiesPage>();
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((invocation) {
        final limit = invocation.namedArguments[#limit] as int;
        return limit == 1 ? totalCompleter.future : pageCompleter.future;
      });

      await Future<void>.delayed(Duration.zero);
      pageCompleter.complete(
        StudiesPage(studies: [_study('s1')], totalCount: 4),
      );
      await h.settle();

      expect(h.state.loadedStudies, hasLength(1));
      expect(h.state.isLoadingInitial, isTrue);

      totalCompleter.complete(const StudiesPage(studies: [], totalCount: 4));
      await h.settle();

      expect(h.state.isLoadingInitial, isFalse);
      expect(h.state.displayTotalStudyCount, 4);
    });

    for (final change in ['sort', 'filter', 'search']) {
      test('$change retains rows until replacement results arrive', () async {
        final h = _Harness(
          initialFilter: StudiesFilter.all,
          pinnedIds: {'p'},
          initialPinned: [_study('p')],
          initialPage: StudiesPage(studies: [_study('a')], totalCount: 40),
        );
        await h.settle();
        final pending = h.holdPage();

        switch (change) {
          case 'sort':
            h.controller.setSorting(StudiesTableColumn.title, true);
          case 'filter':
            unawaited(
              h.controller.updateFilter(
                FilterGroup(
                  children: [
                    FilterCondition(
                      property: StudyProperty.participantCount,
                      operator: FilterOperator.greaterThan,
                      value: 5,
                    ),
                  ],
                ),
              ),
            );
          case 'search':
            await h.controller.filterStudies('no match');
            expect(h.state.displayedStudies.requireValue.map((s) => s.id), [
              'p',
              'a',
            ]);
            await Future<void>.delayed(const Duration(milliseconds: 350));
        }
        await h.settle();

        expect(h.state.isLoadingInitial, isFalse);
        expect(h.state.isRefreshing, isTrue);
        expect(h.state.displayedStudies.requireValue.map((s) => s.id), [
          'p',
          'a',
        ]);
        clearInteractions(h.studyRepo);
        await h.controller.loadMore();
        verifyZeroInteractions(h.studyRepo);

        pending.complete(const StudiesPage(studies: [], totalCount: 0));
        await h.settle();
        expect(h.state.isRefreshing, isFalse);
        expect(h.state.retainedStudies, isNull);
        expect(h.state.loadedStudies, isEmpty);
      });
    }

    test('failed search retains rows and retry replaces them', () async {
      final h = _Harness(
        initialPage: StudiesPage(studies: [_study('a')], totalCount: 1),
      );
      await h.settle();
      final pending = h.holdPage();
      await h.controller.filterStudies('no match');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final error = StateError('refresh failed');
      pending.completeError(error);
      await h.settle();

      expect(h.state.isRefreshing, isFalse);
      expect(h.state.loadError, same(error));
      expect(h.state.displayedStudies.requireValue.map((s) => s.id), ['a']);

      final retryPage = h.holdPage();
      final retry = h.controller.retry();
      expect(h.state.displayedStudies.requireValue.map((s) => s.id), ['a']);
      retryPage.complete(const StudiesPage(studies: [], totalCount: 0));
      await retry;
      expect(h.state.displayedStudies.requireValue, isEmpty);
      expect(h.state.loadError, isNull);
    });

    test(
      'unpin keeps the only row visible and blocks repeat actions',
      () async {
        final pinned = _study('p');
        final h = _Harness(
          initialFilter: StudiesFilter.all,
          pinnedIds: {'p'},
          initialPinned: [pinned],
        );
        await h.settle();
        final save = Completer<StudyUUser>();
        when(h.userRepo.updatePreferences(PreferenceAction.pinOff, 'p'))
            .thenAnswer((_) => save.future);
        final page = h.holdPage();

        final action = h.controller.pinOffStudy('p');
        await h.controller.pinOffStudy('p');
        expect(h.state.pendingStudyIds, {'p'});
        verify(h.userRepo.updatePreferences(PreferenceAction.pinOff, 'p'))
            .called(1);
        expect(h.state.displayedStudies.requireValue, [pinned]);

        h.studyUUser.preferences.pinnedStudies.clear();
        save.complete(h.studyUUser);
        await h.settle();
        expect(h.state.pinnedStudiesList, isEmpty);
        expect(h.state.isLoadingInitial, isFalse);
        expect(h.state.isRefreshing, isTrue);
        expect(h.state.pendingStudyIds, {'p'});
        expect(h.state.displayedStudies.requireValue, [pinned]);

        page.complete(StudiesPage(studies: [pinned], totalCount: 1));
        await action;
        expect(h.state.displayedStudies.requireValue, [pinned]);
        expect(h.state.isRefreshing, isFalse);
        expect(h.state.pendingStudyIds, isEmpty);
      },
    );

    test('failed pin keeps rows and releases the action lock', () async {
      final study = _study('a');
      final h = _Harness(
        initialPage: StudiesPage(studies: [study], totalCount: 1),
      );
      await h.settle();
      final error = StateError('save failed');
      when(h.userRepo.updatePreferences(PreferenceAction.pin, 'a'))
          .thenAnswer((_) => Future<StudyUUser>.error(error));

      await h.controller.pinStudy('a');
      expect(h.state.displayedStudies.requireValue, [study]);
      expect(h.state.pendingStudyIds, isEmpty);
      expect(h.state.loadError, same(error));
    });

    test(
      'duplicate stays busy through refresh and blocks repeat actions',
      () async {
        final study = _study('a');
        final h = _Harness(
          initialPage: StudiesPage(studies: [study], totalCount: 1),
        );
        await h.settle();
        final save = Completer<void>();
        var executions = 0;
        when(h.studyRepo.availableActions(study)).thenReturn([
          ModelAction(
            type: StudyActionType.duplicate,
            label: 'duplicate',
            onExecute: () {
              executions++;
              return save.future;
            },
          ),
        ]);
        final page = h.holdPage();
        final action = h.controller
            .availableActions(study)
            .firstWhere((action) => action.type == StudyActionType.duplicate);
        final execution = action.onExecute();
        await action.onExecute();
        expect(executions, 1);
        expect(h.state.pendingStudyIds, {'a'});

        save.complete();
        await h.settle();
        await action.onExecute();
        expect(executions, 1);
        expect(h.state.pendingStudyIds, {'a'});
        expect(h.state.displayedStudies.requireValue, [study]);

        page.complete(
          StudiesPage(studies: [study, _study('copy')], totalCount: 2),
        );
        await execution;
        expect(h.state.pendingStudyIds, isEmpty);
        expect(h.state.displayedStudies.requireValue, hasLength(2));
      },
    );

    test('hasMore is false when total <= loaded', () async {
      final h = _Harness(
        initialPage: StudiesPage(
          studies: List.generate(10, (i) => _study('s$i')),
          totalCount: 10,
        ),
      );
      await h.settle();
      expect(h.state.hasMore, isFalse);
    });

    test('loadMore appends next page with offset', () async {
      final h = _Harness();
      // First call: full page.
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer(
        (inv) async => StudiesPage(
          studies: List.generate(
            25,
            (i) => _study('s${(inv.namedArguments[#offset] as int) + i}'),
          ),
          totalCount: 60,
        ),
      );
      await h.settle();
      expect(h.state.loadedStudies.first.id, 's0');

      await h.controller.loadMore();
      await h.settle();

      expect(h.state.loadedStudies, hasLength(50));
      expect(h.state.loadedStudies[25].id, 's25');
      expect(h.state.hasMore, isTrue);
    });

    test('loadMore is a no-op when hasMore is false', () async {
      final h = _Harness(
        initialPage: StudiesPage(
          studies: List.generate(5, (i) => _study('s$i')),
          totalCount: 5,
        ),
      );
      await h.settle();
      clearInteractions(h.studyRepo);

      await h.controller.loadMore();
      await h.settle();

      verifyNever(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      );
    });

    test('loadMore is a no-op while a load is in flight', () async {
      final h = _Harness();
      final firstPage = StudiesPage(
        studies: List.generate(25, (i) => _study('s$i')),
        totalCount: 100,
      );
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((_) async => firstPage);
      await h.settle();
      clearInteractions(h.studyRepo);

      // Hold the next page open via a manual completer.
      final completer = Completer<StudiesPage>();
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((_) => completer.future);

      // Two rapid loadMore calls — only the first should hit the repo.
      final firstLoad = h.controller.loadMore();
      final secondLoad = h.controller.loadMore();
      await Future<void>.delayed(Duration.zero);

      verify(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).called(1);

      completer.complete(
        StudiesPage(
          studies: List.generate(25, (i) => _study('p${i + 25}')),
          totalCount: 100,
        ),
      );
      await Future.wait([firstLoad, secondLoad]);
    });

    test('setSorting resets pagination and reloads with new sort', () async {
      final h = _Harness(
        initialPage: StudiesPage(
          studies: List.generate(25, (i) => _study('s$i')),
          totalCount: 100,
        ),
      );
      await h.settle();
      clearInteractions(h.studyRepo);

      h.controller.setSorting(StudiesTableColumn.title, true);
      await h.settle();

      verify(
        h.studyRepo.fetchPage(
          offset: 0,
          limit: DashboardState.pageSize,
          sortBy: StudiesTableColumn.title,
          ascending: true,
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).called(1);
      expect(h.state.sortByColumn, StudiesTableColumn.title);
      expect(h.state.sortAscending, isTrue);
    });

    test(
      'setStudiesFilter resets pagination and reloads with new preset',
      () async {
        final h = _Harness();
        await h.settle();
        clearInteractions(h.studyRepo);

        await h.controller.setStudiesFilter(StudiesFilter.public);
        await h.settle();

        verify(
          h.studyRepo.fetchPage(
            offset: 0,
            limit: DashboardState.pageSize,
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: StudiesFilter.public,
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        ).called(1);
        expect(h.state.studiesFilter, StudiesFilter.public);
      },
    );

    test('search query change is debounced before triggering reload', () {
      fakeAsync((async) {
        final h = _Harness();
        async.flushMicrotasks();
        clearInteractions(h.studyRepo);

        h.controller.filterStudies('foo');
        async.elapse(const Duration(milliseconds: 50));
        verifyNever(
          h.studyRepo.fetchPage(
            offset: anyNamed('offset'),
            limit: anyNamed('limit'),
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        );

        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();
        verify(
          h.studyRepo.fetchPage(
            offset: 0,
            limit: anyNamed('limit'),
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: 'foo',
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        ).called(1);
      });
    });

    test('rapid keystrokes only trigger one fetch (debounce coalesces)', () {
      fakeAsync((async) {
        final h = _Harness();
        async.flushMicrotasks();
        clearInteractions(h.studyRepo);

        h.controller.filterStudies('f');
        async.elapse(const Duration(milliseconds: 50));
        h.controller.filterStudies('fo');
        async.elapse(const Duration(milliseconds: 50));
        h.controller.filterStudies('foo');
        async.elapse(const Duration(milliseconds: 301));
        async.flushMicrotasks();

        verify(
          h.studyRepo.fetchPage(
            offset: anyNamed('offset'),
            limit: anyNamed('limit'),
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: 'foo',
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        ).called(1);
      });
    });

    test('stale fetch responses are discarded by token mechanism', () async {
      final h = _Harness();
      await h.settle();
      clearInteractions(h.studyRepo);

      // First reload (filter=public) — will be intentionally slow.
      final slowCompleter = Completer<StudiesPage>();
      // Second reload (filter=all) — fast.
      final fastPage = StudiesPage(
        studies: [_study('fast1'), _study('fast2')],
        totalCount: 2,
      );

      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((invocation) {
        final limit = invocation.namedArguments[#limit] as int;
        final preset = invocation.namedArguments[#preset] as StudiesFilter;
        if (limit == DashboardState.pageSize &&
            preset == StudiesFilter.public) {
          return slowCompleter.future;
        }
        return Future.value(fastPage);
      });

      // Kick off the slow reload.
      h.controller.setStudiesFilter(StudiesFilter.public);
      await Future<void>.delayed(Duration.zero);

      // Trigger the second reload while the first is still pending.
      h.controller.setStudiesFilter(StudiesFilter.all);
      await h.settle();

      expect(h.state.loadedStudies.map((s) => s.id), ['fast1', 'fast2']);

      // Now resolve the slow first call — its result must NOT overwrite state.
      slowCompleter.complete(
        StudiesPage(studies: [_study('slow1'), _study('slow2')], totalCount: 2),
      );
      await h.settle();
      expect(h.state.loadedStudies.map((s) => s.id), ['fast1', 'fast2']);
    });

    test('in-flight fetches do not update state after disposal', () async {
      final studyRepo = MockStudyRepository();
      final authRepo = MockAuthRepository();
      final userRepo = MockUserRepository();
      final user = MockUser();
      final studyUUser = StudyUUser(
        id: 'me',
        email: 'me@x.test',
        preferences: Preferences(),
      );
      when(user.id).thenReturn('me');
      when(user.email).thenReturn('me@x.test');
      when(authRepo.currentUser).thenReturn(user);
      when(userRepo.fetchUser()).thenAnswer((_) async => studyUUser);
      when(userRepo.user).thenReturn(studyUUser);
      when(userRepo.getCustomPresets()).thenReturn(const []);
      when(userRepo.getActiveFilter(any))
          .thenReturn((presetId: null, filterGroup: null));
      when(userRepo.getActiveSort(any))
          .thenReturn((sortColumn: null, sortAscending: null));
      final pageCompleter = Completer<StudiesPage>();
      when(
        studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((_) => pageCompleter.future);

      final container = ProviderContainer(
        overrides: [
          studyRepositoryProvider.overrideWithValue(studyRepo),
          authRepositoryProvider.overrideWithValue(authRepo),
          userRepositoryProvider.overrideWithValue(userRepo),
          dashboardDispatchProvider.overrideWithValue((_) {}),
        ],
      );
      final subscription = container.listen(
        dashboardControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      final loading = container
          .read(dashboardControllerProvider.notifier)
          .setStudiesFilter(null);
      await Future<void>.delayed(Duration.zero);

      subscription.close();
      container.dispose();
      pageCompleter.complete(const StudiesPage(studies: [], totalCount: 0));

      await loading;
    });

    test(
      'UnsupportedFilterException flips advancedFilterUnsupported',
      () async {
        final h = _Harness();
        await h.settle();
        clearInteractions(h.studyRepo);

        when(
          h.studyRepo.fetchPage(
            offset: anyNamed('offset'),
            limit: anyNamed('limit'),
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        ).thenAnswer(
          (_) async => throw const UnsupportedFilterException('unsupported'),
        );

        await h.controller.updateFilter(
          FilterGroup(
            children: [
              FilterCondition(
                property: StudyProperty.participantCount,
                operator: FilterOperator.greaterThan,
                value: 5,
              ),
            ],
          ),
        );
        await h.settle();

        expect(h.state.advancedFilterUnsupported, isTrue);
        expect(h.state.loadedStudies, isEmpty);
        expect(h.state.hasMore, isFalse);
      },
    );

    test('pinStudy moves a loaded study locally without reloading', () async {
      final h = _Harness(
        initialPage: StudiesPage(
          studies: [_study('a'), _study('b'), _study('c')],
          totalCount: 3,
        ),
      );
      await h.settle();

      var currentUser = h.studyUUser;
      when(h.userRepo.user).thenAnswer((_) => currentUser);
      final updatedUser = StudyUUser(
        id: 'me',
        email: 'me@x.test',
        preferences: Preferences(pinnedStudies: {'b'}),
      );
      when(h.userRepo.updatePreferences(any, any)).thenAnswer((_) async {
        currentUser = updatedUser;
        return updatedUser;
      });
      clearInteractions(h.studyRepo);

      await h.controller.pinStudy('b');

      expect(h.state.loadedStudies.map((s) => s.id), ['a', 'c']);
      expect(h.state.pinnedStudiesList.map((s) => s.id), ['b']);
      expect(h.state.totalCount, 2);
      expect(h.state.pageTotalCount, 2);
      expect(h.state.hasMore, isFalse);
      verifyNever(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      );
      verifyNever(h.studyRepo.fetchPinned(any));
    });

    test('pinStudy reloads when the study is not loaded', () async {
      final h = _Harness(
        initialPage: StudiesPage(
          studies: [_study('a'), _study('b')],
          totalCount: 2,
        ),
      );
      await h.settle();

      var currentUser = h.studyUUser;
      when(h.userRepo.user).thenAnswer((_) => currentUser);
      final updatedUser = StudyUUser(
        id: 'me',
        email: 'me@x.test',
        preferences: Preferences(pinnedStudies: {'missing'}),
      );
      when(h.userRepo.updatePreferences(any, any)).thenAnswer((_) async {
        currentUser = updatedUser;
        return updatedUser;
      });
      when(h.studyRepo.fetchPinned(any))
          .thenAnswer((_) async => [_study('missing')]);
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer(
        (_) async =>
            StudiesPage(studies: [_study('a'), _study('b')], totalCount: 2),
      );
      clearInteractions(h.studyRepo);

      await h.controller.pinStudy('missing');
      await h.settle();

      verify(h.studyRepo.fetchPinned(any)).called(1);
      verify(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).called(greaterThanOrEqualTo(1));
      expect(h.state.pinnedStudiesList.map((s) => s.id), ['missing']);
    });

    test('pinOffStudy reloads the unpinned study in server order', () async {
      final h = _Harness(
        pinnedIds: {'p'},
        initialPage: StudiesPage(studies: [_study('a')], totalCount: 1),
        initialPinned: [_study('p')],
      );
      await h.settle();

      var currentUser = h.studyUUser;
      when(h.userRepo.user).thenAnswer((_) => currentUser);
      final updatedUser = StudyUUser(
        id: 'me',
        email: 'me@x.test',
        preferences: Preferences(),
      );
      when(h.userRepo.updatePreferences(any, any)).thenAnswer((_) async {
        currentUser = updatedUser;
        return updatedUser;
      });
      when(h.studyRepo.fetchPinned(any)).thenAnswer((_) async => const []);
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer(
        (_) async =>
            StudiesPage(studies: [_study('p'), _study('a')], totalCount: 2),
      );
      clearInteractions(h.studyRepo);

      await h.controller.pinOffStudy('p');
      await h.settle();

      verify(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).called(greaterThanOrEqualTo(1));
      expect(h.state.pinnedStudiesList, isEmpty);
      expect(h.state.loadedStudies.map((s) => s.id), ['p', 'a']);
    });

    test(
      'initial fetch excludes pinned ids from the paginated query',
      () async {
        final h = _Harness(
          pinnedIds: {'pinA', 'pinB'},
          initialPinned: [_study('pinA'), _study('pinB')],
        );
        await h.settle();

        final captured = verify(
          h.studyRepo.fetchPage(
            offset: 0,
            limit: anyNamed('limit'),
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: captureAnyNamed('excludeIds'),
          ),
        ).captured;
        final excludeIds = captured.last as List<String>;
        expect(excludeIds, containsAll(<String>['pinA', 'pinB']));
        expect(h.state.pinnedStudiesList.map((s) => s.id), ['pinA', 'pinB']);
      },
    );

    test(
      'pinned fetch failure keeps pinned studies in the page query',
      () async {
        final pinnedError = StateError('pinned fetch failed');
        final h = _Harness(
          pinnedIds: {'pin'},
          pinnedError: pinnedError,
          initialPage: StudiesPage(
            studies: [_study('pin'), _study('other')],
            totalCount: 2,
          ),
        );
        await h.settle();

        final captured = verify(
          h.studyRepo.fetchPage(
            offset: anyNamed('offset'),
            limit: anyNamed('limit'),
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: captureAnyNamed('excludeIds'),
          ),
        ).captured.cast<List<String>>();

        expect(captured, everyElement(isEmpty));
        expect(h.state.loadedStudies.map((study) => study.id), [
          'pin',
          'other',
        ]);
        expect(h.state.loadError, same(pinnedError));
      },
    );

    test(
      'page count failure preserves its previous value and is retryable',
      () async {
        final h = _Harness(
          initialPage: StudiesPage(
            studies: [_study('a'), _study('b')],
            totalCount: 3,
          ),
        );
        await h.settle();
        expect(h.state.pageTotalCount, 3);

        final countError = StateError('count failed');
        when(
          h.studyRepo.fetchPage(
            offset: anyNamed('offset'),
            limit: anyNamed('limit'),
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        ).thenAnswer((invocation) {
          if (invocation.namedArguments[#limit] == 1) {
            return Future<StudiesPage>.error(countError);
          }
          return Future.value(
            StudiesPage(studies: [_study('a'), _study('b')], totalCount: 3),
          );
        });

        await h.controller.retry();
        await h.settle();

        expect(h.state.pageTotalCount, 3);
        expect(h.state.loadError, same(countError));
      },
    );

    test('displayedStudies filters pinned rows like paginated rows', () {
      final user = MockUser();
      when(user.id).thenReturn('me');
      when(user.email).thenReturn('me@x.test');

      final matching = _study('matching', title: 'Target public')
        ..registryPublished = true
        ..participantCount = 10;
      final wrongPreset = _study('wrong-preset', title: 'Target private')
        ..participantCount = 10;
      final wrongSearch = _study('wrong-search', title: 'Other public')
        ..registryPublished = true
        ..participantCount = 10;
      final wrongFilter = _study('wrong-filter', title: 'Target public low')
        ..registryPublished = true
        ..participantCount = 1;
      final pageStudy = _study('page');

      final state = DashboardState(
        currentUser: user,
        searchController: dashboard_search.SearchController(),
        studiesFilter: StudiesFilter.public,
        query: 'target',
        activeFilter: FilterGroup(
          children: [
            FilterCondition(
              property: StudyProperty.participantCount,
              operator: FilterOperator.greaterThan,
              value: 5,
            ),
          ],
        ),
        pinnedStudiesList: [matching, wrongPreset, wrongSearch, wrongFilter],
        loadedStudies: [pageStudy],
        isLoadingInitial: false,
      );

      expect(state.displayedStudies.requireValue.map((study) => study.id), [
        'matching',
      ]);
    });

    test('displayedStudies stays on the data path when the load failed', () {
      final user = MockUser();
      when(user.id).thenReturn('me');
      when(user.email).thenReturn('me@x.test');

      final state = DashboardState(
        currentUser: user,
        searchController: dashboard_search.SearchController(),
        isLoadingInitial: false,
        loadError: () => StateError('fetch failed'),
      );

      // Regression: returning AsyncValue.error here let the default
      // AsyncValueWidget error builder show a raw exception string and
      // hid the localized unsupported-filter/retry notices.
      expect(state.displayedStudies.hasValue, isTrue);
      expect(state.displayedStudies.requireValue, isEmpty);
    });

    test('setSorting persists sort to user preferences', () async {
      final h = _Harness();
      when(
        h.userRepo.saveActiveSort(
          page: anyNamed('page'),
          sortColumn: anyNamed('sortColumn'),
          sortAscending: anyNamed('sortAscending'),
        ),
      ).thenAnswer((_) async => h.studyUUser);
      await h.settle();

      h.controller.setSorting(StudiesTableColumn.title, true);
      await h.settle();

      verify(
        h.userRepo.saveActiveSort(
          page: 'my_studies',
          sortColumn: 'title',
          sortAscending: true,
        ),
      ).called(1);
    });

    test(
      'initial load restores persisted sort and uses it for fetch',
      () async {
        final h = _Harness(
          activeSort: (sortColumn: 'title', sortAscending: true),
        );
        await h.settle();

        expect(h.state.sortByColumn, StudiesTableColumn.title);
        expect(h.state.sortAscending, isTrue);
        verify(
          h.studyRepo.fetchPage(
            offset: 0,
            limit: anyNamed('limit'),
            sortBy: StudiesTableColumn.title,
            ascending: true,
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    test('unknown persisted sort column falls back to default', () async {
      final h = _Harness(
        activeSort: (sortColumn: 'someRemovedColumn', sortAscending: true),
      );
      await h.settle();

      expect(h.state.sortByColumn, StudiesTableColumn.createdAt);
      expect(h.state.sortAscending, isFalse);
    });

    test('controller does not double-fetch on first build (no race with '
        'setStudiesFilter)', () async {
      // Regression: previously, build() -> _loadInitial -> _resetAndReload
      // raced against initState's setStudiesFilter(widget.filter), firing
      // two HTTP fetches per navigation. The fix routes the single load
      // through setStudiesFilter only.
      final h = _Harness();
      await h.settle();

      verify(
        h.studyRepo.fetchPage(
          offset: 0,
          limit: DashboardState.pageSize,
          sortBy: StudiesTableColumn.createdAt,
          ascending: false,
          preset: StudiesFilter.owned,
          currentUser: h.user,
          searchQuery: '',
        ),
      ).called(1);
      verify(
        h.studyRepo.fetchPage(
          offset: 0,
          limit: 1,
          sortBy: StudiesTableColumn.createdAt,
          ascending: false,
          preset: StudiesFilter.owned,
          currentUser: h.user,
        ),
      ).called(1);
    });

    test('delete keeps list populated while refresh is in flight', () async {
      final firstStudy = _study('s1');
      final secondStudy = _study('s2');
      final h = _Harness(
        initialPage: StudiesPage(
          studies: [firstStudy, secondStudy],
          totalCount: 2,
        ),
      );
      await h.settle();
      clearInteractions(h.studyRepo);

      when(h.studyRepo.availableActions(firstStudy)).thenReturn([
        ModelAction(
          type: StudyActionType.delete,
          label: 'delete',
          onExecute: () {},
        ),
      ]);

      final pageCompleter = Completer<StudiesPage>();
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((invocation) {
        final limit = invocation.namedArguments[#limit] as int;
        return limit == 1
            ? Future.value(const StudiesPage(studies: [], totalCount: 1))
            : pageCompleter.future;
      });

      final deleteAction = h.controller
          .availableActions(firstStudy)
          .firstWhere((action) => action.type == StudyActionType.delete);

      deleteAction.onExecute();
      await h.settle();

      expect(h.state.loadedStudies.map((study) => study.id), ['s2']);
      expect(h.state.isLoadingInitial, isFalse);

      pageCompleter.complete(
        StudiesPage(studies: [secondStudy], totalCount: 1),
      );
      await h.settle();

      expect(h.state.loadedStudies.map((study) => study.id), ['s2']);
      expect(h.state.totalCount, 1);
    });

    test('deleting a pinned study does not decrement page counts', () async {
      final pinnedStudy = _study('pinned');
      final pageStudy = _study('page');
      final h = _Harness(
        pinnedIds: {'pinned'},
        initialPinned: [pinnedStudy],
        initialPage: StudiesPage(studies: [pageStudy], totalCount: 1),
      );
      await h.settle();
      clearInteractions(h.studyRepo);

      var currentUser = h.studyUUser;
      when(h.userRepo.user).thenAnswer((_) => currentUser);
      when(h.studyRepo.availableActions(pinnedStudy)).thenReturn([
        ModelAction(
          type: StudyActionType.delete,
          label: 'delete',
          onExecute: () {
            currentUser = StudyUUser(
              id: 'me',
              email: 'me@x.test',
              preferences: Preferences(),
            );
          },
        ),
      ]);
      final pageCompleter = Completer<StudiesPage>();
      when(
        h.studyRepo.fetchPage(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
          preset: anyNamed('preset'),
          currentUser: anyNamed('currentUser'),
          searchQuery: anyNamed('searchQuery'),
          advancedFilter: anyNamed('advancedFilter'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((invocation) {
        if (invocation.namedArguments[#limit] == 1) {
          return Future.value(const StudiesPage(studies: [], totalCount: 1));
        }
        return pageCompleter.future;
      });

      final action = h.controller
          .availableActions(pinnedStudy)
          .firstWhere((action) => action.type == StudyActionType.delete);
      final execution = action.onExecute();
      await h.settle();

      expect(h.state.pinnedStudiesList, isEmpty);
      expect(h.state.totalCount, 1);
      expect(h.state.pageTotalCount, 1);

      pageCompleter.complete(StudiesPage(studies: [pageStudy], totalCount: 1));
      await execution;
    });

    test('duplicate action failures update loadError', () async {
      final study = _study('study');
      final error = StateError('duplicate failed');
      final h = _Harness(
        initialPage: StudiesPage(studies: [study], totalCount: 1),
      );
      await h.settle();
      when(h.studyRepo.availableActions(study)).thenReturn([
        ModelAction(
          type: StudyActionType.duplicate,
          label: 'duplicate',
          onExecute: () => Future<void>.error(error),
        ),
      ]);

      final action = h.controller
          .availableActions(study)
          .firstWhere((action) => action.type == StudyActionType.duplicate);
      await action.onExecute();

      expect(h.state.loadError, same(error));
    });

    test(
      'duplicate refresh keeps current row budget instead of first-page reset',
      () async {
        final studies = List.generate(25, (i) => _study('s$i'));
        final h = _Harness(
          initialPage: StudiesPage(studies: studies, totalCount: 80),
        );
        await h.settle();
        clearInteractions(h.studyRepo);

        when(h.studyRepo.availableActions(studies.first)).thenReturn([
          ModelAction(
            type: StudyActionType.duplicate,
            label: 'duplicate',
            onExecute: () {},
          ),
        ]);

        when(
          h.studyRepo.fetchPage(
            offset: anyNamed('offset'),
            limit: anyNamed('limit'),
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        ).thenAnswer(
          (_) async => StudiesPage(studies: studies, totalCount: 81),
        );

        final duplicateAction = h.controller
            .availableActions(studies.first)
            .firstWhere((action) => action.type == StudyActionType.duplicate);

        await duplicateAction.onExecute();
        await h.settle();

        verify(
          h.studyRepo.fetchPage(
            offset: 0,
            limit: 25,
            sortBy: anyNamed('sortBy'),
            ascending: anyNamed('ascending'),
            preset: anyNamed('preset'),
            currentUser: anyNamed('currentUser'),
            searchQuery: anyNamed('searchQuery'),
            advancedFilter: anyNamed('advancedFilter'),
            excludeIds: anyNamed('excludeIds'),
          ),
        ).called(1);
        expect(h.state.loadedStudies, hasLength(25));
        expect(h.state.isLoadingInitial, isFalse);
      },
    );
  });
}

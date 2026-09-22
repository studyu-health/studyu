@TestOn('browser')
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

import 'study_repository_test.mocks.dart';

Study _study(String id, {StudyStatus status = StudyStatus.draft}) {
  return Study(id, 'me')
    ..title = 'Study $id'
    ..status = status;
}

class _Harness() {
  this {
    apiClient = MockStudyUApiClient();
    authRepository = MockAuthRepository();
    router = MockGoRouter();
    user = MockUser();
    when(user.id).thenReturn('me');
    when(user.email).thenReturn('me@example.com');
    when(authRepository.currentUser).thenReturn(user);

    container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(apiClient),
        authRepositoryProvider.overrideWithValue(authRepository),
        routerProvider.overrideWithValue(router),
      ],
    );
    addTearDown(container.dispose);
    subscription = container.listen(
      studyRepositoryProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    repository = subscription.read();
  }

  late final MockStudyUApiClient apiClient;
  late final MockAuthRepository authRepository;
  late final MockGoRouter router;
  late final MockUser user;
  late final ProviderContainer container;
  late final ProviderSubscription<StudyRepository> subscription;
  late final StudyRepository repository;
}

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  test(
    'dashboard page fetch caches studies and marks them as fetched',
    () async {
      final h = _Harness();
      final study = _study('page');
      when(
        h.apiClient.getUserStudiesPage(
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
      ).thenAnswer((_) async => StudiesPage(studies: [study], totalCount: 1));

      final page = await h.repository.fetchPage(
        offset: 0,
        limit: 20,
        sortBy: StudiesTableColumn.createdAt,
        ascending: false,
        preset: StudiesFilter.owned,
        currentUser: h.user,
      );

      expect(page.studies, [study]);
      final cached = h.repository.get(study.id)!;
      expect(cached.model, same(study));
      expect(cached.isLocalOnly, isFalse);
      expect(cached.lastFetched, isNotNull);
    },
  );

  test('pinned fetch caches studies and marks them as fetched', () async {
    final h = _Harness();
    final study = _study('pinned');
    when(h.apiClient.getPinnedUserStudies(pinnedIds: {'pinned'}))
        .thenAnswer((_) async => [study]);

    final studies = await h.repository.fetchPinned({'pinned'});

    expect(studies, [study]);
    final cached = h.repository.get(study.id)!;
    expect(cached.model, same(study));
    expect(cached.isLocalOnly, isFalse);
    expect(cached.lastFetched, isNotNull);
  });

  test('dashboard duplicate actions do not redirect back to studies', () async {
    final h = _Harness();
    final studies = [
      _study('draft'),
      _study('running', status: StudyStatus.running),
    ];
    when(h.apiClient.fetchStudy(any)).thenAnswer(
      (invocation) async => _study(
        invocation.positionalArguments.single as String,
        status: studies
            .singleWhere(
              (study) =>
                  study.id == invocation.positionalArguments.single as String,
            )
            .status,
      ),
    );
    when(h.apiClient.saveStudy(any)).thenAnswer(
      (invocation) async => invocation.positionalArguments.single as Study,
    );

    for (final study in studies) {
      final type = study.status == StudyStatus.draft
          ? StudyActionType.duplicate
          : StudyActionType.duplicateDraft;
      final action = h.repository
          .availableActions(study)
          .singleWhere((action) => action.type == type);
      await action.onExecute();
    }

    verifyNever(
      h.router.goNamed(
        RoutingIntents.studies.routeName,
        pathParameters: anyNamed('pathParameters'),
        queryParameters: anyNamed('queryParameters'),
        extra: anyNamed('extra'),
      ),
    );
  });

  test(
    'duplicateAndSave waits for backend persistence before returning',
    () async {
      final h = _Harness();
      final study = _study('study');
      when(h.apiClient.fetchStudy(study.id)).thenAnswer((_) async => study);
      final persistence = Completer<Study>();
      late Study duplicate;
      when(h.apiClient.saveStudy(any)).thenAnswer((invocation) {
        duplicate = invocation.positionalArguments.single as Study;
        return persistence.future;
      });

      var completed = false;
      final duplication = h.repository.duplicateAndSave(study).then((_) {
        completed = true;
      });
      await Future<void>.delayed(Duration.zero);

      expect(completed, isFalse);
      persistence.complete(duplicate);
      await duplication;
      expect(completed, isTrue);
    },
  );
}

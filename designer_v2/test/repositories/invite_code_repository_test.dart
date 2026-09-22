@TestOn('browser')
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/model_repository_events.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';

final _refProvider = Provider<Ref>((ref) => ref);

class _MockAuthRepository() extends Mock implements IAuthRepository;

class _FakeStudyRepository(Study study) implements IStudyRepository {
  final WrappedModel<Study> _study = WrappedModel(study);

  @override
  WrappedModel<Study>? get(ModelID modelId, {bool strict = false}) => _study;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeApiClient() implements StudyUApi {
  final pages = <List<StudyInvite>>[];
  final deletedInvites = <StudyInvite>[];

  @override
  Future<List<StudyInvite>> fetchStudyInvitesPage(
    StudyID studyId, {
    required int offset,
    required int limit,
    String? query,
    InviteCodesSortColumn sortBy = InviteCodesSortColumn.code,
    bool ascending = true,
  }) async => pages.removeAt(0);

  @override
  Future<void> deleteStudyInvite(StudyInvite invite) async {
    deletedInvites.add(invite);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Study study;
  late _FakeApiClient apiClient;
  late ProviderContainer container;
  late InviteCodeRepository repository;

  setUp(() {
    study = Study('study-id', 'owner-id');
    apiClient = _FakeApiClient();
    container = ProviderContainer();
    repository = InviteCodeRepository(
      studyId: study.id,
      apiClient: apiClient,
      authRepository: _MockAuthRepository(),
      studyRepository: _FakeStudyRepository(study),
      ref: container.read(_refProvider),
    );
  });

  tearDown(() {
    repository.dispose();
    container.dispose();
  });

  test(
    'page cache evicts stale invites and preserves shared wrappers',
    () async {
      final firstA = StudyInvite('invite-a', study.id);
      final firstB = StudyInvite('invite-b', study.id);
      final nextB = StudyInvite('invite-b', study.id);
      final nextC = StudyInvite('invite-c', study.id);
      apiClient.pages.addAll([
        [firstA, firstB],
        [nextB, nextC],
      ]);

      await repository.fetchPage(offset: 0, limit: 2);
      final firstBWrapper = repository.get(firstB.code);

      await repository.fetchPage(offset: 2, limit: 2);

      expect(repository.get(firstA.code), isNull);
      expect(repository.get(nextB.code), same(firstBWrapper));
      expect(repository.get(nextC.code), isNotNull);
    },
  );

  test('page cache retains watched invites until the next refresh', () async {
    final watchedInvite = StudyInvite('invite-a', study.id);
    final nextInvite = StudyInvite('invite-b', study.id);
    apiClient.pages.addAll([
      [watchedInvite],
      [nextInvite],
      [nextInvite],
    ]);

    await repository.fetchPage(offset: 0, limit: 1);
    final watchedWrapper = repository.get(watchedInvite.code);
    final subscription = repository
        .watch(watchedInvite.code, fetchOnSubscribe: false)
        .listen((_) {});

    await repository.fetchPage(offset: 1, limit: 1);
    expect(repository.get(watchedInvite.code), same(watchedWrapper));

    await subscription.cancel();
    await repository.fetchPage(offset: 1, limit: 1);
    expect(repository.get(watchedInvite.code), isNull);
  });

  test('delete uses the API and emits IsDeleted', () async {
    final invite = StudyInvite('invite-a', study.id);
    apiClient.pages.add([invite]);
    await repository.fetchPage(offset: 0, limit: 1);
    final deletedEvent = repository.watchAllChanges().firstWhere(
      (event) => event is IsDeleted<StudyInvite>,
    );

    await repository.delete(invite.code, runOptimistically: false);

    expect(apiClient.deletedInvites, [invite]);
    expect(await deletedEvent, isA<IsDeleted<StudyInvite>>());
    expect(repository.get(invite.code), isNull);
    expect(study.invites, isNull);
  });

  test('dispose closes all model change streams', () async {
    final allChangesSubscription = repository.watchAllChanges().listen((_) {});
    final inviteChangesSubscription = repository
        .watchChanges('invite-a')
        .listen((_) {});
    final allChangesDone = allChangesSubscription.asFuture<void>();
    final inviteChangesDone = inviteChangesSubscription.asFuture<void>();

    repository.dispose();

    await Future.wait([allChangesDone, inviteChangesDone]);
    await allChangesSubscription.cancel();
    await inviteChangesSubscription.cancel();
  });
}

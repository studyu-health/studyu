import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/deep_link_service.dart';
import 'package:studyu_core/core.dart';

void main() {
  tearDown(DeepLinkService.resetTestOverrides);

  Study study({String id = 'study-123'}) {
    return Study(id, 'owner-123')
      ..title = 'Invite study'
      ..participation = Participation.invite;
  }

  group('DeepLinkService.processDeepLink study links', () {
    test(
      'returns study not found with attempted ID when lookup misses',
      () async {
        DeepLinkService.fetchStudyForDeepLink = (_) async => null;

        final result = await DeepLinkService.processDeepLink(
          studyId: 'missing-study',
          inviteCode: null,
          isAuthenticated: true,
        );

        expect(result, isA<DeepLinkError>());
        final error = result as DeepLinkError;
        expect(error.type, DeepLinkErrorType.studyNotFound);
        expect(error.errorValue, 'missing-study');
      },
    );

    test('returns needs auth for an unauthenticated user', () async {
      final targetStudy = study()..participation = Participation.open;
      DeepLinkService.fetchStudyForDeepLink = (_) async => targetStudy;

      final result = await DeepLinkService.processDeepLink(
        studyId: targetStudy.id,
        inviteCode: null,
        isAuthenticated: false,
      );

      expect(result, isA<DeepLinkNeedsAuth>());
      expect((result as DeepLinkNeedsAuth).study, same(targetStudy));
    });

    test('rejects invite-only studies', () async {
      final targetStudy = study();
      DeepLinkService.fetchStudyForDeepLink = (_) async => targetStudy;

      final result = await DeepLinkService.processDeepLink(
        studyId: targetStudy.id,
        inviteCode: null,
        isAuthenticated: true,
      );

      expect(result, isA<DeepLinkError>());
      final error = result as DeepLinkError;
      expect(error.type, DeepLinkErrorType.inviteOnly);
      expect(error.errorValue, targetStudy.id);
    });

    test('marks a public study as already enrolled', () async {
      final targetStudy = study()..participation = Participation.open;
      DeepLinkService.fetchStudyForDeepLink = (_) async => targetStudy;

      final result = await DeepLinkService.processDeepLink(
        studyId: targetStudy.id,
        inviteCode: null,
        isAuthenticated: true,
        activeStudyId: targetStudy.id,
      );

      expect(result, isA<DeepLinkSuccess>());
      final success = result as DeepLinkSuccess;
      expect(success.study, same(targetStudy));
      expect(success.alreadyEnrolled, isTrue);
    });

    test('returns success for an authenticated public study', () async {
      final targetStudy = study()..participation = Participation.open;
      DeepLinkService.fetchStudyForDeepLink = (_) async => targetStudy;

      final result = await DeepLinkService.processDeepLink(
        studyId: targetStudy.id,
        inviteCode: null,
        isAuthenticated: true,
      );

      expect(result, isA<DeepLinkSuccess>());
      final success = result as DeepLinkSuccess;
      expect(success.study, same(targetStudy));
      expect(success.alreadyEnrolled, isFalse);
    });
  });

  group('DeepLinkService.processDeepLink invite links', () {
    test(
      'returns needs auth with invite details when user is not authenticated',
      () async {
        final targetStudy = study();
        DeepLinkService.fetchInviteForDeepLink = (_) async => (
          StudyInvite('invite-123', targetStudy.id)
            ..preselectedInterventionIds = ['intervention-a'],
          targetStudy,
        );

        final result = await DeepLinkService.processDeepLink(
          studyId: null,
          inviteCode: 'invite-123',
          isAuthenticated: false,
        );

        expect(result, isA<DeepLinkNeedsAuth>());
        final needsAuth = result as DeepLinkNeedsAuth;
        expect(needsAuth.study, same(targetStudy));
        expect(needsAuth.inviteCode, 'invite-123');
        expect(needsAuth.preselectedInterventionIds, ['intervention-a']);
      },
    );

    test(
      'returns success with invite details when user is authenticated',
      () async {
        final targetStudy = study();
        DeepLinkService.fetchInviteForDeepLink = (_) async => (
          StudyInvite('invite-123', targetStudy.id)
            ..preselectedInterventionIds = ['intervention-a'],
          targetStudy,
        );

        final result = await DeepLinkService.processDeepLink(
          studyId: null,
          inviteCode: 'invite-123',
          isAuthenticated: true,
        );

        expect(result, isA<DeepLinkSuccess>());
        final success = result as DeepLinkSuccess;
        expect(success.study, same(targetStudy));
        expect(success.inviteCode, 'invite-123');
        expect(success.preselectedInterventionIds, ['intervention-a']);
        expect(success.alreadyEnrolled, isFalse);
      },
    );

    test('marks invite success as already enrolled for active study', () async {
      final targetStudy = study();
      DeepLinkService.fetchInviteForDeepLink = (_) async =>
          (StudyInvite('invite-123', targetStudy.id), targetStudy);

      final result = await DeepLinkService.processDeepLink(
        studyId: null,
        inviteCode: 'invite-123',
        isAuthenticated: true,
        activeStudyId: targetStudy.id,
      );

      expect(result, isA<DeepLinkSuccess>());
      expect((result as DeepLinkSuccess).alreadyEnrolled, isTrue);
    });

    test(
      'returns invalid invite with attempted code when invite lookup misses',
      () async {
        DeepLinkService.fetchInviteForDeepLink = (_) async => (null, null);

        final result = await DeepLinkService.processDeepLink(
          studyId: null,
          inviteCode: 'missing-invite',
          isAuthenticated: true,
        );

        expect(result, isA<DeepLinkError>());
        final error = result as DeepLinkError;
        expect(error.type, DeepLinkErrorType.invalidInvite);
        expect(error.errorValue, 'missing-invite');
      },
    );
  });
}

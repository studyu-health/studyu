import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/deferred_link_service.dart';

void main() {
  group('parseAndroidDeferredLink', () {
    test('parses invite links from new Android referrer key', () {
      final link = parseAndroidDeferredLink(
        inviteCode: null,
        studyId: null,
        referrer: 'utm_source=landing&invite=invite-123',
      );

      expect(link?.inviteCode, 'invite-123');
      expect(link?.studyId, isNull);
    });

    test('parses study links from new Android referrer key', () {
      final link = parseAndroidDeferredLink(
        inviteCode: null,
        studyId: null,
        referrer: 'utm_source=landing&study=study-123',
      );

      expect(link?.studyId, 'study-123');
      expect(link?.inviteCode, isNull);
    });

    test(
      'preserves invite precedence when a referrer contains invite and study',
      () {
        final link = parseAndroidDeferredLink(
          inviteCode: null,
          studyId: null,
          referrer: 'utm_source=landing&study=study-123&invite=invite-123',
        );

        expect(link?.inviteCode, 'invite-123');
        expect(link?.studyId, isNull);
      },
    );
  });

  group('pendingDeferredLinkFromStorageValues', () {
    test('restores invite links before study links', () {
      final link = pendingDeferredLinkFromStorageValues(
        inviteCode: ' invite-123 ',
        studyId: 'study-123',
      );

      expect(link?.inviteCode, 'invite-123');
      expect(link?.studyId, isNull);
    });

    test('restores study links when no invite is pending', () {
      final link = pendingDeferredLinkFromStorageValues(
        inviteCode: null,
        studyId: ' study-123 ',
      );

      expect(link?.studyId, 'study-123');
      expect(link?.inviteCode, isNull);
    });

    test('ignores empty pending values', () {
      final link = pendingDeferredLinkFromStorageValues(
        inviteCode: ' ',
        studyId: '',
      );

      expect(link, isNull);
    });
  });
}

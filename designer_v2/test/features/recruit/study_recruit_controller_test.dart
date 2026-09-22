import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_pagination.dart';

void main() {
  group('clampInviteCodePageIndex', () {
    test('keeps valid page indexes unchanged', () {
      expect(
        clampInviteCodePageIndex(
          requestedPageIndex: 1,
          totalCount: 120,
          pageSize: 50,
        ),
        1,
      );
    });

    test(
      'clamps invalid last page after delete to the new last valid page',
      () {
        expect(
          clampInviteCodePageIndex(
            requestedPageIndex: 2,
            totalCount: 100,
            pageSize: 50,
          ),
          1,
        );
      },
    );

    test('returns first page when no invites remain', () {
      expect(
        clampInviteCodePageIndex(
          requestedPageIndex: 3,
          totalCount: 0,
          pageSize: 50,
        ),
        0,
      );
    });
  });
}

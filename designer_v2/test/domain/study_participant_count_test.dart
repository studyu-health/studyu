import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';

void main() {
  group('StudyParticipantCountX', () {
    test(
      'ignores soft-deleted participants when counting invite enrollment',
      () {
        final study = Study('study-id', 'owner-id');
        final invite = StudyInvite('invite-code', study.id);

        final activeParticipant = StudySubject(
          'subject-1',
          study.id,
          'user-1',
          const <String>[],
        )..inviteCode = invite.code;

        final deletedParticipant =
            StudySubject('subject-2', study.id, 'user-2', const <String>[])
              ..inviteCode = invite.code
              ..isDeleted = true;

        study.participants = <StudySubject>[
          activeParticipant,
          deletedParticipant,
        ];

        expect(study.getParticipantCountForInvite(invite), 1);
      },
    );
  });
}

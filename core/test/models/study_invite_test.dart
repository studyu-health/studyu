import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  test('invite preview accepts incomplete study configuration', () {
    final study = Study.fromInvitePreviewJson(<String, dynamic>{
      'id': 'study-id',
      'title': 'Draft study',
      'description': 'Study description',
      'icon_name': 'accountHeart',
      'status': 'draft',
    });

    expect(study.title, 'Draft study');
    expect(study.description, 'Study description');
    expect(study.status, StudyStatus.draft);
    expect(study.interventions, isEmpty);
    expect(study.observations, isEmpty);
    expect(study.schedule, isNotNull);
  });

  test('fromJson keeps computed participant count from api payload', () {
    final invite = StudyInvite.fromJson(<String, dynamic>{
      'code': 'invite-code',
      'study_id': 'study-id',
      'study_invite_participant_count': 3,
    });

    expect(invite.participantCount, 3);
  });

  test('fromJson defaults computed participant count to zero when absent', () {
    final invite = StudyInvite.fromJson(<String, dynamic>{
      'code': 'invite-code',
      'study_id': 'study-id',
    });

    expect(invite.participantCount, 0);
  });

  test('toJson excludes computed participant count from save payload', () {
    final invite = StudyInvite('invite-code', 'study-id', participantCount: 3);

    expect(
      invite.toJson().containsKey(StudyInvite.participantCountJsonKey),
      isFalse,
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';

void main() {
  test('participant progress is tracked before a study is selected', () {
    final state = AppState();

    expect(state.isPreview, isFalse);
    expect(state.trackParticipantProgress, isTrue);
  });

  test('participant recovery UI is disabled in preview mode', () {
    final state = AppState();

    expect(state.showParticipantRecovery, isTrue);
    state.isPreview = true;
    expect(state.showParticipantRecovery, isFalse);
  });

  test('preview progress is tracked only for a known non-running study', () {
    final state = AppState()..isPreview = true;

    expect(state.trackParticipantProgress, isFalse);
    state.selectedStudy = Study('study', 'user');
    expect(state.trackParticipantProgress, isTrue);
    state.selectedStudy!.status = StudyStatus.running;
    expect(state.trackParticipantProgress, isFalse);
    state.clearAccountState();
    expect(state.trackParticipantProgress, isFalse);
  });

  test('preview study can update before a subject is created', () {
    final state = AppState();
    final study = Study('study', 'user');

    expect(() => state.updateStudy(study), returnsNormally);
    expect(state.selectedStudy, same(study));
  });
}

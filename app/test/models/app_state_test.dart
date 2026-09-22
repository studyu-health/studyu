import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';

void main() {
  test('participant recovery UI is disabled in preview mode', () {
    final state = AppState();

    expect(state.showParticipantRecovery, isTrue);
    state.isPreview = true;
    expect(state.showParticipantRecovery, isFalse);
  });

  test('preview study can update before a subject is created', () {
    final state = AppState();
    final study = Study('study', 'user');

    expect(() => state.updateStudy(study), returnsNormally);
    expect(state.selectedStudy, same(study));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller_state.dart';
import 'package:studyu_designer_v2/repositories/study_repository_interface.dart';

void main() {
  test('states with different preview languages are not equal', () {
    final studyRepository = _StudyRepository();
    final router = GoRouter(routes: []);
    final english = StudyTestControllerState(
      studyId: 'study',
      studyRepository: studyRepository,
      router: router,
      currentUser: null,
      studyWithMetadata: null,
      hasSession: true,
    );
    final german = StudyTestControllerState(
      studyId: 'study',
      studyRepository: studyRepository,
      router: router,
      currentUser: null,
      studyWithMetadata: null,
      hasSession: true,
      languageCode: 'de',
    );

    expect(english, isNot(german));
  });
}

class _StudyRepository() extends Mock implements IStudyRepository;

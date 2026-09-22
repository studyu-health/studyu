import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_controller.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_repository.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/invite_code_repository.dart';

final inviteCodeFormViewModelProvider =
    Provider.family<InviteCodeFormViewModel, StudyID>((ref, studyId) {
      final state = ref.watch(studyControllerProvider(studyId));
      final InviteCodeFormRepository inviteCodeRepository = ref.watch(
        inviteCodeRepositoryProvider(studyId),
      );

      return InviteCodeFormViewModel(
        study: state.studyValueRequired,
        inviteCodeRepository: inviteCodeRepository,
      );
    });

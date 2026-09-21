import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

abstract class InviteCodeFormRepository() {
  Future<bool> isCodeAlreadyUsed(String code);

  Future<WrappedModel<StudyInvite>?> save(
    StudyInvite invite, {
    bool runOptimistically = true,
  });

  Future<void> delete(String inviteCode, {bool runOptimistically = true});
}

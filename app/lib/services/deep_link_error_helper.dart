import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/services/deep_link_service.dart';

String getDeepLinkErrorMessage(
  AppLocalizations l10n,
  DeepLinkErrorType type, [
  String? errorValue,
]) {
  return switch (type) {
    DeepLinkErrorType.studyNotFound => l10n.deep_link_study_not_found(
      errorValue ?? '',
    ),
    DeepLinkErrorType.inviteOnly => l10n.deep_link_study_invite_only,
    DeepLinkErrorType.invalidInvite => l10n.deep_link_invite_invalid(
      errorValue ?? '',
    ),
  };
}

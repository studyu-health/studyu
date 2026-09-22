@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/qr_code_preview_dialog.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_controller.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_repository.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_view.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/services/clipboard.dart';
import 'package:supabase/supabase.dart';

class _FakeClipboardService() implements IClipboardService {
  String? copiedText;

  @override
  Future<String> copy(String text) async {
    copiedText = text;
    return text;
  }
}

class _FakeInviteCodeRepository() implements InviteCodeFormRepository {
  @override
  Future<bool> isCodeAlreadyUsed(String code) async => false;

  @override
  Future<WrappedModel<StudyInvite>?> save(
    StudyInvite invite, {
    bool runOptimistically = true,
  }) async => WrappedModel(invite);

  @override
  Future<void> delete(
    String inviteCode, {
    bool runOptimistically = true,
  }) async {}
}

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(lookupAppLocalizations(const Locale('en')));
    env.setEnv(
      'https://example.supabase.co',
      'test-anon-key',
      envAndroidPackageName: 'com.example.studyu',
      envIosAppStoreId: '123456789',
      supabaseClient: SupabaseClient('https://example.supabase.co', 'test'),
    );
  });

  testWidgets('invite link and QR code follow the code field', (tester) async {
    final study = Study('study-12345678', 'owner-id')..title = 'Test study';
    final viewModel = InviteCodeFormViewModel(
      study: study,
      inviteCodeRepository: _FakeInviteCodeRepository(),
    );
    final clipboard = _FakeClipboardService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [clipboardServiceProvider.overrideWithValue(clipboard)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ReactiveForm(
              formGroup: viewModel.form,
              child: SingleChildScrollView(
                child: InviteCodeFormView(formViewModel: viewModel),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, ' New-Code ');
    await tester.pump(const Duration(milliseconds: 250));

    const expectedLink = 'https://app.studyu.health/invite/new-code';
    expect(find.text(expectedLink), findsOneWidget);
    final qrCodePreview = tester.widget<QrCodePreview>(
      find.byType(QrCodePreview),
    );
    expect(qrCodePreview.data, expectedLink);
    expect(qrCodePreview.downloadFilename, 'studyu-invite-new-code');

    final downloadButton = tester.widget<PrimaryButton>(
      find.byType(PrimaryButton),
    );
    expect(downloadButton.text, tr.action_qr_code_download);
    expect(downloadButton.icon, Icons.download);

    final invitationHeader = find.text(tr.form_field_invitation_message);
    await tester.ensureVisible(invitationHeader);
    await tester.tap(invitationHeader);
    await tester.pump();

    final invitationMessage = tester.widget<Text>(
      find.byKey(const ValueKey('invitation_message_preview')),
    );
    final expectedInvitationMessage = [
      tr.invitation_message_intro('Test study'),
      '',
      tr.invitation_message_install_app,
      tr.invitation_message_android(
        'https://play.google.com/store/apps/details?id=com.example.studyu&referrer=invite%3Dnew-code',
      ),
      tr.invitation_message_ios('https://apps.apple.com/app/id123456789'),
      '',
      tr.invitation_message_open_link,
      expectedLink,
      '',
      tr.invitation_message_alternative,
      'new-code',
    ].join('\n');
    expect(invitationMessage.data, expectedInvitationMessage);

    await tester.tap(find.byTooltip(tr.action_copy_invitation));
    await tester.pump();
    expect(clipboard.copiedText, expectedInvitationMessage);

    final copyInviteCodeButton = find.byTooltip(tr.action_copy_invite_code);
    await tester.ensureVisible(copyInviteCodeButton);
    await tester.tap(copyInviteCodeButton);
    await tester.pump();

    expect(clipboard.copiedText, 'new-code');
  });
}

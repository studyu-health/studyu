import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

@visibleForTesting
String buildAppLaunchLink({String? inviteCode, String? studyId}) {
  assert(inviteCode != null || studyId != null);
  if (inviteCode != null) {
    return generateAppSchemeLink('invite/${Uri.encodeComponent(inviteCode)}');
  }
  return generateAppDeepLink('study/$studyId');
}

/// A screen shown to web users who open a deep link (invite or study).
///
/// Desktop browsers receive an invitation handoff surface. Mobile browsers
/// attempt to open the installed app and retain the existing store fallback.
class const DeepLinkWebLandingPage({
  super.key,
  final String? inviteCode,
  final String? studyId,
  @visibleForTesting
  final Future<(StudyInvite?, Study?)> Function(String)? lookupInvite,
}) extends StatefulWidget {
  this : assert(inviteCode != null || studyId != null);

  @override
  State<DeepLinkWebLandingPage> createState() => _DeepLinkWebLandingPageState();
}

class _DeepLinkWebLandingPageState() extends State<DeepLinkWebLandingPage> {
  Future<(StudyInvite?, Study?)>? _inviteFuture;
  Timer? _copyFeedbackTimer;
  bool _inviteCodeCopied = false;

  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    if (!_isMobile && widget.inviteCode != null) {
      final lookup =
          widget.lookupInvite ??
          (code) => Study.fetchByInviteCode(code, previewOnly: true);
      _inviteFuture = lookup(widget.inviteCode!);
    }
    _launchAppScheme();
  }

  @override
  void dispose() {
    _copyFeedbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _launchAppScheme() async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final path = widget.inviteCode != null
        ? 'invite/${Uri.encodeComponent(widget.inviteCode!)}'
        : 'study/${widget.studyId}';
    final uri = Uri.parse(generateAppSchemeLink(path));
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Uri? _playStoreUrl() {
    final packageName = androidPackageName;
    if (packageName == null || packageName.isEmpty) return null;

    final referrer = widget.inviteCode != null
        ? 'invite=${widget.inviteCode}'
        : widget.studyId != null
        ? 'study=${widget.studyId}'
        : null;
    final queryParameters = {'id': packageName};
    if (referrer != null) queryParameters['referrer'] = referrer;
    return Uri.https('play.google.com', '/store/apps/details', queryParameters);
  }

  Uri? _appStoreUrl() {
    final storeId = iosAppStoreId;
    if (storeId == null || storeId.isEmpty) return null;
    return Uri.parse('https://apps.apple.com/app/id$storeId');
  }

  Future<void> _launchStore(Uri? url) async {
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _copyInviteCode() async {
    final inviteCode = widget.inviteCode;
    if (inviteCode == null) return;

    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (!mounted) return;

    _copyFeedbackTimer?.cancel();
    setState(() => _inviteCodeCopied = true);
    _copyFeedbackTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _inviteCodeCopied = false);
    });
  }

  Future<void> _launchAppStore() async {
    final url = switch (defaultTargetPlatform) {
      TargetPlatform.android => _playStoreUrl(),
      TargetPlatform.iOS => _appStoreUrl(),
      _ => null,
    };
    await _launchStore(url);
  }

  Widget _buildDesktopSurface(
    BuildContext context, {
    Study? study,
    String? error,
    bool loading = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final inviteCode = widget.inviteCode;
    final inviteLink = inviteCode == null
        ? null
        : generateAppDeepLink('invite/${Uri.encodeComponent(inviteCode)}');
    final playStoreUrl = _playStoreUrl();
    final appStoreUrl = _appStoreUrl();
    final compact = MediaQuery.sizeOf(context).width < 600;
    final studyIcon = study == null
        ? null
        : MdiIconsHelper.fromString(study.iconName);
    final hasStudyTitle = study?.title?.trim().isNotEmpty ?? false;
    final hasStudyDescription = study?.description?.trim().isNotEmpty ?? false;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(compact ? 16 : 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: EdgeInsets.all(compact ? 20 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        key: const Key('invite-study-summary'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (studyIcon != null) ...[
                            Icon(
                              studyIcon,
                              size: 40,
                              color: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  header: true,
                                  child: hasStudyTitle
                                      ? Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${l10n.invite_landing_invited_title} “',
                                              ),
                                              TextSpan(
                                                text: study!.title!.trim(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const TextSpan(text: '”'),
                                            ],
                                          ),
                                          style: theme.textTheme.headlineMedium,
                                        )
                                      : Text(
                                          widget.inviteCode != null
                                              ? l10n.you_have_been_invited
                                              : l10n.invite_landing_instruction_title,
                                          style: theme.textTheme.headlineMedium,
                                        ),
                                ),
                                if (hasStudyDescription) ...[
                                  const SizedBox(height: 4),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 640,
                                    ),
                                    child: Text(
                                      study!.description!.trim(),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (loading) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(l10n.invite_landing_loading)),
                          ],
                        ),
                      ],
                      if (error != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          error,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                      if (study != null &&
                          inviteCode != null &&
                          inviteLink != null) ...[
                        const SizedBox(height: 32),
                        Column(
                          key: const Key('invite-static-steps'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                l10n.invite_landing_instruction_title,
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _InviteStep(
                              key: const ValueKey('invite-step-1'),
                              number: 1,
                              title: l10n.invite_landing_step_download,
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  if (playStoreUrl != null)
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(0, 48),
                                      ),
                                      onPressed: () =>
                                          _launchStore(playStoreUrl),
                                      icon: const Icon(Icons.android),
                                      label: Text(
                                        l10n.invite_landing_google_play,
                                      ),
                                    ),
                                  if (appStoreUrl != null)
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(0, 48),
                                      ),
                                      onPressed: () =>
                                          _launchStore(appStoreUrl),
                                      icon: const Icon(Icons.apple),
                                      label: Text(
                                        l10n.invite_landing_app_store,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _InviteStep(
                              key: const ValueKey('invite-step-2'),
                              number: 2,
                              title: l10n.invite_landing_step_join,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final stacked = constraints.maxWidth < 700;

                                  Widget optionHeader(
                                    String title,
                                    String description,
                                  ) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        description,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  );

                                  final inviteCodeField = Align(
                                    alignment: Alignment.centerLeft,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 360,
                                      ),
                                      child: Semantics(
                                        key: const Key(
                                          'invite-code-copy-semantics',
                                        ),
                                        container: true,
                                        button: true,
                                        excludeSemantics: true,
                                        liveRegion: _inviteCodeCopied,
                                        label: _inviteCodeCopied
                                            ? l10n.invite_landing_copied
                                            : l10n.invite_landing_copy_code,
                                        onTap: _copyInviteCode,
                                        child: Tooltip(
                                          message: _inviteCodeCopied
                                              ? l10n.invite_landing_copied
                                              : l10n.invite_landing_copy_code,
                                          excludeFromSemantics: true,
                                          child: Material(
                                            key: const Key('invite-code-field'),
                                            color: theme.colorScheme.surface,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              side: BorderSide(
                                                color: theme
                                                    .colorScheme
                                                    .outlineVariant,
                                              ),
                                            ),
                                            child: InkWell(
                                              key: const Key(
                                                'invite-code-copy-button',
                                              ),
                                              onTap: _copyInviteCode,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              hoverColor: theme
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              focusColor: theme
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              highlightColor: theme
                                                  .colorScheme
                                                  .surfaceContainerHigh,
                                              child: SizedBox(
                                                height: 76,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              l10n.invite_landing_invite_code,
                                                              style: theme
                                                                  .textTheme
                                                                  .labelMedium
                                                                  ?.copyWith(
                                                                    color: theme
                                                                        .colorScheme
                                                                        .onSurfaceVariant,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              height: 2,
                                                            ),
                                                            Text(
                                                              inviteCode,
                                                              key: const Key(
                                                                'invite-code',
                                                              ),
                                                              maxLines: 1,
                                                              style: theme
                                                                  .textTheme
                                                                  .headlineSmall
                                                                  ?.copyWith(
                                                                    fontFamily: 'monospace',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    letterSpacing:
                                                                        1.4,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Icon(
                                                        _inviteCodeCopied
                                                            ? Icons
                                                                  .check_rounded
                                                            : Icons
                                                                  .copy_rounded,
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  final inviteCodeHeader = optionHeader(
                                    l10n.invite_landing_enter_code_title,
                                    l10n.invite_landing_phone_instruction,
                                  );
                                  final qrCodeHeader = optionHeader(
                                    l10n.invite_landing_scan_qr_title,
                                    l10n.invite_landing_other_device_instruction,
                                  );
                                  final qrCode = QrCode.fromData(
                                    data: inviteLink,
                                    errorCorrectLevel: QrErrorCorrectLevel.H,
                                  );
                                  final qrCard = Align(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 210,
                                      ),
                                      child: Semantics(
                                        key: const Key('invite-qr'),
                                        image: true,
                                        label: l10n.invite_landing_qr_label,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: theme
                                                  .colorScheme
                                                  .outlineVariant,
                                            ),
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: PrettyQrView(
                                              qrImage: QrImage(qrCode),
                                              decoration:
                                                  const PrettyQrDecoration(
                                                    background: Colors.white,
                                                    image:
                                                        PrettyQrDecorationImage(
                                                          image: AssetImage(
                                                            'assets/icon/icon.png',
                                                          ),
                                                        ),
                                                    // ignore: experimental_member_use
                                                    shape: PrettyQrShape.custom(
                                                      PrettyQrSquaresSymbol(),
                                                      finderPattern:
                                                          PrettyQrSmoothSymbol(),
                                                      alignmentPatterns:
                                                          PrettyQrDotsSymbol(),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );

                                  if (stacked) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        inviteCodeHeader,
                                        const SizedBox(height: 12),
                                        inviteCodeField,
                                        const SizedBox(height: 24),
                                        qrCodeHeader,
                                        const SizedBox(height: 12),
                                        qrCard,
                                      ],
                                    );
                                  }

                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            inviteCodeHeader,
                                            const SizedBox(height: 12),
                                            inviteCodeField,
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 32),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            qrCodeHeader,
                                            const SizedBox(height: 12),
                                            qrCard,
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ] else if (!loading && error == null) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.invite_landing_step_join_description,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMobile) {
      if (_inviteFuture == null) return _buildDesktopSurface(context);
      return FutureBuilder<(StudyInvite?, Study?)>(
        future: _inviteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildDesktopSurface(context, loading: true);
          }
          if (snapshot.hasError) {
            return _buildDesktopSurface(
              context,
              error: AppLocalizations.of(context)!.invite_landing_load_error,
            );
          }
          final study = snapshot.data?.$2;
          if (study == null) {
            return _buildDesktopSurface(
              context,
              error: AppLocalizations.of(context)!.invite_landing_invalid,
            );
          }
          return _buildDesktopSurface(context, study: study);
        },
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.you_have_been_invited,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              onPressed: _launchAppScheme,
              icon: const Icon(Icons.open_in_new),
              label: Text(AppLocalizations.of(context)!.open_study_app),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _launchAppStore,
              child: Text(AppLocalizations.of(context)!.download_app_join),
            ),
          ],
        ),
      ),
    );
  }
}

class const _InviteStep({
  required final int number,
  required final String title,
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/services/clipboard.dart';
import 'package:studyu_designer_v2/utils/debug_print.dart';
import 'package:studyu_designer_v2/utils/qr_code_downloader.dart';

class const QrCodePreviewDialog({
  required final String data,
  required final String filename,
  final String? title,
  final String? inviteCode,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const dialogWidth = 450.0;

    return ScaffoldMessenger(
      child: Builder(
        builder: (dialogContext) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: ModalBarrier(
                  color: Colors.transparent,
                  semanticsLabel: MaterialLocalizations.of(dialogContext)
                      .modalBarrierDismissLabel,
                  onDismiss: () => Navigator.of(dialogContext).maybePop(),
                ),
              ),
              StandardDialog(
                titleText: title ?? tr.action_qr_code_show,
                width: dialogWidth,
                minHeight: 400,
                body: QrCodePreview(
                  data: data,
                  inviteCode: inviteCode,
                  snackBarWidth: dialogWidth,
                ),
                actionButtons: [
                  DismissButton(text: tr.dialog_close),
                  PrimaryButton(
                    text: tr.action_qr_code_download,
                    icon: Icons.download,
                    onPressed: () async {
                      await QrCodeDownloader.downloadQrCode(
                        data: data,
                        filename: filename,
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class const QrCodePreview({
  required final String data,
  final String? inviteCode,
  final double? snackBarWidth,
  final bool showInviteLink = true,
  final String? downloadFilename,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<QrCodePreview> createState() => _QrCodePreviewState();
}

class _QrCodePreviewState() extends ConsumerState<QrCodePreview> {
  late Future<Widget> _qrWidgetFuture;

  @override
  void initState() {
    super.initState();
    _qrWidgetFuture = QrCodeDownloader.generateQrWidget(data: widget.data);
  }

  @override
  void didUpdateWidget(QrCodePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _qrWidgetFuture = QrCodeDownloader.generateQrWidget(data: widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(tr.dialog_qr_code_description, style: theme.textTheme.bodyMedium),
        if (widget.inviteCode != null) ...[
          const SizedBox(height: 16.0),
          Text(
            '${tr.form_field_code}: ${widget.inviteCode}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const SizedBox(height: 16.0),
        SizedBox(
          height: 232.0,
          child: Row(
            children: [
              SizedBox(
                width: 232.0,
                child: FutureBuilder<Widget>(
                  future: _qrWidgetFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      debugLog('Failed to generate QR code: ${snapshot.error}');
                      return Center(
                        child: Text(
                          tr.error_qr_code_generation,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      );
                    }
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: snapshot.data,
                      ),
                    );
                  },
                ),
              ),
              if (widget.downloadFilename case final String filename) ...[
                const SizedBox(width: 24.0),
                PrimaryButton(
                  text: tr.action_qr_code_download,
                  icon: Icons.download,
                  onPressed: () async {
                    await QrCodeDownloader.downloadQrCode(
                      data: widget.data,
                      filename: filename,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        if (widget.showInviteLink) ...[
          const SizedBox(height: 16.0),
          InviteLinkPreview(
            data: widget.data,
            snackBarWidth: widget.snackBarWidth,
          ),
        ],
      ],
    );
  }
}

class const InviteLinkPreview({
  required final String data,
  final double? snackBarWidth,
  super.key,
}) extends ConsumerWidget {
  Future<void> _copyLink(BuildContext context, WidgetRef ref) async {
    await ref.read(clipboardServiceProvider).copy(data);
    if (!context.mounted) return;

    final theme = Theme.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            tr.notification_invite_link_copied,
            style: theme.textTheme.titleMedium!.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          width: snackBarWidth,
          duration: const Duration(milliseconds: 2500),
          persist: false,
          padding: const EdgeInsets.fromLTRB(40.0, 16.0, 24.0, 16.0),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          closeIconColor: theme.colorScheme.onPrimary,
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      key: const ValueKey('invite_link_preview'),
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        mouseCursor: SystemMouseCursors.click,
        onTap: () => _copyLink(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(data, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 12.0),
              Tooltip(
                message: tr.action_copy_link,
                preferBelow: true,
                child: Icon(
                  Icons.copy_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_app/util/recovery_file_utils.dart';

class const RecoveryPhraseContent({
  super.key,
  final bool useGridLayout = true,
  final List<String>? initialPhrase,
  final bool isChecked = false,
  final ValueChanged<bool?>? onCheckedChanged,
  final bool showConfirmation = true,
  final bool showSuccessFeedback = true,
  final bool showRotation = true,
  final VoidCallback? onLoadError,
}) extends StatefulWidget {
  @override
  State<RecoveryPhraseContent> createState() => RecoveryPhraseContentState();
}

class RecoveryPhraseContentState() extends State<RecoveryPhraseContent> {
  late List<String>? _phrase = widget.initialPhrase;
  late bool _isLoading = widget.initialPhrase == null;
  bool _isRotating = false;
  String? _error;

  List<String>? get phrase => _phrase;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhrase == null) loadPhrase();
  }

  Future<void> loadPhrase() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final phrase = await RestoreAccountService.getRecoveryPhrase();
      if (mounted) {
        setState(() {
          _phrase = phrase;
          _isLoading = false;
          _error = phrase == null
              ? AppLocalizations.of(context)!.recovery_phrase_load_error
              : null;
        });
        if (phrase == null) widget.onLoadError?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = AppLocalizations.of(context)!.recovery_phrase_load_error;
        });
        widget.onLoadError?.call();
      }
    }
  }

  void _copyToClipboard() {
    if (_phrase == null) return;
    final text = _phrase!.join(' ');
    Clipboard.setData(ClipboardData(text: text));
    if (widget.showSuccessFeedback) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.copied_to_clipboard),
        ),
      );
    }
  }

  Future<void> _downloadText() async {
    if (_phrase == null) return;
    try {
      await RecoveryFileUtils.downloadRecoveryText(_phrase!);
      if (mounted && widget.showSuccessFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.file_saved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.file_save_error),
          ),
        );
      }
    }
  }

  Future<void> _confirmRotation() async {
    var acknowledged = false;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(l10n.recovery_phrase_rotate_dialog_title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.recovery_phrase_rotate_dialog_description),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(l10n.recovery_phrase_rotate_acknowledgement),
                    value: acknowledged,
                    onChanged: (value) =>
                        setDialogState(() => acknowledged = value ?? false),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: acknowledged
                    ? () => Navigator.pop(dialogContext, true)
                    : null,
                child: Text(l10n.recovery_phrase_rotate_confirm),
              ),
            ],
          );
        },
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isRotating = true);
    final phrase = await RestoreAccountService.rotateRecoveryPhrase();
    if (!mounted) return;

    setState(() {
      _isRotating = false;
      if (phrase != null) _phrase = phrase;
    });
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          phrase == null
              ? l10n.recovery_phrase_rotate_error
              : l10n.recovery_phrase_rotate_success,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: loadPhrase,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.try_again),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        if (widget.useGridLayout) _buildPhraseGrid() else _buildPhraseChips(),
        const SizedBox(height: 16),
        _buildActionButtons(),
        if (widget.showRotation) ...[
          const SizedBox(height: 8),
          Center(
            child: OutlinedButton.icon(
              onPressed: _isRotating ? null : _confirmRotation,
              icon: const Icon(Icons.refresh),
              label: Text(
                AppLocalizations.of(context)!.recovery_phrase_rotate_button,
              ),
            ),
          ),
        ],
        if (widget.showConfirmation) ...[
          const SizedBox(height: 16),
          CheckboxListTile(
            title: Text(
              AppLocalizations.of(context)!.recovery_phrase_saved_confirmation,
            ),
            value: widget.isChecked,
            onChanged: widget.onCheckedChanged,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ],
    );
  }

  Widget _buildPhraseGrid() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const rowHeight = 36.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                for (var index = 0; index < _phrase!.length; index++)
                  SizedBox(
                    height: rowHeight,
                    width: 28,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SelectionArea(
                child: SelectableText(
                  _phrase!.join('\n'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    height:
                        rowHeight /
                        (theme.textTheme.titleMedium?.fontSize ?? 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhraseChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _phrase!.map((word) => Chip(label: Text(word))).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.copy_outlined),
          label: Text(AppLocalizations.of(context)!.copy_btn),
          onPressed: _copyToClipboard,
        ),
        TextButton.icon(
          icon: const Icon(Icons.download_outlined),
          label: Text(AppLocalizations.of(context)!.download_btn),
          onPressed: _downloadText,
        ),
      ],
    );
  }
}

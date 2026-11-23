import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

enum AssistedNutritionVoiceStage() {
  idle,
  starting,
  recording,
  transcribing,
}

enum _VoiceError() {
  permission,
  recording,
  transcription,
}

class AssistedNutritionVoiceCapture() extends ChangeNotifier {
  AssistedNutritionVoiceStage _stage = AssistedNutritionVoiceStage.idle;
  _VoiceError? _error;
  _VoiceTake? _take;
  bool _hasSample = false;

  AssistedNutritionVoiceStage get stage => _stage;
  bool get busy => _stage != AssistedNutritionVoiceStage.idle;

  Future<void> start() async {
    if (busy) return;

    final take = _VoiceTake();
    _take = take;
    _stage = AssistedNutritionVoiceStage.starting;
    _error = null;
    notifyListeners();

    try {
      final granted = await take.recorder.hasPermission();
      if (_take != take) return;
      if (!granted) {
        _finish(take, error: _VoiceError.permission);
        return;
      }

      final stream = await take.recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      if (_take != take) return;

      take.subscription = stream.listen(
        take.measure,
        onError: (Object _) {
          if (_take == take) _finish(take, error: _VoiceError.recording);
        },
        onDone: () {
          if (_take == take &&
              _stage == AssistedNutritionVoiceStage.recording) {
            _finish(take, error: _VoiceError.recording);
          }
        },
      );
      take.elapsed.start();
      take.timer = Timer.periodic(const Duration(milliseconds: 120), (_) {
        if (_take == take) {
          take.sampleLevel();
          notifyListeners();
        }
      });
      _stage = AssistedNutritionVoiceStage.recording;
      notifyListeners();
    } catch (_) {
      if (_take == take) _finish(take, error: _VoiceError.recording);
    }
  }

  Future<void> stopAndTranscribe({
    required String sample,
    required ValueChanged<String> onTranscript,
  }) async {
    final take = _take;
    if (take == null || _stage != AssistedNutritionVoiceStage.recording) return;
    take.timer?.cancel();
    _stage = AssistedNutritionVoiceStage.transcribing;
    notifyListeners();

    try {
      await take.recorder.stop();
      if (_take != take) return;
      if (!take.hasAudio) {
        _finish(take, error: _VoiceError.transcription);
        return;
      }
      unawaited(take.release(cancel: false));
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (_take != take) return;
      onTranscript(sample);
      _hasSample = true;
      _finish(take);
    } catch (_) {
      if (_take == take) _finish(take, error: _VoiceError.transcription);
    }
  }

  void cancel() {
    final take = _take;
    if (take != null) _finish(take);
  }

  void _finish(_VoiceTake take, {_VoiceError? error}) {
    _take = null;
    _error = error;
    _stage = AssistedNutritionVoiceStage.idle;
    unawaited(take.release(cancel: true));
    notifyListeners();
  }

  @override
  void dispose() {
    final take = _take;
    _take = null;
    if (take != null) unawaited(take.release(cancel: true));
    super.dispose();
  }
}

class _VoiceTake() {
  final recorder = AudioRecorder();
  final elapsed = Stopwatch();
  final levels = List<double>.filled(28, 0);
  StreamSubscription<Uint8List>? subscription;
  Timer? timer;
  Future<void>? _release;
  bool hasAudio = false;
  double _peak = 0;

  void measure(Uint8List audio) {
    if (audio.lengthInBytes < 2) return;
    hasAudio = true;
    final pcm = ByteData.sublistView(audio);
    for (var offset = 0; offset + 1 < pcm.lengthInBytes; offset += 8) {
      _peak = math.max(
        _peak,
        pcm.getInt16(offset, Endian.little).abs() / 32768,
      );
    }
  }

  void sampleLevel() {
    levels.setRange(0, levels.length - 1, levels, 1);
    levels.last = math.sqrt(_peak);
    _peak = 0;
  }

  Future<void> release({required bool cancel}) =>
      _release ??= _releaseResources(cancel: cancel);

  Future<void> _releaseResources({required bool cancel}) async {
    timer?.cancel();
    elapsed.stop();
    try {
      if (cancel) await recorder.cancel();
    } catch (_) {
      // Dispose also releases the platform recorder if cancellation fails.
    }
    try {
      await subscription?.cancel();
    } catch (_) {
      // Dispose releases the platform recorder and its event stream.
    } finally {
      try {
        await recorder.dispose();
      } catch (_) {
        // The platform recorder may not have started.
      }
    }
  }
}

class const AssistedNutritionVoiceField({
  super.key,
  required final AssistedNutritionVoiceCapture voice,
  required final TextEditingController controller,
  required final String hint,
  final VoidCallback? onChanged,
}) extends StatefulWidget {
  @override
  State<AssistedNutritionVoiceField> createState() =>
      _AssistedNutritionVoiceFieldState();
}

class _AssistedNutritionVoiceFieldState()
    extends State<AssistedNutritionVoiceField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final voice = widget.voice;
    final error = switch (voice._error) {
      _VoiceError.permission => l10n.microphone_access_denied,
      _VoiceError.recording => l10n.recording_error,
      _VoiceError.transcription => l10n.nutrition_assisted_transcript_error,
      null => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (voice.stage == AssistedNutritionVoiceStage.recording)
          _RecordingPanel(take: voice._take!)
        else if (voice.stage == AssistedNutritionVoiceStage.transcribing)
          Semantics(
            liveRegion: true,
            child: _VoicePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.nutrition_assisted_transcribing),
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                ],
              ),
            ),
          )
        else
          ListenableBuilder(
            listenable: _focusNode,
            builder: (context, _) => TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              enabled: !voice.busy,
              style: theme.textTheme.bodyMedium,
              minLines: 4,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => widget.onChanged?.call(),
              decoration: InputDecoration(
                hintText: _focusNode.hasFocus ? null : widget.hint,
                hintMaxLines: 3,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colors.surface,
                contentPadding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: Align(
                  alignment: AlignmentDirectional.topEnd,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: IconButton(
                    tooltip: l10n.start_recording,
                    onPressed: voice.busy
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            unawaited(voice.start());
                          },
                    icon: voice.busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.mic_none, color: colors.primary),
                  ),
                ),
              ),
            ),
          ),
        if (voice._hasSample && !voice.busy) ...[
          const SizedBox(height: 8),
          Text(
            l10n.nutrition_assisted_demo_transcript,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 8),
          AssistedNutritionError(error),
        ],
      ],
    );
  }
}

class const _RecordingPanel({required final _VoiceTake take})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final seconds = take.elapsed.elapsed.inSeconds;
    final elapsed =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

    return _VoicePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                Icon(Icons.circle, color: colors.error, size: 8),
                const SizedBox(width: 8),
                Text(
                  l10n.nutrition_assisted_recording,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ExcludeSemantics(
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final level in take.levels)
                          Flexible(
                            child: Container(
                              height: 4 + level * 40,
                              width: 3,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(elapsed, style: theme.textTheme.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class const _VoicePanel({required final Widget child}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class const AssistedNutritionError(final String message, {super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

Future<T?> showAssistedNutritionSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: false,
  enableDrag: false,
  isDismissible: false,
  backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
  builder: builder,
);

class const AssistedNutritionSheet({
  super.key,
  required final Widget content,
  required final Widget action,
  final String? title,
  final bool? centerTitle,
  final VoidCallback? onBack,
  final VoidCallback? onClose,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = AppBarTheme.of(context);
    final usesBackChevron =
        !kIsWeb &&
        (theme.platform == TargetPlatform.iOS ||
            theme.platform == TargetPlatform.macOS);
    // Match the visible height of the native back icon.
    final closeIconSize = usesBackChevron ? 32.0 : 28.0;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (title != null)
                AppBar(
                  primary: false,
                  automaticallyImplyLeading: false,
                  leading: onBack == null
                      ? null
                      : BackButton(onPressed: onBack),
                  title: Text(title!),
                  centerTitle: centerTitle,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  actionsPadding: EdgeInsets.zero,
                  actions: [
                    if (onClose != null)
                      SizedBox(
                        width: appBarTheme.leadingWidth ?? kToolbarHeight,
                        child: CloseButton(
                          onPressed: onClose,
                          style: IconButton.styleFrom(iconSize: closeIconSize),
                        ),
                      ),
                  ],
                ),
              Flexible(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: content,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: action,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> showAssistedNutritionCorrection(
  BuildContext context, {
  bool Function(String)? onApply,
}) => showAssistedNutritionSheet<String>(
  context,
  builder: (_) => _CorrectionSheet(onApply: onApply),
);

class const _CorrectionSheet({required final bool Function(String)? onApply})
    extends StatefulWidget {
  @override
  State<_CorrectionSheet> createState() => _CorrectionSheetState();
}

class _CorrectionSheetState() extends State<_CorrectionSheet> {
  final _controller = TextEditingController();
  final _voice = AssistedNutritionVoiceCapture();
  late final AppLifecycleListener _lifecycle;
  bool _applyFailed = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onPause: _voice.cancel);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _voice.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final correction = _controller.text.trim();
    if (_voice.busy || correction.isEmpty) return;
    if (widget.onApply?.call(correction) == false) {
      setState(() => _applyFailed = true);
      return;
    }
    Navigator.pop(context, correction);
  }

  void _edit() {
    if (_applyFailed) setState(() => _applyFailed = false);
  }

  void _stop() {
    final sample = AppLocalizations.of(context)!
        .nutrition_assisted_sample_correction;
    unawaited(
      _voice.stopAndTranscribe(
        sample: sample,
        onTranscript: (transcript) {
          _controller.text = transcript;
          _edit();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([_voice, _controller]),
      builder: (context, _) {
        final action = switch (_voice.stage) {
          AssistedNutritionVoiceStage.recording => FilledButton(
            onPressed: _stop,
            child: Text(l10n.nutrition_assisted_stop_transcribe),
          ),
          AssistedNutritionVoiceStage.transcribing => OutlinedButton(
            onPressed: _voice.cancel,
            child: Text(l10n.cancel),
          ),
          _ => FilledButton(
            onPressed: !_voice.busy && _controller.text.trim().isNotEmpty
                ? _apply
                : null,
            child: Text(l10n.nutrition_assisted_apply_correction),
          ),
        };

        return PopScope<String>(
          canPop: !_voice.busy,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _voice.cancel();
          },
          child: AssistedNutritionSheet(
            title: l10n.nutrition_assisted_correct_voice,
            onBack: () => Navigator.pop(context),
            onClose: () => Navigator.pop(context),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.nutrition_assisted_correction_help,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                AssistedNutritionVoiceField(
                  voice: _voice,
                  controller: _controller,
                  hint: l10n.nutrition_assisted_correction_hint,
                  onChanged: _edit,
                ),
                if (_applyFailed) ...[
                  const SizedBox(height: 8),
                  AssistedNutritionError(
                    l10n.nutrition_assisted_correction_error,
                  ),
                ],
              ],
            ),
            action: action,
          ),
        );
      },
    );
  }
}

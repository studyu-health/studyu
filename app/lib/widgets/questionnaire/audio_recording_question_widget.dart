import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class const AudioRecordingQuestionWidget({
  super.key,
  required final AudioRecordingQuestion question,
  final Function(Answer<FutureBlobFile>)? onDone,
}) extends QuestionWidget {
  @override
  State<AudioRecordingQuestionWidget> createState() =>
      _AudioRecordingQuestionWidgetState();
}

class _AudioRecordingQuestionWidgetState()
    extends State<AudioRecordingQuestionWidget> {
  bool _isRecording = false;
  bool _hasRecorded = false;
  late final AudioRecorder _audioRecorder;
  Timer? _timer;
  int _recordDurationSeconds = 0;
  FutureBlobFile? _recordedFile;

  @override
  void initState() {
    _audioRecorder = AudioRecorder();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();
    final maxRecordingDurationSeconds =
        widget.question.maxRecordingDurationSeconds;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: _isRecording ? Colors.red.shade600 : null,
              foregroundColor: _isRecording
                  ? Colors.white
                  : theme.colorScheme.primary,
              side: BorderSide(
                color: _hasRecorded
                    ? Colors.black38
                    : _isRecording
                    ? Colors.red.shade600
                    : theme.colorScheme.primary,
              ),
            ),
            onPressed: !_hasRecorded
                ? () async {
                    if (_isRecording) {
                      await _stopRecording();
                    } else {
                      await _startRecording(
                        appState.activeSubject!.studyId,
                        appState.activeSubject!.userId,
                      );
                    }
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 2.0,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      _hasRecorded
                          ? MdiIcons.checkCircleOutline
                          : _isRecording
                          ? MdiIcons.stop
                          : MdiIcons.microphone,
                      color: _hasRecorded
                          ? Colors.black38
                          : _isRecording
                          ? Colors.white
                          : theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _hasRecorded
                        ? loc.audio_recorded
                        : _isRecording
                        ? loc.stop_recording
                        : loc.start_recording,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        Text(
          '${_formatNumber(_recordDurationSeconds ~/ 60)}:${_formatNumber(_recordDurationSeconds % 60)}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8.0),
        if (_isRecording &&
            _recordDurationSeconds > 0 &&
            _recordDurationSeconds < maxRecordingDurationSeconds)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              value:
                  1.0 - (_recordDurationSeconds / maxRecordingDurationSeconds),
              strokeWidth: 2.5,
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Future<void> _startRecording(String studyId, String userId) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.multimodal_not_supported),
        ),
      );
      return;
    }

    if (_isRecording || _hasRecorded) return;
    setState(() {
      _isRecording = true;
    });
    try {
      final hasPermission = await _audioRecorder.hasPermission();

      if (!hasPermission) {
        debugPrint('No permission to record audio');
        _handleRecordingError(isPermissionRelated: true);
        return;
      }

      final storage = TemporaryStorageHandler(studyId, userId);
      const config = RecordConfig(numChannels: 1);
      _recordedFile = await storage.getStagingAudio();

      if (_recordedFile == null) {
        throw ArgumentError('Staging audio file is null');
      }

      await _audioRecorder.start(config, path: _recordedFile!.localFilePath);
      _startTimer();
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _handleRecordingError();
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _hasRecorded) return;
    setState(() {
      _hasRecorded = true;
      _isRecording = false;
    });
    try {
      _timer?.cancel();
      final recordedFilePath = await _audioRecorder.stop();
      final recordedFile = _recordedFile;
      if (recordedFile == null) {
        throw ArgumentError('Recorded file is null');
      }
      if (recordedFilePath != recordedFile.localFilePath) {
        throw ArgumentError('No file path returned from stop');
      }
      widget.onDone!(widget.question.constructAnswer(recordedFile));
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _handleRecordingError();
    }
  }

  void _startTimer() {
    _recordDurationSeconds = 0;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      setState(() => _recordDurationSeconds++);
      if (_recordDurationSeconds >=
          widget.question.maxRecordingDurationSeconds) {
        await _stopRecording();
      }
    });
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  void _handleRecordingError({bool isPermissionRelated = false}) {
    if (!mounted) return;
    setState(() {
      _isRecording = false;
    });
    final errorMessage = isPermissionRelated
        ? AppLocalizations.of(context)!.microphone_access_denied
        : AppLocalizations.of(context)!.recording_error;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}

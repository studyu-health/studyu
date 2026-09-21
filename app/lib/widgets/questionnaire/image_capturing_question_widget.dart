import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class const ImageCapturingQuestionWidget({
  super.key,
  required final ImageCapturingQuestion question,
  final Function(Answer<FutureBlobFile>)? onDone,
}) extends QuestionWidget {
  @override
  State<ImageCapturingQuestionWidget> createState() =>
      _ImageCapturingQuestionWidgetState();
}

class _ImageCapturingQuestionWidgetState()
    extends State<ImageCapturingQuestionWidget> {
  bool _hasCaptured = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(
          color: _hasCaptured ? Colors.black38 : theme.colorScheme.primary,
        ),
      ),
      onPressed: !_hasCaptured
          ? () async {
              await _captureImage();
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                _hasCaptured ? MdiIcons.checkCircleOutline : MdiIcons.camera,
                color: _hasCaptured
                    ? Colors.black38
                    : theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const Spacer(),
            Text(
              _hasCaptured ? loc.photo_captured : loc.take_a_photo,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.multimodal_not_supported),
        ),
      );
      return;
    }
    final appState = context.read<AppState>();
    final FutureBlobFile? imageFile = await context.push(
      '/${RouteNames.capturePicture}',
      extra: {
        'studyId': appState.activeSubject!.studyId,
        'userId': appState.activeSubject!.userId,
      },
    );
    if (imageFile != null) {
      setState(() {
        _hasCaptured = true;
      });
      widget.onDone!(widget.question.constructAnswer(imageFile));
    }
  }
}

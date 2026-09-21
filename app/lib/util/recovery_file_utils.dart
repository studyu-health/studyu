import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:universal_html/html.dart' as html;

class RecoveryFileUtils() {
  static Future<void> downloadRecoveryText(List<String> phrase) async {
    try {
      final text = phrase.join(' ');
      final bytes = Uint8List.fromList(text.codeUnits);

      if (kIsWeb) {
        await _downloadFileWeb(
          bytes,
          'studyu_recovery_phrase.txt',
          'text/plain',
        );
        return;
      }

      final params = SaveFileDialogParams(
        data: bytes,
        fileName: 'studyu_recovery_phrase.txt',
        mimeTypesFilter: ['text/plain'],
      );

      await FlutterFileDialog.saveFile(params: params);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _downloadFileWeb(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    final blob = html.Blob([bytes], mimeType);

    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);

    anchor.remove();
  }
}

import 'dart:core';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:studyu_core/core.dart';

class TemporaryStorageHandler(final String _studyId, final String _userId) {
  static const String _stagingBaseNamePrefix = 'staging_';
  static const String _audioFileType = ".m4a";
  static const String _imageFileType = ".jpg";

  // a file name does not include the file suffix/type, like .png
  String _buildFileName() {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return "user-id_${_userId}_study-id_${_studyId}_$timestamp";
  }

  static Future<Directory?> _getMultimodalTempDirectory() async {
    try {
      final tempAppData = await getTemporaryDirectory();
      final multimodalTempDirectory = Directory(
        "${tempAppData.path}/multimodal-temp",
      );

      if (!await multimodalTempDirectory.exists()) {
        await multimodalTempDirectory.create(recursive: true);
      }

      return multimodalTempDirectory;
    } catch (e) {
      StudyULogger.error(e);
      return null;
    }
  }

  static Future<Directory> _getMultimodalUploadDirectory() async {
    final appData = await getApplicationDocumentsDirectory();
    final multimodalUploadDirectory = Directory(
      "${appData.path}/multimodal-upload",
    );
    await multimodalUploadDirectory.create(recursive: true);
    return multimodalUploadDirectory;
  }

  static Future<void> moveStagingFileToUploadDirectory(
    String stagingFilePath,
    String blobId,
  ) async {
    final stagingFile = File(stagingFilePath);
    final uploadDirectory = await _getMultimodalUploadDirectory();
    final uploadFile = File(path.join(uploadDirectory.path, [blobId].join()));
    await stagingFile.rename(uploadFile.path);
  }

  static Future<List<FutureBlobFile>> getFutureBlobFiles() async {
    final uploadDirectory = await _getMultimodalUploadDirectory();
    final files = await uploadDirectory.list().toList();
    final futureBlobFiles = files.map((file) {
      final fileName = path.basename(file.path);
      return FutureBlobFile(file.path, fileName);
    }).toList();
    return futureBlobFiles;
  }

  Future<FutureBlobFile?> getStagingAudio() async {
    final temporaryMultimodalDirectory = await _getMultimodalTempDirectory();

    if (temporaryMultimodalDirectory == null) {
      return null;
    }

    final fileName = _buildFileName();
    final localFilePath = path.join(
      temporaryMultimodalDirectory.path,
      [
        TemporaryStorageHandler._stagingBaseNamePrefix,
        fileName,
        TemporaryStorageHandler._audioFileType,
      ].join(),
    );

    final futureBlobId = [
      fileName,
      TemporaryStorageHandler._audioFileType,
    ].join();
    return FutureBlobFile(localFilePath, futureBlobId);
  }

  Future<FutureBlobFile?> getStagingImage() async {
    final temporaryMultimodalDirectory = await _getMultimodalTempDirectory();

    if (temporaryMultimodalDirectory == null) {
      return null;
    }

    final fileName = _buildFileName();
    final localFilePath = path.join(
      temporaryMultimodalDirectory.path,
      [
        TemporaryStorageHandler._stagingBaseNamePrefix,
        fileName,
        TemporaryStorageHandler._imageFileType,
      ].join(),
    );

    final futureBlobId = [
      fileName,
      TemporaryStorageHandler._imageFileType,
    ].join();
    return FutureBlobFile(localFilePath, futureBlobId);
  }

  static Future<void> deleteAllStagingFiles() async {
    final temporaryMultimodalDirectory = await _getMultimodalTempDirectory();

    if (temporaryMultimodalDirectory == null) {
      StudyULogger.error("Temporary multimodal directory is null");
      return;
    }

    for (final file
        in await temporaryMultimodalDirectory
            .list()
            .where(
              (f) => path
                  .basename(f.path)
                  .startsWith(TemporaryStorageHandler._stagingBaseNamePrefix),
            )
            .toList()) {
      await file.delete();
    }
  }
}

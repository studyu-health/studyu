import 'package:archive/archive.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/file_download.dart';
import 'package:studyu_designer_v2/utils/json_format.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

extension StudyExportZipX on StudyExportData {
  Future<Archive> get archive async {
    final archive = Archive();
    final toCSVString = CSVStringEncoder();
    final toJsonString = JsonStringEncoder();

    final files = {
      'study_definition.json': prettyJson(study.toJson()),
      'measurements.csv': toCSVString(measurementsData),
      'measurements.json': toJsonString(measurementsData),
      'interventions.csv': toCSVString(interventionsData),
      'interventions.json': toJsonString(interventionsData),
    };

    files.forEach((filename, content) {
      final archiveFile = ArchiveFile.string(filename, content);
      archive.addFile(archiveFile);
    });

    for (final mediaFile in mediaData) {
      final content = await BlobStorageHandler().downloadObservation(mediaFile);
      final archiveFile = ArchiveFile(mediaFile, content.length, content);
      archive.addFile(archiveFile);
    }

    return archive;
  }

  Future<List<int>?> get encodedZip async => ZipEncoder().encode(await archive);

  String get defaultFilename =>
      '${study.title?.toKey() ?? ''}_${DateTime.now()}';

  Future downloadAsZip({String? filename}) async {
    filename ??= defaultFilename;
    return downloadBytes(
      bytes: (await encodedZip)!,
      filename: filename.ensureSuffix('.zip'),
    );
  }
}

extension StudyExportX on Study {
  bool canExport(User user) =>
      (canEdit(user) || publishedToRegistryResults) &&
      (participants?.isNotEmpty ?? false);

  String? exportDisabledReason(User user) {
    if (canExport(user)) return null;
    if (!canEdit(user) && !publishedToRegistryResults) {
      return tr.study_export_unavailable_no_permission_tooltip;
    }
    if (participants?.isEmpty ?? true) {
      return tr.study_export_unavailable_empty_tooltip;
    }
    return null;
  }
}

extension StudyDefinitionExportX on Study {
  void downloadDefinition() {
    final json = prettyJson((this as dynamic).toJson());
    final filename = '${title?.toKey() ?? ''}_study_definition.json';
    downloadFile(fileContent: json, filename: filename);
  }
}

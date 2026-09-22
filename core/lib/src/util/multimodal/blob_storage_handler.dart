import 'dart:io';
import 'dart:typed_data';

import 'package:studyu_core/env.dart' as env;
import 'package:supabase/supabase.dart';

class BlobStorageHandler() {
  static const String _observationsBucketName = 'observations';

  Future<void> uploadObservation(String blobPath, File file) async {
    await env.client.storage
        .from(_observationsBucketName)
        .upload(blobPath, file);
  }

  Future<Uint8List> downloadObservation(String blobPath) async {
    return await env.client.storage
        .from(_observationsBucketName)
        .download(blobPath);
  }

  Future<List<FileObject>> removeObservation(List<String> blobPaths) async {
    return await env.client.storage
        .from(_observationsBucketName)
        .remove(blobPaths);
  }
}

import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:web/web.dart' as web;

class StudyImport() {
  static Future<bool> importStudy(WidgetRef ref) async {
    final uploadInput = web.HTMLInputElement()
      ..type = 'file'
      ..accept = '.json';

    uploadInput.click();

    await uploadInput.onChange.first;

    if (uploadInput.files?.length == 0) return false;

    final file = uploadInput.files!.item(0)!;
    final reader = web.FileReader();

    reader.readAsText(file);
    await web.EventStreamProviders.loadEvent.forTarget(reader).first;

    final result = reader.result;
    if (result == null) return false;
    final content = (result as JSString).toDart;

    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      final study = Study.fromJson(json);

      final currentUser = ref.read(authRepositoryProvider).currentUser;
      if (currentUser == null) return false;

      final newDraft = study.duplicateAsDraft(currentUser.id);

      await ref.read(studyRepositoryProvider).save(newDraft);
      return true;
    } catch (e) {
      print('Failed to import study: $e');
      return false;
    }
  }
}

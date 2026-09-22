import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/preview.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  testWidgets(
    'live study remains authoritative while preview authorization completes',
    (tester) async {
      final state = AppState();
      final preview = Preview({
        'studyid': 'study-id',
      }, AppLanguage(const [Locale('en')]));
      final initialStudy = Study('study-id', 'owner-id')..title = 'A';
      final liveStudy = Study('study-id', 'owner-id')..title = 'B';
      final authorization = Completer<void>();

      state.updateStudy(initialStudy);
      preview.study = initialStudy;
      final authorizationResult = preview.handleAuthorization(
        'session',
        recoverSession: (_) => authorization.future,
      );
      await tester.pump();

      state.updateStudy(liveStudy);
      preview.study = liveStudy;
      authorization.complete();

      expect(await authorizationResult, isTrue);
      state.selectedStudy = preview.study;
      expect(preview.study, same(liveStudy));
      expect(state.selectedStudy, same(liveStudy));
    },
  );
}

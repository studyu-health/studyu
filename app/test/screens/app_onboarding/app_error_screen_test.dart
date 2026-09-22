import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/app_onboarding/app_error_screen.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  testWidgets('can be disposed while cached data is loading', (tester) async {
    final containsKey = Completer<bool>();
    const secureStorageChannel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      secureStorageChannel,
      (call) => call.method == 'containsKey' ? containsKey.future : null,
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        secureStorageChannel,
        null,
      );
    });

    await tester.pumpWidget(
      const MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: Locale('en'),
        home: AppErrorScreen(),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox());

    containsKey.complete(false);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('contacts the study team from the error screen', (tester) async {
    final study = Study('study-1', 'researcher-1')
      ..contact.email = 'researcher@example.org';
    final subject = StudySubject('subject-1', study.id, 'user-1', const [])
      ..study = study;
    final secureValues = <String, String>{
      cacheSubjectKey: jsonEncode(subject.toFullJson()),
      'selected_study_object_id': subject.id,
      'user_email': 'participant@example.org',
    };
    const secureStorageChannel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      secureStorageChannel,
      (call) async {
        final arguments = call.arguments as Map<Object?, Object?>;
        final key = arguments['key'] as String?;
        return switch (call.method) {
          'containsKey' => secureValues.containsKey(key),
          'read' => secureValues[key],
          _ => null,
        };
      },
    );

    String? launchedUrl;
    const urlLauncherChannel = MethodChannel('plugins.flutter.io/url_launcher');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      urlLauncherChannel,
      (call) async {
        if (call.method == 'launch') {
          launchedUrl =
              (call.arguments as Map<Object?, Object?>)['url']! as String;
          return true;
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        secureStorageChannel,
        null,
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        urlLauncherChannel,
        null,
      );
    });

    await tester.pumpWidget(
      const MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: Locale('en'),
        home: AppErrorScreen(selectedSubjectId: 'subject-1'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Contact study team'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Contact study team'));
    await tester.pumpAndSettle();

    expect(Uri.parse(launchedUrl!).path, 'researcher@example.org');
  });
}

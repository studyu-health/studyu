import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/active_subject_sync_controller.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  testWidgets(
    'offline Fitbit widget submission queues durable progress and returns to dashboard',
    (tester) async {
      const storageChannel = MethodChannel(
        'plugins.it_nomads.com/flutter_secure_storage',
      );
      const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
      final storage = <String, String>{};
      final directory = Directory.systemTemp.createTempSync(
        'studyu-questionnaire-',
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(storageChannel, (call) async {
            final args = call.arguments as Map<Object?, Object?>;
            final key = args['key'] as String?;
            return switch (call.method) {
              'write' => storage[key!] = args['value']! as String,
              'read' => storage[key],
              'containsKey' => storage.containsKey(key),
              'delete' => storage.remove(key),
              _ => null,
            };
          });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathChannel, (_) async => directory.path);
      final question = FitbitQuestion.withId(
        questionType: FitbitQuestion.questionType,
        types: [FitbitQuestionType.steps],
      );
      final period = CompletionPeriod(
        id: 'period',
        unlockTime: StudyUTimeOfDay(),
        lockTime: StudyUTimeOfDay(hour: 23, minute: 59),
      );
      final task = QuestionnaireTask.withId()
        ..title = 'Fitbit task'
        ..schedule.completionPeriods = [period]
        ..questions.questions = [question];
      final study = Study('study', 'user')
        ..interventions = [
          Intervention('intervention', 'Intervention'),
          Intervention('other', 'Other'),
        ]
        ..observations = [task];
      study.schedule.includeBaseline = false;
      final subject = StudySubject.fromStudy(study, 'user', [
        'intervention',
        'other',
      ], null)..startedAt = DateTime.now().subtract(const Duration(days: 1));
      final state = AppState()..activeSubject = subject;
      FitbitHandler.debugAuthorizeForOfflineParticipationOverride = (
        _,
        _,
      ) async => fail('must not authorize offline');
      appConnectionStatusController.setStatus(
        AppConnectionStatus.deviceOffline,
      );
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () => context.push('/task'),
                child: const Text('Open task'),
              ),
            ),
          ),
          GoRoute(
            path: '/task',
            builder: (_, _) =>
                TaskScreen(taskInstance: TaskInstance(task, period.id)),
          ),
        ],
      );
      addTearDown(() {
        router.dispose();
        state.dispose();
        ActiveSubjectSyncController.instance.debugResetForTesting();
        appConnectionStatusController.reset();
        FitbitHandler.debugAuthorizeForOfflineParticipationOverride = null;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(storageChannel, null);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(pathChannel, null);
        if (directory.existsSync()) directory.deleteSync(recursive: true);
      });
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: state,
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
          ),
        ),
      );
      await tester.tap(find.text('Open task'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sync Fitbit Data'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Complete task'));
      await tester.tap(find.text('Complete task'));
      await tester.pumpAndSettle();
      expect(find.text('Open task'), findsOneWidget);
      expect(find.text('Fitbit task'), findsNothing);
      expect(subject.progress, hasLength(1));
      final requests = await Cache.loadDeferredFitbitRequests();
      expect(requests, hasLength(1));
      expect(requests.single.questionId, question.id);
      expect(requests.single.periodId, period.id);
      expect((await Cache.loadSubject()).progress, subject.progress);
      expect(ActiveSubjectSyncController.instance.debugIsPending, isTrue);
      await tester.pumpWidget(const SizedBox());
      ActiveSubjectSyncController.instance.onAccountCleared();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
    },
  );
}

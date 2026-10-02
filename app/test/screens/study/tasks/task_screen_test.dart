import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/active_subject_sync_controller.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_core/core.dart';

StudySubject _buildSubject() {
  final study = Study('study', 'user')
    ..interventions = [Intervention('intervention-a', 'Intervention A')];

  return StudySubject.fromStudy(study, 'user', ['intervention-a'], null)
    ..startedAt = DateTime.now().subtract(const Duration(days: 1));
}

const _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

/// Pumps a minimal app and returns the [BuildContext] `handleTaskCompletion`
/// needs: a `Provider<AppState>` ancestor, a `ScaffoldMessenger` to show
/// snackbars on, and `AppLocalizations`.
Future<BuildContext> _pumpHostContext(
  WidgetTester tester, {
  required AppState appState,
}) async {
  late BuildContext capturedContext;
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    ),
  );
  return capturedContext;
}

void main() {
  final storage = <String, String>{};
  var failSecureStorageWrites = false;

  setUp(() {
    storage.clear();
    failSecureStorageWrites = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (call) async {
          final arguments = call.arguments as Map<Object?, Object?>;
          final key = arguments['key'] as String?;
          return switch (call.method) {
            'write' =>
              failSecureStorageWrites
                  ? throw PlatformException(code: 'write_error')
                  : storage[key!] = arguments['value']! as String,
            'read' => storage[key],
            'delete' => storage.remove(key),
            'containsKey' => storage.containsKey(key),
            _ => throw UnimplementedError(call.method),
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
  });

  testWidgets('returns true and shows nothing when the completion callback '
      'succeeds', (tester) async {
    final appState = AppState()..activeSubject = _buildSubject();
    addTearDown(appState.dispose);
    final context = await _pumpHostContext(tester, appState: appState);

    final result = await handleTaskCompletion(context, (_) {});
    await tester.pump();

    expect(result, isTrue);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets(
    'returns true (saved offline, will sync) when the completion callback '
    'fails but the local cache write succeeds',
    (tester) async {
      final appState = AppState()..activeSubject = _buildSubject();
      addTearDown(appState.dispose);
      final context = await _pumpHostContext(tester, appState: appState);

      final result = await handleTaskCompletion(context, (
        StudySubject? subject,
      ) {
        subject!.progress.add(
          SubjectProgress(
            subjectId: subject.id,
            interventionId: 'intervention-a',
            taskId: 'task',
            resultType: 'bool',
            result: Result<bool>.app(
              type: 'bool',
              periodId: 'period',
              result: true,
            ),
          )..completedAt = DateTime.utc(2020),
        );
        throw Exception('network unreachable');
      });
      await tester.pump();

      expect(result, isTrue);
      expect(find.byType(SnackBar), findsNothing);
      ActiveSubjectSyncController.instance.onAccountCleared();
    },
  );

  testWidgets(
    'returns false and shows a retry snackbar when both the completion '
    'callback and the local cache write fail',
    (tester) async {
      final appState = AppState()..activeSubject = _buildSubject();
      addTearDown(appState.dispose);
      final context = await _pumpHostContext(tester, appState: appState);
      failSecureStorageWrites = true;

      final result = await handleTaskCompletion(context, (
        StudySubject? subject,
      ) {
        subject!.progress.add(
          SubjectProgress(
            subjectId: subject.id,
            interventionId: 'intervention-a',
            taskId: 'task',
            resultType: 'bool',
            result: Result<bool>.app(
              type: 'bool',
              periodId: 'period',
              result: true,
            ),
          )..completedAt = DateTime.utc(2020),
        );
        throw Exception('network unreachable');
      });
      await tester.pump();

      expect(result, isFalse);
      expect(find.text('Could not save results'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    },
  );
  testWidgets(
    'task completion survives an active-subject replacement during its save',
    (tester) async {
      final original = _buildSubject();
      final state = AppState()..activeSubject = original;
      final context = await _pumpHostContext(tester, appState: state);
      final started = Completer<void>();
      final release = Completer<void>();
      final completion = handleTaskCompletion(context, (
        StudySubject? subject,
      ) async {
        started.complete();
        await release.future;
        subject!.progress.add(
          SubjectProgress(
            subjectId: subject.id,
            interventionId: 'intervention-a',
            taskId: 'first',
            resultType: 'bool',
            result: Result<bool>.app(
              type: 'bool',
              periodId: 'period',
              result: true,
            ),
          )..completedAt = DateTime.utc(2020),
        );
        throw Exception('network unreachable');
      });
      await started.future;
      final replacement = StudySubject.fromJson(original.toFullJson());
      ActiveSubjectSyncController.instance.onSynchronized!(replacement);
      release.complete();
      expect(await completion, isTrue);
      expect(state.activeSubject!.progress.single.taskId, 'first');
      expect(
        await handleTaskCompletion(context, (StudySubject? subject) {
          subject!.progress.add(
            SubjectProgress(
              subjectId: subject.id,
              interventionId: 'intervention-a',
              taskId: 'second',
              resultType: 'bool',
              result: Result<bool>.app(
                type: 'bool',
                periodId: 'period',
                result: true,
              ),
            )..completedAt = DateTime.utc(2020, 1, 2),
          );
          throw Exception('network unreachable');
        }),
        isTrue,
      );
      expect((await Cache.loadSubject()).progress.map((p) => p.taskId), [
        'first',
        'second',
      ]);
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    },
  );
  testWidgets('queue overflow keeps the task open and shows an error', (
    tester,
  ) async {
    final state = AppState()..activeSubject = _buildSubject();
    addTearDown(state.dispose);
    final context = await _pumpHostContext(tester, appState: state);
    final result = await handleTaskCompletion(
      context,
      (_) => throw DeferredFitbitQueueFullException(),
    );
    await tester.pump();
    expect(result, isFalse);
    expect(
      find.text(
        'Too many Fitbit tasks are waiting to sync. Sync pending tasks before completing another task.',
      ),
      findsOneWidget,
    );
  });
  testWidgets(
    'a failed callback without a saved result cannot complete a task',
    (tester) async {
      final state = AppState()..activeSubject = _buildSubject();
      final context = await _pumpHostContext(tester, appState: state);
      final result = await handleTaskCompletion(
        context,
        (_) => throw StateError('no result'),
      );
      await tester.pump();
      expect(result, isFalse);
      expect(find.text('Could not save results'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    },
  );
  testWidgets('failed cache persistence rolls back the in-memory completion', (
    tester,
  ) async {
    final state = AppState()..activeSubject = _buildSubject();
    final context = await _pumpHostContext(tester, appState: state);
    failSecureStorageWrites = true;
    final result = await handleTaskCompletion(context, (StudySubject? subject) {
      subject!.progress.add(
        SubjectProgress(
          subjectId: subject.id,
          interventionId: 'intervention-a',
          taskId: 'task',
          resultType: 'bool',
          result: Result<bool>.app(
            type: 'bool',
            periodId: 'period',
            result: true,
          ),
        )..completedAt = DateTime.utc(2020),
      );
      throw StateError('offline');
    });
    await tester.pump();
    expect(result, isFalse);
    expect(state.activeSubject!.progress, isEmpty);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
}

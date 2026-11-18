import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_widget.dart';
import 'package:studyu_core/core.dart';

void main() {
  for (final refreshStudy in [false, true]) {
    testWidgets(
      'photo answer survives camera navigation with study refresh: $refreshStudy',
      (tester) async {
        final h = _PhotoTaskHarness();
        await h.pump(tester);
        await tester.tap(find.text(h.loc.take_a_photo));
        await tester.pumpAndSettle();
        if (refreshStudy) {
          h.appState.updateStudy(Study.fromJson(h.study.toJson()));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Return captured photo'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text(h.loc.photo_captured), findsOneWidget);
        final payload = h
            .getQuestionnaire(tester)
            .validateSyncAndBuildPayload();
        expect(payload?.answers[h.question.id]?.response, same(h.image));
      },
    );
  }

  testWidgets('study metadata changes preserve the photo answer', (
    tester,
  ) async {
    final h = _PhotoTaskHarness();
    await h.pump(tester);
    await h.capture(tester);
    final questionnaire = h.getQuestionnaire(tester);
    final replacement = Study.fromJson(h.study.toJson())
      ..title = 'Updated study';
    h.appState.updateStudy(replacement);
    await tester.pumpAndSettle();

    expect(h.getQuestionnaire(tester), same(questionnaire));
    final payload = questionnaire.validateSyncAndBuildPayload();
    expect(payload?.answers[h.question.id]?.response, same(h.image));
  });

  testWidgets('new required questions reset stale questionnaire validation', (
    tester,
  ) async {
    final h = _PhotoTaskHarness();
    await h.pump(tester);
    await h.capture(tester);
    final taskState = tester.state(find.byType(TaskScreen));
    final questionnaire = h.getQuestionnaire(tester);
    expect(questionnaire.validateSyncAndBuildPayload(), isNotNull);

    final replacement = Study.fromJson(h.study.toJson());
    final task = replacement.observations.single as QuestionnaireTask;
    final requiredQuestion = BooleanQuestion.withId()
      ..prompt = 'Required question';
    task.questions.questions = [requiredQuestion, ...task.questions.questions];
    h.appState.updateStudy(replacement);
    await tester.pumpAndSettle();

    expect(tester.state(find.byType(TaskScreen)), same(taskState));
    expect(h.getQuestionnaire(tester), isNot(same(questionnaire)));
    expect(
      find.text(requiredQuestion.prompt!, findRichText: true),
      findsOneWidget,
    );
    expect(h.getQuestionnaire(tester).validateSyncAndBuildPayload(), isNull);
  });

  testWidgets('question edits with unchanged IDs reset questionnaire state', (
    tester,
  ) async {
    final h = _PhotoTaskHarness();
    await h.pump(tester);
    await h.capture(tester);
    final questionnaire = h.getQuestionnaire(tester);
    final replacement = Study.fromJson(h.study.toJson());
    final task = replacement.observations.single as QuestionnaireTask;
    task.questions.questions.single.prompt = 'Updated photo question';
    h.appState.updateStudy(replacement);
    await tester.pumpAndSettle();

    expect(h.getQuestionnaire(tester), isNot(same(questionnaire)));
    expect(
      find.text('Updated photo question', findRichText: true),
      findsOneWidget,
    );
    expect(h.getQuestionnaire(tester).validateSyncAndBuildPayload(), isNull);
  });

  testWidgets('definition changes during capture discard the obsolete answer', (
    tester,
  ) async {
    final h = _PhotoTaskHarness();
    await h.pump(tester);
    await tester.tap(find.text(h.loc.take_a_photo));
    await tester.pumpAndSettle();
    final replacement = Study.fromJson(h.study.toJson());
    final task = replacement.observations.single as QuestionnaireTask;
    task.questions.questions.single.prompt = 'Updated photo question';
    h.appState.updateStudy(replacement);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Return captured photo'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(h.loc.take_a_photo), findsOneWidget);
    expect(h.getQuestionnaire(tester).validateSyncAndBuildPayload(), isNull);
  });
}

class _PhotoTaskHarness() {
  late AppState appState;
  late Study study;
  late ImageCapturingQuestion question;
  late FutureBlobFile image;
  late AppLocalizations loc;

  Future<void> pump(WidgetTester tester) async {
    final directory = Directory.systemTemp.createTempSync('studyu-photo-');
    Directory(path.join(directory.path, 'multimodal-temp')).createSync();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (_) async => directory.path,
    );

    question = ImageCapturingQuestion.withId()..prompt = 'Take a test photo';
    final task = QuestionnaireTask.withId()
      ..title = 'Photo survey'
      ..questions.questions = [question];
    study = Study('test-study', 'test-owner')..observations = [task];
    appState = AppState()
      ..activeSubject = StudySubject.fromStudy(study, 'test-user', [], null);
    image = FutureBlobFile(path.join(directory.path, 'photo.jpg'), 'photo.jpg');
    final instance = TaskInstance(
      task,
      task.schedule.completionPeriods.single.id,
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => TaskScreen(taskInstance: instance),
        ),
        GoRoute(
          path: '/${RouteNames.capturePicture}',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop(image),
              child: const Text('Return captured photo'),
            ),
          ),
        ),
      ],
    );
    addTearDown(() async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await TemporaryStorageHandler.deleteAllStagingFiles();
        await directory.delete(recursive: true);
      });
      router.dispose();
      appState.dispose();
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
    });

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    loc = AppLocalizations.of(tester.element(find.byType(TaskScreen)))!;
  }

  QuestionnaireWidgetState getQuestionnaire(WidgetTester tester) =>
      tester.state<QuestionnaireWidgetState>(find.byType(QuestionnaireWidget));

  Future<void> capture(WidgetTester tester) async {
    await tester.tap(find.text(loc.take_a_photo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Return captured photo'));
    await tester.pumpAndSettle();
  }
}

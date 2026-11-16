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
        final directory = Directory.systemTemp.createTempSync('studyu-photo-');
        Directory(path.join(directory.path, 'multimodal-temp')).createSync();
        const channel = MethodChannel('plugins.flutter.io/path_provider');
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          (_) async => directory.path,
        );

        final question = ImageCapturingQuestion.withId()
          ..prompt = 'Take a test photo';
        final task = QuestionnaireTask.withId()
          ..title = 'Photo survey'
          ..questions.questions = [question];
        final study = Study('test-study', 'test-owner')..observations = [task];
        final appState = AppState()
          ..activeSubject = StudySubject.fromStudy(
            study,
            'test-user',
            [],
            null,
          );
        final image = FutureBlobFile(
          path.join(directory.path, 'photo.jpg'),
          'photo.jpg',
        );
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
        final loc = AppLocalizations.of(
          tester.element(find.byType(TaskScreen)),
        )!;
        await tester.tap(find.text(loc.take_a_photo));
        await tester.pumpAndSettle();
        if (refreshStudy) {
          appState.updateStudy(study);
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Return captured photo'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text(loc.photo_captured), findsOneWidget);
        final questionnaire = tester.state<QuestionnaireWidgetState>(
          find.byType(QuestionnaireWidget),
        );
        final payload = questionnaire.validateSyncAndBuildPayload();
        expect(payload?.answers[question.id]?.response, same(image));
      },
    );
  }
}

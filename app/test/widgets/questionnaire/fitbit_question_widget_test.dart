import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/widgets/questionnaire/questions/fitbit_question_widget.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  tearDown(appConnectionStatusController.reset);
  testWidgets('offline sync creates an empty answer without OAuth', (
    tester,
  ) async {
    final study = Study('study', 'user')
      ..interventions = [Intervention('i', 'Intervention')];
    final state = AppState()
      ..activeSubject = (StudySubject.fromStudy(study, 'user', ['i'], null)
        ..startedAt = DateTime.utc(2020));
    final question = FitbitQuestion.withId(
      questionType: FitbitQuestion.questionType,
      types: [FitbitQuestionType.steps],
    );
    Answer? answer;
    appConnectionStatusController.setStatus(AppConnectionStatus.deviceOffline);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FitbitQuestionWidget(
              question: question,
              taskId: 'task',
              onDone: (value) => answer = value,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Sync Fitbit Data'));
    await tester.pumpAndSettle();
    expect(answer?.question, question.id);
    expect(answer?.response, isEmpty);
    expect(
      find.text('Fitbit data will sync when a connection is available.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
}

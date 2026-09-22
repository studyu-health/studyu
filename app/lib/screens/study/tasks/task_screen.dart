import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/tasks/intervention/checkmark_task_widget.dart';
import 'package:studyu_app/screens/study/tasks/observation/questionnaire_task_widget.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_core/core.dart';

class const TaskScreen({required final TaskInstance taskInstance, super.key})
    extends StatefulWidget {
  static MaterialPageRoute<bool> routeFor({
    required TaskInstance taskInstance,
  }) =>
      MaterialPageRoute(builder: (_) => TaskScreen(taskInstance: taskInstance));

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState() extends State<TaskScreen> {
  late TaskInstance taskInstance;
  StudySubject? subject;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subject = context.watch<AppState>().activeSubject;
    taskInstance = TaskInstance.fromInstanceId(
      widget.taskInstance.id,
      study: subject!.study,
    );
  }

  Widget _buildTask() {
    switch (taskInstance.task) {
      case final CheckmarkTask checkmarkTask:
        return SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                HtmlText(taskInstance.task.header, centered: true),
                const SizedBox(height: 20),
                CheckmarkTaskWidget(
                  task: checkmarkTask,
                  key: UniqueKey(),
                  completionPeriod: taskInstance.completionPeriod,
                ),
              ],
            ),
          ),
        );
      case final QuestionnaireTask questionnaireTask:
        return QuestionnaireTaskWidget(
          task: questionnaireTask,
          key: UniqueKey(),
          completionPeriod: taskInstance.completionPeriod,
        );
      default:
        throw ArgumentError('Task ${taskInstance.task.type} not supported');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(taskInstance.task.title ?? '')),
      body: Padding(padding: const EdgeInsets.all(16), child: _buildTask()),
    );
  }
}

Future<void> handleTaskCompletion(
  BuildContext context,
  Function(StudySubject?) completionCallback,
) async {
  final state = context.read<AppState>();
  final activeSubject = state.activeSubject;
  try {
    if (state.trackParticipantProgress) {
      await completionCallback(activeSubject);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.preview_mode_results_not_saved,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } catch (exception) {
    debugPrint("Could not save results: $exception");
    try {
      await Cache.storeSubject(activeSubject);
      debugPrint("Store subject in cache");
    } catch (cacheError) {
      debugPrint("Could not cache results: $cacheError");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.could_not_save_results),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => handleTaskCompletion(context, completionCallback),
          ),
        ),
      );
    }
  }
}

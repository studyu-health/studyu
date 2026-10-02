import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/tasks/intervention/checkmark_task_widget.dart';
import 'package:studyu_app/screens/study/tasks/observation/questionnaire_task_widget.dart';
import 'package:studyu_app/util/active_subject_sync_controller.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

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

/// Runs [completionCallback] and returns whether the task's result is safe
/// to treat as saved: either tracked remotely, saved to the local offline
/// cache ("saved offline, will sync"), or exempt in preview mode.
///
/// Returns `false` only when the result could not be saved anywhere — the
/// caller must not dismiss the task as complete in that case.
Future<bool> handleTaskCompletion(
  BuildContext context,
  Function(StudySubject?) completionCallback,
) async {
  final state = context.read<AppState>();
  final activeSubject = state.activeSubject;
  final previousProgress =
      activeSubject?.progress.toList() ?? <SubjectProgress>[];
  StudySubject? completionSubject() {
    final current = state.activeSubject;
    if (activeSubject != null &&
        current != null &&
        !identical(current, activeSubject) &&
        Cache.isCompatibleCachedSubject(
          localSubject: activeSubject,
          remoteSubject: current,
        )) {
      current.progress = Cache.buildProgressSyncPlan(
        localSubject: activeSubject,
        remoteSubject: current,
      ).mergedProgress;
      return current;
    }
    return activeSubject;
  }

  try {
    if (state.trackParticipantProgress) {
      await completionCallback(activeSubject);
      final current = completionSubject();
      if (!identical(current, activeSubject)) {
        await Cache.storeSubject(current);
        ActiveSubjectSyncController.instance.markSynchronizationPending();
      }
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
    return true;
  } catch (exception) {
    debugPrint("Could not save results: $exception");
    if (exception is DeferredFitbitQueueFullException) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.fitbit_queue_full),
          ),
        );
      }
      return false;
    }
    final status = connectionStatusFromError(exception);
    if (status != null) appConnectionStatusController.setStatus(status);
    try {
      if (activeSubject == null ||
          activeSubject.progress.length <= previousProgress.length) {
        throw StateError('The task result was not recorded.');
      }
      await Cache.storeSubject(completionSubject());
      ActiveSubjectSyncController.instance.markSynchronizationPending();
      debugPrint("Store subject in cache");
      return true;
    } catch (cacheError) {
      activeSubject?.progress = previousProgress;
      debugPrint("Could not cache results: $cacheError");
      if (!context.mounted) return false;
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
      return false;
    }
  }
}

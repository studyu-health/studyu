import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/string_extensions.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class const FitbitQuestionWidget({
  super.key,
  required final FitbitQuestion question,
  required final String taskId,
  required final Function(Answer) onDone,
}) extends QuestionWidget {
  @override
  State<FitbitQuestionWidget> createState() => _FitbitQuestionWidgetState();
}

class _FitbitQuestionWidgetState() extends State<FitbitQuestionWidget> {
  late List<FitbitData> value;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    value = [];
  }

  Future<void> _syncFitbitData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final study = context.read<AppState>().activeSubject!.study;
      final data = await FitbitHandler.syncFitbitData(
        study,
        widget.question,
        widget.taskId,
        context.read<AppState>().activeSubject!,
      );

      setState(() {
        value = data;
        _isLoading = false;
      });
      if (!mounted) return;
      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.fitbit_data_not_synced),
          ),
        );
        return;
      }

      _showSyncSuccessSnackbar(data);

      widget.onDone(widget.question.constructAnswer(value));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .error_syncing_fitbit_data(e.toString()),
          ),
        ),
      );
      StudyULogger.error('Error syncing Fitbit data: $e');
    }
  }

  Map<String, Map<String, DateTime>> _calculateSyncDates(
    List<FitbitData> data,
  ) {
    final Map<String, DateTime> earliestDates = {};
    final Map<String, DateTime> latestDates = {};

    for (final d in data) {
      if (!earliestDates.containsKey(d.type) ||
          d.dateTime.isBefore(earliestDates[d.type]!)) {
        earliestDates[d.type] = d.dateTime;
      }
      if (!latestDates.containsKey(d.type) ||
          d.dateTime.isAfter(latestDates[d.type]!)) {
        latestDates[d.type] = d.dateTime;
      }
    }
    return {'earliest': earliestDates, 'latest': latestDates};
  }

  void _showSyncDetailsDialog(Map<String, Map<String, DateTime>> syncDates) {
    final earliestDates = syncDates['earliest']!;
    final latestDates = syncDates['latest']!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.fitbit_data_synced_dialog_title,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.fitbit_data_synced_info),
              for (final type in earliestDates.keys)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.toPascalCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        AppLocalizations.of(context)!.fitbit_data_earliest_date(
                          //textual representation of the date
                          DateFormat.yMMMd().add_jm().format(
                            earliestDates[type]!,
                          ),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.fitbit_data_latest_date(
                          DateFormat.yMMMd().add_jm().format(
                            latestDates[type]!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context)!.fitbit_data_close_btn),
            ),
          ],
        );
      },
    );
  }

  void _showSyncSuccessSnackbar(List<FitbitData> data) {
    //calculate earliest and latest date for each data type

    final syncDates = _calculateSyncDates(data);
    final earliestDates = syncDates['earliest']!;
    final latestDates = syncDates['latest']!;

    for (final d in data) {
      if (!earliestDates.containsKey(d.type) ||
          d.dateTime.isBefore(earliestDates[d.type]!)) {
        earliestDates[d.type] = d.dateTime;
      }
      if (!latestDates.containsKey(d.type) ||
          d.dateTime.isAfter(latestDates[d.type]!)) {
        latestDates[d.type] = d.dateTime;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.fitbit_data_synced,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.fitbit_data_details_btn,
          textColor: Theme.of(context).colorScheme.onSecondary,
          onPressed: () {
            _showSyncDetailsDialog(syncDates);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
          onPressed: _isLoading ? null : _syncFitbitData,
          child: _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                )
              : Text(AppLocalizations.of(context)!.sync_fitbit_data),
        ),
      ],
    );
  }
}

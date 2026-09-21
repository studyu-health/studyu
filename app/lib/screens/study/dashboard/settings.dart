import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_app/util/date_time_preferences.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/localization.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_app/widgets/recovery_phrase_content.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';
import 'package:studyu_app/widgets/title_description_layout.dart';
import 'package:studyu_app/widgets/why_dialog.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase/supabase.dart' show PostgrestException;

class const Settings({super.key}) extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState() extends State<Settings> {
  static const _selectorWidth = 180.0;

  Locale? _selectedValue;
  StudySubject? subject;

  @override
  void initState() {
    super.initState();
    _selectedValue = context.read<AppLanguage>().appLocal;
    subject = context.read<AppState>().activeSubject;
  }

  List<DropdownMenuItem<Locale>> _buildDropdownItems(BuildContext context) {
    final dropDownItems = <DropdownMenuItem<Locale>>[
      DropdownMenuItem(
        child: Text(AppLocalizations.of(context)!.use_device_language),
      ),
    ];

    for (final locale in AppLocalizations.supportedLocales) {
      dropDownItems.add(
        DropdownMenuItem(
          value: locale,
          child: Text(localeName(context, locale.languageCode)!),
        ),
      );
    }

    return dropDownItems;
  }

  String _dateFormatLabel(
    AppLocalizations localizations,
    DateFormatPreference format,
  ) => switch (format) {
    DateFormatPreference.iso => localizations.date_format_iso,
    DateFormatPreference.european => localizations.date_format_european,
    DateFormatPreference.us => localizations.date_format_us,
    DateFormatPreference.german => localizations.date_format_german,
  };

  String _timeFormatLabel(
    AppLocalizations localizations,
    TimeFormatPreference format,
  ) => switch (format) {
    TimeFormatPreference.h24 => localizations.time_format_24_hour,
    TimeFormatPreference.h12 => localizations.time_format_12_hour,
  };

  void _showPreferenceSaveError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!
              .error_occurred_with_message(error.toString()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeSubject = context.watch<AppState>().activeSubject;
    final dateTimePreferences = context.watch<DateTimePreferences?>();
    final now = DateTime.now();
    final dashboardHasTasks =
        activeSubject?.startedAt != null &&
        activeSubject!.selectedInterventionIds.length >=
            StudySchedule.numberOfInterventions &&
        !activeSubject.startedAt!.isAfter(now) &&
        activeSubject.scheduleFor(now).isNotEmpty;
    final destructiveButtonStyle = OutlinedButton.styleFrom(
      foregroundColor: theme.colorScheme.error,
      side: BorderSide(color: theme.colorScheme.error),
    );
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: context.pop),
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: TitleDescriptionLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // General section header
            Text(
              AppLocalizations.of(context)!.general_section,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Language card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.language, color: theme.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.language,
                        style: theme.textTheme.bodyMedium!.copyWith(),
                      ),
                    ),
                    SizedBox(
                      width: _selectorWidth,
                      child: DropdownButton<Locale>(
                        isExpanded: true,
                        value: _selectedValue,
                        style: theme.textTheme.bodyMedium,
                        hint: Text(
                          AppLocalizations.of(context)!.use_device_language,
                        ),
                        underline: const SizedBox(),
                        items: _buildDropdownItems(context),
                        onChanged: (value) async {
                          setState(() {
                            _selectedValue = value;
                          });
                          await context.read<AppLanguage>().changeLanguage(
                            value,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: theme.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.date_format,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    SizedBox(
                      width: _selectorWidth,
                      child: DropdownButton<DateFormatPreference?>(
                        isExpanded: true,
                        value: dateTimePreferences?.dateFormat,
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem<DateFormatPreference?>(
                            child: Text(AppLocalizations.of(context)!.system),
                          ),
                          ...DateFormatPreference.values.map(
                            (format) => DropdownMenuItem(
                              value: format,
                              child: Text(
                                _dateFormatLabel(
                                  AppLocalizations.of(context)!,
                                  format,
                                ),
                              ),
                            ),
                          ),
                        ],
                        onChanged: dateTimePreferences == null
                            ? null
                            : (value) async {
                                try {
                                  await dateTimePreferences.changeDateFormat(
                                    value,
                                  );
                                } catch (error) {
                                  if (mounted) _showPreferenceSaveError(error);
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: theme.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.time_format,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    SizedBox(
                      width: _selectorWidth,
                      child: DropdownButton<TimeFormatPreference?>(
                        isExpanded: true,
                        value: dateTimePreferences?.timeFormat,
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem<TimeFormatPreference?>(
                            child: Text(AppLocalizations.of(context)!.system),
                          ),
                          ...TimeFormatPreference.values.map(
                            (format) => DropdownMenuItem(
                              value: format,
                              child: Text(
                                _timeFormatLabel(
                                  AppLocalizations.of(context)!,
                                  format,
                                ),
                              ),
                            ),
                          ),
                        ],
                        onChanged: dateTimePreferences == null
                            ? null
                            : (value) async {
                                try {
                                  await dateTimePreferences.changeTimeFormat(
                                    value,
                                  );
                                } catch (error) {
                                  if (mounted) _showPreferenceSaveError(error);
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              AppLocalizations.of(context)!.study_settings_section,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Dashboard showcase reset
            Card(
              key: const ValueKey('settings_dashboard_showcase_card'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.help_outline, color: theme.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.dashboard_tour,
                        style: theme.textTheme.bodyMedium!.copyWith(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      key: const ValueKey(
                        'settings_show_dashboard_showcase_again',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      onPressed: dashboardHasTasks
                          ? () async {
                              await DashboardShowcaseStorage.reset();
                              if (!context.mounted) return;
                              context.pop(true);
                            }
                          : null,
                      child: Text(AppLocalizations.of(context)!.show_again),
                    ),
                  ],
                ),
              ),
            ),
            if (context.watch<AppState>().showParticipantRecovery) ...[
              const SizedBox(height: 8),
              const RecoveryPhraseWidget(),
            ],
            const SizedBox(height: 8),

            Card(
              key: const ValueKey('settings_study_information_card'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.science_outlined, color: theme.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.study_information,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    OutlinedButton(
                      key: const ValueKey('settings_study_information'),
                      onPressed: () =>
                          context.push('/${RouteNames.studyInformation}'),
                      child: Text(
                        AppLocalizations.of(context)!.view_study_information,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            //wrap buttons to fill the width for mobile phones but for web fixed width
            Text(
              textAlign: TextAlign.start,
              AppLocalizations.of(context)!.participation_options_section,
              style: theme.textTheme.titleLarge,
            ),
            Align(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width < 600
                      ? double.infinity
                      : 400,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(MdiIcons.exitToApp),
                      label: Text(AppLocalizations.of(context)!.opt_out),
                      style: destructiveButtonStyle,
                      onPressed: () async {
                        TransitionRoute<bool>? dialogRoute;
                        final completed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            dialogRoute ??= ModalRoute.of<bool>(dialogContext);
                            return OptOutAlertDialog(subject: subject);
                          },
                        );
                        await dialogRoute?.completed;
                        if (!context.mounted || completed != true) return;
                        context.go('/${RouteNames.welcome}');
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: Text(AppLocalizations.of(context)!.delete_data),
                      style: destructiveButtonStyle,
                      onPressed: () async {
                        TransitionRoute<bool>? dialogRoute;
                        final completed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            dialogRoute ??= ModalRoute.of<bool>(dialogContext);
                            return DeleteAlertDialog(subject: subject);
                          },
                        );
                        await dialogRoute?.completed;
                        if (!context.mounted || completed != true) return;
                        context.go('/${RouteNames.welcome}');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class const RecoveryPhraseWidget({super.key}) extends StatefulWidget {
  @override
  State<RecoveryPhraseWidget> createState() => _RecoveryPhraseWidgetState();
}

class _RecoveryPhraseWidgetState() extends State<RecoveryPhraseWidget> {
  bool _hasExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Card(
      key: const ValueKey('settings_recovery_phrase_card'),
      child: ExpansionTile(
        leading: Icon(Icons.lock_outline, color: theme.primaryColor),
        title: Text(
          localizations.recovery_phrase_header,
          style: theme.textTheme.bodyMedium,
        ),
        onExpansionChanged: (expanded) {
          if (expanded && !_hasExpanded) {
            setState(() => _hasExpanded = true);
          }
        },
        children: [
          if (_hasExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: theme.colorScheme.surface),
                child: Column(
                  children: [
                    StudyOnboardingDescription(
                      text: localizations.recovery_phrase_description,
                      actionLabel: localizations.recovery_phrase_why,
                      onAction: () => showDialog(
                        context: context,
                        builder: (context) => WhyDialog(
                          content: localizations.recovery_phrase_reason,
                        ),
                      ),
                    ),
                    const RecoveryPhraseContent(
                      useGridLayout: false,
                      showConfirmation: false,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _connectivityErrorMessage(
  BuildContext context,
  AppConnectionStatus status,
) {
  return switch (status) {
    AppConnectionStatus.deviceOffline => AppLocalizations.of(
      context,
    )!.no_internet_connection,
    AppConnectionStatus.backendUnavailable => AppLocalizations.of(
      context,
    )!.connection_banner_backend_unavailable,
    AppConnectionStatus.healthy => '',
  };
}

SnackBar _buildStatusSnackBar(BuildContext context, String message) {
  final theme = Theme.of(context);
  return SnackBar(
    backgroundColor: theme.colorScheme.primary,
    content: Text(
      message,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class const OptOutAlertDialog({super.key, required final StudySubject? subject})
    extends StatefulWidget {
  @override
  State<OptOutAlertDialog> createState() => _OptOutAlertDialogState();
}

class _OptOutAlertDialogState() extends State<OptOutAlertDialog> {
  bool acknowledged = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.leave_study_keep_data_title),
      actionsOverflowButtonSpacing: 12,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.leave_study_keep_data_body(
                widget.subject!.study.title ?? l10n.not_available,
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(
                l10n.acknowledge_consequences,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              value: acknowledged,
              onChanged: (value) {
                setState(() => acknowledged = value ?? false);
              },
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(onPressed: context.pop, child: Text(l10n.stay_in_study)),
        ElevatedButton.icon(
          icon: const Icon(MdiIcons.exitToApp),
          label: Text(l10n.leave_keep_data),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          onPressed: acknowledged
              ? () async {
                  try {
                    await widget.subject!.softDelete();
                  } catch (error) {
                    final status = connectionStatusFromError(error);
                    if (status != null) {
                      appConnectionStatusController.setStatus(status);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          _buildStatusSnackBar(
                            context,
                            _connectivityErrorMessage(context, status),
                          ),
                        );
                      }
                      return;
                    }
                    rethrow;
                  }
                  await deleteActiveStudyReference();
                  await FitbitHandler.deleteFitbitCredentials(
                    widget.subject!.studyId,
                  );
                  if (context.mounted) await cancelNotifications(context);
                  if (context.mounted) {
                    // Clear the in-memory active study state so the
                    // participant can legitimately enroll in a new study.
                    context.read<AppState>().clearAccountState();
                    context.pop(true);
                  }
                }
              : null,
        ),
      ],
    );
  }
}

class const DeleteAlertDialog({super.key, required final StudySubject? subject})
    extends StatefulWidget {
  @override
  State<DeleteAlertDialog> createState() => _DeleteAlertDialogState();
}

class _DeleteAlertDialogState() extends State<DeleteAlertDialog> {
  bool acknowledged = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.leave_study_delete_data_title),
      actionsOverflowButtonSpacing: 12,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.leave_study_delete_data_body(
                widget.subject!.study.title ?? l10n.not_available,
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(
                l10n.acknowledge_consequences,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              value: acknowledged,
              onChanged: (value) {
                setState(() => acknowledged = value ?? false);
              },
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(onPressed: context.pop, child: Text(l10n.stay_in_study)),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete),
          label: Text(l10n.leave_delete_data),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          onPressed: acknowledged
              ? () async {
                  try {
                    await widget.subject!.delete();
                  } on PostgrestException catch (error) {
                    if (error.code != 'PGRST116') {
                      // Unexpected DB error — don't clear local data
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          _buildStatusSnackBar(
                            context,
                            AppLocalizations.of(context)!
                                .error_occurred_with_message(error.message),
                          ),
                        );
                      }
                      return;
                    }
                    // PGRST116: subject already deleted from DB — proceed with local cleanup
                  } catch (error) {
                    final status = connectionStatusFromError(error);
                    if (status != null) {
                      appConnectionStatusController.setStatus(status);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          _buildStatusSnackBar(
                            context,
                            _connectivityErrorMessage(context, status),
                          ),
                        );
                      }
                      return;
                    }
                    rethrow;
                  }
                  // Reached when delete succeeded or subject was already gone from DB
                  RestoreAccountService.clearCache();
                  await deleteLocalData();
                  await FitbitHandler.deleteFitbitCredentials(
                    widget.subject!.studyId,
                  );
                  if (context.mounted) await cancelNotifications(context);
                  if (context.mounted) {
                    // Clear the in-memory active study state so the
                    // participant can legitimately enroll in a new study.
                    context.read<AppState>().clearAccountState();
                    context.pop(true);
                  }
                }
              : null,
        ),
      ],
    );
  }
}

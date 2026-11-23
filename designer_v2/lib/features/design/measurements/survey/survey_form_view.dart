import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet_form.dart';
import 'package:studyu_designer_v2/common_views/styling_information.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_controls_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_list_view.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/theme.dart';

class const MeasurementSurveyFormView({
  required final MeasurementSurveyFormViewModel formViewModel,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<MeasurementSurveyFormView> createState() =>
      _MeasurementSurveyFormViewState();
}

class _MeasurementSurveyFormViewState()
    extends ConsumerState<MeasurementSurveyFormView> {
  bool isStylingInformationDismissed = true;

  void onDismissedCallback() => setState(() {
    isStylingInformationDismissed = !isStylingInformationDismissed;
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              control: widget.formViewModel.surveyTitleControl,
              label: tr.form_field_measurement_survey_title,
              labelHelpText: tr.form_field_measurement_survey_title_tooltip,
              input: ReactiveTextField(
                formControl: widget.formViewModel.surveyTitleControl,
                decoration: InputDecoration(
                  hintText: tr.form_field_measurement_survey_title,
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
                validationMessages:
                    widget.formViewModel.surveyTitleControl.validationMessages,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.surveyIntroTextControl,
              labelBuilder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormLabel(
                    labelText: tr.form_field_measurement_survey_intro_text,
                    helpText:
                        tr.form_field_measurement_survey_intro_text_tooltip,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(left: 3.0),
                    child: Opacity(
                      opacity: ThemeConfig.kMuteFadeFactor,
                      child: Tooltip(
                        message: "Use html to style your content",
                        child: Hyperlink(
                          text: "styleable",
                          onClick: () => setState(() {
                            isStylingInformationDismissed =
                                !isStylingInformationDismissed;
                          }),
                          visitedColor: null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              input: ReactiveTextField(
                formControl: widget.formViewModel.surveyIntroTextControl,
                decoration: InputDecoration(
                  hintText: tr.form_field_measurement_survey_intro_text_hint,
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(2000)],
                validationMessages: widget
                    .formViewModel
                    .surveyIntroTextControl
                    .validationMessages,
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: 5,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.surveyOutroTextControl,
              labelBuilder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormLabel(
                    labelText: tr.form_field_measurement_survey_outro_text,
                    helpText:
                        tr.form_field_measurement_survey_outro_text_tooltip,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(left: 3.0),
                    child: Opacity(
                      opacity: ThemeConfig.kMuteFadeFactor,
                      child: Tooltip(
                        message: "Use html to style your content",
                        child: Hyperlink(
                          text: "styleable",
                          onClick: () => setState(() {
                            isStylingInformationDismissed =
                                !isStylingInformationDismissed;
                          }),
                          visitedColor: null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              input: ReactiveTextField(
                formControl: widget.formViewModel.surveyOutroTextControl,
                decoration: InputDecoration(
                  hintText: tr.form_field_measurement_survey_outro_text_hint,
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(2000)],
                validationMessages: widget
                    .formViewModel
                    .surveyOutroTextControl
                    .validationMessages,
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: 5,
              ),
            ),
          ],
        ),
        HtmlStylingBanner(
          isDismissed: isStylingInformationDismissed,
          onDismissed: onDismissedCallback,
        ),
        const SizedBox(height: 28.0),
        ReactiveFormConsumer(
          // [ReactiveFormConsumer] is needed to to re-render when descendant controls are updated
          // By default, ReactiveFormArray only updates when adding/removing controls
          builder: (context, form, child) {
            return ReactiveFormArray(
              formArray: widget.formViewModel.questionsArray,
              builder: (context, formArray, child) {
                return FormListView<QuestionFormViewModel>(
                  control: widget.formViewModel.questionsArray,
                  items: widget.formViewModel.questionModels,
                  onSelectItem: (viewModel) =>
                      _onSelectItem(viewModel, context, ref),
                  getActionsAt: (viewModel, _) =>
                      widget.formViewModel.availablePopupActions(viewModel),
                  onNewItem: () => _onNewItem(context, ref),
                  onNewItemLabel:
                      tr.form_array_measurement_survey_questions_new,
                  rowTitle: (viewModel) =>
                      viewModel.formData?.questionText ?? '',
                  rowSuffix: (context, viewModel, rowIdx) {
                    if (viewModel.formData?.conditional != null) {
                      return Tooltip(
                        message: tr
                            .form_array_question_visibility_logic_question_tooltip,
                        child: const Icon(
                          Icons.rule,
                          size: 16,
                          color: Colors.grey,
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                  sectionTitle: tr.form_array_measurement_survey_questions,
                  emptyIcon: Icons.content_paste_off_rounded,
                  emptyTitle:
                      tr.form_array_measurement_survey_questions_empty_title,
                  emptyDescription: tr
                      .form_array_measurement_survey_questions_empty_description,
                  hideLeadingTrailingWhenEmpty: true,
                  rowPrefix: (context, viewModel, rowIdx) {
                    return Row(
                      children: [
                        Tooltip(
                          message: viewModel.questionType.string,
                          child: Icon(
                            viewModel.questionType.icon,
                            color: ThemeConfig.dropdownMenuItemTheme(theme)
                                .iconTheme!
                                .color,
                            size: ThemeConfig.dropdownMenuItemTheme(theme)
                                .iconTheme!
                                .size,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                      ],
                    );
                  },
                  reorderable:
                      widget.formViewModel.questionModels.length > 1 &&
                      !widget.formViewModel.isReadonly,
                  onReorder: (oldIndex, newIndex) {
                    var effectiveNewIndex = newIndex;
                    if (effectiveNewIndex > oldIndex) {
                      effectiveNewIndex -= 1;
                    }
                    final item = widget.formViewModel.questionModels.removeAt(
                      oldIndex,
                    );
                    widget.formViewModel.questionModels.insert(
                      effectiveNewIndex,
                      item,
                    );
                    final controlItem = widget.formViewModel.questionsArray
                        .removeAt(oldIndex);
                    widget.formViewModel.questionsArray.insert(
                      effectiveNewIndex,
                      controlItem,
                    );
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 28.0),
        FormSectionHeader(title: tr.form_section_scheduling),
        const SizedBox(height: 4.0),
        TextParagraph(text: tr.form_section_scheduling_description),
        const SizedBox(height: 16.0),
        _ScheduleRuleEditor(formViewModel: widget.formViewModel),
        const SizedBox(height: 16.0),
        ScheduleControls(
          formViewModel: widget.formViewModel,
          isReadonly: widget.formViewModel.isReadonly,
          showSectionHeader: false,
        ),
      ],
    );
  }

  void _onNewItem(BuildContext context, WidgetRef ref) {
    final routeArgs = widget.formViewModel.buildNewFormRouteArgs();
    _showSidesheetWithArgs(routeArgs, context, ref);
  }

  void _onSelectItem(
    QuestionFormViewModel item,
    BuildContext context,
    WidgetRef ref,
  ) {
    final routeArgs = widget.formViewModel.buildFormRouteArgs(item);
    _showSidesheetWithArgs(routeArgs, context, ref);
  }

  // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
  void _showSidesheetWithArgs(
    SurveyQuestionFormRouteArgs routeArgs,
    BuildContext context,
    WidgetRef ref,
  ) {
    // Add current unsaved questions from the form
    final currentUnsavedQuestions = widget
        .formViewModel
        .questionFormViewModels
        .formViewModels
        .map((vm) => vm.buildFormData().toQuestion())
        .toList();

    // Combine both lists
    final List<Question> allAvailableQuestions = [...currentUnsavedQuestions];

    final surveyQuestionFormViewModel = ref.watch(
      surveyQuestionFormViewModelProvider(routeArgs),
    );
    showFormSideSheet<QuestionFormViewModel>(
      context: context,
      formViewModel: surveyQuestionFormViewModel,
      actionButtons: _buildQuestionFormButtons(surveyQuestionFormViewModel),
      tabs: <FormSideSheetTab<QuestionFormViewModel>>[
        FormSideSheetTab(
          title: tr.navlink_screener_question_content,
          index: 0,
          formViewBuilder: (formViewModel) => SurveyQuestionFormView(
            formViewModel: formViewModel,
            studyId: routeArgs.studyId,
          ),
        ),
        FormSideSheetTab(
          title: tr.navlink_question_visibility_logic,
          index: 1,
          formViewBuilder: (formViewModel) => ConditionalQuestionFormView(
            formViewModel: formViewModel,
            allQuestions: allAvailableQuestions,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildQuestionFormButtons(QuestionFormViewModel formViewModel) {
    return [
      const DismissButton(),
      ReactiveFormConsumer(
        builder: (context, form, child) {
          final fitbitCredentialsFormViewModel =
              formViewModel.fitbitCredentialsFormViewModel;
          final requiresFitbitCredentials =
              formViewModel.questionType == SurveyQuestionType.fitbit;

          if (!requiresFitbitCredentials ||
              fitbitCredentialsFormViewModel == null) {
            final validationSummary = formViewModel.form.validationErrorSummary
                .trim();
            return PrimaryButton(
              text: tr.dialog_save,
              tooltipDisabled: _buildInvalidTooltip(validationSummary),
              icon: null,
              enabled: formViewModel.isValid,
              onPressedFuture: formViewModel.isValid
                  ? () {
                      final navigator = Navigator.of(context);
                      return formViewModel.save().then((_) {
                        if (mounted) navigator.maybePop();
                      });
                    }
                  : null,
            );
          }

          return StreamBuilder(
            stream: fitbitCredentialsFormViewModel.form.statusChanged,
            builder: (context, _) {
              final isValid =
                  formViewModel.isValid &&
                  fitbitCredentialsFormViewModel.form.valid;
              final validationSummary = [
                formViewModel.form.validationErrorSummary.trim(),
                fitbitCredentialsFormViewModel.form.validationErrorSummary
                    .trim(),
              ].where((summary) => summary.trim().isNotEmpty).join('\n\n');

              return PrimaryButton(
                text: tr.dialog_save,
                tooltipDisabled: _buildInvalidTooltip(validationSummary),
                icon: null,
                enabled: isValid,
                onPressedFuture: isValid
                    ? () {
                        final navigator = Navigator.of(context);
                        return formViewModel.save().then((_) {
                          if (mounted) navigator.maybePop();
                        });
                      }
                    : null,
              );
            },
          );
        },
      ),
    ];
  }

  String _buildInvalidTooltip(String validationSummary) {
    if (validationSummary.isEmpty) {
      return tr.form_invalid_prompt;
    }
    return '${tr.form_invalid_prompt}\n\n$validationSummary';
  }
}

// =============================================================================
// Schedule Rule Editor Widget
// =============================================================================

class const _ScheduleRuleEditor({
  required final MeasurementSurveyFormViewModel formViewModel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ReactiveFormConsumer(
      builder: (context, form, child) {
        final isScheduled = formViewModel.isScheduledControl.value ?? false;

        return FormTableLayout(
          rows: [
            FormTableRow(
              control: formViewModel.isScheduledControl,
              label: tr.form_survey_schedule_title,
              labelHelpText: tr.form_survey_schedule_separation_help,
              input: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReactiveSwitch(formControl: formViewModel.isScheduledControl),
                  if (isScheduled) ...[
                    const SizedBox(height: 16),
                    Text(
                      '${tr.form_survey_schedule_inactive} '
                      '${tr.form_survey_schedule_pattern_help}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    _ScheduleTypeSelector(formViewModel: formViewModel),
                    const SizedBox(height: 16),
                    _ScheduleTypeControls(formViewModel: formViewModel),
                    const SizedBox(height: 16),
                    _SchedulePreview(formViewModel: formViewModel),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// Schedule Type Selector (Segmented Button)
// =============================================================================

class const _ScheduleTypeSelector({
  required final MeasurementSurveyFormViewModel formViewModel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ReactiveFormConsumer(
      builder: (context, form, child) {
        final selectedType = formViewModel.selectedScheduleType;

        return SegmentedButton<TaskScheduleType>(
          segments: [
            ButtonSegment(
              value: TaskScheduleType.specificDays,
              label: Text(tr.form_survey_schedule_specific_days),
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
            ),
            ButtonSegment(
              value: TaskScheduleType.everyNDays,
              label: Text(tr.form_survey_schedule_every_n_days),
              icon: const Icon(Icons.repeat_rounded, size: 18),
            ),
            ButtonSegment(
              value: TaskScheduleType.perCycle,
              label: Text(tr.form_survey_schedule_per_cycle),
              icon: const Icon(Icons.loop_rounded, size: 18),
            ),
          ],
          selected: {selectedType},
          onSelectionChanged: (selected) {
            formViewModel.scheduleTypeControl.value = selected.first.name;
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.primaryContainer;
              }
              return colorScheme.surface;
            }),
          ),
          showSelectedIcon: false,
        );
      },
    );
  }
}

// =============================================================================
// Type-specific Controls
// =============================================================================

class const _ScheduleTypeControls({
  required final MeasurementSurveyFormViewModel formViewModel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(
      builder: (context, form, child) {
        switch (formViewModel.selectedScheduleType) {
          case TaskScheduleType.specificDays:
            return _SpecificDaysEditor(formViewModel: formViewModel);
          case TaskScheduleType.everyNDays:
            return _EveryNDaysEditor(formViewModel: formViewModel);
          case TaskScheduleType.perCycle:
            return _PerCycleEditor(formViewModel: formViewModel);
        }
      },
    );
  }
}

// --- Specific Days: Multi-select chip grid ---

class const _SpecificDaysEditor({
  required final MeasurementSurveyFormViewModel formViewModel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalDays = formViewModel.studyLength;
    final selectedDays = formViewModel.specificDaysControl.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.form_survey_schedule_select_days,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: List.generate(totalDays, (index) {
            final isSelected = selectedDays.contains(index);
            return FilterChip(
              label: Text(
                tr.form_survey_schedule_day_label(index + 1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final updated = List<int>.from(selectedDays);
                if (selected) {
                  updated.add(index);
                } else {
                  updated.remove(index);
                }
                updated.sort();
                formViewModel.specificDaysControl.value = updated;
                formViewModel.specificDaysControl.markAsDirty();
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
              backgroundColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }),
        ),
      ],
    );
  }
}

// --- Every N Days ---

class const _EveryNDaysEditor({
  required final MeasurementSurveyFormViewModel formViewModel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalDays = formViewModel.studyLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tr.form_survey_schedule_every_n_interval_label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: ReactiveTextField<int>(
                formControl: formViewModel.intervalDaysControl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              tr.form_survey_schedule_days_suffix,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              tr.form_survey_schedule_every_n_delay_label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: ReactiveTextField<int>(
                formControl: formViewModel.startDayOffsetControl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tr.form_survey_schedule_every_n_delay_suffix,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          tr.form_survey_schedule_every_n_delay_help(totalDays),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// --- Per Cycle ---

class const _PerCycleEditor({
  required final MeasurementSurveyFormViewModel formViewModel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final numberOfCycles = formViewModel.numberOfCycles;
    final selectedCycles = formViewModel.targetCyclesControl.value ?? [];
    final phaseDuration = formViewModel.study.schedule.phaseDuration;
    final phasesPerCycle =
        formViewModel.study.schedule.sequence == PhaseSequence.customized
        ? formViewModel.study.schedule.sequenceCustom.length
        : StudySchedule.numberOfInterventions;
    final cycleLengthDays = phasesPerCycle * phaseDuration;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tr.form_survey_schedule_per_cycle_delay_label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: ReactiveTextField<int>(
                formControl: formViewModel.dayOfCycleControl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tr.form_survey_schedule_per_cycle_delay_suffix,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          tr.form_survey_schedule_per_cycle_help(
            cycleLengthDays,
            phasesPerCycle,
            phaseDuration,
          ),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),

        // Cycle selector
        Text(
          tr.form_survey_schedule_target_cycles,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: List.generate(numberOfCycles, (index) {
            final isSelected = selectedCycles.contains(index);
            return FilterChip(
              label: Text(
                tr.form_survey_schedule_cycle_label(index + 1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final updated = List<int>.from(selectedCycles);
                if (selected) {
                  updated.add(index);
                } else {
                  updated.remove(index);
                }
                updated.sort();
                formViewModel.targetCyclesControl.value = updated;
                formViewModel.targetCyclesControl.markAsDirty();
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
              backgroundColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }),
        ),
        const SizedBox(height: 16),

        // Include baseline toggle
        if (formViewModel.study.schedule.includeBaseline)
          Row(
            children: [
              Icon(
                Icons.flag_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                tr.form_survey_schedule_include_baseline,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              ReactiveSwitch(formControl: formViewModel.includeBaselineControl),
            ],
          ),
      ],
    );
  }
}

// =============================================================================
// Schedule Preview
// =============================================================================

class const _SchedulePreview({
  required final MeasurementSurveyFormViewModel formViewModel,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final previewDays = formViewModel.previewDays;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primaryContainer),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_available, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.form_survey_schedule_summary_title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  previewDays.isEmpty
                      ? tr.form_survey_schedule_summary_empty
                      : tr.form_survey_schedule_summary_days(
                          previewDays
                              .map(
                                (day) =>
                                    tr.form_survey_schedule_day_label(day + 1),
                              )
                              .join(', '),
                        ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                if (previewDays.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      tr.form_survey_schedule_summary_occurrences(
                        previewDays.length,
                        formViewModel.studyLength,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

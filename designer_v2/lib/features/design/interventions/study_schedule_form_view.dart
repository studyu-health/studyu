import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_banner.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/input_formatter.dart';

class const StudyScheduleFormView({
  required final StudyScheduleControls formViewModel,
  super.key,
}) extends StatefulWidget {
  @override
  State<StudyScheduleFormView> createState() => _StudyScheduleFormViewState();
}

class _StudyScheduleFormViewState() extends State<StudyScheduleFormView> {
  bool _isBannerDismissed = true;

  FormTableRow _renderCustomSequence() {
    if (!widget.formViewModel.isSequencingCustom()) {
      return FormTableRow(input: const SizedBox.shrink());
    } else {
      return FormTableRow(
        control: widget.formViewModel.sequenceTypeCustomControl,
        label: tr.phase_sequence_custom_label,
        labelHelpText: tr.phase_sequence_custom_label_help,
        input: TextField(
          onChanged: (value) =>
              widget.formViewModel.sequenceTypeCustomControl.value = value,
          controller: TextEditingController()
            ..value = TextEditingValue(
              text: widget.formViewModel.sequenceTypeCustomControl.value!,
              selection: TextSelection.collapsed(
                offset: widget
                    .formViewModel
                    .sequenceTypeCustomControl
                    .value!
                    .length,
              ),
            ),
          //formControl: widget.formViewModel.sequenceTypeCustomControl,
          keyboardType: TextInputType.text,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.singleLineFormatter,
            StudySequenceFormatter(),
            LengthLimitingTextInputFormatter(10),
          ],
          //validationMessages: widget.formViewModel.sequenceTypeCustomControl.validationMessages,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _studyScheduleDescription(),
        const SizedBox(height: 16.0),
        FormTableLayout(
          rows: [
            FormTableRow(
              control: widget.formViewModel.sequenceTypeControl,
              label: tr.form_field_crossover_schedule_sequence,
              labelHelpText: tr.form_field_crossover_schedule_sequence_tooltip,
              input: DropdownButtonFormField(
                //formControl: widget.formViewModel.sequenceTypeControl,
                onChanged: widget.formViewModel.sequenceTypeControl.disabled
                    ? null
                    : (PhaseSequence? value) {
                        setState(() {
                          widget.formViewModel.sequenceTypeControl.value =
                              value;
                          widget.formViewModel.sequenceTypeCustomControl
                              .updateValueAndValidity();
                        });
                      },
                initialValue: widget.formViewModel.sequenceTypeControl.value,
                decoration: InputDecoration(
                  helperText:
                      tr.form_field_crossover_schedule_sequence_description,
                  helperMaxLines: 5,
                ),
                items: widget.formViewModel.sequenceTypeControlOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option.value,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                //validationMessages: widget.formViewModel.sequenceTypeControl.validationMessages,
              ),
            ),
            _renderCustomSequence(),
            FormTableRow(
              control: widget.formViewModel.phaseDurationControl,
              label: tr.form_field_crossover_schedule_phase_length,
              labelHelpText:
                  tr.form_field_crossover_schedule_phase_length_tooltip,
              input: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 70),
                    child: TextField(
                      readOnly:
                          widget.formViewModel.phaseDurationControl.disabled,
                      controller: TextEditingController()
                        ..value = TextEditingValue(
                          text: widget.formViewModel.phaseDurationControl.value
                              .toString(),
                          selection: TextSelection.collapsed(
                            offset: widget
                                .formViewModel
                                .phaseDurationControl
                                .value
                                .toString()
                                .length,
                          ),
                        ),
                      //formControl: widget.formViewModel.phaseDurationControl,
                      onChanged: (value) {
                        final phaseDuration = int.tryParse(value);
                        if (phaseDuration != null) {
                          widget.formViewModel.phaseDurationControl.value =
                              phaseDuration;
                        }
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                        NumericalRangeFormatter(
                          min: StudyScheduleControls.kPhaseDurationMin,
                          max: StudyScheduleControls.kPhaseDurationMax,
                        ),
                      ],
                      //validationMessages: widget.formViewModel.phaseDurationControl.validationMessages,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  FormControlLabel(
                    formControl: widget.formViewModel.phaseDurationControl,
                    text: tr.form_field_amount_days,
                  ),
                ],
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.numCyclesControl,
              label: tr.form_field_crossover_schedule_num_cycles,
              labelHelpText:
                  tr.form_field_crossover_schedule_num_cycles_tooltip,
              input: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: DropdownButtonFormField<int>(
                      initialValue: widget.formViewModel.numCyclesControl.value,
                      isExpanded: true,
                      alignment: Alignment.centerLeft,
                      onChanged: widget.formViewModel.numCyclesControl.disabled
                          ? null
                          : (value) {
                              if (value != null) {
                                widget.formViewModel.numCyclesControl.value =
                                    value;
                              }
                            },
                      items: [
                        for (
                          var value = StudyScheduleControls.kNumCyclesMin;
                          value <= StudyScheduleControls.kNumCyclesMax;
                          value++
                        )
                          DropdownMenuItem(value: value, child: Text('$value')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  FormControlLabel(
                    formControl: widget.formViewModel.numCyclesControl,
                    text: tr.form_field_amount_crossover_schedule_num_cycles,
                  ),
                ],
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.includeBaselineControl,
              label: tr.form_field_crossover_schedule_include_baseline,
              labelHelpText:
                  tr.form_field_crossover_schedule_include_baseline_tooltip,
              input: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 70),
                    child: Checkbox(
                      value: widget.formViewModel.includeBaselineControl.value,
                      onChanged:
                          widget.formViewModel.includeBaselineControl.disabled
                          ? null
                          : (value) =>
                                widget
                                        .formViewModel
                                        .includeBaselineControl
                                        .value =
                                    value,
                      //formControl: widget.formViewModel.includeBaselineControl,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  FormControlLabel(
                    formControl: widget.formViewModel.includeBaselineControl,
                    text:
                        tr.form_field_crossover_schedule_include_baseline_label,
                  ),
                ],
              ),
            ),
            // TODO washout
          ],
          columnWidths: const {
            0: MaxColumnWidth(FixedColumnWidth(130), IntrinsicColumnWidth()),
            1: FlexColumnWidth(),
          },
        ),
      ],
    );
  }

  Widget _studyScheduleDescription() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextParagraph(text: tr.study_schedule_banner_description),
        const SizedBox(height: 16.0),
        _buildSequenceTypeInfo(
          theme,
          tr.study_schedule_alternating_description,
        ),
        const SizedBox(height: 8.0),
        _buildSequenceTypeInfo(theme, tr.study_schedule_balanced_description),
        const SizedBox(height: 8.0),
        _buildSequenceTypeInfo(theme, tr.study_schedule_random_description),
        const SizedBox(height: 8.0),
        _buildSequenceTypeInfo(theme, tr.study_schedule_custom_description),
        const SizedBox(height: 8.0),
        Hyperlink(
          icon: Icons.north_east_rounded,
          text: tr.study_schedule_learn_more,
          onClick: () {
            setState(() {
              _isBannerDismissed = false;
            });
          },
          visitedColor: null,
        ),
        const SizedBox(height: 8.0),
        StudyScheduleBanner(
          isDismissed: _isBannerDismissed,
          onDismissed: () {
            setState(() {
              _isBannerDismissed = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSequenceTypeInfo(ThemeData theme, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8.0, right: 12.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(child: TextParagraph(text: description)),
      ],
    );
  }
}

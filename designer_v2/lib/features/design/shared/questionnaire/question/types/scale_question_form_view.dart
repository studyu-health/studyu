import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/collapse.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/reactive_color_picker.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/color.dart';
import 'package:studyu_designer_v2/utils/input_formatter.dart';

abstract class IScaleQuestionFormViewModel() {
  bool get isMidValuesClearedInfoVisible;
}

class const ScaleQuestionFormView({
  required final QuestionFormViewModel formViewModel,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<ScaleQuestionFormView> createState() =>
      _ScaleQuestionFormViewState();
}

class _ScaleQuestionFormViewState()
    extends ConsumerState<ScaleQuestionFormView> {
  QuestionFormViewModel get formViewModel => widget.formViewModel;

  late bool isMinMaxColorsVisible =
      formViewModel.scaleMinColorControl.value != null ||
      formViewModel.scaleMaxColorControl.value != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8.0),
        _buildLabelValueControlsPair(
          labelControl: formViewModel.scaleMinLabelControl,
          valueControl: formViewModel.scaleMinValueControl,
          labelControlLabel: tr.form_field_response_scale_min_label,
          labelControlHelpText: tr.form_field_response_scale_min_label_tooltip,
          valueControlLabel: tr.form_field_response_scale_min_value,
        ),
        const SizedBox(height: 16.0),
        Collapsible(
          title: tr.form_array_response_scale_mid_values,
          contentBuilder: (context, _) => _buildMidValuesSection(context),
        ),
        const SizedBox(height: 12.0),
        const SizedBox(height: 8.0),
        _buildLabelValueControlsPair(
          labelControl: formViewModel.scaleMaxLabelControl,
          valueControl: formViewModel.scaleMaxValueControl,
          labelControlLabel: tr.form_field_response_scale_max_label,
          labelControlHelpText: tr.form_field_response_scale_max_label_tooltip,
          valueControlLabel: tr.form_field_response_scale_max_value,
        ),
        const SizedBox(height: 16.0),
        const SizedBox(height: 8.0),
        if (isMinMaxColorsVisible)
          Column(
            children: [
              _buildVisualizationHeader(context),
              const SizedBox(height: 12.0),
              _buildMinMaxColorPickers(context),
            ],
          )
        else if (!formViewModel.isReadonly)
          Opacity(
            opacity: ThemeConfig.kMuteFadeFactor,
            child: Hyperlink(
              text: "+ ${tr.form_field_response_scale_colors_add}",
              onClick: () => setState(() {
                isMinMaxColorsVisible = true;
              }),
              visitedColor: null,
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildVisualizationHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        FormSectionHeader(title: tr.navlink_question_visuals, divider: false),
        const SizedBox(height: 16.0),
        TextParagraph(
          text: tr.navlink_question_visuals_description,
          style: ThemeConfig.bodyTextMuted(theme),
        ),
      ],
    );
  }

  Widget _buildMinMaxColorPickers(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 5,
          child: FormTableLayout(
            rowLayout: FormTableRowLayout.vertical,
            rows: [
              _buildColorControlRow(
                context,
                formViewModel.scaleMinColorControl,
                tr.form_field_response_scale_color_min,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12.0),
        Flexible(
          flex: 5,
          child: FormTableLayout(
            rowLayout: FormTableRowLayout.vertical,
            rows: [
              _buildColorControlRow(
                context,
                formViewModel.scaleMaxColorControl,
                tr.form_field_response_scale_color_max,
              ),
            ],
          ),
        ),
      ],
    );
  }

  FormTableRow _buildColorControlRow(
    BuildContext context,
    FormControl<Color> control,
    String labelText,
  ) {
    final theme = Theme.of(context);
    return FormTableRow(
      control: control,
      labelBuilder: (context) => Row(
        children: [
          FormLabel(
            labelText: labelText,
            helpText: tr.form_field_response_scale_color_tooltip,
          ),
          const SizedBox(width: 24.0),
          if (control.value == null && !formViewModel.isReadonly)
            Opacity(
              opacity: ThemeConfig.kMuteFadeFactor,
              child: Hyperlink(
                text: "+ ${tr.form_field_response_scale_color_add}",
                onClick: () => control.value = SerializableColor(
                  ThemeConfig.colorPickerInitialColor(theme).toARGB32(),
                ),
                visitedColor: null,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
      input: (control.value != null)
          ? ReactiveCustomColorPicker(
              formControl: control,
              //hexInputBar: true,
              enableAlpha: false,
              labelTypes: const [],
              pickerHsvColor: HSVColor.fromColor(
                control.value ?? ThemeConfig.colorPickerInitialColor(theme),
              ),
            )
          : Opacity(
              // prevent layout shift with disabled hidden placeholder
              opacity: 0.5,
              child: ReactiveCustomColorPicker(
                formControl: FormControl(disabled: true),
                disabledOpacity: 0.0,
              ),
            ),
    );
  }

  Widget _buildMidValuesSection(BuildContext context) {
    return Column(
      children: [
        ReactiveFormConsumer(
          builder: (context, formArray, child) {
            return (!formViewModel.isReadonly)
                ? Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: BannerBox(
                      style: BannerStyle.info,
                      body: TextParagraph(
                        text: tr
                            .form_array_response_scale_mid_values_dirty_banner,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 12.0,
                      ),
                      noPrefix: true,
                      isDismissed: !formViewModel.isMidValuesClearedInfoVisible,
                      dismissIconSize: Theme.of(context).iconTheme.size ?? 14.0,
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
        ReactiveFormArray(
          formArray: formViewModel.scaleMidValueControls,
          builder: (context, formArray, child) {
            if (formArray.controls.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(formArray.controls.length, (i) {
                final valueControl =
                    formViewModel.scaleMidValueControls.controls[i]
                        as FormControl;
                final labelControl =
                    formViewModel.scaleMidLabelControls.controls[i]
                        as FormControl;

                return _buildLabelValueControlsPair(
                  labelControl: labelControl,
                  valueControl: valueControl,
                  labelControlKey: ValueKey(valueControl.value),
                  valueControlKey: ValueKey(valueControl.value),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLabelValueControlsPair({
    required FormControl labelControl,
    required FormControl valueControl,
    String? labelControlLabel,
    String? labelControlHelpText,
    String? valueControlLabel,
    String? valueControlHelpText,
    Key? labelControlKey,
    Key? valueControlKey,
  }) {
    return Row(
      children: [
        Flexible(
          flex: 5,
          child: FormTableLayout(
            rowLayout: FormTableRowLayout.vertical,
            rows: [
              FormTableRow(
                control: labelControl,
                label: labelControlLabel,
                labelHelpText: labelControlHelpText,
                input: ReactiveTextField(
                  key: labelControlKey,
                  formControl: labelControl,
                  validationMessages: labelControl.validationMessages,
                  decoration: (!formViewModel.isReadonly)
                      ? InputDecoration(
                          hintText: tr.form_field_response_scale_label_hint,
                        )
                      : const InputDecoration(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12.0),
        Flexible(
          flex: 3,
          child: FormTableLayout(
            rowLayout: FormTableRowLayout.vertical,
            rows: [
              FormTableRow(
                control: valueControl,
                label: valueControlLabel,
                labelHelpText: valueControlHelpText,
                input: ReactiveTextField(
                  key: valueControlKey,
                  formControl: valueControl,
                  validationMessages: valueControl.validationMessages,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    NumericalRangeFormatter(max: 10000),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

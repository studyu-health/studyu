import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/common_views/styling_information.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_controller.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class const ConsentItemFormView({
  required final ConsentItemFormViewModel formViewModel,
  super.key,
}) extends StatefulWidget {
  @override
  State<ConsentItemFormView> createState() => _ConsentItemFormViewState();
}

class _ConsentItemFormViewState() extends State<ConsentItemFormView> {
  bool isStylingInformationDismissed = true;

  void onDismissedCallback() => setState(() {
    isStylingInformationDismissed = !isStylingInformationDismissed;
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(
      builder: (context, formGroup, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormTableLayout(
              rowLayout: FormTableRowLayout.vertical,
              rows: [
                FormTableRow(
                  control: widget.formViewModel.titleControl,
                  label: tr.form_field_consent_title,
                  labelHelpText: tr.form_field_consent_title_tooltip,
                  input: Row(
                    children: [
                      Expanded(
                        child: ReactiveTextField(
                          formControl: widget.formViewModel.titleControl,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(100),
                          ],
                          validationMessages: widget
                              .formViewModel
                              .titleControl
                              .validationMessages,
                          decoration: InputDecoration(
                            hintText: tr.form_field_consent_title_hint,
                          ),
                        ),
                      ),
                      ReactiveFormConsumer(
                        builder: (context, form, child) {
                          return (widget.formViewModel.iconControl.value !=
                                  null)
                              ? const SizedBox(width: 4.0)
                              : const SizedBox(width: 8.0);
                        },
                      ),
                      IntrinsicWidth(
                        child: ReactiveIconPicker(
                          formControl: widget.formViewModel.iconControl,
                          iconOptions: IconPack.material,
                        ),
                      ),
                    ],
                  ),
                ),
                FormTableRow(
                  control: widget.formViewModel.descriptionControl,
                  labelBuilder: (context) => Row(
                    children: [
                      FormLabel(
                        labelText: tr.form_field_consent_text,
                        helpText: tr.form_field_consent_text_tooltip,
                      ),
                      const SizedBox(width: 8),
                      Opacity(
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
                    ],
                  ),
                  input: ReactiveTextField(
                    formControl: widget.formViewModel.descriptionControl,
                    inputFormatters: [LengthLimitingTextInputFormatter(10000)],
                    validationMessages: widget
                        .formViewModel
                        .descriptionControl
                        .validationMessages,
                    keyboardType: TextInputType.multiline,
                    minLines: 10,
                    maxLines: 30,
                    decoration: InputDecoration(
                      hintText: tr.form_field_consent_text_hint,
                    ),
                  ),
                ),
              ],
            ),
            HtmlStylingBanner(
              isDismissed: isStylingInformationDismissed,
              onDismissed: onDismissedCallback,
            ),
          ],
        );
      },
    );
  }
}

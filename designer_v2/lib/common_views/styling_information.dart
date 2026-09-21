import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/reusable_banner.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class const HtmlStylingBanner({
  final bool isDismissed = false,
  final Function()? onDismissed,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ReusableBanner(
      isDismissed: isDismissed,
      onDismissed: onDismissed,
      body: Column(
        children: [
          TextParagraph(
            text: tr.html_styling_banner_description,
            style: ThemeConfig.bodyTextMuted(theme),
          ),
          const SizedBox(height: 8.0),
          SelectionArea(
            child: Table(
              border: TableBorder.all(color: Colors.transparent),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(4),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    Text(tr.html_styling_bold_example),
                    Text(
                      tr.html_styling_bold_code,
                      style: ThemeConfig.bodyTextMuted(theme),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(tr.html_styling_italic_example),
                    Text(
                      tr.html_styling_italic_code,
                      style: ThemeConfig.bodyTextMuted(theme),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(tr.html_styling_underline_example),
                    Text(
                      tr.html_styling_underline_code,
                      style: ThemeConfig.bodyTextMuted(theme),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(tr.html_styling_link_example),
                    Text(
                      tr.html_styling_link_code,
                      style: ThemeConfig.bodyTextMuted(theme),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(tr.html_styling_linebreak_example),
                    Text(
                      tr.html_styling_linebreak_code,
                      style: ThemeConfig.bodyTextMuted(theme),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Text(
                tr.html_styling_more_info,
                style: ThemeConfig.bodyTextMuted(theme),
              ),
              const SizedBox(width: 4.0),
              Hyperlink(
                icon: Icons.north_east_rounded,
                text: tr.html_styling_documentation_link,
                url: 'https://demo.fwfh.dev/supported/tags.html',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

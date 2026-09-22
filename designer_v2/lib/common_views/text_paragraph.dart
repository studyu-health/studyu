import 'package:flutter/material.dart';

class TextParagraph({
  final String? text,
  final TextStyle? style,
  final bool selectable = true,
  final List<TextSpan>? span,
  super.key,
}) extends StatelessWidget {
  this {
    if (text == null && span == null) {
      throw Exception("Either text or TextSpan has to be provided");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium!.merge(style);

    if (!selectable) {
      if (span != null) {
        return RichText(text: TextSpan(children: span));
      }
      return Text(text!, style: textStyle);
    }
    if (span != null) {
      return SelectableText.rich(TextSpan(children: span), style: textStyle);
    }
    return SelectableText(text!, style: textStyle);
  }
}

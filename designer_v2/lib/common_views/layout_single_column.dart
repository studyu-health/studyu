import 'dart:math';

import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/layout_two_column.dart';
import 'package:studyu_designer_v2/theme.dart';

enum SingleColumnLayoutType() {
  boundedWide,
  boundedNarrow,
  stretched,
  split,
}

class const SingleColumnLayout({
  required final Widget body,
  final Widget? header,
  final bool stickyHeader = false,
  final BoxConstraints? constraints = defaultConstraints,
  final bool scroll = true,
  final EdgeInsets? padding = TwoColumnLayout.defaultContentPadding,
  super.key,
}) extends StatefulWidget {
  static const defaultConstraints = BoxConstraints(
    minWidth: ThemeConfig.kMinContentWidth,
    maxWidth: ThemeConfig.kMaxContentWidth,
  );

  static const defaultConstraintsNarrow = BoxConstraints(
    minWidth: 8 / 12 * ThemeConfig.kMinContentWidth,
    maxWidth: 8 / 12 * ThemeConfig.kMaxContentWidth,
  );

  factory fromType({
    required SingleColumnLayoutType type,
    required Widget body,
    required BuildContext context,
    bool stickyHeader = false,
    Widget? header,
  }) {
    switch (type) {
      case SingleColumnLayoutType.split:
        final screenSize = MediaQuery.of(context).size;
        return SingleColumnLayout(
          body: body,
          header: header,
          stickyHeader: stickyHeader,
          constraints: BoxConstraints(
            minWidth: min(ThemeConfig.kMinContentWidth, screenSize.width * 0.5),
            maxWidth: min(ThemeConfig.kMaxContentWidth, screenSize.width * 0.5),
          ),
        );
      case SingleColumnLayoutType.stretched:
        return SingleColumnLayout(
          body: body,
          header: header,
          stickyHeader: stickyHeader,
          constraints: null,
        );
      case SingleColumnLayoutType.boundedWide:
        return SingleColumnLayout(
          body: body,
          header: header,
          stickyHeader: stickyHeader,
        );
      case SingleColumnLayoutType.boundedNarrow:
        return SingleColumnLayout(
          body: body,
          header: header,
          stickyHeader: stickyHeader,
          constraints: defaultConstraintsNarrow,
        );
    }
  }

  @override
  State<SingleColumnLayout> createState() => _SingleColumnLayoutState();
}

class _SingleColumnLayoutState() extends State<SingleColumnLayout> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = widget.body;

    if (widget.padding != null) {
      body = Padding(padding: widget.padding!, child: body);
    }
    if (widget.constraints != null) {
      body = Container(constraints: widget.constraints, child: body);
    }

    body = Row(
      children: [
        Flexible(
          child: Container(constraints: widget.constraints, child: body),
        ),
      ],
    );

    Widget decorateScroll(Widget child) {
      return Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: child,
        ),
      );
    }

    if (widget.stickyHeader) {
      if (widget.scroll) {
        body = decorateScroll(body);
      }
      if (widget.header != null) {
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.header!,
            Flexible(child: body),
          ],
        );
      }
    } else {
      // non-sticky header
      if (widget.header != null) {
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [widget.header!, body],
        );
      }
      if (widget.scroll) {
        body = decorateScroll(body);
      }
    }

    return body;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/features/study/study_participation_badge.dart';
import 'package:studyu_designer_v2/features/study/study_status_badge.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

class const StudiesTableItem({
  super.key,
  required final Study study,
  required final List<ModelAction> actions,
  required final List<StudiesTableColumnSize> columnSizes,
  required final bool isPinned,
  final bool isBusy = false,
  final bool isHighlighted = false,
  final void Function(Study, bool)? onPinnedChanged,
  final void Function(Study)? onTap,
  final double itemHeight = 60.0,
  final double itemPadding = 10.0,
  final double rowSpacing = 9.0,
  final double columnSpacing = 10.0,
}) extends StatefulWidget {
  static const _prototypeStudyTitle =
      'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM';

  this : assert(columnSizes.length == 9);

  factory prototype({
    required List<StudiesTableColumnSize> columnSizes,
    required double itemHeight,
    required double itemPadding,
    required double rowSpacing,
    required double columnSpacing,
  }) {
    final prototypeStudy = Study.withId('_prototype')
      ..title = _prototypeStudyTitle
      ..status = StudyStatus.running
      ..participation = Participation.invite
      ..createdAt = DateTime.now();
    return StudiesTableItem(
      study: prototypeStudy,
      actions: const [],
      columnSizes: columnSizes,
      isPinned: true,
      itemHeight: itemHeight,
      itemPadding: itemPadding,
      rowSpacing: rowSpacing,
      columnSpacing: columnSpacing,
    );
  }

  @override
  State<StudiesTableItem> createState() => _StudiesTableItemState();
}

class _StudiesTableItemState() extends State<StudiesTableItem> {
  bool isHovering = false;
  bool isHoveringPin = false;
  late final FocusNode _focusNode;

  String get _studyTitle => widget.study.title ?? '[Missing study title]';

  String get _semanticLabel => widget.isHighlighted
      ? 'Copied draft: $_studyTitle'.hardcoded
      : _studyTitle;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'study_row_${widget.study.id}');
    _scrollHighlightedIntoView();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StudiesTableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isHighlighted && widget.isHighlighted) {
      _scrollHighlightedIntoView();
    }
  }

  void _scrollHighlightedIntoView() {
    if (!widget.isHighlighted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      _focusNode.requestFocus();
      Scrollable.ensureVisible(
        context,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        duration: disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    TextStyle? mutedTextStyleIfZero(int value) {
      return (value > 0) ? null : ThemeConfig.bodyTextBackground(theme);
    }

    Icon icon(IconData iconData) {
      return Icon(iconData, color: Colors.grey, size: 25);
    }

    Widget getRespectivePinIcon(Set<WidgetState> state) {
      if (isHoveringPin) {
        return widget.isPinned ? icon(MdiIcons.pinOff) : icon(MdiIcons.pin);
      } else {
        return widget.isPinned ? icon(MdiIcons.pin) : const SizedBox.shrink();
      }
    }

    final highlightColor = theme.colorScheme.secondaryContainer;
    final baseColor = theme.colorScheme.onPrimary;

    return Semantics(
      label: _semanticLabel,
      focused: widget.isHighlighted,
      container: true,
      child: Focus(
        focusNode: _focusNode,
        child: Container(
          height: widget.itemHeight,
          margin: EdgeInsets.only(bottom: widget.rowSpacing),
          child: AnimatedContainer(
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: widget.isHighlighted ? highlightColor : baseColor,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              border: Border.all(
                color: widget.isHighlighted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primaryContainer.withValues(alpha: 0.9),
                width: widget.isHighlighted || isHovering ? 1.5 : 0.75,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: InkWell(
                key: ValueKey('study_row_ink_${widget.study.id}'),
                splashColor: Colors.transparent,
                onTap: widget.isBusy
                    ? null
                    : () => widget.onTap?.call(widget.study),
                onHover: (hover) {
                  if (isHovering == hover) return;
                  setState(() {
                    isHovering = hover;
                  });
                },
                hoverColor: widget.isHighlighted ? highlightColor : baseColor,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: widget.itemPadding),
                  child: Row(
                    children: [
                      widget.columnSizes[0].createContainer(
                        height: widget.itemHeight,
                        child: MouseEventsRegion(
                          key: ValueKey('pin_icon_${widget.study.id}'),
                          onTap: widget.isBusy
                              ? null
                              : () => widget.onPinnedChanged?.call(
                                  widget.study,
                                  !widget.isPinned,
                                ),
                          onEnter: (_) => setState(() => isHoveringPin = true),
                          onExit: (_) => setState(() => isHoveringPin = false),
                          builder: (context, mouseEventState) {
                            return getRespectivePinIcon(mouseEventState);
                          },
                        ),
                      ),
                      SizedBox(
                        width: widget.columnSizes[0].collapsed
                            ? 0
                            : widget.columnSpacing,
                      ),
                      widget.columnSizes[1].createContainer(
                        child: Text(
                          _studyTitle,
                          maxLines: 3,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      SizedBox(
                        width: widget.columnSizes[1].collapsed
                            ? 0
                            : widget.columnSpacing,
                      ),
                      widget.columnSizes[2].createContainer(
                        child: Center(
                          child: StudyStatusBadge(
                            status: widget.study.status,
                            showPrefixIcon: false,
                            showTooltip: false,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: widget.columnSizes[2].collapsed
                            ? 0
                            : widget.columnSpacing,
                      ),
                      widget.columnSizes[3].createContainer(
                        child: StudyParticipationBadge(
                          participation: widget.study.participation,
                        ),
                      ),
                      SizedBox(
                        width: widget.columnSizes[3].collapsed
                            ? 0
                            : widget.columnSpacing,
                      ),
                      widget.columnSizes[4].createContainer(
                        child: Center(
                          child: Text(
                            widget.study.createdAt?.toTimeAgoString() ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: widget.columnSizes[4].collapsed
                            ? 0
                            : widget.columnSpacing,
                      ),
                      widget.columnSizes[5].createContainer(
                        child: Center(
                          child: Text(
                            widget.study.participantCount.toString(),
                            style: mutedTextStyleIfZero(
                              widget.study.participantCount,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: widget.columnSizes[5].collapsed
                            ? 0
                            : widget.columnSpacing,
                      ),
                      widget.columnSizes[6].createContainer(
                        child: Center(
                          child: Text(
                            widget.study.activeSubjectCount.toString(),
                            style: mutedTextStyleIfZero(
                              widget.study.activeSubjectCount,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: widget.columnSizes[6].collapsed
                            ? 0
                            : widget.columnSpacing,
                      ),
                      widget.columnSizes[7].createContainer(
                        child: Center(
                          child: Text(
                            widget.study.endedCount.toString(),
                            style: mutedTextStyleIfZero(
                              widget.study.endedCount,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: widget.columnSizes[7].collapsed
                            ? 0
                            : widget.columnSpacing,
                      ),
                      widget.columnSizes[8].createContainer(
                        child: _buildActionMenu(context, widget.actions),
                      ),
                      SizedBox(
                        width: widget.columnSizes[8].collapsed
                            ? 0
                            : widget.columnSpacing,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, List<ModelAction> actions) {
    final theme = Theme.of(context);

    return Align(
      child: ActionPopUpMenuButton(
        key: ValueKey('study_row_actions_${widget.study.id}'),
        actions: actions,
        enabled: !widget.isBusy,
        triggerIconColor: ThemeConfig.bodyTextMuted(theme).color
            ?.withValues(alpha: 0.6),
        triggerIconColorHover: theme.colorScheme.primary,
        disableSplashEffect: true,
        position: PopupMenuPosition.over,
      ),
    );
  }
}

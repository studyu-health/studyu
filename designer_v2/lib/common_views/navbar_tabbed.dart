import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

class NavbarTab({
  /// The text displayed as the tab's title
  required final String title,
  required final int index,

  /// The route to navigate to when switching to the tab
  final RoutingIntent? intent,
  final bool enabled = true,
});

typedef OnTabSelectCallback<T extends NavbarTab> = void Function(
  int tabIdx,
  T tab,
);

class const TabbedNavbar<T extends NavbarTab>({
  required final List<T> tabs,
  final T? selectedTab,
  final BoxDecoration? indicator,
  final double? height,
  final Color? disabledBackgroundColor,
  final String? disabledTooltipText,
  final OnTabSelectCallback<T>? onSelect,
  final EdgeInsets? labelPadding = const EdgeInsets.symmetric(horizontal: 20.0),
  final double? labelSpacing = 0,
  final TabBarIndicatorSize? indicatorSize,
  final bool isScrollable = false,
  final Color? backgroundColor,
  final WidgetStateProperty<Color>? overlayColor,
  final Color? labelColorHover,
  final Color? unselectedLabelColorHover,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TabbedNavbarState<T>();
}

class _TabbedNavbarState<T extends NavbarTab>()
    extends ConsumerState<TabbedNavbar>
    with TickerProviderStateMixin
    implements Listenable {
  /// A [TabController] that has its index synced to the currently selected
  /// tab provided by the widget. The widget's parameter may be injected e.g.
  /// via a router
  late final TabController _tabController;

  late int _selectedTabIndex =
      widget.selectedTab?.index ?? _findFirstEnabledTabIndex();
  int get selectedTabIndex => _selectedTabIndex;
  set selectedTabIndex(int idx) {
    final tab = widget.tabs[idx];
    final prevIdx = _selectedTabIndex;
    final int newIdx;
    if (!tab.enabled) {
      // prevent selecting disabled tabs
      newIdx = _findFirstEnabledTabIndex();
    } else {
      newIdx = tab.index;
    }
    _selectedTabIndex = newIdx;

    if (prevIdx != newIdx) {
      for (final listener in onTabChangedListeners) {
        listener();
      }
    }
  }

  T get selectedTab => widget.tabs[selectedTabIndex] as T;

  /// Registered listeners that are called immediately when changing the
  /// currently selected tab
  ///
  /// Note: [TabController.addListener] default listeners are only called
  /// after the animation has completed
  List<VoidCallback> onTabChangedListeners = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
    _tabController.index = selectedTabIndex;
    addListener(navigateToTabRoute);
    if (widget.onSelect != null) {
      addListener(() => widget.onSelect!(selectedTabIndex, selectedTab));
    }
  }

  void revalidateTabSelection() {
    final currentIdx = selectedTabIndex;
    selectedTabIndex = currentIdx;
  }

  @override
  void didUpdateWidget(TabbedNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    revalidateTabSelection();
    // Sync up the tab controller when a new widget is created
    // (e.g. by navigating to a different page)
    _tabController.animateTo(selectedTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    //_tabController.removeListener(resetDisabledTab);
    super.dispose();
  }

  @override
  void addListener(VoidCallback listener) {
    onTabChangedListeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    onTabChangedListeners.remove(listener);
  }

  void navigateToTabRoute() {
    if (!selectedTab.enabled || selectedTab.intent == null) {
      return;
    }
    runAsync(() => ref.read(routerProvider).dispatch(selectedTab.intent!));
  }

  void _onSelectTab(int tabIndex) {
    setState(() {
      selectedTabIndex = tabIndex;
    });
  }

  int _findFirstEnabledTabIndex() {
    for (final t in widget.tabs) {
      if (t.enabled) {
        return t.index;
      }
    }
    throw Exception("Must provide at least one non-disabled tab.");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget decorateIfDisabled({required Widget tabContent, required T tab}) {
      if (tab.enabled) {
        return tabContent;
      }
      final disablePointerCursor = MouseEventsRegion(
        builder: (context, state) => tabContent,
      );
      if (widget.disabledTooltipText != null) {
        return Tooltip(
          message: widget.disabledTooltipText,
          child: disablePointerCursor,
        );
      }
      return disablePointerCursor;
    }

    return Theme(
      data: theme.copyWith(splashColor: Colors.transparent),
      child: TabBar(
        key: const ValueKey('navbar_tab_bar'),
        dividerColor: Colors.transparent,
        isScrollable: widget.isScrollable,
        labelPadding: widget.labelPadding,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.8,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge,
        indicator: widget.indicator ?? theme.tabBarTheme.indicator,
        indicatorPadding: EdgeInsets.only(right: widget.labelSpacing ?? 0),
        indicatorSize: widget.indicatorSize,
        controller: _tabController,
        overlayColor: widget.overlayColor,
        tabs: (widget.tabs as List<T>)
            .map(
              (t) => decorateIfDisabled(
                tabContent: _buildTabContent(context, t),
                tab: t,
              ),
            )
            .toList(),
        onTap: _onSelectTab,
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, T t) {
    final theme = Theme.of(context);
    final indicatorHeight =
        (theme.tabBarTheme.indicator! as BoxDecoration)
            .border
            ?.dimensions
            .vertical ??
        0.0;

    return Container(
      key: ValueKey('navbar_tab_${t.index}'),
      decoration: (!t.enabled)
          ? BoxDecoration(color: widget.disabledBackgroundColor)
          : null,
      height: (widget.height != null) ? widget.height! - indicatorHeight : null,
      child: Row(
        children: [
          MouseEventsRegion(
            builder: (context, states) {
              final isSelected = t.index == selectedTabIndex;
              final isHovered = states.contains(WidgetState.hovered);

              TextStyle actualTextStyle = isSelected
                  ? theme.tabBarTheme.labelStyle ??
                        TextStyle(color: theme.tabBarTheme.labelColor)
                  : theme.tabBarTheme.unselectedLabelStyle ??
                        TextStyle(
                          color: theme.tabBarTheme.unselectedLabelColor,
                        );

              final mergeColorStyle = TextStyle(
                color: isSelected
                    ? widget.labelColorHover
                    : widget.unselectedLabelColorHover,
              );
              actualTextStyle = isHovered
                  ? actualTextStyle.merge(mergeColorStyle)
                  : actualTextStyle;

              return Align(
                child: Text(
                  t.title,
                  style: (!t.enabled)
                      ? TextStyle(
                          color: theme.disabledColor.withValues(alpha: 0.5),
                        )
                      : actualTextStyle,
                ),
              );
            },
            onTap: () => _onSelectTab(t.index), // pass through on-tap event
          ),
          MouseEventsRegion(
            builder: (context, states) {
              // wrap spacer in mouse region to disable pointer mouse cursor
              return Container(width: widget.labelSpacing);
            },
          ),
        ],
      ),
    );
  }
}

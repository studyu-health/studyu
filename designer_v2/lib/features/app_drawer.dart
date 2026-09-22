import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/assets.dart';
import 'package:studyu_designer_v2/common_views/icons.dart';
import 'package:studyu_designer_v2/features/account/account_settings.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/routing/router_utils.dart';

typedef OnEntrySelectedCallback = void Function(BuildContext, WidgetRef);

class const DrawerEntry({
  required final LocalizedStringResolver localizedTitle,
  required final bool autoCloseDrawer,
  final IconData? icon,
  final OnEntrySelectedCallback? onSelected,
  final LocalizedStringResolver? localizedHelpText,
  final bool enabled = true,
}) {
  String get title => localizedTitle();
  String? get helpText => localizedHelpText?.call();

  void onClick(BuildContext context, WidgetRef ref) {
    if (autoCloseDrawer) {
      Navigator.pop(context);
    }
    onSelected?.call(context, ref);
  }
}

class const GoRouterDrawerEntry({
  required super.localizedTitle,
  required super.autoCloseDrawer,
  super.icon,
  super.localizedHelpText,
  super.enabled,
  required final RoutingIntent intent,
  final void Function()? onNavigated,
}) extends DrawerEntry {
  @override
  void onClick(BuildContext context, WidgetRef ref) {
    super.onClick(context, ref);
    ref.read(routerProvider).dispatch(intent);
    onNavigated?.call();
  }
}

class const AppDrawer({
  final int width = 250,
  final bool autoCloseDrawer = true,
  final double leftPaddingEntries = 28.0,
  final double logoPaddingVertical = 24.0,
  final double logoPaddingHorizontal = 48.0,
  final double logoMaxHeight = 30,
  final double logoSectionMinHeight = 110,
  final double logoSectionMaxHeight = double.infinity,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState() extends ConsumerState<AppDrawer> {
  /// List of sections with their corresponding menu entries
  late final List<List<GoRouterDrawerEntry>> topEntries;

  /// List of sections with their corresponding menu entries
  late final List<List<DrawerEntry>> bottomEntries;

  List<DrawerEntry> get allEntries =>
      [...topEntries, ...bottomEntries].expand((e) => e).toList();

  /// Index of the currently selected navigation entry
  /// Defaults to -1 if none of the entries is currently selected
  int _selectedIdx = -1;

  /// Flag to ensure router listener is only set up once
  bool _routerListenerSetUp = false;

  /// Router reference for cleanup in dispose
  GoRouter? _router;

  @override
  void initState() {
    super.initState();

    // Initialize navigation entries
    topEntries = [
      [
        GoRouterDrawerEntry(
          localizedTitle: () => tr.navlink_my_studies,
          autoCloseDrawer: widget.autoCloseDrawer,
          icon: Icons.folder_copy_rounded,
          intent: RoutingIntents.studies,
          onNavigated: () => _updateSelectedRoute(hintEntryIdx: 0),
        ),
        GoRouterDrawerEntry(
          localizedTitle: () => tr.navlink_shared_studies,
          autoCloseDrawer: widget.autoCloseDrawer,
          icon: Icons.folder_shared_rounded,
          intent: RoutingIntents.studiesShared,
          enabled: false,
          onNavigated: () => _updateSelectedRoute(hintEntryIdx: 1),
        ),
      ],
      [
        GoRouterDrawerEntry(
          localizedTitle: () => tr.navlink_public_studies,
          autoCloseDrawer: widget.autoCloseDrawer,
          icon: Icons.public,
          intent: RoutingIntents.publicRegistry,
          localizedHelpText: () => tr.navlink_public_studies_tooltip,
          onNavigated: () => _updateSelectedRoute(hintEntryIdx: 2),
        ),
      ],
    ];

    bottomEntries = [
      [
        DrawerEntry(
          localizedTitle: () => tr.navlink_account_settings,
          autoCloseDrawer: widget.autoCloseDrawer,
          icon: Icons.settings_rounded,
          onSelected: (context, ref) {
            showDialog(
              context: context,
              builder: (context) => const AccountSettingsDialog(),
            );
          },
        ),
        DrawerEntry(
          localizedTitle: () => tr.navlink_logout,
          autoCloseDrawer: widget.autoCloseDrawer,
          icon: Icons.logout_rounded,
          onSelected: (context, ref) {
            ref.read(authRepositoryProvider).signOut();
          },
        ),
      ],
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Set up router listener to detect route changes
    if (!_routerListenerSetUp) {
      _router = ref.read(routerProvider);

      // Listen to route information changes directly from the router
      _router!.routeInformationProvider.addListener(_onRouteChanged);

      _routerListenerSetUp = true;
    }

    // Update the selected route when dependencies change
    _updateSelectedRoute();
  }

  @override
  void dispose() {
    // Clean up the route listener
    if (_routerListenerSetUp && _router != null) {
      _router!.routeInformationProvider.removeListener(_onRouteChanged);
    }
    super.dispose();
  }

  void _onRouteChanged() {
    // Schedule update for next frame to ensure route change is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateSelectedRoute();
      }
    });
  }

  void _updateSelectedRoute({int? hintEntryIdx}) {
    final entryIdx = hintEntryIdx ?? _getCurrentRouteIndex();
    setSelectedIdx(entryIdx);
  }

  int _getCurrentRouteIndex() {
    final currentRouteSettings = readCurrentRouteSettingsFrom(context);

    final idx = allEntries.indexWhere((e) {
      if (e is! GoRouterDrawerEntry) {
        return false;
      }
      return e.intent.matches(currentRouteSettings);
    });

    return idx;
  }

  void setSelectedIdx(int index) {
    if (_selectedIdx != index) {
      setState(() {
        _selectedIdx = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(splashColor: Colors.transparent), // disable splash
      child: Drawer(
        width: widget.width.toDouble(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: ListTileTheme(
                selectedColor: theme.colorScheme.primary,
                selectedTileColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: [
                    _buildLogo(context),
                    ..._buildTopMenuItems(context),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(children: _buildBottomMenuItems(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: widget.logoSectionMinHeight,
        maxHeight: widget.logoSectionMaxHeight,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: widget.logoMaxHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.logoPaddingHorizontal,
            vertical: widget.logoPaddingVertical,
          ),
          child: GestureDetector(
            onTap: () => ref.read(routerProvider).dispatch(RoutingIntents.root),
            child: Container(
              foregroundDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.4),
                backgroundBlendMode: BlendMode.color,
              ),
              child: Image.asset(Assets.logoWide, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );

    /* return Padding(
      padding: EdgeInsets.all(widget.leftPaddingEntries),
      child: SelectableText(
        widget.title,
        style: textTheme.headline5?.copyWith(fontWeight: FontWeight.bold),
      ),
    ); */
  }

  List<Widget> _buildSections(List<List<DrawerEntry>> sections) {
    final List<Widget> widgets = [];
    for (final section in sections) {
      for (final entry in section) {
        widgets.add(_entryToListTile(entry));
      }
      // Add section divider
      widgets.add(const SizedBox(height: 8));
      widgets.add(const Divider(height: 1));
      widgets.add(const SizedBox(height: 8));
    }
    // Remove the last section divider
    return widgets.sublist(0, widgets.length - 3);
  }

  List<Widget> _buildTopMenuItems(BuildContext context) {
    return _buildSections(topEntries);
  }

  List<Widget> _buildBottomMenuItems(BuildContext context) {
    return _buildSections(bottomEntries);
  }

  ListTile _entryToListTile(DrawerEntry entry) {
    final theme = Theme.of(context);
    final entryIdx = allEntries.indexOf(entry);
    final isSelected = entryIdx == _selectedIdx;

    return ListTile(
      trailing: (entry.helpText != null)
          ? IntrinsicWidth(
              child: Row(
                children: [
                  HelpIcon(tooltipText: entry.helpText),
                  const SizedBox(width: 24.0),
                ],
              ),
            )
          : null,
      leading: Icon(
        entry.icon,
        size: theme.iconTheme.size! * 1.2,
        color: isSelected
            ? null
            : (entry.enabled)
            ? theme.iconTheme.color!.withValues(alpha: 0.75)
            : theme.iconTheme.color!.withValues(alpha: 0.3),
      ),
      // hoverColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      title: Text(
        entry.title,
        style: isSelected ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
      contentPadding: EdgeInsets.only(left: widget.leftPaddingEntries),
      selected: isSelected,
      enabled: entry.enabled,
      onTap: () => entry.onClick(context, ref),
    );
  }
}

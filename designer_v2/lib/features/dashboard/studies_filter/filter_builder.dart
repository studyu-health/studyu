import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_draft_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/bool_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/date_range_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/enum_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_category.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/number_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/text_filter.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:uuid/uuid.dart';

class const FilterBuilder({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<FilterBuilder> createState() => _FilterBuilderState();
}

class _FilterBuilderState() extends ConsumerState<FilterBuilder> {
  // Text/Number inputs need controllers for the UI, but we sync them with state
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _participantCountController =
      TextEditingController();
  final TextEditingController _activeSubjectCountController =
      TextEditingController();
  final TextEditingController _endedCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize from current active filter if possible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFromProvider();
    });
  }

  void _initFromProvider() {
    final state = ref.read(dashboardControllerProvider);
    final activeFilter = state.activeFilter;
    final controller = ref.read(filterDraftControllerProvider.notifier);

    if (activeFilter != null) {
      String? presetId;
      if (state.selectedSavedFilterId != null) {
        presetId = state.selectedSavedFilterId;
      } else {
        // Try to find if this filter matches a saved preset
        final saved = state.savedFilters;
        for (final s in saved) {
          if (s.root == activeFilter) {
            presetId = s.id;
            break;
          }
        }
      }
      controller.initFromFilter(activeFilter, presetId: presetId);
      _syncControllers(ref.read(filterDraftControllerProvider));
    }

    // Attach listeners to update state on text change
    _titleController.addListener(() {
      ref
          .read(filterDraftControllerProvider.notifier)
          .updateTitle(_titleController.text);
    });
    _participantCountController.addListener(() {
      ref
          .read(filterDraftControllerProvider.notifier)
          .updateParticipantCount(_participantCountController.text);
    });
    _activeSubjectCountController.addListener(() {
      ref
          .read(filterDraftControllerProvider.notifier)
          .updateActiveSubjectCount(_activeSubjectCountController.text);
    });
    _endedCountController.addListener(() {
      ref
          .read(filterDraftControllerProvider.notifier)
          .updateEndedCount(_endedCountController.text);
    });
  }

  void _syncControllers(FilterDraft draft) {
    if (_titleController.text != draft.title) {
      _titleController.text = draft.title;
    }
    if (_participantCountController.text != draft.participantCount) {
      _participantCountController.text = draft.participantCount;
    }
    if (_activeSubjectCountController.text != draft.activeSubjectCount) {
      _activeSubjectCountController.text = draft.activeSubjectCount;
    }
    if (_endedCountController.text != draft.endedCount) {
      _endedCountController.text = draft.endedCount;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _participantCountController.dispose();
    _activeSubjectCountController.dispose();
    _endedCountController.dispose();
    super.dispose();
  }

  bool _areFiltersEqual(FilterElement? a, FilterElement? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.runtimeType != b.runtimeType) return false;

    if (a is FilterCondition && b is FilterCondition) {
      return a.property == b.property &&
          a.operator == b.operator &&
          a.value == b.value;
    } else if (a is FilterGroup && b is FilterGroup) {
      if (a.logic != b.logic) return false;
      if (a.children.length != b.children.length) return false;
      for (int i = 0; i < a.children.length; i++) {
        if (!_areFiltersEqual(a.children[i], b.children[i])) return false;
      }
      return true;
    }
    return false;
  }

  void _applyFilter() {
    final draft = ref.read(filterDraftControllerProvider);
    final group = draft.toFilterGroup;
    ref
        .read(dashboardControllerProvider.notifier)
        .updateFilter(group, presetId: draft.loadedPresetId);
  }

  void _onResetAll() {
    final controller = ref.read(filterDraftControllerProvider.notifier);
    controller.resetAll();
    _syncControllers(ref.read(filterDraftControllerProvider));
  }

  Future<void> _onSavePreset() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.filter_dialog_save_title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!
                .filter_dialog_preset_name_hint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.dialog_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(AppLocalizations.of(context)!.dialog_save),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final newId = const Uuid().v4();
      final filterDraft = ref.read(filterDraftControllerProvider);
      final filter = SavedFilter(
        id: newId,
        name: name,
        root: filterDraft.toFilterGroup,
      );
      ref.read(dashboardControllerProvider.notifier).saveFilter(filter);

      ref
          .read(filterDraftControllerProvider.notifier)
          .updateLoadedPreset(newId);
    }
  }

  void _onUpdatePreset() {
    final filterDraft = ref.read(filterDraftControllerProvider);
    if (filterDraft.loadedPresetId == null) return;

    final savedFilters = ref.read(dashboardControllerProvider).savedFilters;
    final existingIndex = savedFilters.indexWhere(
      (f) => f.id == filterDraft.loadedPresetId,
    );
    if (existingIndex == -1) return;

    final existing = savedFilters[existingIndex];
    final updated = SavedFilter(
      id: existing.id,
      name: existing.name,
      root: filterDraft.toFilterGroup,
      sortColumn: existing.sortColumn,
      sortAscending: existing.sortAscending,
      isDefault: existing.isDefault,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );

    ref.read(dashboardControllerProvider.notifier).deleteFilter(existing.id);
    ref.read(dashboardControllerProvider.notifier).saveFilter(updated);
  }

  void _onDeletePreset() {
    final loadedId = ref.read(filterDraftControllerProvider).loadedPresetId;
    if (loadedId == null) return;
    ref.read(dashboardControllerProvider.notifier).deleteFilter(loadedId);
    _onResetAll();
  }

  String _getStudyStatusLabel(StudyStatus status) {
    switch (status) {
      case StudyStatus.draft:
        return AppLocalizations.of(context)!.study_status_draft;
      case StudyStatus.running:
        return AppLocalizations.of(context)!.study_status_running;
      case StudyStatus.closed:
        return AppLocalizations.of(context)!.study_status_closed;
    }
  }

  String _getParticipationLabel(Participation participation) {
    switch (participation) {
      case Participation.open:
        return AppLocalizations.of(context)!.participation_open;
      case Participation.invite:
        return AppLocalizations.of(context)!.participation_invite;
    }
  }

  String _getResultSharingLabel(ResultSharing sharing) {
    switch (sharing) {
      case ResultSharing.public:
        return AppLocalizations.of(context)!.filter_result_sharing_public;
      case ResultSharing.private:
        return AppLocalizations.of(context)!.filter_result_sharing_private;
      case ResultSharing.organization:
        return AppLocalizations.of(context)!.filter_result_sharing_organization;
    }
  }

  String _getPresetTooltip(String? id) {
    if (id == DefaultPresets.myActiveStudies.id) {
      return AppLocalizations.of(context)!.preset_tooltip_my_active_studies;
    } else if (id == DefaultPresets.studiesNeedingAttention.id) {
      return AppLocalizations.of(context)!
          .preset_tooltip_studies_needing_attention;
    } else if (id == DefaultPresets.recentlyCreated.id) {
      return AppLocalizations.of(context)!.preset_tooltip_recently_created;
    } else if (id == DefaultPresets.publicStudies.id) {
      return AppLocalizations.of(context)!.preset_tooltip_public_studies;
    } else if (id == DefaultPresets.draftStudies.id) {
      return AppLocalizations.of(context)!.preset_tooltip_draft_studies;
    }
    return AppLocalizations.of(context)!.preset_custom;
  }

  String _getLocalizedPresetName(String id) {
    if (id == DefaultPresets.myActiveStudies.id) {
      return AppLocalizations.of(context)!.preset_my_active_studies;
    } else if (id == DefaultPresets.studiesNeedingAttention.id) {
      return AppLocalizations.of(context)!.preset_studies_needing_attention;
    } else if (id == DefaultPresets.recentlyCreated.id) {
      return AppLocalizations.of(context)!.preset_recently_created;
    } else if (id == DefaultPresets.publicStudies.id) {
      return AppLocalizations.of(context)!.preset_public_studies;
    } else if (id == DefaultPresets.draftStudies.id) {
      return AppLocalizations.of(context)!.preset_draft_studies;
    }
    return AppLocalizations.of(context)!.preset_custom;
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(filterDraftControllerProvider);
    final controller = ref.watch(filterDraftControllerProvider.notifier);

    SavedFilter? loadedPreset;
    if (draft.loadedPresetId != null) {
      try {
        loadedPreset = DefaultPresets.all.firstWhere(
          (p) => p.id == draft.loadedPresetId,
        );
      } catch (_) {
        try {
          loadedPreset = ref
              .watch(dashboardControllerProvider)
              .savedFilters
              .firstWhere((f) => f.id == draft.loadedPresetId);
        } catch (_) {
          // Preset ID not found (deleted?)
        }
      }
    }

    String loadedPresetName = AppLocalizations.of(context)!.preset_custom;
    final isDefault = DefaultPresets.all.any(
      (p) => p.id == draft.loadedPresetId,
    );

    if (loadedPreset != null) {
      if (isDefault) {
        loadedPresetName = _getLocalizedPresetName(loadedPreset.id);
      } else {
        loadedPresetName = loadedPreset.name;
      }
    }

    final currentGroup = draft.toFilterGroup;
    final hasChanges =
        loadedPreset != null &&
        !_areFiltersEqual(loadedPreset.root, currentGroup);

    // Auto-apply on close
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Apply filters when the drawer is closing
        if (didPop) {
          // Update synchronously to ensure the provider is updated before widget disposal
          // Note: _applyFilter reads the provider, which is fine.
          _applyFilter();
        }
      },

      child: Container(
        width: 480, // Slightly wider for better spacing
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Sticky Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.filter_studies,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Spacer(),
                      MenuAnchor(
                        builder: (context, controller, child) {
                          return OutlinedButton(
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                            child: Text(
                              AppLocalizations.of(context)!
                                  .filter_manage_presets,
                            ),
                          );
                        },
                        menuChildren: [
                          SubmenuButton(
                            menuChildren: [
                              ...DefaultPresets.all.map((preset) {
                                final theme = Theme.of(context);
                                final isSelected =
                                    draft.loadedPresetId == preset.id;
                                return MenuItemButton(
                                  leadingIcon: Icon(
                                    preset.icon ?? Icons.star_outline,
                                    size: 16,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                  trailingIcon: isSelected
                                      ? Icon(
                                          Icons.check,
                                          color: theme.colorScheme.primary,
                                        )
                                      : null,
                                  child: Tooltip(
                                    message: _getPresetTooltip(preset.id),
                                    child: Text(
                                      _getLocalizedPresetName(preset.id),
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : null,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : null,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    controller.initFromFilter(
                                      preset.root,
                                      presetId: preset.id,
                                    );
                                    _syncControllers(
                                      ref.read(filterDraftControllerProvider),
                                    );
                                  },
                                );
                              }),
                              const Divider(),
                              if (ref
                                  .read(dashboardControllerProvider)
                                  .savedFilters
                                  .isNotEmpty)
                                ...ref
                                    .read(dashboardControllerProvider)
                                    .savedFilters
                                    .map((preset) {
                                      final theme = Theme.of(context);
                                      final isSelected =
                                          draft.loadedPresetId == preset.id;
                                      return MenuItemButton(
                                        leadingIcon: Icon(
                                          preset.icon ?? Icons.perm_identity,
                                          size: 16,
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : null,
                                        ),
                                        trailingIcon: isSelected
                                            ? Icon(
                                                Icons.check,
                                                color:
                                                    theme.colorScheme.primary,
                                              )
                                            : null,
                                        child: Text(
                                          preset.name,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : null,
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : null,
                                          ),
                                        ),
                                        onPressed: () {
                                          controller.initFromFilter(
                                            preset.root,
                                            presetId: preset.id,
                                          );
                                          _syncControllers(
                                            ref.read(
                                              filterDraftControllerProvider,
                                            ),
                                          );
                                        },
                                      );
                                    })
                              else
                                MenuItemButton(
                                  child: Text(
                                    AppLocalizations.of(context)!.preset_none,
                                  ),
                                ),
                            ],
                            child: Text(
                              AppLocalizations.of(context)!.filter_load_preset,
                            ),
                          ),
                          MenuItemButton(
                            leadingIcon: const Icon(Icons.save_as, size: 18),
                            onPressed:
                                (isDefault ||
                                    draft.loadedPresetId == null ||
                                    !hasChanges)
                                ? null
                                : _onUpdatePreset,
                            child: Text(
                              AppLocalizations.of(context)!.filter_save_changes,
                            ),
                          ),
                          MenuItemButton(
                            leadingIcon: const Icon(Icons.save, size: 18),
                            onPressed: _onSavePreset,
                            child: Text(
                              AppLocalizations.of(context)!.filter_save_as_new,
                            ),
                          ),
                          MenuItemButton(
                            leadingIcon: Icon(
                              Icons.delete_outline,
                              color: (isDefault || draft.loadedPresetId == null)
                                  ? null
                                  : Colors.red,
                              size: 18,
                            ),
                            onPressed:
                                (isDefault || draft.loadedPresetId == null)
                                ? null
                                : _onDeletePreset,
                            child: Text(
                              AppLocalizations.of(context)!
                                  .filter_delete_preset,
                              style: TextStyle(
                                color:
                                    (isDefault || draft.loadedPresetId == null)
                                    ? null
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (draft.loadedPresetId != null) ...[
                    const SizedBox(height: 12),
                    Tooltip(
                      message: AppLocalizations.of(context)!
                          .preset_loaded_tooltip,
                      child: Chip(
                        label: Text(loadedPresetName),
                        onDeleted: _onResetAll,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilterCategory(
                      title: AppLocalizations.of(context)!
                          .filter_category_basic,
                      children: [
                        TextFilter(
                          title: AppLocalizations.of(context)!
                              .filter_field_title,
                          controller: _titleController,
                          op: draft.titleOp,
                          onOpChanged: controller.updateTitleOp,
                          isExpanded: draft.expandedFields.contains(
                            "Title".hardcoded,
                          ),
                          onExpansionChanged: (v) =>
                              controller.toggleExpansion("Title".hardcoded, v),
                        ),
                        EnumFilter<StudyStatus>(
                          title: AppLocalizations.of(context)!
                              .filter_field_status,
                          values: StudyStatus.values,
                          selected: draft.status,
                          op: draft.statusOp,
                          onChanged: controller.updateStatus,
                          onOpChanged: controller.updateStatusOp,
                          getValueLabel: _getStudyStatusLabel,
                          isExpanded: draft.expandedFields.contains(
                            "Status".hardcoded,
                          ),
                          onExpansionChanged: (v) =>
                              controller.toggleExpansion("Status".hardcoded, v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilterCategory(
                      title: AppLocalizations.of(context)!
                          .filter_category_visibility,
                      children: [
                        EnumFilter<Participation>(
                          title: AppLocalizations.of(context)!
                              .filter_field_participation,
                          values: Participation.values,
                          selected: draft.participation,
                          op: draft.participationOp,
                          onChanged: controller.updateParticipation,
                          onOpChanged: controller.updateParticipationOp,
                          getValueLabel: _getParticipationLabel,
                          isExpanded: draft.expandedFields.contains(
                            "Participation".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Participation".hardcoded,
                            v,
                          ),
                        ),
                        EnumFilter<ResultSharing>(
                          title: AppLocalizations.of(context)!
                              .filter_field_result_sharing,
                          values: ResultSharing.values,
                          selected: draft.resultSharing,
                          op: draft.resultSharingOp,
                          onChanged: controller.updateResultSharing,
                          onOpChanged: controller.updateResultSharingOp,
                          getValueLabel: _getResultSharingLabel,
                          isExpanded: draft.expandedFields.contains(
                            "Result Sharing".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Result Sharing".hardcoded,
                            v,
                          ),
                        ),
                        BoolFilter(
                          title: AppLocalizations.of(context)!
                              .filter_field_registry_published,
                          selected: draft.registryPublished,
                          op: draft.registryPublishedOp,
                          onChanged: controller.updateRegistryPublished,
                          onOpChanged: controller.updateRegistryPublishedOp,
                          isExpanded: draft.expandedFields.contains(
                            "Registry Published".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Registry Published".hardcoded,
                            v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilterCategory(
                      title: AppLocalizations.of(context)!
                          .filter_category_participants,
                      children: [
                        NumberFilter(
                          title: AppLocalizations.of(context)!
                              .filter_field_participant_count,
                          controller: _participantCountController,
                          op: draft.participantCountOp,
                          onOpChanged: controller.updateParticipantCountOp,
                          isExpanded: draft.expandedFields.contains(
                            "Participant Count".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Participant Count".hardcoded,
                            v,
                          ),
                        ),
                        NumberFilter(
                          title: AppLocalizations.of(context)!
                              .filter_field_active_count,
                          controller: _activeSubjectCountController,
                          op: draft.activeSubjectCountOp,
                          onOpChanged: controller.updateActiveSubjectCountOp,
                          isExpanded: draft.expandedFields.contains(
                            "Active Count".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Active Count".hardcoded,
                            v,
                          ),
                        ),
                        NumberFilter(
                          title: AppLocalizations.of(context)!
                              .filter_field_completed_count,
                          controller: _endedCountController,
                          op: draft.endedCountOp,
                          onOpChanged: controller.updateEndedCountOp,
                          isExpanded: draft.expandedFields.contains(
                            "Completed Count".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Completed Count".hardcoded,
                            v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilterCategory(
                      title: AppLocalizations.of(context)!
                          .filter_category_dates,
                      children: [
                        DateRangeFilter(
                          start: draft.createdAfter,
                          end: draft.createdBefore,
                          onStartChanged: controller.updateCreatedAfter,
                          onEndChanged: controller.updateCreatedBefore,
                          isExpanded: draft.expandedFields.contains(
                            "Created Date".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Created Date".hardcoded,
                            v,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),
            // Sticky Footer
            Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _onResetAll,
                        icon: const Icon(Icons.restart_alt),
                        label: Text(
                          AppLocalizations.of(context)!.filter_reset_all,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),

                      FilledButton.icon(
                        onPressed: () {
                          _applyFilter();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.check),
                        label: Text(
                          AppLocalizations.of(context)!.filter_studies,
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

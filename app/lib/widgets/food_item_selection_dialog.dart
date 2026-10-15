import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/services/food_analysis_service.dart';

/// A dialog for selecting which food items to add when LLM detects multiple
/// items in an image.
class const FoodItemSelectionDialog({
  /// The list of analyzed food items to select from.
  required final List<AnalyzedFoodItem> items,

  /// Overall confidence score for the analysis.
  required final double overallConfidence,

  /// Optional notes about the analysis.
  final String? notes,
  super.key,
}) extends StatefulWidget {
  /// Creates a new [FoodItemSelectionDialog].
  this;

  /// Shows the dialog and returns the selected items.
  static Future<List<AnalyzedFoodItem>?> show(
    BuildContext context, {
    required List<AnalyzedFoodItem> items,
    required double overallConfidence,
    String? notes,
  }) {
    return showDialog<List<AnalyzedFoodItem>>(
      context: context,
      builder: (context) => FoodItemSelectionDialog(
        items: items,
        overallConfidence: overallConfidence,
        notes: notes,
      ),
    );
  }

  @override
  State<FoodItemSelectionDialog> createState() =>
      _FoodItemSelectionDialogState();
}

class _FoodItemSelectionDialogState() extends State<FoodItemSelectionDialog> {
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    // By default, select all items with confidence > 0.5
    for (var i = 0; i < widget.items.length; i++) {
      if (widget.items[i].confidenceScore >= 0.5) {
        _selectedIndices.add(i);
      }
    }
  }

  void _toggleItem(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIndices.addAll(List.generate(widget.items.length, (i) => i));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedIndices.clear();
    });
  }

  void _confirmSelection() {
    final selectedItems = _selectedIndices
        .map((index) => widget.items[index])
        .toList();
    Navigator.of(context).pop(selectedItems);
  }

  void _analyzeAgain() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.selectFoodItemsTitle),
          const SizedBox(height: 4),
          Text(
            l10n.selectFoodItemsSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Analysis info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.confidenceLabel(
                            (widget.overallConfidence * 100).round(),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        if (widget.notes != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.notes!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Select/Deselect all buttons
            Row(
              children: [
                TextButton(onPressed: _selectAll, child: Text(l10n.select_all)),
                TextButton(
                  onPressed: _deselectAll,
                  child: Text(l10n.deselect_all),
                ),
              ],
            ),

            // Items list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = _selectedIndices.contains(index);

                  return _FoodItemTile(
                    item: item,
                    isSelected: isSelected,
                    onToggle: () => _toggleItem(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _analyzeAgain, child: Text(l10n.analyzeAgain)),
        FilledButton(
          onPressed: _selectedIndices.isNotEmpty ? _confirmSelection : null,
          child: Text(l10n.addSelected),
        ),
      ],
    );
  }
}

class const _FoodItemTile({
  required final AnalyzedFoodItem item,
  required final bool isSelected,
  required final VoidCallback onToggle,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final food = item.foodEntry;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(value: isSelected, onChanged: (_) => onToggle()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (food.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        food.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${food.amount} ${food.unit}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${food.nutrition.energyKcal.toStringAsFixed(0)} kcal',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Confidence indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(theme, item.confidenceScore),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(item.confidenceScore * 100).round()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(ThemeData theme, double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

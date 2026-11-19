import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

class const NutritionWaterCard({
  required final int? waterIntakeMl,
  required final int cupSizeMl,
  required final bool readOnly,
  required final ValueChanged<int>? onAdjust,
  required final VoidCallback? onEditCupSize,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final materialL10n = MaterialLocalizations.of(context);
    String volume(int amount) => '${materialL10n.formatDecimal(amount)} mL';
    final amountMl = waterIntakeMl ?? 0;
    final adjust = onAdjust;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 12,
              children: [
                Icon(
                  Icons.local_drink_outlined,
                  color: theme.colorScheme.primary,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.nutrition_water,
                        style: theme.textTheme.titleMedium,
                      ),
                      Semantics(
                        liveRegion: !readOnly,
                        child: Text(
                          readOnly && waterIntakeMl == null
                              ? l10n.nutrition_water_unlogged
                              : volume(amountMl),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!readOnly)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.outlined(
                        tooltip: l10n.nutrition_water_remove_cup,
                        onPressed: adjust == null || amountMl == 0
                            ? null
                            : () => adjust(-cupSizeMl),
                        icon: const Icon(Icons.remove),
                      ),
                      IconButton.filledTonal(
                        tooltip: l10n.nutrition_water_add_cup,
                        onPressed: adjust == null
                            ? null
                            : () => adjust(cupSizeMl),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
              ],
            ),
            if (!readOnly)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: onEditCupSize,
                  child: Text(
                    '${l10n.nutrition_water_cup_size} · ${volume(cupSizeMl)}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

bool isValidWaterCupSize(int sizeMl) => sizeMl >= 1 && sizeMl <= 9999;

Future<int?> showWaterCupSizeDialog(BuildContext context, int currentSizeMl) {
  final formKey = GlobalKey<FormState>();
  var input = currentSizeMl.toString();
  return showDialog<int>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return AlertDialog(
        scrollable: true,
        title: Text(l10n.nutrition_water_cup_size),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: input,
            decoration: const InputDecoration(suffixText: 'mL'),
            keyboardType: TextInputType.number,
            autofocus: true,
            onChanged: (value) => input = value,
            validator: (value) {
              final size = int.tryParse(value?.trim() ?? '', radix: 10);
              return size != null && isValidWaterCupSize(size)
                  ? null
                  : l10n.nutrition_water_cup_size_invalid;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(context).pop(int.parse(input.trim(), radix: 10));
            },
            child: Text(l10n.save),
          ),
        ],
      );
    },
  );
}

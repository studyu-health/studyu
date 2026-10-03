import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/core.dart' as studyu;

Duration selectionAnimationDuration(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : const Duration(milliseconds: 180);

Offset? globalCenter(BuildContext context) {
  final renderObject = context.findRenderObject();
  if (renderObject is! RenderBox ||
      !renderObject.attached ||
      !renderObject.hasSize) {
    return null;
  }
  return renderObject.localToGlobal(renderObject.size.center(Offset.zero));
}

class const SelectionFeedbackCard({
  required final bool selected,
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected
        ? colorScheme.primaryContainer.withValues(alpha: 0.55)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    return Semantics(
      selected: selected,
      child: TweenAnimationBuilder<Color?>(
        duration: selectionAnimationDuration(context),
        tween: ColorTween(end: color),
        builder: (context, color, child) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: color,
          child: child,
        ),
        child: child,
      ),
    );
  }
}

class const SelectionQuantityText({
  required final int quantity,
  final TextStyle? style,
  super.key,
}) extends StatefulWidget {
  @override
  State<SelectionQuantityText> createState() => _SelectionQuantityTextState();
}

class _SelectionQuantityTextState() extends State<SelectionQuantityText> {
  int _direction = 1;

  @override
  void didUpdateWidget(SelectionQuantityText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity) {
      _direction = widget.quantity > oldWidget.quantity ? 1 : -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: selectionAnimationDuration(context),
        transitionBuilder: (child, animation) {
          final incoming = child.key == ValueKey(widget.quantity);
          final offset = 0.3 * _direction * (incoming ? 1 : -1);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: Offset(0, offset), end: Offset.zero)
                  .animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        child: Text(
          '${widget.quantity}',
          key: ValueKey(widget.quantity),
          style: widget.style,
        ),
      ),
    );
  }
}

class const SelectionQuantityButton({
  required final String tooltip,
  required final IconData icon,
  required final VoidCallback? onPressed,
  final VisualDensity? visualDensity,
  super.key,
}) extends StatefulWidget {
  @override
  State<SelectionQuantityButton> createState() =>
      _SelectionQuantityButtonState();
}

class _SelectionQuantityButtonState() extends State<SelectionQuantityButton> {
  bool _pressed = false;
  bool _pointerInteraction = false;
  int _releaseGeneration = 0;

  bool get _motionDisabled => MediaQuery.disableAnimationsOf(context);

  @override
  void didUpdateWidget(SelectionQuantityButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed == null) {
      _releaseGeneration++;
      _pressed = false;
      _pointerInteraction = false;
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.onPressed == null || _motionDisabled) return;
    _releaseGeneration++;
    _pointerInteraction = true;
    setState(() => _pressed = true);
  }

  void _releasePointer(PointerEvent event) {
    if (!_pointerInteraction) return;
    _scheduleRelease();
  }

  void _scheduleRelease() {
    final generation = ++_releaseGeneration;
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || generation != _releaseGeneration) return;
      setState(() {
        _pressed = false;
        _pointerInteraction = false;
      });
    });
  }

  void _onPressed() {
    if (!_pointerInteraction && !_motionDisabled) {
      setState(() => _pressed = true);
      _scheduleRelease();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final motionDisabled = MediaQuery.disableAnimationsOf(context);
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _releasePointer,
      onPointerCancel: _releasePointer,
      child: AnimatedScale(
        scale: motionDisabled || !_pressed ? 1 : 0.96,
        duration: motionDisabled
            ? Duration.zero
            : const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: SizedBox.square(
          dimension: 48,
          child: IconButton(
            tooltip: widget.tooltip,
            onPressed: widget.onPressed == null ? null : _onPressed,
            icon: Icon(widget.icon),
            visualDensity: widget.visualDensity,
          ),
        ),
      ),
    );
  }
}

class const SelectionQuantityControl({
  required final String name,
  required final int quantity,
  required final ValueChanged<Offset?> onIncrement,
  required final VoidCallback onDecrement,
  final GlobalKey? quantityAnchorKey,
  final TextStyle? quantityStyle,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      container: true,
      selected: true,
      label: l10n.food_selection_selected(name, quantity),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectionQuantityButton(
            tooltip: l10n.food_selection_decrement(name),
            onPressed: onDecrement,
            icon: Icons.remove,
            visualDensity: VisualDensity.compact,
          ),
          SelectionQuantityText(
            key: quantityAnchorKey,
            quantity: quantity,
            style: quantityStyle,
          ),
          Builder(
            builder: (buttonContext) => SelectionQuantityButton(
              tooltip: l10n.food_selection_increment(name),
              onPressed: () => onIncrement(globalCenter(buttonContext)),
              icon: Icons.add,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

String formatFoodNumber(double value) => value == value.roundToDouble()
    ? value.round().toString()
    : value.toStringAsFixed(1);

num foodServingAmount(double value) =>
    value == value.roundToDouble() ? value.round() : value;

String formatFoodMetadata(
  AppLocalizations l10n, {
  double? grams,
  required String servingDescription,
  double? calories,
}) {
  final quantity = grams != null && grams.isFinite && grams > 0
      ? '${formatFoodNumber(grams)} g'
      : servingDescription;
  final energy = calories != null && calories.isFinite && calories >= 0
      ? l10n.kcal_value(calories.round().toString())
      : '— kcal';
  return '$quantity · $energy';
}

String foodTotalMetadata(
  AppLocalizations l10n,
  studyu.FoodEntry food,
  int quantity, {
  bool gramsKnown = true,
  bool caloriesKnown = true,
}) {
  final totalAmount = food.amount * quantity;
  final portionReference = food.portionReference?.trim();
  final servingDescription =
      portionReference != null && portionReference.isNotEmpty
      ? totalAmount == 1
            ? portionReference
            : '${formatFoodNumber(totalAmount)} × $portionReference'
      : l10n.serving_amount(foodServingAmount(totalAmount));
  final hasCalories =
      caloriesKnown &&
      !food.nutrition.unavailableNutrients.contains('energyKcal');
  return formatFoodMetadata(
    l10n,
    grams: gramsKnown ? food.servingSizeGrams * totalAmount : null,
    servingDescription: servingDescription,
    calories: hasCalories
        ? food.nutrition.energyKcal *
              (food.entryType == studyu.FoodEntryType.meal
                  ? totalAmount
                  : quantity)
        : null,
  );
}

String? foodImageUrl(studyu.FoodEntry food) {
  for (final key in [
    'image_front_small_url',
    'image_front_url',
    'image_url',
    'imageUrl',
  ]) {
    final value = food.originalValues[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  return null;
}

class const FoodDetailsAffordance({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Tooltip(
    message: AppLocalizations.of(context)!.details,
    child: const SizedBox(
      width: 40,
      height: 48,
      child: Icon(Icons.chevron_right, size: 22),
    ),
  );
}

Widget fallbackFoodIcon(ThemeData theme, IconData icon, {double size = 22}) =>
    Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: size, color: theme.colorScheme.onSurfaceVariant),
    );

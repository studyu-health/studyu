import 'package:flutter/material.dart';

const nutritionEditorWidth = 640.0;
const nutritionEditorSpacing = 12.0;

InputDecoration nutritionFieldDecoration(
  String label, {
  IconData? icon,
  String? unit,
  String? hint,
  String? helper,
}) => InputDecoration(
  labelText: label,
  border: const OutlineInputBorder(),
  prefixIcon: icon == null ? null : Icon(icon, size: 20),
  prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 48),
  suffixText: unit,
  floatingLabelBehavior: unit == null ? null : FloatingLabelBehavior.always,
  hintText: hint,
  helperText: helper,
  helperMaxLines: 2,
);

class const NutritionEditorTitle({required final String title})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text(
    title,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

class const NutritionEditorForm({
  required final GlobalKey<FormState> formKey,
  required final List<Widget> children,
  final double bottomClearance = 0,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(
        bottom: bottomClearance + MediaQuery.paddingOf(context).bottom,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: nutritionEditorWidth),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: nutritionEditorSpacing,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class const NutritionEditorSection({
  required final String title,
  required final List<Widget> children,
  final IconData? icon,
  final String? subtitle,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (subtitle case final description?)
            Semantics(
              header: true,
              child: ListTile(
                leading: icon == null ? null : Icon(icon),
                iconColor: theme.colorScheme.primary,
                title: Text(title),
                subtitle: Text(description),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, subtitle == null ? 16 : 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: nutritionEditorSpacing,
              children: [
                if (subtitle == null)
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class const NutritionEditorExpansion({
  required final IconData icon,
  required final String title,
  required final String subtitle,
  required final List<Widget> children,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: nutritionEditorSpacing,
            children: children,
          ),
        ],
      ),
    );
  }
}

class const NutritionEditorFields({
  required final List<Widget> children,
  final double minimumFieldWidth = 160,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = MediaQuery.textScalerOf(context)
            .scale(minimumFieldWidth);
        final rowWidth =
            fieldWidth * children.length +
            nutritionEditorSpacing * (children.length - 1);
        if (constraints.maxWidth < rowWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: nutritionEditorSpacing,
            children: children,
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: nutritionEditorSpacing,
          children: [for (final child in children) Expanded(child: child)],
        );
      },
    );
  }
}

class const NutritionCurrentMealOnlyNotice({
  required final String message,
  required final ThemeData theme,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: true,
    label: message,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.onSecondaryContainer,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

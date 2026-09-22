import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

class const BottomOnboardingNavigation({
  super.key,
  final VoidCallback? onNext,
  final VoidCallback? onBack,
  final String? backLabel,
  final String? nextLabel,
  final bool hideNext = false,
  final bool hideBack = false,
  final bool backEnabled = true,
  final bool showNextIcon = true,
  final bool showBackIcon = true,
  final bool primaryNext = false,
  final Icon? nextIcon,
  final Icon? backIcon,
  final Widget? progress,
  final Key? backButtonKey,
  final Key? nextButtonKey,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // A custom onBack handler may perform its own navigation regardless of
    // whether the navigator stack has entries, so we only gate pop-based
    // navigation on canPop; custom handlers are always enabled when
    // backEnabled is true.
    final canNavigateBack = backEnabled && (onBack != null || context.canPop());

    void handleBack() {
      if (onBack != null) {
        onBack!.call();
        return;
      }

      context.pop();
    }

    final nextButtonChild = Row(
      children: [
        Text(nextLabel ?? AppLocalizations.of(context)!.next),
        if (showNextIcon) nextIcon ?? const Icon(Icons.navigate_next),
      ],
    );

    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Visibility(
              visible: !hideBack && (onBack != null || context.canPop()),
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TextButton(
                key: backButtonKey,
                onPressed: canNavigateBack ? handleBack : null,
                child: Row(
                  children: [
                    if (showBackIcon)
                      backIcon ?? const Icon(Icons.navigate_before),
                    Text(backLabel ?? AppLocalizations.of(context)!.back),
                  ],
                ),
              ),
            ),
            if (progress != null) ...[
              const SizedBox(width: 8),
              Expanded(child: progress!),
              const SizedBox(width: 8),
            ] else
              const Spacer(),
            Visibility(
              visible: !hideNext,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: primaryNext
                  ? FilledButton(
                      key: nextButtonKey,
                      onPressed: onNext,
                      child: nextButtonChild,
                    )
                  : TextButton(
                      key: nextButtonKey,
                      onPressed: onNext,
                      child: nextButtonChild,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

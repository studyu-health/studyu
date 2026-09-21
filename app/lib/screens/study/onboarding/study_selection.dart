import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/invite_qr_scanner.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';
import 'package:studyu_app/widgets/study_tile.dart';
import 'package:studyu_app/widgets/why_dialog.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> navigateToStudyOverview(
  BuildContext context,
  Study study, {
  String? inviteCode,
  List<String>? preselectedIds,
}) async {
  final state = context.read<AppState>()
    ..preselectedInterventionIds = preselectedIds
    ..inviteCode = inviteCode
    ..selectedStudy = study
    // Reset any state left over from an abandoned enrollment.
    ..onboardingPhase = null;
  // Selecting a different study abandons a draft (un-started) subject;
  // a started subject can never reach this flow.
  if (!state.isPreview && state.activeSubject?.startedAt == null) {
    state.activeSubject = null;
  }
  context.push('/${RouteNames.studyOverview}');
}

Future<void> showAppOutdatedDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.study_selection_unsupported_title,
      ),
      content: Text(AppLocalizations.of(context)!.study_selection_unsupported),
      actions: [
        TextButton(
          key: const ValueKey('dialog_ok'),
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.ok),
        ),
      ],
    ),
  );
}

Future<void> showStudyClosedDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      key: const ValueKey('study_closed_dialog'),
      title: Text(AppLocalizations.of(context)!.study_selection_closed_title),
      content: Text(AppLocalizations.of(context)!.study_selection_closed),
      actions: [
        TextButton(
          key: const ValueKey('dialog_ok'),
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.ok),
        ),
      ],
    ),
  );
}

class const StudySelectionScreen({
  super.key,
  final Future<ExtractionResult<Study>>? publicStudies,
}) extends StatefulWidget {
  @override
  State<StudySelectionScreen> createState() => _StudySelectionScreenState();
}

class _StudySelectionScreenState() extends State<StudySelectionScreen> {
  bool _hiddenStudies = false;

  Future<ExtractionResult<Study>> get publishedStudies =>
      widget.publicStudies ?? Study.publishedPublicStudies();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteNames.welcome);
            }
          },
        ),
        title: Text(AppLocalizations.of(context)!.browse_public_studies),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: RetryFutureBuilder<ExtractionResult<Study>>(
              tryFunction: () => publishedStudies,
              trackConnectionStatus: true,
              successBuilder:
                  (
                    BuildContext context,
                    ExtractionResult<Study>? extractionResult,
                  ) {
                    final studies = extractionResult!.extracted;
                    if (extractionResult is ExtractionFailedException<Study>) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_hiddenStudies) return;
                        debugPrint(
                          '${extractionResult.notExtracted.length} studies could not be extracted.',
                        );
                        setState(() {
                          _hiddenStudies = true;
                        });
                      });
                    }

                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverToBoxAdapter(
                            child: StudyOnboardingDescription(
                              text: AppLocalizations.of(context)!
                                  .study_selection_single,
                              actionLabel: AppLocalizations.of(context)!
                                  .study_selection_single_why,
                              onAction: () => showDialog(
                                context: context,
                                builder: (context) => WhyDialog(
                                  content: AppLocalizations.of(context)!
                                      .study_selection_single_reason,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        if (_hiddenStudies) ...[
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverToBoxAdapter(
                              child: MaterialBanner(
                                padding: const EdgeInsets.all(8),
                                leading: const Icon(
                                  MdiIcons.exclamationThick,
                                  color: Colors.orange,
                                  size: 32,
                                ),
                                content: Text(
                                  AppLocalizations.of(context)!
                                      .study_selection_hidden_studies,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                actions: const [SizedBox.shrink()],
                                backgroundColor: Colors.yellow[100],
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        ],
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          sliver: studies.isEmpty
                              ? const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: NoPublicStudiesWidget(),
                                )
                              : SliverList.builder(
                                  itemCount: studies.length,
                                  itemBuilder: (context, index) {
                                    final study = studies[index];
                                    return Material(
                                      child: InkWell(
                                        onTap: () {
                                          unawaited(
                                            navigateToStudyOverview(
                                              context,
                                              study,
                                            ),
                                          );
                                        },
                                        child: Hero(
                                          tag: 'study_tile_${study.id}',
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: StudyTile.fromStudy(
                                              study: study,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
            ),
          ),
        ),
      ),
    );
  }
}

class const NoPublicStudiesWidget({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.study_selection_no_public_studies,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class const InviteCodeDialog({super.key}) extends StatefulWidget {
  @override
  State<InviteCodeDialog> createState() => _InviteCodeDialogState();
}

class _InviteCodeDialogState() extends State<InviteCodeDialog> {
  final _controller = TextEditingController();
  String? _errorMessage;

  Future<void> _scanInviteCode() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const InviteQrScannerScreen()),
    );
    if (!mounted || code == null) return;

    _controller
      ..text = code
      ..selection = TextSelection.collapsed(offset: code.length);
    await _submitInviteCode();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitInviteCode() async {
    final code = _controller.text.trim();
    try {
      final (invite, study) = await Study.fetchByInviteCode(code);

      if (!mounted) return;

      if (study == null) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.invalid_invite_code;
        });
        return;
      }

      setState(() {
        _errorMessage = null;
      });

      if (study.isClosed) {
        if (!context.mounted) return;
        context.pop();
        await showStudyClosedDialog(context);
        return;
      }

      if (!context.mounted) return;
      context.pop();

      await navigateToStudyOverview(
        context,
        study,
        inviteCode: code,
        preselectedIds: invite?.preselectedInterventionIds,
      );
    } catch (e) {
      if (!mounted) return;
      if (e is ArgumentError) {
        // A newer study schema requires an app update.
        setState(() => _errorMessage = null);
        context.pop();
        await showAppOutdatedDialog(context);
      } else if (e is PostgrestException) {
        setState(
          () =>
              _errorMessage = AppLocalizations.of(context)!
                  .error_occurred_with_message(e.message),
        );
      } else {
        setState(
          () =>
              _errorMessage = AppLocalizations.of(context)!.invalid_invite_code,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.private_study_invite_code),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.private_study_invite_code_description),
          const SizedBox(height: 16),
          TextFormField(
            controller: _controller,
            autofocus: true,
            validator: (_) => _errorMessage,
            autovalidateMode: AutovalidateMode.always,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => unawaited(_submitInviteCode()),
            decoration: InputDecoration(
              labelText: l10n.invite_code,
              suffixIcon: IconButton(
                tooltip: l10n.scan_invite_code,
                onPressed: _scanInviteCode,
                icon: const Icon(Icons.qr_code_scanner),
              ),
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: _submitInviteCode,
          child: Text(l10n.continue_label),
        ),
      ],
    );
  }
}

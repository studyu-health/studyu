import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';
import 'package:studyu_app/widgets/title_description_layout.dart';
import 'package:studyu_core/core.dart';

class const RestoreAccountScreen({super.key}) extends StatefulWidget {
  @override
  State<RestoreAccountScreen> createState() => _RestoreAccountScreenState();
}

class _RestoreAccountScreenState() extends State<RestoreAccountScreen> {
  final TextEditingController _phraseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isLoading = false;
  List<String> _words = [];
  bool get _hasTooManyWords => _words.length > RecoveryConstants.totalWordCount;
  bool get _canSubmitPhrase =>
      !_isLoading && _words.length == RecoveryConstants.totalWordCount;

  @override
  void initState() {
    super.initState();
    _phraseController.addListener(_onPhraseChanged);
  }

  @override
  void dispose() {
    _phraseController.removeListener(_onPhraseChanged);
    _phraseController.dispose();
    super.dispose();
  }

  void _onPhraseChanged() {
    setState(() {
      _words = _phraseController.text
          .trim()
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .toList();
    });
  }

  String _getErrorMessage(String? errorKey) {
    final localizations = AppLocalizations.of(context)!;

    switch (errorKey) {
      case 'User not found':
        return localizations.recovery_user_not_found;
      case 'recovery_user_not_found':
        return localizations.recovery_user_not_found;
      case 'recovery_network_error':
        return localizations.recovery_network_error;
      case 'recovery_failed':
        return localizations.recovery_failed;
      default:
        return localizations.recovery_failed;
    }
  }

  Future<void> _validateAndSubmit() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final localizations = AppLocalizations.of(context)!;
    final words = _words.map((w) => w.trim().toLowerCase()).toList();

    if (words.length != RecoveryConstants.totalWordCount) {
      setState(() {
        _errorMessage = words.length > RecoveryConstants.totalWordCount
            ? localizations.recovery_phrase_too_many_words
            : localizations.invalid_recovery_phrase;
      });
      return;
    }

    try {
      final id = RestoreAccountService.decodeRecoveryPhrase(words);
      if (RestoreAccountService.isUserLoggedIn &&
          !await _confirmAccountRestoration()) {
        return;
      }
      await _onSuccess(id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = localizations.invalid_recovery_phrase;
      });
    }
  }

  Future<bool> _confirmAccountRestoration() async {
    final localizations = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(localizations.restore_account_signed_in_title),
            content: Text(localizations.restore_account_signed_in_description),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(localizations.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(localizations.restore_account),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _onSuccess(BigInt id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await RestoreAccountService.performRecovery(
        id,
        appState: context.read<AppState>(),
      );

      if (!mounted) return;

      if (!result.success) {
        setState(() {
          _errorMessage = _getErrorMessage(result.error);
          _isLoading = false;
        });
        return;
      }

      if (!mounted) return;

      if (result.subjectId != null) {
        context.goNamed(RouteNames.loading);
      } else {
        context.goNamed(RouteNames.studySelection);
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      StudyULogger.warning('Recovery error: $e\n$stackTrace');

      setState(() {
        _errorMessage = AppLocalizations.of(context)!.recovery_network_error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.restore_account),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteNames.welcome);
            }
          },
        ),
      ),
      body: TitleDescriptionLayout(
        descriptionWidget: StudyOnboardingDescription(
          text: AppLocalizations.of(context)!.restore_account_description,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _phraseController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!
                      .enter_recovery_phrase,
                  hintText: 'apple banana cherry ...',
                  border: const OutlineInputBorder(),
                  helperText: _hasTooManyWords
                      ? AppLocalizations.of(context)!
                            .recovery_phrase_too_many_words
                      : AppLocalizations.of(context)!
                            .recovery_phrase_word_count(
                              _words.length,
                              RecoveryConstants.totalWordCount,
                            ),
                  helperStyle: TextStyle(
                    color: _hasTooManyWords
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.normal,
                  ),
                  suffixIcon: _words.length == RecoveryConstants.totalWordCount
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                maxLines: 4,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (_canSubmitPhrase) _validateAndSubmit();
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.required;
                  }
                  if (_hasTooManyWords) {
                    return AppLocalizations.of(context)!
                        .recovery_phrase_too_many_words;
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _canSubmitPhrase ? _validateAndSubmit : null,
                child: _isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.recovery_in_progress,
                          ),
                        ],
                      )
                    : Text(AppLocalizations.of(context)!.restore_account),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

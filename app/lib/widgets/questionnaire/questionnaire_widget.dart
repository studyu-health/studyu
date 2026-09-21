import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_app/widgets/questionnaire/question_container.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_controller.dart';
import 'package:studyu_app/widgets/questionnaire/questions/free_text_question_widget.dart';
import 'package:studyu_core/core.dart';

typedef StateHandler = void Function(QuestionnaireState?);
typedef ContinuationPredicate = bool Function(QuestionnaireState);

class const QuestionnaireWidget(
  final List<Question> questions, {
  final String? taskId,
  final String? title,
  final String? header,
  final String? footer,
  final StateHandler? onComplete,
  final ContinuationPredicate? shouldContinue,

  /// When true, the global CTA shows a loading spinner and is disabled.
  /// The parent sets this while it processes a completed submission.
  final bool isSubmitting = false,
  final bool hideCta = false,
  final bool autoComplete = false,
  super.key,
}) extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => QuestionnaireWidgetState();
}

class QuestionnaireWidgetState() extends State<QuestionnaireWidget> {
  late final QuestionnaireController _controller;
  final List<QuestionContainer> shownQuestions = <QuestionContainer>[];
  final List<GlobalKey> questionKeys = <GlobalKey>[];
  final _scrollController = ScrollController();
  final _completeButtonFocusNode = FocusNode(
    debugLabel: 'questionnaire_complete',
  );
  bool _isProgrammaticScroll = false;

  // Stable keys reused across rebuilds to preserve widget state.
  final Map<String, GlobalKey> _containerKeys = {};
  final Map<String, GlobalKey<FreeTextQuestionWidgetState>> _freeTextKeys = {};
  final Set<String> _shownReviewErrors = {};
  final Set<String> _reviewedAnswerIds = {};

  QuestionnaireState? validateSyncAndBuildPayload() {
    final containersAtClick = List<QuestionContainer>.of(shownQuestions);
    final renderKeysAtClick = List<GlobalKey>.of(questionKeys);
    final visibleBeforeCommit = _controller.visibleQuestions
        .map((question) => question.id)
        .toList(growable: false);

    // Commit all visible free-text drafts. The controller validates drafts
    // and returns the first validation error, or null if all are valid.
    final freeTextToSync = <FreeTextQuestion>[];
    for (int i = 0; i < containersAtClick.length; i++) {
      final container = containersAtClick[i];
      if (container.question is! FreeTextQuestion) continue;
      freeTextToSync.add(container.question as FreeTextQuestion);
    }

    if (freeTextToSync.isNotEmpty) {
      final error = _controller.commitFreeTextDraftsFor(freeTextToSync);
      if (error != null) {
        // Scroll to first actually invalid free-text question.
        for (int i = 0; i < containersAtClick.length; i++) {
          final container = containersAtClick[i];
          if (container.question is! FreeTextQuestion) continue;
          final ftQuestion = container.question as FreeTextQuestion;
          final draft = _controller.draftFor(ftQuestion.id);
          if (ftQuestion.validateResponse(draft) != null) {
            _scrollToQuestion(renderKeysAtClick[i]);
            return null;
          }
        }
        return null;
      }
    }

    final visibleAfterCommit = _controller.visibleQuestions;
    final visibleAfterCommitIds = visibleAfterCommit
        .map((question) => question.id)
        .toList(growable: false);

    // Applying a branch change is a progression step, not completion. Rebuild
    // first so newly required questions are rendered before another attempt.
    if (!listEquals(visibleBeforeCommit, visibleAfterCommitIds)) {
      setState(() => _rebuildShownQuestionsFromController());
      _controller.markRestoredVisibleAnswersNeedingReview(
        visibleBeforeCommit.toSet(),
      );
      _scrollToNewQuestion();
      return null;
    }

    final firstUnanswered = visibleAfterCommit.indexWhere(
      (question) => _controller.answerFor(question.id) == null,
    );
    if (firstUnanswered >= 0) {
      final questionId = visibleAfterCommit[firstUnanswered].id;
      final shownIndex = containersAtClick.indexWhere(
        (container) => container.question.id == questionId,
      );
      if (shownIndex >= 0) {
        _scrollToQuestion(renderKeysAtClick[shownIndex]);
      } else {
        setState(() => _rebuildShownQuestionsFromController());
        _scrollToNewQuestion();
      }
      return null;
    }

    if (_blockCompletionForReview(
      containers: containersAtClick,
      renderKeys: renderKeysAtClick,
    )) {
      return null;
    }

    return _controller.buildVisiblePayload();
  }

  bool _supportsInitialAnswerRestore(Question question) {
    // Only question widgets that can render an initial answer may restore
    // cached hidden answers into UI and questionnaire state.
    return question is BooleanQuestion ||
        question is ChoiceQuestion ||
        question is ScaleQuestion ||
        question is FreeTextQuestion ||
        question is DateQuestion ||
        question is AnnotatedScaleQuestion ||
        // todo remove this when older studies are finished
        question is VisualAnalogueQuestion;
  }

  Answer? _initialAnswerForQuestion(Question question) {
    if (!_supportsInitialAnswerRestore(question)) return null;

    if (question is FreeTextQuestion) {
      if (_controller.hasDraft(question.id)) {
        final draft = _controller.draftFor(question.id);
        return question.constructAnswer(draft);
      }
    }

    return _controller.answerFor(question.id);
  }

  bool _blockCompletionForReview({
    List<QuestionContainer>? containers,
    List<GlobalKey>? renderKeys,
  }) {
    final reviewQuestionId = _controller.firstVisibleAnswerNeedingReview();
    if (reviewQuestionId == null) return false;

    setState(() => _shownReviewErrors.add(reviewQuestionId));
    final reviewIndex = containers?.indexWhere(
      (container) => container.question.id == reviewQuestionId,
    );
    if (reviewIndex != null &&
        reviewIndex >= 0 &&
        renderKeys != null &&
        reviewIndex < renderKeys.length) {
      _scrollToQuestion(renderKeys[reviewIndex]);
    }
    return true;
  }

  void _finishQuestionnaireIfReviewed(QuestionnaireState payload) {
    if (_blockCompletionForReview()) {
      return;
    }
    _finishQuestionnaire(payload);
  }

  void _finishQuestionnaire(QuestionnaireState? result) {
    widget.onComplete?.call(result);
  }

  bool _autoCompleteIfReady() {
    if (!widget.autoComplete ||
        _controller.ctaModeFor(shownQuestions.map((c) => c.question)) !=
            QuestionnaireCtaMode.complete) {
      return false;
    }

    final payload = validateSyncAndBuildPayload();
    if (payload == null) return false;
    _finishQuestionnaire(payload);
    return true;
  }

  void _handleGlobalCtaPressed() {
    // Capture CTA mode before committing — a "Continue" press must never
    // submit; it only advances and reveals the next step.
    final modeBefore = _controller.ctaModeFor(
      shownQuestions.map((c) => c.question),
    );

    final payload = validateSyncAndBuildPayload();
    if (payload == null) return;

    final visibleBeforeRebuild = _controller.visibleQuestions
        .map((question) => question.id)
        .toSet();
    setState(() => _rebuildShownQuestionsFromController());
    _controller.markRestoredVisibleAnswersNeedingReview(visibleBeforeRebuild);

    if (modeBefore == QuestionnaireCtaMode.complete) {
      // Use the payload validated above rather than calling buildVisiblePayload()
      // a second time after setState, which can produce a different snapshot if
      // the rebuild changed which questions are visible.
      _finishQuestionnaireIfReviewed(payload);
    } else {
      _finishQuestionnaire(null);
      _scrollToNewQuestion();
    }
  }

  void _onQuestionCleared(String questionId) {
    _controller.removeAnswer(questionId);
    setState(() {
      _reviewedAnswerIds.remove(questionId);
      _rebuildShownQuestionsFromController(revealNext: false);
    });
    _finishQuestionnaire(null);
  }

  QuestionContainer _buildQuestionContainer({
    required Question question,
    required int index,
    required GlobalKey containerKey,
    bool isLastQuestion = false,
    GlobalKey<FreeTextQuestionWidgetState>? freeTextKey,
    Answer? initialAnswer,
    void Function(String questionId, String value)? onFreeTextDraftChanged,
  }) {
    return QuestionContainer(
      containerKey: containerKey,
      question: question,
      onDone: _onQuestionDone,
      onCleared: () => _onQuestionCleared(question.id),
      index: index,
      taskId: widget.taskId,
      initialAnswer: initialAnswer,
      onFreeTextDraftChanged: onFreeTextDraftChanged,
      freeTextKey: freeTextKey,
      isLastQuestion: isLastQuestion,
    );
  }

  /// Rebuilds [shownQuestions] and [questionKeys] from the controller's
  /// [progressiveVisibleQuestions]. Also cleans up answers for hidden questions
  /// whose type does not support initial answer restore.
  ///
  /// When [revealNext] is true (default), also includes the first
  /// visible unanswered question after the last progressive question,
  /// enabling normal progressive reveal.
  void _rebuildShownQuestionsFromController({bool revealNext = true}) {
    // Clean up answers for hidden unsupported question types so that
    // re-showing them does not auto-restore stale answers.
    final allVisible = _controller.visibleQuestions;
    for (final question in widget.questions) {
      if (!allVisible.any((q) => q.id == question.id)) {
        if (_controller.answerFor(question.id) != null &&
            !_supportsInitialAnswerRestore(question)) {
          _controller.removeAnswer(question.id);
        }
      }
    }

    shownQuestions.clear();
    questionKeys.clear();

    final progressive = _controller.progressiveVisibleQuestions;
    final questionsToShow = List<Question>.from(progressive);

    // If enabled, reveal the first visible unanswered question after
    // the last progressive question.
    if (revealNext) {
      final visible = _controller.visibleQuestions;
      final progressiveIds = progressive.map((q) => q.id).toSet();
      for (final q in visible) {
        if (!progressiveIds.contains(q.id)) {
          questionsToShow.add(q);
          break;
        }
      }
    }

    for (int i = 0; i < questionsToShow.length; i++) {
      final question = questionsToShow[i];
      final containerKey = _containerKeys.putIfAbsent(
        question.id,
        () => GlobalKey(debugLabel: 'container_${question.id}'),
      );
      final freeTextKey = question is FreeTextQuestion
          ? _freeTextKeys.putIfAbsent(
              question.id,
              () => GlobalKey<FreeTextQuestionWidgetState>(
                debugLabel: 'free_text_state_${question.id}',
              ),
            )
          : null;
      final initialAnswer = _initialAnswerForQuestion(question);
      final isLast = i == questionsToShow.length - 1;
      questionKeys.add(containerKey);
      shownQuestions.add(
        _buildQuestionContainer(
          containerKey: containerKey,
          question: question,
          index: i,
          isLastQuestion: isLast,
          initialAnswer: initialAnswer,
          onFreeTextDraftChanged: _controller.updateFreeTextDraft,
          freeTextKey: freeTextKey,
        ),
      );
    }
  }

  void _onQuestionDone(Answer answer, int _) {
    _reviewedAnswerIds.remove(answer.question);
    if (kDebugMode) {
      debugPrint(
        "QuestionnaireWidget: Answer received for question ${answer.question} - $answer",
      );
    }
    _controller.submitAnswer(answer);

    // Check shouldContinue before revealing new questions in the UI.
    // This prevents prematurely revealing questions that the continuation
    // predicate would stop.
    final shouldContinue = widget.shouldContinue?.call(
      _controller.buildVisiblePayload(),
    );

    if (shouldContinue == false) {
      setState(() => _rebuildShownQuestionsFromController(revealNext: false));
      _finishQuestionnaire(null);
      return;
    }

    final visibleBeforeRebuild = _controller.visibleQuestions
        .map((question) => question.id)
        .toSet();
    setState(() => _rebuildShownQuestionsFromController());
    _controller.markRestoredVisibleAnswersNeedingReview(visibleBeforeRebuild);

    if (_controller.allVisibleQuestionsAnswered) {
      if (_autoCompleteIfReady()) return;
    } else if (_controller.hasConditionalDependents(answer.question)) {
      _finishQuestionnaire(null);
    }
    _scrollToNewQuestion();
  }

  void _scrollToNewQuestion() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetIndex = _findNextInteractiveQuestionIndex();
      if (targetIndex < 0 || targetIndex >= questionKeys.length) return;
      final targetContext = questionKeys[targetIndex].currentContext;
      if (targetContext == null || !context.mounted) return;
      _isProgrammaticScroll = true;
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: 0.2,
      ).whenComplete(() => _isProgrammaticScroll = false);
    });
  }

  int _findNextInteractiveQuestionIndex() {
    for (int i = 0; i < shownQuestions.length; i++) {
      final questionId = shownQuestions[i].question.id;
      if (_controller.answerFor(questionId) == null) {
        return i;
      }
    }
    return shownQuestions.length - 1;
  }

  void _scrollToQuestion(GlobalKey targetKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = targetKey.currentContext;
      if (targetContext != null && context.mounted) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Add scroll listener to dismiss keyboard when scrolling
    _scrollController.addListener(_onScroll);

    _controller = QuestionnaireController(widget.questions);
    _controller.addListener(_onControllerChanged);

    if (widget.questions.isNotEmpty) {
      _rebuildShownQuestionsFromController(revealNext: false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _completeButtonFocusNode.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    // Defer to post-frame to avoid setState during the build phase
    // (e.g. when FreeTextQuestionWidget.initState restores an initial
    // answer and immediately calls onDraftChanged).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _onScroll() {
    if (!_isProgrammaticScroll && _scrollController.hasClients) {
      if (_scrollController.position.userScrollDirection !=
          ScrollDirection.idle) {
        FocusScope.of(context).unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctaMode = _controller.ctaModeFor(
      shownQuestions.map((c) => c.question),
    );
    final showCta =
        !widget.autoComplete &&
        !widget.hideCta &&
        ctaMode != QuestionnaireCtaMode.hidden;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: shownQuestions.length + (showCta ? 1 : 0),
            itemBuilder: (context, index) {
              if (showCta && index == shownQuestions.length) {
                return _buildCtaBar(ctaMode);
              }
              final question = shownQuestions[index];
              return Column(
                children: [
                  if (index == 0 &&
                      widget.header != null &&
                      widget.header!.isNotEmpty)
                    HtmlTextBox(widget.header),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        question,
                        if (_controller.needsReview(question.question.id))
                          _buildReviewRequiredNotice(question.question.id)
                        else if (_reviewedAnswerIds.contains(
                          question.question.id,
                        ))
                          _buildAnswerReviewedNotice(),
                      ],
                    ),
                  ),
                  if (index == shownQuestions.length - 1 &&
                      widget.footer != null &&
                      widget.footer!.isNotEmpty)
                    HtmlTextBox(widget.footer),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _markAnswerReviewed(String questionId) {
    _controller.markReviewed(questionId);
    setState(() {
      _shownReviewErrors.remove(questionId);
      _reviewedAnswerIds.add(questionId);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _controller.visibleAnswersNeedReview()) return;
      if (_autoCompleteIfReady()) return;
      if (_completeButtonFocusNode.context != null) {
        _completeButtonFocusNode.requestFocus();
      }
    });
  }

  Widget _buildReviewRequiredNotice(String questionId) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.restore_outlined, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.restored_answer_needs_review,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.restored_answer_review_description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                FilledButton.icon(
                  onPressed: () => _markAnswerReviewed(questionId),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.check),
                  label: Text(l10n.mark_answer_reviewed),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerReviewedNotice() {
    final l10n = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme.primary;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              l10n.answer_reviewed,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaBar(QuestionnaireCtaMode mode) {
    final l10n = AppLocalizations.of(context)!;
    final isContinue = mode == QuestionnaireCtaMode.continue_;
    final label = isContinue ? l10n.continue_label : l10n.complete_task;
    final backgroundColor = isContinue ? Colors.orange.shade700 : Colors.green;
    final isSubmitting = widget.isSubmitting;
    final needsReview = !isContinue && _controller.visibleAnswersNeedReview();
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            icon: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(isContinue ? Icons.arrow_forward : Icons.check),
            label: Text(label),
            focusNode: isContinue ? null : _completeButtonFocusNode,
            onPressed: isSubmitting || needsReview
                ? null
                : _handleGlobalCtaPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: colorScheme.onSurface.withValues(
                alpha: 0.12,
              ),
              disabledForegroundColor: colorScheme.onSurface.withValues(
                alpha: 0.38,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          if (needsReview) ...[
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.review_restored_answer_to_continue,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class const HtmlTextBox(final String? text, {super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [HtmlText(text)],
        ),
      ),
    );
  }
}

## 2.15.0

 - **REFACTOR**: Rename wordlist constants and export recovery utilities from the core package.
 - **REFACTOR**(app): keep legal consent visible.
 - **REFACTOR**(app): move onboarding debug control.
 - **REFACTOR**(app): unify study onboarding descriptions.
 - **REFACTOR**(app): unify study onboarding navigation.
 - **REFACTOR**(app): remove recovery phrase purpose messages from localization files.
 - **REFACTOR**(app): simplify onboarding layouts.
 - **REFACTOR**(app): simplify questionnaire flow.
 - **REFACTOR**: simplify onboarding button logic and remove unused localization strings for study switch.
 - **REFACTOR**: Optimize widget instantiation and clean up imports in recovery flow tests.
 - **REFACTOR**: simplify builder syntax for deep link invite route.
 - **REFACTOR**: centralize study fetching logic by moving `fetchById` and `fetchByInviteCode` methods to the `Study` model.
 - **REFACTOR**: centralize invite code fetching in DeepLinkService.
 - **REFACTOR**(deep-link): apply Copilot review suggestions.
 - **REFACTOR**: use RoutePaths constant for eligibility check route.
 - **REFACTOR**: Improve formatting of button labels in recovery phrase widget for better readability.
 - **REFACTOR**: Update import paths for recovery QR utilities and enhance UI theming in QR code scanner and settings screens.
 - **REFACTOR**: Update `share_plus` API usage, simplify QR scanner camera setup and color opacity, and streamline menu positioning.
 - **FIX**(app): clear multi-choice answers consistently.
 - **FIX**(app): group onboarding content.
 - **FIX**(app): localize recovery word count.
 - **FIX**(app): center onboarding content.
 - **FIX**(l10n): preserve German resource entries.
 - **FIX**(deep-links): separate web and app links.
 - **FIX**: clear CI analysis failures.
 - **FIX**(app): connect eligibility banner to nav.
 - **FIX**(app): restore study tile Hero transition.
 - **FIX**(app): center titles and toggle labels.
 - **FIX**(app): refine invite code action.
 - **FIX**(app): close why dialogs.
 - **FIX**(app): align legal content spacing.
 - **FIX**(app): refine study page hierarchy.
 - **FIX**(app): correct onboarding back navigation.
 - **FIX**(app): gate dashboard tour replay.
 - **FIX**(app): redirect study exit to welcome.
 - **FIX**(app): fix exit dialog layout and transitions.
 - **FIX**(app): refine study start state.
 - **FIX**(app): align onboarding navigation.
 - **FIX**(app): stop eligibility banner flicker.
 - **FIX**(app): clarify study start copy.
 - **FIX**(app): refine onboarding presentation.
 - **FIX**(app): keep onboarding navigation current.
 - **FIX**(app): refine onboarding copy and spacing.
 - **FIX**(app): clarify welcome action hierarchy.
 - **FIX**(app): guard onboarding route progression.
 - **FIX**(app): refine onboarding flow.
 - **FIX**(app): align onboarding progress.
 - **FIX**(app): remove kickoff screen flicker.
 - **FIX**(app): tighten journey timeline spacing.
 - **FIX**(app): align journey onboarding layout.
 - **FIX**(app): align destructive action colors.
 - **FIX**(app): route support email to study team.
 - **FIX**(app): simplify study information.
 - **FIX**(app): streamline debug onboarding.
 - **FIX**(app): clear declined consent state.
 - **FIX**(app): align onboarding layouts.
 - **FIX**(app): harden participant navigation.
 - **FIX**(app): show recovery before dashboard.
 - **FIX**(app): handle dismissed notifications.
 - **FIX**(recovery): keep recovery phrases stable.
 - **FIX**(recovery): make account recovery retry-safe and revoke old sessions.
 - **FIX**: address review feedback.
 - **FIX**(app): restrict preview Firebase origins.
 - **FIX**(app): reject explicit preview ports.
 - **FIX**(app): validate preview origins exactly.
 - **FIX**(app): localize deep-link warning instruction.
 - **FIX**(app): reject lookalike firebase project ids for preview origin.
 - **FIX**(app): restrict preview designer origin to trusted hosts.
 - **FIX**(designer): restore referrer-first origin for preview messaging.
 - **FIX**(app): resolve blocking review findings.
 - **FIX**(app): allow recovery phrase retry.
 - **FIX**(app): propagate recovery lookup errors.
 - **FIX**(app): initialize internal browser routes.
 - **FIX**(app): preserve latest preview study during startup.
 - **FIX**(designer): transmit preview studies outside urls.
 - **FIX**(app): remove study list invite action.
 - **FIX**(app): stabilize study tile hero.
 - **FIX**(app): align study overview hero bounds.
 - **FIX**(designer): preserve legacy free-text conditions.
 - **FIX**(deps): bump deps.
 - **FIX**(app): clear required choice answers.
 - **FIX**(app): allow clearing required choice answers.
 - **FIX**(app): guard unavailable study router lookup.
 - **FIX**(app): restore unavailable study back navigation.
 - **FIX**(app): hide unavailable study back fallback.
 - **FIX**(app): block unavailable studies from participant flows.
 - **FIX**(app): handle unknown eligibility criteria.
 - **FIX**(core): correct choice visibility evaluation.
 - **FIX**(app): improve disabled choice button contrast.
 - **FIX**(app): refine legal onboarding experience.
 - **FIX**(app): focus invite code input.
 - **FIX**(app): reuse invite code action on study selection.
 - **FIX**(app): improve invite code label.
 - **FIX**(app): make onboarding back navigation consistent.
 - **FIX**(app): keep study onboarding steps in order.
 - **FIX**(app): preserve onboarding back stack.
 - **FIX**(l10n): complete Korean localization.
 - **FIX**(app): align public study description spacing.
 - **FIX**(app): make invite code field copyable.
 - **FIX**(app): balance invite code and QR options.
 - **FIX**(db): rotate account recovery credentials.
 - **FIX**(designer): secure participant study previews.
 - **FIX**(app): remember terms acceptance during onboarding.
 - **FIX**(app): isolate preview scroll state.
 - **FIX**(app): guard invite lookup lifecycle.
 - **FIX**(app): replace invite dialog during navigation.
 - **FIX**(app): keep invite dialog mounted during lookup.
 - **FIX**(app): hide recovery success banners in dialog.
 - **FIX**(app): assess eligibility after final answer.
 - **FIX**(app): update review prompts and button labels in questionnaire.
 - **FIX**(designer): support free-text length conditions.
 - **FIX**(app): disable completion while answers need review.
 - **FIX**(app): reevaluate questionnaire after free-text edits.
 - **FIX**(app): prevent study tile overflow.
 - **FIX**(deps): update Podfile.lock checksum.
 - **FIX**(app): preserve onboarding back stack.
 - **FIX**(app): update terms and privacy content to remove contact information.
 - **FIX**(app): return from intervention to eligibility.
 - **FIX**(app): avoid null study during eligibility exit.
 - **FIX**(app): preserve cold start deep links.
 - **FIX**(app): keep deep link navigation unblocked.
 - **FIX**(app): return to study selection from overview.
 - **FIX**(app): clear abandoned invite flows.
 - **FIX**(app): keep onboarding completion forward.
 - **FIX**(app): remove debug prefix from onboarding button.
 - **FIX**(app): skip onboarding in debug and preview.
 - **FIX**(designer): stream live study updates to preview.
 - **FIX**(app): stop eligibility flow on failed answer.
 - **FIX**(app): restore eligibility gating.
 - **FIX**(app): resolve dev merge conflicts.
 - **FIX**(app): show dashboard tour after study starts.
 - **FIX**(app): clarify active study invite switch.
 - **FIX**(app): repair invite onboarding routing.
 - **FIX**(app): persist pending deep links.
 - **FIX**(app): show recovery phrase after dashboard opens.
 - **FIX**: re-design app language picker.
 - **FIX**(app): prevent recovery phrase cache leaks.
 - **FIX**(app): rename rejoin account route to restore account and update related references.
 - **FIX**(app): rename recovery account route.
 - **FIX**(app): improve account recovery flow.
 - **FIX**(app): preserve malformed invite URLs.
 - **FIX**(designer): preserve free text conditional semantics.
 - **FIX**(app,core,db): address code review findings from dev merge.
 - **FIX**(app): update deep link routes from studyShared to study.
 - **FIX**(app): reuse onboarding participant.
 - **FIX**: address code review findings across app, core, and designer.
 - **FIX**(app): keep about out of terms back stack.
 - **FIX**(app): allow terms back navigation.
 - **FIX**(app): show welcome after completed tour.
 - **FIX**(app): guard iframe preview posts.
 - **FIX**: add passkeys script to index.html for app & designer to support supabase_flutter v2.15.0.
 - **FIX**(app): make recovery reset visible.
 - **FIX**(app): clarify dashboard tour actions.
 - **FIX**(app): preserve draft review context.
 - **FIX**(app): fix app initialization.
 - **FIX**(app): repair german showcase localization.
 - **FIX**(app): repair dashboard showcase replay.
 - **FIX**(app): handle nullable iframe referrer.
 - **FIX**(app): restore done button after editing free text.
 - **FIX**(app): remove done buttons from slider questions.
 - **FIX**(app): remove Done button for non-last free text, clean up unused code.
 - **FIX**(app): review lower restored answers.
 - **FIX**(app): require review for restored answers.
 - **FIX**(app): keep local data for deleted studies.
 - **FIX**(app): prevent dashboard reload crash.
 - **FIX**(app): register dashboard showcase consistently.
 - **FIX**(app): resolve questionnaire controller merge conflicts.
 - **FIX**(app): apply dart fix and replace deprecated mdi store icons with material icons.
 - **FIX**: migrate remaining material_design_icons_flutter imports to flutter_material_design_icons.
 - **FIX**: remove deprecated material_design_icons_flutter dependency.
 - **FIX**: address pr review items - study shared link path, web landing page study link, ios deferred link host.
 - **FIX**(app): continue button advances only, add free-text placeholder hint.
 - **FIX**(app): unify questionnaire cta into single button, fix validation and caching bugs.
 - **FIX**(app): preserve questionnaire cta cache.
 - **FIX**(app): normalize welcome locale.
 - **FIX**: ensure correct subject and studyId are returned by validating activeSubject and cache against activeSubjectId.
 - **FIX**: use pushNamed for terms route when handling pending deep link to preserve navigation stack.
 - **FIX**: migrate Riverpod analyzer plugin.
 - **FIX**: allow public study reads for open studies. Adjust RLS policy to allow anon role to read open studies for onboarding via deep links.
 - **FIX**: update download app join message to specify StudyU App in localization files.
 - **FIX**: update web deep link handling to support both invite codes and study IDs.
 - **FIX**: update deep link handling to prioritize invite codes and adjust pending link storage.
 - **FIX**: update invite code RPC permissions for anonymous access.
 - **FIX**: Handle deleted study subject gracefully with localized error messages.
 - **FIX**: onboarding translation issues.
 - **FIX**(deps): update flutter and deps.
 - **FIX**(l10n): merge dev and correct Korean copy.
 - **FIX**(ci): resolve invite flow checks.
 - **FIX**: Correctly instantiate RecoveryPhraseWidget with const for performance optimization.
 - **FIX**: Update exception handling in rejoin study service and improve recovery flow tests.
 - **FIX**(deep-link): handle custom URL scheme in GoRouter.
 - **FIX**: remove obsolete analyzer plugins.
 - **FIX**(app): fix deep linking native splash overlay and dev environment support.
 - **FIX**: address Copilot review comments for deep link feature.
 - **FIX**: Remove integration_test dependency from dev_dependencies in pubspec.yaml.
 - **FIX**: resolve analysis and web build failures.
 - **FIX**: onboarding screen new route.
 - **FIX**: Update LoadingScreen query parameters to use state.uri for improved navigation.
 - **FIX**: Ensure mounted state check in InviteCodeDialog and handle errors in deep link processing.
 - **FIX**: address localization review feedback.
 - **FIX**(app): clarify invite instructions.
 - **FIX**(app): restore bottom onboarding back arrows using go_router.
 - **FIX**(app): allow isolated welcome rendering.
 - **FIX**: error screen email did not work.
 - **FIX**(router): add root route to handle '/' path.
 - **FIX**: update loading screen routing for onboarding completion.
 - **FEAT**: user can view onboarding again in about screen.
 - **FEAT**: fix startup flow structure and warn user if deeplink opened and already in study.
 - **FEAT**: refactor deep link generation for invite codes.
 - **FEAT**: improve deep link study switch UX with confirmation dialogs and clearer data choice options.
 - **FEAT**(app): add dashboard showcase tour.
 - **FEAT**: Introduce recovery phrase and rejoin study features with new onboarding screens, core utilities, and localization.
 - **FEAT**: Add initial internationalization support with German and English localization files.
 - **FEAT**: Update deep link handling and environment configuration for Android and iOS.
 - **FEAT**: implement account recovery and study rejoining functionality with a new service and backend migration.
 - **FEAT**(app): add study information and participation controls.
 - **FEAT**: Upgrade recovery phrase system to 128-bit IDs, updating encoding logic and UI to support 13 words.
 - **FEAT**: Enhance recovery flow with validation, constants, and integration tests.
 - **FEAT**: enhance deep link processing and add error handling for missing parameters.
 - **FEAT**(app): support required choice selections.
 - **FEAT**: add deep link handling for study invites.
 - **FEAT**(app): improve onboarding entry choices.
 - **FEAT**(app): add onboarding widget previews.
 - **FEAT**: Refactor route path constants to route name constants and update navigation throughout the app.
 - **FEAT**(app): defer terms until study review.
 - **FEAT**(app): simplify study entry choices.
 - **FEAT**(app): add public studies app bar.
 - **FEAT**(app): add recovery phrase rotation.
 - **FEAT**(recruit): improve invite sharing.
 - **FEAT**(app): link invite entry from study list.
 - **FEAT**: Implement deep link handling for studies and invite codes with a new service, routing, and UI.
 - **FEAT**(app): add korean localization.
 - **FEAT**: Implement secure account recovery with a dedicated recovery ID and refactor phrase display into a new widget.
 - **FEAT**: Migrate navigation to GoRouter and update route handling across multiple screens.
 - **FEAT**: Implement navigation improvements in settings and study selection screens.
 - **FEAT**: Enhance loading screen behavior and improve router configuration.
 - **FEAT**(localization): synchronize app language with server and improve locale handling.
 - **FEAT**: Update recovery phrase save hint for improved clarity in English and German localizations.
 - **FEAT**(app): unify recovery phrase guidance.
 - **FEAT**: Add localized strings for general settings, current study, participation options, and recovery actions in English and German.
 - **FEAT**(app): add welcome language picker.
 - **FEAT**: Implement deep linking for Android and iOS, and update unknown route handling to a loading screen.
 - **FEAT**(app): add invite QR flow.
 - **FEAT**: Add QR code support for recovery phrase management, enabling scanning, sharing, and downloading options.
 - **FEAT**(app): animate invite code dialog.
 - **FEAT**: enhance rejoin study screen with a single recovery phrase input field and comprehensive help instructions.
 - **FEAT**(app): submit invite code with enter.
 - **DOCS**(app): explain pushReplacementNamed in invite navigation.
 - **DOCS**(app): condense study guidance in onboarding.

## 2.14.0

 - **REFACTOR**: clean up date question localization and validation messages.
 - **FIX**(app): disable back without route history.
 - **FIX**(app): open preview on study overview.
 - **FIX**(app): restore date question answers.
 - **FIX**: upgrade deps.
 - **FIX**: upgrade deps.
 - **FIX**: replace deprecated mdi store icons with material icons.
 - **FIX**: remove deprecated material_design_icons_flutter dependency.
 - **FIX**(app): clarify study selection banner message.
 - **FIX**(preview): avoid reloading test app page navigation.
 - **FIX**(preview): skip app onboarding in designer preview.
 - **FEAT**(designer): localize hardcoded preview overlay strings.
 - **FEAT**: Add onCleared callback to DateQuestionWidget and QuestionContainer.
 - **FEAT**: Enhance Date Question Functionality with Time Input and Localization.
 - **FEAT**: remove initial date handling from date question components.
 - **FEAT**: add date picker localization strings in German.
 - **FEAT**: add DateQuestion and DateQuestionWidget for date selection in questionnaires.

## 2.13.0

 - **REFACTOR**(questionnaire): improve free text question handling and remove custom error message support.
 - **REFACTOR**: removed unused shared preferences.
 - **FIX**: upgrade deps.
 - **FIX**(app): gate free text submit to active question.
 - **FIX**(app): restore free text validation invalidation/re-completion and fix custom regex length skip.
 - **FIX**: update free text validation messages and regex handling.
 - **FIX**: align dependencies for Flutter 3.44.
 - **FIX**: add missing const constructors to satisfy linter.
 - **FIX**: replace deprecated MdiIcons with Flutter's built-in Icons for store links.
 - **FIX**: migrate to flutter_material_design_icons in favor of deprecated material_design_icons_flutter.
 - **FIX**: upgrade deps.
 - **FIX**: adjust iOS project configurations.
 - **FIX**: migrate flutter_secure_storage v10.0.0.
 - **FIX**: Update onboarding subtitles for clarity and fix image paths.
 - **FIX**: hide back button on terms screen.
 - **FEAT**(app): cache hidden questionnaire answers, restore UI, validate complete.
 - **FEAT**: Add custom error message support for free text questions.
 - **FEAT**: add validation handling for free text questions.
 - **FEAT**(test): add stable ValueKeys for MCP automation.
 - **FEAT**: Make onboarding screen shorter.
 - **FEAT**: Revamp onboarding screen content and structure for improved user guidance.
 - **FEAT**: add custom_lint dependency for improved code quality checks".
 - **FEAT**: update custom_lint and add riverpod_lint for enhanced code quality".
 - **FEAT**: update custom_lint and add riverpod_lint for enhanced code quality.
 - **FEAT**: add custom_lint dependency for improved code quality checks.
 - **FEAT**: enhance onboarding flow by redirecting users based on onboarding status.
 - **FEAT**: replace onboarding skip button with a back button.
 - **FEAT**: Implement new app onboarding flow with dedicated screen and assets, and refine study schedule localization.

## 2.12.5

 - **FIX**: migrate flutter_local_notifications.
 - **FIX**: update to flutter v3.41.5.
 - **FIX**: upgrade to flutter v3.38.4.

## 2.12.4

 - **FIX**: fix caching.
 - **FIX**(designer_v2): update code for Riverpod 3.x compatibility.
 - **FIX**: null check for study invite.
 - **FIX**(database): revoke unnecessary EXECUTE privileges and update function access policies.
 - **FIX**: study length calculation and update localization for study schedule.
 - **FIX**(app): offline mode was not working.
 - **FIX**: offline mode was not working.

## 2.12.3

 - **FIX**: fix caching.
 - **FIX**(designer_v2): update code for Riverpod 3.x compatibility.
 - **FIX**: null check for study invite.
 - **FIX**(database): revoke unnecessary EXECUTE privileges and update function access policies.
 - **FIX**: study length calculation and update localization for study schedule.
 - **FIX**(app): offline mode was not working.

## 2.12.2

 - **FIX**(app): offline mode was not working.
 - **FIX**: migrate FlutterTimezone.

## 2.12.1

 - **FIX**: app starting issues due to storage reading.

## 2.12.0

 - **REFACTOR**: refine free text question widget to improve submission handling on focus loss.
 - **FIX**: improve scrolling behavior in questionnaire widget if questions were out of screen.
 - **FIX**: improve handling of conditional question dependencies in questionnaire widget.
 - **FIX**: improve free text question widget to handle auto-submit on focus loss.
 - **FIX**: enhance choice question widget to support auto-submit on confirm button touch.
 - **FIX**: handle conditional dependencies for earlier question modifications in questionnaire widget.
 - **FIX**: improve free text question widget by refining keyboard dismissal logic during user scroll.
 - **FEAT**: implement auto-submit on focus loss for free text question widget.
 - **FEAT**: improve free text question widget by removing unnecessary scroll controller and enhancing keyboard dismissal on user scroll.
 - **FEAT**: center text field in viewport for improved layout.
 - **FEAT**: improve free text question widget with debounced validation and autovalidation.
 - **FEAT**: enhance free text question widget with improved keyboard handling and validation.

## 2.11.1

 - **FIX**: improve validation logic for free text input handling with minimum length checks.
 - **FIX**: add submit button and update localization for free text question widget.
 - **FIX**: add skip button text for free text question widget.
 - **FIX**: improve free text question interaction and validation handling.
 - **FIX**: implement smooth scrolling to newly added questions in questionnaire.
 - **FIX**(app): disable color change of appbar on dashboard scrolling.

## 2.11.0

 - **FIX**: add preview mode active/inactive state messages.
 - **FIX**: replace GestureDetector with InkWell for application icon in about dialog.
 - **FIX**: improve question insertion and scrolling behavior in questionnaire.
 - **FIX**: invalidate existing result on continuation check to update eligibility banner.
 - **FIX**: suppress mouse tracker assertion error on web platform.
 - **FEAT**: add preview mode functionality for app and localization support.
 - **FEAT**: add debug mode functionality for study progression".
 - **FEAT**: add debug mode functionality for study progression.

## 2.10.2

 - **FIX**: same conditional question was inserted on answer change.
 - **FIX**: last conditional question did not finish.
 - **FIX**: choice button support multiline now.

## 2.10.1

 - **FIX**: disabled eligibility check free text hotfix.

## 2.10.0

 - **REFACTOR**: rename core FitbitCredentials to FitbitAuthCredentials.
 - **REFACTOR**: improve code formatting and readability in body-related files.
 - **REFACTOR**: add localization support for Fitbit data sync messages and improve code formatting.
 - **REFACTOR**: improve code formatting and readability in localization and conditional question files.
 - **REFACTOR**: cleanup.
 - **REFACTOR**(fitbit): sleep data fetching logic.
 - **FIX**: uncomment platform definition in Podfile.
 - **FIX**: regenerate ios and android folders.
 - **FIX**: update app deps.
 - **FIX**: replace translate and scale methods with their double counterparts in body_part_selector.dart.
 - **FIX**: passing taskId to fitbit_question_widget.dart.
 - **FIX**: update Fitbit integration and callback URLs.
 - **FIX**: uncomment iOS deployment target configuration in Podfile.
 - **FIX**: update Flutter version to 3.35.2 and add l10n-missing.txt file.
 - **FIX**: upgrade package dependencies.
 - **FIX**: update dependencies and versions in pubspec.yaml and pubspec.lock.
 - **FIX**: remove unnecessary pain level text display in PainEditDialog.
 - **FIX**: update PRODUCT_BUNDLE_IDENTIFIER for Fitbit app.
 - **FIX**: proper onDone handling for fitbit_question_widget.dart.
 - **FIX**: regenerate ios and android folders.
 - **FIX**: improve error messages and user guidance in loading screen.
 - **FIX**: show dialog after email sending.
 - **FIX**: show dialog after email sending.
 - **FIX**: improve error handling and user support options in loading screen.
 - **FIX**: questionnaire screen refactor.
 - **FIX**: update Flutter SDK version to 3.35.3 and dependencies in pubspec.lock.
 - **FIX**: localization.
 - **FIX**: prevent duplicate questions.
 - **FIX**: scales without annotations are displayed now.
 - **FIX**: update deps.
 - **FIX**: only show complete button if all shown questions are answered.
 - **FIX**: translate reports not found.
 - **FIX**: broken question animation.
 - **FIX**: later conditional questions not shown.
 - **FIX**: add null answer if there is no default answer.
 - **FIX**: maybe fix reports bug.
 - **FIX**: ios and android configuration.
 - **FIX**: android config.
 - **FIX**: auto formatting of localization files.
 - **FIX**: body part ids & german translations for body parts.
 - **FIX**: default for app deployment flutter variables.
 - **FIX**: default for app deployment flutter variables 2.
 - **FIX**: do not store null answers.
 - **FEAT**: add pain selection question and body part selection widgets.
 - **FEAT**: web configuration for fitbitter package.
 - **FEAT**: make fitbit syncing process more transparent.
 - **FEAT**: implement pain selection question inside designer.
 - **FEAT**: add pain type and body part children support.
 - **FEAT**: pain type model.
 - **FEAT**: add FitbitHandler.
 - **FEAT**: make body pain type and part selection optional.
 - **FEAT**: re-create android and ios folders gemfile"".
 - **FEAT**: initialize pain type selection in body part selector.
 - **FEAT**: re-create android and ios folders gemfile".
 - **FEAT**: re-create android and ios folders gemfile.
 - **FEAT**: re-create android and ios folders.
 - **FEAT**: refactor pain selection dialog to use PainType model.
 - **FEAT**: update Fitbit credentials form and related dependencies.
 - **FEAT**: enhance Fitbit credential handling to include permission scopes.
 - **FEAT**: update Fitbit redirect URL and callback scheme.
 - **FEAT**: fetching remote subject with Fitbit credentials on onboarding.
 - **FEAT**: update Fitbit credentials form and AndroidManifest of app.
 - **FEAT**: fitbit_credentials table and integration.
 - **FEAT**: Add Fitbit credential deletion on study removal.
 - **FEAT**(fitbit): refactor _findLatestDataEntry function in fitbit_handler.dart.
 - **FEAT**: change dialog sequence of pain tracking.
 - **FEAT**: update Fitbit data handling and syncing process.
 - **FEAT**: add validation for Fitbit credentials in forms.
 - **FEAT**: add sleep data fetching.
 - **FEAT**: rename WongBakerScale to PainScale for consistency.
 - **FEAT**(fitbit): update sleep data model and sleep fetch.
 - **FEAT**: integrate Pods project and add localization for Fitbit questions.
 - **FEAT**: sync Fitbit data on button press.
 - **FEAT**: update Info.plist for localization and app permissions.
 - **FEAT**: update pain type in body pain and selector.

## 2.9.1

- **FIX**: update deps.

## 2.9.0

- **REFACTOR**: remove print.
- **FIX**: bump dependencies.
- **FIX**: update selectedStudyObjectId to null on study deletion.
- **FIX**: study reset process by removing unnecessary user ID handling.
- **FIX**: reset subject temp fix.
- **FIX**: reset subject progress.
- **FEAT**: enhance study reset functionality to support user-specific data deletion.

## 2.8.0

- **REFACTOR**: TextualSummarySectionWidget.
- **REFACTOR**: print remove dead code.
- **FIX**: textual summary widget width.
- **FIX**: upgrade deps.
- **FIX**: getTemporaryDirectory no longer throws error for web.
- **FIX**: double confirmation of data deletion and reload action + translations.
- **FIX**: handle secure storage errors with user prompt.
- **FIX**: improve notification task error messages.
- **FIX**: ios deployment.
- **FIX**: only main deployment and github deployment depends on core + flutter_common packages.
- **FIX**: android deployment bump desugar_jdk_libs.
- **FIX**: add core and flutter_common local path dependency.
- **FIX**: add string_extensions.dart.
- **FIX**: colorless gauge translations.
- **FIX**: translation.
- **FIX**: upgrade deps.
- **FIX**: current intervention text split.
- **FIX**: deprecated withOpacity.
- **FIX**: create fallback dir if _getMultimodalTempDirectory fails.
- **FIX**: remove placeholder file creation.
- **FIX**: handle errors during app reset process.
- **FIX**: handle null cases for staging audio and image files & handle temp directory fail.
- **FIX**: migrate code.
- **FIX**: localization.
- **FIX**: improve baseline name handling in average section widget localization.
- **FIX**: update average section widget for better title handling and improve pubspec.lock dependencies.
- **FIX**: default for app deployment flutter variables 2.
- **FIX**: default for app deployment flutter variables.
- **FIX**: auto formatting of localization files.
- **FIX**: android config.
- **FIX**: ios and android configuration.
- **FEAT**(designer): reset feature on test mode now resets all subject data that belongs to the editor.
- **FEAT**: re-create android and ios folders gemfile".
- **FEAT**: re-create android and ios folders gemfile.
- **FEAT**: re-create android and ios folders.
- **FEAT**: implement textual summary section with data processing and UI integration.
- **FEAT**: add gauge comparison section with loading state and colorless gauge option.
- **FEAT**: enhance textual summary with localized messages for intervention comparisons.
- **FEAT**(designer): reset feature on test mode now resets all subject data that belongs to the editor.".
- **FEAT**: invert colorless gauge display logic in gauge comparison section.
- **FEAT**: descriptive stats section widget for app.
- **FEAT**: refactor statistical widgets and implement synchronous t-test results.
- **FEAT**: report overview.
- **FEAT**: report overview.
- **FEAT**: add splash screen for app.
- **FEAT**: re-create android and ios folders gemfile"".

## 2.8.0-dev.0

 - **REFACTOR**: rename core FitbitCredentials to FitbitAuthCredentials.
 - **REFACTOR**(fitbit): sleep data fetching logic.
 - **FIX**: default for app deployment flutter variables 2.
 - **FIX**: default for app deployment flutter variables.
 - **FIX**: auto formatting of localization files.
 - **FIX**: android config.
 - **FIX**: ios and android configuration.
 - **FIX**: localization.
 - **FIX**: proper onDone handling for fitbit_question_widget.dart.
 - **FIX**: update Fitbit integration and callback URLs.
 - **FIX**: passing taskId to fitbit_question_widget.dart.
 - **FIX**: current intervention text split.
 - **FEAT**: re-create android and ios folders gemfile"".
 - **FEAT**: re-create android and ios folders gemfile".
 - **FEAT**: re-create android and ios folders gemfile.
 - **FEAT**: re-create android and ios folders.
 - **FEAT**: update Fitbit credentials form and related dependencies.
 - **FEAT**: enhance Fitbit credential handling to include permission scopes.
 - **FEAT**: update Fitbit redirect URL and callback scheme.
 - **FEAT**: fetching remote subject with Fitbit credentials on onboarding.
 - **FEAT**: update Fitbit credentials form and AndroidManifest of app.
 - **FEAT**: fitbit_credentials table and integration.
 - **FEAT**: Add Fitbit credential deletion on study removal.
 - **FEAT**(fitbit): refactor _findLatestDataEntry function in fitbit_handler.dart.
 - **FEAT**: update Fitbit data handling and syncing process.
 - **FEAT**: add validation for Fitbit credentials in forms.
 - **FEAT**: add sleep data fetching.
 - **FEAT**(fitbit): update sleep data model and sleep fetch.
 - **FEAT**: sync Fitbit data on button press.
 - **FEAT**: add FitbitHandler.
 - **FEAT**: report overview.
 - **FEAT**: report overview.

## 2.7.14

 - **FIX**: linter.

## 2.7.13

 - **FIX**: migrate code.
 - **FIX**: upgrade deps and flutter v3.24.5.

## 2.7.12

 - **FIX**: notification icon mipmap 2.
 - **FIX**: notification icon mipmap.
 - **FIX**: configure AndroidNotificationDetails correctly.
 - **FIX**: disable R8 full mode for flutter_local_notifications.

## 2.7.11

 - **FIX**: upgrade deps.
 - **FIX**: notification scheduling.
 - **FIX**: upgrade fvm to flutter v3.24.3.
 - **FIX**: prompt user to restart after reset.
 - **FIX**: debug screen.

## 2.7.10

 - **FIX**: schedule notifications for 7 days.
 - **FIX**: refactor notification cancelling and add missing translations.
 - **FIX**: upgrade to flutter v3.24.2.
 - **FIX**: maybe prevent blank screen in notification debug view.

## 2.7.9

 - **FIX**: upgrade deps.

## 2.7.8

 - **FIX**: safety check.
 - **FIX**: outdated cached subject.
 - **FIX**: upgrade deps.

## 2.7.7

 - **FIX**: upgrade deps.
 - **FIX**: upgrade deps.

## 2.7.6

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 2.7.6-dev.3

 - **REFACTOR**: migrate to riverpod code generation 2.
 - **FIX**: app preview stuck at AppLanguage.
 - **FIX**: formatting issues.
 - **FIX**: formatting issues.
 - **FIX**: users not able to continue closed study.
 - **FIX**(app): update ios deployment.
 - **FIX**(app): update android deployment.
 - **FIX**: upgrade deps.
 - **FEAT**: deprecate published for study_status.
 - **FEAT**: close study using is_closed column.
 - **FEAT**: close study.

## 2.7.6-dev.2

 - **FIX**: formatting issues.
 - **FIX**(app): update ios deployment.
 - **FIX**(app): update android deployment.
 - **FIX**: upgrade deps.
 - **FIX**(app): update ios deployment.
 - **FIX**(app): update android deployment.
 - **FIX**(app): update android deployment.
 - **FIX**(app): update ios deployment.
 - **FIX**(app): update android deployment.

## 2.7.6-dev.1

 - **FIX**(app): update android deployment.
 - **FIX**(app): update ios deployment.
 - **FIX**(app): update android deployment.

## 2.7.6-dev.0

 - **FIX**: upgrade deps.
 - **FIX**: UI overflows.

## 2.7.5

 - **FIX**: update podfile.

## 2.7.4

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 2.7.4-dev.1

 - Update a dependency to the latest release.

## 2.7.4-dev.0

 - **FIX**: upgrade deps and migrate.

## 2.7.3

 - **FIX**: skip handling multimodal for web. ([27ba5298](https://github.com/hpi-studyu/studyu/commit/27ba5298a1b714e1cc7e21a6d88c286f91e2907a))

## 2.7.2

 - Update a dependency to the latest release.

## 2.7.1

 - **FIX**: add NSCameraUsageDescription. ([bfdd5a9e](https://github.com/hpi-studyu/studyu/commit/bfdd5a9ea795b83152d8ccdd02dec8e0d30b2e7f))

## 2.7.0

 - **REFACTOR**: move blob_storage_handler.dart and add download feature. ([9546e7d0](https://github.com/hpi-studyu/studyu/commit/9546e7d094286f28933fab5b7a50b7048b48215e))
 - **REFACTOR**: remove flex. ([6509e85d](https://github.com/hpi-studyu/studyu/commit/6509e85d34971da725dccae7239e5fa17f1fde45))
 - **REFACTOR**(app): move flex to QuestionnaireTaskWidget. ([1a12ece1](https://github.com/hpi-studyu/studyu/commit/1a12ece137fc2cf2bbc1dae2a9ab2e83a20b2064))
 - **REFACTOR**: late vars. ([f0b6a15e](https://github.com/hpi-studyu/studyu/commit/f0b6a15e661185c7ab1c50c65ed50006ca2dd1a8))
 - **REFACTOR**: remove capture_question_widget. ([50ee289c](https://github.com/hpi-studyu/studyu/commit/50ee289cd1aaad21e348a0257db20e4f2c5cb38d))
 - **REFACTOR**: audio and picture screen. ([61dba8ed](https://github.com/hpi-studyu/studyu/commit/61dba8ed4a624b9408cf6e85c0acedce48ab8b34))
 - **REFACTOR**: make multimodal stateful widgets private. ([c2bf84f7](https://github.com/hpi-studyu/studyu/commit/c2bf84f79484038dab64b6e5f6e45e66bdc7ec0a))
 - **FIX**: rework of capture_picture_screen. ([61bac286](https://github.com/hpi-studyu/studyu/commit/61bac286887b15e1d7af33e97a942811ed1e583c))
 - **FIX**: do not upload image directly. ([9414afcb](https://github.com/hpi-studyu/studyu/commit/9414afcb899e40ab1e72436dfaba337d8052bb64))
 - **FIX**: style of photo capture button. ([7ec85382](https://github.com/hpi-studyu/studyu/commit/7ec853828a51e7aa454563786d782e9c8ffc4e22))
 - **FIX**: use Android minSdk >= 21. ([95829c6a](https://github.com/hpi-studyu/studyu/commit/95829c6ace02330ea921c51c0160903fcf94d0b0))
 - **FIX**: update ios deps. ([2c77103c](https://github.com/hpi-studyu/studyu/commit/2c77103cd047be6fd757f03222778edbfa8caf2a))
 - **FIX**: storage bug. ([b7e58d09](https://github.com/hpi-studyu/studyu/commit/b7e58d09a80bfb4f62c11859d6065356085255c8))
 - **FIX**: use 16 as IV length. ([f72a191a](https://github.com/hpi-studyu/studyu/commit/f72a191a1c750c414b98205d6faa512342181b26))
 - **FIX**: typo. ([51f62bb7](https://github.com/hpi-studyu/studyu/commit/51f62bb7d95ba50a315687027f8e27b36e58522e))
 - **FIX**: add versions to pub devs. ([6948ca1e](https://github.com/hpi-studyu/studyu/commit/6948ca1e60b6c3d6a740863a05ca6702079c8310))
 - **FIX**: camera does not need audio. ([54cca2b9](https://github.com/hpi-studyu/studyu/commit/54cca2b9ee6e299548eb0b9ff48c87e04b42c739))
 - **FIX**: const constructor. ([2a5d4b48](https://github.com/hpi-studyu/studyu/commit/2a5d4b488c090a7b55de3ccf58f3203a2034ff95))
 - **FIX**: do not support multimodal for web, refactor multimodal questions. ([19f08166](https://github.com/hpi-studyu/studyu/commit/19f08166e3726532d0a6042dafeed3283f58ce5b))
 - **FIX**: defer upload of multimodal files. ([e8324cab](https://github.com/hpi-studyu/studyu/commit/e8324cabd5dc7b20d1be529ae8ba94d51ab5eb39))
 - **FIX**: switch to uploadBinary for now. ([b9884dee](https://github.com/hpi-studyu/studyu/commit/b9884deeba14de85f00ebe55703acdeeb1de1422))
 - **FIX**: switch object equal check. ([200c4643](https://github.com/hpi-studyu/studyu/commit/200c46431d9d44227ad8ff55b284c85358f63e0a))
 - **FIX**: upgrade deps, move multimodal from core to app, migrate switch case. ([c4c1bd1e](https://github.com/hpi-studyu/studyu/commit/c4c1bd1e7e234535291b609deda21ea0e12b8506))
 - **FIX**: dart fix. ([1ebe9d00](https://github.com/hpi-studyu/studyu/commit/1ebe9d005d4c5d0f9e7ba1d8a0f24fc4e71641c2))
 - **FIX**: use dynamic Sdk version, use release env. ([0e4cbe5d](https://github.com/hpi-studyu/studyu/commit/0e4cbe5dc9cbf3109194d001e6439d2a782192b6))
 - **FIX**: upgrade deps (switch to wakelock_plus). ([1000d89c](https://github.com/hpi-studyu/studyu/commit/1000d89cd4df62bbfedfb5238f0e427c4d2d2c08))
 - **FIX**: modify xcode version and ios target platform. ([2ca76bf2](https://github.com/hpi-studyu/studyu/commit/2ca76bf2c950934554dee7dabed84a34454cc4a1))
 - **FIX**: change provisioning profile name. ([d12fa572](https://github.com/hpi-studyu/studyu/commit/d12fa5722e4dfc9cb7200359c971e47a259fe4d8))
 - **FEAT**: record audio inside question widget. ([aa9cb51d](https://github.com/hpi-studyu/studyu/commit/aa9cb51d9469707e39587dbe9bd6f68ed262f4d9))
 - **FEAT**: translate. ([8811b543](https://github.com/hpi-studyu/studyu/commit/8811b5434e1657ef91774012445178c19741efbe))
 - **FEAT**: deprecate SharedPreferences for flutter_secure_storage. ([1ff25946](https://github.com/hpi-studyu/studyu/commit/1ff259469e3c354f57e22a3d42ce0d1c60036f44))
 - **FEAT**(app): directly show task description in task screen. ([76fd9f65](https://github.com/hpi-studyu/studyu/commit/76fd9f65d7f3685471f3a75fc4a8beaf34739a3a))
 - **FEAT**: delete local multimodal files. ([319d7c22](https://github.com/hpi-studyu/studyu/commit/319d7c2261e38a42c68324516e9295b36ce8b9f3))
 - **FEAT**: add localization for multimodal. ([32d15487](https://github.com/hpi-studyu/studyu/commit/32d154879118f57a4a397ffa43c33d86f63a4f0f))
 - **FEAT**: add offline handling for multimodal files. ([92e3d3b3](https://github.com/hpi-studyu/studyu/commit/92e3d3b3732543ecf2bcfa855cb20ef3cc3123de))

## 2.6.5

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 2.6.5-dev.8

 - **FIX**: pod update. ([a289069e](https://github.com/hpi-studyu/studyu/commit/a289069ef8eeab8ee996f9a9b6d26f98535a25e3))

## 2.6.5-dev.7

 - **REFACTOR**: login process and offline mode. ([aab64a42](https://github.com/hpi-studyu/studyu/commit/aab64a429df81037eb6cd9c06b7eb89b282a1a05))
 - **REFACTOR**: remove unnecessary late. ([f17902e2](https://github.com/hpi-studyu/studyu/commit/f17902e2d22294cc0ddcaa25ed091982da8fc082))
 - **REFACTOR**: improve return type of publishedPublicStudies(). ([fedec441](https://github.com/hpi-studyu/studyu/commit/fedec441fd4f0f39fe35e7cb89b2922a10ac9ea3))
 - **REFACTOR**: create abstract exception and rename ExtractedSupabaseListResult. ([5ef1bc43](https://github.com/hpi-studyu/studyu/commit/5ef1bc4378c2ac35e9781a040c4868910291794b))
 - **REFACTOR**: bind faulty studies to return value. ([e6b4ed70](https://github.com/hpi-studyu/studyu/commit/e6b4ed70d367ddb9e8b1e7fd0015d0f70a179a0c))
 - **REFACTOR**: remove ExtractedSupabaseListResult. ([0d3f4af9](https://github.com/hpi-studyu/studyu/commit/0d3f4af9d201556ba5ec0884741969e7dfa47b71))
 - **REFACTOR**: mounted check. ([e1b07e45](https://github.com/hpi-studyu/studyu/commit/e1b07e45093dd77898274e92582ba48b54e762e3))
 - **FIX**: upgrade deps. ([b491c9c4](https://github.com/hpi-studyu/studyu/commit/b491c9c469ee808fe1aaa50b7a50759be2378552))
 - **FIX**: make offline mode more reliable. ([45370246](https://github.com/hpi-studyu/studyu/commit/45370246253bfdf1a884a7e873ef68d4542e8e55))
 - **FIX**: multi-retrieval of public studies. ([4218eb00](https://github.com/hpi-studyu/studyu/commit/4218eb00f9067ea9586eb1a5b76dba202b493e5f))
 - **FIX**: showSnackBar() method cannot be called during build. ([e835db62](https://github.com/hpi-studyu/studyu/commit/e835db62a6ca61b6e1afd3d0df4d0d9e53153a07))
 - **FIX**: translation. ([15af570a](https://github.com/hpi-studyu/studyu/commit/15af570ab0cc7d6ab053efac1666b6380c94a692))
 - **FIX**: future-proof deserialization of studies. ([ca7c3145](https://github.com/hpi-studyu/studyu/commit/ca7c3145cd663dda47716ffa4ac5cef3fb25da84))
 - **FEAT**: show hidden studies info with MaterialBanner. ([5cac27d5](https://github.com/hpi-studyu/studyu/commit/5cac27d58cb3415c54de5ecc07c1eed4df74ac97))
 - **FEAT**: rework deserialization of unsupported types to throw exception. ([54956cf1](https://github.com/hpi-studyu/studyu/commit/54956cf17c879dce27821da3a85f2d8d509542e7))

## 2.6.5-dev.6

 - **REFACTOR**: login process and offline mode. ([aab64a42](https://github.com/hpi-studyu/studyu/commit/aab64a429df81037eb6cd9c06b7eb89b282a1a05))
 - **REFACTOR**: remove unnecessary late. ([f17902e2](https://github.com/hpi-studyu/studyu/commit/f17902e2d22294cc0ddcaa25ed091982da8fc082))
 - **REFACTOR**: improve return type of publishedPublicStudies(). ([fedec441](https://github.com/hpi-studyu/studyu/commit/fedec441fd4f0f39fe35e7cb89b2922a10ac9ea3))
 - **REFACTOR**: create abstract exception and rename ExtractedSupabaseListResult. ([5ef1bc43](https://github.com/hpi-studyu/studyu/commit/5ef1bc4378c2ac35e9781a040c4868910291794b))
 - **REFACTOR**: bind faulty studies to return value. ([e6b4ed70](https://github.com/hpi-studyu/studyu/commit/e6b4ed70d367ddb9e8b1e7fd0015d0f70a179a0c))
 - **REFACTOR**: remove ExtractedSupabaseListResult. ([0d3f4af9](https://github.com/hpi-studyu/studyu/commit/0d3f4af9d201556ba5ec0884741969e7dfa47b71))
 - **REFACTOR**: mounted check. ([e1b07e45](https://github.com/hpi-studyu/studyu/commit/e1b07e45093dd77898274e92582ba48b54e762e3))
 - **REFACTOR**: move constants to separate file. ([b4d3853d](https://github.com/hpi-studyu/studyu/commit/b4d3853d827c3e0f08db16234f5a136094938a0d))
 - **FIX**: upgrade deps. ([b491c9c4](https://github.com/hpi-studyu/studyu/commit/b491c9c469ee808fe1aaa50b7a50759be2378552))
 - **FIX**: make offline mode more reliable. ([45370246](https://github.com/hpi-studyu/studyu/commit/45370246253bfdf1a884a7e873ef68d4542e8e55))
 - **FIX**: web compatibility for app outdated screen. ([40f39afe](https://github.com/hpi-studyu/studyu/commit/40f39afe60293bfd62ea705a55f59012c6aa00e3))
 - **FIX**: multi-retrieval of public studies. ([4218eb00](https://github.com/hpi-studyu/studyu/commit/4218eb00f9067ea9586eb1a5b76dba202b493e5f))
 - **FIX**: review comments. ([71896db6](https://github.com/hpi-studyu/studyu/commit/71896db6425a04cbfe644fb73045102287abcd2b))
 - **FIX**: showSnackBar() method cannot be called during build. ([e835db62](https://github.com/hpi-studyu/studyu/commit/e835db62a6ca61b6e1afd3d0df4d0d9e53153a07))
 - **FIX**: translation. ([15af570a](https://github.com/hpi-studyu/studyu/commit/15af570ab0cc7d6ab053efac1666b6380c94a692))
 - **FIX**: check min app version improvements. ([8d36dc78](https://github.com/hpi-studyu/studyu/commit/8d36dc78771d748483bbf3ad22794a95e73dad06))
 - **FIX**: future-proof deserialization of studies. ([ca7c3145](https://github.com/hpi-studyu/studyu/commit/ca7c3145cd663dda47716ffa4ac5cef3fb25da84))
 - **FEAT**: show hidden studies info with MaterialBanner. ([5cac27d5](https://github.com/hpi-studyu/studyu/commit/5cac27d58cb3415c54de5ecc07c1eed4df74ac97))
 - **FEAT**: check app min version on resume. ([e82c3ac6](https://github.com/hpi-studyu/studyu/commit/e82c3ac68beb4adf0662753c551d7cf3d53814b9))
 - **FEAT**: rework deserialization of unsupported types to throw exception. ([54956cf1](https://github.com/hpi-studyu/studyu/commit/54956cf17c879dce27821da3a85f2d8d509542e7))
 - **FEAT**: check min app version and force update. ([08f33618](https://github.com/hpi-studyu/studyu/commit/08f3361865aa4b158e9e29e69efd30547db9991a))

## 2.6.5-dev.5

 - **FIX**: upgrade deps. ([5327eb97](https://github.com/hpi-studyu/studyu/commit/5327eb971e6673847dc09ef56923b6a73ae73654))
 - **FIX**: missing notification icon. ([679ebc64](https://github.com/hpi-studyu/studyu/commit/679ebc64d779b87589dcec24135c3f8533b7ed62))
 - **FIX**: correct CFBundleDisplayName. ([eb364558](https://github.com/hpi-studyu/studyu/commit/eb364558133f18d47737e198b585544e2344a03c))
 - **FIX**: add notification icon again". ([5905e4e4](https://github.com/hpi-studyu/studyu/commit/5905e4e4dda66734d9205e90c0a78a7c999ace18))

## 2.6.5-dev.4

 - **FIX**: breaking deps. ([34896ad3](https://github.com/hpi-studyu/studyu/commit/34896ad381b38a4ad03caf92f57ad527bc1f6706))

## 2.6.5-dev.3

 - **REFACTOR**: rework android release platform and pipeline. ([08f4c97f](https://github.com/hpi-studyu/studyu/commit/08f4c97f07c84491bac4147955ba7f03a5bae65d))
 - **FIX**: upgrade deps. ([6ad9bea4](https://github.com/hpi-studyu/studyu/commit/6ad9bea42903a25a5be5a84f2af8b70654d05616))
 - **FIX**: null value. ([3a0e6592](https://github.com/hpi-studyu/studyu/commit/3a0e65928dd74f0b630fd53a15efb3cbbc1ec555))
 - **FIX**: add notification icon again. ([23656f60](https://github.com/hpi-studyu/studyu/commit/23656f60d3de85d2007e9c88c28656b4503d7e7b))
 - **FIX**: crash on Android 12L / 13. ([1d8dd104](https://github.com/hpi-studyu/studyu/commit/1d8dd10479aebf490c3941cf5f0493c95de494bc))
 - **FIX**: wrong notification icon path. ([7b91f55f](https://github.com/hpi-studyu/studyu/commit/7b91f55f06d132739e1066e7df814b92d8470634))
 - **FIX**: update gitignore files. ([939d6be4](https://github.com/hpi-studyu/studyu/commit/939d6be422ee37f2ea56b39bb3921060fd1844cd))
 - **FIX**: use icon directory. ([d3d627cd](https://github.com/hpi-studyu/studyu/commit/d3d627cda35c14af026507f4181c232b8c43e22d))
 - **FIX**: new web deployment with generated icons. ([fd8fcc9f](https://github.com/hpi-studyu/studyu/commit/fd8fcc9f459cc0f46c5185d96cce6586adbfc543))
 - **FIX**: upgrade deps. ([7ac0d4ca](https://github.com/hpi-studyu/studyu/commit/7ac0d4cab42b1ce27ec200a5241f92d612ade499))
 - **FIX**: upgrade deps. ([3e186fc4](https://github.com/hpi-studyu/studyu/commit/3e186fc409f038102cc5fd1e6d11b73057dab8d7))
 - **FEAT**: add other platforms. ([34f5dafa](https://github.com/hpi-studyu/studyu/commit/34f5dafadafda6bc8652639245901620a2a116ab))

## 2.6.5-dev.2

 - **REFACTOR**: rename analytics. ([98386b03](https://github.com/hpi-studyu/studyu/commit/98386b03ada1a47d28469afbd15e3bde411ef6b9))
 - **REFACTOR**: enable cache again and add new logger. ([e0ad446f](https://github.com/hpi-studyu/studyu/commit/e0ad446fe03c94261782606a186a0364dbe87428))
 - **REFACTOR**: disable cache addition. ([711da599](https://github.com/hpi-studyu/studyu/commit/711da599025242748700959b2d1e59b34fb44028))
 - **REFACTOR**: move questions to subdir. ([0a28df5a](https://github.com/hpi-studyu/studyu/commit/0a28df5a2bf39b18dfb642dcdeb3dd1863eba50a))
 - **FIX**: upgrade deps. ([3e186fc4](https://github.com/hpi-studyu/studyu/commit/3e186fc409f038102cc5fd1e6d11b73057dab8d7))
 - **FIX**: resolve suggestions. ([e3584b70](https://github.com/hpi-studyu/studyu/commit/e3584b706e3ac44e51257165dcf9e0678205d8a5))
 - **FIX**: quickfix for free text eligibility. ([5bb2e42b](https://github.com/hpi-studyu/studyu/commit/5bb2e42b89383611fd9cd0882c1cdb6df4c07544))
 - **FIX**: free text form fields. ([b2badeb0](https://github.com/hpi-studyu/studyu/commit/b2badeb00e43d16518c8af29e4ec0d18f1389b14))
 - **FIX**: use correct switch case for questions. ([c13e67f6](https://github.com/hpi-studyu/studyu/commit/c13e67f6b05571b9476fe476154bb927108fff1f))
 - **FIX**: disable cache synchronization for now. ([204157cd](https://github.com/hpi-studyu/studyu/commit/204157cd970cb7228cf4d2d1a804bed1fabb657a))
 - **FEAT**: increase max free text range. ([5b288caf](https://github.com/hpi-studyu/studyu/commit/5b288cafc67f6f841671afd94b0f5cdaa56d60af))
 - **FEAT**: improve translation. ([c4b9f1ec](https://github.com/hpi-studyu/studyu/commit/c4b9f1ec4da93eb5ce189c5c001f9884ba34d152))
 - **FEAT**: implement free text validator for app. ([44c3fa20](https://github.com/hpi-studyu/studyu/commit/44c3fa2070e0073a6ab4352daa4d96d7ee1632fe))
 - **FEAT**: implement free_text for designer. ([f0ce3512](https://github.com/hpi-studyu/studyu/commit/f0ce3512f28b1eaae1bc69f75701038e42e6936d))

## 2.6.5-dev.1

 - **FIX**: upgrade deps. ([304430c8](https://github.com/hpi-studyu/studyu/commit/304430c858d4035a279b42114c7ccf86299357a2))
 - **FIX**: type checks and matching. ([92629cb4](https://github.com/hpi-studyu/studyu/commit/92629cb4395d8e456a0531647d6ba1de4a77a92f))
 - **FIX**: type checks. ([b85e073d](https://github.com/hpi-studyu/studyu/commit/b85e073d7075b8d45d15f32e62d5761416cdad4a))

## 2.6.5-dev.0

 - **FIX**: refresh dashboard on app resume. ([9bcd0e51](https://github.com/hpi-studyu/studyu/commit/9bcd0e5159d80e1f4cd4948f0ee8956705cd8c38))
 - **FIX**: add required manifest entries for notifications to work again. ([5c8e4bbe](https://github.com/hpi-studyu/studyu/commit/5c8e4bbe42e6e5d93ee0f20a5732d8f28324df1a))

## 2.6.4

 - **FIX**: upgrade deps. ([f37d0a71](https://github.com/hpi-studyu/studyu/commit/f37d0a711ab9a126b7da13b7eb4fbb9b784f3725))
 - **FIX**: dart fix. ([d184c43b](https://github.com/hpi-studyu/studyu/commit/d184c43bafd0229a799ec835b16c3dcb851016b9))
 - **FIX**: upgrade deps. ([567a3b07](https://github.com/hpi-studyu/studyu/commit/567a3b07c360e55da62898e928a794a756ab0546))
 - **FIX**: dart fix. ([8d81f96c](https://github.com/hpi-studyu/studyu/commit/8d81f96c0caf63df04fc41f156d3312e5b09c076))

## 2.6.3

 - **FIX**: upgrade deps. ([567a3b07](https://github.com/hpi-studyu/studyu/commit/567a3b07c360e55da62898e928a794a756ab0546))
 - **FIX**: dart fix. ([8d81f96c](https://github.com/hpi-studyu/studyu/commit/8d81f96c0caf63df04fc41f156d3312e5b09c076))

## 2.6.2

 - **FIX**: update descriptions and rename imprint. ([6d3757f4](https://github.com/hpi-studyu/studyu/commit/6d3757f425dd5b95ee581e10b6ad675f8e71786a))

## 2.6.1

 - **FIX**: upgrade deps. ([6fa0e8b8](https://github.com/hpi-studyu/studyu/commit/6fa0e8b8332c0872b59c7c31042fb845f0708e73))
 - **FIX**: update cocoapod. ([ed45f6f5](https://github.com/hpi-studyu/studyu/commit/ed45f6f5a71e8227652d291232769bcc0bb75ba6))

## 2.6.0

 - **REFACTOR**: hardcoded baseline id. ([aeac14a2](https://github.com/hpi-studyu/studyu/commit/aeac14a2e2b01c0d48799d9ed69264d72f170353))
 - **REFACTOR**: bar generator. ([a05c7808](https://github.com/hpi-studyu/studyu/commit/a05c78082828551381483c15434cddf25ab681ac))
 - **REFACTOR**: remove code duplication. ([a3ff4203](https://github.com/hpi-studyu/studyu/commit/a3ff4203f883170e0730e79d5b0aa677e0f1aa8a))
 - **REFACTOR**: remove unnecessary passing of instance variable. ([5142f0e8](https://github.com/hpi-studyu/studyu/commit/5142f0e8a088acacfd881d4d1dbcf0c01d5a603b))
 - **REFACTOR**: pass diagram data. ([7062d4f0](https://github.com/hpi-studyu/studyu/commit/7062d4f034d8fa0a24886bed7ab12525d674ea39))
 - **FIX**: upgrade deps. ([7cdc7c55](https://github.com/hpi-studyu/studyu/commit/7cdc7c559f64cfdd63ee07efbeeb028c418f6f4e))
 - **FIX**: upgrade deps. ([17213746](https://github.com/hpi-studyu/studyu/commit/172137469ed236dc694979bbfe017708faabbd77))
 - **FIX**: revert minSdkVersion to 19. ([c928cf9b](https://github.com/hpi-studyu/studyu/commit/c928cf9b893455d8cc9ce436799f7a83930f742c))
 - **FIX**: reports for studies without baseline. ([231915ae](https://github.com/hpi-studyu/studyu/commit/231915aef5f7d22e5749600b779177ba36b7f9e8))
 - **FIX**: day offset when baseline is excluded. ([5b3577aa](https://github.com/hpi-studyu/studyu/commit/5b3577aa381b2d554c11a88d24798c82b361a7ca))
 - **FIX**: chart import. ([7d616580](https://github.com/hpi-studyu/studyu/commit/7d616580ccc11473117a255f0f94ee08432db639))
 - **FIX**: bump minimum required sdk version to 33 and set target to flutter.compileSdkVersion. ([92bec536](https://github.com/hpi-studyu/studyu/commit/92bec536c676b1ff361030e4b045428c9c1b025d))
 - **FEAT**: add 20% y-padding. ([0d5694d6](https://github.com/hpi-studyu/studyu/commit/0d5694d61e74f368a450fc1cba075f9599713dfd))
 - **FEAT**: bold title. ([e2c9914e](https://github.com/hpi-studyu/studyu/commit/e2c9914ec1243ebb89b7218f975faa3948646a7b))
 - **FEAT**: dynamic bar width. ([474f9223](https://github.com/hpi-studyu/studyu/commit/474f922325f42c525691f0c2e0b84446181190af))
 - **FEAT**: display phase number as integer. ([0dab0269](https://github.com/hpi-studyu/studyu/commit/0dab026951c13c13b7f8c96f85c5c1109ca40fcb))
 - **FEAT**: enable tooltips. ([3b642f5b](https://github.com/hpi-studyu/studyu/commit/3b642f5b99376dad324da41a9b69470f36470c90))
 - **FEAT**: phase separator lines. ([5b6921a5](https://github.com/hpi-studyu/studyu/commit/5b6921a565ec7f8c3fb1cdbdfd84e2a8e8dfb9b1))
 - **FEAT**: add question title. ([0450f925](https://github.com/hpi-studyu/studyu/commit/0450f925bbe388d4dc4eb8a49061b93e8b92587c))
 - **FEAT**: chart legend. ([4a5984e2](https://github.com/hpi-studyu/studyu/commit/4a5984e29220cc1ce88ba981d6ba2679681fe2b0))
 - **FEAT**: get intervention names. ([8525cc7d](https://github.com/hpi-studyu/studyu/commit/8525cc7d838ec2c4a97d4454747b56e474c45c5f))
 - **FEAT**: legend widgets. ([8031b88e](https://github.com/hpi-studyu/studyu/commit/8031b88e491152ed4c37b83b34ec2b8f5b2af051))

## 2.5.0

 - **FIX**: make analytics fully optional. ([67d58887](https://github.com/hpi-studyu/studyu/commit/67d588879a69a9105cd2e54c08f2a2feae1224a2))
 - **FIX**: upgrade deps. ([aa2cb251](https://github.com/hpi-studyu/studyu/commit/aa2cb2512e3db4e31f97edea8d2bccf55e91f9d2))
 - **FEAT**: make study tags reactive. ([f2f8ecaf](https://github.com/hpi-studyu/studyu/commit/f2f8ecafb4f21d21128ce089eb99608778b91e2e))

## 2.4.7

 - **FIX**: upgrade deps (switch to wakelock_plus). ([177e5057](https://github.com/hpi-studyu/studyu/commit/177e5057fb41821a2f924ffda79e1faa3119859d))
 - **FIX**: upgrade deps (switch to wakelock_plus). ([9112f5f0](https://github.com/hpi-studyu/studyu/commit/9112f5f0a9c778e2abf24f6aa585bc9f539e6ccf))

## 2.4.6

 - **FIX**: upgrade deps (switch to wakelock_plus). ([9112f5f0](https://github.com/hpi-studyu/studyu/commit/9112f5f0a9c778e2abf24f6aa585bc9f539e6ccf))
 - **FIX**: modify xcode version and ios target platform. ([67ec1562](https://github.com/hpi-studyu/studyu/commit/67ec15621054606f2e1995caa9f2b778e1d6593e))
 - **FIX**: change provisioning profile name. ([5d84a1fc](https://github.com/hpi-studyu/studyu/commit/5d84a1fc7939674e509aff7a72581b10df0d969a))
 - **FIX**: const constructor. ([1629003a](https://github.com/hpi-studyu/studyu/commit/1629003ae93d6fd6a495b3cbe6c23dd84ae3bcd8))

## 2.4.5

 - **FIX**: add await-workflow action to wait for pub.dev publishing. ([7206a006](https://github.com/hpi-studyu/studyu/commit/7206a00663657f6d6256b99b0c3aca33e9b263bb))

## 2.4.4

 - **FIX**(deps): new temporary wakelock fix repo. ([414364c5](https://github.com/hpi-studyu/studyu/commit/414364c5373092994b20765c986cba75e21b3dc4))
 - **FIX**: upgrade deps. ([35c629aa](https://github.com/hpi-studyu/studyu/commit/35c629aa28fc5761a707168d998a425307ec6d9a))

## 2.4.3

 - **FIX**(deps): new temporary wakelock fix repo. ([bc2d90b2](https://github.com/hpi-studyu/studyu/commit/bc2d90b2f2859a79481e0c7ae9840c0e30cb7503))
 - **FIX**: upgrade deps. ([b2926c39](https://github.com/hpi-studyu/studyu/commit/b2926c395988077d4aa172490dbd9c6fd75d52c6))
 - **FIX**: upgrade deps. ([daad1465](https://github.com/hpi-studyu/studyu/commit/daad146590e874bedee3f82bb72bf4b94e5c3801))

## 2.4.2

 - **FIX**: upgrade deps. ([daad1465](https://github.com/hpi-studyu/studyu/commit/daad146590e874bedee3f82bb72bf4b94e5c3801))

## 2.4.1

 - **FIX**: analytics same key. ([b2412c42](https://github.com/hpi-studyu/studyu/commit/b2412c422263c8f1e08f5fe6197ac412fe5941c6))
 - **DOCS**: add todo, describe bug. ([4316341c](https://github.com/hpi-studyu/studyu/commit/4316341c601bd884daf271c6b6ef5805828bc32e))

## 2.4.0

 - **FEAT**: store analytics data in the backend and support caching. ([f3e70610](https://github.com/hpi-studyu/studyu/commit/f3e7061081f631d74c6df0ea78024ace6ea1f333))

## 2.3.4

 - **FIX**: overwrite universal_html dep. ([19f30c86](https://github.com/hpi-studyu/studyu/commit/19f30c863dbb59c4f176694c177fc8c0f964dc24))
 - **FIX**: deps quickfix. ([99cc4ea6](https://github.com/hpi-studyu/studyu/commit/99cc4ea642b4d97c3d59ffe1412eb1e2c231615b))

## 2.3.3

 - **FIX**: downgrade deps to stable release. ([773ec700](https://github.com/hpi-studyu/studyu/commit/773ec7003716877115632102eadcf704a5a270e3))

## 2.3.2

 - **FIX**: do not show notifications after study was left. ([f478ab9d](https://github.com/hpi-studyu/studyu/commit/f478ab9de6463b666d7c3f55ad2afcdbc65cf72f))

## 2.3.1

 - **REFACTOR**: initial null safety support. ([82c119f9](https://github.com/hpi-studyu/studyu/commit/82c119f980f647133bff1c3748625e148cbc6ffe))
 - **FIX**: only invalidate questions if necessary. ([c33d5162](https://github.com/hpi-studyu/studyu/commit/c33d5162b18965787a0a80d2cc98c3194281c693))
 - **FIX**: improve offline mode, check earlier if device is offline. ([c7a143f5](https://github.com/hpi-studyu/studyu/commit/c7a143f5d2b16220ac72e6b533cee18ac25cd0d3))

## 2.3.0

 - **REFACTOR**: button for null safety. ([9c2796e3](https://github.com/hpi-studyu/studyu/commit/9c2796e311c5729759c7bbe6c9ad054423a2b3fe))
 - **FIX**: add untouched slider buttons again. ([9775f7ef](https://github.com/hpi-studyu/studyu/commit/9775f7eff28001b0fdff7e45fe1c266085dec878))
 - **FEAT**: implement limited offline mode for app. ([cbc898f3](https://github.com/hpi-studyu/studyu/commit/cbc898f34a47535e8f950365ded92ef210137e23))

## 2.2.1

 - **FIX**: study cannot be left inadvertently anymore via about. ([b8237b5b](https://github.com/hpi-studyu/studyu/commit/b8237b5b4e0b4c1e35d3b22efe22fd89d2990ba5))
 - **FIX**: provide option to disable analytics in settings. ([1f2dc252](https://github.com/hpi-studyu/studyu/commit/1f2dc252aee41896d12951a2e13bd37b24d47df9))

## 2.2.0

 - **FIX**: could not find libflutter.so. ([95aa1828](https://github.com/hpi-studyu/studyu/commit/95aa1828cc8b9c280218ae91da4127f75cc6b96d))
 - **FIX**: device language is now used as default app language. ([ee78de35](https://github.com/hpi-studyu/studyu/commit/ee78de35c5ebed91fca297f9c1a7e78aac4d67f3))
 - **FIX**: improve debug mode and send test notification. ([84937a2b](https://github.com/hpi-studyu/studyu/commit/84937a2bd50dfe18cd26cb1e112347f0a2cabd73))
 - **FIX**: more slider usability fixes. ([d8309803](https://github.com/hpi-studyu/studyu/commit/d83098037f6f1cf9bdc0f150df6d94156c81f19d))
 - **FIX**: improve questionnaire slider usability. ([9068c195](https://github.com/hpi-studyu/studyu/commit/9068c1954ccc1e3265e72e16304528b7f2e81dbc))
 - **FIX**: slider design overhaul. ([75589ca1](https://github.com/hpi-studyu/studyu/commit/75589ca1f443f4ef779a8766cc9150cda74fb3bb))
 - **FIX**: improve debug mode and send test notification. ([8c6afd6f](https://github.com/hpi-studyu/studyu/commit/8c6afd6fd36904592a5aa0c118c5cf88afc8bfc1))
 - **FIX**: more slider usability fixes. ([6e151bc6](https://github.com/hpi-studyu/studyu/commit/6e151bc6281c3740ccb8d23154994c2066fc65ae))
 - **FIX**: improve questionnaire slider usability. ([187fda96](https://github.com/hpi-studyu/studyu/commit/187fda96dfb6faa44d6521859cf0219c726cab17))
 - **FIX**: slider design overhaul. ([b5a6b8ad](https://github.com/hpi-studyu/studyu/commit/b5a6b8ad18c67d2ab5b21313ff5740f175d9b7eb))
 - **FEAT**: sentry integration in core. ([0fae767f](https://github.com/hpi-studyu/studyu/commit/0fae767f0a7dc3c3409dd5179eeb870429b580cd))
 - **FEAT**: Add sentry.io for crash reports. ([d19e0e9b](https://github.com/hpi-studyu/studyu/commit/d19e0e9b2d1db453f9e1e09cd0b37269c22278cb))

## 2.1.2

 - **FIX**: improve debug mode and send test notification. ([8c6afd6f](https://github.com/hpi-studyu/studyu/commit/8c6afd6fd36904592a5aa0c118c5cf88afc8bfc1))
 - **FIX**: more slider usability fixes. ([6e151bc6](https://github.com/hpi-studyu/studyu/commit/6e151bc6281c3740ccb8d23154994c2066fc65ae))
 - **FIX**: improve questionnaire slider usability. ([187fda96](https://github.com/hpi-studyu/studyu/commit/187fda96dfb6faa44d6521859cf0219c726cab17))
 - **FIX**: slider design overhaul. ([b5a6b8ad](https://github.com/hpi-studyu/studyu/commit/b5a6b8ad18c67d2ab5b21313ff5740f175d9b7eb))
 - **FIX**: disable multiple submit button clicks for task widget. ([5297f590](https://github.com/hpi-studyu/studyu/commit/5297f59074f3e2771cdb9431fc563a236894fd08))

## 2.1.1

 - **FIX**: upgrade deps to fix invalid refresh token bug. ([6a4da159](https://github.com/hpi-studyu/studyu/commit/6a4da1594d7baed5d76f74464670ec411abc961c))

## 2.1.0

 - **FIX**: Missing Push Notification Entitlement for iOS. ([28ffd2c2](https://github.com/hpi-studyu/studyu/commit/28ffd2c2f2e06822d95c5a3e77e23fdfcb11b823))
 - **FIX**: make intervention task title wrappable. ([ea73a74e](https://github.com/hpi-studyu/studyu/commit/ea73a74e20833001a494bfc35d2d84d04e786f95))
 - **FIX**(app): question footer not being shown. ([e2553c34](https://github.com/hpi-studyu/studyu/commit/e2553c34689a26d2b404e69292ad07914f1ae0b9))
 - **FIX**(app): Next Day button overflow. ([0c78e221](https://github.com/hpi-studyu/studyu/commit/0c78e22115a89bb5c04c628191370829658562b6))
 - **FIX**: consent items not centered if no icon. ([827d68b0](https://github.com/hpi-studyu/studyu/commit/827d68b0371c999e502a941a2e49c592b7ef0993))
 - **FEAT**: add report section validation sets. ([5c063148](https://github.com/hpi-studyu/studyu/commit/5c0631480aa0efa886104640380908da6dc78f39))
 - **FEAT**: translation and styling. ([4f62ba65](https://github.com/hpi-studyu/studyu/commit/4f62ba65c6f5736465f40654c352902289f8db37))

## 2.0.2

 - **FIX**: preview mode working again. ([75bec484](https://github.com/hpi-studyu/studyu/commit/75bec484a065cea9a4842afde26205876718d7d0))

## 2.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 2.0.0-dev.7

 - **FIX**: reload dashboard if subject is null. ([42ccfc42](https://github.com/hpi-studyu/studyu/commit/42ccfc42ac437fb54d670f5c5cbbf557e6ef34f4))
 - **FEAT**: start study at the next day for new participants. ([0445a1f4](https://github.com/hpi-studyu/studyu/commit/0445a1f4c137e3b4c07a945640e660e47e1d51a0))

## 2.0.0-dev.6

 - Update a dependency to the latest release.

## 2.0.0-dev.5

 - **FIX**: show dashboard correctly for the day if intervention cycle occurs - match reminder to correct completionperiod. ([7532031a](https://github.com/hpi-studyu/studyu/commit/7532031a546b2ebfa1b5fd7904f6ef186327570d))
 - **FIX**: show dashboard correctly for the day if intervention cycle occurs. ([f4eba956](https://github.com/hpi-studyu/studyu/commit/f4eba956be2509643c17530385f151d7e3937c0f))
 - **FIX**: increase notification reliability. ([b384a83d](https://github.com/hpi-studyu/studyu/commit/b384a83dcf327a0f770ed5babe078e4ab54a95f3))
 - **FIX**: request REQUEST_IGNORE_BATTERY_OPTIMIZATIONS on android for scheduled notifications. ([92f9f2b0](https://github.com/hpi-studyu/studyu/commit/92f9f2b064520454e0c9e6fbb1d45209f24ece3b))
 - **FEAT**: add migration option to app for studyu v2. ([82698517](https://github.com/hpi-studyu/studyu/commit/82698517843cfc4aad80c194a6e5f349343a182d))
 - **FEAT**: Notification debug dialog. ([dd9984e8](https://github.com/hpi-studyu/studyu/commit/dd9984e8ce2f0bd1e9a6de585a3cd4359be436cb))

## 2.0.0-dev.4

 - **FIX**: do not show notifications for already completed tasks. ([39419c36](https://github.com/hpi-studyu/studyu/commit/39419c369907a046438900f77d5559c2606fb3d5))
 - **FIX**: reload dashboard after notification task completed. ([5737f080](https://github.com/hpi-studyu/studyu/commit/5737f08044f185e34dadfc54e45637b82f038692))

## 2.0.0-dev.3

 - Update a dependency to the latest release.

## 2.0.0-dev.2

 - **FIX**: didChangeDependencies executing twice on startup. ([9d33caf7](https://github.com/hpi-studyu/studyu/commit/9d33caf7c1f834a336cb962931150f96baed86d9))
 - **FIX**: designerV2 TaskInstance support for single completionperiods to restore live preview functionality. ([45792baf](https://github.com/hpi-studyu/studyu/commit/45792bafb0291914228ed4af058c821eb6be2f6d))
 - **FIX**: designerV2 TaskInstance support for single completionperiods to restore live preview functionality. ([6a85f162](https://github.com/hpi-studyu/studyu/commit/6a85f16252b91f9d8dc3b92f7deb00fef293f032))
 - **FIX**: notification have wrong ids. ([144b8d7d](https://github.com/hpi-studyu/studyu/commit/144b8d7dc834e0b0d38f5ae4a0f658300f4af073))
 - **FIX**: task instance named constructor. ([c88094f1](https://github.com/hpi-studyu/studyu/commit/c88094f1d7eb007f1926c2f7281b7d89a4a4dc3d))
 - **FIX**: notifications are only rescheduled if notification action was not completed before. ([ea7ea3d9](https://github.com/hpi-studyu/studyu/commit/ea7ea3d9eba0e788ffde2a4839ede933d9a6182b))
 - **FIX**: notifications can only be opened if inside period. ([dbc78b85](https://github.com/hpi-studyu/studyu/commit/dbc78b8505f20c3cf51e9d6036144d5f6cf8272b))
 - **FIX**: replace web-only library html. ([f708284d](https://github.com/hpi-studyu/studyu/commit/f708284da8ddc55f581ae5c4661ba396962be0fb))
 - **FIX**: go to loading screen after task completed to update dashboard. ([3a419b5f](https://github.com/hpi-studyu/studyu/commit/3a419b5f0ce2d47e8fc2ad48e5653aebe0c2fb5d))
 - **FIX**: adopt preview language. ([c0cc6973](https://github.com/hpi-studyu/studyu/commit/c0cc6973f7fb7ce083ed4b1514842c3eb149ba7d))
 - **FEAT**: rename TimedTask to TaskInstance and make it mandatory. ([42f4ee14](https://github.com/hpi-studyu/studyu/commit/42f4ee14dd1d30c0df11b8e3e221c842c3fcc8af))

## 2.0.0-dev.1

 - **FIX**: merge issues. ([8a560314](https://github.com/hpi-studyu/studyu/commit/8a560314c14fcf3e37e9d40f7129a4db483e8a8a))
 - **FIX**: invite code not usable. ([0dc3e2a1](https://github.com/hpi-studyu/studyu/commit/0dc3e2a16b0f944b7dbba0793358f8e59fd56042))
 - **FIX**: report null value. ([8602cc10](https://github.com/hpi-studyu/studyu/commit/8602cc10b427ac9a67c7b44b46f57ba1b72d4768))
 - **FIX**: notification debug. ([483120fb](https://github.com/hpi-studyu/studyu/commit/483120fb9c4810721ad087f60d28ad8716153716))
 - **FIX**: notification debug mode, do not schedule past notifications. ([366d6886](https://github.com/hpi-studyu/studyu/commit/366d68867811f9d5332a7be41b48e5db30441aca))
 - **FIX**: reschedule notifications after a task was completed. ([ab92651d](https://github.com/hpi-studyu/studyu/commit/ab92651de93b225b47c5aeef9d46690bb2050187))
 - **FIX**: notification reloading bug on intervention change. ([b5a52bb9](https://github.com/hpi-studyu/studyu/commit/b5a52bb906226f3b98d000d5d36f167a5094a95a))
 - **FIX**: update outdated stuff and dart generate. ([82b58bdc](https://github.com/hpi-studyu/studyu/commit/82b58bdcbf6f077003398b1a19813aa35a36bd91))
 - **FIX**: after notification task completed reload dashboard. ([ed571950](https://github.com/hpi-studyu/studyu/commit/ed571950398de32ccbfb3ba26bd4b26022f8f344))
 - **FIX**: do not handle notification twice. ([2c61b868](https://github.com/hpi-studyu/studyu/commit/2c61b8688cb7a133bf66271ca932a31f4a590843))
 - **FIX**: do not allow to pop navigator after kickoff. ([65159a19](https://github.com/hpi-studyu/studyu/commit/65159a19d87b6fa0eb39189eca86ac4af1d928c1))
 - **FIX**: added missing deps and desugar v2.0.0. ([081241ca](https://github.com/hpi-studyu/studyu/commit/081241ca61d32d2f4f60f4b9d22973f174bbae79))
 - **FIX**: upgrade supabase_flutter (^1.3.1) and supabase (^1.4.0). ([88e6dad4](https://github.com/hpi-studyu/studyu/commit/88e6dad4cbf6f5847fe382e7969ec2e13a1dee44))
 - **FIX**: terms not showing correctly on android. ([b0fed23c](https://github.com/hpi-studyu/studyu/commit/b0fed23c5413cec0dde3874383b16a3c31d0a2db))
 - **FIX**: migration. ([3ac8f192](https://github.com/hpi-studyu/studyu/commit/3ac8f192d4191eed640340e1292bcdd1c64ece98))
 - **FIX**: show correct screen when app is launched by a notification. ([77c22707](https://github.com/hpi-studyu/studyu/commit/77c227078fa70e78e29ee7bf810b2bc20cb45657))
 - **FIX**: do not show interventions with empty titles. ([2a9abe76](https://github.com/hpi-studyu/studyu/commit/2a9abe764d245062548cff5a1a43251a9fc14a4f))
 - **FIX**: tasks cannot be completed multiple times via notifications + localization. ([d9974911](https://github.com/hpi-studyu/studyu/commit/d997491127016fed840a6b9b336db9b98583c051))
 - **FIX**: restructure notifications. ([e6627f5a](https://github.com/hpi-studyu/studyu/commit/e6627f5a4ae635465a1b805338b8b2f122704d03))
 - **FIX**: report screen null exceptions. ([38c59426](https://github.com/hpi-studyu/studyu/commit/38c5942626d042d6287fec8c5d603999c421193a))
 - **FIX**: keep alive question item states on scrolling. ([c27881f8](https://github.com/hpi-studyu/studyu/commit/c27881f8102f27a3200fc3e3ad7828ef1061edda))
 - **FIX**: tasks could be accessed outside of their completion times. ([d6fcd920](https://github.com/hpi-studyu/studyu/commit/d6fcd920af2f14ed57235111b7382f736cffbb55))
 - **FIX**: task screen empty title null exception. ([f8527dd4](https://github.com/hpi-studyu/studyu/commit/f8527dd41f16ec16ec7d8c5a8f36eb7e15775f0b))
 - **FIX**: notification icon. ([523e6396](https://github.com/hpi-studyu/studyu/commit/523e6396d143962e50eaaccc91fd2fc0cc7adb44))
 - **FIX**: notification not being delivered, add notification body. ([ed8e440b](https://github.com/hpi-studyu/studyu/commit/ed8e440ba66e04e0c06e98b4e1c0770927855377))
 - **FIX**: Skip consentCheck if study doesn't have one. ([5675d92a](https://github.com/hpi-studyu/studyu/commit/5675d92af89849bf8fb22ee99bfcf5a61408b5a4))
 - **FIX**: Remove error message at performance section. ([6a5b5905](https://github.com/hpi-studyu/studyu/commit/6a5b5905bc2aa765e550c37225f111603b692aa1))
 - **FIX**: upgrade to flutter 3.7.0. ([2aa80015](https://github.com/hpi-studyu/studyu/commit/2aa80015a22161773649790edf2c38742809c45b))
 - **FIX**: refactor questionnaire widget for eligibility and related tasks. ([b9639bcc](https://github.com/hpi-studyu/studyu/commit/b9639bcce5607b975b592683dc0c5d9a552f3927))
 - **FIX**: upgrade deps. ([1b411140](https://github.com/hpi-studyu/studyu/commit/1b41114080e405c385c15b7beb8d140193656e6a))
 - **FEAT**: Upgrade notifications & deps. ([08be0c3a](https://github.com/hpi-studyu/studyu/commit/08be0c3ac3bcffabd9ad6b518cbc0e4067183424))
 - **FEAT**: - Results of tasks with multiple completion periods are now saved uniquely. ([bf9e2818](https://github.com/hpi-studyu/studyu/commit/bf9e2818b5dc88102f69a7e773b5f9ccea0e7c73))

## 1.11.7

 - **FIX**: notification debug. ([483120fb](https://github.com/hpi-studyu/studyu/commit/483120fb9c4810721ad087f60d28ad8716153716))

## 1.11.6

 - Update a dependency to the latest release.

## 1.11.5

 - **FIX**: notification debug mode, do not schedule past notifications. ([366d6886](https://github.com/hpi-studyu/studyu/commit/366d68867811f9d5332a7be41b48e5db30441aca))

## 1.11.4

 - **FIX**: reschedule notifications after a task was completed. ([ab92651d](https://github.com/hpi-studyu/studyu/commit/ab92651de93b225b47c5aeef9d46690bb2050187))

## 1.11.3

 - **FIX**: notification reloading bug on intervention change. ([b5a52bb9](https://github.com/hpi-studyu/studyu/commit/b5a52bb906226f3b98d000d5d36f167a5094a95a))

## 1.11.2

 - **FIX**: after notification task completed reload dashboard. ([ed571950](https://github.com/hpi-studyu/studyu/commit/ed571950398de32ccbfb3ba26bd4b26022f8f344))
 - **FIX**: do not handle notification twice. ([2c61b868](https://github.com/hpi-studyu/studyu/commit/2c61b8688cb7a133bf66271ca932a31f4a590843))
 - **FIX**: do not allow to pop navigator after kickoff. ([65159a19](https://github.com/hpi-studyu/studyu/commit/65159a19d87b6fa0eb39189eca86ac4af1d928c1))
 - **FIX**: added missing deps and desugar v2.0.0. ([081241ca](https://github.com/hpi-studyu/studyu/commit/081241ca61d32d2f4f60f4b9d22973f174bbae79))
 - **FIX**: terms not showing correctly on android. ([b0fed23c](https://github.com/hpi-studyu/studyu/commit/b0fed23c5413cec0dde3874383b16a3c31d0a2db))

## 1.11.1

 - **FIX**: migration. ([3ac8f192](https://github.com/hpi-studyu/studyu/commit/3ac8f192d4191eed640340e1292bcdd1c64ece98))

## 1.11.0

 - **FIX**: show correct screen when app is launched by a notification. ([77c22707](https://github.com/hpi-studyu/studyu/commit/77c227078fa70e78e29ee7bf810b2bc20cb45657))
 - **FIX**: do not show interventions with empty titles. ([2a9abe76](https://github.com/hpi-studyu/studyu/commit/2a9abe764d245062548cff5a1a43251a9fc14a4f))
 - **FIX**: tasks cannot be completed multiple times via notifications + localization. ([d9974911](https://github.com/hpi-studyu/studyu/commit/d997491127016fed840a6b9b336db9b98583c051))
 - **FIX**: restructure notifications. ([e6627f5a](https://github.com/hpi-studyu/studyu/commit/e6627f5a4ae635465a1b805338b8b2f122704d03))
 - **FIX**: report screen null exceptions. ([38c59426](https://github.com/hpi-studyu/studyu/commit/38c5942626d042d6287fec8c5d603999c421193a))
 - **FIX**: keep alive question item states on scrolling. ([c27881f8](https://github.com/hpi-studyu/studyu/commit/c27881f8102f27a3200fc3e3ad7828ef1061edda))
 - **FIX**: tasks could be accessed outside of their completion times. ([d6fcd920](https://github.com/hpi-studyu/studyu/commit/d6fcd920af2f14ed57235111b7382f736cffbb55))
 - **FIX**: task screen empty title null exception. ([f8527dd4](https://github.com/hpi-studyu/studyu/commit/f8527dd41f16ec16ec7d8c5a8f36eb7e15775f0b))
 - **FIX**: notification icon. ([523e6396](https://github.com/hpi-studyu/studyu/commit/523e6396d143962e50eaaccc91fd2fc0cc7adb44))
 - **FIX**: notification not being delivered, add notification body. ([ed8e440b](https://github.com/hpi-studyu/studyu/commit/ed8e440ba66e04e0c06e98b4e1c0770927855377))
 - **FIX**: Skip consentCheck if study doesn't have one. ([5675d92a](https://github.com/hpi-studyu/studyu/commit/5675d92af89849bf8fb22ee99bfcf5a61408b5a4))
 - **FIX**: Remove error message at performance section. ([6a5b5905](https://github.com/hpi-studyu/studyu/commit/6a5b5905bc2aa765e550c37225f111603b692aa1))
 - **FIX**: upgrade to flutter 3.7.0. ([2aa80015](https://github.com/hpi-studyu/studyu/commit/2aa80015a22161773649790edf2c38742809c45b))
 - **FIX**: refactor questionnaire widget for eligibility and related tasks. ([b9639bcc](https://github.com/hpi-studyu/studyu/commit/b9639bcce5607b975b592683dc0c5d9a552f3927))
 - **FIX**: upgrade deps. ([1b411140](https://github.com/hpi-studyu/studyu/commit/1b41114080e405c385c15b7beb8d140193656e6a))
 - **FIX**: lint errors. ([6007e46e](https://github.com/hpi-studyu/studyu/commit/6007e46e45c36e77932930ce94c634499d57a444))
 - **FEAT**: Upgrade notifications & deps. ([08be0c3a](https://github.com/hpi-studyu/studyu/commit/08be0c3ac3bcffabd9ad6b518cbc0e4067183424))
 - **FEAT**: - Results of tasks with multiple completion periods are now saved uniquely. ([bf9e2818](https://github.com/hpi-studyu/studyu/commit/bf9e2818b5dc88102f69a7e773b5f9ccea0e7c73))

## 2.0.0-dev.0

> Note: This release has breaking changes.

 - **FIX**: null and reload error. ([b2f11da8](https://github.com/hpi-studyu/studyu/commit/b2f11da888e2579e2f363d53a60639b44a01291f))
 - **FIX**: Ability to delete studies with access code. ([2e965703](https://github.com/hpi-studyu/studyu/commit/2e9657033fcfd022642a963b6d496170bb9529e5))
 - **FIX**: load study subject if exists. ([d9202bf2](https://github.com/hpi-studyu/studyu/commit/d9202bf2274e9acc84b64076ad17738ef6afd8f6))
 - **FIX**: reload bug @ survey preview. ([1baa3462](https://github.com/hpi-studyu/studyu/commit/1baa34620b572802ca6eecca4ff254f8bca360ad))
 - **FIX**: leave study with soft delete & delete data option with hard delete. ([8006f0f6](https://github.com/hpi-studyu/studyu/commit/8006f0f6c9a63eb6ede1b9b25f8dc77b1fef7616))
 - **FIX**: skip eligibility screener correctly. ([4bf95db4](https://github.com/hpi-studyu/studyu/commit/4bf95db41fbc85b5513803d55574b946e08ea2b0))
 - **FIX**: correctly position annotations / labels for scale questions. ([acfa3524](https://github.com/hpi-studyu/studyu/commit/acfa3524fcc7e9c2f5237398e271b9390fe6e1e1))
 - **FIX**: refactoring. ([e5bf8ccb](https://github.com/hpi-studyu/studyu/commit/e5bf8ccb207026031bcde1e53b07f8f6f7112001))
 - **FIX**: enable banner again. ([1084274e](https://github.com/hpi-studyu/studyu/commit/1084274e9bcd4f05f9d6ee17ba12d42fe5295d80))
 - **FIX**: measurement preview bug, refactoring. ([10935ef6](https://github.com/hpi-studyu/studyu/commit/10935ef696ca9a4b09d1468ed15ed3cac28e1983))
 - **FIX**: upgrade deps. ([4b011445](https://github.com/hpi-studyu/studyu/commit/4b011445bb2390570c536646bb119b5a00a809ab))
 - **FIX**: order if interventions == 2. ([c0e46fa8](https://github.com/hpi-studyu/studyu/commit/c0e46fa8b4d1dbeb55eb55f93d18ecb605f2aa2a))
 - **FIX**: refactor improvements and bugfixes. ([3c7d84fc](https://github.com/hpi-studyu/studyu/commit/3c7d84fc70be852c52516ac173b33812076f5992))
 - **FIX**: working with updated changes. ([844528ef](https://github.com/hpi-studyu/studyu/commit/844528ef77ac338ad4b584d8ad1e627d02f61bbd))
 - **FIX**: lint errors. ([6007e46e](https://github.com/hpi-studyu/studyu/commit/6007e46e45c36e77932930ce94c634499d57a444))
 - **FIX**: observation/intervention preview. ([f24dcfdc](https://github.com/hpi-studyu/studyu/commit/f24dcfdcb3b62eb0fa4ec06ea0b2b1a891ed679d))
 - **FIX**: new intervention handling. ([250c8c14](https://github.com/hpi-studyu/studyu/commit/250c8c140f5b1040f1b713a7cb5860f48cd1c8ea))
 - **FIX**: Add missing functions and policy. ([4e84d95f](https://github.com/hpi-studyu/studyu/commit/4e84d95ff35fffca1d440abfb8bfc84e598b54e1))
 - **FIX**: refactor skipping and add preview class. ([afe11d88](https://github.com/hpi-studyu/studyu/commit/afe11d88aeaf784637b95ecf06fd2ef06e92ccad))
 - **FIX**: improve skipping days. ([479c669e](https://github.com/hpi-studyu/studyu/commit/479c669ec1ad3ebd8b1c573dd2254a8aa24f68f6))
 - **FIX**: intervention and observation. ([738e3e87](https://github.com/hpi-studyu/studyu/commit/738e3e87f6a81a3bd9c4e2fd2b56832e9976405e))
 - **FEAT**: dont record participant progress for launched studies in test mode. ([2dc6a8ca](https://github.com/hpi-studyu/studyu/commit/2dc6a8ca72785d8929b3ecf3451d352c893fabde))
 - **FEAT**: wip send study to app. ([18949295](https://github.com/hpi-studyu/studyu/commit/18949295e7f494f0b2cf36203dad1499ba338c7b))
 - **FEAT**: live preview. ([5ac4aac8](https://github.com/hpi-studyu/studyu/commit/5ac4aac8878f0dc58dffae56e566be1c2e3ad999))
 - **FEAT**: test selective preview screens. ([df26f6f3](https://github.com/hpi-studyu/studyu/commit/df26f6f3374d9d3e5f68bc653a928cfe9f82e167))
 - **FEAT**: add scale question-type to app + improved annotation layout. ([169ef10d](https://github.com/hpi-studyu/studyu/commit/169ef10d145a0b4e9da104af9fd22817b1c14d82))
 - **FEAT**: add selective preview for eligibility check. ([af96450f](https://github.com/hpi-studyu/studyu/commit/af96450f0d98afd719acc1bce09b9148dc924123))
 - **FEAT**: add selective preview for consent. ([382f6272](https://github.com/hpi-studyu/studyu/commit/382f62723d64d7b02a95971171856779cd8636c1))
 - **FEAT**: add selective preview for eligibility check. ([3fdb98c8](https://github.com/hpi-studyu/studyu/commit/3fdb98c894bec9f32c6f37820b9b2216ff0e69a3))
 - **FEAT**: improve scale widget in app. ([1d2652aa](https://github.com/hpi-studyu/studyu/commit/1d2652aa5e3fd1d7dcc929ebf7f69b004b5f3147))
 - **FEAT**: deeplink studyID to app to test study. ([3e363c48](https://github.com/hpi-studyu/studyu/commit/3e363c4886f674f93065a4f68ff66e21f9eca271))
 - **FEAT**: decouple preview app state from live app. ([82b0e3c4](https://github.com/hpi-studyu/studyu/commit/82b0e3c4b0dfe9d957a11563546fbb3ae328731e))
 - **FEAT**: move all selectedStudyObjectId to preview. ([e62f589b](https://github.com/hpi-studyu/studyu/commit/e62f589be7db31479e815ec3ea93bda0be717a00))
 - **FEAT**: colored scale questions. ([305377d3](https://github.com/hpi-studyu/studyu/commit/305377d38d59f42c7d310a58b2b1b61cf85922c2))
 - **FEAT**: add cmd again. ([b5524b96](https://github.com/hpi-studyu/studyu/commit/b5524b96136c1709e78d34ec22069e8abbb2925e))
 - **FEAT**: reset selectedStudyObjectId and reset cmd. ([ccf530b8](https://github.com/hpi-studyu/studyu/commit/ccf530b8e96da4a009d5a6a289f63fa3af587bfd))
 - **FEAT**: move selectedStudyObjectId back to preview. ([21062f47](https://github.com/hpi-studyu/studyu/commit/21062f47fe225d2999ee53b702ba8e805e5d00d2))
 - **FEAT**: add try catch and move selectedStudyObjectId out of preview. ([ece76329](https://github.com/hpi-studyu/studyu/commit/ece763291cec80db373cb198293bc960e0b85b65))
 - **FEAT**: reset fix. ([1a038873](https://github.com/hpi-studyu/studyu/commit/1a038873d8ba6bf8dfb73589c77b8f2b1c60a14b))
 - **FEAT**: finish preview refactoring. ([30f431ff](https://github.com/hpi-studyu/studyu/commit/30f431ff2e6ed67943114852ab50fc78a12595f3))
 - **FEAT**: auth and cmds to preview class. ([a0c1ede5](https://github.com/hpi-studyu/studyu/commit/a0c1ede53493dd944c70144a76d674ffb467bcb0))
 - **FEAT**: make use of preview class. ([477ced8b](https://github.com/hpi-studyu/studyu/commit/477ced8b5ccfb0a6b964ec3df47e8e822ae8c327))
 - **FEAT**: modify selectedStudyObjectId. ([af979983](https://github.com/hpi-studyu/studyu/commit/af9799838640e14ed24925a8dfec1667211a0a73))
 - **FEAT**: add skipping again. ([2ca6a2f3](https://github.com/hpi-studyu/studyu/commit/2ca6a2f3d40d0bcabad861cc58f74f14c7663c16))
 - **FEAT**: improve validation, copy, etc for study design & test mode. ([3b7fe99e](https://github.com/hpi-studyu/studyu/commit/3b7fe99e2847a169124a7ad0303cf8c2bc010ce0))
 - **FEAT**: finish german localization. ([86ef9a7a](https://github.com/hpi-studyu/studyu/commit/86ef9a7abafd30a7992df3962e29508997991126))
 - **FEAT**: allow skipping days in preview mode. ([ef2f19c1](https://github.com/hpi-studyu/studyu/commit/ef2f19c11f12a9a9171e20afb561b1222f09c13a))
 - **FEAT**: add reset functionality to preview. ([cfe76a8a](https://github.com/hpi-studyu/studyu/commit/cfe76a8a6d96111495fde976f132165006c5bbd1))
 - **FEAT**: test app changes. ([8e5c598b](https://github.com/hpi-studyu/studyu/commit/8e5c598b7241ea23166286cf37c6f2d477c75d04))
 - **FEAT**: merge dev_designer-v2. ([d4aae759](https://github.com/hpi-studyu/studyu/commit/d4aae759dded62dbe70657a8a528683c54c4a0dc))
 - **BREAKING** **CHANGE**: Database changes, so that only studies which are both published and open can be viewed. ([f8e85013](https://github.com/hpi-studyu/studyu/commit/f8e85013a23dd0450ce75e97fa0d751c6d4af055))

## 1.10.21

 - **FIX**: upgrade deps. ([d221eae7](https://github.com/hpi-studyu/studyu/commit/d221eae7ea55fa8761d7ff7625f92eaa3488148e))

## 1.10.20

 - **FIX**: upgrade dependencies. ([bc8cda17](https://github.com/hpi-studyu/studyu/commit/bc8cda17561511d8ec05ce13bc9fcba644768ef5))

## 1.10.19

 - **FIX**: upgrade deps. ([c16d7722](https://github.com/hpi-studyu/studyu/commit/c16d7722719efa732392d0f04bf74f4eefd95406))

## 1.10.18

 - Update a dependency to the latest release.

## 1.10.17

 - **FIX**: fix jmespath vulnerability issue. ([182e67a9](https://github.com/hpi-studyu/studyu/commit/182e67a92c148e47a3a3f2e40a7e6763499aeeb6))

## 1.10.16

 - **FIX**: upgrade deps. ([18dc5206](https://github.com/hpi-studyu/studyu/commit/18dc5206aff15093338a3973ef4196ea9d78d922))

## 1.10.15

 - **FIX**: upgrade deps. ([dca763c6](https://github.com/hpi-studyu/studyu/commit/dca763c6f5531c725148bb99e25c2a2debdeadd6))

## 1.10.14

 - **FIX**: upgrade deps. ([d14c52dd](https://github.com/hpi-studyu/studyu/commit/d14c52dd492bb2e6ceed941a2d33a053276629f4))
 - **FIX**: Use new flutter_common. ([0c9919e4](https://github.com/hpi-studyu/studyu/commit/0c9919e46ad8936a88950ac275c7759705124bf9))

## 1.10.13

 - **FIX**: Use new flutter_common. ([0c9919e4](https://github.com/hpi-studyu/studyu/commit/0c9919e46ad8936a88950ac275c7759705124bf9))
 - **FIX**: Use new studyu package versions. ([cfc65599](https://github.com/hpi-studyu/studyu/commit/cfc65599bca7a28490321c7731bc6e8de4cc1e0a))
 - **FIX**: Adjust to breaking dependencies. ([2f4e14bc](https://github.com/hpi-studyu/studyu/commit/2f4e14bc0a5858f18a2883a7ce3ea38e30a2b8fe))

## 1.10.12

 - **FIX**: Use API 30 required queries for opening links and sending emails. ([9aef6585](https://github.com/hpi-studyu/studyu/commit/9aef6585c9ff8cf04196d30f525dd732d14c46b4))

## 1.10.11

 - **FIX**: Upgrade dependencies. ([31ca516b](https://github.com/hpi-studyu/studyu/commit/31ca516be6518de7a41f4762b669f9059c83f3bc))

## 1.10.10

 - **FIX**: Set android targetSdk to latest stable API. ([0e875048](https://github.com/hpi-studyu/studyu/commit/0e875048e904c639be0bfb39d2b9fd2c50e8b52e))
 - **FIX**: Fix automatic multidex not working in IntelliJ. ([4b2cd481](https://github.com/hpi-studyu/studyu/commit/4b2cd4817a06851d5610fb7e0bd6b489851ae399))
 - **FIX**: Fix linting and fix lints. ([765b3525](https://github.com/hpi-studyu/studyu/commit/765b3525c89255bbf983a825bedc45a5ef7d8706))
 - **FIX**: Add new requirements for mulitdex support. ([6fb88196](https://github.com/hpi-studyu/studyu/commit/6fb8819690452c5cb077c7bcb7dbe56d0fd4fa34))
 - **FIX**: Upgrade flutter packages. ([d5d0387a](https://github.com/hpi-studyu/studyu/commit/d5d0387a9a7df464861070be44a9931d2ebb0547))
 - **FIX**: Upgrade android sdk, gradle, kotlin. ([e4886d03](https://github.com/hpi-studyu/studyu/commit/e4886d03c82eb087b275a26f161edc4d85318683))
 - **FIX**: Upgrade deps. ([27f6e8bc](https://github.com/hpi-studyu/studyu/commit/27f6e8bc4526b14320d6d1ca3657db55db2e7c5c))

## 1.10.9

 - **FIX**: Needed upgrade of core, fixes bug in generated files. ([44483b73](https://github.com/hpi-studyu/studyu/commit/44483b733ab53e34456b5b4bcf041c2bee3fc628))

## 1.10.8

 - **FIX**: Upgrade studyu deps. ([c9445358](https://github.com/hpi-studyu/studyu/commit/c9445358d10e0ef72595e7561d153e3f5ebddcfb))
 - **FIX**: Upgrade dependencies. ([f59a9989](https://github.com/hpi-studyu/studyu/commit/f59a9989be6238576a20f5288951745345ec84af))

## 1.10.7

 - **FIX**: Add more german translation.

## 1.10.6

 - **FIX**: Adapt to flutter deprecations.
 - **FIX**: Flutter beta deprecations.
 - **CHORE**: publish packages.

## 1.10.4

 - **FIX**: Upgrade studyu deps.

## 1.10.3

 - **REFACTOR**: Import symbols from supabase package.
 - **FIX**: Fix try out study.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade gradle and kotlin.
 - **CHORE**: publish packages.

## 1.10.2

 - **FIX**: Upgrade flutter_common.

## 1.10.1

 - **FIX**: Upgrade core.

## 1.10.0

 - **FEAT**: Use supabase_flutter for auth and instance.

## 1.9.5

 - **FIX**: Update flutter_common to fix signUp.
 - **FIX**: Use favicon.ico instead of .png.
 - **FIX**: Android 12 support.
 - **FIX**: Upgrade StudyU deps.
 - **FIX**: Upgrade studyu_core.
 - **FIX**: Correct column snail case naming.
 - **FIX**: Upgrade studyu deps.
 - **CHORE**: Add web page settings.
 - **CHORE**: Regen gitignore and metadata.
 - **CHORE**: Cleanup.
 - **CHORE**: Update web files and set icon.
 - **CHORE**: Regenerate android files.
 - **CHORE**: Upgrade gradle and android sdk to 31.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade studyu_core.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps; Generate json_serializable.
 - **CHORE**: Use pub.dev hosted version of core and common.
 - **CHORE**: Upgrade bundle fastlane.

## 1.9.4

 - Update a dependency to the latest release.

## 1.9.3

 - **FIX**: Skip eligibilty screen if not defined.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 1.9.2

 - **REFACTOR**: Table columns now have underscores.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 1.9.1

 - Update a dependency to the latest release.

## 1.9.0

 - **FIX**: Fail on joining by invite w/o preselectedIds.
 - **FEAT**: Research can test draft studies.
 - **CHORE**: Clean up.

## 1.8.0

 - **FEAT**: Add Version, Licenses info dialog.
 - **CI**: fastlane iOS: Readd timeout to create_keychain.
 - **CI**: iOS fastlane: Remove possibly failing params.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 1.7.0

 - **FIX**: Adapt app to new task schedule model.
 - **FEAT**: Lock task outside of completion period.
 - **CI**: Upgrade fastlane.
 - **CHORE**: Adapt to flutter 2.3 release.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 1.6.0

 - **FEAT**: Indicate days left in current intervention.
 - **CI**: Fix Fastlane iOS using temp keychain.
 - **CI**: Set match provisioning profile.
 - **CI**: Use fastlane match.
 - **CI**: Remove unneeded parameters.
 - **CI**: Add fastlane ios keychain creation.
 - **CI**: Add team to get_certs.
 - **CI**: ios fastlane add get certificats.
 - **CI**: Add fastlane get provisioning profiles step.
 - **CI**: Add ios fastlane setup.
 - **CI**: Correctly set fastlane play credentials.
 - **CI**: Set jsonkey data.
 - **CI**: Fix Gemfile.lock for Windows.
 - **CI**: Add fastlane for android app.
 - **CI**: Remove codemagic CI signing.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade studyu_packages.
 - **CHORE**: Add pub.dev release needed files.

## 1.5.2

 - **FIX**: Upgrade supabase -> Fix jwt expired.
 - **FIX**: Add close button to consent item.
 - **CHORE**: Upgrade studyu packages.

## 1.5.1

 - **FIX**: Hide report section until study is finished.
 - **FIX**: Retry fetching subjects if JWT is expired.
 - **CI**: Add gradle files for codemagic.
 - **CHORE**: Upgrade studyu packages.

## 1.5.0

 - **TEST**: Fix tests.
 - **STYLE**: Fix lint.
 - **STYLE**: Address lints.
 - **REFACTOR**: Generate startDate on server.
 - **REFACTOR**: Move UserQueries to common.
 - **REFACTOR**: Rename studyou_core -> studyu_core.
 - **REFACTOR**: Rename numberOfPhases => numberOfInterventions.
 - **REFACTOR**: Rename var.
 - **REFACTOR**: Add isBaseline to Intervention.
 - **REFACTOR**: Rename var.
 - **REFACTOR**: Load env from common.
 - **REFACTOR**: Core only uses dart; added flutter common.
 - **REFACTOR**: Rename StudySubject variables to subject.
 - **REFACTOR**: Remove unneeded result properties.
 - **REFACTOR**: Save results in separate table.
 - **REFACTOR**: Rename UserStudy -> StudySubject.
 - **REFACTOR**: Pass interventionIds.
 - **REFACTOR**: Replace InterventionSet with List<Intervention>.
 - **REFACTOR**: Only save selectedInterventions in DB.
 - **REFACTOR**: Embed Study in userStudy.
 - **REFACTOR**: Add json_serializable to tables.
 - **REFACTOR**: Migrate to null-safety.
 - **REFACTOR**: Prepare for null-safety.
 - **REFACTOR**: Make more methods static.
 - **REFACTOR**: Rename StudyUConfig->AppConfig.
 - **REFACTOR**: Further improvements to SupabaseObjects.
 - **REFACTOR**: Time->ScheduleTime for less collisions.
 - **REFACTOR**: Reorg core library.
 - **REFACTOR**: Improve Supabase objects.
 - **REFACTOR**: Restructure package.
 - **REFACTOR**: Migrate Parse to Supabase.
 - **REFACTOR**: Move ParseConfig queries to core.
 - **REFACTOR**: Add more typing to routing.
 - **REFACTOR**: Setup generated i18n.
 - **REFACTOR**: Cleanup app language.
 - **REFACTOR**: Use new generated localizations class.
 - **REFACTOR**: Clean up code.
 - **REFACTOR**: Replace deprecated buttons with new ones.
 - **REFACTOR**: Adapt to merging of study and details.
 - **REFACTOR**: Rename _evaluateResponse -> _addQuestionnaireResponse.
 - **REFACTOR**: Do not use .then here.
 - **REFACTOR**: Add support for gen. localizations.
 - **REFACTOR**: Change StudyQueries to dart extensions.
 - **REFACTOR**: Move StudyQueries to model class.
 - **REFACTOR**: Remove unused QuestionWidgetModel.
 - **FIX**: Fix compatibility with newest beta.
 - **FIX**: Initialize notifications before scheduling.
 - **FIX**: Remove unneeded shrinkWrap.
 - **FIX**: Fix for CI.
 - **FIX**: Make recovering session more robust.
 - **FIX**: Don't call constructor to call extension.
 - **FIX**: Only fetch keys required for study selection.
 - **FIX**: Upgrade packages to beta channel.
 - **FIX**: Reset invite code and preselected IDs.
 - **FIX**: Scaffold.of deprecated.
 - **FIX**: Use relative path to package.
 - **FIX**: spelling.
 - **FIX**: Disable notifications on web.
 - **FIX**: Masterkey needed to create a user.
 - **FIX**: Improve UI of questionnaires.
 - **FIX**: Future retry button not reloading.
 - **FIX**: Add retry for creating subject.
 - **FIX**: Add language options for ios.
 - **FIX**: onSelectNotification expects Future.
 - **FIX**: Don't color border.
 - **FIX**: Use dart conform names.
 - **FIX**: Fix contact not displaying correctly.
 - **FIX**: Do not call notifications for web.
 - **FIX**: Use clientKey instead of masterKey.
 - **FIX**: Make user login more robust.
 - **FIX**: Typo not kIsWeb.
 - **FIX**: Fix installation-id for back4app.
 - **FIX**: Multiple completion off same task.
 - **FEAT**: Restructure contact screen.
 - **FEAT**: Add IRB contact field.
 - **FEAT**: Add FAQ and contact to Welcome page.
 - **FEAT**: Add FHIR Questionnaire Widget.
 - **FEAT**: Add project generator.
 - **FEAT**: Display support contact.
 - **FEAT**: Load preselectedIds from invite.
 - **FEAT**: Add header/footer to questionnaire.
 - **FEAT**: Add anonymous signup via fake email.
 - **FEAT**: Auto forward on kickoff screen.
 - **FEAT**: Add update repo study data.
 - **FEAT**: Add Complete button to Questionnaire.
 - **FEAT**: Add terms and privacy disclaimer to designer.
 - **FEAT**: Color Study publisher header.
 - **FEAT**: WelcomeScreen: Make Get Started more apparent.
 - **FEAT**: Replace User with locally generated UUID.
 - **FEAT**: Rework terms & privacy screen.
 - **FEAT**: Remove support/contact overview page.
 - **FEAT**: Add support for study invite code.
 - **FEAT**: Use fhir questionnaire with fallback.
 - **FEAT**: Implement conditional FHIR questions.
 - **FEAT**: Add FileSaveDialog + Gradle upgrade.
 - **FEAT**: Separate study publisher contact.
 - **FEAT**: Define generate localizations.
 - **CI**: Fix version bump by using single quote.
 - **CI**: Update dependencies workflow.
 - **CHORE**: Upgrade Parse to Null-safety.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Move packages to null-safety.
 - **CHORE**: Remove deps override.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade minor deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade lint to 1.5.3.
 - **CHORE**: Enable for core; remove avoid_as.
 - **CHORE**: Remove rule which is now part of lint.
 - **CHORE**: Upgrade deps.
 - **CHORE**: By default (codemagic) use test env.
 - **CHORE**: Remove debug skip to dashboard.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Add test back4app environment.
 - **CHORE**: Disable default parse debug msgs.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Rename packages + prefix with studyu.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade parse sdk.
 - **CHORE**: Upgrade deps mostly stable null-safety deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: v1.4.1.
 - **CHORE**: Setup .env files again.
 - **CHORE**: Use gotrue from git.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove unneeded notifications setup.
 - **CHORE**: Upgrade pdf to 2.0.0.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade supabase deps.
 - **CHORE**: v1.4.0.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade dependencies.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove unnecessary form.
 - **CHORE**: Upgrade deps.
 - **CHORE**: v1.2.0.
 - **CHORE**: Refactor according to pdf 1.3.0 deprecation.
 - **CHORE**: Remove unused import.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade gradle: 6.7.1, plugin: 4.1.1.
 - **CHORE**: v1.1.0.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Add mono_repo config.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove unneeded envs.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove unused packages.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Downgrade gradle for codemagic (Java 8).
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: fix formatting.
 - **CHORE**: Upgrade gradle.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove unneeded package.
 - **CHORE**: Upgrade ios project.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade parse sdk.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Downgrade parse to working commit.
 - **CHORE**: Update android files.
 - **CHORE**: Remove heroku envs.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove version +.
 - **CHORE**: Switch back to parse sdk repo.
 - **CHORE**: Upgrade packages.
 - **CHORE**: Upgrade dependencies.
 - **CHORE**: Set default .env file to back4App.
 - **CHORE**: Cleanup envs; Add back4app env.
 - **CHORE**: Minor deps upgrade.
 - **CHORE**: Minor version bump.
 - **CHORE**: Remove unneeded stuff.
 - **CHORE**: Remove cuptertino widgets import everywher.
 - **CHORE**: Add melos, tool for managing packages.
 - **CHORE**: Remove left over gitlab ci.
 - **CHORE**: Remove unused translations.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Downgrade gradle until fixed for flutter.
 - **CHORE**: Remove deprecated entry.
 - **CHORE**: Fix release signing.
 - **CHORE**: Remove mono_repo files.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Use health.studyu.app bundle ID.
 - **CHORE**: Check boxes in debug.
 - **CHORE**: Skip clicking all boxes in debug.
 - **CHORE**: Add release config.
 - **CHORE**: gitignore jks files.
 - **CHORE**: Upgrade gradle plugin.
 - **CHORE**: Cleanup json_annotation remains.


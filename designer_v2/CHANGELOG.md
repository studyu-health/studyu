## 1.19.0

 - **REFACTOR**(designer): introduce dashboardDispatch indirection.
 - **FIX**(designer): keep error notices on empty dashboard.
 - **FIX**(designer): remove flags from language picker.
 - **FIX**: migrate Riverpod analyzer plugin.
 - **FIX**: address localization review feedback.
 - **FIX**: remove obsolete analyzer plugins.
 - **FIX**: resolve analysis and web build failures.
 - **FIX**: close snackbar automatically.
 - **FIX**(l10n): complete Korean localization.
 - **FIX**(deps): update flutter and deps.
 - **FIX**(designer): center empty studies.
 - **FIX**(designer): cache QR preview future.
 - **FIX**(designer): dashboard pagination race, sort persistence, and scroll virtualization.
 - **FIX**(designer): refine QR dialog overlay.
 - **FIX**(designer): hide unchanged invite save.
 - **FIX**(designer): show QR copy feedback above modal.
 - **FIX**(designer): escape LIKE backslashes.
 - **FIX**(designer): prevent invite save flicker.
 - **FIX**(designer): drawer entries silently dropped clicks.
 - **FIX**(designer): refine invite code actions.
 - **FIX**: address pr review items - study shared link path, web landing page study link, ios deferred link host.
 - **FIX**(designer): refine invite dialog interactions.
 - **FIX**: remove deprecated material_design_icons_flutter dependency.
 - **FIX**(designer): improve invite table layout.
 - **FIX**(designer): tune invite pagination.
 - **FIX**(designer): stop invite search flicker.
 - **FIX**(designer): stabilize login footer.
 - **FIX**(designer): close model event streams.
 - **FIX**: center empty studies widget.
 - **FIX**(designer): keep dashboard rows during refresh.
 - **FIX**(designer): fix studies list display.
 - **FIX**(designer): constrain dashboard height.
 - **FIX**(designer): bound invite repository cache.
 - **FIX**(designer): align auth prompt actions.
 - **FIX**(designer): refine auth inline prompt actions.
 - **FIX**(designer): polish auth form layout.
 - **FIX**(designer): use clearer language picker icon.
 - **FIX**(designer): decouple study repository interface.
 - **FIX**(designer): harden invite code flows.
 - **FIX**(designer): harden dashboard pagination.
 - **FIX**: clear CI analysis failures.
 - **FIX**(designer): remove dashboard drawer divider.
 - **FIX**: address review feedback.
 - **FIX**(designer): refresh preview on locale change.
 - **FIX**(designer): dispose preview message listener.
 - **FIX**(designer): remove unusable preview tab action.
 - **FIX**(designer): trim delete confirmation title input.
 - **FIX**(designer): fix filter helper dependencies.
 - **FIX**(designer): isolate advanced filter preview count by tab.
 - **FIX**(designer): make dashboard state testable on vm.
 - **FIX**(app): resolve questionnaire controller merge conflicts.
 - **FIX**(designer): resolve dashboard review issues.
 - **FIX**(designer): address invite review feedback.
 - **FIX**(app): remove Done button for non-last free text, clean up unused code.
 - **FIX**: resolve flutter analyze failure.
 - **FIX**(designer): delete study dependents first.
 - **FIX**(designer): harden dashboard header layout.
 - **FIX**(designer): restore invite code create and dismiss flow.
 - **FIX**(designer): refine invite code empty state copy.
 - **FIX**(designer): improve recruit mobile header layout.
 - **FIX**(designer): refine recruit header responsiveness.
 - **FIX**(designer): update invite code subtitle copy.
 - **FIX**(designer): handle empty invite code fetch.
 - **FIX**(designer): transmit preview studies outside urls.
 - **FIX**(designer): resolve recruit invite code test regressions.
 - **FIX**(designer): refine invite code recruit flow.
 - **FIX**(designer): polish invite page dropdown menu.
 - **FIX**(designer): resolve dashboard test lint warnings.
 - **FIX**(designer): make dashboard updates smoother.
 - **FIX**(designer): stabilize dashboard study actions.
 - **FIX**(designer): refine invite code table polish.
 - **FIX**(designer): remove invite row hover gap.
 - **FIX**(designer): update pinned study locally.
 - **FIX**(designer): hide study count while loading.
 - **FIX**(designer): preserve legacy free-text conditions.
 - **FIX**(designer): use signed free text threshold keyboard.
 - **FIX**(designer): make study mutations reliable.
 - **FIX**(designer): handle enum dashboard filters.
 - **FIX**(designer): remove invite timestamp drift.
 - **FIX**(designer): polish invite page size menu.
 - **FIX**(designer): refresh invite codes recruit ui.
 - **FIX**(designer): clarify required choice selection.
 - **FIX**(designer): style cycle dropdown.
 - **FIX**(designer): tighten cycle dropdown.
 - **FIX**(designer): avoid cycle dropdown overflow.
 - **FIX**(designer): use cycle count dropdown.
 - **FIX**(designer): handle study schedule number input.
 - **FIX**(designer): remove unsupported repository test.
 - **FIX**(designer): strengthen study deletion warning.
 - **FIX**(designer): widen choice question labels.
 - **FIX**(designer): secure participant study previews.
 - **FIX**(designer): strengthen study deletion flow.
 - **FIX**(designer): address dashboard pagination review issues.
 - **FIX**(designer): wait for survey save navigation.
 - **FIX**(designer): await nested form saves.
 - **FIX**(designer): stabilize autosave integration test.
 - **FIX**(designer): show sync status for new studies.
 - **FIX**(designer): keep questionnaire edits in local draft.
 - **FIX**(designer): intercept confirmation dialog pointer events.
 - **FIX**(designer): intercept preview pointer events in discard dialog.
 - **FIX**(designer): normalize custom study sequence input.
 - **FIX**(designer): stream live study updates to preview.
 - **FIX**(designer): keep live preview loaded while editing.
 - **FIX**(designer): preview unsaved test-ready studies.
 - **FIX**(designer): enable copying study names in confirmations.
 - **FIX**(designer): copy raw invite code.
 - **FIX**(designer): widen invite date columns.
 - **FIX**(designer): validate custom sequence conditionally.
 - **FIX**(designer): align invite table serial header.
 - **FIX**(designer): improve invite code table responsiveness.
 - **FIX**(designer): make invite code table responsive.
 - **FIX**(designer): refresh custom sequence validation.
 - **FIX**: add passkeys script to index.html for app & designer to support supabase_flutter v2.15.0.
 - **FIX**(designer): correct invite code pagination state.
 - **FIX**(designer): support free-text length conditions.
 - **FIX**(designer): restore invite code search pagination.
 - **FIX**(designer): allow signed free-text thresholds.
 - **FIX**(designer): correct dashboard study totals.
 - **FIX**(designer): localize dashboard count and copy.
 - **FIX**(designer): refine dashboard header responsiveness.
 - **FIX**(designer): preserve free text conditional semantics.
 - **FIX**(app): update deep link routes from studyShared to study.
 - **FIX**(designer): make preview panes responsive.
 - **FIX**: address code review findings across app, core, and designer.
 - **FIX**(designer): align discard confirmation actions.
 - **FEAT**(designer): add invite code table sorting.
 - **FEAT**(designer): support invite code enrolled sorting.
 - **FEAT**(designer): add invite code filters.
 - **FEAT**: Introduce QR code generation and deep link sharing for study invite codes, supported by new environment variables and localization.
 - **FEAT**(app): support required choice selections.
 - **FEAT**(designer): improve invite code sharing actions.
 - **FEAT**(designer): add korean localization.
 - **FEAT**(localization): synchronize app language with server and improve locale handling.
 - **FEAT**(recruit): improve invite sharing.
 - **FEAT**(designer): improve invite code pagination controls.
 - **FEAT**(dashboard): enhance pagination and localization for dashboard features.
 - **FEAT**(designer): add QR link copy field.
 - **FEAT**(designer): improve QR code dialog.
 - **FEAT**(designer): improve QR copy feedback.
 - **FEAT**(designer): show invite code in QR dialog.
 - **FEAT**(designer): server-side pagination for studies dashboard.
 - **FEAT**(app): add invite QR flow.
 - **FEAT**(designer): translate dashboard filters to PostgREST.
 - **FEAT**: update public recruitment messaging and localization.
 - **FEAT**: add recruitment share links for public studies.
 - **FEAT**: refactor deep link generation for invite codes.
 - **FEAT**(designer): enhance invite code sidebar.
 - **FEAT**: rework recruitment share options.
 - **FEAT**: rework invite code sharing menu.
 - **FEAT**(invite-codes): make invite codes case-insensitive and space-trimmed.
 - **FEAT**: Update deep link handling and environment configuration for Android and iOS.
 - **FEAT**(designer): improve invite code table behavior.

## 1.18.0

 - **REFACTOR**: clean up date question localization and validation messages.
 - **FIX**(designer): enlarge test preview frame.
 - **FIX**(designer): disable screener without questions.
 - **FIX**(app): open preview on study overview.
 - **FIX**(designer): revert unintended app controller change.
 - **FIX**(designer): restore default search bar background.
 - **FIX**(designer): resolve splash screen initialization loop.
 - **FIX**(dashboard): restore localized search placeholder.
 - **FIX**(designer): use outer context for popup actions.
 - **FIX**(designer): defer popup menu action execution.
 - **FIX**(designer): remove default confirmation icons.
 - **FIX**(designer): resolve confirmation merge conflicts.
 - **FIX**(designer): centralize destructive action confirmations.
 - **FIX**(designer): style actions in destructive confirmation dialog.
 - **FIX**(designer): update unsaved changes dialog copy and button weights.
 - **FIX**(designer): centralize destructive action confirmations.
 - **FIX**(designer): handle recruit popup menu delete action.
 - **FIX**: upgrade deps.
 - **FIX**: upgrade deps.
 - **FIX**: remove deprecated material_design_icons_flutter dependency.
 - **FIX**(preview): avoid reloading test app page navigation.
 - **FEAT**(designer): localize hardcoded preview overlay strings.
 - **FEAT**: Add onCleared callback to DateQuestionWidget and QuestionContainer.
 - **FEAT**: Refactor preview iframe style injection and cleanup logic.
 - **FEAT**: Enhance Date Question Functionality with Time Input and Localization.
 - **FEAT**: simplify date question form by removing unused preview section and related logic.
 - **FEAT**: update date label translations for clarity in German and English.
 - **FEAT**: remove initial date handling from date question components.
 - **FEAT**: add localization for date format preset labels in English and German.
 - **FEAT**: implement date range validation and localization for date questions.
 - **FEAT**: add DateQuestion and DateQuestionWidget for date selection in questionnaires.

## 1.17.0

 - **REFACTOR**(questionnaire): improve free text question handling and remove custom error message support.
 - **FIX**: upgrade deps.
 - **FIX**(measurements): persist new survey questions.
 - **FIX**(designer): preserve form dirty guards.
 - **FIX**(designer): intervention task dismissable warning works.
 - **FIX**(designer): duplicate unsaved survey questions.
 - **FIX**: update free text validation messages and regex handling.
 - **FIX**: align dependencies for Flutter 3.44.
 - **FIX**: add missing const constructors to satisfy linter.
 - **FIX**: migrate to flutter_material_design_icons in favor of deprecated material_design_icons_flutter.
 - **FIX**: upgrade deps.
 - **FIX**: update Flutter version to 3.44.0 and clean up unused imports.
 - **FIX**: remove redundant fitbit label.
 - **FEAT**: make barrier dismissable with warning check.
 - **FEAT**: Add custom error message support for free text questions.
 - **FEAT**: add custom free text validation and localization support.
 - **FEAT**(test): add stable ValueKeys for MCP automation.
 - **FEAT**(designer): move fitbit credentials into measurement question editor.

## 1.16.0

 - **REFACTOR**: fix and format.
 - **REFACTOR**: Update widget constructors to use `super.key` and refine filter UI constants and German localization.
 - **REFACTOR**: remove "Clear all" filter option from dashboard studies filter.
 - **REFACTOR**: filter_builder smaller.
 - **REFACTOR**: Add new filter widgets for enum, boolean, number, text, and date range types for dashboard studies, and update the filter builder to utilize them.
 - **FIX**: migrate csv.
 - **FIX**: update to flutter v3.41.5.
 - **FIX**: resolve hash conflict in dashboardControllerHash.
 - **FIX**: filter out exportDefinition action from available study actions.
 - **FIX**: cast error value to Object for validation message function.
 - **FIX**: Center studies table content and headers, adjust column sizing, and add DevTools options file.
 - **FIX**: upgrade to flutter v3.38.4.
 - **FIX**: Introduce comparator utility for symbol display and enhance filter chip labels and conditional form options.
 - **FIX**: filter translation.
 - **FIX**: preset highlighting bug.
 - **FIX**: make `setStudiesFilter` asynchronous and fetch user data.
 - **FIX**: improve dashboard responsiveness by adapting UI elements to screen sizes and add a DevTools options file.
 - **FEAT**: Implement study definition export as JSON and add null check for study import.
 - **FEAT**: Implement study import functionality, include study definition in export, and add customizable row spacing to form layouts.
 - **FEAT**: localize dashboard filter UI, preset management, and related enum labels.
 - **FEAT**: Track expanded filter fields in controller and enhance selected preset UI in filter builder.
 - **FEAT**: add active state highlighting to filter presets, update filter action button labels and icons, and remove filter match count display.
 - **FEAT**: Add 6px horizontal spacing to the filter builder UI.
 - **FEAT**: Add persistent user-defined study filters and active filter state to user preferences.
 - **FEAT**: Initialize filter builder's active preset from dashboard state or by matching saved filters.
 - **FEAT**: Overhaul dashboard filter UI with auto-apply on close, enhanced preset management, and expandable filter sections.
 - **FEAT**: Add dashboard filter presets and a unified filter menu, replacing old filter view components.
 - **FEAT**: Implement dynamic and hierarchical study filtering on the dashboard, including UI, data models, and evaluation logic.

## 1.15.5

 - **FIX**: update balanced description in study schedule translations and upgrade dependencies.

## 1.15.4

 - **FIX**: update balanced description in study schedule translations.

## 1.15.3

 - **REFACTOR**(designer_v2): centralize AsyncValue study state access.
 - **FIX**(designer_v2): simplify AsyncValue state transitions.
 - **FIX**(designer_v2): remove copyWithPrevious usage for Riverpod 3.x compatibility.
 - **FIX**(designer_v2): update code for Riverpod 3.x compatibility.
 - **FIX**: study length calculation and update localization for study schedule.

## 1.15.2

 - **PERF**: Improve update performance using debouncer.
 - **FIX**: add conditional property to question form data and controller.
 - **FIX**: filter out non-dependable question types from available questions.
 - **FIX**: update conditional form titles to use localized strings.
 - **FIX**: filter out ignored question types from available questions.
 - **FIX**: update form control copying logic to handle Choice type values.

## 1.15.1

 - Update a dependency to the latest release.

## 1.15.0

 - **REFACTOR**: ref error in app_drawer.
 - **REFACTOR**: remove debug print statement from model fetching.
 - **REFACTOR**: remove double fetching of study.
 - **REFACTOR**: comment out watchAllChanges method in model_repository.
 - **REFACTOR**: comment out duplicateAndSaveFromRemote method in model_repository.
 - **FIX**: update Supabase configuration and remove debug print statements from model repository.
 - **FIX**: add model refresh mechanism to study repository instead of removing the model.
 - **FIX**: after study cloning redirect to clone directly".
 - **FIX**: optimize user fetching to prevent duplicate user requests.
 - **FIX**: add reports form data application in study copy.
 - **FIX**: implement model removal from cache to fetch complete study when coming from dashboard.
 - **FIX**: enable dashboard display for fetched user studies.
 - **FIX**: cancel study subscription on dispose.
 - **FEAT**: improve version display logic and display on auth pages.

## 1.14.0

 - **REFACTOR**: print empty version instead of null.
 - **FIX**: refactor clamping logic for free text length inputs to use final variables.
 - **FIX**: enhance free text length input handling with clamped values and improved layout.
 - **FIX**: free_text_question could not be added.
 - **FIX**: Increase max length for free text input to 1000.
 - **FIX**: update question response formatting to return structured choice data.
 - **FIX**: enhance question response formatting to include choice text.
 - **FEAT**: add version to designer.

## 1.13.0

 - **FIX**: after study cloning redirect to clone directly.
 - **FIX**: after study cloning show my studies as active in app drawer.
 - **FIX**: update validators for boolean questions in conditional forms.
 - **FIX**: simplify conditional check for boolean values in question forms.
 - **FIX**: prevent reordering of questions in readonly forms.
 - **FIX**: remove redundant deferred conditions initialization check.
 - **FIX**: fix study data loss on study duplication with dashboard.
 - **FIX**: disable reorder action for readonly forms.
 - **FIX**: disable delete action for readonly condition forms.
 - **FIX**: solves [#737](https://github.com/hpi-studyu/studyu/issues/737).
 - **FEAT**: implement deferred conditions initialization in question forms.

## 1.12.1

 - **REFACTOR**: simplify enrollment type input structure in enrollment form.

## 1.12.0

 - **REFACTOR**: incorrect use of static final with lambda function.
 - **REFACTOR**: add localization support for Fitbit data sync messages and improve code formatting.
 - **REFACTOR**: improve code formatting and readability in localization and conditional question files.
 - **REFACTOR**: propagate form mode to condition view models for consistent state management.
 - **REFACTOR**: introduce LiveConditionPreview component for enhanced condition visualization.
 - **REFACTOR**: update answer options type in question form controller.
 - **REFACTOR**: simplify condition handling by updating types and improving view model integration.
 - **REFACTOR**: enhance conditional question handling with FormViewModelCollection.
 - **REFACTOR**: implement ConditionalQuestionFormViewModel.
 - **REFACTOR**: improve code formatting and readability in body-related files.
 - **REFACTOR**: rename core FitbitCredentials to FitbitAuthCredentials.
 - **FIX**: update if logictype changes.
 - **FIX**: migrate enrollment form view to use RadioGroup for better control handling and readability.
 - **FIX**: refactor auth form controller to streamline form control access methods.
 - **FIX**: enhance condition handling and value propagation in questionnaire forms.
 - **FIX**: refactor auth form controller to use getter methods for form controls and improve form handling.
 - **FIX**: update section title and description rendering logic to handle empty states.
 - **FIX**: specify type for conditionsArray and simplify expression building.
 - **FIX**: handle response option in answer construction correctly.
 - **FIX**: upgrade invite code form controller by adjusting debounce time and simplifying control initialization.
 - **FIX**: update conditional logic to use NumericComparator for better clarity.
 - **FIX**: pain question error on save.
 - **FIX**: update conditional question handling to use ConditionRowFormData.
 - **FIX**: add dynamic controls to form based on question type.
 - **FIX**: update question type checks to use constants for better maintainability.
 - **FIX**: update dependencies and versions in pubspec.yaml and pubspec.lock.
 - **FIX**: upgrade package dependencies.
 - **FIX**: add conditional rendering for choice input fields for booleans.
 - **FIX**: preserve ids for choices.
 - **FIX**: scale condition.
 - **FIX**: duplicate add intervention button.
 - **FIX**: duplicate add intervention button.
 - **FIX**: tooltip no element bug.
 - **FIX**: translation and QoL fixes.
 - **FIX**: translation and QoL fixes.
 - **FIX**: static allQuestions default workaround.
 - **FIX**: extract boolean correctly.
 - **FIX**: refactor ConditionalQuestionFormView back to FormConsumerWidget.
 - **FIX**: ConditionalQuestionFormView use static allQuestions.
 - **FIX**: use a UUID for choices".
 - **FIX**: updateCondition correctly.
 - **FIX**: use a UUID for choices.
 - **FIX**: streams and dynamic cast bugs.
 - **FIX**: update conditionArray on changes correctly, only include latter questions.
 - **FIX**: warnings.
 - **FIX**: handle frame errors in study test frame.
 - **FIX**: rebuild form, enable preview, use currentQuestionId.
 - **FIX**: localization.
 - **FIX**: add fitbit question json type to question model.
 - **FIX**: platform localization.
 - **FIX**: form control for fitbit question.
 - **FIX**: fitbit question form.
 - **FIX**: update choice selection logic to use choice ID instead of text.
 - **FIX**: auto formatting of localization files.
 - **FIX**: require fitbit credentials if fitbit question is present.
 - **FIX**: prevent transient conditional logic state from affecting isDirty checks.
 - **FIX**: update deps.
 - **FEAT**: initial version for conditional questions.
 - **FEAT**: add descriptions for Fitbit question types in the designer.
 - **FEAT**: implement pain selection question inside designer.
 - **FEAT**: add form list view.
 - **FEAT**: fitbit credentials base for study model.
 - **FEAT**: add pain type and body part children support.
 - **FEAT**: fitbit questionnaire form.
 - **FEAT**: live preview update.
 - **FEAT**: update Fitbit credentials form and related dependencies.
 - **FEAT**: update Fitbit credentials form and AndroidManifest of app.
 - **FEAT**: fitbit_credentials table and integration.
 - **FEAT**(questionnaire): add validation for Fitbit question type.
 - **FEAT**: add validation for Fitbit credentials in forms.
 - **FEAT**(fitbit): update sleep data model and sleep fetch.
 - **FEAT**: add FitbitHandler.
 - **FEAT**: sleep and step data.
 - **FEAT**: check if credentials exists when adding fitbit question.
 - **FEAT**: update body pain response label to "Pain Tracker".
 - **FEAT**: update pain question icon to accessibility.
 - **FEAT**: update body pain response label to "Pain Tracker".
 - **FEAT**: replace FormArrayTables with FormListView only reorder if items > 1.
 - **DOCS**: fix FormConsumerWidget documentation.

## 1.11.1

- **FIX**: update deps.

## 1.11.0

- **FIX**: bump dependencies.
- **FIX**: study reset process by removing unnecessary user ID handling.
- **FIX**: Disable intervention selection if num of interventions <= 2.
- **FEAT**: enhance study reset functionality to support user-specific data deletion.
- **FEAT**: reset test preview on enter test page in designer.

## 1.10.0

- **REFACTOR**: analysis notes.
- **REFACTOR**: analysis notes.
- **REFACTOR**: incorrect use of static final with lambda function.
- **FIX**: upgrade deps.
- **FIX**: monitoring completed intervention task total calculation.
- **FIX**: add SelectionArea to all side sheets to fix flutter issue [#158095](https://github.com/hpi-studyu/studyu/issues/158095).
- **FIX**: replace Hyperlink with TextButton in choice_question_form_view.
- **FIX**: https://github.com/dart-lang/sdk/issues/60784.
- **FIX**: migrate code.
- **FIX**: only main deployment and github deployment depends on core + flutter_common packages.
- **FIX**: add core and flutter_common local path dependency.
- **FIX**: remove test report text and fix report description spacing.
- **FIX**: zip problems when exporting data and sanitization removal.
- **FIX**: auto formatting of localization files.
- **FIX**: platform localization.
- **FIX**: localization.
- **FEAT**: add Descriptive Stats section to the designer and core.
- **FEAT**: add gauge comparison section with form view.
- **FEAT**: add textual summary section to report with form view and validation.
- **FEAT**: Enhance password reset functionality with improved validation and notifications.
- **FEAT**: Implement password reset functionality in account settings.

## 1.10.0-dev.0

 - **REFACTOR**: rename core FitbitCredentials to FitbitAuthCredentials.
 - **REFACTOR**: incorrect use of static final with lambda function.
 - **FIX**: auto formatting of localization files.
 - **FIX**: platform localization.
 - **FIX**: localization.
 - **FIX**: fitbit question form.
 - **FIX**: form control for fitbit question.
 - **FIX**: add fitbit question json type to question model.
 - **FEAT**: update Fitbit credentials form and related dependencies.
 - **FEAT**: update Fitbit credentials form and AndroidManifest of app.
 - **FEAT**: fitbit_credentials table and integration.
 - **FEAT**(questionnaire): add validation for Fitbit question type.
 - **FEAT**: add validation for Fitbit credentials in forms.
 - **FEAT**(fitbit): update sleep data model and sleep fetch.
 - **FEAT**: add FitbitHandler.
 - **FEAT**: sleep and step data.
 - **FEAT**: check if credentials exists when adding fitbit question.
 - **FEAT**: fitbit questionnaire form.
 - **FEAT**: fitbit credentials base for study model.

## 1.9.4

 - **FIX**: linter.
 - **FIX**: ensure data source in report is copied during study duplication.

## 1.9.3

 - **FIX**: migrate code.
 - **FIX**: upgrade deps and flutter v3.24.5.

## 1.9.2

 - **FIX**: upgrade deps.
 - **FIX**: upgrade fvm to flutter v3.24.3.

## 1.9.1

 - **FIX**: upgrade to flutter v3.24.2.
 - **FIX**: hotfix to sanitize export contents.

## 1.9.0

 - **FIX**: legend spacing.
 - **FIX**: legend overflow.
 - **FIX**: translation.
 - **FIX**: overflow issues.
 - **FIX**: participant info max intervention and survey count.
 - **FIX**: intervention and observation wrong number in table.
 - **FIX**: sort arrow.
 - **FIX**: remove bar chart if no participant.
 - **FIX**: translation.
 - **FIX**: tooltip message.
 - **FIX**: remove min visibility.
 - **FIX**: style consistency for the close button, update style, and add translation.
 - **FIX**: add close button to launch success dialog (public study).
 - **FIX**: translation consistency.
 - **FIX**: remove add participant action button from publish success dialog for public studies.
 - **FIX**: reset invite codes if study gets published as public.
 - **FIX**: check for unique invite codes in designer.
 - **FIX**: upgrade deps.
 - **FIX**: enable atLeastOneTask for intervention again".
 - **FIX**: auto-save new study to prevent exception on intervention screen.
 - **FEAT**: fix translations.
 - **FEAT**: disable invite code creation for public studies.

## 1.8.3

 - **FIX**: upgrade deps.

## 1.8.2

 - **FIX**: upgrade deps.
 - **FIX**: added legend for participant activity tooltip.
 - **FIX**: monitor section header tooltip participants list display fix.
 - **FIX**: upgrade deps.

## 1.8.1

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.8.1-dev.3

 - **REFACTOR**: migrated auth_form_controller.dart to riverpod v2.
 - **REFACTOR**: migrate to riverpod code generation 2.
 - **REFACTOR**: update designer study data after test controller is disposed.
 - **REFACTOR**: migrate StudySettingsFormViewModel Provider.
 - **REFACTOR**: migrate appConfig FutureProvider.
 - **REFACTOR**: migrated dashboard_controller.dart to riverpod v2.
 - **REFACTOR**: migrate to riverpod code generation.
 - **PERF**: remove await for onSave.
 - **PERF**: replace read with watch.
 - **FIX**: test frame live preview.
 - **FIX**: keep eligibility criterion.
 - **FIX**: disable reactive for enrollment radio tile".
 - **FIX**: disable reactive for enrollment radio tile.
 - **FIX**: migrate iFrameElement.
 - **FIX**: Incorrect type casting occurs when an insufficient number of characters entered to password field on the registration page.
 - **FIX**: do not autosave on formarray".
 - **FIX**: do not autosave on formarray.
 - **FIX**: enable atLeastOneTask for intervention again.
 - **FIX**: delay fetching studyRepo.
 - **FIX**: type.
 - **FIX**: catch invite code not existing and better APIException output.
 - **FIX**: disable reactive for schedule intervention screen.
 - **FIX**: disable reactive for enrollment radio tile.
 - **FIX**: empty description init value.
 - **FIX**: migrate close study feature.
 - **FIX**: cannot use ref before provider rebuilt.
 - **FIX**: explicitly type formcontrol when adding multiple choice field.
 - **FIX**: dashbaord user load once.
 - **FIX**: study controller no longer extends study base controller due to riverpod v2.
 - **FIX**: initialization route and splash page.
 - **FIX**: merge dev fixes.
 - **FIX**: missing intervention and measurement data when study is being duplicated.
 - **FIX**: Flutter 3.22 arg error.
 - **FIX**: translate study schedule.
 - **FIX**: add closed success description.
 - **FIX**: only show close button for editors.
 - **FIX**: Login/register notifications (wrong password, etc.) are not showing.
 - **FIX**: potential isClosed error.
 - **FIX**: merge dashboard refactor pr.
 - **FIX**: add compatibility for emoji font with flutter >= 3.22.
 - **FIX**: upgrade deps.
 - **FIX**: let autosave not listen to formarray anymore.
 - **FIX**: check if canPop.
 - **FIX**: typo / grammar.
 - **FIX**: integration test sign out.
 - **FIX**: do not show separator if no delete item shown.
 - **FIX**: add emojis again.
 - **FEAT**: close study.
 - **FEAT**: fix duplicate and designer updates for study closing.
 - **FEAT**: small fixes for study closing.
 - **FEAT**: add separators to model action popup.
 - **FEAT**: deprecate published for study_status.
 - **FEAT**: study close button.
 - **FEAT**: new severe close confirmation.
 - **FEAT**: close study using is_closed column.
 - **DOCS**: add function documentation.

## 1.8.1-dev.2

 - **PERF**: added comments to the getUserStudies function.
 - **PERF**: improve dashboard study fetching.
 - **FIX**: add emojis again.
 - **FIX**: integration test sign out.
 - **FIX**: check if canPop.
 - **FIX**: upgrade deps.
 - **FIX**: add compatibility for emoji font with flutter >= 3.22.
 - **FIX**: Flutter 3.22 arg error.

## 1.8.1-dev.1

 - **FIX**: add emojis again.

## 1.8.1-dev.0

 - **FIX**: integration test sign out.
 - **FIX**: check if canPop.
 - **FIX**: upgrade deps.
 - **FIX**: add compatibility for emoji font with flutter >= 3.22.
 - **FIX**: Flutter 3.22 arg error.

## 1.8.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.8.0-dev.1

 - Update a dependency to the latest release.

## 1.8.0-dev.0

 - **FIX**: upgrade deps and migrate.
 - **FEAT**: sort invite codes alphabetically.

## 1.7.2

 - **FIX**: signup was not possible with flutter_secure_storage. ([26425971](https://github.com/hpi-studyu/studyu/commit/2642597141653aa724a1305456e43840d6fbebe5))

## 1.7.1

 - Update a dependency to the latest release.

## 1.7.0

 - **FIX**: style of photo capture button. ([7ec85382](https://github.com/hpi-studyu/studyu/commit/7ec853828a51e7aa454563786d782e9c8ffc4e22))
 - **FIX**: defer upload of multimodal files. ([e8324cab](https://github.com/hpi-studyu/studyu/commit/e8324cabd5dc7b20d1be529ae8ba94d51ab5eb39))
 - **FIX**: remove insecure remember me. ([9dd34cef](https://github.com/hpi-studyu/studyu/commit/9dd34cefbb90b0b2619875cda6bdf5b550967966))
 - **FIX**: make sure integration test title is saved. ([7ef22930](https://github.com/hpi-studyu/studyu/commit/7ef229304081c418204f45be32a4f37dac7216b8))
 - **FIX**: return empty list instead of null as supabase data. ([697cd5f0](https://github.com/hpi-studyu/studyu/commit/697cd5f07f94c6764e3232eb6109946e2c3ae2ca))
 - **FIX**: add missing audio response entry. ([87ff2805](https://github.com/hpi-studyu/studyu/commit/87ff2805e7d0c1b004d039bc876235208ccfa04e))
 - **FIX**: upgrade deps, move multimodal from core to app, migrate switch case. ([c4c1bd1e](https://github.com/hpi-studyu/studyu/commit/c4c1bd1e7e234535291b609deda21ea0e12b8506))
 - **FIX**: convert status code to int. ([2cc363da](https://github.com/hpi-studyu/studyu/commit/2cc363da52e86fe1c8ad28680d16999988bb7be3))
 - **FIX**: dart fix. ([1ebe9d00](https://github.com/hpi-studyu/studyu/commit/1ebe9d005d4c5d0f9e7ba1d8a0f24fc4e71641c2))
 - **FIX**: upgrade deps (switch to wakelock_plus). ([1000d89c](https://github.com/hpi-studyu/studyu/commit/1000d89cd4df62bbfedfb5238f0e427c4d2d2c08))
 - **FEAT**(designer): enable free text UI. ([6c53867e](https://github.com/hpi-studyu/studyu/commit/6c53867e23c4804b4503196441d70e281130e47d))
 - **FEAT**: add maximum recording duration to designer. ([c601e0ba](https://github.com/hpi-studyu/studyu/commit/c601e0ba1a327c01a2c88f5a323d24bbd558cdf3))
 - **FEAT**: deprecate SharedPreferences for flutter_secure_storage. ([1ff25946](https://github.com/hpi-studyu/studyu/commit/1ff259469e3c354f57e22a3d42ce0d1c60036f44))
 - **FEAT**: export media files with study data. ([ca1474a2](https://github.com/hpi-studyu/studyu/commit/ca1474a20595e39fa708c47268e5c6a587bc021f))

## 1.6.3

 - **FIX**: disable freetext for Designer UI surveys. ([7e3988eb](https://github.com/hpi-studyu/studyu/commit/7e3988ebc80620be52636077a6fb13a180c1802a))

## 1.6.2

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.6.2-dev.7

 - **FIX**: upgrade deps. ([b491c9c4](https://github.com/hpi-studyu/studyu/commit/b491c9c469ee808fe1aaa50b7a50759be2378552))
 - **FIX**: enable color emoji. ([e7f9ddcb](https://github.com/hpi-studyu/studyu/commit/e7f9ddcb7dfbb11e9fdd05e3791b55d2a1fe52b9))
 - **FIX**: temporarily disable free text for the designer. ([00e0b1e6](https://github.com/hpi-studyu/studyu/commit/00e0b1e60e368d1e3620eec61924ff17a098f386))
 - **FIX**: future-proof deserialization of studies. ([ca7c3145](https://github.com/hpi-studyu/studyu/commit/ca7c3145cd663dda47716ffa4ac5cef3fb25da84))
 - **FEAT**: rework deserialization of unsupported types to throw exception. ([54956cf1](https://github.com/hpi-studyu/studyu/commit/54956cf17c879dce27821da3a85f2d8d509542e7))

## 1.6.2-dev.6

 - **FIX**: upgrade deps. ([b491c9c4](https://github.com/hpi-studyu/studyu/commit/b491c9c469ee808fe1aaa50b7a50759be2378552))
 - **FIX**: enable color emoji. ([e7f9ddcb](https://github.com/hpi-studyu/studyu/commit/e7f9ddcb7dfbb11e9fdd05e3791b55d2a1fe52b9))
 - **FIX**: temporarily disable free text for the designer. ([00e0b1e6](https://github.com/hpi-studyu/studyu/commit/00e0b1e60e368d1e3620eec61924ff17a098f386))

## 1.6.2-dev.5

 - **FIX**: upgrade deps. ([5327eb97](https://github.com/hpi-studyu/studyu/commit/5327eb971e6673847dc09ef56923b6a73ae73654))
 - **FIX**: alert dialog box constraints. ([332d1d14](https://github.com/hpi-studyu/studyu/commit/332d1d148e1d8abd18b83426218be25ab3fb512f))

## 1.6.2-dev.4

 - **FIX**: breaking deps. ([34896ad3](https://github.com/hpi-studyu/studyu/commit/34896ad381b38a4ad03caf92f57ad527bc1f6706))

## 1.6.2-dev.3

 - **REVERT**: "refactor: remove unused title"". ([c473bba4](https://github.com/hpi-studyu/studyu/commit/c473bba43f9952dbadb5424e5ad00ae791f85e46))
 - **REVERT**: "refactor: remove unused title". ([26f1ab93](https://github.com/hpi-studyu/studyu/commit/26f1ab9321ab0ddfab9c23bcca48557f95599b9f))
 - **REFACTOR**: use logo in app bar for compact view. ([4f0d81c3](https://github.com/hpi-studyu/studyu/commit/4f0d81c386b7054c85fc3c58b5e32fed53593339))
 - **REFACTOR**: remove unused title. ([3121af17](https://github.com/hpi-studyu/studyu/commit/3121af17f8bdc8de0850c2ff0d94527b28035e4d))
 - **FIX**: upgrade deps. ([6ad9bea4](https://github.com/hpi-studyu/studyu/commit/6ad9bea42903a25a5be5a84f2af8b70654d05616))
 - **FIX**: remove debugPrint of screen width. ([a313908a](https://github.com/hpi-studyu/studyu/commit/a313908a1d2fe037131463b82ecd040d6f45fff6))
 - **FIX**: update gitignore files. ([939d6be4](https://github.com/hpi-studyu/studyu/commit/939d6be422ee37f2ea56b39bb3921060fd1844cd))
 - **FIX**: use icon directory. ([d3d627cd](https://github.com/hpi-studyu/studyu/commit/d3d627cda35c14af026507f4181c232b8c43e22d))
 - **FIX**: new web deployment with generated icons. ([fd8fcc9f](https://github.com/hpi-studyu/studyu/commit/fd8fcc9f459cc0f46c5185d96cce6586adbfc543))
 - **FIX**: upgrade deps. ([7ac0d4ca](https://github.com/hpi-studyu/studyu/commit/7ac0d4cab42b1ce27ec200a5241f92d612ade499))
 - **FIX**: upgrade deps. ([3e186fc4](https://github.com/hpi-studyu/studyu/commit/3e186fc409f038102cc5fd1e6d11b73057dab8d7))
 - **FIX**: alignment of the sorting arrows. ([8b3938c1](https://github.com/hpi-studyu/studyu/commit/8b3938c14aed65b58a5797de754cc87858967b03))
 - **FIX**: restore new study button height. ([67fd5bd0](https://github.com/hpi-studyu/studyu/commit/67fd5bd031545959063f0e075094ab2233a1b9c2))
 - **FIX**: update of selected route in app drawer. ([c0509d9c](https://github.com/hpi-studyu/studyu/commit/c0509d9cabd4b4aa371febe9aba009d01f0ac927))
 - **FIX**: Layout overflow of column headers. ([f550e20a](https://github.com/hpi-studyu/studyu/commit/f550e20a1860db920c40ecb9d1dcdf9b225ac548))
 - **FIX**: Shorter text for study title in German. ([ca965ac4](https://github.com/hpi-studyu/studyu/commit/ca965ac461ba0c2298ed4d996e5388b3f252db40))
 - **FIX**: Remove column spacing when column is collapsed. ([331a0702](https://github.com/hpi-studyu/studyu/commit/331a0702dbe316186eada6fffa37365d065b91cd))
 - **FIX**: Layout overflow of status and participation badge. ([38e7a197](https://github.com/hpi-studyu/studyu/commit/38e7a197df8b3f12a43d49cbca28d21d6eb1b18e))
 - **FIX**: Close drawer after selection. ([9e1adb1c](https://github.com/hpi-studyu/studyu/commit/9e1adb1c7ddc6efffc27dbea2a853478be3cee64))
 - **FIX**: hardcoded width of search bar. ([22778eba](https://github.com/hpi-studyu/studyu/commit/22778eba1142dec0a74dc3813f1be93b4dc04458))
 - **FEAT**: add optional AUTO_LOGIN bool. ([10e8ff74](https://github.com/hpi-studyu/studyu/commit/10e8ff74ab46420766f705e8ecf101ac20345d9b))
 - **FEAT**: handle onSubmitted for password fields. ([f9ce231b](https://github.com/hpi-studyu/studyu/commit/f9ce231baa3e8a93b1436263fa8d457ab75ea3e0))
 - **FEAT**: add other platforms. ([34f5dafa](https://github.com/hpi-studyu/studyu/commit/34f5dafadafda6bc8652639245901620a2a116ab))
 - **FEAT**: style study table item without elevation. ([e45a0021](https://github.com/hpi-studyu/studyu/commit/e45a0021ff0d839f8684a01ff655d8a3d3a58772))
 - **FEAT**: Collapse "Created" column when available width is very low. ([970478db](https://github.com/hpi-studyu/studyu/commit/970478dbd5d2f71bff654c1fe16987fb16a4d50f))
 - **FEAT**: collapse dashboard drawer if horizontal space is low. ([400badea](https://github.com/hpi-studyu/studyu/commit/400badea08f02b24a1fe9792dcb6d05ab0dc8cc9))
 - **FEAT**: collapse enrolled, active, completed if horizontal space is low. ([12ec8b3f](https://github.com/hpi-studyu/studyu/commit/12ec8b3ffb9a4cb0f89da02940f5794892128fa0))
 - **FEAT**: implement studies table using ListView. ([e3f5756e](https://github.com/hpi-studyu/studyu/commit/e3f5756eb87435d2b670f6402f8bbc53fe390553))

## 1.6.2-dev.2

 - **REFACTOR**: rename free text attributes. ([f145b425](https://github.com/hpi-studyu/studyu/commit/f145b425e885501993f5ec60aa5028c68024cb0a))
 - **FIX**: upgrade deps. ([3e186fc4](https://github.com/hpi-studyu/studyu/commit/3e186fc409f038102cc5fd1e6d11b73057dab8d7))
 - **FIX**: resolve suggestions. ([e3584b70](https://github.com/hpi-studyu/studyu/commit/e3584b706e3ac44e51257165dcf9e0678205d8a5))
 - **FIX**: do not show length as double. ([76704bd2](https://github.com/hpi-studyu/studyu/commit/76704bd218cc4d99df8ef5c91260f83628806fef))
 - **FIX**: quickfix for free text eligibility. ([5bb2e42b](https://github.com/hpi-studyu/studyu/commit/5bb2e42b89383611fd9cd0882c1cdb6df4c07544))
 - **FIX**: free text show errors only when dirty. ([d0841113](https://github.com/hpi-studyu/studyu/commit/d08411135a2d2c468a46d72d02f7186319106b4d))
 - **FIX**: free text localization. ([bb1fc558](https://github.com/hpi-studyu/studyu/commit/bb1fc558f3d708ae75307319a85fc1f12105c29d))
 - **FIX**: disable free text options on readonly. ([c882c6d0](https://github.com/hpi-studyu/studyu/commit/c882c6d0be77b8f5fb5fe4c2f6be5ba16f1d775e))
 - **FIX**: standard table error. ([341a8415](https://github.com/hpi-studyu/studyu/commit/341a84155bca30fd023eb92efdf7268160c668eb))
 - **FIX**: reactive free text validation. ([caecd761](https://github.com/hpi-studyu/studyu/commit/caecd761f151abbb127b693a50177cca99e299fd))
 - **FEAT**: use workaround to always show value indicator for range slider. ([61a06ad9](https://github.com/hpi-studyu/studyu/commit/61a06ad9cba422f4ba5a88d9e1d2ea3e7e847557))
 - **FEAT**: increase max free text range. ([5b288caf](https://github.com/hpi-studyu/studyu/commit/5b288cafc67f6f841671afd94b0f5cdaa56d60af))
 - **FEAT**: translate free text. ([0cad3ff9](https://github.com/hpi-studyu/studyu/commit/0cad3ff9ea05f56f25fe16b223b7e140c530ff89))
 - **FEAT**: implement free text validator for app. ([44c3fa20](https://github.com/hpi-studyu/studyu/commit/44c3fa2070e0073a6ab4352daa4d96d7ee1632fe))
 - **FEAT**: implement free_text for designer. ([f0ce3512](https://github.com/hpi-studyu/studyu/commit/f0ce3512f28b1eaae1bc69f75701038e42e6936d))

## 1.6.2-dev.1

 - **REFACTOR**: replace custom validators with native ones. ([e7d8c50b](https://github.com/hpi-studyu/studyu/commit/e7d8c50bb419520ce0889a71a0295c239aa62807))
 - **FIX**: upgrade deps. ([304430c8](https://github.com/hpi-studyu/studyu/commit/304430c858d4035a279b42114c7ccf86299357a2))
 - **FIX**: type checks. ([b85e073d](https://github.com/hpi-studyu/studyu/commit/b85e073d7075b8d45d15f32e62d5761416cdad4a))
 - **FIX**: validate email on signup. ([e5257abe](https://github.com/hpi-studyu/studyu/commit/e5257abe64031731d4c2cfba389f5460bca9a618))
 - **FIX**: show auth validation messages. ([eb7c5a46](https://github.com/hpi-studyu/studyu/commit/eb7c5a463ce02676802bdb06f21225531d21d6db))
 - **FIX**: isDirty evaluation is now based on current state. ([1a24011f](https://github.com/hpi-studyu/studyu/commit/1a24011fe29f711aac37fb1e35b461ee62eaa77e))
 - **FIX**: replace deprecated popcallback with popentry. ([d35d0e4f](https://github.com/hpi-studyu/studyu/commit/d35d0e4f3e5b94b5f1d18138969370f3f0876022))

## 1.6.2-dev.0

 - Update a dependency to the latest release.

## 1.6.1

 - **FIX**: upgrade deps. ([f37d0a71](https://github.com/hpi-studyu/studyu/commit/f37d0a711ab9a126b7da13b7eb4fbb9b784f3725))
 - **FIX**: convert status code to int. ([6b8fc2d2](https://github.com/hpi-studyu/studyu/commit/6b8fc2d29a9a190a3966ba7e0d6bf9404298e9b6))
 - **FIX**: dart fix. ([d184c43b](https://github.com/hpi-studyu/studyu/commit/d184c43bafd0229a799ec835b16c3dcb851016b9))
 - **FIX**: combine all integration tests due to lack of sequential testing. ([0b291cd8](https://github.com/hpi-studyu/studyu/commit/0b291cd8a2cccb6ae6b68f41466d9c9f9808cef4))
 - **FIX**: study test frame exception and lints. ([9a2ee3a5](https://github.com/hpi-studyu/studyu/commit/9a2ee3a589b8b5a44dfd74b3977bc1512f0dbee4))
 - **FIX**: upgrade deps. ([567a3b07](https://github.com/hpi-studyu/studyu/commit/567a3b07c360e55da62898e928a794a756ab0546))
 - **FIX**: convert status code to int. ([38f66b30](https://github.com/hpi-studyu/studyu/commit/38f66b3006dbe6dc74672cb6a9169ac77f050709))
 - **FIX**: dart fix. ([8d81f96c](https://github.com/hpi-studyu/studyu/commit/8d81f96c0caf63df04fc41f156d3312e5b09c076))

## 1.6.0

 - **FIX**: upgrade deps. ([567a3b07](https://github.com/hpi-studyu/studyu/commit/567a3b07c360e55da62898e928a794a756ab0546))
 - **FIX**: convert status code to int. ([38f66b30](https://github.com/hpi-studyu/studyu/commit/38f66b3006dbe6dc74672cb6a9169ac77f050709))
 - **FIX**: dart fix. ([8d81f96c](https://github.com/hpi-studyu/studyu/commit/8d81f96c0caf63df04fc41f156d3312e5b09c076))
 - **FIX**: added missing test files. ([e6b4d401](https://github.com/hpi-studyu/studyu/commit/e6b4d401c66a33be6ea40d8dedc84f5fddecac49))
 - **FIX**: form fields unfindable by patrol_finders. ([96db2a88](https://github.com/hpi-studyu/studyu/commit/96db2a88f884d21dcb2e70c1e9af94c72582ba75))
 - **FIX**: router cannot be reassigned between tests. ([8fae8dad](https://github.com/hpi-studyu/studyu/commit/8fae8dada32e8efed1f21f3b5493fe123cef67d9))
 - **FIX**: authFormController incorrect disposal. ([def9ace1](https://github.com/hpi-studyu/studyu/commit/def9ace12eb8b4f12772cbffe8ee7dc26b21e1bc))
 - **FIX**: constant animation in background. ([0ad4c13b](https://github.com/hpi-studyu/studyu/commit/0ad4c13b0e8db3a6016a328da5871040a6e949a7))
 - **FEAT**: completed e2e tests + script. ([4953e8fe](https://github.com/hpi-studyu/studyu/commit/4953e8feec5dc150543fe107309ea013e7c3adf9))

## 1.5.3

 - **FIX**: update descriptions and rename imprint. ([6d3757f4](https://github.com/hpi-studyu/studyu/commit/6d3757f425dd5b95ee581e10b6ad675f8e71786a))

## 1.5.2

 - **FIX**: upgrade deps. ([6fa0e8b8](https://github.com/hpi-studyu/studyu/commit/6fa0e8b8332c0872b59c7c31042fb845f0708e73))

## 1.5.1

 - **FIX**: rename custom MustMatchValidator. ([613e14a4](https://github.com/hpi-studyu/studyu/commit/613e14a4c846cae5a4ba3f83294a70978d907ca1))

## 1.5.0

 - **FIX**: upgrade deps. ([7cdc7c55](https://github.com/hpi-studyu/studyu/commit/7cdc7c559f64cfdd63ee07efbeeb028c418f6f4e))
 - **FIX**: upgrade deps. ([17213746](https://github.com/hpi-studyu/studyu/commit/172137469ed236dc694979bbfe017708faabbd77))
 - **FIX**: report button visible for read-only studies. ([99daed13](https://github.com/hpi-studyu/studyu/commit/99daed1356840eceb640755a06daa967a8c28fb1))
 - **FIX**: regenerate ids when duplicating a study. ([79b411c3](https://github.com/hpi-studyu/studyu/commit/79b411c3b4dfe9467c412a7cd2c47508ce766623))
 - **FEAT**: localization additions. ([787f2ba6](https://github.com/hpi-studyu/studyu/commit/787f2ba659a39427ae988181ef89f20f24cdb121))

## 1.4.0

 - **REFACTOR**: format. ([595a717f](https://github.com/hpi-studyu/studyu/commit/595a717f0e09a3ba311984ad1f4b584252e091ec))
 - **REFACTOR**: pin changes to user_repository.dart. ([e6579c8b](https://github.com/hpi-studyu/studyu/commit/e6579c8bc9f6b9c5e828c81fe7d185ccbfa7f8d0))
 - **REFACTOR**: cleanup. ([b4a987e7](https://github.com/hpi-studyu/studyu/commit/b4a987e7add7100a23f2366a83d6551b6d861567))
 - **REFACTOR**: rename. ([c1bf13dd](https://github.com/hpi-studyu/studyu/commit/c1bf13dd8f0f8d1ea4ea3ee8fe4663c0700d486a))
 - **REFACTOR**: make tags more reactive. ([d7cb5f30](https://github.com/hpi-studyu/studyu/commit/d7cb5f30f10834a3bf90c2b74e400cd7103846e0))
 - **REFACTOR**: fix dashboard pin null value. ([eda8ccfb](https://github.com/hpi-studyu/studyu/commit/eda8ccfb3a0da3a1d6a2eb986c85bd24526aea0d))
 - **FIX**: upgrade deps. ([aa2cb251](https://github.com/hpi-studyu/studyu/commit/aa2cb2512e3db4e31f97edea8d2bccf55e91f9d2))
 - **FIX**: study was not returned completely. ([324e2ceb](https://github.com/hpi-studyu/studyu/commit/324e2ceb2afe25df5ee06cd2450865137efe7ae1))
 - **FIX**: non-working pin. ([5729a096](https://github.com/hpi-studyu/studyu/commit/5729a096d599827026b68cfce910e6a78e309a35))
 - **FIX**: tag color. ([9baddd1d](https://github.com/hpi-studyu/studyu/commit/9baddd1d3df22ebb45fa5117f724fd9b98b31b98))
 - **FIX**: tag related sql. ([59882b7e](https://github.com/hpi-studyu/studyu/commit/59882b7e86b7145131733c4d6851cf621b676fc8))
 - **FIX**: make color nullable and int, add tags to dashboard. ([ef7532a3](https://github.com/hpi-studyu/studyu/commit/ef7532a3e571abd140cfbeee1e2e1b6fd14f9ed6))
 - **FIX**: update copyright. ([515785bd](https://github.com/hpi-studyu/studyu/commit/515785bd4717693d5cb65c7fd79a1c70ecf8c441))
 - **FIX**: remove Designer V2 version number from page title. ([362a4fe5](https://github.com/hpi-studyu/studyu/commit/362a4fe5f5a31b4364d9695f8f2b7193d3ac811e))
 - **FEAT**: make study tags reactive. ([f2f8ecaf](https://github.com/hpi-studyu/studyu/commit/f2f8ecafb4f21d21128ce089eb99608778b91e2e))
 - **FEAT**: refactor Search to widget and make tags clickable. ([95f33064](https://github.com/hpi-studyu/studyu/commit/95f33064444b9e594d9497bc6321c529253ee0bd))
 - **FEAT**: working tags with foreign key study_tag. ([8d4eaa92](https://github.com/hpi-studyu/studyu/commit/8d4eaa925c8a921bfa70f0afae6a57a155a55c9e))
 - **FEAT**: display and update tags correctly. ([b96dcf8a](https://github.com/hpi-studyu/studyu/commit/b96dcf8a25def52dfc59bc65206177e0ab4a25d8))
 - **FEAT**: initial study tags. ([615d5b62](https://github.com/hpi-studyu/studyu/commit/615d5b629a2ae5d9998d50b1a0f119fa62a2bc87))

## 1.3.9

 - **FIX**: upgrade deps (switch to wakelock_plus). ([177e5057](https://github.com/hpi-studyu/studyu/commit/177e5057fb41821a2f924ffda79e1faa3119859d))
 - **FIX**: upgrade deps (switch to wakelock_plus). ([9112f5f0](https://github.com/hpi-studyu/studyu/commit/9112f5f0a9c778e2abf24f6aa585bc9f539e6ccf))

## 1.3.8

 - **FIX**: upgrade deps (switch to wakelock_plus). ([9112f5f0](https://github.com/hpi-studyu/studyu/commit/9112f5f0a9c778e2abf24f6aa585bc9f539e6ccf))

## 1.3.7

 - **FIX**: add await-workflow action to wait for pub.dev publishing. ([7206a006](https://github.com/hpi-studyu/studyu/commit/7206a00663657f6d6256b99b0c3aca33e9b263bb))

## 1.3.6

 - **FIX**: upgrade deps. ([35c629aa](https://github.com/hpi-studyu/studyu/commit/35c629aa28fc5761a707168d998a425307ec6d9a))

## 1.3.5

 - **FIX**: upgrade deps. ([b2926c39](https://github.com/hpi-studyu/studyu/commit/b2926c395988077d4aa172490dbd9c6fd75d52c6))
 - **FIX**: upgrade deps. ([daad1465](https://github.com/hpi-studyu/studyu/commit/daad146590e874bedee3f82bb72bf4b94e5c3801))

## 1.3.4

 - **FIX**: upgrade deps. ([daad1465](https://github.com/hpi-studyu/studyu/commit/daad146590e874bedee3f82bb72bf4b94e5c3801))

## 1.3.3

 - **FIX**: enable emojis again for designer_v2 web. ([d2ccd3f0](https://github.com/hpi-studyu/studyu/commit/d2ccd3f0f997f304871c223f913c3392b91304c3))

## 1.3.2

 - **REFACTOR**: initial null safety support. ([82c119f9](https://github.com/hpi-studyu/studyu/commit/82c119f980f647133bff1c3748625e148cbc6ffe))

## 1.3.1

 - Update a dependency to the latest release.

## 1.3.0

 - **FIX**: more slider usability fixes. ([d8309803](https://github.com/hpi-studyu/studyu/commit/d83098037f6f1cf9bdc0f150df6d94156c81f19d))
 - **FIX**: more slider usability fixes. ([6e151bc6](https://github.com/hpi-studyu/studyu/commit/6e151bc6281c3740ccb8d23154994c2066fc65ae))
 - **FEAT**: sentry integration in core. ([0fae767f](https://github.com/hpi-studyu/studyu/commit/0fae767f0a7dc3c3409dd5179eeb870429b580cd))

## 1.2.2

 - **FIX**: more slider usability fixes. ([6e151bc6](https://github.com/hpi-studyu/studyu/commit/6e151bc6281c3740ccb8d23154994c2066fc65ae))

## 1.2.1

 - **FIX**: upgrade deps to fix invalid refresh token bug. ([6a4da159](https://github.com/hpi-studyu/studyu/commit/6a4da1594d7baed5d76f74464670ec411abc961c))
 - **FIX**: initial router location. ([6cae20f1](https://github.com/hpi-studyu/studyu/commit/6cae20f1a9b5d1161aae6b08c262e50824b18971))

## 1.2.0

 - **FIX**: number validator not working properly. ([5b60c1da](https://github.com/hpi-studyu/studyu/commit/5b60c1da8d40b5728fbf4a902dad21f3b3009865))
 - **FIX**: intervention task html styling info missing. ([c2ca55f8](https://github.com/hpi-studyu/studyu/commit/c2ca55f83109f14aaafc9dbeb068a1ae32b18632))
 - **FIX**: regenerate instanceId's for duplicates. ([a539ec53](https://github.com/hpi-studyu/studyu/commit/a539ec533fea07cf948dceeeed43c903bde2f630))
 - **FIX**: add pointerinerceptor to timepickers. ([c3491ed2](https://github.com/hpi-studyu/studyu/commit/c3491ed27603071e449c580978e0aae0724fe309))
 - **FIX**(designer2): workaround for schedule timepicker type error. ([93012567](https://github.com/hpi-studyu/studyu/commit/93012567aab06bad584eb06ff9313cbd4dad8969))
 - **FIX**: translation. ([75bc38ca](https://github.com/hpi-studyu/studyu/commit/75bc38ca1ba46ba343c2179ea66d98b78cbf9483))
 - **FIX**: export no element bug. ([588d255e](https://github.com/hpi-studyu/studyu/commit/588d255e920aec5685f69c9983218470c7a0cefb))
 - **FEAT**: try left sidesheet. ([7d8dba3b](https://github.com/hpi-studyu/studyu/commit/7d8dba3b03e92008a4dcbf4acfe6a24333f37d13))
 - **FEAT**(designer2): introduce basic html styleable concept. ([02da7901](https://github.com/hpi-studyu/studyu/commit/02da79014a5ef37f05aa4ef1899d6d94ba7b92a2))
 - **FEAT**: add report section validation sets. ([5c063148](https://github.com/hpi-studyu/studyu/commit/5c0631480aa0efa886104640380908da6dc78f39))
 - **FEAT**: translation and styling. ([4f62ba65](https://github.com/hpi-studyu/studyu/commit/4f62ba65c6f5736465f40654c352902289f8db37))

## 1.1.1

 - **FIX**: preview mode working again. ([75bec484](https://github.com/hpi-studyu/studyu/commit/75bec484a065cea9a4842afde26205876718d7d0))

## 1.1.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.1.0-dev.7

 - Update a dependency to the latest release.

## 1.1.0-dev.6

 - Update a dependency to the latest release.

## 1.1.0-dev.5

 - **FIX**: revert report changes. ([ce336c1a](https://github.com/hpi-studyu/studyu/commit/ce336c1a2afebf916c00fbb9ed649f89182e43ac))

## 1.1.0-dev.4

 - Update a dependency to the latest release.

## 1.1.0-dev.3

 - Update a dependency to the latest release.

## 1.1.0-dev.2

 - **FIX**: designerV2 TaskInstance support for single completionperiods to restore live preview functionality. ([6a85f162](https://github.com/hpi-studyu/studyu/commit/6a85f16252b91f9d8dc3b92f7deb00fef293f032))
 - **FIX**: notification have wrong ids. ([144b8d7d](https://github.com/hpi-studyu/studyu/commit/144b8d7dc834e0b0d38f5ae4a0f658300f4af073))
 - **FIX**: do not require interventions to have at least one task anymore. ([2a656d57](https://github.com/hpi-studyu/studyu/commit/2a656d57d5d9d0750432c593e1d3e68fea8b25fa))
 - **FIX**: pointerinterceptor settings. ([d81c5626](https://github.com/hpi-studyu/studyu/commit/d81c5626adad673f6c64883984eae1c9f05d1dad))
 - **FIX**: pointerinterceptor test help modal. ([5f75eaac](https://github.com/hpi-studyu/studyu/commit/5f75eaacc884d3eaef0b9be40a375568c9ed912a))
 - **FIX**: settings dialog. ([a8aba5b6](https://github.com/hpi-studyu/studyu/commit/a8aba5b62bcd45c51af21c194533e675e91d45c0))
 - **FIX**: pointerinterceptor for survey. ([077290c0](https://github.com/hpi-studyu/studyu/commit/077290c016750df836be8765c82de0497cf35faf))
 - **FEAT**: study reports sidesheet. ([456cc9f9](https://github.com/hpi-studyu/studyu/commit/456cc9f9a4c50aabb5c51da4c397edffaede4652))
 - **FEAT**: implement study reports framework. ([5b39410b](https://github.com/hpi-studyu/studyu/commit/5b39410ba775a558be9f5b507dd4fef9545720f7))
 - **FEAT**: rename TimedTask to TaskInstance and make it mandatory. ([42f4ee14](https://github.com/hpi-studyu/studyu/commit/42f4ee14dd1d30c0df11b8e3e221c842c3fcc8af))

## 1.1.0-dev.1

 - **FIX**: merge issues. ([8a560314](https://github.com/hpi-studyu/studyu/commit/8a560314c14fcf3e37e9d40f7129a4db483e8a8a))
 - **FIX**: iframe preview now working with safari. ([2ceb7e4d](https://github.com/hpi-studyu/studyu/commit/2ceb7e4d25c17ef6b7d654ce9cdb88492dd452b0))
 - **FIX**: enable settings again. ([a070a04d](https://github.com/hpi-studyu/studyu/commit/a070a04d4da820973d36a58281df78e1015516e3))
 - **FIX**: logout null value. ([46894669](https://github.com/hpi-studyu/studyu/commit/468946697afc21e26f65b26d83ae2cd7df858fc1))
 - **FIX**: use pointerinterceptor. ([1cf8ad69](https://github.com/hpi-studyu/studyu/commit/1cf8ad69a6b150077f59ee5d88702e0522f7d001))
 - **FIX**: quickfix router and upgrade deps. ([024303ec](https://github.com/hpi-studyu/studyu/commit/024303ec08edb7a703fd30139920055c909a4a47))
 - **FIX**: l10n error. ([8d922181](https://github.com/hpi-studyu/studyu/commit/8d9221810a421d2686a8e70f85f9aeae33cf9812))
 - **FIX**: router errors. ([1bd34ec3](https://github.com/hpi-studyu/studyu/commit/1bd34ec36937366c08ef9c4fe7d75a38d4be4507))
 - **FIX**: update outdated stuff and dart generate. ([82b58bdc](https://github.com/hpi-studyu/studyu/commit/82b58bdcbf6f077003398b1a19813aa35a36bd91))
 - **FIX**: badge issue. ([44df2912](https://github.com/hpi-studyu/studyu/commit/44df29120fe2f0f5ea1308d79bab4d91c9b8dbe9))
 - **FIX**: upgrade supabase_flutter (^1.3.1) and supabase (^1.4.0). ([88e6dad4](https://github.com/hpi-studyu/studyu/commit/88e6dad4cbf6f5847fe382e7969ec2e13a1dee44))
 - **FEAT**: early release customSequence. ([f65c64d7](https://github.com/hpi-studyu/studyu/commit/f65c64d7a828125c7f36e3dcf08262e42f78ba29))

## 1.1.0-dev.0

 - **REFACTOR**: resolve new study issues & make repository logic more robust. ([ba06ca15](https://github.com/hpi-studyu/studyu/commit/ba06ca158f21fdf1f80c46778e1143cf655ff07b))
 - **REFACTOR**: sidesheet to stateful widget. ([7b464114](https://github.com/hpi-studyu/studyu/commit/7b464114babc83ddacfb9a31b8bfb7494ceb35e5))
 - **REFACTOR**: remove BoundedContainer. ([99f4a4cc](https://github.com/hpi-studyu/studyu/commit/99f4a4ccaa7fcd6695ed7aab1d57efbe82b7977d))
 - **REFACTOR**: cleanup test mode controller, views & architecture. ([47338d92](https://github.com/hpi-studyu/studyu/commit/47338d924c866cc905b0e48ff8ba8d3197981669))
 - **REFACTOR**: move forms package from domain to features. ([9ffbc81e](https://github.com/hpi-studyu/studyu/commit/9ffbc81e8281b24c04b438012c27294c596c4d68))
 - **FIX**: autosave retriggered due to timer not being disposed. ([b7a392cf](https://github.com/hpi-studyu/studyu/commit/b7a392cf45f818e7cfab02373c764789ab122cab))
 - **FIX**: enable remove participation on launch again. ([e177695b](https://github.com/hpi-studyu/studyu/commit/e177695bc94a3b21a501a82aa95da8c29c660973))
 - **FIX**: remove testDelay. ([bec16a79](https://github.com/hpi-studyu/studyu/commit/bec16a79c3d719945b6548244fa9bb1e4c143409))
 - **FIX**: password reset. ([5c3fda47](https://github.com/hpi-studyu/studyu/commit/5c3fda4791bd5aed957dbe721babe701fb462f50))
 - **FIX**: correctly position annotations / labels for scale questions. ([acfa3524](https://github.com/hpi-studyu/studyu/commit/acfa3524fcc7e9c2f5237398e271b9390fe6e1e1))
 - **FIX**: imprint link. ([a8622925](https://github.com/hpi-studyu/studyu/commit/a8622925f9b2a1cdf83cec9fb17301f3f5921b75))
 - **FIX**: designer pw reset redirect url. ([829da3e4](https://github.com/hpi-studyu/studyu/commit/829da3e453d89cd986bf4396cc2647b8b1ff5ee5))
 - **FIX**: unpublish draft copies from study registry. ([bd408196](https://github.com/hpi-studyu/studyu/commit/bd40819613a605a1e71b8208a0b05ed10ecbda0c))
 - **FIX**: dispose tickers & scroll controllers properly. ([66b27874](https://github.com/hpi-studyu/studyu/commit/66b278742995c03b8846f3f6d2ef8643372c8667))
 - **FIX**: upgrade deps. ([4b011445](https://github.com/hpi-studyu/studyu/commit/4b011445bb2390570c536646bb119b5a00a809ab))
 - **FIX**: refactor test frame and fix iframe click bug. ([9a6bc390](https://github.com/hpi-studyu/studyu/commit/9a6bc390505895fa6344fc6bdfdc5be232c90c88))
 - **FIX**: make onSave async. ([6199971b](https://github.com/hpi-studyu/studyu/commit/6199971b05d542af634d0054a7ef72194c244c02))
 - **FIX**: refactoring. ([e5bf8ccb](https://github.com/hpi-studyu/studyu/commit/e5bf8ccb207026031bcde1e53b07f8f6f7112001))
 - **FIX**: enable banner again. ([1084274e](https://github.com/hpi-studyu/studyu/commit/1084274e9bcd4f05f9d6ee17ba12d42fe5295d80))
 - **FIX**: text route overview fix. ([527eb865](https://github.com/hpi-studyu/studyu/commit/527eb86586621af7fa2fd121b3455c3fd7db289a))
 - **FIX**: measurement preview bug, refactoring. ([10935ef6](https://github.com/hpi-studyu/studyu/commit/10935ef696ca9a4b09d1468ed15ed3cac28e1983))
 - **FIX**: update icon picker dialog widget. ([7a992c88](https://github.com/hpi-studyu/studyu/commit/7a992c8815b168f1c03482f6d812f655c31c91c3))
 - **FIX**: launch button validation criteria. ([0906ffd1](https://github.com/hpi-studyu/studyu/commit/0906ffd11a818dac7cdfb62920bf420bea974b5e))
 - **FIX**: make autosave indicator work again. ([6664589f](https://github.com/hpi-studyu/studyu/commit/6664589f27195190dcf21cebdc77719af5db19c0))
 - **FIX**: Json serialization bug & remove copy draft redirect. ([39860a45](https://github.com/hpi-studyu/studyu/commit/39860a45329ad55fdea66968d91f2edd596ef3ec))
 - **FIX**: missing supabase import. ([4dc958c2](https://github.com/hpi-studyu/studyu/commit/4dc958c2ad918e3df8095eb220fa5458066db03a))
 - **FIX**: merge fix. ([bb7bad01](https://github.com/hpi-studyu/studyu/commit/bb7bad01e6406fe1277a1eb55d85cc19c140c55a))
 - **FIX**: refactor. ([74e04f20](https://github.com/hpi-studyu/studyu/commit/74e04f20b8c0d74bd7a4724a69f31258ef9c578f))
 - **FIX**: add howto button again and fix test page reset. ([a08354ed](https://github.com/hpi-studyu/studyu/commit/a08354edfea17039e46636927175dce950c7d318))
 - **FIX**: make createdAt available immediately for study copies. ([ed426744](https://github.com/hpi-studyu/studyu/commit/ed426744df3cd18120ae4c996aac6c0f20c4c87f))
 - **FIX**: merge issues. ([4690353c](https://github.com/hpi-studyu/studyu/commit/4690353cf9315e03e8a80dea0073998c46e2547b))
 - **FIX**: upgrade rxdart. ([46260d7e](https://github.com/hpi-studyu/studyu/commit/46260d7ea68a397ffeefd38d5e6ce225e48eba31))
 - **FIX**: null and reload error. ([b2f11da8](https://github.com/hpi-studyu/studyu/commit/b2f11da888e2579e2f363d53a60639b44a01291f))
 - **FIX**: refactor page navigation. ([cda2c0f3](https://github.com/hpi-studyu/studyu/commit/cda2c0f384abd9580050927f9f6ffa7351421400))
 - **FIX**: refactor improvements and bugfixes. ([3c7d84fc](https://github.com/hpi-studyu/studyu/commit/3c7d84fc70be852c52516ac173b33812076f5992))
 - **FIX**: observation/intervention preview. ([f24dcfdc](https://github.com/hpi-studyu/studyu/commit/f24dcfdcb3b62eb0fa4ec06ea0b2b1a891ed679d))
 - **FIX**: merge preview. ([ed801715](https://github.com/hpi-studyu/studyu/commit/ed801715cda346f818da315db5af67546c0224e9))
 - **FIX**: update test mode disabled copy. ([1dab1004](https://github.com/hpi-studyu/studyu/commit/1dab1004fd70e86fb1889bbf5f9de02a534bf076))
 - **FIX**: deletion of launched studies. ([67e72d45](https://github.com/hpi-studyu/studyu/commit/67e72d459a12b095b9cd135ded931ffcae3b0472))
 - **FIX**: Ability to delete studies with access code. ([2e965703](https://github.com/hpi-studyu/studyu/commit/2e9657033fcfd022642a963b6d496170bb9529e5))
 - **FIX**: readonly warning. ([c7a3e083](https://github.com/hpi-studyu/studyu/commit/c7a3e0836f43975a1bc400b906f0617fc5e7f2dd))
 - **FIX**: display correct notification icon. ([04825fed](https://github.com/hpi-studyu/studyu/commit/04825feda6b75f419915d76a2f5bb76696f5c813))
 - **FIX**: autosave without skipping callbacks. ([150a6edb](https://github.com/hpi-studyu/studyu/commit/150a6edb913f0e6abe8751f1c1226f12b81fd6f6))
 - **FIX**: dont reset controls on cancel in readonly mode. ([7481b214](https://github.com/hpi-studyu/studyu/commit/7481b2146fb02bb82bd5ee893c372ac30640310a))
 - **FIX**: Requirements not working, fix banner. ([aac905a0](https://github.com/hpi-studyu/studyu/commit/aac905a0a29e5af8b5598fd44d48ad23c9775a17))
 - **FIX**: adjust submenu spacing. ([bf64d840](https://github.com/hpi-studyu/studyu/commit/bf64d8406b88c2130b66a43e060a8a535a5569c0))
 - **FIX**: Use app-v2 for preview. ([65d8f023](https://github.com/hpi-studyu/studyu/commit/65d8f0234eff8de6330e1e12b5dac39d83bdac48))
 - **FIX**: prevent infinite autosave loop. ([5b62c609](https://github.com/hpi-studyu/studyu/commit/5b62c6090b0bb89dc6b0cad66e85d7066833f7ca))
 - **FIX**: remove rememberMe if unset. ([66d7aa41](https://github.com/hpi-studyu/studyu/commit/66d7aa41750ae453ccfaa67003986a6924e51541))
 - **FIX**: set correct app link. ([da56b363](https://github.com/hpi-studyu/studyu/commit/da56b3637f61b98fb792da571b31383329ac275a))
 - **FIX**: layout for smaller display resolutions (fullhd). ([62a6db90](https://github.com/hpi-studyu/studyu/commit/62a6db9019c429da9265de1b5ca18df5879b56f5))
 - **FIX**: adapt temp urls to current PR. ([f2360b5d](https://github.com/hpi-studyu/studyu/commit/f2360b5df9ff9b900ed08b958bdfcd822d86ab96))
 - **FIX**: temporary disable not working test. ([ca968822](https://github.com/hpi-studyu/studyu/commit/ca96882213789f061928a743c740565244292204))
 - **FIX**: resolve app drawer select issues by removing localization (for now). ([6227662b](https://github.com/hpi-studyu/studyu/commit/6227662b9b68438479c8c403f7d359738d3e298f))
 - **FIX**: improving page transitions a bit. ([513d94e3](https://github.com/hpi-studyu/studyu/commit/513d94e3a72de148827ec768c4bbd7416b9a4235))
 - **FIX**: reload bug @ survey preview. ([1baa3462](https://github.com/hpi-studyu/studyu/commit/1baa34620b572802ca6eecca4ff254f8bca360ad))
 - **FIX**: link issues. ([8ef727c9](https://github.com/hpi-studyu/studyu/commit/8ef727c9f2141b05e9e3d21ed87ed106b7b2050d))
 - **FIX**: resolve issues for 'new' studies. ([70639305](https://github.com/hpi-studyu/studyu/commit/706393055abb82fc1cc15be24e25c62a1731a5a3))
 - **FIX**: improve routing and feedback. ([a63b1233](https://github.com/hpi-studyu/studyu/commit/a63b123384c6c3984ae45ae8d7fc4733a05f33ea))
 - **FIX**: dispose tab controller properly. ([a9984ef3](https://github.com/hpi-studyu/studyu/commit/a9984ef3a7c29bb5f14e30a25a05886f3d09e506))
 - **FIX**: load/save scheduling fields correctly. ([c107ef34](https://github.com/hpi-studyu/studyu/commit/c107ef34cdd04f0d6d34349731e00e0763e1a2b9))
 - **FIX**: readonly form control type. ([579ad4fb](https://github.com/hpi-studyu/studyu/commit/579ad4fbb24abcb306622702ff1c4c9f4bf8e10b))
 - **FIX**: resolve empty/skipped answer options for choice question. ([83675bc0](https://github.com/hpi-studyu/studyu/commit/83675bc033d2ba931ca1a9df61afcb207fde21bb))
 - **FIX**: resolve rebase issues. ([bcee831f](https://github.com/hpi-studyu/studyu/commit/bcee831f9194b7cf9df4d40d3c3467e0c3cdffbd))
 - **FIX**: make legacy designer work again. ([c9bf76f9](https://github.com/hpi-studyu/studyu/commit/c9bf76f90f509803692378df343ee56b750905a0))
 - **FIX**: correct study scaffold tab indices. ([e6ce889a](https://github.com/hpi-studyu/studyu/commit/e6ce889a8d99b5a9ecf9d8f42d01f8670f1193f7))
 - **FIX**: working with updated changes. ([844528ef](https://github.com/hpi-studyu/studyu/commit/844528ef77ac338ad4b584d8ad1e627d02f61bbd))
 - **FIX**: modify previewsrc. ([118d6e91](https://github.com/hpi-studyu/studyu/commit/118d6e9112191081c6dbcf74090933261a852da1))
 - **FIX**: app preview src not reloading. ([891cbfa9](https://github.com/hpi-studyu/studyu/commit/891cbfa9979d09a2e819aaa68a27671a7fb5aee2))
 - **FIX**: Revert to normal app preview. ([cf4adcfa](https://github.com/hpi-studyu/studyu/commit/cf4adcfa91eebb98645a1745396ee95154635b8a))
 - **FIX**: preview reset button. ([49dadadc](https://github.com/hpi-studyu/studyu/commit/49dadadc760023a11fffdb1b0f9bd247ba8142d4))
 - **FEAT**: add test modal. ([686be9e0](https://github.com/hpi-studyu/studyu/commit/686be9e0ba336de1e7878a164c312f59614a0350))
 - **FEAT**: update autosave indicator copy. ([b17e2d45](https://github.com/hpi-studyu/studyu/commit/b17e2d4540ee7491af7fb3e0b52031816187d142))
 - **FEAT**: improve LocalizationPicker, center horizontal table rows, reset minSplashTime. ([bd4f5f49](https://github.com/hpi-studyu/studyu/commit/bd4f5f4965769aa18ea9b3255e5340d22a530184))
 - **FEAT**: even more localization. ([bbb7ad71](https://github.com/hpi-studyu/studyu/commit/bbb7ad711eac9ce890b748dbf95832c816b0871a))
 - **FEAT**: update banner color. ([761fa600](https://github.com/hpi-studyu/studyu/commit/761fa600e2b7ffbc820574d8708add9689d5bc6c))
 - **FEAT**: wip add preview welcome modal. ([fdd73a59](https://github.com/hpi-studyu/studyu/commit/fdd73a5943c218d040480a4eb88f893537074a19))
 - **FEAT**: add consent items to participation section. ([6392c084](https://github.com/hpi-studyu/studyu/commit/6392c084206d5e3af7f3c493e7ea9359be7ff324))
 - **FEAT**: requirements and banner changes. ([28482963](https://github.com/hpi-studyu/studyu/commit/28482963e65c75e5bc6cc13b5c1a1022707887ee))
 - **FEAT**: new login/auth page design. ([aef206c6](https://github.com/hpi-studyu/studyu/commit/aef206c6fe94bb8873b1a8f65c7d24e8049eff90))
 - **FEAT**: redesign test page. ([e1f75216](https://github.com/hpi-studyu/studyu/commit/e1f75216d347559510ff43a0b894bca221af618f))
 - **FEAT**: add basic settings modal. ([23f9d0ea](https://github.com/hpi-studyu/studyu/commit/23f9d0eab22f89af35c3daaf275fa0998f4ba8a7))
 - **FEAT**: localize study design info page. ([f19b9a4a](https://github.com/hpi-studyu/studyu/commit/f19b9a4a9917a4dd6af3cdb641847d7990f85c91))
 - **FEAT**: wip send study to app. ([18949295](https://github.com/hpi-studyu/studyu/commit/18949295e7f494f0b2cf36203dad1499ba338c7b))
 - **FEAT**: Only load preview when requirements are met. ([6d647dcc](https://github.com/hpi-studyu/studyu/commit/6d647dcc8913e64545e63fba28f523c688d2d8cd))
 - **FEAT**: add readonly mode for study designer. ([357e73d4](https://github.com/hpi-studyu/studyu/commit/357e73d4ddf3da7cf9cc8c9da38780014d3cc092))
 - **FEAT**: add banner component. ([96ef1377](https://github.com/hpi-studyu/studyu/commit/96ef1377758a61722285c4ef1a994b3f47e76d57))
 - **FEAT**: fix scrollbar for 1-column layout. ([47e69348](https://github.com/hpi-studyu/studyu/commit/47e69348ae86af3f2fb4fa43b7d18de934771954))
 - **FEAT**: link localization. ([00990437](https://github.com/hpi-studyu/studyu/commit/00990437dc909e77eb8383e01d09f14f44cb6909))
 - **FEAT**: more localization. ([8dea2110](https://github.com/hpi-studyu/studyu/commit/8dea211039560a027764b5e46555c18efe35836e))
 - **FEAT**: add study icon. ([a57e3fb9](https://github.com/hpi-studyu/studyu/commit/a57e3fb9163677b7c0b0ec9e9a482e2e0a15a9be))
 - **FEAT**: study design general info. ([48842aea](https://github.com/hpi-studyu/studyu/commit/48842aeaff93216e0883db5c1f045fe12d2dc2a1))
 - **FEAT**: design study participation. ([17fbfa4a](https://github.com/hpi-studyu/studyu/commit/17fbfa4a9f36e28dfba883aec473053075ef84a7))
 - **FEAT**: design study interventions. ([71fc3794](https://github.com/hpi-studyu/studyu/commit/71fc3794d2c1e0e7ff655fbf5c37dd64bae6c4c5))
 - **FEAT**: add intervention icons & picker. ([e006df06](https://github.com/hpi-studyu/studyu/commit/e006df066cff6a163431125a289f169df5ad38ef))
 - **FEAT**: colored scale questions. ([305377d3](https://github.com/hpi-studyu/studyu/commit/305377d38d59f42c7d310a58b2b1b61cf85922c2))
 - **FEAT**: Add StudyU icons. ([bb1cb4f6](https://github.com/hpi-studyu/studyu/commit/bb1cb4f6c581b307186f1e4e423e9234392d83ba))
 - **FEAT**: styling fixes. ([8d74256c](https://github.com/hpi-studyu/studyu/commit/8d74256cb2022749ec08c223ce42fb9f74989582))
 - **FEAT**: provide translation without context dependency. ([cd0b0bcf](https://github.com/hpi-studyu/studyu/commit/cd0b0bcfd75c6286a26e4051cc41b46c42763f23))
 - **FEAT**: add studyu logo image to drawer. ([6c68bcd4](https://github.com/hpi-studyu/studyu/commit/6c68bcd4df4f29e4a6b2bd749b2e49ed71534035))
 - **FEAT**: rewrite localization and make language chooser working. ([c75fcf58](https://github.com/hpi-studyu/studyu/commit/c75fcf586333021a44c9bddad3cfe7eb78110b67))
 - **FEAT**: finish complete & redesigned question type sidepanel. ([6f88837b](https://github.com/hpi-studyu/studyu/commit/6f88837b7f3ee13c284632c0ea3c8b6dea135e53))
 - **FEAT**: localize auth pages. ([00f7d892](https://github.com/hpi-studyu/studyu/commit/00f7d892892b7e55d5257902807d32d6cc3cafe2))
 - **FEAT**: implement study registry properly. ([1cc329c0](https://github.com/hpi-studyu/studyu/commit/1cc329c0e2d119f19994b5f1be0f490a03ebb3b1))
 - **FEAT**: update theme and add appconfig repository. ([a504b577](https://github.com/hpi-studyu/studyu/commit/a504b57780af1c9d0c0ddacb14ceb417130eadb5))
 - **FEAT**: add scale question-type to app + improved annotation layout. ([169ef10d](https://github.com/hpi-studyu/studyu/commit/169ef10d145a0b4e9da104af9fd22817b1c14d82))
 - **FEAT**: remove flutterflow, add reactive forms, restructuring. ([b8554d3d](https://github.com/hpi-studyu/studyu/commit/b8554d3d3bdfca7bb189472cbc2d49ec606508e8))
 - **FEAT**: finish german localization. ([86ef9a7a](https://github.com/hpi-studyu/studyu/commit/86ef9a7abafd30a7992df3962e29508997991126))
 - **FEAT**: improve validation, copy, etc for study design & test mode. ([3b7fe99e](https://github.com/hpi-studyu/studyu/commit/3b7fe99e2847a169124a7ad0303cf8c2bc010ce0))
 - **FEAT**: implement study autosave. ([04e2ee0a](https://github.com/hpi-studyu/studyu/commit/04e2ee0a7bb43eef8a452fc080c8c7fafaea2cc0))
 - **FEAT**: styling improvements. ([ae790499](https://github.com/hpi-studyu/studyu/commit/ae790499f66db1b785c78b226b78c0999922f580))
 - **FEAT**: sync indicator when saving study. ([d1c7eb3b](https://github.com/hpi-studyu/studyu/commit/d1c7eb3b9502bf1187eed528c8cb3eeda257c2c0))
 - **FEAT**: enable screening logic for scale questions. ([4f956be1](https://github.com/hpi-studyu/studyu/commit/4f956be135f9b8c36304d22166c5b2a751be1ee3))
 - **FEAT**: localization chooser. ([ca9a14fe](https://github.com/hpi-studyu/studyu/commit/ca9a14fe760259fabed9c5e03f0ad64e84fae471))
 - **FEAT**: modify designer2 description. ([341488b0](https://github.com/hpi-studyu/studyu/commit/341488b00d4580d7c1eca8eb20acb17e95d3dc50))
 - **FEAT**: improve routing, implement password recovery, error handling. ([58f908d3](https://github.com/hpi-studyu/studyu/commit/58f908d30a9e796b6b48e08df8e32d87d0da54b6))
 - **FEAT**: add enrolled count + badge to access codes table. ([4e00fd1f](https://github.com/hpi-studyu/studyu/commit/4e00fd1f4967bc5d46c8fe89114a8d43aed699d3))
 - **FEAT**: improve tabbed navbar + allow disabled tabs. ([71e090c1](https://github.com/hpi-studyu/studyu/commit/71e090c1da21dea8c0dcb503944503e087dc8d76))
 - **FEAT**: dont record participant progress for launched studies in test mode. ([2dc6a8ca](https://github.com/hpi-studyu/studyu/commit/2dc6a8ca72785d8929b3ecf3451d352c893fabde))
 - **FEAT**: map forms to study schema & save. ([5753a68d](https://github.com/hpi-studyu/studyu/commit/5753a68da60e01ec8c46f66e50b68e0507b2b209))
 - **FEAT**: add password reset page, error management, and restructuring. ([4493ab97](https://github.com/hpi-studyu/studyu/commit/4493ab9794a2c77237a73b797a93825964c624a0))
 - **FEAT**: data export. ([1a099135](https://github.com/hpi-studyu/studyu/commit/1a099135d66b1a2bc25bfed8d1e10cf5c6e48a78))
 - **FEAT**: add scheduling form fields to measurement. ([e3ca9c17](https://github.com/hpi-studyu/studyu/commit/e3ca9c1759b596a765c29d1a32633f90f819acc7))
 - **FEAT**: fix designer form styles. ([db6a6c24](https://github.com/hpi-studyu/studyu/commit/db6a6c24d13a75afd75505cc289cf8d4ef291725))
 - **FEAT**: consistent icon theme. ([58cab8f0](https://github.com/hpi-studyu/studyu/commit/58cab8f0e2b8bd2c7568fe1980903ccb2c447c5a))
 - **FEAT**: test selective preview screens. ([df26f6f3](https://github.com/hpi-studyu/studyu/commit/df26f6f3374d9d3e5f68bc653a928cfe9f82e167))
 - **FEAT**: removed created at date from invite codes table. ([a8e35819](https://github.com/hpi-studyu/studyu/commit/a8e35819f8fd2325e312474d177e36afc7114513))
 - **FEAT**: improve empty states, disable shared tab, adjust padding. ([dbae5026](https://github.com/hpi-studyu/studyu/commit/dbae5026aa199f71fa595bbdd196040ca88a7bf8))
 - **FEAT**: theme styling improvements. ([bf2d34f6](https://github.com/hpi-studyu/studyu/commit/bf2d34f62b6b959cddbf5273cf9ffbcabb6dd2bf))
 - **FEAT**: add split layout. ([a1659e73](https://github.com/hpi-studyu/studyu/commit/a1659e73ee6ea80fec7de66ccf4f653bd6570367))
 - **FEAT**: add study design subnav. ([3c916d7f](https://github.com/hpi-studyu/studyu/commit/3c916d7faecc23b92306a65b5ccb4785d2784014))
 - **FEAT**: merge dev_designer-v2. ([d4aae759](https://github.com/hpi-studyu/studyu/commit/d4aae759dded62dbe70657a8a528683c54c4a0dc))
 - **FEAT**: add recruit tab with invite codes. ([0c971476](https://github.com/hpi-studyu/studyu/commit/0c971476305f9c6d01faeec670b6e907bdd0a458))
 - **FEAT**: add selective preview for eligibility check. ([af96450f](https://github.com/hpi-studyu/studyu/commit/af96450f0d98afd719acc1bce09b9148dc924123))
 - **FEAT**: add basic empty state to AsyncValueWidget. ([cb020498](https://github.com/hpi-studyu/studyu/commit/cb020498e315083d9fc8e3ecc70270c4e720746f))
 - **FEAT**: add confirmation modal for study deletion. ([1d7fee26](https://github.com/hpi-studyu/studyu/commit/1d7fee2623105744026c9308d03aac2fe3f89ffe))
 - **FEAT**: add password_reset functionality and main page scaffold. ([1798e9ff](https://github.com/hpi-studyu/studyu/commit/1798e9ff0661fa44a333ad984c0e6227a963c629))
 - **FEAT**: Open preview in new page, redesign. ([e47e67d1](https://github.com/hpi-studyu/studyu/commit/e47e67d176db1019567cb1e55630c53b678cb596))
 - **FEAT**: decouple preview app state from live app. ([82b0e3c4](https://github.com/hpi-studyu/studyu/commit/82b0e3c4b0dfe9d957a11563546fbb3ae328731e))
 - **FEAT**: refactor. ([041d7345](https://github.com/hpi-studyu/studyu/commit/041d734517e75873fed32dc0ec8c21c6bcdc80b7))
 - **FEAT**: perform requirements check. ([28e31dfb](https://github.com/hpi-studyu/studyu/commit/28e31dfb7e9b4e4f431c5d7e037f7d1ef0744634))
 - **FEAT**: make use of preview class. ([477ced8b](https://github.com/hpi-studyu/studyu/commit/477ced8b5ccfb0a6b964ec3df47e8e822ae8c327))
 - **FEAT**: add status badges & refactor dashboard table. ([00fd2a30](https://github.com/hpi-studyu/studyu/commit/00fd2a3015fba920095ee85a57bec3561751dfe7))
 - **FEAT**: implement publish flow. ([723a9204](https://github.com/hpi-studyu/studyu/commit/723a9204ac952e9ce8bfaf8ae3117d3a468366e9))
 - **FEAT**: add reset functionality to preview. ([cfe76a8a](https://github.com/hpi-studyu/studyu/commit/cfe76a8a6d96111495fde976f132165006c5bbd1))
 - **FEAT**: test designer changes. ([4a1c78ed](https://github.com/hpi-studyu/studyu/commit/4a1c78ed1f584e3fc09499eee2e1949531c40bcf))
 - **FEAT**: add consent validation. ([7b06a8ff](https://github.com/hpi-studyu/studyu/commit/7b06a8ff232469b6c24a000f8491e5abef1de43d))
 - **FEAT**: deeplink studyID to app to test study. ([ee6c02d3](https://github.com/hpi-studyu/studyu/commit/ee6c02d38e1677c2263c0f19e07f573af56258e6))
 - **FEAT**: improve phone frame styling for test mode. ([72bacb32](https://github.com/hpi-studyu/studyu/commit/72bacb3262a0e3896088744eb3a9e3a26b6cfb64))
 - **FEAT**: validation mechanisms with dynamic config for study draft, test, publish. ([66121be4](https://github.com/hpi-studyu/studyu/commit/66121be426d23fd0f848ba2dc85d1db6c68e0f81))
 - **FEAT**: Implement preview screen with app iframe. ([0c058c2d](https://github.com/hpi-studyu/studyu/commit/0c058c2dbfdabaf84d1bfa5152ebc8c38bac320b))
 - **FEAT**: login page restructure. ([74e547a9](https://github.com/hpi-studyu/studyu/commit/74e547a9766c7730a05f504a277725e0e764a0b7))
 - **FEAT**: login page revamp. ([654b28c4](https://github.com/hpi-studyu/studyu/commit/654b28c4061208e78c325d31ca163130040b0e86))
 - **FEAT**: modify login page. ([03e5afa3](https://github.com/hpi-studyu/studyu/commit/03e5afa33557478e61a8c86ff6fc839cd99e65ca))
 - **FEAT**: live preview. ([5ac4aac8](https://github.com/hpi-studyu/studyu/commit/5ac4aac8878f0dc58dffae56e566be1c2e3ad999))
 - **FEAT**: Fetch studies from Supabase and show on Dashboard. ([93541672](https://github.com/hpi-studyu/studyu/commit/93541672b64bef4edc3c12b57f14c2cc2f7f4805))
 - **FEAT**: refactor my_app, auth_store, router to use Riverpod, add login_page with Supabase connection. ([edec5c7c](https://github.com/hpi-studyu/studyu/commit/edec5c7c227dd521daa04742ebb42b5ed6922099))
 - **FEAT**: add new test login page imported from flutterflow. ([869f7372](https://github.com/hpi-studyu/studyu/commit/869f7372b250486b06de79113b2c5733a49e93ef))
 - **FEAT**: consistent theme & cleanup for auth widgets. ([200cd129](https://github.com/hpi-studyu/studyu/commit/200cd1290fe9d6de0110da18c76c19d15ea99aee))


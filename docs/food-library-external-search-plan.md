# Food Library External Search and Copy Plan

## Status

Implementation plan only. No database, model, or UI changes have been applied.

## Objective

Extend Food Library search so one query searches both:

- the participant's saved local food library; and
- a single, provider-agnostic external food library.

External results are copy candidates, not local items. Selecting one opens an editable draft. The item becomes local only after the participant reviews it and explicitly saves it.

Current third-party sources remain an internal implementation detail. UI must not name, filter, style, or report errors by individual provider. A future StudyU backend will aggregate, deduplicate, and rank external sources behind the same UI contract.

## Product terminology

Use provider-neutral language throughout UI:

- **My foods** — saved local entries.
- **External library** — aggregated external search results.
- **Copy to My foods** — action on an external result.
- **Review copied food** — editor title for a new external copy.
- **Save copy** — editor confirmation action.

Suggested search hint:

> Search My foods and external library

Suggested editor notice:

> **Copied from external library**  
> Review serving size and nutrition values before saving. Saving creates an independent item in My foods.

Suggested generic failure message:

> External library is currently unavailable.

All final strings must be localized. Suggested wording above is product guidance, not hard-coded widget text.

## Recommended user flow

### Empty query

1. Show the existing local Food Library unchanged.
2. Keep the existing All, Foods, and Meals filters.
3. Do not start an external request.
4. Expose the existing barcode scanner from the search field.

### Active text query

1. Filter local entries immediately.
2. Start external search after the existing 400 ms debounce.
3. Render results in one scroll view with distinct sections:

   ```text
   My foods
     [local entries]

   External library
     [external result]                       [Copy]
     [external result]                       [Copy]
   ```

4. Keep external results combined and ranked. Do not split them by provider.
5. Show external results for All and Foods filters only.
6. Selecting Meals cancels pending external search and shows local meals only.
7. Clearing the query removes external results immediately.

### Copy and review

1. User taps the external result row or its explicit **Copy** action.
2. Convert the selected external result into a new draft `FoodEntry`.
3. Generate fresh local identities for every copy attempt:
   - occurrence ID;
   - definition ID; and
   - provisional version ID.
4. Preserve internal provenance:
   - external source enum;
   - external identifier;
   - barcode;
   - original source metadata; and
   - product image metadata.
5. Open `FoodEntryScreen` in transient external-copy mode.
6. Show an inline, non-dismissible explanatory notice above nutrition fields.
7. Let the user review and edit all supported fields.
8. Back or Cancel discards the draft and performs no repository mutation.
9. Save returns the edited draft to Food Library.
10. Food Library calls `TemplateViewModel.saveFoodAsTemplate` only after that confirmation.
11. On success, refresh local entries and show a localized confirmation.
12. On failure, retain the edited draft and offer Retry, Continue editing, or explicit Discard.

### Barcode

Reuse the current scanner and route its result through the same copy-review-save flow:

```text
Scan barcode
  -> external food draft
  -> Review copied food
  -> Save copy
  -> local library entry
```

No scanner redesign or second import path should be added.

## Identity and persistence semantics

An external result is not a StudyU food definition. Copying it creates a new local definition with its initial local version; it does not create a version of an external entity.

### External result

`UnifiedFoodResult` remains transient:

- not added to `TemplateViewModel.foodTemplates`;
- no local `templateId`;
- provider identity remains internal metadata;
- may coexist with a local item having the same barcode or external ID; and
- may disappear when the search query changes without affecting an active draft.

### Draft copy

Conversion must happen when Copy is selected, not while displaying search results. Each conversion produces independent IDs and retains source metadata.

The editor must preserve:

- `id`;
- `foodId`;
- `foodVersionId`;
- `foodCode`;
- `externalId`;
- `source`; and
- `originalValues`.

The draft remains unpersisted until Save.

### Saved copy

After editor confirmation:

1. `TemplateViewModel.saveFoodAsTemplate` clones the edited draft.
2. `NutritionFoodRepository.saveTemplate` creates the local definition.
3. Backend mutation creates the authoritative persisted version ID.
4. Template reload makes the new entry visible under My foods.
5. The external result remains available and may be copied again.

No automatic deduplication is included initially. Multiple copies can be intentional and must receive independent local identities.

## Architecture boundary

```text
Food Library UI
    |
    v
FoodSearchViewModel
    |
    v
List<UnifiedFoodResult>
    |
    +-- current client-side source aggregation
    |
    `-- future StudyU backend aggregation and ranking
```

UI responsibilities:

- submit query;
- show local and external sections;
- show generic loading/error/empty states;
- start the copy flow; and
- persist only after user confirmation.

Search-layer responsibilities:

- query current external sources;
- combine and rank results;
- ignore stale responses;
- isolate partial source failures;
- paginate; and
- convert a selected unified result into a draft food entry.

Widgets must not:

- branch on an individual external provider;
- display provider names or provider-specific icons;
- expose provider-specific filters;
- show provider-specific errors; or
- know how provider requests are made.

Internal provenance remains available for debugging, attribution requirements, and later backend mapping, but is not shown in normal Food Library UI.

## Phased implementation

## Phase 1: Extract reusable external search boundary

### Goal

Allow Food Search and Food Library to reuse one provider-agnostic search model without creating an import cycle or duplicating API logic.

### Files

- `app/lib/screens/study/nutrition/food_search/food_search_view_model.dart`
- `app/lib/screens/study/nutrition/food_search_screen.dart`
- `app/test/screens/study/nutrition/food_search_view_model_test.dart`

### Changes

1. Convert `food_search_view_model.dart` from a `part` file into a normal importable Dart library.
2. Move the search callback typedefs into that module.
3. Keep existing behavior unchanged:
   - 400 ms debounce;
   - generation-based stale-response protection;
   - combined ranking;
   - partial failure handling;
   - pagination; and
   - disposal of pending timers.
4. Add one public provider-neutral conversion entry point:

   ```dart
   FoodEntry convertFoodResultToFoodEntry(UnifiedFoodResult result)
   ```

5. Keep any source-specific branching private inside the search/conversion module.
6. Update `food_search_screen.dart` to import the reusable module instead of declaring it as a part.
7. Re-export the reusable API from `food_search_screen.dart` if needed to preserve existing imports.
8. Replace source-specific conversion switches in callers with `convertFoodResultToFoodEntry`.

### Completion criteria

- Existing Food Search behavior is unchanged.
- Food Library can import `FoodSearchViewModel` without importing the full Food Search UI or creating a cycle.
- Calling conversion twice for the same result produces different local IDs.
- Barcode, external ID, source, and raw metadata survive conversion.

## Phase 2: Integrate external search into Food Library

### Goal

Search local entries immediately and external entries asynchronously on the same page.

### Files

- `app/lib/screens/study/nutrition/food_library_screen.dart`
- `app/lib/screens/study/nutrition/food_library.dart`
- `app/lib/screens/study/nutrition/food_item_components.dart`
- `app/lib/screens/study/nutrition/food_search/food_search_results_view.dart`

### Changes

1. Add an opt-in Food Library property:

   ```dart
   includeExternalLibrary: true
   ```

   Default it to `false` so direct `FoodLibrary` consumers remain local-only.

2. Enable it from `FoodLibraryScreen` in standalone and embedded modes.
3. Provide `FoodSearchViewModel` alongside the existing `TemplateViewModel`:
   - standalone screen owns both providers;
   - embedded screen creates only the external search model and reuses the ancestor `TemplateViewModel`.
4. Support injectable search callbacks for focused tests without making production widgets provider-aware.
5. Route search text to:
   - `TemplateViewModel.setSearchQuery` immediately; and
   - `FoodSearchViewModel.search` when external search is enabled and the active filter permits foods.
6. When Meals is selected, call `search('')` to cancel debounce and invalidate pending responses.
7. When All or Foods is selected again, restart the current non-empty external query.
8. Restructure the list so an empty local result does not short-circuit external loading or results.
9. Render generic sections:
   - My foods;
   - External library.
10. Reuse the existing food-card visual primitives. Extract only the common external-result body needed by both screens; keep selection controls and Copy controls in their respective wrappers.
11. External cards show an image or fallback, name, optional brand, serving and nutrition summary, and a text-plus-icon Copy action.
12. External cards do not show Edit, Delete, Duplicate, selection quantity, or provider labels.
13. Reuse existing `loadMore` behavior near the end of the scroll view without adding another pagination implementation.
14. Wire `FoodSearchBar.onBarcodeTap` to the existing barcode scanner when external library support is enabled.

### Completion criteria

- Empty query causes no external request.
- Local matching updates before external debounce completes.
- External loading does not hide local results.
- Clearing or replacing a query cannot allow stale results to reappear.
- External results appear only for All and Foods.
- Standalone and embedded Food Library screens work.
- `FoodLibrary` inside existing Food Search remains local-only.

## Phase 3: Add copy-review-save lifecycle

### Goal

Create a local item only after the user reviews and saves an external draft.

### Files

- `app/lib/screens/study/nutrition/food_library.dart`
- `app/lib/screens/study/nutrition/food_entry_screen.dart`
- `app/lib/screens/study/nutrition/template_view_model.dart` only if a small existing save helper needs reuse; no new persistence abstraction is planned.

### Changes

1. Add one Food Library handler shared by text-search and barcode results.
2. On Copy:
   - capture the selected immutable result;
   - convert it once into a fresh draft;
   - set a local in-progress flag; and
   - open `FoodEntryScreen` with `showSearchAction: false`.
3. Add a transient editor route parameter:

   ```dart
   bool isExternalLibraryCopy = false
   ```

4. Require an existing draft when `isExternalLibraryCopy` is true.
5. Do not infer copy mode from `FoodEntry.source`; later normal edits of imported items must not show the new-copy notice.
6. In external-copy mode:
   - use the Review copied food title;
   - show the inline explanatory notice;
   - use Save copy as the primary action; and
   - preserve the current editor fields and validation.
7. Keep persistence outside the editor:
   - editor returns the confirmed `FoodEntry`;
   - Food Library calls the existing `saveFoodAsTemplate` method;
   - Cancel returns `null` and performs no save.
8. Disable duplicate Copy actions while navigation or save is active.
9. On success:
   - let `TemplateViewModel` reload templates;
   - show confirmation; and
   - keep or clear the search query based on the least disruptive existing navigation behavior.
10. On persistence failure:
    - keep the edited draft in memory;
    - log the technical error;
    - show a generic localized message; and
    - offer Retry, Continue editing, or explicit Discard.

### Completion criteria

- Opening the editor performs zero repository saves.
- Cancel/back performs zero repository saves.
- Save performs exactly one template save.
- Every copy attempt receives fresh occurrence, definition, and provisional version IDs.
- Saved copies retain barcode and internal provenance metadata.
- Later editing a saved externally sourced item does not show the copy notice.
- Save failure never reports success or silently loses the draft.

## Phase 4: Localization and accessibility

### Goal

Make the generic external-library flow understandable without exposing individual sources.

### Files

- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_de.arb`
- generated localization Dart files
- affected Food Library and Food Entry widgets

### Localization additions

Add or reuse strings for:

- Search My foods and external library;
- My foods;
- External library;
- Copy;
- Copy-to-My-foods semantic label;
- Review copied food;
- external-copy explanation;
- Save copy;
- copy saved confirmation;
- generic external-library failure;
- generic copy-save failure; and
- Retry / Continue editing / Discard actions where existing strings do not fit.

Do not add source names or provider-specific error strings.

### Accessibility requirements

- Use a text-plus-icon Copy button with at least a 48 logical-pixel target.
- Include food name in button tooltip or semantic label.
- External status must be communicated by the section and action text, not color alone.
- Make search loading, result count, no-results, and error changes available as live-region status where practical.
- Use a visible icon and text in the editor notice.
- Keep keyboard activation through Material buttons and `InkWell`.
- Give meaningful image semantics or exclude duplicate image semantics when adjacent text already names the food.
- Respect existing reduced-animation behavior.

### Completion criteria

- English and German localization generation succeeds.
- No user-visible external-library text is hard-coded.
- No individual source name appears in the Food Library flow.
- Core actions are keyboard and screen-reader accessible.

## Phase 5: Focused tests and validation

### Search-model tests

File: `app/test/screens/study/nutrition/food_search_view_model_test.dart`

Add or retain tests for:

- replacing a query ignores late results from the old query;
- clearing a query ignores pending results;
- one failed internal source does not hide successful aggregated results;
- conversion creates fresh IDs on every call; and
- conversion preserves barcode, external ID, source, and original metadata.

### Food Library tests

File: `app/test/screens/study/nutrition/food_library_test.dart`

Use fake search callbacks and repository behavior. Verify:

- local and external matches can appear together;
- local matches appear before external debounce completes;
- an empty local result does not hide external loading/results;
- external cards expose Copy but no local management actions;
- Meals filter suppresses and invalidates external search;
- barcode and text results enter the same review flow;
- cancel performs no save;
- confirmation saves exactly once;
- persisted copy has fresh local identity and preserved provenance;
- generic external failure leaves local results usable; and
- retry can repeat a failed save without reconstructing the draft.

### Food editor tests

File: `app/test/screens/study/nutrition/food_entry_screen_test.dart`

Verify:

- external-copy mode exposes its review/accessibility contract;
- normal editing of an externally sourced saved item does not activate copy mode;
- edited output preserves identity and provenance fields; and
- discard returns no result.

Tests must assert behavior, state, navigation, identity, and accessibility contracts. Do not add golden tests or assertions tied only to exact colors, spacing, widget classes, icons, or incidental wording.

### Validation commands

Before any Flutter, Dart, FVM, or Melos command, check whether `rtk` is installed and prefix the command when available.

From `app/`:

```sh
command -v rtk
fvm flutter gen-l10n
fvm flutter test test/screens/study/nutrition/food_search_view_model_test.dart
fvm flutter test test/screens/study/nutrition/food_library_test.dart
fvm flutter test test/screens/study/nutrition/food_entry_screen_test.dart
```

When `rtk` is available, run the same FVM commands as `rtk fvm ...`.

From repository root, run the required final check:

```sh
scripts/pre-commit-check
```

## Loading, empty, and error behavior

### Empty query

- Show local library only.
- Do not show External library section.
- Do not issue external requests.

### External initial loading

- Keep local results interactive.
- Show loading only inside External library section.

### Partial internal-source failure

- Show available aggregated results.
- Do not expose which internal source failed.
- Do not replace useful results with a global error.

### Complete external failure

- Keep local results interactive.
- Show generic external-library failure and Retry inside the external section.

### No results

- Wait until local filtering and external search are complete.
- Show one query-specific no-results state when neither section has matches.
- Do not show a global no-results state while external search is still loading.

### Pagination

- Keep existing results visible.
- Show bottom loading progress.
- Request more results only for the current trimmed query.

### Save failure

- Keep edited draft in memory.
- Do not show success.
- Offer Retry, Continue editing, or explicit Discard.

## Acceptance criteria

- Food Library searches local and external entries from one field.
- Empty query never triggers external search.
- External results are grouped under one provider-neutral External library section.
- UI contains no individual source names, icons, filters, or errors.
- Local results update immediately; external results use existing debounce and stale-response protection.
- External cards provide an explicit Copy action.
- Barcode scan uses the same external-copy flow.
- Copy opens a fresh, editable, unpersisted local draft.
- Editor clearly explains that saving creates an independent local item.
- Cancel/back creates nothing.
- Save creates one new local definition and its initial authoritative version.
- Internal barcode and provenance metadata survive copying and editing.
- Recopying the same external result creates independent local items.
- Partial or complete external failures never hide usable local entries.
- Standalone and embedded Food Library surfaces work.
- Existing Food Search behavior remains unchanged.
- English and German localizations compile.
- Focused tests and `scripts/pre-commit-check` pass.

## Explicit non-goals

- No individual source names in UI.
- No source-specific filters, icons, sections, or error messages.
- No write-back or synchronization to external systems.
- No automatic refresh when external data changes.
- No duplicate detection or already-imported state.
- No bulk copy.
- No external meal import.
- No external browsing for an empty query.
- No cache or offline mirror.
- No barcode scanner redesign.
- No database schema change.
- No `FoodEntry` core-model change.
- No new dependency.
- No golden tests.

## Future backend migration

When the StudyU backend becomes the single external search source:

1. Replace current client-side external requests inside the search layer with one backend request.
2. Let the backend perform source aggregation, deduplication, ranking, and pagination.
3. Map the backend response to `UnifiedFoodResult`, or replace it with a normalized equivalent behind the same view-model API.
4. Keep Food Library widgets, generic section labels, copy flow, editor notice, and local persistence unchanged.
5. Keep provider provenance internal if required for auditing or attribution.

The UI boundary in this plan intentionally prevents that migration from becoming another Food Library redesign.

## Expected files changed during implementation

- `app/lib/screens/study/nutrition/food_search/food_search_view_model.dart`
- `app/lib/screens/study/nutrition/food_search_screen.dart`
- `app/lib/screens/study/nutrition/food_search/food_search_results_view.dart`
- `app/lib/screens/study/nutrition/food_item_components.dart`
- `app/lib/screens/study/nutrition/food_library_screen.dart`
- `app/lib/screens/study/nutrition/food_library.dart`
- `app/lib/screens/study/nutrition/food_entry_screen.dart`
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_de.arb`
- generated localization files
- `app/test/screens/study/nutrition/food_search_view_model_test.dart`
- `app/test/screens/study/nutrition/food_library_test.dart`
- `app/test/screens/study/nutrition/food_entry_screen_test.dart`

No new production dependency or database migration is expected.

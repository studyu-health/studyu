# UI Test Keys (MCP / Flutter Driver)

This document defines naming conventions for `ValueKey`s used for UI automation in StudyU.

## Why

- Stable selectors for MCP (`ByValueKey`) and Flutter Driver
- Less brittle than `ByText` (localization/copy changes)
- Faster and more deterministic automation

## Naming Convention

- Use `snake_case` strings
- Keep keys semantic and action-oriented
- Prefer stable IDs for dynamic items

Examples:

- Static button: `ValueKey('welcome_get_started')`
- Dynamic row item: `ValueKey('study_row_${item.id}')`
- Dynamic card: `ValueKey('intervention_card_${intervention.id}')`

## Scope Prefixes

Use a screen/feature prefix for readability:

- `welcome_*`
- `onboarding_*`
- `study_selection_*`
- `eligibility_*`
- `consent_*`
- `dashboard_*`
- `settings_*`
- `task_*`
- `filter_*`
- `study_row_*`
- `navbar_*`
- `form_*`
- `auth_*`

## Current High-Value Keys

### App (`app/`)

- Welcome: `welcome_about`, `welcome_contact`, `welcome_faq`, `welcome_get_started`
- Onboarding: `onboarding_back`, `onboarding_next`, `onboarding_done`
- Terms: `terms_continue`, `terms_checkbox`, `privacy_checkbox`, `imprint_button`
- Study selection: `study_selection_list`, `study_selection_invite_code`, `invite_code_dialog`, `invite_code_field`, `invite_code_submit`
- Eligibility: `eligibility_screen`, `eligibility_pass_banner`, `eligibility_fail_banner`, `eligibility_back`, `eligibility_continue`
- Consent: `consent_decline`, `consent_accept`, `consent_card_<index>`
- Intervention selection: `intervention_selection_screen`, `intervention_selection_list`, `intervention_card_<id>`, `intervention_selection_continue`
- Study/Journey overview: `study_overview_screen`, `study_overview_next`, `journey_overview_screen`, `journey_overview_next`
- Dashboard: `dashboard_contact`, `dashboard_report`, `dashboard_menu`, `dashboard_next_day`, `finished_report_history`, `finished_study_selection`
- Task: `questionnaire_complete`, `task_box_<taskId>`, `task_box_checkbox`
- Settings: `settings_screen`, `settings_language_dropdown`, `settings_analytics_switch`, `settings_opt_out`, `settings_delete_data`, `opt_out_confirm`, `delete_data_confirm`

### Designer (`designer_v2/`)

- Auth: `login_email`, `login_password`, `login_button`, `signup_email`, `signup_password`, `signup_password_confirm`, `signup_button`, `auth_email_field`, `auth_password_field`
- Dashboard table: `studies_table_rows`, `study_row_<id>`, `study_row_ink_<id>`, `pin_icon_<id>`, `study_row_actions_<id>`, `studies_table_column_header_<title>`
- Filters/Search: `filter_toggle_button`, `filter_toggle_button_labeled`, `search_button`, `search_field`
- Navigation: `navbar_tab_bar`, `navbar_tab_<index>`
- Form actions: `form_cancel_button`, `form_save_button`, `form_close_button`, `form_dismiss_button`
- Study actions: `publish_button`, `close_study_button`, `study_settings_button`, `study_overflow_menu`

## Implementation Guidance

- Add keys to **interactive** widgets first:
  - buttons, tabs, row actions, menu triggers, form fields, dialog confirms
- Keep keys stable across refactors
- Avoid including localized text in key names
- For repeated widgets, include unique stable identifiers (`id`, index as fallback)

## MCP Usage

Prefer:

- `finderType: ByValueKey`

Over:

- `ByText` (fallback only)

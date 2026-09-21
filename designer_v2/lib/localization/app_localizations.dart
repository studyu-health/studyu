import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @studyu.
  ///
  /// In en, this message translates to:
  /// **'StudyU'**
  String get studyu;

  /// No description provided for @loading_message.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading_message;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @language_select_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Select a language'**
  String get language_select_tooltip;

  /// No description provided for @locale_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get locale_en;

  /// No description provided for @locale_de.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get locale_de;

  /// No description provided for @navlink_error_home.
  ///
  /// In en, this message translates to:
  /// **'Go back home'**
  String get navlink_error_home;

  /// No description provided for @imprint.
  ///
  /// In en, this message translates to:
  /// **'Legal notice'**
  String get imprint;

  /// No description provided for @link_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get link_forgot_password;

  /// No description provided for @link_signup_description.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get link_signup_description;

  /// No description provided for @link_signup.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get link_signup;

  /// No description provided for @link_login_description.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get link_login_description;

  /// No description provided for @link_login_description2.
  ///
  /// In en, this message translates to:
  /// **'Log into your workspace?'**
  String get link_login_description2;

  /// No description provided for @link_login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get link_login;

  /// No description provided for @action_button_login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get action_button_login;

  /// No description provided for @action_button_signup.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get action_button_signup;

  /// No description provided for @action_button_password_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get action_button_password_reset;

  /// No description provided for @signup_tos_intro.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to StudyU\'s '**
  String get signup_tos_intro;

  /// No description provided for @signup_tos_terms_of_service.
  ///
  /// In en, this message translates to:
  /// **'terms of service '**
  String get signup_tos_terms_of_service;

  /// No description provided for @signup_tos_and.
  ///
  /// In en, this message translates to:
  /// **'and '**
  String get signup_tos_and;

  /// No description provided for @signup_tos_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get signup_tos_privacy_policy;

  /// No description provided for @signup_tos_outro.
  ///
  /// In en, this message translates to:
  /// **''**
  String get signup_tos_outro;

  /// No description provided for @login_page_title.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your workspace'**
  String get login_page_title;

  /// No description provided for @login_page_description.
  ///
  /// In en, this message translates to:
  /// **'Accelerate your research with digital N-of-1 studies.'**
  String get login_page_description;

  /// No description provided for @signup_page_title.
  ///
  /// In en, this message translates to:
  /// **'Create your workspace'**
  String get signup_page_title;

  /// No description provided for @signup_page_description.
  ///
  /// In en, this message translates to:
  /// **'Get started with digital N-of-1 studies for your research or clinical practice. Free, open source & open science!'**
  String get signup_page_description;

  /// No description provided for @password_forgot_page_title.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get password_forgot_page_title;

  /// No description provided for @password_forgot_page_description.
  ///
  /// In en, this message translates to:
  /// **'Enter the email associated with your account and we\'ll send an email with instructions to reset your password'**
  String get password_forgot_page_description;

  /// No description provided for @password_recover_page_title.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get password_recover_page_title;

  /// No description provided for @form_field_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get form_field_email;

  /// No description provided for @form_field_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get form_field_email_hint;

  /// No description provided for @form_field_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get form_field_password;

  /// No description provided for @form_field_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get form_field_password_hint;

  /// No description provided for @form_field_password_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get form_field_password_confirm;

  /// No description provided for @form_field_password_confirm_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter password again'**
  String get form_field_password_confirm_hint;

  /// No description provided for @form_field_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Must enter a valid email'**
  String get form_field_email_invalid;

  /// No description provided for @form_field_password_mustmatch.
  ///
  /// In en, this message translates to:
  /// **'Both passwords must match'**
  String get form_field_password_mustmatch;

  /// No description provided for @form_field_password_minlength.
  ///
  /// In en, this message translates to:
  /// **'Passwords must have a minimum of {minLength} characters'**
  String form_field_password_minlength(num minLength);

  /// No description provided for @form_field_password_new.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get form_field_password_new;

  /// No description provided for @form_field_password_new_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get form_field_password_new_hint;

  /// No description provided for @form_field_password_new_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get form_field_password_new_confirm;

  /// No description provided for @form_field_password_new_confirm_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password again'**
  String get form_field_password_new_confirm_hint;

  /// No description provided for @notification_password_reset_check_email.
  ///
  /// In en, this message translates to:
  /// **'Check your email for a password reset link!'**
  String get notification_password_reset_check_email;

  /// No description provided for @notification_password_reset_success.
  ///
  /// In en, this message translates to:
  /// **'Password was reset successfully'**
  String get notification_password_reset_success;

  /// No description provided for @notification_credentials_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get notification_credentials_invalid;

  /// No description provided for @notification_user_already_registered.
  ///
  /// In en, this message translates to:
  /// **'User already registered'**
  String get notification_user_already_registered;

  /// No description provided for @form_field_password_current.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get form_field_password_current;

  /// No description provided for @form_field_password_current_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get form_field_password_current_hint;

  /// No description provided for @form_field_password_current_invalid.
  ///
  /// In en, this message translates to:
  /// **'Current password is invalid'**
  String get form_field_password_current_invalid;

  /// No description provided for @form_field_reset_password.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get form_field_reset_password;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get change_password;

  /// No description provided for @password_change_description.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password for your account'**
  String get password_change_description;

  /// No description provided for @navlink_my_studies.
  ///
  /// In en, this message translates to:
  /// **'My Studies'**
  String get navlink_my_studies;

  /// No description provided for @navlink_shared_studies.
  ///
  /// In en, this message translates to:
  /// **'Shared With Me'**
  String get navlink_shared_studies;

  /// No description provided for @navlink_public_studies.
  ///
  /// In en, this message translates to:
  /// **'Study Registry'**
  String get navlink_public_studies;

  /// No description provided for @navlink_public_studies_tooltip.
  ///
  /// In en, this message translates to:
  /// **'The study registry is a public collection of studies conducted on the StudyU \nplatform. In the spirit of open science, it fosters collaboration and transparency \namong all researchers and clinicians on the platform.'**
  String get navlink_public_studies_tooltip;

  /// No description provided for @navlink_public_studies_description.
  ///
  /// In en, this message translates to:
  /// **'The study registry is a public collection of studies conducted on the StudyU platform. In the spirit of open science, it fosters collaboration and transparency among all researchers and clinicians on the platform.'**
  String get navlink_public_studies_description;

  /// No description provided for @navlink_account_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navlink_account_settings;

  /// No description provided for @navlink_logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get navlink_logout;

  /// No description provided for @date_format.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get date_format;

  /// No description provided for @time_format.
  ///
  /// In en, this message translates to:
  /// **'Time format'**
  String get time_format;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @date_format_iso.
  ///
  /// In en, this message translates to:
  /// **'ISO (2024-12-31)'**
  String get date_format_iso;

  /// No description provided for @date_format_european.
  ///
  /// In en, this message translates to:
  /// **'European (31/12/2024)'**
  String get date_format_european;

  /// No description provided for @date_format_us.
  ///
  /// In en, this message translates to:
  /// **'US (12/31/2024)'**
  String get date_format_us;

  /// No description provided for @date_format_german.
  ///
  /// In en, this message translates to:
  /// **'German (31.12.2024)'**
  String get date_format_german;

  /// No description provided for @time_format_12_hour.
  ///
  /// In en, this message translates to:
  /// **'12-hour (2:30 PM)'**
  String get time_format_12_hour;

  /// No description provided for @time_format_24_hour.
  ///
  /// In en, this message translates to:
  /// **'24-hour (14:30)'**
  String get time_format_24_hour;

  /// No description provided for @study_status_draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get study_status_draft;

  /// No description provided for @study_status_draft_description.
  ///
  /// In en, this message translates to:
  /// **'This study is still being drafted.'**
  String get study_status_draft_description;

  /// No description provided for @study_status_running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get study_status_running;

  /// No description provided for @study_status_running_description.
  ///
  /// In en, this message translates to:
  /// **'This study is currently in progress.'**
  String get study_status_running_description;

  /// No description provided for @study_status_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get study_status_closed;

  /// No description provided for @study_status_closed_description.
  ///
  /// In en, this message translates to:
  /// **'This study has been completed.\nNew participants can no longer enroll.'**
  String get study_status_closed_description;

  /// No description provided for @participation_open_who.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get participation_open_who;

  /// No description provided for @participation_open_who_description.
  ///
  /// In en, this message translates to:
  /// **'All StudyU users may enroll to the study in the StudyU App.'**
  String get participation_open_who_description;

  /// No description provided for @participation_invite_who.
  ///
  /// In en, this message translates to:
  /// **'Invite-only'**
  String get participation_invite_who;

  /// No description provided for @participation_invite_who_description.
  ///
  /// In en, this message translates to:
  /// **'Only participants with an invite code can enroll in the StudyU App.'**
  String get participation_invite_who_description;

  /// No description provided for @participation_open_as_adjective.
  ///
  /// In en, this message translates to:
  /// **'open to everyone'**
  String get participation_open_as_adjective;

  /// No description provided for @participation_invite_as_adjective.
  ///
  /// In en, this message translates to:
  /// **'invite-only'**
  String get participation_invite_as_adjective;

  /// No description provided for @participation_open_launch_description.
  ///
  /// In en, this message translates to:
  /// **'Once launched, all users of the StudyU platform can enroll in your study as long as they meet your screening criteria.'**
  String get participation_open_launch_description;

  /// No description provided for @participation_invite_launch_description.
  ///
  /// In en, this message translates to:
  /// **'Once launched, you can invite participants by sending them a code to access and enroll in your study'**
  String get participation_invite_launch_description;

  /// No description provided for @phase_sequence_alternating.
  ///
  /// In en, this message translates to:
  /// **'Alternating (AB AB)'**
  String get phase_sequence_alternating;

  /// No description provided for @phase_sequence_counterbalanced.
  ///
  /// In en, this message translates to:
  /// **'Counterbalanced (AB BA)'**
  String get phase_sequence_counterbalanced;

  /// No description provided for @phase_sequence_random.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get phase_sequence_random;

  /// No description provided for @phase_sequence_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get phase_sequence_custom;

  /// No description provided for @phase_sequence_custom_label.
  ///
  /// In en, this message translates to:
  /// **'Custom sequence'**
  String get phase_sequence_custom_label;

  /// No description provided for @phase_sequence_custom_label_help.
  ///
  /// In en, this message translates to:
  /// **'Enter a sequence of interventions by using the letters A and B'**
  String get phase_sequence_custom_label_help;

  /// No description provided for @form_enrollment_option_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get form_enrollment_option_open;

  /// No description provided for @form_enrollment_option_invite.
  ///
  /// In en, this message translates to:
  /// **'Private (Invite-only)'**
  String get form_enrollment_option_invite;

  /// No description provided for @notification_code_deleted.
  ///
  /// In en, this message translates to:
  /// **'Invite code deleted'**
  String get notification_code_deleted;

  /// No description provided for @notification_code_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get notification_code_clipboard;

  /// No description provided for @notification_invite_code_copied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied'**
  String get notification_invite_code_copied;

  /// No description provided for @notification_invite_link_copied.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied'**
  String get notification_invite_link_copied;

  /// No description provided for @notification_invitation_copied.
  ///
  /// In en, this message translates to:
  /// **'Invitation copied'**
  String get notification_invitation_copied;

  /// No description provided for @action_button_new_study.
  ///
  /// In en, this message translates to:
  /// **'New study'**
  String get action_button_new_study;

  /// No description provided for @action_button_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get action_button_retry;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @navlink_all_studies.
  ///
  /// In en, this message translates to:
  /// **'All Studies'**
  String get navlink_all_studies;

  /// No description provided for @studies_list_header_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get studies_list_header_title;

  /// No description provided for @studies_list_header_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get studies_list_header_status;

  /// No description provided for @studies_list_header_participation.
  ///
  /// In en, this message translates to:
  /// **'Participation'**
  String get studies_list_header_participation;

  /// No description provided for @studies_list_header_created_at.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get studies_list_header_created_at;

  /// No description provided for @studies_list_header_participants_enrolled.
  ///
  /// In en, this message translates to:
  /// **'Enrolled'**
  String get studies_list_header_participants_enrolled;

  /// No description provided for @studies_list_header_participants_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get studies_list_header_participants_active;

  /// No description provided for @studies_list_header_participants_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get studies_list_header_participants_completed;

  /// No description provided for @studies_not_found.
  ///
  /// In en, this message translates to:
  /// **'No Studies found'**
  String get studies_not_found;

  /// No description provided for @modify_query.
  ///
  /// In en, this message translates to:
  /// **'Modify your query'**
  String get modify_query;

  /// No description provided for @studies_count_total.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{1 study} other{{total} studies}}'**
  String studies_count_total(int total);

  /// No description provided for @studies_count_filtered.
  ///
  /// In en, this message translates to:
  /// **'{visible} of {total, plural, =1{1 study} other{{total} studies}}'**
  String studies_count_filtered(int visible, int total);

  /// No description provided for @studies_filter_server_side_unsupported.
  ///
  /// In en, this message translates to:
  /// **'This filter can\'t be used here right now. Clear the filter and try again.'**
  String get studies_filter_server_side_unsupported;

  /// No description provided for @studies_empty.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any studies yet'**
  String get studies_empty;

  /// No description provided for @studies_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Build your own study from scratch or create a new draft copy from an already published study!'**
  String get studies_empty_description;

  /// No description provided for @studies_empty_public.
  ///
  /// In en, this message translates to:
  /// **'No public studies found'**
  String get studies_empty_public;

  /// No description provided for @studies_empty_public_description.
  ///
  /// In en, this message translates to:
  /// **'There are no studies in the public registry matching your current filters.'**
  String get studies_empty_public_description;

  /// No description provided for @studies_empty_shared.
  ///
  /// In en, this message translates to:
  /// **'No shared studies found'**
  String get studies_empty_shared;

  /// No description provided for @studies_empty_shared_description.
  ///
  /// In en, this message translates to:
  /// **'No studies have been shared with you yet.'**
  String get studies_empty_shared_description;

  /// No description provided for @studies_end_of_list.
  ///
  /// In en, this message translates to:
  /// **'All studies loaded.'**
  String get studies_end_of_list;

  /// No description provided for @studies_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load studies. Try again.'**
  String get studies_load_failed;

  /// No description provided for @navlink_learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navlink_learn;

  /// No description provided for @navlink_study_design.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get navlink_study_design;

  /// No description provided for @navlink_study_test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get navlink_study_test;

  /// No description provided for @navlink_study_recruit.
  ///
  /// In en, this message translates to:
  /// **'Recruit'**
  String get navlink_study_recruit;

  /// No description provided for @navlink_study_monitor.
  ///
  /// In en, this message translates to:
  /// **'Monitor'**
  String get navlink_study_monitor;

  /// No description provided for @navlink_study_analyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get navlink_study_analyze;

  /// No description provided for @navlink_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get navlink_share;

  /// No description provided for @navlink_study_design_info.
  ///
  /// In en, this message translates to:
  /// **'Study Info'**
  String get navlink_study_design_info;

  /// No description provided for @navlink_study_design_enrollment.
  ///
  /// In en, this message translates to:
  /// **'Participation'**
  String get navlink_study_design_enrollment;

  /// No description provided for @navlink_study_design_interventions.
  ///
  /// In en, this message translates to:
  /// **'Interventions'**
  String get navlink_study_design_interventions;

  /// No description provided for @navlink_study_design_measurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get navlink_study_design_measurements;

  /// No description provided for @navlink_unavailable_tooltip.
  ///
  /// In en, this message translates to:
  /// **'This page is not available to you'**
  String get navlink_unavailable_tooltip;

  /// No description provided for @study_settings.
  ///
  /// In en, this message translates to:
  /// **'Study settings'**
  String get study_settings;

  /// No description provided for @study_settings_publish_study.
  ///
  /// In en, this message translates to:
  /// **'Publish study'**
  String get study_settings_publish_study;

  /// No description provided for @study_settings_publish_study_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Other researchers and clinicians will be able to access, test, review or create a \ncopy of your study design. They won\'t be able to access any data related to \nin-progress studies such as participants or study results (your study\'s \nRecruit, Monitor & Analyze pages will be unavailable).'**
  String get study_settings_publish_study_tooltip;

  /// No description provided for @study_settings_publish_study_launch_description.
  ///
  /// In en, this message translates to:
  /// **'To facilitate collaboration among researchers and clinicians, I agree that the my study will be published to the StudyU study registry for others. (Other researchers and clinicians will be able to contact you and review the study design, but they won\'t be able to access participation or result data unless shared explicitly)'**
  String get study_settings_publish_study_launch_description;

  /// No description provided for @study_settings_publish_results.
  ///
  /// In en, this message translates to:
  /// **'Publish results'**
  String get study_settings_publish_results;

  /// No description provided for @study_settings_publish_results_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Make your anonymized study results & data available in the study registry. \nOther researchers and clinicians will be able to access, export and \nanalyze the results from your study (the Analyze page will be available). \n This will automatically publish your study design to the registry.'**
  String get study_settings_publish_results_tooltip;

  /// No description provided for @action_button_study_launch.
  ///
  /// In en, this message translates to:
  /// **'Launch'**
  String get action_button_study_launch;

  /// No description provided for @action_button_study_close.
  ///
  /// In en, this message translates to:
  /// **'Close study'**
  String get action_button_study_close;

  /// No description provided for @notification_study_deleted.
  ///
  /// In en, this message translates to:
  /// **'Study was deleted'**
  String get notification_study_deleted;

  /// No description provided for @notification_study_closed.
  ///
  /// In en, this message translates to:
  /// **'Study was closed'**
  String get notification_study_closed;

  /// No description provided for @notification_study_closed_description.
  ///
  /// In en, this message translates to:
  /// **'New participants can no longer enroll in this study.'**
  String get notification_study_closed_description;

  /// No description provided for @dialog_study_close_title.
  ///
  /// In en, this message translates to:
  /// **'Close participation?'**
  String get dialog_study_close_title;

  /// No description provided for @dialog_study_close_description.
  ///
  /// In en, this message translates to:
  /// **'Are you sure that you want to stop new enrollments for this study? New participants can no longer join, but those who are already enrolled can still continue. This action cannot be undone.'**
  String get dialog_study_close_description;

  /// No description provided for @dialog_study_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete?'**
  String get dialog_study_delete_title;

  /// No description provided for @dialog_study_delete_description.
  ///
  /// In en, this message translates to:
  /// **'Deleting this study permanently removes the study setup and all stored study data.'**
  String get dialog_study_delete_description;

  /// No description provided for @dialog_study_delete_warning_intro.
  ///
  /// In en, this message translates to:
  /// **'Before deleting, save a backup and consider whether closing the study is enough.'**
  String get dialog_study_delete_warning_intro;

  /// No description provided for @dialog_study_delete_backup_step.
  ///
  /// In en, this message translates to:
  /// **'Save the study definition and collected data as a backup before deleting.'**
  String get dialog_study_delete_backup_step;

  /// No description provided for @dialog_study_delete_close_step.
  ///
  /// In en, this message translates to:
  /// **'Stop new enrollments while keeping the study and existing data available.'**
  String get dialog_study_delete_close_step;

  /// No description provided for @dialog_study_delete_download_backup.
  ///
  /// In en, this message translates to:
  /// **'Download backup'**
  String get dialog_study_delete_download_backup;

  /// No description provided for @dialog_study_delete_data_confirmation.
  ///
  /// In en, this message translates to:
  /// **'I understand that the study and all associated data will be deleted forever and cannot be retrieved again.'**
  String get dialog_study_delete_data_confirmation;

  /// No description provided for @dialog_study_delete_participant_confirmation.
  ///
  /// In en, this message translates to:
  /// **'I understand that current participants will not be able to continue their study and that all data from current and past participants will be deleted for them and for me.'**
  String get dialog_study_delete_participant_confirmation;

  /// No description provided for @dialog_study_delete_irreversible_confirmation.
  ///
  /// In en, this message translates to:
  /// **'I understand that my decision is final and irreversible and that all data is completely deleted and cannot be restored again.'**
  String get dialog_study_delete_irreversible_confirmation;

  /// No description provided for @dialog_study_delete_data_confirmation_emphasis_1.
  ///
  /// In en, this message translates to:
  /// **'deleted forever'**
  String get dialog_study_delete_data_confirmation_emphasis_1;

  /// No description provided for @dialog_study_delete_data_confirmation_emphasis_2.
  ///
  /// In en, this message translates to:
  /// **'cannot be retrieved again'**
  String get dialog_study_delete_data_confirmation_emphasis_2;

  /// No description provided for @dialog_study_delete_participant_confirmation_emphasis_1.
  ///
  /// In en, this message translates to:
  /// **'current participants will not be able to continue'**
  String get dialog_study_delete_participant_confirmation_emphasis_1;

  /// No description provided for @dialog_study_delete_participant_confirmation_emphasis_2.
  ///
  /// In en, this message translates to:
  /// **'all data from current and past participants'**
  String get dialog_study_delete_participant_confirmation_emphasis_2;

  /// No description provided for @dialog_study_delete_irreversible_confirmation_emphasis_1.
  ///
  /// In en, this message translates to:
  /// **'final and irreversible'**
  String get dialog_study_delete_irreversible_confirmation_emphasis_1;

  /// No description provided for @dialog_study_delete_irreversible_confirmation_emphasis_2.
  ///
  /// In en, this message translates to:
  /// **'cannot be restored again'**
  String get dialog_study_delete_irreversible_confirmation_emphasis_2;

  /// No description provided for @dialog_study_delete_type_name_instruction.
  ///
  /// In en, this message translates to:
  /// **'Type the study name \"{studyName}\" to confirm deletion.'**
  String dialog_study_delete_type_name_instruction(Object studyName);

  /// No description provided for @dialog_study_delete_type_name_label.
  ///
  /// In en, this message translates to:
  /// **'Study name'**
  String get dialog_study_delete_type_name_label;

  /// No description provided for @dialog_study_close_type_name_instruction.
  ///
  /// In en, this message translates to:
  /// **'Enter the title of the study \"{studyName}\" to confirm that you want to close it:'**
  String dialog_study_close_type_name_instruction(Object studyName);

  /// No description provided for @dialog_study_close_type_name_label.
  ///
  /// In en, this message translates to:
  /// **'Title of the study to close'**
  String get dialog_study_close_type_name_label;

  /// No description provided for @dialog_study_close_irreversible_confirmation.
  ///
  /// In en, this message translates to:
  /// **'I understand that closing participation is final and cannot be reversed.'**
  String get dialog_study_close_irreversible_confirmation;

  /// No description provided for @dialog_study_delete_close_instead.
  ///
  /// In en, this message translates to:
  /// **'Review closing instead'**
  String get dialog_study_delete_close_instead;

  /// No description provided for @dialog_study_title_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Study title does not match'**
  String get dialog_study_title_mismatch;

  /// No description provided for @dialog_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete {subject}?'**
  String dialog_delete_title(Object subject);

  /// No description provided for @dialog_delete_description.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this {subject}? This action cannot be undone.'**
  String dialog_delete_description(Object subject);

  /// No description provided for @dialog_remove_title.
  ///
  /// In en, this message translates to:
  /// **'Remove {subject}?'**
  String dialog_remove_title(Object subject);

  /// No description provided for @dialog_remove_description.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this {subject}? This action cannot be undone.'**
  String dialog_remove_description(Object subject);

  /// No description provided for @dialog_subject_study.
  ///
  /// In en, this message translates to:
  /// **'study'**
  String get dialog_subject_study;

  /// No description provided for @dialog_subject_item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get dialog_subject_item;

  /// No description provided for @dialog_subject_question.
  ///
  /// In en, this message translates to:
  /// **'question'**
  String get dialog_subject_question;

  /// No description provided for @dialog_subject_screener_question.
  ///
  /// In en, this message translates to:
  /// **'screener question'**
  String get dialog_subject_screener_question;

  /// No description provided for @dialog_subject_answer_option.
  ///
  /// In en, this message translates to:
  /// **'answer option'**
  String get dialog_subject_answer_option;

  /// No description provided for @dialog_subject_intervention.
  ///
  /// In en, this message translates to:
  /// **'intervention'**
  String get dialog_subject_intervention;

  /// No description provided for @dialog_subject_intervention_task.
  ///
  /// In en, this message translates to:
  /// **'intervention task'**
  String get dialog_subject_intervention_task;

  /// No description provided for @dialog_subject_survey.
  ///
  /// In en, this message translates to:
  /// **'survey'**
  String get dialog_subject_survey;

  /// No description provided for @dialog_subject_consent_item.
  ///
  /// In en, this message translates to:
  /// **'consent item'**
  String get dialog_subject_consent_item;

  /// No description provided for @dialog_subject_report_section.
  ///
  /// In en, this message translates to:
  /// **'report section'**
  String get dialog_subject_report_section;

  /// No description provided for @dialog_subject_invite_code.
  ///
  /// In en, this message translates to:
  /// **'invite code'**
  String get dialog_subject_invite_code;

  /// No description provided for @dialog_delete_invite_code_title.
  ///
  /// In en, this message translates to:
  /// **'Delete invite code?'**
  String get dialog_delete_invite_code_title;

  /// No description provided for @dialog_delete_invite_code_message.
  ///
  /// In en, this message translates to:
  /// **'Anyone with invite code {code} will no longer be able to use it.'**
  String dialog_delete_invite_code_message(Object code);

  /// No description provided for @dialog_subject_fitbit_credentials.
  ///
  /// In en, this message translates to:
  /// **'fitbit credentials'**
  String get dialog_subject_fitbit_credentials;

  /// No description provided for @form_question_create.
  ///
  /// In en, this message translates to:
  /// **'New Question'**
  String get form_question_create;

  /// No description provided for @form_question_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Question'**
  String get form_question_edit;

  /// No description provided for @form_question_readonly.
  ///
  /// In en, this message translates to:
  /// **'View Question'**
  String get form_question_readonly;

  /// No description provided for @form_field_question.
  ///
  /// In en, this message translates to:
  /// **'Your question'**
  String get form_field_question;

  /// No description provided for @form_field_question_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter the question that the participant will be prompted with in the app'**
  String get form_field_question_tooltip;

  /// No description provided for @form_field_question_required.
  ///
  /// In en, this message translates to:
  /// **'Your question must not be empty'**
  String get form_field_question_required;

  /// No description provided for @form_field_question_help_text.
  ///
  /// In en, this message translates to:
  /// **'Question help text'**
  String get form_field_question_help_text;

  /// No description provided for @form_field_question_help_text_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a text that is shown with a help icon next to the question in the app'**
  String get form_field_question_help_text_tooltip;

  /// No description provided for @form_field_question_help_text_hint.
  ///
  /// In en, this message translates to:
  /// **'Provide additional context, help or instructions for the question'**
  String get form_field_question_help_text_hint;

  /// No description provided for @form_field_question_help_text_add.
  ///
  /// In en, this message translates to:
  /// **'Add a help text'**
  String get form_field_question_help_text_add;

  /// No description provided for @form_field_question_help_text_add_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a text that is shown with a help icon next to the question in the app'**
  String get form_field_question_help_text_add_tooltip;

  /// No description provided for @form_field_question_response_options.
  ///
  /// In en, this message translates to:
  /// **'Response options'**
  String get form_field_question_response_options;

  /// No description provided for @form_field_question_response_options_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Define the options that participants can answer your question with'**
  String get form_field_question_response_options_tooltip;

  /// No description provided for @form_field_question_response_options_description.
  ///
  /// In en, this message translates to:
  /// **'Choose the response type that best matches your question and define the response options according to the data you want to collect.'**
  String get form_field_question_response_options_description;

  /// No description provided for @question_type_choice.
  ///
  /// In en, this message translates to:
  /// **'Choice'**
  String get question_type_choice;

  /// No description provided for @question_type_free_text.
  ///
  /// In en, this message translates to:
  /// **'Free text'**
  String get question_type_free_text;

  /// No description provided for @question_type_pain.
  ///
  /// In en, this message translates to:
  /// **'Pain Tracker'**
  String get question_type_pain;

  /// No description provided for @question_type_pain_description.
  ///
  /// In en, this message translates to:
  /// **'Participants can select one or more body parts on a diagram and assign a pain level to each selected part using a pain scale. This is useful for tracking localized pain.'**
  String get question_type_pain_description;

  /// No description provided for @question_type_pain_preview_title.
  ///
  /// In en, this message translates to:
  /// **'In-App Preview'**
  String get question_type_pain_preview_title;

  /// No description provided for @question_type_pain_preview_description.
  ///
  /// In en, this message translates to:
  /// **'Below is a simplified representation of how the pain selection interface will appear to participants in the StudyU app. They will be able to tap on body parts to select them and then assign a pain level.'**
  String get question_type_pain_preview_description;

  /// No description provided for @question_type_pain_front_view.
  ///
  /// In en, this message translates to:
  /// **'Front View'**
  String get question_type_pain_front_view;

  /// No description provided for @question_type_pain_back_view.
  ///
  /// In en, this message translates to:
  /// **'Back View'**
  String get question_type_pain_back_view;

  /// No description provided for @question_type_pain_functionality_title.
  ///
  /// In en, this message translates to:
  /// **'Functionality'**
  String get question_type_pain_functionality_title;

  /// No description provided for @question_type_pain_functionality_description.
  ///
  /// In en, this message translates to:
  /// **'When a participant taps on a body part, a dialog appears where they can select a pain level. Each selected body part can have a different pain level. The collected data includes the identified body parts and their corresponding pain scores.'**
  String get question_type_pain_functionality_description;

  /// No description provided for @question_type_bool.
  ///
  /// In en, this message translates to:
  /// **'Yes/no'**
  String get question_type_bool;

  /// No description provided for @question_type_scale.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get question_type_scale;

  /// No description provided for @question_type_image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get question_type_image;

  /// No description provided for @question_type_audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get question_type_audio;

  /// No description provided for @question_type_fitbit.
  ///
  /// In en, this message translates to:
  /// **'Fitbit'**
  String get question_type_fitbit;

  /// No description provided for @form_array_response_options_bool_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get form_array_response_options_bool_yes;

  /// No description provided for @form_array_response_options_bool_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get form_array_response_options_bool_no;

  /// No description provided for @form_field_response_pain.
  ///
  /// In en, this message translates to:
  /// **'Pain Tracker'**
  String get form_field_response_pain;

  /// No description provided for @form_field_response_image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get form_field_response_image;

  /// No description provided for @form_field_response_audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get form_field_response_audio;

  /// No description provided for @form_field_response_audio_max_duration_label.
  ///
  /// In en, this message translates to:
  /// **'Maximum recording duration in seconds'**
  String get form_field_response_audio_max_duration_label;

  /// No description provided for @form_field_response_choice_multiple.
  ///
  /// In en, this message translates to:
  /// **'Allow multiple selections'**
  String get form_field_response_choice_multiple;

  /// No description provided for @form_field_response_choice_multiple_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Participants can select more than one answer.'**
  String get form_field_response_choice_multiple_tooltip;

  /// No description provided for @form_field_response_choice_required.
  ///
  /// In en, this message translates to:
  /// **'Require at least one selection'**
  String get form_field_response_choice_required;

  /// No description provided for @form_field_response_choice_required_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Require the participant to select at least one response option.'**
  String get form_field_response_choice_required_tooltip;

  /// No description provided for @form_array_response_options_choice_new.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get form_array_response_options_choice_new;

  /// No description provided for @form_array_response_options_choice_hint.
  ///
  /// In en, this message translates to:
  /// **'Option'**
  String get form_array_response_options_choice_hint;

  /// No description provided for @form_field_response_scale_min_label.
  ///
  /// In en, this message translates to:
  /// **'Custom low label'**
  String get form_field_response_scale_min_label;

  /// No description provided for @form_field_response_scale_min_label_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a custom label to display at the value\'s position on the scale'**
  String get form_field_response_scale_min_label_tooltip;

  /// No description provided for @form_field_response_scale_min_value.
  ///
  /// In en, this message translates to:
  /// **'Low value'**
  String get form_field_response_scale_min_value;

  /// No description provided for @form_field_response_scale_max_label.
  ///
  /// In en, this message translates to:
  /// **'Custom high label'**
  String get form_field_response_scale_max_label;

  /// No description provided for @form_field_response_scale_max_label_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a custom label to display at the value\'s position on the scale'**
  String get form_field_response_scale_max_label_tooltip;

  /// No description provided for @form_field_response_scale_max_value.
  ///
  /// In en, this message translates to:
  /// **'High value'**
  String get form_field_response_scale_max_value;

  /// No description provided for @form_field_response_scale_label_hint.
  ///
  /// In en, this message translates to:
  /// **'Optional label'**
  String get form_field_response_scale_label_hint;

  /// No description provided for @form_array_response_scale_mid_values.
  ///
  /// In en, this message translates to:
  /// **'See mid-values'**
  String get form_array_response_scale_mid_values;

  /// No description provided for @form_array_response_scale_mid_values_dirty_banner.
  ///
  /// In en, this message translates to:
  /// **'The mid-values values and labels are cleared automatically to reflect the low and high of the scale.'**
  String get form_array_response_scale_mid_values_dirty_banner;

  /// No description provided for @form_field_response_scale_colors_add.
  ///
  /// In en, this message translates to:
  /// **'Add start & end colors'**
  String get form_field_response_scale_colors_add;

  /// No description provided for @form_field_response_scale_color_add.
  ///
  /// In en, this message translates to:
  /// **'Add color'**
  String get form_field_response_scale_color_add;

  /// No description provided for @form_field_response_scale_color_min.
  ///
  /// In en, this message translates to:
  /// **'Low color'**
  String get form_field_response_scale_color_min;

  /// No description provided for @form_field_response_scale_color_max.
  ///
  /// In en, this message translates to:
  /// **'High color'**
  String get form_field_response_scale_color_max;

  /// No description provided for @form_field_response_scale_color_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Set a custom color for the scale shown in the app'**
  String get form_field_response_scale_color_tooltip;

  /// No description provided for @navlink_question_visuals.
  ///
  /// In en, this message translates to:
  /// **'Visuals'**
  String get navlink_question_visuals;

  /// No description provided for @navlink_question_visuals_description.
  ///
  /// In en, this message translates to:
  /// **'Customize the look & feel of the question in the app to your liking. This does not change the data that is collected, but can help guide the study participant visually'**
  String get navlink_question_visuals_description;

  /// No description provided for @form_array_response_options_choice_countmin.
  ///
  /// In en, this message translates to:
  /// **'Your question must have at least {count} non-empty response options'**
  String form_array_response_options_choice_countmin(num count);

  /// No description provided for @form_array_response_options_choice_countmax.
  ///
  /// In en, this message translates to:
  /// **'Your question must have at most {count} non-empty response options'**
  String form_array_response_options_choice_countmax(num count);

  /// No description provided for @form_array_response_options_scale_rangevalid_min.
  ///
  /// In en, this message translates to:
  /// **'The high value of the scale must be greater than the low value'**
  String get form_array_response_options_scale_rangevalid_min;

  /// No description provided for @form_array_response_options_scale_rangevalid_max.
  ///
  /// In en, this message translates to:
  /// **'Do not exceed {count} as a maximum difference between the high and low values of the scale'**
  String form_array_response_options_scale_rangevalid_max(num count);

  /// No description provided for @audio_recording_max_duration_rangevalid_min.
  ///
  /// In en, this message translates to:
  /// **'The minimum recording duration is 1 second'**
  String get audio_recording_max_duration_rangevalid_min;

  /// No description provided for @audio_recording_max_duration_rangevalid_max.
  ///
  /// In en, this message translates to:
  /// **'The maximum recording duration is {count} seconds'**
  String audio_recording_max_duration_rangevalid_max(num count);

  /// No description provided for @free_text_question_logic_not_supported.
  ///
  /// In en, this message translates to:
  /// **'The screener question logic is not yet supported for free text questions.'**
  String get free_text_question_logic_not_supported;

  /// No description provided for @free_text_question_type_any.
  ///
  /// In en, this message translates to:
  /// **'Any text'**
  String get free_text_question_type_any;

  /// No description provided for @free_text_question_type_alphanumeric.
  ///
  /// In en, this message translates to:
  /// **'Alphanumeric'**
  String get free_text_question_type_alphanumeric;

  /// No description provided for @free_text_question_type_numeric.
  ///
  /// In en, this message translates to:
  /// **'Numeric'**
  String get free_text_question_type_numeric;

  /// No description provided for @free_text_question_type_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get free_text_question_type_custom;

  /// No description provided for @free_text_range_label.
  ///
  /// In en, this message translates to:
  /// **'Allowed range of text length'**
  String get free_text_range_label;

  /// No description provided for @free_text_range_label_helper.
  ///
  /// In en, this message translates to:
  /// **'Enter the minimum and maximum number of characters that are allowed for the answer'**
  String get free_text_range_label_helper;

  /// No description provided for @free_text_type_label.
  ///
  /// In en, this message translates to:
  /// **'Allowed text type'**
  String get free_text_type_label;

  /// No description provided for @free_text_type_label_helper.
  ///
  /// In en, this message translates to:
  /// **'Choose the type of text that is allowed for the answer'**
  String get free_text_type_label_helper;

  /// No description provided for @free_text_type_custom_label.
  ///
  /// In en, this message translates to:
  /// **'Regular expression'**
  String get free_text_type_custom_label;

  /// No description provided for @free_text_type_custom_label_helper.
  ///
  /// In en, this message translates to:
  /// **'Enter a regular expression that the answer must match'**
  String get free_text_type_custom_label_helper;

  /// No description provided for @free_text_type_custom_helper.
  ///
  /// In en, this message translates to:
  /// **'Example: Enter [a-zA-Z]+ to only allow letters.'**
  String get free_text_type_custom_helper;

  /// No description provided for @free_text_type_custom_explanation.
  ///
  /// In en, this message translates to:
  /// **'Any input that does not match the expression will be rejected. The input length constraints specified above are still applied. A leading ^ and trailing \$ character will be added automatically.'**
  String get free_text_type_custom_explanation;

  /// No description provided for @free_text_example_label.
  ///
  /// In en, this message translates to:
  /// **'Example text field'**
  String get free_text_example_label;

  /// No description provided for @free_text_example_label_helper.
  ///
  /// In en, this message translates to:
  /// **'This is an example of the text field that will be shown to the participant. The length and input type constraints specified above will be applied.'**
  String get free_text_example_label_helper;

  /// No description provided for @free_text_example_valid.
  ///
  /// In en, this message translates to:
  /// **'Your example input is valid'**
  String get free_text_example_valid;

  /// No description provided for @free_text_example_default_helper.
  ///
  /// In en, this message translates to:
  /// **'Perform a validation test by entering text here.'**
  String get free_text_example_default_helper;

  /// No description provided for @free_text_validation_min_length.
  ///
  /// In en, this message translates to:
  /// **'The input must be at least {countMin} characters long.'**
  String free_text_validation_min_length(num countMin);

  /// No description provided for @free_text_validation_max_length.
  ///
  /// In en, this message translates to:
  /// **'The input must be at most {countMax} characters long.'**
  String free_text_validation_max_length(num countMax);

  /// No description provided for @free_text_validation_pattern.
  ///
  /// In en, this message translates to:
  /// **'The input must match the specified format.'**
  String get free_text_validation_pattern;

  /// No description provided for @free_text_validation_number.
  ///
  /// In en, this message translates to:
  /// **'The input must be a number.'**
  String get free_text_validation_number;

  /// No description provided for @free_text_example_explanation.
  ///
  /// In en, this message translates to:
  /// **'Inputs of type {type} with a character length range of {countMin} to {countMax} will be accepted.'**
  String free_text_example_explanation(String type, num countMin, num countMax);

  /// No description provided for @free_text_example_explanation_custom.
  ///
  /// In en, this message translates to:
  /// **'Inputs of type {type} will be accepted based on the regular expression pattern.'**
  String free_text_example_explanation_custom(String type);

  /// No description provided for @free_text_question_type_any_explanation.
  ///
  /// In en, this message translates to:
  /// **'Any input will be accepted.'**
  String get free_text_question_type_any_explanation;

  /// No description provided for @free_text_question_type_alphanumeric_explanation.
  ///
  /// In en, this message translates to:
  /// **'Alphanumeric input includes letters and numbers only.'**
  String get free_text_question_type_alphanumeric_explanation;

  /// No description provided for @free_text_question_type_numeric_explanation.
  ///
  /// In en, this message translates to:
  /// **'Numeric input includes numbers without special characters.'**
  String get free_text_question_type_numeric_explanation;

  /// No description provided for @free_text_question_type_custom_explanation.
  ///
  /// In en, this message translates to:
  /// **'The input must match the specified regular expression.'**
  String get free_text_question_type_custom_explanation;

  /// No description provided for @question_type_date.
  ///
  /// In en, this message translates to:
  /// **'Date/Time'**
  String get question_type_date;

  /// No description provided for @date_min_date_label.
  ///
  /// In en, this message translates to:
  /// **'Earliest date'**
  String get date_min_date_label;

  /// No description provided for @date_min_date_label_helper.
  ///
  /// In en, this message translates to:
  /// **'The earliest date participants can select'**
  String get date_min_date_label_helper;

  /// No description provided for @date_max_date_label.
  ///
  /// In en, this message translates to:
  /// **'Latest date'**
  String get date_max_date_label;

  /// No description provided for @date_max_date_label_helper.
  ///
  /// In en, this message translates to:
  /// **'The latest date participants can select'**
  String get date_max_date_label_helper;

  /// No description provided for @date_picker_hint.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get date_picker_hint;

  /// No description provided for @time_picker_hint.
  ///
  /// In en, this message translates to:
  /// **'Select a time'**
  String get time_picker_hint;

  /// No description provided for @date_input_type_label.
  ///
  /// In en, this message translates to:
  /// **'Input type'**
  String get date_input_type_label;

  /// No description provided for @date_input_type_label_helper.
  ///
  /// In en, this message translates to:
  /// **'Select what information to collect'**
  String get date_input_type_label_helper;

  /// No description provided for @date_input_type_date.
  ///
  /// In en, this message translates to:
  /// **'Date only'**
  String get date_input_type_date;

  /// No description provided for @date_input_type_time.
  ///
  /// In en, this message translates to:
  /// **'Time only'**
  String get date_input_type_time;

  /// No description provided for @date_input_type_datetime.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get date_input_type_datetime;

  /// No description provided for @date_default_option_label.
  ///
  /// In en, this message translates to:
  /// **'Default value'**
  String get date_default_option_label;

  /// No description provided for @date_default_option_label_helper.
  ///
  /// In en, this message translates to:
  /// **'Select the initial value shown to participants'**
  String get date_default_option_label_helper;

  /// No description provided for @date_default_option_none.
  ///
  /// In en, this message translates to:
  /// **'No default'**
  String get date_default_option_none;

  /// No description provided for @date_default_option_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get date_default_option_today;

  /// No description provided for @date_default_option_now.
  ///
  /// In en, this message translates to:
  /// **'Current time'**
  String get date_default_option_now;

  /// No description provided for @date_default_option_specific.
  ///
  /// In en, this message translates to:
  /// **'Specific date/time'**
  String get date_default_option_specific;

  /// No description provided for @date_default_specific_date_label.
  ///
  /// In en, this message translates to:
  /// **'Default date'**
  String get date_default_specific_date_label;

  /// No description provided for @date_default_specific_date_label_helper.
  ///
  /// In en, this message translates to:
  /// **'The date that will be pre-selected'**
  String get date_default_specific_date_label_helper;

  /// No description provided for @date_default_specific_time_label.
  ///
  /// In en, this message translates to:
  /// **'Default time'**
  String get date_default_specific_time_label;

  /// No description provided for @date_default_specific_time_label_helper.
  ///
  /// In en, this message translates to:
  /// **'The time that will be pre-selected'**
  String get date_default_specific_time_label_helper;

  /// No description provided for @date_min_time_label.
  ///
  /// In en, this message translates to:
  /// **'Earliest time'**
  String get date_min_time_label;

  /// No description provided for @date_min_time_label_helper.
  ///
  /// In en, this message translates to:
  /// **'The earliest time participants can select'**
  String get date_min_time_label_helper;

  /// No description provided for @date_max_time_label.
  ///
  /// In en, this message translates to:
  /// **'Latest time'**
  String get date_max_time_label;

  /// No description provided for @date_max_time_label_helper.
  ///
  /// In en, this message translates to:
  /// **'The latest time participants can select'**
  String get date_max_time_label_helper;

  /// No description provided for @date_validation_min_greater_than_max.
  ///
  /// In en, this message translates to:
  /// **'Earliest date cannot be after the latest date'**
  String get date_validation_min_greater_than_max;

  /// No description provided for @date_picker_button_label_datetime.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get date_picker_button_label_datetime;

  /// No description provided for @time_picker_button_label_datetime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get time_picker_button_label_datetime;

  /// No description provided for @time_picker_button_label.
  ///
  /// In en, this message translates to:
  /// **'Select a time'**
  String get time_picker_button_label;

  /// No description provided for @date_picker_validation_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get date_picker_validation_required;

  /// No description provided for @time_picker_validation_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a time'**
  String get time_picker_validation_required;

  /// No description provided for @datetime_picker_validation_required.
  ///
  /// In en, this message translates to:
  /// **'Please select both date and time'**
  String get datetime_picker_validation_required;

  /// No description provided for @time_picker_validation_range.
  ///
  /// In en, this message translates to:
  /// **'Please select a time within the allowed range'**
  String get time_picker_validation_range;

  /// No description provided for @time_picker_range_hint.
  ///
  /// In en, this message translates to:
  /// **'Select a time between {min} and {max}'**
  String time_picker_range_hint(Object min, Object max);

  /// No description provided for @time_picker_min_hint.
  ///
  /// In en, this message translates to:
  /// **'Earliest allowed time: {min}'**
  String time_picker_min_hint(Object min);

  /// No description provided for @time_picker_max_hint.
  ///
  /// In en, this message translates to:
  /// **'Latest allowed time: {max}'**
  String time_picker_max_hint(Object max);

  /// No description provided for @date_validation_default_today_before_min.
  ///
  /// In en, this message translates to:
  /// **'\'Today\' is before the earliest allowed date'**
  String get date_validation_default_today_before_min;

  /// No description provided for @date_validation_default_today_after_max.
  ///
  /// In en, this message translates to:
  /// **'\'Today\' is after the latest allowed date'**
  String get date_validation_default_today_after_max;

  /// No description provided for @date_validation_default_specific_before_min.
  ///
  /// In en, this message translates to:
  /// **'Default date is before the earliest allowed date'**
  String get date_validation_default_specific_before_min;

  /// No description provided for @date_validation_default_specific_after_max.
  ///
  /// In en, this message translates to:
  /// **'Default date is after the latest allowed date'**
  String get date_validation_default_specific_after_max;

  /// No description provided for @fitbit_question_title.
  ///
  /// In en, this message translates to:
  /// **'Fitbit'**
  String get fitbit_question_title;

  /// No description provided for @fitbit_question_type_empty.
  ///
  /// In en, this message translates to:
  /// **'No Fitbit data available'**
  String get fitbit_question_type_empty;

  /// No description provided for @navlink_question_visibility_logic.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get navlink_question_visibility_logic;

  /// No description provided for @form_array_question_visibility_logic_title.
  ///
  /// In en, this message translates to:
  /// **'Visibility Logic'**
  String get form_array_question_visibility_logic_title;

  /// No description provided for @form_array_question_visibility_logic_question_tooltip.
  ///
  /// In en, this message translates to:
  /// **'This question has visibility logic defined. It will only be shown to the participant if the conditions are met.'**
  String get form_array_question_visibility_logic_question_tooltip;

  /// No description provided for @form_array_question_visibility_logic_description.
  ///
  /// In en, this message translates to:
  /// **'Define the visibility logic for this question. The question will only be shown to the participant if the conditions are met.'**
  String get form_array_question_visibility_logic_description;

  /// No description provided for @form_array_question_visibility_logic_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Conditions are be based on the responses to other questions in the study. Only questions that follow the current question can be used in the visibility logic.'**
  String get form_array_question_visibility_logic_tooltip;

  /// No description provided for @form_array_question_visibility_logic_grouping_title.
  ///
  /// In en, this message translates to:
  /// **'Combine conditions with'**
  String get form_array_question_visibility_logic_grouping_title;

  /// No description provided for @form_array_question_visibility_logic_grouping_and_title.
  ///
  /// In en, this message translates to:
  /// **'AND'**
  String get form_array_question_visibility_logic_grouping_and_title;

  /// No description provided for @form_array_question_visibility_logic_grouping_or_title.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get form_array_question_visibility_logic_grouping_or_title;

  /// No description provided for @from_array_question_visibility_logic_no_conditions.
  ///
  /// In en, this message translates to:
  /// **'No conditions defined yet'**
  String get from_array_question_visibility_logic_no_conditions;

  /// No description provided for @form_array_question_visibility_logic_question_title.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get form_array_question_visibility_logic_question_title;

  /// No description provided for @form_array_question_visibility_logic_comparator_title.
  ///
  /// In en, this message translates to:
  /// **'Comparator'**
  String get form_array_question_visibility_logic_comparator_title;

  /// No description provided for @form_array_question_visibility_logic_true.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get form_array_question_visibility_logic_true;

  /// No description provided for @form_array_question_visibility_logic_false.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get form_array_question_visibility_logic_false;

  /// No description provided for @form_array_question_visibility_logic_value_title.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get form_array_question_visibility_logic_value_title;

  /// No description provided for @form_array_question_visibility_logic_add_condition_button.
  ///
  /// In en, this message translates to:
  /// **'Add condition'**
  String get form_array_question_visibility_logic_add_condition_button;

  /// No description provided for @form_array_question_visibility_logic_add_condition_disabled_tooltip.
  ///
  /// In en, this message translates to:
  /// **'No questions available to add conditions for. Only questions following the current question can be used in the visibility logic.'**
  String
  get form_array_question_visibility_logic_add_condition_disabled_tooltip;

  /// No description provided for @form_array_question_visibility_logic_is_true.
  ///
  /// In en, this message translates to:
  /// **'is true'**
  String get form_array_question_visibility_logic_is_true;

  /// No description provided for @form_array_question_visibility_logic_is_false.
  ///
  /// In en, this message translates to:
  /// **'is false'**
  String get form_array_question_visibility_logic_is_false;

  /// No description provided for @form_array_question_visibility_logic_is.
  ///
  /// In en, this message translates to:
  /// **'is'**
  String get form_array_question_visibility_logic_is;

  /// No description provided for @form_array_question_visibility_logic_is_not.
  ///
  /// In en, this message translates to:
  /// **'is not'**
  String get form_array_question_visibility_logic_is_not;

  /// No description provided for @form_array_question_visibility_logic_contains.
  ///
  /// In en, this message translates to:
  /// **'contains'**
  String get form_array_question_visibility_logic_contains;

  /// No description provided for @form_array_question_visibility_logic_does_not_contain.
  ///
  /// In en, this message translates to:
  /// **'does not contain'**
  String get form_array_question_visibility_logic_does_not_contain;

  /// No description provided for @form_array_question_visibility_logic_shorter_than.
  ///
  /// In en, this message translates to:
  /// **'shorter than'**
  String get form_array_question_visibility_logic_shorter_than;

  /// No description provided for @form_array_question_visibility_logic_shorter_than_or_equal_to.
  ///
  /// In en, this message translates to:
  /// **'shorter than or equal to'**
  String get form_array_question_visibility_logic_shorter_than_or_equal_to;

  /// No description provided for @form_array_question_visibility_logic_longer_than.
  ///
  /// In en, this message translates to:
  /// **'longer than'**
  String get form_array_question_visibility_logic_longer_than;

  /// No description provided for @form_array_question_visibility_logic_longer_than_or_equal_to.
  ///
  /// In en, this message translates to:
  /// **'longer than or equal to'**
  String get form_array_question_visibility_logic_longer_than_or_equal_to;

  /// No description provided for @form_array_question_visibility_logic_same_length_as.
  ///
  /// In en, this message translates to:
  /// **'same length as'**
  String get form_array_question_visibility_logic_same_length_as;

  /// No description provided for @form_array_question_visibility_logic_different_length_as.
  ///
  /// In en, this message translates to:
  /// **'different length as'**
  String get form_array_question_visibility_logic_different_length_as;

  /// No description provided for @form_array_question_visibility_logic_length_greater_than.
  ///
  /// In en, this message translates to:
  /// **'length >'**
  String get form_array_question_visibility_logic_length_greater_than;

  /// No description provided for @form_array_question_visibility_logic_length_less_than.
  ///
  /// In en, this message translates to:
  /// **'length <'**
  String get form_array_question_visibility_logic_length_less_than;

  /// No description provided for @form_array_question_visibility_logic_length_greater_than_or_equal.
  ///
  /// In en, this message translates to:
  /// **'length >='**
  String get form_array_question_visibility_logic_length_greater_than_or_equal;

  /// No description provided for @form_array_question_visibility_logic_length_less_than_or_equal.
  ///
  /// In en, this message translates to:
  /// **'length <='**
  String get form_array_question_visibility_logic_length_less_than_or_equal;

  /// No description provided for @form_array_question_visibility_logic_not.
  ///
  /// In en, this message translates to:
  /// **'NOT'**
  String get form_array_question_visibility_logic_not;

  /// No description provided for @form_array_question_visibility_logic_always_true.
  ///
  /// In en, this message translates to:
  /// **'always true'**
  String get form_array_question_visibility_logic_always_true;

  /// No description provided for @form_array_question_visibility_logic_preview_description.
  ///
  /// In en, this message translates to:
  /// **'Show this question if the following conditions are met:'**
  String get form_array_question_visibility_logic_preview_description;

  /// No description provided for @form_array_question_visibility_logic_unknown_expression.
  ///
  /// In en, this message translates to:
  /// **'Unknown Expression'**
  String get form_array_question_visibility_logic_unknown_expression;

  /// No description provided for @form_array_question_visibility_logic_this_question.
  ///
  /// In en, this message translates to:
  /// **'this question'**
  String get form_array_question_visibility_logic_this_question;

  /// No description provided for @form_mode_visibility_create.
  ///
  /// In en, this message translates to:
  /// **'Create Condition'**
  String get form_mode_visibility_create;

  /// No description provided for @form_mode_visibility_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Condition'**
  String get form_mode_visibility_edit;

  /// No description provided for @form_mode_visibility_readonly.
  ///
  /// In en, this message translates to:
  /// **'View Condition'**
  String get form_mode_visibility_readonly;

  /// No description provided for @validation_number_required.
  ///
  /// In en, this message translates to:
  /// **'The value must be a number'**
  String get validation_number_required;

  /// No description provided for @banner_study_readonly_title.
  ///
  /// In en, this message translates to:
  /// **'This study cannot be edited.'**
  String get banner_study_readonly_title;

  /// No description provided for @banner_study_readonly_description.
  ///
  /// In en, this message translates to:
  /// **'You can only make changes to studies where you are an owner or collaborator. Studies that have been launched cannot be changed by anyone.'**
  String get banner_study_readonly_description;

  /// No description provided for @banner_study_closed_title.
  ///
  /// In en, this message translates to:
  /// **'This study is closed.'**
  String get banner_study_closed_title;

  /// No description provided for @banner_study_closed_description.
  ///
  /// In en, this message translates to:
  /// **'New participants can no longer enroll in this study.'**
  String get banner_study_closed_description;

  /// No description provided for @form_section_scheduling.
  ///
  /// In en, this message translates to:
  /// **'Scheduling and Compliance'**
  String get form_section_scheduling;

  /// No description provided for @form_section_scheduling_description.
  ///
  /// In en, this message translates to:
  /// **'To improve compliance, you can set a limited window of time for participants to complete the task & send a reminder notification at the specified time.'**
  String get form_section_scheduling_description;

  /// No description provided for @form_field_has_reminder.
  ///
  /// In en, this message translates to:
  /// **'App reminder'**
  String get form_field_has_reminder;

  /// No description provided for @form_field_has_reminder_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Select this option to send a reminder notification from the StudyU App to the participant\'s phone at the time specified.'**
  String get form_field_has_reminder_tooltip;

  /// No description provided for @form_field_has_reminder_label.
  ///
  /// In en, this message translates to:
  /// **'Send notification'**
  String get form_field_has_reminder_label;

  /// No description provided for @form_field_time_of_day_hint.
  ///
  /// In en, this message translates to:
  /// **'hh:mm'**
  String get form_field_time_of_day_hint;

  /// No description provided for @form_field_time_restriction.
  ///
  /// In en, this message translates to:
  /// **'Time restriction'**
  String get form_field_time_restriction;

  /// No description provided for @form_field_time_restriction_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Provide the hours of the day during which participants need to complete the task. Please note that the task will not \nbe available for completion outside these hours & will be considered as missed for the purpose of data collection.'**
  String get form_field_time_restriction_tooltip;

  /// No description provided for @form_field_time_restriction_start_hint.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get form_field_time_restriction_start_hint;

  /// No description provided for @form_field_time_restriction_end_hint.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get form_field_time_restriction_end_hint;

  /// No description provided for @form_study_design_info_description.
  ///
  /// In en, this message translates to:
  /// **'Provide general information about your study to participants. If you decide to make your study available in the study registry, this information will be available to other researchers and clinicians as well.'**
  String get form_study_design_info_description;

  /// No description provided for @form_field_study_title.
  ///
  /// In en, this message translates to:
  /// **'Study title'**
  String get form_field_study_title;

  /// No description provided for @form_field_study_title_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Provide the title of the study as it should be displayed in the StudyU App'**
  String get form_field_study_title_tooltip;

  /// No description provided for @form_field_study_title_required.
  ///
  /// In en, this message translates to:
  /// **'The study title must not be empty'**
  String get form_field_study_title_required;

  /// No description provided for @form_field_study_title_default.
  ///
  /// In en, this message translates to:
  /// **'Unnamed study'**
  String get form_field_study_title_default;

  /// No description provided for @form_field_study_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get form_field_study_description;

  /// No description provided for @form_field_study_description_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Give a short summary of your study to participants'**
  String get form_field_study_description_tooltip;

  /// No description provided for @form_field_study_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Give a short summary of your study to participants'**
  String get form_field_study_description_hint;

  /// No description provided for @form_field_study_description_required.
  ///
  /// In en, this message translates to:
  /// **'The study description must not be empty'**
  String get form_field_study_description_required;

  /// No description provided for @form_field_study_tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get form_field_study_tags;

  /// No description provided for @form_field_study_tags_hint.
  ///
  /// In en, this message translates to:
  /// **'Write down a tag and press the Enter key'**
  String get form_field_study_tags_hint;

  /// No description provided for @form_field_study_tags_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add tags to your study to make it easier to find for other researchers and clinicians'**
  String get form_field_study_tags_tooltip;

  /// No description provided for @form_field_study_tags_error_length.
  ///
  /// In en, this message translates to:
  /// **'You can only add up to {count} tags to your study'**
  String form_field_study_tags_error_length(Object count);

  /// No description provided for @form_field_study_tags_helper.
  ///
  /// In en, this message translates to:
  /// **'Select up to {count} tags from the list or add your own.'**
  String form_field_study_tags_helper(Object count);

  /// No description provided for @form_field_study_icon_required.
  ///
  /// In en, this message translates to:
  /// **'You must select an icon for your study'**
  String get form_field_study_icon_required;

  /// No description provided for @form_section_publisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher and Contact Information'**
  String get form_section_publisher;

  /// No description provided for @form_section_publisher_description.
  ///
  /// In en, this message translates to:
  /// **'Participants will be able to contact you via the StudyU App using this information. Other clinicians or researchers will only be able to contact you if you agree to publish your study to the study registry.'**
  String get form_section_publisher_description;

  /// No description provided for @form_field_organization.
  ///
  /// In en, this message translates to:
  /// **'Responsible organization'**
  String get form_field_organization;

  /// No description provided for @form_field_organization_required.
  ///
  /// In en, this message translates to:
  /// **'The responsible organization must not be empty'**
  String get form_field_organization_required;

  /// No description provided for @form_field_review_board.
  ///
  /// In en, this message translates to:
  /// **'Institutional Review Board'**
  String get form_field_review_board;

  /// No description provided for @form_field_review_board_required.
  ///
  /// In en, this message translates to:
  /// **'You must specify the responsible review board for your study'**
  String get form_field_review_board_required;

  /// No description provided for @form_field_review_board_number.
  ///
  /// In en, this message translates to:
  /// **'Institutional Review Board Protocol Number'**
  String get form_field_review_board_number;

  /// No description provided for @form_field_review_board_number_required.
  ///
  /// In en, this message translates to:
  /// **'You must provide a review board protocol number for your study'**
  String get form_field_review_board_number_required;

  /// No description provided for @form_field_researchers.
  ///
  /// In en, this message translates to:
  /// **'Responsible person(s)'**
  String get form_field_researchers;

  /// No description provided for @form_field_researchers_required.
  ///
  /// In en, this message translates to:
  /// **'You must specify the researcher(s) responsible for the study'**
  String get form_field_researchers_required;

  /// No description provided for @form_field_website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get form_field_website;

  /// No description provided for @form_field_website_pattern.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid contact website URL'**
  String get form_field_website_pattern;

  /// No description provided for @form_field_contact_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get form_field_contact_email;

  /// No description provided for @form_field_contact_email_required.
  ///
  /// In en, this message translates to:
  /// **'You must specify a contact email'**
  String get form_field_contact_email_required;

  /// No description provided for @form_field_contact_email_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid contact email address'**
  String get form_field_contact_email_email;

  /// No description provided for @form_field_contact_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get form_field_contact_phone;

  /// No description provided for @form_field_contact_phone_required.
  ///
  /// In en, this message translates to:
  /// **'You must specify a phone number for participants to contact'**
  String get form_field_contact_phone_required;

  /// No description provided for @form_field_contact_additional_info.
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get form_field_contact_additional_info;

  /// No description provided for @form_study_design_enrollment_description.
  ///
  /// In en, this message translates to:
  /// **'Define who will be able to participate in your study, the criteria they have to meet and the terms they have to consent to.'**
  String get form_study_design_enrollment_description;

  /// No description provided for @form_field_enrollment_type.
  ///
  /// In en, this message translates to:
  /// **'Participant pool'**
  String get form_field_enrollment_type;

  /// No description provided for @form_field_enrollment_type_open_description.
  ///
  /// In en, this message translates to:
  /// **'Your study will be open for enrollment to all users of the StudyU platform as long as they match your screening criteria, if any.'**
  String get form_field_enrollment_type_open_description;

  /// No description provided for @form_field_enrollment_type_invite_description.
  ///
  /// In en, this message translates to:
  /// **'Only select participants will be able to enroll in your study using a designated invite code. Choose this option if you have a preselected pool of participants.'**
  String get form_field_enrollment_type_invite_description;

  /// No description provided for @form_array_screener_questions_title.
  ///
  /// In en, this message translates to:
  /// **'Screening criteria'**
  String get form_array_screener_questions_title;

  /// No description provided for @form_array_screener_questions_description.
  ///
  /// In en, this message translates to:
  /// **'Optional screener questions can help determine whether a potential participant is qualified to participate in the study. For invite-only studies, you may choose not to add any screening questions if you are manually qualifying & recruiting participants before inviting them to StudyU.'**
  String get form_array_screener_questions_description;

  /// No description provided for @form_array_screener_questions_new.
  ///
  /// In en, this message translates to:
  /// **'Add screener question'**
  String get form_array_screener_questions_new;

  /// No description provided for @form_array_screener_questions_test.
  ///
  /// In en, this message translates to:
  /// **'Test screener'**
  String get form_array_screener_questions_test;

  /// No description provided for @form_array_consent_items_title.
  ///
  /// In en, this message translates to:
  /// **'Participant consent'**
  String get form_array_consent_items_title;

  /// No description provided for @form_array_consent_items_description.
  ///
  /// In en, this message translates to:
  /// **'Provide the terms that participants have to consent to when enrolling in your study via the StudyU App. You may choose not to add any terms here if you obtain your participants\' consent by some other method before recruiting them to your study on StudyU.'**
  String get form_array_consent_items_description;

  /// No description provided for @form_array_consent_items_new.
  ///
  /// In en, this message translates to:
  /// **'Add consent text'**
  String get form_array_consent_items_new;

  /// No description provided for @form_array_consent_items_test.
  ///
  /// In en, this message translates to:
  /// **'Test consent'**
  String get form_array_consent_items_test;

  /// No description provided for @form_screener_question_create.
  ///
  /// In en, this message translates to:
  /// **'New Screener Question'**
  String get form_screener_question_create;

  /// No description provided for @form_screener_question_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Screener Question'**
  String get form_screener_question_edit;

  /// No description provided for @form_screener_question_readonly.
  ///
  /// In en, this message translates to:
  /// **'View Screener Question'**
  String get form_screener_question_readonly;

  /// No description provided for @form_screener_question_logic_qualify.
  ///
  /// In en, this message translates to:
  /// **'Qualify'**
  String get form_screener_question_logic_qualify;

  /// No description provided for @form_screener_question_logic_disqualify.
  ///
  /// In en, this message translates to:
  /// **'Disqualify'**
  String get form_screener_question_logic_disqualify;

  /// No description provided for @navlink_screener_question_content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get navlink_screener_question_content;

  /// No description provided for @navlink_screener_question_logic.
  ///
  /// In en, this message translates to:
  /// **'Screening'**
  String get navlink_screener_question_logic;

  /// No description provided for @form_array_screener_question_logic_title.
  ///
  /// In en, this message translates to:
  /// **'Screening rules'**
  String get form_array_screener_question_logic_title;

  /// No description provided for @form_array_screener_question_logic_description.
  ///
  /// In en, this message translates to:
  /// **'Define which responses qualify or disqualify participants from enrolling in your study. To qualify as a participant, at least one of the qualifying response options and none of the disqualifying ones must be selected for this question in the screening survey.'**
  String get form_array_screener_question_logic_description;

  /// No description provided for @form_array_screener_question_logic_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Define which response options are qualifying or disqualifying when selected by the participant.'**
  String get form_array_screener_question_logic_tooltip;

  /// No description provided for @form_array_screener_question_logic_dirty_banner.
  ///
  /// In en, this message translates to:
  /// **'The options you see here are cleared automatically to reflect the available responses. Every option is qualifying by default unless you explicitly mark them as disqualifying.'**
  String get form_array_screener_question_logic_dirty_banner;

  /// No description provided for @form_consent_create.
  ///
  /// In en, this message translates to:
  /// **'New Participant Consent'**
  String get form_consent_create;

  /// No description provided for @form_consent_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Participant Consent'**
  String get form_consent_edit;

  /// No description provided for @form_consent_readonly.
  ///
  /// In en, this message translates to:
  /// **'View Participant Consent'**
  String get form_consent_readonly;

  /// No description provided for @form_field_consent_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get form_field_consent_title;

  /// No description provided for @form_field_consent_title_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a short title for the terms the participant must read & accept.\nFor each consent text, a card with the title & icon is shown on the app\'s consent screen.'**
  String get form_field_consent_title_tooltip;

  /// No description provided for @form_field_consent_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter a short title'**
  String get form_field_consent_title_hint;

  /// No description provided for @form_field_consent_title_required.
  ///
  /// In en, this message translates to:
  /// **'You must provide a title for your participant consent'**
  String get form_field_consent_title_required;

  /// No description provided for @form_field_consent_text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get form_field_consent_text;

  /// No description provided for @form_field_consent_text_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter the terms the participant must read & accept when enrolling in the study.\nThe terms are shown when clicking on the corresponding card in the app\'s consent screen.'**
  String get form_field_consent_text_tooltip;

  /// No description provided for @form_field_consent_text_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the full terms to be read & accepted'**
  String get form_field_consent_text_hint;

  /// No description provided for @form_field_consent_text_required.
  ///
  /// In en, this message translates to:
  /// **'The text for your participant consent must not be empty'**
  String get form_field_consent_text_required;

  /// No description provided for @form_study_design_interventions_description.
  ///
  /// In en, this message translates to:
  /// **'Define the different phases of interventions to be studied, as well as the their sequence and frequency. In N-of-1 trials, a single participant will go through the intervention phases once or multiple times in a pre-specified order (so called multi-crossover trial). Each intervention consists of one or more tasks which are administered during the corresponding phase.\n\nNote: If you specify more than two interventions, participants are free to choose any two interventions to compare when they begin the study.'**
  String get form_study_design_interventions_description;

  /// No description provided for @link_n_of_1_learn_more.
  ///
  /// In en, this message translates to:
  /// **'Learn more about N-of-1 trials'**
  String get link_n_of_1_learn_more;

  /// No description provided for @link_n_of_1_learn_more_url.
  ///
  /// In en, this message translates to:
  /// **'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3118090/pdf/nihms297482.pdf'**
  String get link_n_of_1_learn_more_url;

  /// No description provided for @form_array_interventions_minlength.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =2{You must define at least two interventions to compare.} other{form_array_interventions_minlength}}'**
  String form_array_interventions_minlength(num count);

  /// No description provided for @form_array_interventions.
  ///
  /// In en, this message translates to:
  /// **'Intervention phases'**
  String get form_array_interventions;

  /// No description provided for @form_array_interventions_new.
  ///
  /// In en, this message translates to:
  /// **'Add intervention'**
  String get form_array_interventions_new;

  /// No description provided for @form_array_interventions_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No interventions defined'**
  String get form_array_interventions_empty_title;

  /// No description provided for @form_array_interventions_empty_description.
  ///
  /// In en, this message translates to:
  /// **'You must define at least two interventions to compare.'**
  String get form_array_interventions_empty_description;

  /// No description provided for @form_field_intervention_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get form_field_intervention_title;

  /// No description provided for @form_field_intervention_title_required.
  ///
  /// In en, this message translates to:
  /// **'The intervention title must not be empty'**
  String get form_field_intervention_title_required;

  /// No description provided for @form_field_intervention_title_default.
  ///
  /// In en, this message translates to:
  /// **'Unnamed intervention'**
  String get form_field_intervention_title_default;

  /// No description provided for @form_field_intervention_title_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Provide the title of the intervention phase as it should be displayed in the StudyU App'**
  String get form_field_intervention_title_tooltip;

  /// No description provided for @form_field_intervention_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get form_field_intervention_description;

  /// No description provided for @form_field_intervention_description_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter an explanation text that is shown when the intervention phase starts or when the participant\nclicks on the respective phase in the study plan'**
  String get form_field_intervention_description_tooltip;

  /// No description provided for @form_field_intervention_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Describe the intervention phase to participants'**
  String get form_field_intervention_description_hint;

  /// No description provided for @form_array_intervention_tasks.
  ///
  /// In en, this message translates to:
  /// **'Intervention tasks'**
  String get form_array_intervention_tasks;

  /// No description provided for @form_array_intervention_tasks_description.
  ///
  /// In en, this message translates to:
  /// **'Define one or more tasks that participants should complete during this intervention phase. Every day, participants will be prompted to complete these tasks in the StudyU App.'**
  String get form_array_intervention_tasks_description;

  /// No description provided for @form_array_intervention_tasks_new.
  ///
  /// In en, this message translates to:
  /// **'Add intervention task'**
  String get form_array_intervention_tasks_new;

  /// No description provided for @form_array_intervention_tasks_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No intervention tasks defined'**
  String get form_array_intervention_tasks_empty_title;

  /// No description provided for @form_array_intervention_tasks_empty_description.
  ///
  /// In en, this message translates to:
  /// **'You must define at least one task for participants to complete during this intervention phase.'**
  String get form_array_intervention_tasks_empty_description;

  /// No description provided for @form_array_intervention_tasks_minlength.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{You must define at least one task for participants to complete during this intervention phase} other{form_array_intervention_tasks_minlength}}'**
  String form_array_intervention_tasks_minlength(num count);

  /// No description provided for @form_intervention_task_create.
  ///
  /// In en, this message translates to:
  /// **'New Intervention Task'**
  String get form_intervention_task_create;

  /// No description provided for @form_intervention_task_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Intervention Task'**
  String get form_intervention_task_edit;

  /// No description provided for @form_intervention_task_readonly.
  ///
  /// In en, this message translates to:
  /// **'View Intervention Task'**
  String get form_intervention_task_readonly;

  /// No description provided for @form_field_intervention_task_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get form_field_intervention_task_title;

  /// No description provided for @form_field_intervention_task_default.
  ///
  /// In en, this message translates to:
  /// **'Unnamed task'**
  String get form_field_intervention_task_default;

  /// No description provided for @form_field_intervention_task_title_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Provide the title of the intervention task for the daily prompt in the StudyU App'**
  String get form_field_intervention_task_title_tooltip;

  /// No description provided for @form_field_intervention_task_title_required.
  ///
  /// In en, this message translates to:
  /// **'The intervention task title must not be empty'**
  String get form_field_intervention_task_title_required;

  /// No description provided for @form_field_intervention_task_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get form_field_intervention_task_description;

  /// No description provided for @form_field_intervention_task_description_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a detailed description that is shown when clicking on the daily prompt in the StudyU App'**
  String get form_field_intervention_task_description_tooltip;

  /// No description provided for @form_field_intervention_task_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Give a detailed description of the task to be performed, link to a video instruction, etc.'**
  String get form_field_intervention_task_description_hint;

  /// No description provided for @form_field_intervention_task_mark_as_completed_label.
  ///
  /// In en, this message translates to:
  /// **'Require participants to \"Mark as completed\"'**
  String get form_field_intervention_task_mark_as_completed_label;

  /// No description provided for @form_section_crossover_schedule.
  ///
  /// In en, this message translates to:
  /// **'Study schedule'**
  String get form_section_crossover_schedule;

  /// No description provided for @navlink_crossover_schedule_test.
  ///
  /// In en, this message translates to:
  /// **'Test schedule'**
  String get navlink_crossover_schedule_test;

  /// No description provided for @form_field_crossover_schedule_sequence.
  ///
  /// In en, this message translates to:
  /// **'Sequencing'**
  String get form_field_crossover_schedule_sequence;

  /// No description provided for @form_field_crossover_schedule_sequence_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose the pattern for how intervention phases are sequenced in the study schedule'**
  String get form_field_crossover_schedule_sequence_tooltip;

  /// No description provided for @form_field_crossover_schedule_sequence_description.
  ///
  /// In en, this message translates to:
  /// **'This is the default sequence of interventions for each participant. You may override this sequencing individually for each participant in invite-only studies.'**
  String get form_field_crossover_schedule_sequence_description;

  /// No description provided for @form_field_crossover_schedule_phase_length.
  ///
  /// In en, this message translates to:
  /// **'Phase length'**
  String get form_field_crossover_schedule_phase_length;

  /// No description provided for @form_field_crossover_schedule_phase_length_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Number of days it takes to complete a single phase. A phase is one continuous intervention block (e.g., 7 days of A or B).'**
  String get form_field_crossover_schedule_phase_length_tooltip;

  /// No description provided for @form_field_crossover_schedule_phase_length_range.
  ///
  /// In en, this message translates to:
  /// **'Intervention phases must be between {min} and {max} days long'**
  String form_field_crossover_schedule_phase_length_range(num min, num max);

  /// No description provided for @form_field_amount_days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get form_field_amount_days;

  /// No description provided for @form_field_crossover_schedule_num_cycles.
  ///
  /// In en, this message translates to:
  /// **'Number of cycles'**
  String get form_field_crossover_schedule_num_cycles;

  /// No description provided for @form_field_crossover_schedule_num_cycles_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Alternating / Counterbalanced / Random:\nNumber of cycles (pairs of phases) to repeat. One cycle = two phases (e.g., AB or BA).\n\nCustom:\nNumber of times the full custom sequence is repeated. One cycle = the entire sequence you defined (e.g., ABBAA).'**
  String get form_field_crossover_schedule_num_cycles_tooltip;

  /// No description provided for @form_field_crossover_schedule_num_cycles_range.
  ///
  /// In en, this message translates to:
  /// **'The number of cycles in your study schedule must be between {min} and {max}'**
  String form_field_crossover_schedule_num_cycles_range(num min, num max);

  /// No description provided for @form_field_amount_crossover_schedule_num_cycles.
  ///
  /// In en, this message translates to:
  /// **'cycles'**
  String get form_field_amount_crossover_schedule_num_cycles;

  /// No description provided for @form_field_crossover_schedule_include_baseline.
  ///
  /// In en, this message translates to:
  /// **'Baseline phase'**
  String get form_field_crossover_schedule_include_baseline;

  /// No description provided for @form_field_crossover_schedule_include_baseline_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add an intervention-free baseline phase at the beginning of your study'**
  String get form_field_crossover_schedule_include_baseline_tooltip;

  /// No description provided for @form_field_crossover_schedule_include_baseline_label.
  ///
  /// In en, this message translates to:
  /// **'Include in schedule'**
  String get form_field_crossover_schedule_include_baseline_label;

  /// No description provided for @form_study_design_measurements_description.
  ///
  /// In en, this message translates to:
  /// **'Define the data that you want to gather from participants during the study - primarily to evaluate the effect of your interventions. The data will be self-reported by participants in one or more surveys served via the StudyU App on a daily basis. The collected data and results will be available on the Analyze page when the study is launched.'**
  String get form_study_design_measurements_description;

  /// No description provided for @form_array_measurements_minlength.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{You need to define at least one survey to determine the effect of your intervention(s).} other{form_array_measurements_minlength}}'**
  String form_array_measurements_minlength(num count);

  /// No description provided for @form_array_measurements_surveys.
  ///
  /// In en, this message translates to:
  /// **'Surveys'**
  String get form_array_measurements_surveys;

  /// No description provided for @form_array_measurements_surveys_new.
  ///
  /// In en, this message translates to:
  /// **'Add survey'**
  String get form_array_measurements_surveys_new;

  /// No description provided for @form_array_measurements_surveys_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No surveys defined'**
  String get form_array_measurements_surveys_empty_title;

  /// No description provided for @form_array_measurements_surveys_empty_description.
  ///
  /// In en, this message translates to:
  /// **'You need to define at least one survey to determine the effect of your intervention(s).'**
  String get form_array_measurements_surveys_empty_description;

  /// No description provided for @form_field_measurement_survey_title.
  ///
  /// In en, this message translates to:
  /// **'Survey title'**
  String get form_field_measurement_survey_title;

  /// No description provided for @form_field_measurement_survey_title_required.
  ///
  /// In en, this message translates to:
  /// **'The survey title must not be empty'**
  String get form_field_measurement_survey_title_required;

  /// No description provided for @form_field_measurement_survey_title_default.
  ///
  /// In en, this message translates to:
  /// **'Unnamed survey'**
  String get form_field_measurement_survey_title_default;

  /// No description provided for @form_field_measurement_survey_title_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Provide the title of the survey as it should be displayed in the StudyU App'**
  String get form_field_measurement_survey_title_tooltip;

  /// No description provided for @form_field_measurement_survey_intro_text.
  ///
  /// In en, this message translates to:
  /// **'Intro text'**
  String get form_field_measurement_survey_intro_text;

  /// No description provided for @form_field_measurement_survey_intro_text_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a text that is shown at the very beginning of the survey'**
  String get form_field_measurement_survey_intro_text_tooltip;

  /// No description provided for @form_field_measurement_survey_intro_text_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. welcome & introduce participants to the survey'**
  String get form_field_measurement_survey_intro_text_hint;

  /// No description provided for @form_field_measurement_survey_outro_text.
  ///
  /// In en, this message translates to:
  /// **'Outro text'**
  String get form_field_measurement_survey_outro_text;

  /// No description provided for @form_field_measurement_survey_outro_text_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a text that is shown at the very end of the survey after completion'**
  String get form_field_measurement_survey_outro_text_tooltip;

  /// No description provided for @form_field_measurement_survey_outro_text_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. thank participants for completing the survey'**
  String get form_field_measurement_survey_outro_text_hint;

  /// No description provided for @form_array_measurement_survey_questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get form_array_measurement_survey_questions;

  /// No description provided for @form_array_measurement_survey_questions_new.
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get form_array_measurement_survey_questions_new;

  /// No description provided for @form_array_measurement_survey_questions_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No questions defined'**
  String get form_array_measurement_survey_questions_empty_title;

  /// No description provided for @form_array_measurement_survey_questions_empty_description.
  ///
  /// In en, this message translates to:
  /// **'You need to define at least one question to determine the effect of your intervention(s).'**
  String get form_array_measurement_survey_questions_empty_description;

  /// No description provided for @form_array_measurement_survey_questions_minlength.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{You need to define at least one question to determine the effect of your intervention(s)} other{form_array_measurement_survey_questions_minlength}}'**
  String form_array_measurement_survey_questions_minlength(num count);

  /// No description provided for @report_status_primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get report_status_primary;

  /// No description provided for @report_status_secondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get report_status_secondary;

  /// No description provided for @report_status_primary_description.
  ///
  /// In en, this message translates to:
  /// **'Primary Report'**
  String get report_status_primary_description;

  /// No description provided for @report_status_secondary_description.
  ///
  /// In en, this message translates to:
  /// **'Secondary Report'**
  String get report_status_secondary_description;

  /// No description provided for @form_report_create.
  ///
  /// In en, this message translates to:
  /// **'New Report'**
  String get form_report_create;

  /// No description provided for @form_report_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Report'**
  String get form_report_edit;

  /// No description provided for @form_report_readonly.
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get form_report_readonly;

  /// No description provided for @form_field_report_title_required.
  ///
  /// In en, this message translates to:
  /// **'You must provide a title for your report'**
  String get form_field_report_title_required;

  /// No description provided for @form_field_report_text_required.
  ///
  /// In en, this message translates to:
  /// **'The description for your report must not be empty'**
  String get form_field_report_text_required;

  /// No description provided for @form_array_reports_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No reports defined'**
  String get form_array_reports_empty_title;

  /// No description provided for @form_array_report_items_title.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get form_array_report_items_title;

  /// No description provided for @form_array_report_items_description.
  ///
  /// In en, this message translates to:
  /// **'Define how the report that your participants receive should look like. A report includes various sections, the first of which is the primary section. For each section you can define if the data should be reported as average or via a linear regression of the user\'s data. You can choose whether the data is reported for individual days, phases or for each intervention. The data source defines which observation the report section is based on.'**
  String get form_array_report_items_description;

  /// No description provided for @form_array_reports_empty_description.
  ///
  /// In en, this message translates to:
  /// **'You need to define at least one report to provide feedback to your participants.'**
  String get form_array_reports_empty_description;

  /// No description provided for @form_array_reports_new.
  ///
  /// In en, this message translates to:
  /// **'Add new report'**
  String get form_array_reports_new;

  /// No description provided for @form_field_report_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get form_field_report_title;

  /// No description provided for @form_field_report_title_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a short title for the report.'**
  String get form_field_report_title_tooltip;

  /// No description provided for @form_field_report_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter a short title'**
  String get form_field_report_title_hint;

  /// No description provided for @form_field_report_text.
  ///
  /// In en, this message translates to:
  /// **'Report description'**
  String get form_field_report_text;

  /// No description provided for @form_field_report_text_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a description for the report'**
  String get form_field_report_text_tooltip;

  /// No description provided for @form_field_report_text_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter a report description'**
  String get form_field_report_text_hint;

  /// No description provided for @form_field_report_section_type.
  ///
  /// In en, this message translates to:
  /// **'Report Type'**
  String get form_field_report_section_type;

  /// No description provided for @form_field_report_section_type_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose a report type'**
  String get form_field_report_section_type_tooltip;

  /// No description provided for @form_field_report_section_type_description.
  ///
  /// In en, this message translates to:
  /// **'Choose the report type that matches your report.'**
  String get form_field_report_section_type_description;

  /// No description provided for @form_field_report_improvementDirection_title.
  ///
  /// In en, this message translates to:
  /// **'Improvement Direction'**
  String get form_field_report_improvementDirection_title;

  /// No description provided for @form_field_report_improvementDirection_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Define the improvement direction'**
  String get form_field_report_improvementDirection_tooltip;

  /// No description provided for @reportSection_type_average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get reportSection_type_average;

  /// No description provided for @reportSection_type_textual_summary.
  ///
  /// In en, this message translates to:
  /// **'Textual Summary'**
  String get reportSection_type_textual_summary;

  /// No description provided for @reportSection_type_gauge_comparison.
  ///
  /// In en, this message translates to:
  /// **'Gauge Comparison'**
  String get reportSection_type_gauge_comparison;

  /// No description provided for @reportSection_type_descriptive_statistics.
  ///
  /// In en, this message translates to:
  /// **'Descriptive Statistics'**
  String get reportSection_type_descriptive_statistics;

  /// No description provided for @form_field_report_average_temporalAggregation_title.
  ///
  /// In en, this message translates to:
  /// **'Temporal Aggregation'**
  String get form_field_report_average_temporalAggregation_title;

  /// No description provided for @form_field_report_average_temporalAggregation_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Define the temporal aggregation'**
  String get form_field_report_average_temporalAggregation_tooltip;

  /// No description provided for @reportSection_type_temporalAggregation_day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get reportSection_type_temporalAggregation_day;

  /// No description provided for @reportSection_type_temporalAggregation_phase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get reportSection_type_temporalAggregation_phase;

  /// No description provided for @reportSection_type_temporalAggregation_intervention.
  ///
  /// In en, this message translates to:
  /// **'Intervention'**
  String get reportSection_type_temporalAggregation_intervention;

  /// No description provided for @form_field_report_temporalAggregation_required.
  ///
  /// In en, this message translates to:
  /// **'A temporal aggregation value needs to be defined'**
  String get form_field_report_temporalAggregation_required;

  /// No description provided for @reportSection_type_linearRegression.
  ///
  /// In en, this message translates to:
  /// **'Linear Regression'**
  String get reportSection_type_linearRegression;

  /// No description provided for @reportSection_type_improvementDirection_positive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get reportSection_type_improvementDirection_positive;

  /// No description provided for @reportSection_type_improvementDirection_negative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get reportSection_type_improvementDirection_negative;

  /// No description provided for @form_field_report_improvementDirection_required.
  ///
  /// In en, this message translates to:
  /// **'An improvement direction needs to be defined'**
  String get form_field_report_improvementDirection_required;

  /// No description provided for @form_field_report_linearRegression_alpha_title.
  ///
  /// In en, this message translates to:
  /// **'Alpha Confidence'**
  String get form_field_report_linearRegression_alpha_title;

  /// No description provided for @form_field_report_linearRegression_alpha_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Define the alpha confidence'**
  String get form_field_report_linearRegression_alpha_tooltip;

  /// No description provided for @form_field_report_linearRegression_alpha_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter a numerical value'**
  String get form_field_report_linearRegression_alpha_hint;

  /// No description provided for @form_field_report_alphaConfidence_required.
  ///
  /// In en, this message translates to:
  /// **'An alpha confidence value needs to be defined'**
  String get form_field_report_alphaConfidence_required;

  /// No description provided for @form_field_report_alphaConfidence_number.
  ///
  /// In en, this message translates to:
  /// **'The alpha confidence value must be a numeric value'**
  String get form_field_report_alphaConfidence_number;

  /// No description provided for @form_field_report_data_source_title.
  ///
  /// In en, this message translates to:
  /// **'Data Source'**
  String get form_field_report_data_source_title;

  /// No description provided for @form_field_report_data_source_tooltip.
  ///
  /// In en, this message translates to:
  /// **'The data source defines which observation the report section is based on. The observation needs to be a question with a numerical result, e.g. a scale question.'**
  String get form_field_report_data_source_tooltip;

  /// No description provided for @form_field_report_data_source_required.
  ///
  /// In en, this message translates to:
  /// **'A data source needs to be defined'**
  String get form_field_report_data_source_required;

  /// No description provided for @form_field_report_select_aggregation.
  ///
  /// In en, this message translates to:
  /// **'Select an aggregation value'**
  String get form_field_report_select_aggregation;

  /// No description provided for @study_test_page_description.
  ///
  /// In en, this message translates to:
  /// **'In the test mode you can test your study as a participant.'**
  String get study_test_page_description;

  /// No description provided for @navlink_study_test_help.
  ///
  /// In en, this message translates to:
  /// **'How does this work?'**
  String get navlink_study_test_help;

  /// No description provided for @study_test_app_nav_title.
  ///
  /// In en, this message translates to:
  /// **'Choose a page:'**
  String get study_test_app_nav_title;

  /// No description provided for @navlink_study_test_app_overview.
  ///
  /// In en, this message translates to:
  /// **'Study Overview'**
  String get navlink_study_test_app_overview;

  /// No description provided for @navlink_study_test_app_eligibility.
  ///
  /// In en, this message translates to:
  /// **'Screener'**
  String get navlink_study_test_app_eligibility;

  /// No description provided for @navlink_study_test_app_intervention.
  ///
  /// In en, this message translates to:
  /// **'Intervention Selection'**
  String get navlink_study_test_app_intervention;

  /// No description provided for @navlink_study_test_app_intervention_disabled.
  ///
  /// In en, this message translates to:
  /// **'The intervention selection is disabled, as the study has less than three interventions defined. Interventions are selected automatically in this case.'**
  String get navlink_study_test_app_intervention_disabled;

  /// No description provided for @navlink_study_test_app_consent.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get navlink_study_test_app_consent;

  /// No description provided for @navlink_study_test_app_journey.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navlink_study_test_app_journey;

  /// No description provided for @navlink_study_test_app_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Daily Dashboard'**
  String get navlink_study_test_app_dashboard;

  /// No description provided for @action_button_study_test_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get action_button_study_test_reset;

  /// No description provided for @action_button_study_test_open_new_tab.
  ///
  /// In en, this message translates to:
  /// **'Open in new tab'**
  String get action_button_study_test_open_new_tab;

  /// No description provided for @preview_overlay_health_checking_title.
  ///
  /// In en, this message translates to:
  /// **'Checking app availability'**
  String get preview_overlay_health_checking_title;

  /// No description provided for @preview_overlay_connecting_title.
  ///
  /// In en, this message translates to:
  /// **'Connecting to app preview'**
  String get preview_overlay_connecting_title;

  /// No description provided for @preview_overlay_loading_title.
  ///
  /// In en, this message translates to:
  /// **'Loading app preview'**
  String get preview_overlay_loading_title;

  /// No description provided for @preview_overlay_health_checking_description_local.
  ///
  /// In en, this message translates to:
  /// **'Checking whether the StudyU app is running at {url}.'**
  String preview_overlay_health_checking_description_local(String url);

  /// No description provided for @preview_overlay_health_checking_description_remote.
  ///
  /// In en, this message translates to:
  /// **'Checking whether the participant app is reachable at {url}.'**
  String preview_overlay_health_checking_description_remote(String url);

  /// No description provided for @preview_overlay_connecting_description_local.
  ///
  /// In en, this message translates to:
  /// **'The local StudyU app is reachable. Establishing the connection now.'**
  String get preview_overlay_connecting_description_local;

  /// No description provided for @preview_overlay_connecting_description_remote.
  ///
  /// In en, this message translates to:
  /// **'The participant app is reachable. Establishing the connection now.'**
  String get preview_overlay_connecting_description_remote;

  /// No description provided for @preview_overlay_loading_description_local.
  ///
  /// In en, this message translates to:
  /// **'The app preview is connected. The app is now loading inside the phone frame.'**
  String get preview_overlay_loading_description_local;

  /// No description provided for @preview_overlay_loading_description_remote.
  ///
  /// In en, this message translates to:
  /// **'The app preview is connected. The participant app is now loading.'**
  String get preview_overlay_loading_description_remote;

  /// No description provided for @preview_overlay_local_unavailable_title.
  ///
  /// In en, this message translates to:
  /// **'Local app preview unavailable'**
  String get preview_overlay_local_unavailable_title;

  /// No description provided for @preview_overlay_remote_unavailable_title.
  ///
  /// In en, this message translates to:
  /// **'App under maintenance'**
  String get preview_overlay_remote_unavailable_title;

  /// No description provided for @preview_overlay_local_unavailable_message.
  ///
  /// In en, this message translates to:
  /// **'The local StudyU app could not be reached.'**
  String get preview_overlay_local_unavailable_message;

  /// No description provided for @preview_overlay_remote_unavailable_message.
  ///
  /// In en, this message translates to:
  /// **'The StudyU mobile app is temporarily unavailable or under maintenance. Please try again in a little while.'**
  String get preview_overlay_remote_unavailable_message;

  /// No description provided for @preview_overlay_could_not_load.
  ///
  /// In en, this message translates to:
  /// **'The StudyU app preview could not be loaded.'**
  String get preview_overlay_could_not_load;

  /// No description provided for @preview_overlay_preview_not_opened.
  ///
  /// In en, this message translates to:
  /// **'The StudyU app preview could not be opened right now.'**
  String get preview_overlay_preview_not_opened;

  /// No description provided for @banner_study_test_unavailable.
  ///
  /// In en, this message translates to:
  /// **'The test mode is unavailable until you update the following information:'**
  String get banner_study_test_unavailable;

  /// No description provided for @banner_study_preview_unavailable.
  ///
  /// In en, this message translates to:
  /// **'The preview is unavailable until you update the following information:'**
  String get banner_study_preview_unavailable;

  /// No description provided for @dialog_study_test_help_title.
  ///
  /// In en, this message translates to:
  /// **'Test your study!'**
  String get dialog_study_test_help_title;

  /// No description provided for @dialog_study_test_help_description.
  ///
  /// In en, this message translates to:
  /// **'This page allows you to experience your study like one of your study\'s participants, so that you can tailor the design to your needs and verify everything works correctly.'**
  String get dialog_study_test_help_description;

  /// No description provided for @dialog_study_test_section_tips.
  ///
  /// In en, this message translates to:
  /// **'⭐ Pro tips'**
  String get dialog_study_test_section_tips;

  /// No description provided for @dialog_study_test_section_tips_text.
  ///
  /// In en, this message translates to:
  /// **'• Use the menu in the top-left to quickly preview and jump to different parts of your study\n• Fast-forward through the participant\'s schedule by clicking \'next day\' on the app\'s dashboard page\n• Preview what your results will look like by exporting and analyzing the data from your latest test session (via the Analyze tab)\n• To get a fresh experience, you can reset all data and enroll as a new test user'**
  String get dialog_study_test_section_tips_text;

  /// No description provided for @dialog_study_test_download_url_intro.
  ///
  /// In en, this message translates to:
  /// **'• You can also'**
  String get dialog_study_test_download_url_intro;

  /// No description provided for @dialog_study_test_download_url.
  ///
  /// In en, this message translates to:
  /// **'https://github.com/hpi-studyu/studyu#app-stores'**
  String get dialog_study_test_download_url;

  /// No description provided for @dialog_study_test_download_url_text.
  ///
  /// In en, this message translates to:
  /// **'download the StudyU App'**
  String get dialog_study_test_download_url_text;

  /// No description provided for @dialog_study_test_download_url_outro.
  ///
  /// In en, this message translates to:
  /// **' on your phone for testing'**
  String get dialog_study_test_download_url_outro;

  /// No description provided for @dialog_study_test_section_notice.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Please note'**
  String get dialog_study_test_section_notice;

  /// No description provided for @dialog_study_test_section_notice_text.
  ///
  /// In en, this message translates to:
  /// **'• All test users and their data will be reset once you launch the study'**
  String get dialog_study_test_section_notice_text;

  /// No description provided for @dialog_action_study_test_start.
  ///
  /// In en, this message translates to:
  /// **'Start testing'**
  String get dialog_action_study_test_start;

  /// No description provided for @enrolled_count_tooltip.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{Nobody has enrolled in the study with this code yet} =1{{count} participant is enrolled in the study with this code} other{{count} participants are enrolled in the study with this code}}'**
  String enrolled_count_tooltip(num count);

  /// No description provided for @form_code_create.
  ///
  /// In en, this message translates to:
  /// **'New Invite Code'**
  String get form_code_create;

  /// No description provided for @form_code_readonly.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get form_code_readonly;

  /// No description provided for @form_field_code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get form_field_code;

  /// No description provided for @form_field_code_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a unique code that participants can use to enroll in your study'**
  String get form_field_code_tooltip;

  /// No description provided for @form_field_code_required.
  ///
  /// In en, this message translates to:
  /// **'The code must not be empty'**
  String get form_field_code_required;

  /// No description provided for @form_field_code_minlength.
  ///
  /// In en, this message translates to:
  /// **'The code must have at least {minLength} characters'**
  String form_field_code_minlength(num minLength);

  /// No description provided for @form_field_code_maxlength.
  ///
  /// In en, this message translates to:
  /// **'The code must have at most {maxLength} characters'**
  String form_field_code_maxlength(num maxLength);

  /// No description provided for @form_field_code_alreadyused.
  ///
  /// In en, this message translates to:
  /// **'This code is already in use'**
  String get form_field_code_alreadyused;

  /// No description provided for @form_field_is_preconfigured_schedule.
  ///
  /// In en, this message translates to:
  /// **'Predefined Schedule'**
  String get form_field_is_preconfigured_schedule;

  /// No description provided for @form_field_is_preconfigured_schedule_description.
  ///
  /// In en, this message translates to:
  /// **'You can predefine the phases and interventions for any participant who joins your study via this invite code. If enabled, these settings will override the default schedule defined in your study design.'**
  String get form_field_is_preconfigured_schedule_description;

  /// No description provided for @form_field_preconfigured_schedule_type.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get form_field_preconfigured_schedule_type;

  /// No description provided for @form_field_preconfigured_schedule_intervention_a.
  ///
  /// In en, this message translates to:
  /// **'Intervention A'**
  String get form_field_preconfigured_schedule_intervention_a;

  /// No description provided for @form_field_preconfigured_schedule_intervention_b.
  ///
  /// In en, this message translates to:
  /// **'Intervention B'**
  String get form_field_preconfigured_schedule_intervention_b;

  /// No description provided for @form_field_preconfigured_schedule_intervention_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get form_field_preconfigured_schedule_intervention_default;

  /// No description provided for @form_field_preconfigured_schedule_intervention_hint.
  ///
  /// In en, this message translates to:
  /// **'Select intervention...'**
  String get form_field_preconfigured_schedule_intervention_hint;

  /// No description provided for @code_list_section_title.
  ///
  /// In en, this message translates to:
  /// **'Invite Codes'**
  String get code_list_section_title;

  /// No description provided for @code_public_disabled.
  ///
  /// In en, this message translates to:
  /// **'Public Recruitment'**
  String get code_public_disabled;

  /// No description provided for @code_public_disabled_description.
  ///
  /// In en, this message translates to:
  /// **'Participants can easily join this study by using the links below, scanning the QR code, or by finding it in the app\'s public study list. Note that invite codes are not available here, as they are exclusively used for private studies.'**
  String get code_public_disabled_description;

  /// No description provided for @code_list_empty_title.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t invited anyone yet'**
  String get code_list_empty_title;

  /// No description provided for @code_list_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Add participants to your study via invite codes.'**
  String get code_list_empty_description;

  /// No description provided for @code_list_header_code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code_list_header_code;

  /// No description provided for @code_list_header_actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get code_list_header_actions;

  /// No description provided for @action_button_code_new.
  ///
  /// In en, this message translates to:
  /// **'New code'**
  String get action_button_code_new;

  /// No description provided for @participant_details_title.
  ///
  /// In en, this message translates to:
  /// **'Participant details'**
  String get participant_details_title;

  /// No description provided for @participant_details_study_days_overview.
  ///
  /// In en, this message translates to:
  /// **'Study days overview'**
  String get participant_details_study_days_overview;

  /// No description provided for @participant_details_study_days_description.
  ///
  /// In en, this message translates to:
  /// **'This section provides an overview of the participant\'s progress in the study. The color coding indicates the status of the participant\'s tasks on each day. Hover over each day to see more details about the participant\'s activity.'**
  String get participant_details_study_days_description;

  /// No description provided for @participant_details_color_legend_title.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get participant_details_color_legend_title;

  /// No description provided for @participant_details_color_tooltip_legend_title.
  ///
  /// In en, this message translates to:
  /// **'Activity Detail Legend'**
  String get participant_details_color_tooltip_legend_title;

  /// No description provided for @participant_details_color_legend_completed_task.
  ///
  /// In en, this message translates to:
  /// **'Completed task'**
  String get participant_details_color_legend_completed_task;

  /// No description provided for @participant_details_color_legend_completed_task_tooltip.
  ///
  /// In en, this message translates to:
  /// **'The participant has completed this task'**
  String get participant_details_color_legend_completed_task_tooltip;

  /// No description provided for @participant_details_color_legend_missed_task.
  ///
  /// In en, this message translates to:
  /// **'Missed task'**
  String get participant_details_color_legend_missed_task;

  /// No description provided for @participant_details_color_legend_missed_task_tooltip.
  ///
  /// In en, this message translates to:
  /// **'The participant has missed this task'**
  String get participant_details_color_legend_missed_task_tooltip;

  /// No description provided for @participant_details_color_legend_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed all tasks'**
  String get participant_details_color_legend_completed;

  /// No description provided for @participant_details_color_legend_partially_completed.
  ///
  /// In en, this message translates to:
  /// **'Some tasks incomplete'**
  String get participant_details_color_legend_partially_completed;

  /// No description provided for @participant_details_color_legend_missed.
  ///
  /// In en, this message translates to:
  /// **'Missed all tasks'**
  String get participant_details_color_legend_missed;

  /// No description provided for @participant_details_completed_legend_tooltip.
  ///
  /// In en, this message translates to:
  /// **'All intervention and survey tasks have been completed for this day'**
  String get participant_details_completed_legend_tooltip;

  /// No description provided for @participant_details_partially_completed_legend_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Not all intervention or survey tasks have been completed for this day'**
  String get participant_details_partially_completed_legend_tooltip;

  /// No description provided for @participant_details_incomplete_legend_tooltip.
  ///
  /// In en, this message translates to:
  /// **'No intervention or survey tasks have been completed for this day'**
  String get participant_details_incomplete_legend_tooltip;

  /// No description provided for @participant_details_progress_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No progress data available yet'**
  String get participant_details_progress_empty_title;

  /// No description provided for @participant_details_progress_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Once the participant has started the study, you can monitor their progress here.'**
  String get participant_details_progress_empty_description;

  /// No description provided for @monitoring_no_participants_title.
  ///
  /// In en, this message translates to:
  /// **'There are no participants in this study yet'**
  String get monitoring_no_participants_title;

  /// No description provided for @monitoring_no_participants_description.
  ///
  /// In en, this message translates to:
  /// **'Once participants have enrolled in your study, you can monitor their progress and view their data here.'**
  String get monitoring_no_participants_description;

  /// No description provided for @monitoring_participants_title.
  ///
  /// In en, this message translates to:
  /// **'Participant overview'**
  String get monitoring_participants_title;

  /// No description provided for @monitoring_total.
  ///
  /// In en, this message translates to:
  /// **'Total number of participants'**
  String get monitoring_total;

  /// No description provided for @monitoring_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get monitoring_active;

  /// No description provided for @monitoring_active_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Number of participants who are currently in the study'**
  String get monitoring_active_tooltip;

  /// No description provided for @monitoring_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get monitoring_inactive;

  /// No description provided for @monitoring_inactive_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Number of participants who have not completed a task for more than 3 days in a row'**
  String get monitoring_inactive_tooltip;

  /// No description provided for @monitoring_dropout.
  ///
  /// In en, this message translates to:
  /// **'Dropout'**
  String get monitoring_dropout;

  /// No description provided for @monitoring_dropout_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Number of participants who have left the study before the end or are inactive more than 5 days in a row'**
  String get monitoring_dropout_tooltip;

  /// No description provided for @monitoring_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get monitoring_completed;

  /// No description provided for @monitoring_completed_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Number of participants who have reached the end of the study'**
  String get monitoring_completed_tooltip;

  /// No description provided for @monitoring_table_column_participant_id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get monitoring_table_column_participant_id;

  /// No description provided for @monitoring_table_column_invite_code.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get monitoring_table_column_invite_code;

  /// No description provided for @monitoring_table_column_enrolled.
  ///
  /// In en, this message translates to:
  /// **'Started at'**
  String get monitoring_table_column_enrolled;

  /// No description provided for @monitoring_table_column_last_activity.
  ///
  /// In en, this message translates to:
  /// **'Last activity'**
  String get monitoring_table_column_last_activity;

  /// No description provided for @monitoring_table_column_day_in_study.
  ///
  /// In en, this message translates to:
  /// **'Day in study'**
  String get monitoring_table_column_day_in_study;

  /// No description provided for @monitoring_table_column_completed_intervention_tasks.
  ///
  /// In en, this message translates to:
  /// **'Completed intervention tasks'**
  String get monitoring_table_column_completed_intervention_tasks;

  /// No description provided for @monitoring_table_column_completed_surveys.
  ///
  /// In en, this message translates to:
  /// **'Completed surveys'**
  String get monitoring_table_column_completed_surveys;

  /// No description provided for @monitoring_table_row_tooltip_dropout.
  ///
  /// In en, this message translates to:
  /// **'This participant has dropped out of the study and no new activity will be added'**
  String get monitoring_table_row_tooltip_dropout;

  /// No description provided for @monitoring_table_days_in_study_header_tooltip.
  ///
  /// In en, this message translates to:
  /// **'The number of days the participant has been in the study'**
  String get monitoring_table_days_in_study_header_tooltip;

  /// No description provided for @monitoring_table_completed_interventions_header_tooltip.
  ///
  /// In en, this message translates to:
  /// **'All of intervention tasks have been completed throughout the study'**
  String get monitoring_table_completed_interventions_header_tooltip;

  /// No description provided for @monitoring_table_completed_surveys_header_tooltip.
  ///
  /// In en, this message translates to:
  /// **'A survey is completed, if all of its tasks have been completed for that day'**
  String get monitoring_table_completed_surveys_header_tooltip;

  /// No description provided for @banner_text_study_recruit_draft.
  ///
  /// In en, this message translates to:
  /// **'Because this study has not been launched yet, the links on this page will not work yet.'**
  String get banner_text_study_recruit_draft;

  /// No description provided for @banner_text_study_analyze_draft.
  ///
  /// In en, this message translates to:
  /// **'Because this study has not been launched yet, this page is currently based on the data generated during study testing.\nThe data on this page will be reset once you launch the study with real participants.'**
  String get banner_text_study_analyze_draft;

  /// No description provided for @action_button_study_export.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get action_button_study_export;

  /// No description provided for @action_button_study_export_prompt.
  ///
  /// In en, this message translates to:
  /// **'Want to run your own analysis?'**
  String get action_button_study_export_prompt;

  /// No description provided for @study_export_unavailable_empty_tooltip.
  ///
  /// In en, this message translates to:
  /// **'There is no data available yet'**
  String get study_export_unavailable_empty_tooltip;

  /// No description provided for @study_export_unavailable_no_permission_tooltip.
  ///
  /// In en, this message translates to:
  /// **'You do not have sufficient permission to access this study\'s data'**
  String get study_export_unavailable_no_permission_tooltip;

  /// No description provided for @study_launch_title.
  ///
  /// In en, this message translates to:
  /// **'Great work! 👏 Ready to launch?'**
  String get study_launch_title;

  /// No description provided for @study_launch_participation_intro.
  ///
  /// In en, this message translates to:
  /// **'The study you are creating is'**
  String get study_launch_participation_intro;

  /// No description provided for @study_launch_participation_outro.
  ///
  /// In en, this message translates to:
  /// **''**
  String get study_launch_participation_outro;

  /// No description provided for @study_launch_post_launch_intro.
  ///
  /// In en, this message translates to:
  /// **'After launching your study:'**
  String get study_launch_post_launch_intro;

  /// No description provided for @study_launch_post_launch_summary.
  ///
  /// In en, this message translates to:
  /// **'- The study design will be locked and you won’t be able to make any changes\n- All data from test runs will be reset (incl. test users, their tasks and results)'**
  String get study_launch_post_launch_summary;

  /// No description provided for @study_launch_success_title.
  ///
  /// In en, this message translates to:
  /// **'Your study is live!'**
  String get study_launch_success_title;

  /// No description provided for @study_launch_success_description.
  ///
  /// In en, this message translates to:
  /// **'Next, you can start inviting and enrolling your participants in the StudyU App.'**
  String get study_launch_success_description;

  /// No description provided for @study_public_launch_success_description.
  ///
  /// In en, this message translates to:
  /// **'Your study is now available for everyone in the StudyU App.'**
  String get study_public_launch_success_description;

  /// No description provided for @action_button_post_launch_followup.
  ///
  /// In en, this message translates to:
  /// **'Add participants'**
  String get action_button_post_launch_followup;

  /// No description provided for @action_button_post_launch_followup_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get action_button_post_launch_followup_skip;

  /// No description provided for @action_button_study_participation_change.
  ///
  /// In en, this message translates to:
  /// **'Change\nparticipation'**
  String get action_button_study_participation_change;

  /// No description provided for @form_field_required.
  ///
  /// In en, this message translates to:
  /// **'Field must not be empty'**
  String get form_field_required;

  /// No description provided for @form_invalid_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please fill out all fields as required'**
  String get form_invalid_prompt;

  /// No description provided for @copy_suffix_label.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy_suffix_label;

  /// No description provided for @date_diff_years.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 year ago} other{{count} years ago}}'**
  String date_diff_years(num count);

  /// No description provided for @date_diff_months.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 month ago} other{{count} months ago}}'**
  String date_diff_months(num count);

  /// No description provided for @date_diff_days.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 day ago} other{{count} days ago}}'**
  String date_diff_days(num count);

  /// No description provided for @date_diff_hours.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 hour ago} other{{count} hours ago}}'**
  String date_diff_hours(num count);

  /// No description provided for @date_diff_minutes.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String date_diff_minutes(num count);

  /// No description provided for @date_diff_seconds.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 second ago} other{{count} seconds ago}}'**
  String date_diff_seconds(num count);

  /// No description provided for @date_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get date_just_now;

  /// No description provided for @action_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get action_edit;

  /// No description provided for @action_pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get action_pin;

  /// No description provided for @action_unpin.
  ///
  /// In en, this message translates to:
  /// **'Remove pin'**
  String get action_unpin;

  /// No description provided for @action_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get action_delete;

  /// No description provided for @action_delete_invite_code.
  ///
  /// In en, this message translates to:
  /// **'Delete invite code'**
  String get action_delete_invite_code;

  /// No description provided for @action_delete_code.
  ///
  /// In en, this message translates to:
  /// **'Delete code'**
  String get action_delete_code;

  /// No description provided for @action_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get action_remove;

  /// No description provided for @action_duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get action_duplicate;

  /// No description provided for @action_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get action_clipboard;

  /// No description provided for @action_copy_invite_code.
  ///
  /// In en, this message translates to:
  /// **'Copy invite code'**
  String get action_copy_invite_code;

  /// No description provided for @action_copy_invite_link.
  ///
  /// In en, this message translates to:
  /// **'Copy invite link'**
  String get action_copy_invite_link;

  /// No description provided for @action_qr_code_show.
  ///
  /// In en, this message translates to:
  /// **'View QR code'**
  String get action_qr_code_show;

  /// No description provided for @action_qr_code_download.
  ///
  /// In en, this message translates to:
  /// **'Download QR code'**
  String get action_qr_code_download;

  /// No description provided for @action_share.
  ///
  /// In en, this message translates to:
  /// **'Share invite link'**
  String get action_share;

  /// No description provided for @action_copy_link.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get action_copy_link;

  /// No description provided for @action_copy_invitation.
  ///
  /// In en, this message translates to:
  /// **'Copy invitation'**
  String get action_copy_invitation;

  /// No description provided for @action_reportPrimary.
  ///
  /// In en, this message translates to:
  /// **'Set as primary report'**
  String get action_reportPrimary;

  /// No description provided for @action_study_duplicate_draft.
  ///
  /// In en, this message translates to:
  /// **'Copy as draft'**
  String get action_study_duplicate_draft;

  /// No description provided for @action_study_export_results.
  ///
  /// In en, this message translates to:
  /// **'Export results'**
  String get action_study_export_results;

  /// No description provided for @action_export_study_definition.
  ///
  /// In en, this message translates to:
  /// **'Export study definition'**
  String get action_export_study_definition;

  /// No description provided for @dialog_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get dialog_continue;

  /// No description provided for @dialog_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialog_close;

  /// No description provided for @dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialog_cancel;

  /// No description provided for @dialog_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dialog_save;

  /// No description provided for @sync_initial.
  ///
  /// In en, this message translates to:
  /// **'No changes to be saved'**
  String get sync_initial;

  /// No description provided for @sync_dirty.
  ///
  /// In en, this message translates to:
  /// **'There are unsaved changes'**
  String get sync_dirty;

  /// No description provided for @sync_saving.
  ///
  /// In en, this message translates to:
  /// **'Saving changes...'**
  String get sync_saving;

  /// No description provided for @sync_done.
  ///
  /// In en, this message translates to:
  /// **'All changes saved'**
  String get sync_done;

  /// No description provided for @sync_last_saved.
  ///
  /// In en, this message translates to:
  /// **'Last saved'**
  String get sync_last_saved;

  /// No description provided for @sync_failed.
  ///
  /// In en, this message translates to:
  /// **'Changes could not be saved'**
  String get sync_failed;

  /// No description provided for @iconpicker_nonempty_prompt.
  ///
  /// In en, this message translates to:
  /// **'Change icon'**
  String get iconpicker_nonempty_prompt;

  /// No description provided for @iconpicker_empty_prompt.
  ///
  /// In en, this message translates to:
  /// **'Pick an icon'**
  String get iconpicker_empty_prompt;

  /// No description provided for @iconpicker_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Pick an icon'**
  String get iconpicker_dialog_title;

  /// No description provided for @dialog_unsaved_changes_title.
  ///
  /// In en, this message translates to:
  /// **'Discard unsaved changes?'**
  String get dialog_unsaved_changes_title;

  /// No description provided for @dialog_unsaved_changes_description.
  ///
  /// In en, this message translates to:
  /// **'If you leave now, your recent changes will be permanently lost.'**
  String get dialog_unsaved_changes_description;

  /// No description provided for @dialog_action_unsaved_changes_stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get dialog_action_unsaved_changes_stay;

  /// No description provided for @dialog_action_unsaved_changes_discard.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get dialog_action_unsaved_changes_discard;

  /// No description provided for @under_construction.
  ///
  /// In en, this message translates to:
  /// **'Under construction'**
  String get under_construction;

  /// No description provided for @under_construction_description.
  ///
  /// In en, this message translates to:
  /// **'We are still busy working on this part, check back soon!'**
  String get under_construction_description;

  /// No description provided for @fitbit_credentials_instruction.
  ///
  /// In en, this message translates to:
  /// **'To integrate Fitbit data, follow these steps to obtain your Client ID and Client Secret:'**
  String get fitbit_credentials_instruction;

  /// No description provided for @fitbit_credentials_step1.
  ///
  /// In en, this message translates to:
  /// **'1. Go to the Fitbit Developer Portal.'**
  String get fitbit_credentials_step1;

  /// No description provided for @fitbit_credentials_step2.
  ///
  /// In en, this message translates to:
  /// **'2. Log in with your Fitbit account or create one if you do not have it.'**
  String get fitbit_credentials_step2;

  /// No description provided for @fitbit_credentials_step3.
  ///
  /// In en, this message translates to:
  /// **'3. Navigate to the \"Manage\" section and select \"Register an App\".'**
  String get fitbit_credentials_step3;

  /// No description provided for @fitbit_credentials_step4.
  ///
  /// In en, this message translates to:
  /// **'4. Fill in the required fields such as application name, description, and Redirect URL (use: \"studyu://fitbit/auth\").'**
  String get fitbit_credentials_step4;

  /// No description provided for @fitbit_credentials_step5.
  ///
  /// In en, this message translates to:
  /// **'5. Select \"Client\" under \"OAuth 2.0 Application Type\" and set \"Access\" to \"Read-Only.\"'**
  String get fitbit_credentials_step5;

  /// No description provided for @fitbit_credentials_step6.
  ///
  /// In en, this message translates to:
  /// **'6. Submit the form to get your \"Client ID\" and \"Client Secret\".'**
  String get fitbit_credentials_step6;

  /// No description provided for @fitbit_credentials_step7.
  ///
  /// In en, this message translates to:
  /// **'7. Please fill the following form to obtain access for intraday data. Without this, you cannot obtain any data from Fitbit for your trials.'**
  String get fitbit_credentials_step7;

  /// No description provided for @fitbit_credentials_step8.
  ///
  /// In en, this message translates to:
  /// **'8. Copy and paste the credentials below.'**
  String get fitbit_credentials_step8;

  /// No description provided for @fitbit_credentials_success_instruction.
  ///
  /// In en, this message translates to:
  /// **'Once you enter the credentials, Fitbit integration will be enabled for your study.'**
  String get fitbit_credentials_success_instruction;

  /// No description provided for @fitbit_credentials_add_question_instruction.
  ///
  /// In en, this message translates to:
  /// **'To add a Fitbit question, navigate to the measurements section and create a new Fitbit Question within a measurement.'**
  String get fitbit_credentials_add_question_instruction;

  /// No description provided for @fitbit_credentials_screenshot_step1.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Developer Portal'**
  String get fitbit_credentials_screenshot_step1;

  /// No description provided for @fitbit_credentials_screenshot_step2.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Login'**
  String get fitbit_credentials_screenshot_step2;

  /// No description provided for @fitbit_credentials_screenshot_step3.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Register App'**
  String get fitbit_credentials_screenshot_step3;

  /// No description provided for @fitbit_credentials_screenshot_step4.
  ///
  /// In en, this message translates to:
  /// **'Step 4: Input Details'**
  String get fitbit_credentials_screenshot_step4;

  /// No description provided for @fitbit_credentials_screenshot_step5.
  ///
  /// In en, this message translates to:
  /// **'Step 5: Set Access'**
  String get fitbit_credentials_screenshot_step5;

  /// No description provided for @fitbit_credentials_screenshot_step6.
  ///
  /// In en, this message translates to:
  /// **'Step 6: Get Credentials'**
  String get fitbit_credentials_screenshot_step6;

  /// No description provided for @fitbit_credentials_screenshot_step7.
  ///
  /// In en, this message translates to:
  /// **'Step 7: Fill Form'**
  String get fitbit_credentials_screenshot_step7;

  /// No description provided for @fitbit_credentials_cannot_change_title.
  ///
  /// In en, this message translates to:
  /// **'Fitbit credentials can\'t be changed'**
  String get fitbit_credentials_cannot_change_title;

  /// No description provided for @fitbit_credentials_cannot_change_description.
  ///
  /// In en, this message translates to:
  /// **'Fitbit credentials can\'t be changed while the study is not in draft mode.'**
  String get fitbit_credentials_cannot_change_description;

  /// No description provided for @fitbit_only_participant_title.
  ///
  /// In en, this message translates to:
  /// **'If you\'re running this study just for yourself'**
  String get fitbit_only_participant_title;

  /// No description provided for @fitbit_only_participant_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Since you\'re both creating and participating in this study, you don\'t need to fill out the intraday data request form. Simply follow these easy steps:'**
  String get fitbit_only_participant_subtitle;

  /// No description provided for @fitbit_only_participant_description.
  ///
  /// In en, this message translates to:
  /// **'If you\'re running this study just for yourself, you must use your own Fitbit account\'s Client ID and Client Secret on the previous page.'**
  String get fitbit_only_participant_description;

  /// No description provided for @fitbit_multiple_participant_title.
  ///
  /// In en, this message translates to:
  /// **'If you\'re running this study for multiple participants'**
  String get fitbit_multiple_participant_title;

  /// No description provided for @fitbit_multiple_participant_description.
  ///
  /// In en, this message translates to:
  /// **'Each participant must log in with their own Fitbit account in the StudyU app. The data will be collected separately for each participant.'**
  String get fitbit_multiple_participant_description;

  /// No description provided for @study_import_title.
  ///
  /// In en, this message translates to:
  /// **'Import Study'**
  String get study_import_title;

  /// No description provided for @study_import_description.
  ///
  /// In en, this message translates to:
  /// **'Import a study definition from a JSON file. This will create a new draft study.'**
  String get study_import_description;

  /// No description provided for @study_import_button.
  ///
  /// In en, this message translates to:
  /// **'Import Study from JSON'**
  String get study_import_button;

  /// No description provided for @study_import_success.
  ///
  /// In en, this message translates to:
  /// **'Study imported successfully'**
  String get study_import_success;

  /// No description provided for @study_import_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to import study: {error}'**
  String study_import_error(String error);

  /// No description provided for @fitbit_only_participant_step_1.
  ///
  /// In en, this message translates to:
  /// **'When creating your Fitbit app, choose \'Personal\' as the app type.'**
  String get fitbit_only_participant_step_1;

  /// No description provided for @fitbit_only_participant_step_2.
  ///
  /// In en, this message translates to:
  /// **'When syncing data, make sure to use the same Google account that\'s connected to your Fitbit watch and the Fitbit app you\'ve set up.'**
  String get fitbit_only_participant_step_2;

  /// No description provided for @client_id.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get client_id;

  /// No description provided for @client_id_label_help.
  ///
  /// In en, this message translates to:
  /// **'Enter the Client ID from Fitbit Developer Portal.'**
  String get client_id_label_help;

  /// No description provided for @client_id_hint.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get client_id_hint;

  /// No description provided for @client_secret.
  ///
  /// In en, this message translates to:
  /// **'Client Secret'**
  String get client_secret;

  /// No description provided for @client_secret_label_help.
  ///
  /// In en, this message translates to:
  /// **'Enter the Client Secret from Fitbit Developer Portal.'**
  String get client_secret_label_help;

  /// No description provided for @client_secret_hint.
  ///
  /// In en, this message translates to:
  /// **'Client Secret'**
  String get client_secret_hint;

  /// No description provided for @fitbit_credentials_how_to_obtain.
  ///
  /// In en, this message translates to:
  /// **'How to obtain Fitbit credentials'**
  String get fitbit_credentials_how_to_obtain;

  /// No description provided for @fitbit_client_id_required.
  ///
  /// In en, this message translates to:
  /// **'Client ID is required'**
  String get fitbit_client_id_required;

  /// No description provided for @fitbit_client_secret_required.
  ///
  /// In en, this message translates to:
  /// **'Client secret is required'**
  String get fitbit_client_secret_required;

  /// No description provided for @fitbit_question_type_required.
  ///
  /// In en, this message translates to:
  /// **'At least one Fitbit type must be selected.'**
  String get fitbit_question_type_required;

  /// No description provided for @screenshots_for_guidance.
  ///
  /// In en, this message translates to:
  /// **'Screenshots for Guidance:'**
  String get screenshots_for_guidance;

  /// No description provided for @fitbit_credentials_not_set.
  ///
  /// In en, this message translates to:
  /// **'Fitbit credentials are not set. Please navigate to the \'Fitbit\' tab in the study designer to enter your Fitbit client ID and client secret. Once completed, return here to add Fitbit questions.'**
  String get fitbit_credentials_not_set;

  /// No description provided for @fitbit_question_type_heartrate_description.
  ///
  /// In en, this message translates to:
  /// **'Captures heart rate measured every minute throughout the day.'**
  String get fitbit_question_type_heartrate_description;

  /// No description provided for @fitbit_question_type_steps_description.
  ///
  /// In en, this message translates to:
  /// **'Records the number of steps taken, measured every minute.'**
  String get fitbit_question_type_steps_description;

  /// No description provided for @fitbit_question_type_sleep_description.
  ///
  /// In en, this message translates to:
  /// **'Records sleep stages (wake, light, deep, REM) at 30-second to 1-minute intervals during your sleep.'**
  String get fitbit_question_type_sleep_description;

  /// No description provided for @html_styling_banner_description.
  ///
  /// In en, this message translates to:
  /// **'You can use basic HTML tags to style the content of the fields marked with styleable. Some examples are:'**
  String get html_styling_banner_description;

  /// No description provided for @html_styling_bold_example.
  ///
  /// In en, this message translates to:
  /// **'Make your text bold'**
  String get html_styling_bold_example;

  /// No description provided for @html_styling_bold_code.
  ///
  /// In en, this message translates to:
  /// **'<b>Bold text</b>'**
  String get html_styling_bold_code;

  /// No description provided for @html_styling_italic_example.
  ///
  /// In en, this message translates to:
  /// **'Make your text italic'**
  String get html_styling_italic_example;

  /// No description provided for @html_styling_italic_code.
  ///
  /// In en, this message translates to:
  /// **'<i>Italic text</i>'**
  String get html_styling_italic_code;

  /// No description provided for @html_styling_underline_example.
  ///
  /// In en, this message translates to:
  /// **'Underline your text'**
  String get html_styling_underline_example;

  /// No description provided for @html_styling_underline_code.
  ///
  /// In en, this message translates to:
  /// **'<u>Underlined text</u>'**
  String get html_styling_underline_code;

  /// No description provided for @html_styling_link_example.
  ///
  /// In en, this message translates to:
  /// **'Add clickable links'**
  String get html_styling_link_example;

  /// No description provided for @html_styling_link_code.
  ///
  /// In en, this message translates to:
  /// **'<a href=\"https://example.com\">Link text</a>'**
  String get html_styling_link_code;

  /// No description provided for @html_styling_linebreak_example.
  ///
  /// In en, this message translates to:
  /// **'Insert line breaks'**
  String get html_styling_linebreak_example;

  /// No description provided for @html_styling_linebreak_code.
  ///
  /// In en, this message translates to:
  /// **'Line 1<br>Line 2'**
  String get html_styling_linebreak_code;

  /// No description provided for @html_styling_more_info.
  ///
  /// In en, this message translates to:
  /// **'For more information, see the'**
  String get html_styling_more_info;

  /// No description provided for @html_styling_documentation_link.
  ///
  /// In en, this message translates to:
  /// **'HTML documentation'**
  String get html_styling_documentation_link;

  /// No description provided for @study_schedule_learn_more.
  ///
  /// In en, this message translates to:
  /// **'Learn more about designing a study schedule'**
  String get study_schedule_learn_more;

  /// No description provided for @study_schedule_banner_explanation.
  ///
  /// In en, this message translates to:
  /// **'We use the following terminology:\n\nEach trial consists of different intervention phases (= intervention periods = intervention blocks) of a certain length.\nFor example, a trial may contain 4 phases of 7 days each, and hence last for 28 days in total.\nThere may be an additional baseline phase, which is fixed to have the same length as each phase.\nThat means a trial with 4 phases of 7 days each and an additional baseline period will last for 35 days in total.\n\nThe phases may follow different sequences.\nWe consider two interventions, A and B.\nThey can follow an alternating, counterbalanced, random, or custom design.\n\nWe define one cycle of phases as a pair of treatment phases for the alternating, counterbalanced, and random designs.\nThe random design yields either an alternating or counterbalanced sequence.\nOne cycle of the respective designs yields AB (alternating), AB (counterbalanced), or AB/BA (random).\nTwo cycles yield ABAB (alternating), ABBA (counterbalanced), or ABAB/ABBA (random).\n\nIn the custom design, a custom sequence can be defined, e.g., ABBAA.\nHere, one cycle refers to the full custom sequence, i.e., 2 cycles of ABBAA would yield ABBAAABBAA.'**
  String get study_schedule_banner_explanation;

  /// No description provided for @study_schedule_banner_description.
  ///
  /// In en, this message translates to:
  /// **'Design effective N-of-1 trials by understanding the different sequence types and how they affect your study results.'**
  String get study_schedule_banner_description;

  /// No description provided for @study_schedule_alternating_description.
  ///
  /// In en, this message translates to:
  /// **'Alternating: Each participant follows an ABAB pattern, switching between interventions in a predictable sequence.'**
  String get study_schedule_alternating_description;

  /// No description provided for @study_schedule_balanced_description.
  ///
  /// In en, this message translates to:
  /// **'Counterbalanced: Each participant follows an ABBA pattern, switching between interventions in a predictable sequence.'**
  String get study_schedule_balanced_description;

  /// No description provided for @study_schedule_random_description.
  ///
  /// In en, this message translates to:
  /// **'Random: The sequence is completely randomized for each cycle, providing maximum variability.'**
  String get study_schedule_random_description;

  /// No description provided for @study_schedule_custom_description.
  ///
  /// In en, this message translates to:
  /// **'Custom: Define your own sequence pattern to meet specific study requirements.'**
  String get study_schedule_custom_description;

  /// No description provided for @form_nutrition_tracking_title.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Tracking'**
  String get form_nutrition_tracking_title;

  /// No description provided for @form_nutrition_tracking_enable_hint.
  ///
  /// In en, this message translates to:
  /// **'Enable nutritional tracking for this study'**
  String get form_nutrition_tracking_enable_hint;

  /// No description provided for @form_measurement_type_select.
  ///
  /// In en, this message translates to:
  /// **'Select Measurement Type'**
  String get form_measurement_type_select;

  /// No description provided for @form_measurement_type_survey.
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get form_measurement_type_survey;

  /// No description provided for @form_measurement_type_survey_description.
  ///
  /// In en, this message translates to:
  /// **'Collect self-reported data from participants using questions and scales.'**
  String get form_measurement_type_survey_description;

  /// No description provided for @form_measurement_type_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Task'**
  String get form_measurement_type_nutrition;

  /// No description provided for @form_measurement_type_nutrition_description.
  ///
  /// In en, this message translates to:
  /// **'Track participant food and drink intake using a structured journal or photo capture.'**
  String get form_measurement_type_nutrition_description;

  /// No description provided for @form_field_nutrition_instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get form_field_nutrition_instructions;

  /// No description provided for @form_field_nutrition_instructions_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter instructions for the participant'**
  String get form_field_nutrition_instructions_hint;

  /// No description provided for @form_field_nutrition_collect_meal_context.
  ///
  /// In en, this message translates to:
  /// **'Collect Meal Context'**
  String get form_field_nutrition_collect_meal_context;

  /// No description provided for @form_field_nutrition_allow_recipes.
  ///
  /// In en, this message translates to:
  /// **'Allow Recipes'**
  String get form_field_nutrition_allow_recipes;

  /// No description provided for @form_field_nutrition_minimum_meals_required.
  ///
  /// In en, this message translates to:
  /// **'Minimum Meals Required'**
  String get form_field_nutrition_minimum_meals_required;

  /// No description provided for @form_field_nutrition_minimum_meals_hint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get form_field_nutrition_minimum_meals_hint;

  /// No description provided for @form_field_nutrition_default_title.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Tracking'**
  String get form_field_nutrition_default_title;

  /// No description provided for @form_field_nutrition_custom_meal_types.
  ///
  /// In en, this message translates to:
  /// **'Custom Meal Types'**
  String get form_field_nutrition_custom_meal_types;

  /// No description provided for @form_field_nutrition_custom_meal_types_hint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use defaults'**
  String get form_field_nutrition_custom_meal_types_hint;

  /// No description provided for @form_field_nutrition_add_meal_type.
  ///
  /// In en, this message translates to:
  /// **'Add meal type'**
  String get form_field_nutrition_add_meal_type;

  /// No description provided for @form_field_nutrition_meal_type_label.
  ///
  /// In en, this message translates to:
  /// **'Meal type {index}'**
  String form_field_nutrition_meal_type_label(Object index);

  /// No description provided for @form_field_nutrition_minimum_meals_min_error.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 1'**
  String get form_field_nutrition_minimum_meals_min_error;

  /// No description provided for @filter_studies.
  ///
  /// In en, this message translates to:
  /// **'Filter Studies'**
  String get filter_studies;

  /// No description provided for @filter_manage_presets.
  ///
  /// In en, this message translates to:
  /// **'Manage Presets'**
  String get filter_manage_presets;

  /// No description provided for @filter_load_preset.
  ///
  /// In en, this message translates to:
  /// **'Load Preset'**
  String get filter_load_preset;

  /// No description provided for @filter_save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get filter_save_changes;

  /// No description provided for @filter_save_as_new.
  ///
  /// In en, this message translates to:
  /// **'Save as new'**
  String get filter_save_as_new;

  /// No description provided for @filter_delete_preset.
  ///
  /// In en, this message translates to:
  /// **'Delete preset'**
  String get filter_delete_preset;

  /// No description provided for @filter_reset_all.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get filter_reset_all;

  /// No description provided for @code_list_filter_title.
  ///
  /// In en, this message translates to:
  /// **'Filter invite codes'**
  String get code_list_filter_title;

  /// No description provided for @code_list_filter_enrolled_status.
  ///
  /// In en, this message translates to:
  /// **'Enrolled status'**
  String get code_list_filter_enrolled_status;

  /// No description provided for @code_list_filter_enrolled_min.
  ///
  /// In en, this message translates to:
  /// **'Enrolled min'**
  String get code_list_filter_enrolled_min;

  /// No description provided for @code_list_filter_enrolled_max.
  ///
  /// In en, this message translates to:
  /// **'Enrolled max'**
  String get code_list_filter_enrolled_max;

  /// No description provided for @code_list_filter_intervention_assignment.
  ///
  /// In en, this message translates to:
  /// **'Intervention assignment'**
  String get code_list_filter_intervention_assignment;

  /// No description provided for @code_list_filter_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get code_list_filter_apply;

  /// No description provided for @code_list_filter_option_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get code_list_filter_option_all;

  /// No description provided for @code_list_filter_option_unused.
  ///
  /// In en, this message translates to:
  /// **'Unused'**
  String get code_list_filter_option_unused;

  /// No description provided for @code_list_filter_option_used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get code_list_filter_option_used;

  /// No description provided for @code_list_filter_button_active.
  ///
  /// In en, this message translates to:
  /// **'Filter ({count})'**
  String code_list_filter_button_active(int count);

  /// No description provided for @filter_show_studies.
  ///
  /// In en, this message translates to:
  /// **'Show {count} Studies'**
  String filter_show_studies(int count);

  /// No description provided for @filter_dialog_save_title.
  ///
  /// In en, this message translates to:
  /// **'Save Filter Preset'**
  String get filter_dialog_save_title;

  /// No description provided for @filter_dialog_preset_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Preset Name'**
  String get filter_dialog_preset_name_hint;

  /// No description provided for @filter_category_basic.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get filter_category_basic;

  /// No description provided for @filter_category_visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility & Role'**
  String get filter_category_visibility;

  /// No description provided for @filter_category_participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get filter_category_participants;

  /// No description provided for @filter_category_dates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get filter_category_dates;

  /// No description provided for @filter_field_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get filter_field_title;

  /// No description provided for @filter_field_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filter_field_status;

  /// No description provided for @filter_field_participation.
  ///
  /// In en, this message translates to:
  /// **'Participation'**
  String get filter_field_participation;

  /// No description provided for @filter_field_result_sharing.
  ///
  /// In en, this message translates to:
  /// **'Result Sharing'**
  String get filter_field_result_sharing;

  /// No description provided for @filter_field_registry_published.
  ///
  /// In en, this message translates to:
  /// **'Registry Published'**
  String get filter_field_registry_published;

  /// No description provided for @filter_field_participant_count.
  ///
  /// In en, this message translates to:
  /// **'Participant Count'**
  String get filter_field_participant_count;

  /// No description provided for @filter_field_active_count.
  ///
  /// In en, this message translates to:
  /// **'Active Count'**
  String get filter_field_active_count;

  /// No description provided for @filter_field_completed_count.
  ///
  /// In en, this message translates to:
  /// **'Completed Count'**
  String get filter_field_completed_count;

  /// No description provided for @filter_field_created_date.
  ///
  /// In en, this message translates to:
  /// **'Created Date'**
  String get filter_field_created_date;

  /// No description provided for @filter_date_from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get filter_date_from;

  /// No description provided for @filter_date_to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get filter_date_to;

  /// No description provided for @filter_operator_contains.
  ///
  /// In en, this message translates to:
  /// **'Contains'**
  String get filter_operator_contains;

  /// No description provided for @filter_operator_equals.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get filter_operator_equals;

  /// No description provided for @filter_operator_starts_with.
  ///
  /// In en, this message translates to:
  /// **'Starts with'**
  String get filter_operator_starts_with;

  /// No description provided for @filter_operator_ends_with.
  ///
  /// In en, this message translates to:
  /// **'Ends with'**
  String get filter_operator_ends_with;

  /// No description provided for @filter_operator_is.
  ///
  /// In en, this message translates to:
  /// **'Is'**
  String get filter_operator_is;

  /// No description provided for @filter_operator_is_not.
  ///
  /// In en, this message translates to:
  /// **'Is not'**
  String get filter_operator_is_not;

  /// No description provided for @filter_operator_min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get filter_operator_min;

  /// No description provided for @filter_operator_max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get filter_operator_max;

  /// No description provided for @filter_operator_exactly.
  ///
  /// In en, this message translates to:
  /// **'Exactly'**
  String get filter_operator_exactly;

  /// No description provided for @filter_operator_more_than.
  ///
  /// In en, this message translates to:
  /// **'More than'**
  String get filter_operator_more_than;

  /// No description provided for @filter_operator_less_than.
  ///
  /// In en, this message translates to:
  /// **'Less than'**
  String get filter_operator_less_than;

  /// No description provided for @filter_bool_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get filter_bool_yes;

  /// No description provided for @filter_bool_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get filter_bool_no;

  /// No description provided for @preset_my_active_studies.
  ///
  /// In en, this message translates to:
  /// **'My Active Studies'**
  String get preset_my_active_studies;

  /// No description provided for @preset_studies_needing_attention.
  ///
  /// In en, this message translates to:
  /// **'Studies Needing Attention'**
  String get preset_studies_needing_attention;

  /// No description provided for @preset_recently_created.
  ///
  /// In en, this message translates to:
  /// **'Recently Created'**
  String get preset_recently_created;

  /// No description provided for @preset_public_studies.
  ///
  /// In en, this message translates to:
  /// **'Public Studies'**
  String get preset_public_studies;

  /// No description provided for @preset_draft_studies.
  ///
  /// In en, this message translates to:
  /// **'Draft Studies'**
  String get preset_draft_studies;

  /// No description provided for @preset_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom preset'**
  String get preset_custom;

  /// No description provided for @preset_none.
  ///
  /// In en, this message translates to:
  /// **'No custom presets'**
  String get preset_none;

  /// No description provided for @preset_tooltip_my_active_studies.
  ///
  /// In en, this message translates to:
  /// **'Studies you own that are currently running'**
  String get preset_tooltip_my_active_studies;

  /// No description provided for @preset_tooltip_studies_needing_attention.
  ///
  /// In en, this message translates to:
  /// **'Running studies with low participation'**
  String get preset_tooltip_studies_needing_attention;

  /// No description provided for @preset_tooltip_recently_created.
  ///
  /// In en, this message translates to:
  /// **'Studies created in the last 30 days'**
  String get preset_tooltip_recently_created;

  /// No description provided for @preset_tooltip_public_studies.
  ///
  /// In en, this message translates to:
  /// **'Studies published to the registry or with public results'**
  String get preset_tooltip_public_studies;

  /// No description provided for @preset_tooltip_draft_studies.
  ///
  /// In en, this message translates to:
  /// **'Studies currently in draft mode'**
  String get preset_tooltip_draft_studies;

  /// No description provided for @preset_loaded_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Currently loaded preset'**
  String get preset_loaded_tooltip;

  /// No description provided for @filter_result_sharing_public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get filter_result_sharing_public;

  /// No description provided for @filter_result_sharing_private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get filter_result_sharing_private;

  /// No description provided for @filter_result_sharing_organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get filter_result_sharing_organization;

  /// No description provided for @participation_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get participation_open;

  /// No description provided for @participation_invite.
  ///
  /// In en, this message translates to:
  /// **'Invite-only'**
  String get participation_invite;

  /// No description provided for @filter_section_default_presets.
  ///
  /// In en, this message translates to:
  /// **'Default Presets'**
  String get filter_section_default_presets;

  /// No description provided for @filter_section_custom_presets.
  ///
  /// In en, this message translates to:
  /// **'Custom Presets'**
  String get filter_section_custom_presets;

  /// No description provided for @filter_button_advanced.
  ///
  /// In en, this message translates to:
  /// **'Configure Filters...'**
  String get filter_button_advanced;

  /// No description provided for @filter_button_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get filter_button_clear;

  /// No description provided for @filter_button_main.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter_button_main;

  /// No description provided for @code_list_no_results_title.
  ///
  /// In en, this message translates to:
  /// **'No matching invite codes'**
  String get code_list_no_results_title;

  /// No description provided for @code_list_no_results_description.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search to see more invite codes.'**
  String get code_list_no_results_description;

  /// No description provided for @code_list_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search invite codes'**
  String get code_list_search_hint;

  /// No description provided for @code_list_search_hint_compact.
  ///
  /// In en, this message translates to:
  /// **'Search codes'**
  String get code_list_search_hint_compact;

  /// No description provided for @code_list_active_count.
  ///
  /// In en, this message translates to:
  /// **'{count} active invite codes'**
  String code_list_active_count(int count);

  /// No description provided for @code_list_total_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 invite} other{{count} invites}}'**
  String code_list_total_count(int count);

  /// No description provided for @code_list_page_size.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get code_list_page_size;

  /// No description provided for @code_list_rows_per_page.
  ///
  /// In en, this message translates to:
  /// **'Rows per page:'**
  String get code_list_rows_per_page;

  /// No description provided for @code_list_page.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String code_list_page(int page);

  /// No description provided for @code_list_page_range.
  ///
  /// In en, this message translates to:
  /// **'{start}–{end} of {count}'**
  String code_list_page_range(int start, int end, int count);

  /// No description provided for @code_list_page_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading {start}–{end}...'**
  String code_list_page_loading(int start, int end);

  /// No description provided for @code_list_page_fetch_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load the next page. Check your connection and try again.'**
  String get code_list_page_fetch_error;

  /// No description provided for @code_list_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get code_list_retry;

  /// No description provided for @code_list_previous_page.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get code_list_previous_page;

  /// No description provided for @code_list_next_page.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get code_list_next_page;

  /// No description provided for @action_regenerate_invite_code.
  ///
  /// In en, this message translates to:
  /// **'Regenerate invite code'**
  String get action_regenerate_invite_code;

  /// No description provided for @dialog_qr_code_description.
  ///
  /// In en, this message translates to:
  /// **'Share the link or QR code with participants so they can access this study. When participants open the link or scan the QR code with their phone, the StudyU App opens and adds them to the study.'**
  String get dialog_qr_code_description;

  /// No description provided for @all_studies.
  ///
  /// In en, this message translates to:
  /// **'All Studies'**
  String get all_studies;

  /// No description provided for @studies_filter_add_filter.
  ///
  /// In en, this message translates to:
  /// **'Add filter'**
  String get studies_filter_add_filter;

  /// No description provided for @studies_filter_remove_filter.
  ///
  /// In en, this message translates to:
  /// **'Remove filter'**
  String get studies_filter_remove_filter;

  /// No description provided for @studies_end_of_list_create.
  ///
  /// In en, this message translates to:
  /// **'Create a study.'**
  String get studies_end_of_list_create;

  /// No description provided for @studies_end_of_list_public.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t find what you\'re looking for?'**
  String get studies_end_of_list_public;

  /// No description provided for @error_qr_code_generation.
  ///
  /// In en, this message translates to:
  /// **'The QR code could not be displayed.'**
  String get error_qr_code_generation;

  /// No description provided for @form_field_invite_link.
  ///
  /// In en, this message translates to:
  /// **'Invite link'**
  String get form_field_invite_link;

  /// No description provided for @form_field_invite_link_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Share this link with participants so they can open the StudyU App and join the study.'**
  String get form_field_invite_link_tooltip;

  /// No description provided for @form_field_invitation_message.
  ///
  /// In en, this message translates to:
  /// **'Invitation message'**
  String get form_field_invitation_message;

  /// No description provided for @invitation_message_intro.
  ///
  /// In en, this message translates to:
  /// **'You have been invited to participate in the study \"{title}\" using StudyU.'**
  String invitation_message_intro(Object title);

  /// No description provided for @invitation_message_install_app.
  ///
  /// In en, this message translates to:
  /// **'1. Install the StudyU Health app on your phone if needed:'**
  String get invitation_message_install_app;

  /// No description provided for @invitation_message_android.
  ///
  /// In en, this message translates to:
  /// **'Android: {link}'**
  String invitation_message_android(Object link);

  /// No description provided for @invitation_message_ios.
  ///
  /// In en, this message translates to:
  /// **'iPhone/iPad: {link}'**
  String invitation_message_ios(Object link);

  /// No description provided for @invitation_message_open_link.
  ///
  /// In en, this message translates to:
  /// **'2. Open this invitation link on your phone:'**
  String get invitation_message_open_link;

  /// No description provided for @invitation_message_alternative.
  ///
  /// In en, this message translates to:
  /// **'Alternatively, open the StudyU Health app and enter this invitation code:'**
  String get invitation_message_alternative;

  /// No description provided for @form_field_report_improvementDirection_hint.
  ///
  /// In en, this message translates to:
  /// **'Select an improvement direction'**
  String get form_field_report_improvementDirection_hint;

  /// No description provided for @form_field_report_data_source_hint.
  ///
  /// In en, this message translates to:
  /// **'Select a data source'**
  String get form_field_report_data_source_hint;

  /// No description provided for @form_field_report_data_source_empty.
  ///
  /// In en, this message translates to:
  /// **'No scale survey question defined'**
  String get form_field_report_data_source_empty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

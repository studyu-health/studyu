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
/// import 'l10n/app_localizations.dart';
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

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @starting_study.
  ///
  /// In en, this message translates to:
  /// **'Starting your study…'**
  String get starting_study;

  /// No description provided for @loading_error_title.
  ///
  /// In en, this message translates to:
  /// **'Loading Error'**
  String get loading_error_title;

  /// No description provided for @loading_error_description.
  ///
  /// In en, this message translates to:
  /// **'The study data could not be retrieved. If you are currently participating in a study, please first contact your study supervisor for assistance. Only contact support if you are not in a study or your supervisor instructs you to do so. Do not delete your data unless told by your supervisor or support. Deleting data will remove all your study data and you will have to rejoin the study.'**
  String get loading_error_description;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get try_again;

  /// No description provided for @delete_all_data.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get delete_all_data;

  /// No description provided for @delete_all_data_description.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete all data? This will delete all your study data and you will have to rejoin the study.'**
  String get delete_all_data_description;

  /// No description provided for @reset_app.
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get reset_app;

  /// No description provided for @what_is_studyu.
  ///
  /// In en, this message translates to:
  /// **'What is StudyU?'**
  String get what_is_studyu;

  /// No description provided for @description_part1.
  ///
  /// In en, this message translates to:
  /// **'Imagine reading the sentence: \"Eating after 6 pm decreases sleep quality\"'**
  String get description_part1;

  /// No description provided for @description_part2.
  ///
  /// In en, this message translates to:
  /// **'Now you might think something like: Well... good to know but is that affecting everyone and also ME?'**
  String get description_part2;

  /// No description provided for @description_part3.
  ///
  /// In en, this message translates to:
  /// **'The problem is: you did not take part in the study yourself, so we simply cannot answer that question. A traditional study can only answer whether it is more LIKELY that your sleep quality is affected. You would therefore have to test the effect of eating late on YOUR sleep.'**
  String get description_part3;

  /// No description provided for @description_part4.
  ///
  /// In en, this message translates to:
  /// **'This means that you would have to do your own personal study, in which you would have phases of eating late and phases of abstaining from eating late. You would regularly assess your sleep quality and in the end come to a result that could finally answer the question of whether eating late decreases your sleep quality or not. Giving you a reliable answer to such questions is the goal of StudyU.'**
  String get description_part4;

  /// No description provided for @description_part5.
  ///
  /// In en, this message translates to:
  /// **'StudyU offers the possibility to enroll to N-of-1 studies designed by experts. N-of-1 means that the number of people in the trials, which is usually indicated as N, is 1. And just like traditional trials, N-of-1 trials need a clearly defined plan (a so-called study protocol).'**
  String get description_part5;

  /// No description provided for @description_part6.
  ///
  /// In en, this message translates to:
  /// **'And because good study protocols are not easy to make, we have developed this App. Here you can choose between different N-of-1 studies, according to YOUR personal interest, and you will automatically receive a plan developed by experts that will give you a reliable result.'**
  String get description_part6;

  /// No description provided for @description_part7.
  ///
  /// In en, this message translates to:
  /// **'Once you have chosen one of our studies we will make sure that your health status allows participation. Afterwards you can enroll as a participant and adapt the study plan to your everyday life. Tasks (e.g. eating late and rating your tiredness) have to be done on a regular basis (e.g. once per day). Once you have reached the minimum study duration (usually just a few weeks) you will be able to unlock results for free.'**
  String get description_part7;

  /// No description provided for @description_part8.
  ///
  /// In en, this message translates to:
  /// **'But bear in mind that results are more reliable the longer you take actively part in the study. And in order to prevent systematic error you cannot go on with the study after unlocking results. Therefore, with the help of a progress bar we will indicate you how many tasks are still needed for the minimum and how much you could improve your results with going on for some more weeks.'**
  String get description_part8;

  /// No description provided for @description_part9.
  ///
  /// In en, this message translates to:
  /// **'But enough from our side, now it\'s time for StudyU!'**
  String get description_part9;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get get_started;

  /// No description provided for @welcome_find_study_title.
  ///
  /// In en, this message translates to:
  /// **'Find what works for you'**
  String get welcome_find_study_title;

  /// No description provided for @made_with_love_in_potsdam.
  ///
  /// In en, this message translates to:
  /// **'Made with ♥ in Potsdam'**
  String get made_with_love_in_potsdam;

  /// No description provided for @browse_public_studies.
  ///
  /// In en, this message translates to:
  /// **'Browse public studies'**
  String get browse_public_studies;

  /// No description provided for @welcome_returning_participant.
  ///
  /// In en, this message translates to:
  /// **'Already participated with StudyU?'**
  String get welcome_returning_participant;

  /// No description provided for @show_onboarding_again.
  ///
  /// In en, this message translates to:
  /// **'Show onboarding again'**
  String get show_onboarding_again;

  /// No description provided for @onboarding_page0_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to StudyU'**
  String get onboarding_page0_title;

  /// No description provided for @onboarding_page0_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Researchers can estimate what works on average. They cannot determine whether a habit or treatment works for you. StudyU helps you test that question yourself.'**
  String get onboarding_page0_subtitle;

  /// No description provided for @onboarding_page1_title.
  ///
  /// In en, this message translates to:
  /// **'Your personal study'**
  String get onboarding_page1_title;

  /// No description provided for @onboarding_page1_subtitle.
  ///
  /// In en, this message translates to:
  /// **'In an N-of-1 study, you are the only participant. You follow different phases, such as eating early and eating late, and record outcomes such as sleep quality.'**
  String get onboarding_page1_subtitle;

  /// No description provided for @onboarding_page2_title.
  ///
  /// In en, this message translates to:
  /// **'An expert study plan'**
  String get onboarding_page2_title;

  /// No description provided for @onboarding_page2_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a study that matches your question. StudyU provides an expert-designed protocol, checks whether you can participate safely, and helps fit the plan into your routine.'**
  String get onboarding_page2_subtitle;

  /// No description provided for @onboarding_page3_title.
  ///
  /// In en, this message translates to:
  /// **'Complete regular tasks'**
  String get onboarding_page3_title;

  /// No description provided for @onboarding_page3_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow the assigned option and record your observations, usually once a day. The progress bar shows how many tasks remain before you can view your results.'**
  String get onboarding_page3_subtitle;

  /// No description provided for @onboarding_page4_title.
  ///
  /// In en, this message translates to:
  /// **'Build reliable evidence'**
  String get onboarding_page4_title;

  /// No description provided for @onboarding_page4_subtitle.
  ///
  /// In en, this message translates to:
  /// **'After a few weeks, you can compare how each option worked for you. Each completed task strengthens the result. When you unlock your results, StudyU ends the study to protect the analysis.'**
  String get onboarding_page4_subtitle;

  /// No description provided for @study_selection.
  ///
  /// In en, this message translates to:
  /// **'Study Selection'**
  String get study_selection;

  /// No description provided for @study_selection_single.
  ///
  /// In en, this message translates to:
  /// **'You can only participate in one study at a time.'**
  String get study_selection_single;

  /// No description provided for @study_selection_single_why.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get study_selection_single_why;

  /// No description provided for @study_selection_single_reason.
  ///
  /// In en, this message translates to:
  /// **'If you were to participate in multiple studies at a time, the interventions of these studies might interfere with one another and alter the results.'**
  String get study_selection_single_reason;

  /// No description provided for @study_selection_unsupported_title.
  ///
  /// In en, this message translates to:
  /// **'Outdated app version'**
  String get study_selection_unsupported_title;

  /// No description provided for @study_selection_unsupported.
  ///
  /// In en, this message translates to:
  /// **'The study you are trying to join is not compatible with your app version. Please update the app to the latest version.'**
  String get study_selection_unsupported;

  /// No description provided for @study_selection_closed_title.
  ///
  /// In en, this message translates to:
  /// **'Study closed'**
  String get study_selection_closed_title;

  /// No description provided for @study_selection_closed.
  ///
  /// In en, this message translates to:
  /// **'This study is currently closed for new participants.'**
  String get study_selection_closed;

  /// No description provided for @study_selection_hidden_studies.
  ///
  /// In en, this message translates to:
  /// **'Some studies couldn\'t be shown, because your app version is outdated. Please update your app to see all available studies.'**
  String get study_selection_hidden_studies;

  /// No description provided for @study_selection_no_public_studies.
  ///
  /// In en, this message translates to:
  /// **'There are currently no public studies available. If you have an invite code, you can still join a private study.'**
  String get study_selection_no_public_studies;

  /// No description provided for @study_overview_title.
  ///
  /// In en, this message translates to:
  /// **'Study overview'**
  String get study_overview_title;

  /// No description provided for @eligibility_questionnaire_title.
  ///
  /// In en, this message translates to:
  /// **'Eligibility check'**
  String get eligibility_questionnaire_title;

  /// No description provided for @please_answer_eligibility.
  ///
  /// In en, this message translates to:
  /// **'Please answer a few questions to make sure that you can safely participate in this study.'**
  String get please_answer_eligibility;

  /// No description provided for @intervention_selection_title.
  ///
  /// In en, this message translates to:
  /// **'Intervention selection'**
  String get intervention_selection_title;

  /// No description provided for @please_select_interventions.
  ///
  /// In en, this message translates to:
  /// **'Please select two interventions to apply during the study.'**
  String get please_select_interventions;

  /// No description provided for @please_select_interventions_description.
  ///
  /// In en, this message translates to:
  /// **'The effects of these two interventions will be measured and compared during the study.'**
  String get please_select_interventions_description;

  /// No description provided for @no_interventions_available.
  ///
  /// In en, this message translates to:
  /// **'No interventions available.'**
  String get no_interventions_available;

  /// No description provided for @task_already_completed.
  ///
  /// In en, this message translates to:
  /// **'You have already completed this task today'**
  String get task_already_completed;

  /// No description provided for @task_cannot_be_completed.
  ///
  /// In en, this message translates to:
  /// **'The task cannot be completed'**
  String get task_cannot_be_completed;

  /// No description provided for @task_outside_period.
  ///
  /// In en, this message translates to:
  /// **'The task cannot be completed outside of the intervention period'**
  String get task_outside_period;

  /// No description provided for @study_notification_body.
  ///
  /// In en, this message translates to:
  /// **'A new task awaits your attention'**
  String get study_notification_body;

  /// No description provided for @intervention_phase_duration.
  ///
  /// In en, this message translates to:
  /// **'Intervention phase duration'**
  String get intervention_phase_duration;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @study_length.
  ///
  /// In en, this message translates to:
  /// **'Study length'**
  String get study_length;

  /// No description provided for @study_publisher.
  ///
  /// In en, this message translates to:
  /// **'Study Publisher'**
  String get study_publisher;

  /// No description provided for @tasks_daily.
  ///
  /// In en, this message translates to:
  /// **'Tasks:'**
  String get tasks_daily;

  /// No description provided for @baseline_description.
  ///
  /// In en, this message translates to:
  /// **'The baseline is a phase within a study in which the initial state is measured to allow later comparisons. During the baseline phase you should behave as usual, no study-specific interventions are carried out yet.'**
  String get baseline_description;

  /// No description provided for @baseline.
  ///
  /// In en, this message translates to:
  /// **'Baseline'**
  String get baseline;

  /// No description provided for @days_left.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get days_left;

  /// No description provided for @today_tasks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s tasks'**
  String get today_tasks;

  /// No description provided for @intervention_current.
  ///
  /// In en, this message translates to:
  /// **'Current intervention'**
  String get intervention_current;

  /// No description provided for @opt_out.
  ///
  /// In en, this message translates to:
  /// **'Leave study'**
  String get opt_out;

  /// No description provided for @leave_study_keep_data_title.
  ///
  /// In en, this message translates to:
  /// **'Leave study and keep your data?'**
  String get leave_study_keep_data_title;

  /// No description provided for @leave_study_keep_data_body.
  ///
  /// In en, this message translates to:
  /// **'You will stop participating in the study “{studyName}”. We will keep the progress and responses you have already submitted, and researchers may continue to use your anonymized data.\n\nYou cannot rejoin this participation after leaving. Your previous studies will not be affected.'**
  String leave_study_keep_data_body(String studyName);

  /// No description provided for @stay_in_study.
  ///
  /// In en, this message translates to:
  /// **'Stay in study'**
  String get stay_in_study;

  /// No description provided for @acknowledge_consequences.
  ///
  /// In en, this message translates to:
  /// **'I have read this information and understand the consequences.'**
  String get acknowledge_consequences;

  /// No description provided for @leave_keep_data.
  ///
  /// In en, this message translates to:
  /// **'Leave and keep my data'**
  String get leave_keep_data;

  /// No description provided for @delete_data.
  ///
  /// In en, this message translates to:
  /// **'Leave study and delete my data'**
  String get delete_data;

  /// No description provided for @leave_study_delete_data_title.
  ///
  /// In en, this message translates to:
  /// **'Leave study and delete my data?'**
  String get leave_study_delete_data_title;

  /// No description provided for @leave_study_delete_data_body.
  ///
  /// In en, this message translates to:
  /// **'You will stop participating in the study “{studyName}”. We will permanently delete your progress and responses for this study from our servers and remove its saved data from this device.\n\nThis cannot be undone. Neither you nor anyone from the study team will be able to recover this data.'**
  String leave_study_delete_data_body(String studyName);

  /// No description provided for @leave_delete_data.
  ///
  /// In en, this message translates to:
  /// **'Leave and delete my data'**
  String get leave_delete_data;

  /// No description provided for @your_journey.
  ///
  /// In en, this message translates to:
  /// **'Your journey'**
  String get your_journey;

  /// No description provided for @journey_overview_description.
  ///
  /// In en, this message translates to:
  /// **'Review your study timeline before continuing.'**
  String get journey_overview_description;

  /// No description provided for @journey_results_available.
  ///
  /// In en, this message translates to:
  /// **'Results available'**
  String get journey_results_available;

  /// No description provided for @consent.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get consent;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred!'**
  String get error;

  /// No description provided for @please_give_consent.
  ///
  /// In en, this message translates to:
  /// **'Please give your consent to participate in this study. You are required to read all boxes by clicking on them.'**
  String get please_give_consent;

  /// No description provided for @please_give_consent_why.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get please_give_consent_why;

  /// No description provided for @please_give_consent_reason.
  ///
  /// In en, this message translates to:
  /// **'Studies need to request specific consent from participants, for reasons of safety and data privacy. Hence, you must explicitly consent to participate in each study.'**
  String get please_give_consent_reason;

  /// No description provided for @user_did_not_give_consent.
  ///
  /// In en, this message translates to:
  /// **'You did not give your consent. To participate you need to give consent.'**
  String get user_did_not_give_consent;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @study_not_available_for_testing_yet.
  ///
  /// In en, this message translates to:
  /// **'This study is not available for testing yet.'**
  String get study_not_available_for_testing_yet;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// Body of the support email, includes the subject ID
  ///
  /// In en, this message translates to:
  /// **'Hello,\n\nI am experiencing a loading error in the StudyU app. My subject ID is: {subjectId}\n\nPlease assist me with this issue.\n\nThank you.'**
  String support_email_body(String subjectId);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @study_information.
  ///
  /// In en, this message translates to:
  /// **'Study information'**
  String get study_information;

  /// No description provided for @study_information_description.
  ///
  /// In en, this message translates to:
  /// **'Only share these details with your study team when they ask for them.'**
  String get study_information_description;

  /// No description provided for @study_name.
  ///
  /// In en, this message translates to:
  /// **'Study name'**
  String get study_name;

  /// No description provided for @study_id.
  ///
  /// In en, this message translates to:
  /// **'Study ID'**
  String get study_id;

  /// No description provided for @subject_id.
  ///
  /// In en, this message translates to:
  /// **'Subject ID'**
  String get subject_id;

  /// No description provided for @study_start_date.
  ///
  /// In en, this message translates to:
  /// **'Study start date'**
  String get study_start_date;

  /// No description provided for @app_version.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get app_version;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @not_available.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get not_available;

  /// No description provided for @view_study_information.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get view_study_information;

  /// No description provided for @email_study_team.
  ///
  /// In en, this message translates to:
  /// **'Contact study team'**
  String get email_study_team;

  /// No description provided for @study_team_email_unavailable.
  ///
  /// In en, this message translates to:
  /// **'This study has no contact email.'**
  String get study_team_email_unavailable;

  /// No description provided for @copy_all_information.
  ///
  /// In en, this message translates to:
  /// **'Copy all'**
  String get copy_all_information;

  /// No description provided for @all_information_copied.
  ///
  /// In en, this message translates to:
  /// **'All information copied to clipboard.'**
  String get all_information_copied;

  /// No description provided for @participant_information_email_subject.
  ///
  /// In en, this message translates to:
  /// **'[StudyU] Participant information'**
  String get participant_information_email_subject;

  /// No description provided for @participant_information_email_intro.
  ///
  /// In en, this message translates to:
  /// **'Hello,\n\nI am contacting you about my participation in the study. These are my StudyU details:'**
  String get participant_information_email_intro;

  /// No description provided for @email_app_unavailable.
  ///
  /// In en, this message translates to:
  /// **'No email app is available.'**
  String get email_app_unavailable;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm selection'**
  String get confirm;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @faq_full.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faq_full;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @next_day.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get next_day;

  /// No description provided for @could_not_save_results.
  ///
  /// In en, this message translates to:
  /// **'Could not save results'**
  String get could_not_save_results;

  /// No description provided for @take_a_photo.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get take_a_photo;

  /// No description provided for @start_recording.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get start_recording;

  /// No description provided for @stop_recording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stop_recording;

  /// No description provided for @photo_captured.
  ///
  /// In en, this message translates to:
  /// **'Photo captured'**
  String get photo_captured;

  /// No description provided for @audio_recorded.
  ///
  /// In en, this message translates to:
  /// **'Audio recorded'**
  String get audio_recorded;

  /// No description provided for @multimodal_not_supported.
  ///
  /// In en, this message translates to:
  /// **'Multimodal Trials are currently not supported to run in a web browser. Please use the StudyU App for Android or iOS.'**
  String get multimodal_not_supported;

  /// No description provided for @camera_access_denied.
  ///
  /// In en, this message translates to:
  /// **'Camera access denied'**
  String get camera_access_denied;

  /// No description provided for @no_camera_available.
  ///
  /// In en, this message translates to:
  /// **'No camera available'**
  String get no_camera_available;

  /// No description provided for @microphone_access_denied.
  ///
  /// In en, this message translates to:
  /// **'Microphone access denied'**
  String get microphone_access_denied;

  /// No description provided for @camera_error.
  ///
  /// In en, this message translates to:
  /// **'Camera error'**
  String get camera_error;

  /// No description provided for @recording_error.
  ///
  /// In en, this message translates to:
  /// **'Recording error'**
  String get recording_error;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @use_device_language.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get use_device_language;

  /// No description provided for @en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get en;

  /// No description provided for @de.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get de;

  /// No description provided for @current_report.
  ///
  /// In en, this message translates to:
  /// **'Current report'**
  String get current_report;

  /// No description provided for @report_history.
  ///
  /// In en, this message translates to:
  /// **'Report history'**
  String get report_history;

  /// No description provided for @no_reports_found.
  ///
  /// In en, this message translates to:
  /// **'No reports defined yet'**
  String get no_reports_found;

  /// No description provided for @current_power_level.
  ///
  /// In en, this message translates to:
  /// **'Current status'**
  String get current_power_level;

  /// No description provided for @not_enough_data.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get not_enough_data;

  /// No description provided for @barely_enough_data.
  ///
  /// In en, this message translates to:
  /// **'Barely enough data'**
  String get barely_enough_data;

  /// No description provided for @enough_data.
  ///
  /// In en, this message translates to:
  /// **'Enough data'**
  String get enough_data;

  /// No description provided for @legal_documents.
  ///
  /// In en, this message translates to:
  /// **'Legal documents'**
  String get legal_documents;

  /// No description provided for @legal_documents_description.
  ///
  /// In en, this message translates to:
  /// **'Please review and accept these documents to continue.'**
  String get legal_documents_description;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get terms;

  /// No description provided for @terms_read.
  ///
  /// In en, this message translates to:
  /// **'Read Terms of Use'**
  String get terms_read;

  /// No description provided for @terms_content.
  ///
  /// In en, this message translates to:
  /// **'The terms of use give an overview on the purpose and use of the StudyU app.'**
  String get terms_content;

  /// No description provided for @terms_agree.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the terms of use'**
  String get terms_agree;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @privacy_read.
  ///
  /// In en, this message translates to:
  /// **'Read Privacy Policy'**
  String get privacy_read;

  /// No description provided for @privacy_content.
  ///
  /// In en, this message translates to:
  /// **'The privacy policy describes which data is stored, why, when, where, access rights, and which rights you have.'**
  String get privacy_content;

  /// No description provided for @privacy_agree.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the privacy policy'**
  String get privacy_agree;

  /// No description provided for @legal_notice.
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get legal_notice;

  /// No description provided for @legal_notice_content.
  ///
  /// In en, this message translates to:
  /// **'The legal notice shows who is responsible for StudyU and how you can contact us.'**
  String get legal_notice_content;

  /// No description provided for @imprint_read.
  ///
  /// In en, this message translates to:
  /// **'Read Legal Notice'**
  String get imprint_read;

  /// No description provided for @invite_code_button.
  ///
  /// In en, this message translates to:
  /// **'Join with an invite code'**
  String get invite_code_button;

  /// No description provided for @private_study_invite_code.
  ///
  /// In en, this message translates to:
  /// **'Enter invite code'**
  String get private_study_invite_code;

  /// No description provided for @private_study_invite_code_description.
  ///
  /// In en, this message translates to:
  /// **'Enter the code shared by your study team.'**
  String get private_study_invite_code_description;

  /// No description provided for @invite_code.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get invite_code;

  /// No description provided for @invalid_invite_code.
  ///
  /// In en, this message translates to:
  /// **'Not a valid invite code'**
  String get invalid_invite_code;

  /// No description provided for @was_saved_to.
  ///
  /// In en, this message translates to:
  /// **'The file was saved to '**
  String get was_saved_to;

  /// No description provided for @save_not_supported.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get save_not_supported;

  /// No description provided for @save_not_supported_description.
  ///
  /// In en, this message translates to:
  /// **'Downloading files is currently not supported in the web version.'**
  String get save_not_supported_description;

  /// No description provided for @eligible_no.
  ///
  /// In en, this message translates to:
  /// **'You are not eligible for this study'**
  String get eligible_no;

  /// No description provided for @eligible_yes.
  ///
  /// In en, this message translates to:
  /// **'You are eligible for this study'**
  String get eligible_yes;

  /// No description provided for @eligible_mistake.
  ///
  /// In en, this message translates to:
  /// **'If you made a mistake, you can still change your answers'**
  String get eligible_mistake;

  /// No description provided for @eligible_choice_multi_selection.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply (optional)'**
  String get eligible_choice_multi_selection;

  /// No description provided for @eligible_choice_multi_selection_required.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply (at least one required)'**
  String get eligible_choice_multi_selection_required;

  /// No description provided for @report_overview.
  ///
  /// In en, this message translates to:
  /// **'Report overview'**
  String get report_overview;

  /// No description provided for @report_primary_result.
  ///
  /// In en, this message translates to:
  /// **'Primary Result'**
  String get report_primary_result;

  /// No description provided for @report_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'This report is only valid if you entered all information correctly.'**
  String get report_disclaimer;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @performance_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview of completion of tasks'**
  String get performance_overview;

  /// No description provided for @performance_overview_interventions.
  ///
  /// In en, this message translates to:
  /// **'Interventions'**
  String get performance_overview_interventions;

  /// No description provided for @performance_overview_observations.
  ///
  /// In en, this message translates to:
  /// **'Observations'**
  String get performance_overview_observations;

  /// No description provided for @completed_study.
  ///
  /// In en, this message translates to:
  /// **'You completed your last study. Look at past reports or start a new study.'**
  String get completed_study;

  /// No description provided for @app_support.
  ///
  /// In en, this message translates to:
  /// **'App support'**
  String get app_support;

  /// No description provided for @app_support_text.
  ///
  /// In en, this message translates to:
  /// **'Contact for problems or questions with the app'**
  String get app_support_text;

  /// No description provided for @study_support.
  ///
  /// In en, this message translates to:
  /// **'Study support'**
  String get study_support;

  /// No description provided for @study_support_text.
  ///
  /// In en, this message translates to:
  /// **'Contact for problems or questions with the study'**
  String get study_support_text;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @irb.
  ///
  /// In en, this message translates to:
  /// **'Institutional Review Board'**
  String get irb;

  /// No description provided for @researchers.
  ///
  /// In en, this message translates to:
  /// **'Researchers'**
  String get researchers;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get additionalInfo;

  /// No description provided for @free_text_min_length_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least {min} characters'**
  String free_text_min_length_error(num min);

  /// No description provided for @free_text_max_length_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter at most {max} characters'**
  String free_text_max_length_error(num max);

  /// No description provided for @free_text_alphanumeric_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter only alphanumeric characters'**
  String get free_text_alphanumeric_error;

  /// No description provided for @free_text_numeric_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter only numeric characters'**
  String get free_text_numeric_error;

  /// No description provided for @free_text_custom_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value in the required format'**
  String get free_text_custom_error;

  /// No description provided for @app_outdated_message.
  ///
  /// In en, this message translates to:
  /// **'A new version of the StudyU App is available. Please update to get the latest features and improvements. Thank you for your support!'**
  String get app_outdated_message;

  /// No description provided for @update_now.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get update_now;

  /// No description provided for @text_summary_section_prefix_higher.
  ///
  /// In en, this message translates to:
  /// **'Your '**
  String get text_summary_section_prefix_higher;

  /// No description provided for @text_summary_section_was_higher.
  ///
  /// In en, this message translates to:
  /// **' was higher during intervention: '**
  String get text_summary_section_was_higher;

  /// No description provided for @text_summary_section_was_lower.
  ///
  /// In en, this message translates to:
  /// **' was lower during intervention: '**
  String get text_summary_section_was_lower;

  /// No description provided for @text_summary_section_compared_to.
  ///
  /// In en, this message translates to:
  /// **' compared to: '**
  String get text_summary_section_compared_to;

  /// No description provided for @text_summary_section_and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get text_summary_section_and;

  /// No description provided for @text_summary_section_no_evidence.
  ///
  /// In en, this message translates to:
  /// **'There was no evidence for a difference in '**
  String get text_summary_section_no_evidence;

  /// No description provided for @text_summary_section_between.
  ///
  /// In en, this message translates to:
  /// **' between interventions: '**
  String get text_summary_section_between;

  /// No description provided for @intervention.
  ///
  /// In en, this message translates to:
  /// **'Intervention'**
  String get intervention;

  /// No description provided for @phase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get phase;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @no_data_available_yet.
  ///
  /// In en, this message translates to:
  /// **'No data available yet'**
  String get no_data_available_yet;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @show_colorless_gauges.
  ///
  /// In en, this message translates to:
  /// **'Enable accessible charts'**
  String get show_colorless_gauges;

  /// No description provided for @mean.
  ///
  /// In en, this message translates to:
  /// **'mean'**
  String get mean;

  /// No description provided for @t_statistic.
  ///
  /// In en, this message translates to:
  /// **'t-statistic'**
  String get t_statistic;

  /// No description provided for @degrees_of_freedom.
  ///
  /// In en, this message translates to:
  /// **'Degrees of freedom'**
  String get degrees_of_freedom;

  /// No description provided for @p_value.
  ///
  /// In en, this message translates to:
  /// **'p-value'**
  String get p_value;

  /// No description provided for @level_of_significance.
  ///
  /// In en, this message translates to:
  /// **'Level of significance'**
  String get level_of_significance;

  /// No description provided for @t_test_outcome_based_on.
  ///
  /// In en, this message translates to:
  /// **'The outcome is based on the following values:'**
  String get t_test_outcome_based_on;

  /// No description provided for @statistical_information.
  ///
  /// In en, this message translates to:
  /// **'Statistical Information'**
  String get statistical_information;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @significance_level_and_p_value.
  ///
  /// In en, this message translates to:
  /// **'Significance level and p-value'**
  String get significance_level_and_p_value;

  /// Label for comparing results between two interventions or samples
  ///
  /// In en, this message translates to:
  /// **'Compare results between {nameA} and {nameB}'**
  String compare_results_between(String nameA, String nameB);

  /// No description provided for @missing_observations_note.
  ///
  /// In en, this message translates to:
  /// **'Note: Missing observations indicate days when data was not recorded.'**
  String get missing_observations_note;

  /// No description provided for @quick_summary.
  ///
  /// In en, this message translates to:
  /// **'Quick Summary'**
  String get quick_summary;

  /// No description provided for @average_score.
  ///
  /// In en, this message translates to:
  /// **'Average score'**
  String get average_score;

  /// No description provided for @data_completeness.
  ///
  /// In en, this message translates to:
  /// **'Data completeness'**
  String get data_completeness;

  /// No description provided for @statistic.
  ///
  /// In en, this message translates to:
  /// **'Statistic'**
  String get statistic;

  /// No description provided for @total_recordings.
  ///
  /// In en, this message translates to:
  /// **'Total recordings'**
  String get total_recordings;

  /// No description provided for @missing_recordings.
  ///
  /// In en, this message translates to:
  /// **'Missing recordings'**
  String get missing_recordings;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// No description provided for @support_email_sent.
  ///
  /// In en, this message translates to:
  /// **'Email opened'**
  String get support_email_sent;

  /// No description provided for @support_email_sent_description.
  ///
  /// In en, this message translates to:
  /// **'Your message to the study team was prepared in your email app. Review and send the email, then wait for their reply.\n\nIf you are currently participating in a study, continue tracking your results outside the app until the issue is resolved.'**
  String get support_email_sent_description;

  /// No description provided for @sync_fitbit_data.
  ///
  /// In en, this message translates to:
  /// **'Sync Fitbit Data'**
  String get sync_fitbit_data;

  /// No description provided for @fitbit_data_synced.
  ///
  /// In en, this message translates to:
  /// **'Fitbit data synced successfully'**
  String get fitbit_data_synced;

  /// No description provided for @fitbit_data_not_synced.
  ///
  /// In en, this message translates to:
  /// **'Fitbit data could not be synced. Please be sure that you have synced your Fitbit data with the Fitbit app.'**
  String get fitbit_data_not_synced;

  /// No description provided for @error_syncing_fitbit_data.
  ///
  /// In en, this message translates to:
  /// **'Error syncing Fitbit data: {error}'**
  String error_syncing_fitbit_data(String error);

  /// No description provided for @fitbit_data_synced_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Fitbit Data Synced'**
  String get fitbit_data_synced_dialog_title;

  /// No description provided for @fitbit_data_synced_info.
  ///
  /// In en, this message translates to:
  /// **'Data was synced for the following data types:'**
  String get fitbit_data_synced_info;

  /// No description provided for @fitbit_data_earliest_date.
  ///
  /// In en, this message translates to:
  /// **'Earliest date: {date}'**
  String fitbit_data_earliest_date(String date);

  /// No description provided for @fitbit_data_latest_date.
  ///
  /// In en, this message translates to:
  /// **'Latest date: {date}'**
  String fitbit_data_latest_date(String date);

  /// No description provided for @fitbit_data_details_btn.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get fitbit_data_details_btn;

  /// No description provided for @fitbit_data_close_btn.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get fitbit_data_close_btn;

  /// No description provided for @painIndicatorText.
  ///
  /// In en, this message translates to:
  /// **'Pain Level'**
  String get painIndicatorText;

  /// No description provided for @dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Pain Level'**
  String get dialogTitle;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @painLevel_0.
  ///
  /// In en, this message translates to:
  /// **'No pain'**
  String get painLevel_0;

  /// No description provided for @painLevel_2.
  ///
  /// In en, this message translates to:
  /// **'Hurts a little bit'**
  String get painLevel_2;

  /// No description provided for @painLevel_4.
  ///
  /// In en, this message translates to:
  /// **'Hurts a little more'**
  String get painLevel_4;

  /// No description provided for @painLevel_6.
  ///
  /// In en, this message translates to:
  /// **'Hurts even more'**
  String get painLevel_6;

  /// No description provided for @painLevel_8.
  ///
  /// In en, this message translates to:
  /// **'Hurts a whole lot'**
  String get painLevel_8;

  /// No description provided for @painLevel_10.
  ///
  /// In en, this message translates to:
  /// **'Worst pain possible'**
  String get painLevel_10;

  /// No description provided for @body_head.
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get body_head;

  /// No description provided for @body_head_front.
  ///
  /// In en, this message translates to:
  /// **'Head (Front)'**
  String get body_head_front;

  /// No description provided for @body_face.
  ///
  /// In en, this message translates to:
  /// **'Face'**
  String get body_face;

  /// No description provided for @body_forehead.
  ///
  /// In en, this message translates to:
  /// **'Forehead'**
  String get body_forehead;

  /// No description provided for @body_eyes.
  ///
  /// In en, this message translates to:
  /// **'Eyes'**
  String get body_eyes;

  /// No description provided for @body_nose.
  ///
  /// In en, this message translates to:
  /// **'Nose'**
  String get body_nose;

  /// No description provided for @body_mouth.
  ///
  /// In en, this message translates to:
  /// **'Mouth'**
  String get body_mouth;

  /// No description provided for @body_head_back.
  ///
  /// In en, this message translates to:
  /// **'Head (Back)'**
  String get body_head_back;

  /// No description provided for @body_inner_ear_balance.
  ///
  /// In en, this message translates to:
  /// **'Inner Ear / Balance'**
  String get body_inner_ear_balance;

  /// No description provided for @body_neck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get body_neck;

  /// No description provided for @body_neck_front.
  ///
  /// In en, this message translates to:
  /// **'Neck (Front)'**
  String get body_neck_front;

  /// No description provided for @body_neck_back.
  ///
  /// In en, this message translates to:
  /// **'Neck (Back)'**
  String get body_neck_back;

  /// No description provided for @body_torso.
  ///
  /// In en, this message translates to:
  /// **'Torso'**
  String get body_torso;

  /// No description provided for @body_chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get body_chest;

  /// No description provided for @body_left_chest.
  ///
  /// In en, this message translates to:
  /// **'Left Chest'**
  String get body_left_chest;

  /// No description provided for @body_right_chest.
  ///
  /// In en, this message translates to:
  /// **'Right Chest'**
  String get body_right_chest;

  /// No description provided for @body_breastbone.
  ///
  /// In en, this message translates to:
  /// **'Breastbone'**
  String get body_breastbone;

  /// No description provided for @body_upper_back.
  ///
  /// In en, this message translates to:
  /// **'Upper Back'**
  String get body_upper_back;

  /// No description provided for @body_left_shoulder_blade.
  ///
  /// In en, this message translates to:
  /// **'Left Shoulder Blade'**
  String get body_left_shoulder_blade;

  /// No description provided for @body_right_shoulder_blade.
  ///
  /// In en, this message translates to:
  /// **'Right Shoulder Blade'**
  String get body_right_shoulder_blade;

  /// No description provided for @body_spine_upper_middle.
  ///
  /// In en, this message translates to:
  /// **'Spine (Upper/Middle)'**
  String get body_spine_upper_middle;

  /// No description provided for @body_abdomen.
  ///
  /// In en, this message translates to:
  /// **'Abdomen'**
  String get body_abdomen;

  /// No description provided for @body_upper_abdomen.
  ///
  /// In en, this message translates to:
  /// **'Upper Abdomen'**
  String get body_upper_abdomen;

  /// No description provided for @body_lower_abdomen.
  ///
  /// In en, this message translates to:
  /// **'Lower Abdomen'**
  String get body_lower_abdomen;

  /// No description provided for @body_left_side_abdomen.
  ///
  /// In en, this message translates to:
  /// **'Left Side (Abdomen)'**
  String get body_left_side_abdomen;

  /// No description provided for @body_right_side_abdomen.
  ///
  /// In en, this message translates to:
  /// **'Right Side (Abdomen)'**
  String get body_right_side_abdomen;

  /// No description provided for @body_lower_back.
  ///
  /// In en, this message translates to:
  /// **'Lower Back'**
  String get body_lower_back;

  /// No description provided for @body_spine_lower.
  ///
  /// In en, this message translates to:
  /// **'Spine (Lower)'**
  String get body_spine_lower;

  /// No description provided for @body_left_flank.
  ///
  /// In en, this message translates to:
  /// **'Left Flank (Side)'**
  String get body_left_flank;

  /// No description provided for @body_right_flank.
  ///
  /// In en, this message translates to:
  /// **'Right Flank (Side)'**
  String get body_right_flank;

  /// No description provided for @body_arms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get body_arms;

  /// No description provided for @body_left_arm.
  ///
  /// In en, this message translates to:
  /// **'Left Arm'**
  String get body_left_arm;

  /// No description provided for @body_left_shoulder.
  ///
  /// In en, this message translates to:
  /// **'Left Shoulder'**
  String get body_left_shoulder;

  /// No description provided for @body_left_upper_arm.
  ///
  /// In en, this message translates to:
  /// **'Left Upper Arm'**
  String get body_left_upper_arm;

  /// No description provided for @body_left_bicep.
  ///
  /// In en, this message translates to:
  /// **'Left Bicep'**
  String get body_left_bicep;

  /// No description provided for @body_left_tricep.
  ///
  /// In en, this message translates to:
  /// **'Left Tricep'**
  String get body_left_tricep;

  /// No description provided for @body_left_elbow.
  ///
  /// In en, this message translates to:
  /// **'Left Elbow'**
  String get body_left_elbow;

  /// No description provided for @body_left_lower_arm.
  ///
  /// In en, this message translates to:
  /// **'Left Lower Arm'**
  String get body_left_lower_arm;

  /// No description provided for @body_left_forearm.
  ///
  /// In en, this message translates to:
  /// **'Left Forearm'**
  String get body_left_forearm;

  /// No description provided for @body_left_wrist.
  ///
  /// In en, this message translates to:
  /// **'Left Wrist'**
  String get body_left_wrist;

  /// No description provided for @body_left_hand.
  ///
  /// In en, this message translates to:
  /// **'Left Hand'**
  String get body_left_hand;

  /// No description provided for @body_left_palm.
  ///
  /// In en, this message translates to:
  /// **'Left Palm'**
  String get body_left_palm;

  /// No description provided for @body_left_fingers.
  ///
  /// In en, this message translates to:
  /// **'Left Fingers'**
  String get body_left_fingers;

  /// No description provided for @body_right_arm.
  ///
  /// In en, this message translates to:
  /// **'Right Arm'**
  String get body_right_arm;

  /// No description provided for @body_right_shoulder.
  ///
  /// In en, this message translates to:
  /// **'Right Shoulder'**
  String get body_right_shoulder;

  /// No description provided for @body_right_upper_arm.
  ///
  /// In en, this message translates to:
  /// **'Right Upper Arm'**
  String get body_right_upper_arm;

  /// No description provided for @body_right_bicep.
  ///
  /// In en, this message translates to:
  /// **'Right Bicep'**
  String get body_right_bicep;

  /// No description provided for @body_right_tricep.
  ///
  /// In en, this message translates to:
  /// **'Right Tricep'**
  String get body_right_tricep;

  /// No description provided for @body_right_elbow.
  ///
  /// In en, this message translates to:
  /// **'Right Elbow'**
  String get body_right_elbow;

  /// No description provided for @body_right_lower_arm.
  ///
  /// In en, this message translates to:
  /// **'Right Lower Arm'**
  String get body_right_lower_arm;

  /// No description provided for @body_right_forearm.
  ///
  /// In en, this message translates to:
  /// **'Right Forearm'**
  String get body_right_forearm;

  /// No description provided for @body_right_wrist.
  ///
  /// In en, this message translates to:
  /// **'Right Wrist'**
  String get body_right_wrist;

  /// No description provided for @body_right_hand.
  ///
  /// In en, this message translates to:
  /// **'Right Hand'**
  String get body_right_hand;

  /// No description provided for @body_right_palm.
  ///
  /// In en, this message translates to:
  /// **'Right Palm'**
  String get body_right_palm;

  /// No description provided for @body_right_fingers.
  ///
  /// In en, this message translates to:
  /// **'Right Fingers'**
  String get body_right_fingers;

  /// No description provided for @body_lower_body.
  ///
  /// In en, this message translates to:
  /// **'Lower Body'**
  String get body_lower_body;

  /// No description provided for @body_pelvis.
  ///
  /// In en, this message translates to:
  /// **'Pelvis'**
  String get body_pelvis;

  /// No description provided for @body_groin.
  ///
  /// In en, this message translates to:
  /// **'Groin'**
  String get body_groin;

  /// No description provided for @body_hips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get body_hips;

  /// No description provided for @body_buttocks.
  ///
  /// In en, this message translates to:
  /// **'Buttocks'**
  String get body_buttocks;

  /// No description provided for @body_legs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get body_legs;

  /// No description provided for @body_left_leg.
  ///
  /// In en, this message translates to:
  /// **'Left Leg'**
  String get body_left_leg;

  /// No description provided for @body_left_upper_leg.
  ///
  /// In en, this message translates to:
  /// **'Left Upper Leg'**
  String get body_left_upper_leg;

  /// No description provided for @body_left_thigh_front.
  ///
  /// In en, this message translates to:
  /// **'Thigh (Front)'**
  String get body_left_thigh_front;

  /// No description provided for @body_left_thigh_back.
  ///
  /// In en, this message translates to:
  /// **'Thigh (Back)'**
  String get body_left_thigh_back;

  /// No description provided for @body_left_knee.
  ///
  /// In en, this message translates to:
  /// **'Left Knee'**
  String get body_left_knee;

  /// No description provided for @body_left_lower_leg.
  ///
  /// In en, this message translates to:
  /// **'Left Lower Leg'**
  String get body_left_lower_leg;

  /// No description provided for @body_left_shin.
  ///
  /// In en, this message translates to:
  /// **'Shin'**
  String get body_left_shin;

  /// No description provided for @body_left_calf.
  ///
  /// In en, this message translates to:
  /// **'Calf'**
  String get body_left_calf;

  /// No description provided for @body_left_ankle.
  ///
  /// In en, this message translates to:
  /// **'Left Ankle'**
  String get body_left_ankle;

  /// No description provided for @body_left_foot.
  ///
  /// In en, this message translates to:
  /// **'Left Foot'**
  String get body_left_foot;

  /// No description provided for @body_left_heel.
  ///
  /// In en, this message translates to:
  /// **'Heel'**
  String get body_left_heel;

  /// No description provided for @body_left_foot_sole.
  ///
  /// In en, this message translates to:
  /// **'Foot Sole / Arch'**
  String get body_left_foot_sole;

  /// No description provided for @body_left_toes.
  ///
  /// In en, this message translates to:
  /// **'Toes'**
  String get body_left_toes;

  /// No description provided for @body_right_leg.
  ///
  /// In en, this message translates to:
  /// **'Right Leg'**
  String get body_right_leg;

  /// No description provided for @body_right_upper_leg.
  ///
  /// In en, this message translates to:
  /// **'Right Upper Leg'**
  String get body_right_upper_leg;

  /// No description provided for @body_right_thigh_front.
  ///
  /// In en, this message translates to:
  /// **'Thigh (Front)'**
  String get body_right_thigh_front;

  /// No description provided for @body_right_thigh_back.
  ///
  /// In en, this message translates to:
  /// **'Thigh (Back)'**
  String get body_right_thigh_back;

  /// No description provided for @body_right_knee.
  ///
  /// In en, this message translates to:
  /// **'Right Knee'**
  String get body_right_knee;

  /// No description provided for @body_right_lower_leg.
  ///
  /// In en, this message translates to:
  /// **'Right Lower Leg'**
  String get body_right_lower_leg;

  /// No description provided for @body_right_shin.
  ///
  /// In en, this message translates to:
  /// **'Shin'**
  String get body_right_shin;

  /// No description provided for @body_right_calf.
  ///
  /// In en, this message translates to:
  /// **'Calf'**
  String get body_right_calf;

  /// No description provided for @body_right_ankle.
  ///
  /// In en, this message translates to:
  /// **'Right Ankle'**
  String get body_right_ankle;

  /// No description provided for @body_right_foot.
  ///
  /// In en, this message translates to:
  /// **'Right Foot'**
  String get body_right_foot;

  /// No description provided for @body_right_heel.
  ///
  /// In en, this message translates to:
  /// **'Heel'**
  String get body_right_heel;

  /// No description provided for @body_right_foot_sole.
  ///
  /// In en, this message translates to:
  /// **'Foot Sole / Arch'**
  String get body_right_foot_sole;

  /// No description provided for @body_right_toes.
  ///
  /// In en, this message translates to:
  /// **'Toes'**
  String get body_right_toes;

  /// No description provided for @painTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pain Type'**
  String get painTypeLabel;

  /// No description provided for @bodyPartLabel.
  ///
  /// In en, this message translates to:
  /// **'Body Part'**
  String get bodyPartLabel;

  /// No description provided for @painTypeUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Unspecified'**
  String get painTypeUnspecified;

  /// No description provided for @painTypeBurning.
  ///
  /// In en, this message translates to:
  /// **'Burning'**
  String get painTypeBurning;

  /// No description provided for @painTypeStabbing.
  ///
  /// In en, this message translates to:
  /// **'Stabbing'**
  String get painTypeStabbing;

  /// No description provided for @painTypeAching.
  ///
  /// In en, this message translates to:
  /// **'Aching'**
  String get painTypeAching;

  /// No description provided for @painTypeThrobbing.
  ///
  /// In en, this message translates to:
  /// **'Throbbing'**
  String get painTypeThrobbing;

  /// No description provided for @painTypeSharp.
  ///
  /// In en, this message translates to:
  /// **'Sharp'**
  String get painTypeSharp;

  /// No description provided for @painTypeDull.
  ///
  /// In en, this message translates to:
  /// **'Dull'**
  String get painTypeDull;

  /// No description provided for @painTypeCramping.
  ///
  /// In en, this message translates to:
  /// **'Cramping'**
  String get painTypeCramping;

  /// No description provided for @painTypeRadiating.
  ///
  /// In en, this message translates to:
  /// **'Radiating'**
  String get painTypeRadiating;

  /// No description provided for @painTypeTingling.
  ///
  /// In en, this message translates to:
  /// **'Tingling'**
  String get painTypeTingling;

  /// No description provided for @painTypeShooting.
  ///
  /// In en, this message translates to:
  /// **'Shooting'**
  String get painTypeShooting;

  /// No description provided for @painTypePulsing.
  ///
  /// In en, this message translates to:
  /// **'Pulsing'**
  String get painTypePulsing;

  /// No description provided for @painTypePressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get painTypePressure;

  /// No description provided for @painTypeTightness.
  ///
  /// In en, this message translates to:
  /// **'Tightness'**
  String get painTypeTightness;

  /// No description provided for @painTypeSoreness.
  ///
  /// In en, this message translates to:
  /// **'Soreness'**
  String get painTypeSoreness;

  /// No description provided for @painTypeStiffness.
  ///
  /// In en, this message translates to:
  /// **'Stiffness'**
  String get painTypeStiffness;

  /// No description provided for @preview_mode.
  ///
  /// In en, this message translates to:
  /// **'Preview Mode'**
  String get preview_mode;

  /// No description provided for @preview_mode_active.
  ///
  /// In en, this message translates to:
  /// **'Preview Mode Active'**
  String get preview_mode_active;

  /// No description provided for @preview_mode_active_state.
  ///
  /// In en, this message translates to:
  /// **'Preview mode is now active.'**
  String get preview_mode_active_state;

  /// No description provided for @preview_mode_inactive_state.
  ///
  /// In en, this message translates to:
  /// **'Preview mode is now inactive.'**
  String get preview_mode_inactive_state;

  /// No description provided for @preview_mode_description.
  ///
  /// In en, this message translates to:
  /// **'You are currently in preview mode. This allows you to:\n\n• Fast-forward through study days using the \"Next Day\" button\n• Complete tasks multiple times without restrictions\n• Experience the full study flow without affecting real data\n\nImportant: Results and data from preview mode are not stored or mixed with actual participant results from running studies.'**
  String get preview_mode_description;

  /// No description provided for @preview_mode_results_not_saved.
  ///
  /// In en, this message translates to:
  /// **'Task completed in preview mode - results are not saved to protect study data integrity.'**
  String get preview_mode_results_not_saved;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @study_settings_section.
  ///
  /// In en, this message translates to:
  /// **'Study settings'**
  String get study_settings_section;

  /// No description provided for @recovery_phrase_header.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase'**
  String get recovery_phrase_header;

  /// No description provided for @copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard. Paste the recovery phrase somewhere secure on your phone now.'**
  String get copied_to_clipboard;

  /// No description provided for @show_recovery_phrase.
  ///
  /// In en, this message translates to:
  /// **'Show Recovery Phrase'**
  String get show_recovery_phrase;

  /// No description provided for @recovery_phrase_saved_confirmation.
  ///
  /// In en, this message translates to:
  /// **'I have saved all 13 words in a safe place and can retrieve them when I want to restore my account. I can also view them again in Study Settings.'**
  String get recovery_phrase_saved_confirmation;

  /// No description provided for @recovery_phrase_rotate_button.
  ///
  /// In en, this message translates to:
  /// **'Reissue recovery phrase'**
  String get recovery_phrase_rotate_button;

  /// No description provided for @recovery_phrase_rotate_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Reissue recovery phrase?'**
  String get recovery_phrase_rotate_dialog_title;

  /// No description provided for @recovery_phrase_rotate_dialog_description.
  ///
  /// In en, this message translates to:
  /// **'Your current recovery phrase will immediately stop working. You must save the new phrase to recover your account in the future.'**
  String get recovery_phrase_rotate_dialog_description;

  /// No description provided for @recovery_phrase_rotate_acknowledgement.
  ///
  /// In en, this message translates to:
  /// **'I understand that my current recovery phrase will immediately stop working.'**
  String get recovery_phrase_rotate_acknowledgement;

  /// No description provided for @recovery_phrase_rotate_confirm.
  ///
  /// In en, this message translates to:
  /// **'Reissue phrase'**
  String get recovery_phrase_rotate_confirm;

  /// No description provided for @recovery_phrase_rotate_success.
  ///
  /// In en, this message translates to:
  /// **'A new recovery phrase has been issued. Save it now.'**
  String get recovery_phrase_rotate_success;

  /// No description provided for @recovery_phrase_rotate_error.
  ///
  /// In en, this message translates to:
  /// **'Could not issue a new recovery phrase. Please try again.'**
  String get recovery_phrase_rotate_error;

  /// No description provided for @continue_to_study.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get continue_to_study;

  /// No description provided for @restore_account.
  ///
  /// In en, this message translates to:
  /// **'Restore account'**
  String get restore_account;

  /// No description provided for @enter_recovery_phrase.
  ///
  /// In en, this message translates to:
  /// **'Enter your recovery phrase'**
  String get enter_recovery_phrase;

  /// No description provided for @restore_account_signed_in_title.
  ///
  /// In en, this message translates to:
  /// **'Already signed in'**
  String get restore_account_signed_in_title;

  /// No description provided for @restore_account_signed_in_description.
  ///
  /// In en, this message translates to:
  /// **'You are already signed in on this device. Restoring an account will replace the current account. Your recovery phrase remains valid after recovery.'**
  String get restore_account_signed_in_description;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalid_recovery_phrase.
  ///
  /// In en, this message translates to:
  /// **'This recovery phrase does not match an account. Make sure all 13 words are in the right order.'**
  String get invalid_recovery_phrase;

  /// No description provided for @recovery_phrase_too_many_words.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrases have 13 words. Remove extra words to continue.'**
  String get recovery_phrase_too_many_words;

  /// No description provided for @deep_link_study_not_found.
  ///
  /// In en, this message translates to:
  /// **'Study with ID {studyId} not found or not available'**
  String deep_link_study_not_found(String studyId);

  /// No description provided for @recovery_in_progress.
  ///
  /// In en, this message translates to:
  /// **'Recovering your account...'**
  String get recovery_in_progress;

  /// No description provided for @recovery_failed.
  ///
  /// In en, this message translates to:
  /// **'Recovery failed. Please check your recovery phrase and try again.'**
  String get recovery_failed;

  /// No description provided for @recovery_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'No account found with this recovery phrase.'**
  String get recovery_user_not_found;

  /// No description provided for @recovery_network_error.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get recovery_network_error;

  /// No description provided for @restore_account_description.
  ///
  /// In en, this message translates to:
  /// **'Restore your account on this device with the recovery phrase you saved before joining a study.'**
  String get restore_account_description;

  /// No description provided for @file_saved.
  ///
  /// In en, this message translates to:
  /// **'File saved successfully'**
  String get file_saved;

  /// No description provided for @file_save_error.
  ///
  /// In en, this message translates to:
  /// **'Error saving file'**
  String get file_save_error;

  /// No description provided for @copy_btn.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy_btn;

  /// No description provided for @download_btn.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download_btn;

  /// No description provided for @general_section.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general_section;

  /// No description provided for @participation_options_section.
  ///
  /// In en, this message translates to:
  /// **'Manage participation'**
  String get participation_options_section;

  /// No description provided for @recovery_phrase_load_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recovery phrase'**
  String get recovery_phrase_load_error;

  /// No description provided for @deep_link_study_invite_only.
  ///
  /// In en, this message translates to:
  /// **'This study requires an invite code to join'**
  String get deep_link_study_invite_only;

  /// No description provided for @deep_link_invite_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired invite code: {code}'**
  String deep_link_invite_invalid(String code);

  /// No description provided for @deep_link_switch_warning_title.
  ///
  /// In en, this message translates to:
  /// **'You are already in a study'**
  String get deep_link_switch_warning_title;

  /// No description provided for @deep_link_switch_warning_description.
  ///
  /// In en, this message translates to:
  /// **'You are currently enrolled in:\n{currentStudy}\n\nThe deep link points to:\n{targetStudy}\n\nYou can return to your current study (recommended) or continue to leave it and switch.'**
  String deep_link_switch_warning_description(
    String currentStudy,
    String targetStudy,
  );

  /// No description provided for @deep_link_switch_warning_opt_out_instruction.
  ///
  /// In en, this message translates to:
  /// **'If you want to leave your current study, open Settings and use \"{optOut}\" first. Then open the invite again.'**
  String deep_link_switch_warning_opt_out_instruction(String optOut);

  /// No description provided for @deep_link_switch_open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get deep_link_switch_open_settings;

  /// No description provided for @deep_link_switch_continue_study.
  ///
  /// In en, this message translates to:
  /// **'Continue Study'**
  String get deep_link_switch_continue_study;

  /// No description provided for @you_have_been_invited.
  ///
  /// In en, this message translates to:
  /// **'You have been invited to a study!'**
  String get you_have_been_invited;

  /// No description provided for @download_app_join.
  ///
  /// In en, this message translates to:
  /// **'Download the StudyU App & Join'**
  String get download_app_join;

  /// No description provided for @deleted_study_error_title.
  ///
  /// In en, this message translates to:
  /// **'Study unavailable'**
  String get deleted_study_error_title;

  /// No description provided for @deleted_study_error_description.
  ///
  /// In en, this message translates to:
  /// **'This study is no longer available from the server. Your data remains on this device for now. Please contact your study supervisor or support before deleting anything. Only use \'Delete all data\' if they tell you to reset the app.'**
  String get deleted_study_error_description;

  /// No description provided for @dashboard_showcase_progress_title.
  ///
  /// In en, this message translates to:
  /// **'Study progress'**
  String get dashboard_showcase_progress_title;

  /// No description provided for @dashboard_showcase_progress_description.
  ///
  /// In en, this message translates to:
  /// **'This shows where you are in the study and how much is left.'**
  String get dashboard_showcase_progress_description;

  /// No description provided for @dashboard_showcase_current_intervention_title.
  ///
  /// In en, this message translates to:
  /// **'Current intervention'**
  String get dashboard_showcase_current_intervention_title;

  /// No description provided for @dashboard_showcase_current_intervention_description.
  ///
  /// In en, this message translates to:
  /// **'Here you can see your current intervention and how many days remain in this phase.'**
  String get dashboard_showcase_current_intervention_description;

  /// No description provided for @dashboard_showcase_today_tasks_title.
  ///
  /// In en, this message translates to:
  /// **'Today\'s tasks'**
  String get dashboard_showcase_today_tasks_title;

  /// No description provided for @dashboard_showcase_today_tasks_description.
  ///
  /// In en, this message translates to:
  /// **'Here you can find the tasks you need to complete today as part of the study.'**
  String get dashboard_showcase_today_tasks_description;

  /// No description provided for @dashboard_showcase_contact_title.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get dashboard_showcase_contact_title;

  /// No description provided for @dashboard_showcase_contact_description.
  ///
  /// In en, this message translates to:
  /// **'Use this if you need help from the study team.'**
  String get dashboard_showcase_contact_description;

  /// No description provided for @dashboard_showcase_report_title.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get dashboard_showcase_report_title;

  /// No description provided for @dashboard_showcase_report_description.
  ///
  /// In en, this message translates to:
  /// **'Open your current report when results are available.'**
  String get dashboard_showcase_report_description;

  /// No description provided for @dashboard_showcase_menu_title.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get dashboard_showcase_menu_title;

  /// No description provided for @dashboard_showcase_menu_description.
  ///
  /// In en, this message translates to:
  /// **'Find settings, FAQs, report history, and more here.'**
  String get dashboard_showcase_menu_description;

  /// No description provided for @dashboard_showcase_finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get dashboard_showcase_finish;

  /// No description provided for @support_email_subject_loading_error.
  ///
  /// In en, this message translates to:
  /// **'StudyU Support Request - Loading Error'**
  String get support_email_subject_loading_error;

  /// No description provided for @support_email_subject_deleted_study.
  ///
  /// In en, this message translates to:
  /// **'StudyU Support Request - Study Unavailable'**
  String get support_email_subject_deleted_study;

  /// Body of the support email for deleted study errors, includes the Subject ID
  ///
  /// In en, this message translates to:
  /// **'Hello,\n\nThe StudyU app says that my study is no longer available from the server. My subject ID is: {subjectId}\n\nPlease let me know whether I should keep my local data or reset the app.\n\nThank you.'**
  String deleted_study_support_email_body(String subjectId);

  /// No description provided for @dashboard_tour.
  ///
  /// In en, this message translates to:
  /// **'Dashboard tour'**
  String get dashboard_tour;

  /// No description provided for @show_again.
  ///
  /// In en, this message translates to:
  /// **'View tour again'**
  String get show_again;

  /// No description provided for @free_text_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your answer'**
  String get free_text_hint;

  /// No description provided for @preview_failed_to_initialize.
  ///
  /// In en, this message translates to:
  /// **'Preview failed to initialize.'**
  String get preview_failed_to_initialize;

  /// No description provided for @preview_overlay_reset_hint.
  ///
  /// In en, this message translates to:
  /// **'The preview could not be opened right now. Please try resetting the preview.'**
  String get preview_overlay_reset_hint;

  /// No description provided for @preview_overlay_study_not_ready.
  ///
  /// In en, this message translates to:
  /// **'The preview could not be opened for this study yet. Please try resetting the preview.'**
  String get preview_overlay_study_not_ready;

  /// No description provided for @preview_overlay_route_open_failed.
  ///
  /// In en, this message translates to:
  /// **'The preview route could not be opened right now.'**
  String get preview_overlay_route_open_failed;

  /// No description provided for @continue_label.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_label;

  /// No description provided for @restored_answer_needs_review.
  ///
  /// In en, this message translates to:
  /// **'Restored answer requires review'**
  String get restored_answer_needs_review;

  /// No description provided for @restored_answer_review_description.
  ///
  /// In en, this message translates to:
  /// **'Complete task becomes available after review.'**
  String get restored_answer_review_description;

  /// No description provided for @mark_answer_reviewed.
  ///
  /// In en, this message translates to:
  /// **'I\'ve reviewed this answer'**
  String get mark_answer_reviewed;

  /// No description provided for @answer_reviewed.
  ///
  /// In en, this message translates to:
  /// **'Answer reviewed'**
  String get answer_reviewed;

  /// No description provided for @review_restored_answer_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Review the restored answer to continue.'**
  String get review_restored_answer_to_continue;

  /// No description provided for @complete_task.
  ///
  /// In en, this message translates to:
  /// **'Complete task'**
  String get complete_task;

  /// No description provided for @no_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again when online.'**
  String get no_internet_connection;

  /// No description provided for @error_occurred_with_message.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {message}'**
  String error_occurred_with_message(String message);

  /// No description provided for @date_picker_button_label.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get date_picker_button_label;

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

  /// No description provided for @date_picker_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get date_picker_clear;

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

  /// No description provided for @please_select_interventions_why.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get please_select_interventions_why;

  /// No description provided for @recovery_phrase_description.
  ///
  /// In en, this message translates to:
  /// **'Save these 13 words in a safe place. They are the only way to restore your account if you lose access to this device.'**
  String get recovery_phrase_description;

  /// No description provided for @recovery_phrase_why.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get recovery_phrase_why;

  /// No description provided for @recovery_phrase_reason.
  ///
  /// In en, this message translates to:
  /// **'StudyU does not use passwords or email accounts. These 13 words are the only way to restore your account if you get a new phone or reinstall the app. Write them down or store them digitally somewhere only you can access. Never share them with anyone. You can view your recovery phrase again at any time under Settings → Study settings.'**
  String get recovery_phrase_reason;

  /// No description provided for @study_not_started_title.
  ///
  /// In en, this message translates to:
  /// **'You’ve joined the study'**
  String get study_not_started_title;

  /// No description provided for @study_not_started_description.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow to begin. We’ll remind you when there’s something to do.'**
  String get study_not_started_description;

  /// No description provided for @recovery_phrase_word_count.
  ///
  /// In en, this message translates to:
  /// **'{count}/{total} words'**
  String recovery_phrase_word_count(Object count, Object total);

  /// No description provided for @ko.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get ko;

  /// No description provided for @faq_section_data_storage_privacy.
  ///
  /// In en, this message translates to:
  /// **'Data Storage and Privacy'**
  String get faq_section_data_storage_privacy;

  /// No description provided for @faq_question_data_storage.
  ///
  /// In en, this message translates to:
  /// **'Where and how is my data stored?'**
  String get faq_question_data_storage;

  /// No description provided for @faq_answer_data_storage.
  ///
  /// In en, this message translates to:
  /// **'The data collected from you is stored locally on your device and is uploaded to a secure server when it is connected to the internet. All study data is collected and stored anonymously.'**
  String get faq_answer_data_storage;

  /// No description provided for @faq_question_personal_data.
  ///
  /// In en, this message translates to:
  /// **'Which personal data does the app collect?'**
  String get faq_question_personal_data;

  /// No description provided for @faq_answer_personal_data.
  ///
  /// In en, this message translates to:
  /// **'The app does not collect any personal data of the user.'**
  String get faq_answer_personal_data;

  /// No description provided for @faq_section_studies.
  ///
  /// In en, this message translates to:
  /// **'Studies'**
  String get faq_section_studies;

  /// No description provided for @faq_question_study_duration.
  ///
  /// In en, this message translates to:
  /// **'How long will the study take to finish?'**
  String get faq_question_study_duration;

  /// No description provided for @faq_answer_study_duration.
  ///
  /// In en, this message translates to:
  /// **'The duration of each study is mentioned during initial study selection.'**
  String get faq_answer_study_duration;

  /// No description provided for @faq_question_change_intervention.
  ///
  /// In en, this message translates to:
  /// **'Can I select a different intervention?'**
  String get faq_question_change_intervention;

  /// No description provided for @faq_answer_change_intervention.
  ///
  /// In en, this message translates to:
  /// **'Before starting the study, go back to the intervention selection screen to choose different interventions. After the study has started, you cannot change the selected interventions for that participation. To choose different interventions, leave the study from Settings, choose whether to keep or permanently delete your existing data, and then select a study and its interventions again during enrollment.'**
  String get faq_answer_change_intervention;

  /// No description provided for @faq_question_missed_tasks.
  ///
  /// In en, this message translates to:
  /// **'Can I redo my missed tasks on a later date?'**
  String get faq_question_missed_tasks;

  /// No description provided for @faq_answer_missed_tasks.
  ///
  /// In en, this message translates to:
  /// **'No, you cannot redo a missed task on a later date. However, you can finish it at anytime on the same day.'**
  String get faq_answer_missed_tasks;

  /// No description provided for @faq_question_leave_study.
  ///
  /// In en, this message translates to:
  /// **'How can I leave the current study?'**
  String get faq_question_leave_study;

  /// No description provided for @faq_answer_leave_study.
  ///
  /// In en, this message translates to:
  /// **'Go to the Settings tab on the Dashboard and click \"Leave study\". This will exit the study without deleting your progress data, allowing it to be included in the study analysis. To leave the study and delete all progress data both locally and on the server, click \"Leave study and delete all data\". All data will be permanently removed from the server and your device.'**
  String get faq_answer_leave_study;

  /// No description provided for @faq_section_report_details.
  ///
  /// In en, this message translates to:
  /// **'Report Details'**
  String get faq_section_report_details;

  /// No description provided for @faq_question_daily_tasks.
  ///
  /// In en, this message translates to:
  /// **'What are daily tasks and how do I complete them?'**
  String get faq_question_daily_tasks;

  /// No description provided for @faq_answer_daily_tasks.
  ///
  /// In en, this message translates to:
  /// **'To find out which intervention works best for you, you need to perform some daily tasks for each intervention. Please make sure to hit the \"Complete\" button after finishing it'**
  String get faq_answer_daily_tasks;

  /// No description provided for @faq_question_rate_your_day.
  ///
  /// In en, this message translates to:
  /// **'What is \"Rate your day\"?'**
  String get faq_question_rate_your_day;

  /// No description provided for @faq_answer_rate_your_day.
  ///
  /// In en, this message translates to:
  /// **'\"Rate your day\" is a feature that tracks your health during entire study period. It requires you to rate certain health-related queries on a scale of 1 to 10.'**
  String get faq_answer_rate_your_day;

  /// No description provided for @faq_question_track_activities.
  ///
  /// In en, this message translates to:
  /// **'How can I keep track of my activities?'**
  String get faq_question_track_activities;

  /// No description provided for @faq_answer_track_activities.
  ///
  /// In en, this message translates to:
  /// **'You can get an overview of your daily tasks and health status in the \"Reports History section\"'**
  String get faq_answer_track_activities;

  /// No description provided for @faq_question_download_report.
  ///
  /// In en, this message translates to:
  /// **'How can I download my Study report?'**
  String get faq_question_download_report;

  /// No description provided for @faq_answer_download_report.
  ///
  /// In en, this message translates to:
  /// **'Your report will be ready to download once you have completed the minimum required tasks for a study. It will be available in the Report History tab located on the Dashboard.'**
  String get faq_answer_download_report;

  /// No description provided for @debug_notifications_not_initialized.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not initialized yet. Please start a study and open this through the about section.'**
  String get debug_notifications_not_initialized;

  /// No description provided for @debug_test_notification_title.
  ///
  /// In en, this message translates to:
  /// **'StudyU Test Notification'**
  String get debug_test_notification_title;

  /// No description provided for @debug_test_notification_body.
  ///
  /// In en, this message translates to:
  /// **'This notification confirms that you receive StudyU notifications'**
  String get debug_test_notification_body;

  /// No description provided for @debug_reset_success.
  ///
  /// In en, this message translates to:
  /// **'App reset successfully! Please restart the app.'**
  String get debug_reset_success;

  /// No description provided for @debug_reset_error.
  ///
  /// In en, this message translates to:
  /// **'Error while resetting the app. Please try again.'**
  String get debug_reset_error;

  /// No description provided for @debug_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Debug Screen'**
  String get debug_screen_title;

  /// No description provided for @debug_send_information_via_email.
  ///
  /// In en, this message translates to:
  /// **'Send debug information via email'**
  String get debug_send_information_via_email;

  /// No description provided for @debug_receive_test_notification.
  ///
  /// In en, this message translates to:
  /// **'Receive test notification'**
  String get debug_receive_test_notification;

  /// No description provided for @debug_show_onboarding.
  ///
  /// In en, this message translates to:
  /// **'Show onboarding'**
  String get debug_show_onboarding;

  /// No description provided for @invite_landing_instruction_title.
  ///
  /// In en, this message translates to:
  /// **'Join the study with StudyU Health'**
  String get invite_landing_instruction_title;

  /// No description provided for @invite_landing_qr_label.
  ///
  /// In en, this message translates to:
  /// **'Study invitation QR code'**
  String get invite_landing_qr_label;

  /// No description provided for @invite_landing_invite_code.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get invite_landing_invite_code;

  /// No description provided for @invite_landing_invalid.
  ///
  /// In en, this message translates to:
  /// **'This invitation is no longer available. Please check the link or code and try again.'**
  String get invite_landing_invalid;

  /// No description provided for @invite_landing_load_error.
  ///
  /// In en, this message translates to:
  /// **'We could not load this invitation. Please try again later.'**
  String get invite_landing_load_error;

  /// No description provided for @invite_landing_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading invitation…'**
  String get invite_landing_loading;

  /// No description provided for @scan_invite_code.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scan_invite_code;

  /// No description provided for @scan_invite_code_description.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the invitation QR code.'**
  String get scan_invite_code_description;

  /// No description provided for @open_study_app.
  ///
  /// In en, this message translates to:
  /// **'Open in StudyU Health'**
  String get open_study_app;

  /// No description provided for @invite_landing_google_play.
  ///
  /// In en, this message translates to:
  /// **'Get it on Google Play'**
  String get invite_landing_google_play;

  /// No description provided for @invite_landing_app_store.
  ///
  /// In en, this message translates to:
  /// **'Download on the App Store'**
  String get invite_landing_app_store;

  /// No description provided for @invite_landing_step_download.
  ///
  /// In en, this message translates to:
  /// **'Get the StudyU Health app'**
  String get invite_landing_step_download;

  /// No description provided for @invite_landing_step_join.
  ///
  /// In en, this message translates to:
  /// **'Join the study in the app'**
  String get invite_landing_step_join;

  /// No description provided for @invite_landing_step_join_description.
  ///
  /// In en, this message translates to:
  /// **'Open StudyU Health on your phone and tap Join with an invite code. Enter the invite code or scan the QR code to join the study.'**
  String get invite_landing_step_join_description;

  /// No description provided for @invite_landing_invited_title.
  ///
  /// In en, this message translates to:
  /// **'You’re invited to join'**
  String get invite_landing_invited_title;

  /// No description provided for @invite_landing_phone_instruction.
  ///
  /// In en, this message translates to:
  /// **'Enter this invite code in the StudyU Health app.'**
  String get invite_landing_phone_instruction;

  /// No description provided for @invite_landing_other_device_instruction.
  ///
  /// In en, this message translates to:
  /// **'For quick access, scan this QR code with your phone.'**
  String get invite_landing_other_device_instruction;

  /// No description provided for @invite_landing_enter_code_title.
  ///
  /// In en, this message translates to:
  /// **'Enter invite code'**
  String get invite_landing_enter_code_title;

  /// No description provided for @invite_landing_scan_qr_title.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get invite_landing_scan_qr_title;

  /// No description provided for @invite_landing_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get invite_landing_copied;

  /// No description provided for @invite_landing_copy_code.
  ///
  /// In en, this message translates to:
  /// **'Copy invite code'**
  String get invite_landing_copy_code;

  /// No description provided for @date_format.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get date_format;

  /// No description provided for @date_format_european.
  ///
  /// In en, this message translates to:
  /// **'European (31/12/2024)'**
  String get date_format_european;

  /// No description provided for @date_format_german.
  ///
  /// In en, this message translates to:
  /// **'German (31.12.2024)'**
  String get date_format_german;

  /// No description provided for @date_format_iso.
  ///
  /// In en, this message translates to:
  /// **'ISO (2024-12-31)'**
  String get date_format_iso;

  /// No description provided for @date_format_us.
  ///
  /// In en, this message translates to:
  /// **'US (12/31/2024)'**
  String get date_format_us;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @time_format.
  ///
  /// In en, this message translates to:
  /// **'Time format'**
  String get time_format;

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

  /// No description provided for @daily_food_diary.
  ///
  /// In en, this message translates to:
  /// **'Daily Food Diary'**
  String get daily_food_diary;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @saved_ago.
  ///
  /// In en, this message translates to:
  /// **'Saved {time} ago'**
  String saved_ago(String time);

  /// No description provided for @just_now.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get just_now;

  /// No description provided for @seconds_ago.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds ago'**
  String seconds_ago(int seconds);

  /// No description provided for @minutes_ago.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minute(s) ago'**
  String minutes_ago(int minutes);

  /// No description provided for @hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{hours} hour(s) ago'**
  String hours_ago(int hours);

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @nutrition_instructions_default.
  ///
  /// In en, this message translates to:
  /// **'Please record all the foods and beverages you consumed today. For each meal or snack, provide as much detail as possible including portion sizes and preparation methods.'**
  String get nutrition_instructions_default;

  /// No description provided for @min_meals_required.
  ///
  /// In en, this message translates to:
  /// **'Please record at least {count} meal(s)'**
  String min_meals_required(int count);

  /// No description provided for @recall_details.
  ///
  /// In en, this message translates to:
  /// **'Recall Details'**
  String get recall_details;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @recall_mode.
  ///
  /// In en, this message translates to:
  /// **'Recall Mode'**
  String get recall_mode;

  /// No description provided for @recall_mode_realtime.
  ///
  /// In en, this message translates to:
  /// **'Real-time Recording'**
  String get recall_mode_realtime;

  /// No description provided for @recall_mode_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday Recall'**
  String get recall_mode_yesterday;

  /// No description provided for @usual_intake_day.
  ///
  /// In en, this message translates to:
  /// **'Usual Intake Day'**
  String get usual_intake_day;

  /// No description provided for @usual_intake_question.
  ///
  /// In en, this message translates to:
  /// **'Was this a typical day for your diet?'**
  String get usual_intake_question;

  /// No description provided for @special_occasion.
  ///
  /// In en, this message translates to:
  /// **'Special Occasion'**
  String get special_occasion;

  /// No description provided for @special_occasion_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Birthday, Holiday, etc.'**
  String get special_occasion_hint;

  /// No description provided for @meals_count.
  ///
  /// In en, this message translates to:
  /// **'Meals ({count})'**
  String meals_count(int count);

  /// No description provided for @add_meal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get add_meal;

  /// No description provided for @no_meals_recorded.
  ///
  /// In en, this message translates to:
  /// **'No meals recorded yet'**
  String get no_meals_recorded;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @meal_type_breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get meal_type_breakfast;

  /// No description provided for @meal_type_lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get meal_type_lunch;

  /// No description provided for @meal_type_dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get meal_type_dinner;

  /// No description provided for @meal_type_snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get meal_type_snack;

  /// No description provided for @meal_type_brunch.
  ///
  /// In en, this message translates to:
  /// **'Brunch'**
  String get meal_type_brunch;

  /// No description provided for @meal_type_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get meal_type_other;

  /// No description provided for @food_items_count.
  ///
  /// In en, this message translates to:
  /// **'{count} food items'**
  String food_items_count(int count);

  /// No description provided for @meal_entry_title.
  ///
  /// In en, this message translates to:
  /// **'Meal Entry'**
  String get meal_entry_title;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @meal_information.
  ///
  /// In en, this message translates to:
  /// **'Meal Information'**
  String get meal_information;

  /// No description provided for @meal_type_label.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get meal_type_label;

  /// No description provided for @custom_meal_label.
  ///
  /// In en, this message translates to:
  /// **'Custom Meal Label'**
  String get custom_meal_label;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @where_did_you_eat.
  ///
  /// In en, this message translates to:
  /// **'Where did you eat?'**
  String get where_did_you_eat;

  /// No description provided for @location_description.
  ///
  /// In en, this message translates to:
  /// **'Location Description'**
  String get location_description;

  /// No description provided for @location_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Describe where you ate'**
  String get location_description_hint;

  /// No description provided for @who_were_you_with.
  ///
  /// In en, this message translates to:
  /// **'Who were you with?'**
  String get who_were_you_with;

  /// No description provided for @distractions_during_meal.
  ///
  /// In en, this message translates to:
  /// **'Distractions during meal?'**
  String get distractions_during_meal;

  /// No description provided for @skipped_this_meal.
  ///
  /// In en, this message translates to:
  /// **'Skipped this meal'**
  String get skipped_this_meal;

  /// No description provided for @reason_for_skipping.
  ///
  /// In en, this message translates to:
  /// **'Reason for skipping'**
  String get reason_for_skipping;

  /// No description provided for @food_items_section.
  ///
  /// In en, this message translates to:
  /// **'Food Items ({count})'**
  String food_items_section(int count);

  /// No description provided for @add_food.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get add_food;

  /// No description provided for @no_food_items_yet.
  ///
  /// In en, this message translates to:
  /// **'No food items yet'**
  String get no_food_items_yet;

  /// No description provided for @not_specified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get not_specified;

  /// No description provided for @context_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get context_home;

  /// No description provided for @context_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get context_restaurant;

  /// No description provided for @context_takeout.
  ///
  /// In en, this message translates to:
  /// **'Takeout'**
  String get context_takeout;

  /// No description provided for @context_vending.
  ///
  /// In en, this message translates to:
  /// **'Vending'**
  String get context_vending;

  /// No description provided for @context_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get context_other;

  /// No description provided for @company_alone.
  ///
  /// In en, this message translates to:
  /// **'👤 Alone'**
  String get company_alone;

  /// No description provided for @company_family.
  ///
  /// In en, this message translates to:
  /// **'👨‍👩‍👧‍👦 Family'**
  String get company_family;

  /// No description provided for @company_friends.
  ///
  /// In en, this message translates to:
  /// **'👥 Friends'**
  String get company_friends;

  /// No description provided for @company_colleagues.
  ///
  /// In en, this message translates to:
  /// **'💼 Colleagues'**
  String get company_colleagues;

  /// No description provided for @company_other.
  ///
  /// In en, this message translates to:
  /// **'🤝 Other'**
  String get company_other;

  /// No description provided for @distraction_none.
  ///
  /// In en, this message translates to:
  /// **'🧘 None'**
  String get distraction_none;

  /// No description provided for @distraction_tv.
  ///
  /// In en, this message translates to:
  /// **'📺 TV'**
  String get distraction_tv;

  /// No description provided for @distraction_phone.
  ///
  /// In en, this message translates to:
  /// **'📱 Phone'**
  String get distraction_phone;

  /// No description provided for @distraction_work.
  ///
  /// In en, this message translates to:
  /// **'💻 Work'**
  String get distraction_work;

  /// No description provided for @distraction_other.
  ///
  /// In en, this message translates to:
  /// **'📖 Other'**
  String get distraction_other;

  /// No description provided for @food_entry_title.
  ///
  /// In en, this message translates to:
  /// **'Food Entry'**
  String get food_entry_title;

  /// No description provided for @food_information.
  ///
  /// In en, this message translates to:
  /// **'Food Information'**
  String get food_information;

  /// No description provided for @entry_type.
  ///
  /// In en, this message translates to:
  /// **'Entry Type'**
  String get entry_type;

  /// No description provided for @food_name.
  ///
  /// In en, this message translates to:
  /// **'Food Name *'**
  String get food_name;

  /// No description provided for @brand_name.
  ///
  /// In en, this message translates to:
  /// **'Brand Name'**
  String get brand_name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @description_hint.
  ///
  /// In en, this message translates to:
  /// **'Optional notes about this food'**
  String get description_hint;

  /// No description provided for @recipe_info.
  ///
  /// In en, this message translates to:
  /// **'Recipe: Use Recipe Builder for better ingredient management'**
  String get recipe_info;

  /// No description provided for @open_recipe_builder.
  ///
  /// In en, this message translates to:
  /// **'Open Recipe Builder'**
  String get open_recipe_builder;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount *'**
  String get amount;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit *'**
  String get unit;

  /// No description provided for @serving_size.
  ///
  /// In en, this message translates to:
  /// **'Serving Size (grams) *'**
  String get serving_size;

  /// No description provided for @portion_reference.
  ///
  /// In en, this message translates to:
  /// **'Portion Reference'**
  String get portion_reference;

  /// No description provided for @portion_reference_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 1 cup, 3 oz, medium apple'**
  String get portion_reference_hint;

  /// No description provided for @portion_estimation_method.
  ///
  /// In en, this message translates to:
  /// **'Portion Estimation Method'**
  String get portion_estimation_method;

  /// No description provided for @portion_state.
  ///
  /// In en, this message translates to:
  /// **'Portion State'**
  String get portion_state;

  /// No description provided for @yield_factor.
  ///
  /// In en, this message translates to:
  /// **'Yield Factor'**
  String get yield_factor;

  /// No description provided for @yield_factor_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 0.75'**
  String get yield_factor_hint;

  /// No description provided for @edible_portion.
  ///
  /// In en, this message translates to:
  /// **'Edible Portion'**
  String get edible_portion;

  /// No description provided for @edible_portion_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 0.85'**
  String get edible_portion_hint;

  /// No description provided for @nutrition_information.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Information'**
  String get nutrition_information;

  /// No description provided for @energy_kcal.
  ///
  /// In en, this message translates to:
  /// **'Energy (kcal) *'**
  String get energy_kcal;

  /// No description provided for @protein_g.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get protein_g;

  /// No description provided for @carbs_g.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbs_g;

  /// No description provided for @fat_g.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fat_g;

  /// No description provided for @saturated_fat_g.
  ///
  /// In en, this message translates to:
  /// **'Sat. Fat (g)'**
  String get saturated_fat_g;

  /// No description provided for @sugars_g.
  ///
  /// In en, this message translates to:
  /// **'Sugars (g)'**
  String get sugars_g;

  /// No description provided for @fiber_g.
  ///
  /// In en, this message translates to:
  /// **'Fiber (g)'**
  String get fiber_g;

  /// No description provided for @sodium_mg.
  ///
  /// In en, this message translates to:
  /// **'Sodium (mg)'**
  String get sodium_mg;

  /// No description provided for @required_error.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required_error;

  /// No description provided for @enter_food_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter a food name'**
  String get enter_food_name;

  /// No description provided for @enter_serving_size.
  ///
  /// In en, this message translates to:
  /// **'Please enter serving size'**
  String get enter_serving_size;

  /// No description provided for @entry_type_single_ingredient.
  ///
  /// In en, this message translates to:
  /// **'🥕 Single Ingredient'**
  String get entry_type_single_ingredient;

  /// No description provided for @entry_type_recipe.
  ///
  /// In en, this message translates to:
  /// **'📖 Recipe'**
  String get entry_type_recipe;

  /// No description provided for @entry_type_branded_product.
  ///
  /// In en, this message translates to:
  /// **'🏷️ Branded Product'**
  String get entry_type_branded_product;

  /// No description provided for @entry_type_manual_entry.
  ///
  /// In en, this message translates to:
  /// **'✏️ Manual Entry'**
  String get entry_type_manual_entry;

  /// No description provided for @portion_method_household.
  ///
  /// In en, this message translates to:
  /// **'Household Measure'**
  String get portion_method_household;

  /// No description provided for @portion_method_photograph.
  ///
  /// In en, this message translates to:
  /// **'Photograph'**
  String get portion_method_photograph;

  /// No description provided for @portion_method_standard_unit.
  ///
  /// In en, this message translates to:
  /// **'Standard Unit'**
  String get portion_method_standard_unit;

  /// No description provided for @portion_method_user_weighted.
  ///
  /// In en, this message translates to:
  /// **'User Weighted'**
  String get portion_method_user_weighted;

  /// No description provided for @portion_method_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get portion_method_unknown;

  /// No description provided for @portion_state_raw.
  ///
  /// In en, this message translates to:
  /// **'Raw'**
  String get portion_state_raw;

  /// No description provided for @portion_state_cooked.
  ///
  /// In en, this message translates to:
  /// **'Cooked'**
  String get portion_state_cooked;

  /// No description provided for @portion_state_as_served.
  ///
  /// In en, this message translates to:
  /// **'As Served'**
  String get portion_state_as_served;

  /// No description provided for @my_templates.
  ///
  /// In en, this message translates to:
  /// **'My Templates'**
  String get my_templates;

  /// No description provided for @save_as_template.
  ///
  /// In en, this message translates to:
  /// **'Save as Template'**
  String get save_as_template;

  /// No description provided for @save_meal_template.
  ///
  /// In en, this message translates to:
  /// **'Save Meal Template'**
  String get save_meal_template;

  /// No description provided for @save_food_template.
  ///
  /// In en, this message translates to:
  /// **'Save Food Template'**
  String get save_food_template;

  /// No description provided for @save_recipe_template.
  ///
  /// In en, this message translates to:
  /// **'Save Recipe Template'**
  String get save_recipe_template;

  /// No description provided for @template_name.
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get template_name;

  /// No description provided for @template_tags_optional.
  ///
  /// In en, this message translates to:
  /// **'Tags (optional)'**
  String get template_tags_optional;

  /// No description provided for @template_tags_hint.
  ///
  /// In en, this message translates to:
  /// **'breakfast, quick, healthy'**
  String get template_tags_hint;

  /// No description provided for @template_saved.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get template_saved;

  /// No description provided for @select_meal_template.
  ///
  /// In en, this message translates to:
  /// **'Select Meal Template'**
  String get select_meal_template;

  /// No description provided for @select_food_template.
  ///
  /// In en, this message translates to:
  /// **'Select Food Template'**
  String get select_food_template;

  /// No description provided for @search_templates.
  ///
  /// In en, this message translates to:
  /// **'Search templates...'**
  String get search_templates;

  /// No description provided for @no_templates_saved.
  ///
  /// In en, this message translates to:
  /// **'No templates saved yet'**
  String get no_templates_saved;

  /// No description provided for @save_templates_hint.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite meals and foods as templates for quick access'**
  String get save_templates_hint;

  /// No description provided for @from_template.
  ///
  /// In en, this message translates to:
  /// **'From Template'**
  String get from_template;

  /// No description provided for @add_new_food.
  ///
  /// In en, this message translates to:
  /// **'Add New Food'**
  String get add_new_food;

  /// No description provided for @delete_template.
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get delete_template;

  /// No description provided for @delete_template_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this template?'**
  String get delete_template_confirmation;

  /// No description provided for @filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filter_all;

  /// No description provided for @filter_meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get filter_meals;

  /// No description provided for @filter_foods.
  ///
  /// In en, this message translates to:
  /// **'Foods'**
  String get filter_foods;

  /// No description provided for @filter_recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get filter_recipes;

  /// No description provided for @items_count.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String items_count(int count);

  /// No description provided for @kcal_value.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String kcal_value(String value);

  /// No description provided for @template_type_meal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get template_type_meal;

  /// No description provided for @template_type_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get template_type_food;

  /// No description provided for @template_type_recipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get template_type_recipe;

  /// No description provided for @rename_template.
  ///
  /// In en, this message translates to:
  /// **'Rename Template'**
  String get rename_template;

  /// No description provided for @new_name.
  ///
  /// In en, this message translates to:
  /// **'New Name'**
  String get new_name;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @food_items.
  ///
  /// In en, this message translates to:
  /// **'Food items'**
  String get food_items;

  /// No description provided for @tap_to_add_first_meal.
  ///
  /// In en, this message translates to:
  /// **'Tap the button above to add your first meal'**
  String get tap_to_add_first_meal;

  /// No description provided for @tap_to_add_food.
  ///
  /// In en, this message translates to:
  /// **'Tap to add food'**
  String get tap_to_add_food;

  /// No description provided for @add_food_title.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get add_food_title;

  /// No description provided for @edit_food_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Food'**
  String get edit_food_title;

  /// No description provided for @add_food_manually.
  ///
  /// In en, this message translates to:
  /// **'Add Food Manually'**
  String get add_food_manually;

  /// No description provided for @basic_information.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basic_information;

  /// No description provided for @macronutrients.
  ///
  /// In en, this message translates to:
  /// **'Macronutrients'**
  String get macronutrients;

  /// No description provided for @detailed_nutrients.
  ///
  /// In en, this message translates to:
  /// **'Detailed Nutrients'**
  String get detailed_nutrients;

  /// No description provided for @daily_nutrition_total.
  ///
  /// In en, this message translates to:
  /// **'Daily Nutrition Total'**
  String get daily_nutrition_total;

  /// No description provided for @meal_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Meal Nutrition'**
  String get meal_nutrition;

  /// No description provided for @nutrition_summary.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Summary'**
  String get nutrition_summary;

  /// No description provided for @calorie_distribution.
  ///
  /// In en, this message translates to:
  /// **'Calorie Distribution'**
  String get calorie_distribution;

  /// No description provided for @more_options.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get more_options;

  /// No description provided for @search_food_hint.
  ///
  /// In en, this message translates to:
  /// **'Search food (e.g., \"apple\", \"chicken\")'**
  String get search_food_hint;

  /// No description provided for @my_saved_items.
  ///
  /// In en, this message translates to:
  /// **'My Saved Items'**
  String get my_saved_items;

  /// No description provided for @global_database.
  ///
  /// In en, this message translates to:
  /// **'Global Database'**
  String get global_database;

  /// No description provided for @quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions;

  /// No description provided for @create_recipe.
  ///
  /// In en, this message translates to:
  /// **'Create Recipe'**
  String get create_recipe;

  /// No description provided for @create_recipe_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Build from multiple ingredients'**
  String get create_recipe_subtitle;

  /// No description provided for @add_manually.
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get add_manually;

  /// No description provided for @add_manually_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter nutrition facts yourself'**
  String get add_manually_subtitle;

  /// No description provided for @scan_barcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scan_barcode;

  /// No description provided for @scan_barcode_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Find packaged products quickly'**
  String get scan_barcode_subtitle;

  /// No description provided for @search_for_food.
  ///
  /// In en, this message translates to:
  /// **'Search for Food'**
  String get search_for_food;

  /// No description provided for @search_food_description.
  ///
  /// In en, this message translates to:
  /// **'Type above to search global databases'**
  String get search_food_description;

  /// No description provided for @searching_databases.
  ///
  /// In en, this message translates to:
  /// **'Searching databases...'**
  String get searching_databases;

  /// No description provided for @end_of_results.
  ///
  /// In en, this message translates to:
  /// **'End of results'**
  String get end_of_results;

  /// No description provided for @no_results_found.
  ///
  /// In en, this message translates to:
  /// **'No results found. Try different keywords.'**
  String get no_results_found;

  /// No description provided for @no_matching_templates.
  ///
  /// In en, this message translates to:
  /// **'No matching templates'**
  String get no_matching_templates;

  /// No description provided for @detailed_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Detailed Nutrition'**
  String get detailed_nutrition;

  /// No description provided for @detailed_nutrition_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Fiber, Sugar, Sodium'**
  String get detailed_nutrition_subtitle;

  /// No description provided for @advanced_options.
  ///
  /// In en, this message translates to:
  /// **'Advanced Options'**
  String get advanced_options;

  /// No description provided for @advanced_options_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Food type, serving size, portions'**
  String get advanced_options_subtitle;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @search_food_database.
  ///
  /// In en, this message translates to:
  /// **'Search Food Database'**
  String get search_food_database;

  /// No description provided for @no_data_yet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get no_data_yet;

  /// No description provided for @start_tracking_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your nutrition by adding meals'**
  String get start_tracking_nutrition;

  /// No description provided for @photoRecallTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Recall'**
  String get photoRecallTitle;

  /// No description provided for @photoRecallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View photos from around this time'**
  String get photoRecallSubtitle;

  /// No description provided for @photoRecallPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Tap to enable photo access'**
  String get photoRecallPermissionNeeded;

  /// No description provided for @photoRecallPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Photo Access'**
  String get photoRecallPermissionTitle;

  /// No description provided for @photoRecallPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Access to your photos helps you recall what you ate. Photos are only displayed on your device.'**
  String get photoRecallPermissionDescription;

  /// No description provided for @photoRecallNoPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos found'**
  String get photoRecallNoPhotos;

  /// No description provided for @photoRecallNoPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any photos taken around this time'**
  String get photoRecallNoPhotosSubtitle;

  /// No description provided for @photoRecallTapToEnlarge.
  ///
  /// In en, this message translates to:
  /// **'Tap a photo to view it full screen'**
  String get photoRecallTapToEnlarge;

  /// No description provided for @photoRecallTimeInfo.
  ///
  /// In en, this message translates to:
  /// **'Showing photos from around {time} (±2 hours)'**
  String photoRecallTimeInfo(String time);

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @analyzePhotoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Analyze this food photo'**
  String get analyzePhotoTooltip;

  /// No description provided for @analyzingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Analyzing photo...'**
  String get analyzingPhoto;

  /// No description provided for @foodAnalysisError.
  ///
  /// In en, this message translates to:
  /// **'Could not analyze image - try manual entry'**
  String get foodAnalysisError;

  /// No description provided for @foodAnalysisNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to analysis service'**
  String get foodAnalysisNetworkError;

  /// No description provided for @foodAnalysisNoItems.
  ///
  /// In en, this message translates to:
  /// **'No food items detected in image'**
  String get foodAnalysisNoItems;

  /// No description provided for @aiEstimatedBanner.
  ///
  /// In en, this message translates to:
  /// **'AI-estimated values - please review'**
  String get aiEstimatedBanner;

  /// No description provided for @selectFoodItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Food Items'**
  String get selectFoodItemsTitle;

  /// No description provided for @selectFoodItemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select which items to add to your meal'**
  String get selectFoodItemsSubtitle;

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'Add Selected'**
  String get addSelected;

  /// No description provided for @analyzeAgain.
  ///
  /// In en, this message translates to:
  /// **'Analyze Again'**
  String get analyzeAgain;

  /// No description provided for @select_all.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get select_all;

  /// No description provided for @deselect_all.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselect_all;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {percentage}%'**
  String confidenceLabel(int percentage);

  /// No description provided for @min_meals_not_met_title.
  ///
  /// In en, this message translates to:
  /// **'Minimum meals not reached'**
  String get min_meals_not_met_title;

  /// No description provided for @min_meals_not_met_message.
  ///
  /// In en, this message translates to:
  /// **'This task requires at least {count} meal(s). You have recorded fewer than required. Leave anyway?'**
  String min_meals_not_met_message(int count);

  /// No description provided for @leave_anyway.
  ///
  /// In en, this message translates to:
  /// **'Leave anyway'**
  String get leave_anyway;
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

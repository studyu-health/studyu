// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loading => 'Loading';

  @override
  String get starting_study => 'Starting your study…';

  @override
  String get loading_error_title => 'Loading Error';

  @override
  String get loading_error_description =>
      'The study data could not be retrieved. If you are currently participating in a study, please first contact your study supervisor for assistance. Only contact support if you are not in a study or your supervisor instructs you to do so. Do not delete your data unless told by your supervisor or support. Deleting data will remove all your study data and you will have to rejoin the study.';

  @override
  String get try_again => 'Try again';

  @override
  String get delete_all_data => 'Delete all data';

  @override
  String get delete_all_data_description =>
      'Do you really want to delete all data? This will delete all your study data and you will have to rejoin the study.';

  @override
  String get reset_app => 'Reset App';

  @override
  String get what_is_studyu => 'What is StudyU?';

  @override
  String get description_part1 =>
      'Imagine reading the sentence: \"Eating after 6 pm decreases sleep quality\"';

  @override
  String get description_part2 =>
      'Now you might think something like: Well... good to know but is that affecting everyone and also ME?';

  @override
  String get description_part3 =>
      'The problem is: you did not take part in the study yourself, so we simply cannot answer that question. A traditional study can only answer whether it is more LIKELY that your sleep quality is affected. You would therefore have to test the effect of eating late on YOUR sleep.';

  @override
  String get description_part4 =>
      'This means that you would have to do your own personal study, in which you would have phases of eating late and phases of abstaining from eating late. You would regularly assess your sleep quality and in the end come to a result that could finally answer the question of whether eating late decreases your sleep quality or not. Giving you a reliable answer to such questions is the goal of StudyU.';

  @override
  String get description_part5 =>
      'StudyU offers the possibility to enroll to N-of-1 studies designed by experts. N-of-1 means that the number of people in the trials, which is usually indicated as N, is 1. And just like traditional trials, N-of-1 trials need a clearly defined plan (a so-called study protocol).';

  @override
  String get description_part6 =>
      'And because good study protocols are not easy to make, we have developed this App. Here you can choose between different N-of-1 studies, according to YOUR personal interest, and you will automatically receive a plan developed by experts that will give you a reliable result.';

  @override
  String get description_part7 =>
      'Once you have chosen one of our studies we will make sure that your health status allows participation. Afterwards you can enroll as a participant and adapt the study plan to your everyday life. Tasks (e.g. eating late and rating your tiredness) have to be done on a regular basis (e.g. once per day). Once you have reached the minimum study duration (usually just a few weeks) you will be able to unlock results for free.';

  @override
  String get description_part8 =>
      'But bear in mind that results are more reliable the longer you take actively part in the study. And in order to prevent systematic error you cannot go on with the study after unlocking results. Therefore, with the help of a progress bar we will indicate you how many tasks are still needed for the minimum and how much you could improve your results with going on for some more weeks.';

  @override
  String get description_part9 =>
      'But enough from our side, now it\'s time for StudyU!';

  @override
  String get get_started => 'Get started';

  @override
  String get welcome_find_study_title => 'Find what works for you';

  @override
  String get made_with_love_in_potsdam => 'Made with ♥ in Potsdam';

  @override
  String get welcome_find_study_description =>
      'Choose a public study or use an invitation.';

  @override
  String get browse_public_studies => 'Browse public studies';

  @override
  String get welcome_returning_participant =>
      'Already participated with StudyU?';

  @override
  String get restore_studyu_account => 'Restore StudyU account';

  @override
  String get show_onboarding_again => 'Show onboarding again';

  @override
  String get onboarding_page0_title => 'Welcome to StudyU';

  @override
  String get onboarding_page0_subtitle =>
      'Researchers can estimate what works on average. They cannot determine whether a habit or treatment works for you. StudyU helps you test that question yourself.';

  @override
  String get onboarding_page1_title => 'Your personal study';

  @override
  String get onboarding_page1_subtitle =>
      'In an N-of-1 study, you are the only participant. You follow different phases, such as eating early and eating late, and record outcomes such as sleep quality.';

  @override
  String get onboarding_page2_title => 'An expert study plan';

  @override
  String get onboarding_page2_subtitle =>
      'Choose a study that matches your question. StudyU provides an expert-designed protocol, checks whether you can participate safely, and helps fit the plan into your routine.';

  @override
  String get onboarding_page3_title => 'Complete regular tasks';

  @override
  String get onboarding_page3_subtitle =>
      'Follow the assigned option and record your observations, usually once a day. The progress bar shows how many tasks remain before you can view your results.';

  @override
  String get onboarding_page4_title => 'Build reliable evidence';

  @override
  String get onboarding_page4_subtitle =>
      'After a few weeks, you can compare how each option worked for you. Each completed task strengthens the result. When you unlock your results, StudyU ends the study to protect the analysis.';

  @override
  String get study_selection => 'Study Selection';

  @override
  String get study_selection_single =>
      'You can only participate in one study at a time.';

  @override
  String get study_selection_single_why => 'Why?';

  @override
  String get study_selection_single_reason =>
      'If you were to participate in multiple studies at a time, the interventions of these studies might interfere with one another and alter the results.';

  @override
  String get study_selection_unsupported_title => 'Outdated app version';

  @override
  String get study_selection_unsupported =>
      'The study you are trying to join is not compatible with your app version. Please update the app to the latest version.';

  @override
  String get study_selection_closed_title => 'Study closed';

  @override
  String get study_selection_closed =>
      'This study is currently closed for new participants.';

  @override
  String get study_selection_hidden_studies =>
      'Some studies couldn\'t be shown, because your app version is outdated. Please update your app to see all available studies.';

  @override
  String get study_selection_no_public_studies =>
      'There are currently no public studies available. If you have an invite code, you can still join a private study.';

  @override
  String get study_overview_title => 'Study overview';

  @override
  String get eligibility_questionnaire_title => 'Eligibility check';

  @override
  String get please_answer_eligibility =>
      'Please answer a few questions to make sure that you can safely participate in this study.';

  @override
  String get intervention_selection_title => 'Intervention selection';

  @override
  String get please_select_interventions =>
      'Please select two interventions to apply during the study.';

  @override
  String get please_select_interventions_description =>
      'The effects of these two interventions will be measured and compared during the study.';

  @override
  String get no_interventions_available => 'No interventions available.';

  @override
  String get loading_interventions => 'Loading interventions';

  @override
  String get task_already_completed =>
      'You have already completed this task today';

  @override
  String get task_cannot_be_completed => 'The task cannot be completed';

  @override
  String get task_outside_period =>
      'The task cannot be completed outside of the intervention period';

  @override
  String get study_notification_body => 'A new task awaits your attention';

  @override
  String get intervention_phase_duration => 'Intervention phase duration';

  @override
  String get days => 'days';

  @override
  String get study_length => 'Study length';

  @override
  String get study_publisher => 'Study Publisher';

  @override
  String get tasks_daily => 'Tasks:';

  @override
  String get baseline_description =>
      'The baseline is a phase within a study in which the initial state is measured to allow later comparisons. During the baseline phase you should behave as usual, no study-specific interventions are carried out yet.';

  @override
  String get baseline => 'Baseline';

  @override
  String get days_left => 'days left';

  @override
  String get today_tasks => 'Today\'s tasks';

  @override
  String get intervention_current => 'Current intervention';

  @override
  String get study_current => 'Current study:';

  @override
  String get opt_out => 'Leave study';

  @override
  String get leave_study_keep_data_title => 'Leave study and keep your data?';

  @override
  String leave_study_keep_data_body(String studyName) {
    return 'You will stop participating in the study “$studyName”. We will keep the progress and responses you have already submitted, and researchers may continue to use your anonymized data.\n\nYou cannot rejoin this participation after leaving. Your previous studies will not be affected.';
  }

  @override
  String get stay_in_study => 'Stay in study';

  @override
  String get acknowledge_consequences =>
      'I have read this information and understand the consequences.';

  @override
  String get leave_keep_data => 'Leave and keep my data';

  @override
  String get leave_study_description =>
      'Stop participating. Your existing study data will be retained.';

  @override
  String get delete_data => 'Leave study and delete my data';

  @override
  String get leave_study_delete_data_title => 'Leave study and delete my data?';

  @override
  String leave_study_delete_data_body(String studyName) {
    return 'You will stop participating in the study “$studyName”. We will permanently delete your progress and responses for this study from our servers and remove its saved data from this device.\n\nThis cannot be undone. Neither you nor anyone from the study team will be able to recover this data.';
  }

  @override
  String get leave_delete_data => 'Leave and delete my data';

  @override
  String get delete_study_data_description =>
      'Permanently delete your study data. This cannot be undone.';

  @override
  String get soft_delete_desc => 'You will lose your progress in ';

  @override
  String get soft_delete_desc_2 =>
      ' and won\'t be able to recover it. Previously completed studies will not be deleted.\nYour anonymized data up to this point may still be used for research purposes.';

  @override
  String get hard_delete_desc =>
      'You are about to delete all data from your device and our servers. You will not be able to restore your data.\nYour anonymized data will not be available for research purposes anymore.';

  @override
  String get your_journey => 'Your journey';

  @override
  String get journey_overview_description =>
      'Review your study timeline before continuing.';

  @override
  String get journey_results_available => 'Results available';

  @override
  String get summary => 'Summary';

  @override
  String get consent => 'Consent';

  @override
  String get error => 'An error occurred!';

  @override
  String get tea_vs_coffee => 'Tea vs. Coffee';

  @override
  String get weed_vs_alcohol => 'Weed vs. Alcohol';

  @override
  String get back_pain => 'Back pain';

  @override
  String get video_task => 'Video task';

  @override
  String get finished => 'Finished';

  @override
  String get how_would_you_rate_your_pain_today =>
      'How would you rate your pain today? (0 = no pain, 10 = extreme pain)';

  @override
  String get thank_you_for_your_input => 'Thank you for your input';

  @override
  String get please_give_consent =>
      'Please give your consent to participate in this study. You are required to read all boxes by clicking on them.';

  @override
  String get please_give_consent_why => 'Why?';

  @override
  String get please_give_consent_reason =>
      'Studies need to request specific consent from participants, for reasons of safety and data privacy. Hence, you must explicitly consent to participate in each study.';

  @override
  String get user_did_not_give_consent =>
      'You did not give your consent. To participate you need to give consent.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get study_not_available_for_testing_yet =>
      'This study is not available for testing yet.';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get help => 'Help';

  @override
  String get contact => 'Contact';

  @override
  String get contact_support => 'Contact study team';

  @override
  String support_email_body(String subjectId) {
    return 'Hello,\n\nI am experiencing a loading error in the StudyU app. My subject ID is: $subjectId\n\nPlease assist me with this issue.\n\nThank you.';
  }

  @override
  String get about => 'About';

  @override
  String get study_information => 'Study information';

  @override
  String get study_information_description =>
      'Only share these details with your study team when they ask for them.';

  @override
  String get study_name => 'Study name';

  @override
  String get study_id => 'Study ID';

  @override
  String get subject_id => 'Subject ID';

  @override
  String get study_start_date => 'Study start date';

  @override
  String get app_version => 'App version';

  @override
  String get platform => 'Platform';

  @override
  String get not_available => 'Not available';

  @override
  String get view_study_information => 'View details';

  @override
  String get email_study_team => 'Contact study team';

  @override
  String get study_team_email_unavailable => 'This study has no contact email.';

  @override
  String get copy_all_information => 'Copy all';

  @override
  String value_copied(String label) {
    return '$label copied to clipboard.';
  }

  @override
  String get all_information_copied => 'All information copied to clipboard.';

  @override
  String get participant_information_email_subject =>
      '[StudyU] Participant information';

  @override
  String get participant_information_email_intro =>
      'Hello,\n\nI am contacting you about my participation in the study. These are my StudyU details:';

  @override
  String get email_app_unavailable => 'No email app is available.';

  @override
  String get settings => 'Settings';

  @override
  String get yes => 'yes';

  @override
  String get no => 'no';

  @override
  String get confirm => 'Confirm selection';

  @override
  String get survey => 'Survey';

  @override
  String get complete => 'Complete';

  @override
  String get cancel => 'Cancel';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get completed => 'Completed';

  @override
  String get faq_full => 'Frequently Asked Questions';

  @override
  String get faq => 'FAQ';

  @override
  String get start_study => 'Start Study';

  @override
  String get next_day => 'Next day';

  @override
  String get could_not_save_results => 'Could not save results';

  @override
  String get take_a_photo => 'Take a photo';

  @override
  String get start_recording => 'Start recording';

  @override
  String get stop_recording => 'Stop recording';

  @override
  String get error_recording => 'Error occurred during recording';

  @override
  String get photo_captured => 'Photo captured';

  @override
  String get audio_recorded => 'Audio recorded';

  @override
  String get multimodal_not_supported =>
      'Multimodal Trials are currently not supported to run in a web browser. Please use the StudyU App for Android or iOS.';

  @override
  String get camera_access_denied => 'Camera access denied';

  @override
  String get no_camera_available => 'No camera available';

  @override
  String get microphone_access_denied => 'Microphone access denied';

  @override
  String get camera_error => 'Camera error';

  @override
  String get recording_error => 'Recording error';

  @override
  String get storing_photo => 'The photo is being stored';

  @override
  String get storing_audio => 'The audio file is being stored';

  @override
  String get upload_error => 'The file could not be uploaded';

  @override
  String get language => 'Language';

  @override
  String get use_device_language => 'Use device language';

  @override
  String get en => 'English';

  @override
  String get de => 'German';

  @override
  String get allow_analytics => 'Allow app analytics';

  @override
  String get allow_analytics_desc =>
      'All collected data is used only to improve app performance and never for tracking purposes. You can read more about this in our data privacy.';

  @override
  String get video_test => 'This is a video test';

  @override
  String get survey_test => 'This is a survey test';

  @override
  String get current_report => 'Current report';

  @override
  String get report_history => 'Report history';

  @override
  String get no_reports_found => 'No reports defined yet';

  @override
  String get current_power_level => 'Current status';

  @override
  String get not_enough_data => 'Not enough data';

  @override
  String get barely_enough_data => 'Barely enough data';

  @override
  String get enough_data => 'Enough data';

  @override
  String get legal_documents => 'Legal documents';

  @override
  String get legal_documents_description =>
      'Please review and accept these documents to continue.';

  @override
  String get terms => 'Terms of Use';

  @override
  String get terms_read => 'Read Terms of Use';

  @override
  String get terms_content =>
      'The terms of use give an overview on the purpose and use of the StudyU app.';

  @override
  String get terms_agree => 'I have read and agree to the terms of use';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get privacy_read => 'Read Privacy Policy';

  @override
  String get privacy_content =>
      'The privacy policy describes which data is stored, why, when, where, access rights, and which rights you have.';

  @override
  String get privacy_agree => 'I have read and agree to the privacy policy';

  @override
  String get legal_notice => 'Legal Notice';

  @override
  String get legal_notice_content =>
      'The legal notice shows who is responsible for StudyU and how you can contact us.';

  @override
  String get imprint_read => 'Read Legal Notice';

  @override
  String get invite_code_button => 'Join with an invite code';

  @override
  String get private_study_invite_code => 'Enter invite code';

  @override
  String get private_study_invite_code_description =>
      'Enter the code shared by your study team.';

  @override
  String get invite_code => 'Invite code';

  @override
  String get invalid_invite_code => 'Not a valid invite code';

  @override
  String get save_pdf => 'Save as PDF';

  @override
  String get was_saved_to => 'The file was saved to ';

  @override
  String get save_not_supported => 'Error';

  @override
  String get save_not_supported_description =>
      'Downloading files is currently not supported in the web version.';

  @override
  String get eligible_no => 'You are not eligible for this study';

  @override
  String get eligible_yes => 'You are eligible for this study';

  @override
  String get eligible_mistake =>
      'If you made a mistake, you can still change your answers';

  @override
  String get eligible_back => 'Back to study selection';

  @override
  String get eligible_choice_multi_selection =>
      'Select all that apply (optional)';

  @override
  String get eligible_choice_multi_selection_required =>
      'Select all that apply (at least one required)';

  @override
  String get report_overview => 'Report overview';

  @override
  String get report_primary_result => 'Primary Result';

  @override
  String get report_disclaimer =>
      'This report is only valid if you entered all information correctly.';

  @override
  String get performance => 'Performance';

  @override
  String get performance_overview => 'Overview of completion of tasks';

  @override
  String get performance_overview_interventions => 'Interventions';

  @override
  String get performance_overview_observations => 'Observations';

  @override
  String get report_outcome_inconclusive =>
      'The results are inconclusive. There does not seem to be a statistically significant difference between the interventions.';

  @override
  String get report_outcome_neither =>
      'Both interventions seem to have a negative effect on the outcome for you.';

  @override
  String report_outcome_one(Object intervention) {
    return 'The intervention $intervention seems to improve the outcome for you.';
  }

  @override
  String get report_axis_phase => 'Phase';

  @override
  String get completed_study =>
      'You completed your last study. Look at past reports or start a new study.';

  @override
  String get app_support => 'App support';

  @override
  String get app_support_text =>
      'Contact for problems or questions with the app';

  @override
  String get study_support => 'Study support';

  @override
  String get study_support_text =>
      'Contact for problems or questions with the study';

  @override
  String get organization => 'Organization';

  @override
  String get irb => 'Institutional Review Board';

  @override
  String get researchers => 'Researchers';

  @override
  String get website => 'Website';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get additionalInfo => 'Additional information';

  @override
  String free_text_min_length_error(num min) {
    return 'Please enter at least $min characters';
  }

  @override
  String free_text_max_length_error(num max) {
    return 'Please enter at most $max characters';
  }

  @override
  String get free_text_alphanumeric_error =>
      'Please enter only alphanumeric characters';

  @override
  String get free_text_numeric_error => 'Please enter only numeric characters';

  @override
  String get free_text_custom_error =>
      'Please enter a value in the required format';

  @override
  String get app_outdated_message =>
      'A new version of the StudyU App is available. Please update to get the latest features and improvements. Thank you for your support!';

  @override
  String get update_now => 'Update now';

  @override
  String get text_summary_section_prefix_higher => 'Your ';

  @override
  String get text_summary_section_was_higher =>
      ' was higher during intervention: ';

  @override
  String get text_summary_section_was_lower =>
      ' was lower during intervention: ';

  @override
  String get text_summary_section_compared_to => ' compared to: ';

  @override
  String get text_summary_section_and => ' and ';

  @override
  String get text_summary_section_no_evidence =>
      'There was no evidence for a difference in ';

  @override
  String get text_summary_section_between => ' between interventions: ';

  @override
  String get intervention => 'Intervention';

  @override
  String get phase => 'Phase';

  @override
  String get day => 'Day';

  @override
  String get no_data_available_yet => 'No data available yet';

  @override
  String get value => 'Value';

  @override
  String get show_colorless_gauges => 'Enable accessible charts';

  @override
  String get welchs_t_test_results => 'Welch\'s t-test Results';

  @override
  String get sample_a => 'Sample A';

  @override
  String get sample_b => 'Sample B';

  @override
  String get sample_size => 'n';

  @override
  String get mean => 'mean';

  @override
  String get variance => 'var';

  @override
  String get t_statistic => 't-statistic';

  @override
  String get degrees_of_freedom => 'Degrees of freedom';

  @override
  String get p_value => 'p-value';

  @override
  String get result_significant => 'Significantly different';

  @override
  String get result_not_significant => 'Not significantly different';

  @override
  String get level_of_significance => 'Level of significance';

  @override
  String get t_test_outcome_based_on =>
      'The outcome is based on the following values:';

  @override
  String get statistical_information => 'Statistical Information';

  @override
  String get close => 'Close';

  @override
  String get significance_level_and_p_value => 'Significance level and p-value';

  @override
  String get descriptive_statistics => 'Descriptive statistics';

  @override
  String compare_results_between(String nameA, String nameB) {
    return 'Compare results between $nameA and $nameB';
  }

  @override
  String get missing_observations_note =>
      'Note: Missing observations indicate days when data was not recorded.';

  @override
  String get quick_summary => 'Quick Summary';

  @override
  String get average_score => 'Average score';

  @override
  String get data_completeness => 'Data completeness';

  @override
  String get statistic => 'Statistic';

  @override
  String get total_recordings => 'Total recordings';

  @override
  String get missing_recordings => 'Missing recordings';

  @override
  String get average => 'Average';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get support_email_sent => 'Email opened';

  @override
  String get support_email_sent_description =>
      'Your message to the study team was prepared in your email app. Review and send the email, then wait for their reply.\n\nIf you are currently participating in a study, continue tracking your results outside the app until the issue is resolved.';

  @override
  String get no_contact_email =>
      'The support email address is not configured. Please contact your study supervisor for assistance.';

  @override
  String get sync_fitbit_data => 'Sync Fitbit Data';

  @override
  String get fitbit_data_synced => 'Fitbit data synced successfully';

  @override
  String get fitbit_data_not_synced =>
      'Fitbit data could not be synced. Please be sure that you have synced your Fitbit data with the Fitbit app.';

  @override
  String error_syncing_fitbit_data(String error) {
    return 'Error syncing Fitbit data: $error';
  }

  @override
  String get fitbit_data_synced_dialog_title => 'Fitbit Data Synced';

  @override
  String get fitbit_data_synced_info =>
      'Data was synced for the following data types:';

  @override
  String fitbit_data_earliest_date(String date) {
    return 'Earliest date: $date';
  }

  @override
  String fitbit_data_latest_date(String date) {
    return 'Latest date: $date';
  }

  @override
  String get fitbit_data_details_btn => 'Details';

  @override
  String get fitbit_data_close_btn => 'Close';

  @override
  String get painIndicatorText => 'Pain Level';

  @override
  String get dialogTitle => 'Select Pain Level';

  @override
  String get okButton => 'OK';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get painLevel_0 => 'No pain';

  @override
  String get painLevel_2 => 'Hurts a little bit';

  @override
  String get painLevel_4 => 'Hurts a little more';

  @override
  String get painLevel_6 => 'Hurts even more';

  @override
  String get painLevel_8 => 'Hurts a whole lot';

  @override
  String get painLevel_10 => 'Worst pain possible';

  @override
  String get body_head => 'Head';

  @override
  String get body_head_front => 'Head (Front)';

  @override
  String get body_face => 'Face';

  @override
  String get body_forehead => 'Forehead';

  @override
  String get body_eyes => 'Eyes';

  @override
  String get body_nose => 'Nose';

  @override
  String get body_mouth => 'Mouth';

  @override
  String get body_head_back => 'Head (Back)';

  @override
  String get body_inner_ear_balance => 'Inner Ear / Balance';

  @override
  String get body_neck => 'Neck';

  @override
  String get body_neck_front => 'Neck (Front)';

  @override
  String get body_neck_back => 'Neck (Back)';

  @override
  String get body_torso => 'Torso';

  @override
  String get body_chest => 'Chest';

  @override
  String get body_left_chest => 'Left Chest';

  @override
  String get body_right_chest => 'Right Chest';

  @override
  String get body_breastbone => 'Breastbone';

  @override
  String get body_upper_back => 'Upper Back';

  @override
  String get body_left_shoulder_blade => 'Left Shoulder Blade';

  @override
  String get body_right_shoulder_blade => 'Right Shoulder Blade';

  @override
  String get body_spine_upper_middle => 'Spine (Upper/Middle)';

  @override
  String get body_abdomen => 'Abdomen';

  @override
  String get body_upper_abdomen => 'Upper Abdomen';

  @override
  String get body_lower_abdomen => 'Lower Abdomen';

  @override
  String get body_left_side_abdomen => 'Left Side (Abdomen)';

  @override
  String get body_right_side_abdomen => 'Right Side (Abdomen)';

  @override
  String get body_lower_back => 'Lower Back';

  @override
  String get body_spine_lower => 'Spine (Lower)';

  @override
  String get body_left_flank => 'Left Flank (Side)';

  @override
  String get body_right_flank => 'Right Flank (Side)';

  @override
  String get body_arms => 'Arms';

  @override
  String get body_left_arm => 'Left Arm';

  @override
  String get body_left_shoulder => 'Left Shoulder';

  @override
  String get body_left_upper_arm => 'Left Upper Arm';

  @override
  String get body_left_bicep => 'Left Bicep';

  @override
  String get body_left_tricep => 'Left Tricep';

  @override
  String get body_left_elbow => 'Left Elbow';

  @override
  String get body_left_lower_arm => 'Left Lower Arm';

  @override
  String get body_left_forearm => 'Left Forearm';

  @override
  String get body_left_wrist => 'Left Wrist';

  @override
  String get body_left_hand => 'Left Hand';

  @override
  String get body_left_palm => 'Left Palm';

  @override
  String get body_left_fingers => 'Left Fingers';

  @override
  String get body_right_arm => 'Right Arm';

  @override
  String get body_right_shoulder => 'Right Shoulder';

  @override
  String get body_right_upper_arm => 'Right Upper Arm';

  @override
  String get body_right_bicep => 'Right Bicep';

  @override
  String get body_right_tricep => 'Right Tricep';

  @override
  String get body_right_elbow => 'Right Elbow';

  @override
  String get body_right_lower_arm => 'Right Lower Arm';

  @override
  String get body_right_forearm => 'Right Forearm';

  @override
  String get body_right_wrist => 'Right Wrist';

  @override
  String get body_right_hand => 'Right Hand';

  @override
  String get body_right_palm => 'Right Palm';

  @override
  String get body_right_fingers => 'Right Fingers';

  @override
  String get body_lower_body => 'Lower Body';

  @override
  String get body_pelvis => 'Pelvis';

  @override
  String get body_groin => 'Groin';

  @override
  String get body_hips => 'Hips';

  @override
  String get body_buttocks => 'Buttocks';

  @override
  String get body_legs => 'Legs';

  @override
  String get body_left_leg => 'Left Leg';

  @override
  String get body_left_upper_leg => 'Left Upper Leg';

  @override
  String get body_left_thigh_front => 'Thigh (Front)';

  @override
  String get body_left_thigh_back => 'Thigh (Back)';

  @override
  String get body_left_knee => 'Left Knee';

  @override
  String get body_left_lower_leg => 'Left Lower Leg';

  @override
  String get body_left_shin => 'Shin';

  @override
  String get body_left_calf => 'Calf';

  @override
  String get body_left_ankle => 'Left Ankle';

  @override
  String get body_left_foot => 'Left Foot';

  @override
  String get body_left_heel => 'Heel';

  @override
  String get body_left_foot_sole => 'Foot Sole / Arch';

  @override
  String get body_left_toes => 'Toes';

  @override
  String get body_right_leg => 'Right Leg';

  @override
  String get body_right_upper_leg => 'Right Upper Leg';

  @override
  String get body_right_thigh_front => 'Thigh (Front)';

  @override
  String get body_right_thigh_back => 'Thigh (Back)';

  @override
  String get body_right_knee => 'Right Knee';

  @override
  String get body_right_lower_leg => 'Right Lower Leg';

  @override
  String get body_right_shin => 'Shin';

  @override
  String get body_right_calf => 'Calf';

  @override
  String get body_right_ankle => 'Right Ankle';

  @override
  String get body_right_foot => 'Right Foot';

  @override
  String get body_right_heel => 'Heel';

  @override
  String get body_right_foot_sole => 'Foot Sole / Arch';

  @override
  String get body_right_toes => 'Toes';

  @override
  String get painTypeLabel => 'Pain Type';

  @override
  String get bodyPartLabel => 'Body Part';

  @override
  String get painTypeUnspecified => 'Unspecified';

  @override
  String get painTypeBurning => 'Burning';

  @override
  String get painTypeStabbing => 'Stabbing';

  @override
  String get painTypeAching => 'Aching';

  @override
  String get painTypeThrobbing => 'Throbbing';

  @override
  String get painTypeSharp => 'Sharp';

  @override
  String get painTypeDull => 'Dull';

  @override
  String get painTypeCramping => 'Cramping';

  @override
  String get painTypeRadiating => 'Radiating';

  @override
  String get painTypeTingling => 'Tingling';

  @override
  String get painTypeShooting => 'Shooting';

  @override
  String get painTypePulsing => 'Pulsing';

  @override
  String get painTypePressure => 'Pressure';

  @override
  String get painTypeTightness => 'Tightness';

  @override
  String get painTypeSoreness => 'Soreness';

  @override
  String get painTypeStiffness => 'Stiffness';

  @override
  String get preview_mode => 'Preview Mode';

  @override
  String get preview_mode_active => 'Preview Mode Active';

  @override
  String get preview_mode_active_state => 'Preview mode is now active.';

  @override
  String get preview_mode_inactive_state => 'Preview mode is now inactive.';

  @override
  String get preview_mode_description =>
      'You are currently in preview mode. This allows you to:\n\n• Fast-forward through study days using the \"Next Day\" button\n• Complete tasks multiple times without restrictions\n• Experience the full study flow without affecting real data\n\nImportant: Results and data from preview mode are not stored or mixed with actual participant results from running studies.';

  @override
  String get preview_mode_results_not_saved =>
      'Task completed in preview mode - results are not saved to protect study data integrity.';

  @override
  String get ok => 'OK';

  @override
  String get submit => 'Submit';

  @override
  String get go_back => 'Go back';

  @override
  String get study_settings_section => 'Study settings';

  @override
  String get recovery_phrase_header => 'Recovery phrase';

  @override
  String get copy_to_clipboard => 'Copy to clipboard';

  @override
  String get copied_to_clipboard =>
      'Copied to clipboard. Paste the recovery phrase somewhere secure on your phone now.';

  @override
  String get recovery_phrase_save_warning => 'Never share them with anyone.';

  @override
  String get show_recovery_phrase => 'Show Recovery Phrase';

  @override
  String get recovery_phrase_saved_confirmation =>
      'I have saved all 13 words in a safe place and can retrieve them when I want to restore my account. I can also view them again in Study Settings.';

  @override
  String get recovery_phrase_rotate_button => 'Reissue recovery phrase';

  @override
  String get recovery_phrase_rotate_dialog_title => 'Reissue recovery phrase?';

  @override
  String get recovery_phrase_rotate_dialog_description =>
      'Your current recovery phrase will immediately stop working. You must save the new phrase to recover your account in the future.';

  @override
  String get recovery_phrase_rotate_acknowledgement =>
      'I understand that my current recovery phrase will immediately stop working.';

  @override
  String get recovery_phrase_rotate_confirm => 'Reissue phrase';

  @override
  String get recovery_phrase_rotate_success =>
      'A new recovery phrase has been issued. Save it now.';

  @override
  String get recovery_phrase_rotate_error =>
      'Could not issue a new recovery phrase. Please try again.';

  @override
  String get continue_to_study => 'Done';

  @override
  String get restore_account => 'Restore account';

  @override
  String get enter_recovery_phrase => 'Enter your recovery phrase';

  @override
  String get restore_account_signed_in_title => 'Already signed in';

  @override
  String get restore_account_signed_in_description =>
      'You are already signed in on this device. Restoring an account will replace the current account. Your recovery phrase remains valid after recovery.';

  @override
  String get required => 'Required';

  @override
  String get invalid_recovery_phrase =>
      'This recovery phrase does not match an account. Make sure all 13 words are in the right order.';

  @override
  String get recovery_phrase_too_many_words =>
      'Recovery phrases have 13 words. Remove extra words to continue.';

  @override
  String recovery_successful(String id) {
    return 'Recovery successful! ID: $id';
  }

  @override
  String get deep_link_error_title => 'Error';

  @override
  String deep_link_study_not_found(String studyId) {
    return 'Study with ID $studyId not found or not available';
  }

  @override
  String get recovery_in_progress => 'Recovering your account...';

  @override
  String get recovery_failed =>
      'Recovery failed. Please check your recovery phrase and try again.';

  @override
  String get recovery_user_not_found =>
      'No account found with this recovery phrase.';

  @override
  String get recovery_network_error =>
      'Network error. Please check your connection and try again.';

  @override
  String get restore_account_description =>
      'Restore your account on this device with the recovery phrase you saved before joining a study.';

  @override
  String get restore_account_help_title => 'Restore with your recovery phrase';

  @override
  String get restore_account_help_1 => 'Enter all 13 words in order';

  @override
  String get restore_account_help_2 =>
      'You can type or paste the phrase manually';

  @override
  String get share_recovery => 'Share Recovery';

  @override
  String get share_as_text => 'Share as Text';

  @override
  String get download_recovery => 'Download Recovery';

  @override
  String get download_as_text => 'Download as Text File';

  @override
  String get file_saved => 'File saved successfully';

  @override
  String get file_save_error => 'Error saving file';

  @override
  String get share_btn => 'Share';

  @override
  String get copy_btn => 'Copy';

  @override
  String get download_btn => 'Download';

  @override
  String get general_section => 'General';

  @override
  String get current_study_section => 'Current study';

  @override
  String get participation_options_section => 'Manage participation';

  @override
  String get share_recovery_text_btn => 'Share Recovery Text';

  @override
  String get recovery_phrase_load_error => 'Failed to load recovery phrase';

  @override
  String share_error(String error) {
    return 'Error sharing: $error';
  }

  @override
  String get deep_link_study_invite_only =>
      'This study requires an invite code to join';

  @override
  String deep_link_invite_invalid(String code) {
    return 'Invalid or expired invite code: $code';
  }

  @override
  String get deep_link_error_invalid_invite => 'Invalid invite code';

  @override
  String get deep_link_switch_warning_title => 'You are already in a study';

  @override
  String deep_link_switch_warning_description(
    String currentStudy,
    String targetStudy,
  ) {
    return 'You are currently enrolled in:\n$currentStudy\n\nThe deep link points to:\n$targetStudy\n\nYou can return to your current study (recommended) or continue to leave it and switch.';
  }

  @override
  String deep_link_switch_warning_opt_out_instruction(String optOut) {
    return 'If you want to leave your current study, open Settings and use \"$optOut\" first. Then open the invite again.';
  }

  @override
  String get deep_link_switch_open_settings => 'Open Settings';

  @override
  String get deep_link_switch_continue_study => 'Continue Study';

  @override
  String get deep_link_switch_primary_return => 'Return to current study';

  @override
  String get deep_link_switch_secondary_continue =>
      'Leave current study and switch';

  @override
  String get deep_link_switch_data_choice_title =>
      'How do you want to leave your current study?';

  @override
  String get deep_link_switch_data_choice_description =>
      'Choose what should happen to your current study data before switching.';

  @override
  String get deep_link_switch_soft_delete_button => 'Soft delete and switch';

  @override
  String get deep_link_switch_hard_delete_button => 'Hard delete and switch';

  @override
  String get deep_link_switch_confirm_soft_title => 'Confirm soft delete';

  @override
  String get deep_link_switch_confirm_soft_button => 'Confirm soft delete';

  @override
  String get deep_link_switch_confirm_hard_title => 'Confirm hard delete';

  @override
  String get deep_link_switch_confirm_hard_description =>
      'This will permanently and irreversibly delete all your data.';

  @override
  String get deep_link_switch_confirm_hard_button => 'Confirm hard delete';

  @override
  String get open_link_on_mobile =>
      'Please open this link on your mobile device.';

  @override
  String get you_have_been_invited => 'You have been invited to a study!';

  @override
  String get download_app_join => 'Download the StudyU App & Join';

  @override
  String get deleted_study_error_title => 'Study unavailable';

  @override
  String get deleted_study_error_description =>
      'This study is no longer available from the server. Your data remains on this device for now. Please contact your study supervisor or support before deleting anything. Only use \'Delete all data\' if they tell you to reset the app.';

  @override
  String get dashboard_showcase_progress_title => 'Study progress';

  @override
  String get dashboard_showcase_progress_description =>
      'This shows where you are in the study and how much is left.';

  @override
  String get dashboard_showcase_current_intervention_title =>
      'Current intervention';

  @override
  String get dashboard_showcase_current_intervention_description =>
      'Here you can see your current intervention and how many days remain in this phase.';

  @override
  String get dashboard_showcase_today_tasks_title => 'Today\'s tasks';

  @override
  String get dashboard_showcase_today_tasks_description =>
      'Here you can find the tasks you need to complete today as part of the study.';

  @override
  String get dashboard_showcase_contact_title => 'Contact';

  @override
  String get dashboard_showcase_contact_description =>
      'Use this if you need help from the study team.';

  @override
  String get dashboard_showcase_report_title => 'Report';

  @override
  String get dashboard_showcase_report_description =>
      'Open your current report when results are available.';

  @override
  String get dashboard_showcase_menu_title => 'More options';

  @override
  String get dashboard_showcase_menu_description =>
      'Find settings, FAQs, report history, and more here.';

  @override
  String get dashboard_showcase_finish => 'Finish';

  @override
  String get support_email_subject_loading_error =>
      'StudyU Support Request - Loading Error';

  @override
  String get support_email_subject_deleted_study =>
      'StudyU Support Request - Study Unavailable';

  @override
  String deleted_study_support_email_body(String subjectId) {
    return 'Hello,\n\nThe StudyU app says that my study is no longer available from the server. My subject ID is: $subjectId\n\nPlease let me know whether I should keep my local data or reset the app.\n\nThank you.';
  }

  @override
  String get dashboard_tour => 'Dashboard tour';

  @override
  String get show_again => 'View tour again';

  @override
  String get free_text_hint => 'Enter your answer';

  @override
  String get preview_failed_to_initialize => 'Preview failed to initialize.';

  @override
  String get preview_overlay_reset_hint =>
      'The preview could not be opened right now. Please try resetting the preview.';

  @override
  String get preview_overlay_study_not_ready =>
      'The preview could not be opened for this study yet. Please try resetting the preview.';

  @override
  String get preview_overlay_route_open_failed =>
      'The preview route could not be opened right now.';

  @override
  String get continue_label => 'Continue';

  @override
  String get restored_answer_needs_review => 'Restored answer requires review';

  @override
  String get restored_answer_review_description =>
      'Complete task becomes available after review.';

  @override
  String get mark_answer_reviewed => 'I\'ve reviewed this answer';

  @override
  String get answer_reviewed => 'Answer reviewed';

  @override
  String get review_restored_answer_to_continue =>
      'Review the restored answer to continue.';

  @override
  String get complete_task => 'Complete task';

  @override
  String get no_internet_connection =>
      'No internet connection. Please try again when online.';

  @override
  String error_occurred_with_message(String message) {
    return 'An error occurred: $message';
  }

  @override
  String get date_picker_hint => 'Select a date';

  @override
  String get time_picker_hint => 'Select a time';

  @override
  String get date_picker_button_label => 'Choose date';

  @override
  String get date_time_picker_button_label => 'Choose date and time';

  @override
  String get date_picker_button_label_datetime => 'Select date';

  @override
  String get time_picker_button_label_datetime => 'Select time';

  @override
  String get time_picker_button_label => 'Select a time';

  @override
  String get date_picker_clear => 'Clear';

  @override
  String get date_picker_validation_required => 'Please select a date';

  @override
  String get time_picker_validation_required => 'Please select a time';

  @override
  String get datetime_picker_validation_required =>
      'Please select both date and time';

  @override
  String get time_picker_validation_range =>
      'Please select a time within the allowed range';

  @override
  String time_picker_range_hint(Object min, Object max) {
    return 'Select a time between $min and $max';
  }

  @override
  String time_picker_min_hint(Object min) {
    return 'Earliest allowed time: $min';
  }

  @override
  String time_picker_max_hint(Object max) {
    return 'Latest allowed time: $max';
  }

  @override
  String date_picker_validation_min_date(String minDate) {
    return 'Date must be after $minDate';
  }

  @override
  String date_picker_validation_max_date(String maxDate) {
    return 'Date must be before $maxDate';
  }

  @override
  String get please_select_interventions_why => 'Why?';

  @override
  String get recovery_phrase_description =>
      'Save these 13 words in a safe place. They are the only way to restore your account if you lose access to this device.';

  @override
  String get recovery_phrase_why => 'Why?';

  @override
  String get recovery_phrase_reason =>
      'StudyU does not use passwords or email accounts. These 13 words are the only way to restore your account if you get a new phone or reinstall the app. Write them down or store them digitally somewhere only you can access. Never share them with anyone. You can view your recovery phrase again at any time under Settings → Study settings.';

  @override
  String get study_not_started_title => 'You’ve joined the study';

  @override
  String get study_not_started_description =>
      'Come back tomorrow to begin. We’ll remind you when there’s something to do.';

  @override
  String recovery_phrase_word_count(Object count, Object total) {
    return '$count/$total words';
  }

  @override
  String get ko => 'Korean';

  @override
  String get faq_section_data_storage_privacy => 'Data Storage and Privacy';

  @override
  String get faq_question_data_storage => 'Where and how is my data stored?';

  @override
  String get faq_answer_data_storage =>
      'The data collected from you is stored locally on your device and is uploaded to a secure server when it is connected to the internet. All study data is collected and stored anonymously.';

  @override
  String get faq_question_personal_data =>
      'Which personal data does the app collect?';

  @override
  String get faq_answer_personal_data =>
      'The app does not collect any personal data of the user.';

  @override
  String get faq_section_studies => 'Studies';

  @override
  String get faq_question_study_duration =>
      'How long will the study take to finish?';

  @override
  String get faq_answer_study_duration =>
      'The duration of each study is mentioned during initial study selection.';

  @override
  String get faq_question_change_intervention =>
      'Can I select a different intervention?';

  @override
  String get faq_answer_change_intervention =>
      'Before starting the study, go back to the intervention selection screen to choose different interventions. After the study has started, you cannot change the selected interventions for that participation. To choose different interventions, leave the study from Settings, choose whether to keep or permanently delete your existing data, and then select a study and its interventions again during enrollment.';

  @override
  String get faq_question_missed_tasks =>
      'Can I redo my missed tasks on a later date?';

  @override
  String get faq_answer_missed_tasks =>
      'No, you cannot redo a missed task on a later date. However, you can finish it at anytime on the same day.';

  @override
  String get faq_question_leave_study => 'How can I leave the current study?';

  @override
  String get faq_answer_leave_study =>
      'Go to the Settings tab on the Dashboard and click \"Leave study\". This will exit the study without deleting your progress data, allowing it to be included in the study analysis. To leave the study and delete all progress data both locally and on the server, click \"Leave study and delete all data\". All data will be permanently removed from the server and your device.';

  @override
  String get faq_section_report_details => 'Report Details';

  @override
  String get faq_question_daily_tasks =>
      'What are daily tasks and how do I complete them?';

  @override
  String get faq_answer_daily_tasks =>
      'To find out which intervention works best for you, you need to perform some daily tasks for each intervention. Please make sure to hit the \"Complete\" button after finishing it';

  @override
  String get faq_question_rate_your_day => 'What is \"Rate your day\"?';

  @override
  String get faq_answer_rate_your_day =>
      '\"Rate your day\" is a feature that tracks your health during entire study period. It requires you to rate certain health-related queries on a scale of 1 to 10.';

  @override
  String get faq_question_track_activities =>
      'How can I keep track of my activities?';

  @override
  String get faq_answer_track_activities =>
      'You can get an overview of your daily tasks and health status in the \"Reports History section\"';

  @override
  String get faq_question_download_report =>
      'How can I download my Study report?';

  @override
  String get faq_answer_download_report =>
      'Your report will be ready to download once you have completed the minimum required tasks for a study. It will be available in the Report History tab located on the Dashboard.';

  @override
  String get debug_notifications_not_initialized =>
      'Notifications are not initialized yet. Please start a study and open this through the about section.';

  @override
  String get debug_test_notification_title => 'StudyU Test Notification';

  @override
  String get debug_test_notification_body =>
      'This notification confirms that you receive StudyU notifications';

  @override
  String get debug_reset_success =>
      'App reset successfully! Please restart the app.';

  @override
  String get debug_reset_error =>
      'Error while resetting the app. Please try again.';

  @override
  String get debug_screen_title => 'Debug Screen';

  @override
  String get debug_send_information_via_email =>
      'Send debug information via email';

  @override
  String get debug_receive_test_notification => 'Receive test notification';

  @override
  String get debug_show_onboarding => 'Show onboarding';

  @override
  String get invite_landing_instruction_title =>
      'Join the study with StudyU Health';

  @override
  String get invite_landing_qr_label => 'Study invitation QR code';

  @override
  String get invite_landing_invite_code => 'Invite code';

  @override
  String get invite_landing_invalid =>
      'This invitation is no longer available. Please check the link or code and try again.';

  @override
  String get invite_landing_load_error =>
      'We could not load this invitation. Please try again later.';

  @override
  String get invite_landing_loading => 'Loading invitation…';

  @override
  String get scan_invite_code => 'Scan QR code';

  @override
  String get scan_invite_code_description =>
      'Point your camera at the invitation QR code.';

  @override
  String get open_study_app => 'Open in StudyU Health';

  @override
  String get invite_landing_google_play => 'Get it on Google Play';

  @override
  String get invite_landing_app_store => 'Download on the App Store';

  @override
  String get invite_landing_step_download => 'Get the StudyU Health app';

  @override
  String get invite_landing_step_join => 'Join the study in the app';

  @override
  String get invite_landing_step_join_description =>
      'Open StudyU Health on your phone and tap Join with an invite code. Enter the invite code or scan the QR code to join the study.';

  @override
  String get invite_landing_invited_title => 'You’re invited to join';

  @override
  String get invite_landing_phone_instruction =>
      'Enter this invite code in the StudyU Health app.';

  @override
  String get invite_landing_other_device_instruction =>
      'For quick access, scan this QR code with your phone.';

  @override
  String get invite_landing_enter_code_title => 'Enter invite code';

  @override
  String get invite_landing_scan_qr_title => 'Scan QR code';

  @override
  String get invite_landing_copied => 'Copied';

  @override
  String get invite_landing_copy_code => 'Copy invite code';

  @override
  String get date_format => 'Date format';

  @override
  String get date_format_european => 'European (31/12/2024)';

  @override
  String get date_format_german => 'German (31.12.2024)';

  @override
  String get date_format_iso => 'ISO (2024-12-31)';

  @override
  String get date_format_us => 'US (12/31/2024)';

  @override
  String get system => 'System';

  @override
  String get time_format => 'Time format';

  @override
  String get time_format_12_hour => '12-hour (2:30 PM)';

  @override
  String get time_format_24_hour => '24-hour (14:30)';

  @override
  String get daily_food_diary => 'Daily Food Diary';

  @override
  String get instructions => 'Instructions';

  @override
  String get nutrition_instructions_default =>
      'Please record all the foods and beverages you consumed today. For each meal or snack, provide as much detail as possible including portion sizes and preparation methods.';

  @override
  String min_meals_required(int count) {
    return 'Please record at least $count meal(s)';
  }

  @override
  String get recall_details => 'Recall Details';

  @override
  String get date => 'Date';

  @override
  String get recall_mode => 'Recall Mode';

  @override
  String get recall_mode_realtime => 'Real-time Recording';

  @override
  String get recall_mode_yesterday => 'Yesterday Recall';

  @override
  String get usual_intake_day => 'Usual Intake Day';

  @override
  String get usual_intake_question => 'Was this a typical day for your diet?';

  @override
  String get special_occasion => 'Special Occasion';

  @override
  String get special_occasion_hint => 'e.g., Birthday, Holiday, etc.';

  @override
  String meals_count(int count) {
    return 'Meals ($count)';
  }

  @override
  String get add_meal => 'New meal';

  @override
  String get no_meals_recorded => 'No meals recorded yet';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get meal_type_breakfast => 'Breakfast';

  @override
  String get meal_type_lunch => 'Lunch';

  @override
  String get meal_type_dinner => 'Dinner';

  @override
  String get meal_type_snack => 'Snack';

  @override
  String get meal_type_brunch => 'Brunch';

  @override
  String get meal_type_other => 'Other';

  @override
  String get meal_category_snacks => 'Snacks';

  @override
  String get meal_category_other => 'Other meals';

  @override
  String get no_foods_added => 'No foods added';

  @override
  String get log_food => 'Log food';

  @override
  String food_items_count(int count) {
    return '$count food items';
  }

  @override
  String get meal_entry_title => 'Meal Entry';

  @override
  String get add_meal_or_snack => 'Add meal or snack';

  @override
  String get meal_neutral_label => 'Meal';

  @override
  String get meal_suffix => 'meal';

  @override
  String get meal_label => 'Meal label';

  @override
  String get no_meal_label => 'No label';

  @override
  String get time_not_remembered => 'Time not remembered';

  @override
  String about_time(String time) {
    return 'About $time';
  }

  @override
  String get time_exact => 'Exact time';

  @override
  String get time_exact_description => 'I know the exact time';

  @override
  String get time_approximate => 'Approximate time';

  @override
  String get time_approximate_description => 'I know roughly when';

  @override
  String get time_unknown => 'I don\'t remember';

  @override
  String get set_time => 'Set time';

  @override
  String get save => 'Save';

  @override
  String get new_item => 'New';

  @override
  String get discard => 'Discard';

  @override
  String get unsaved_changes_title => 'Discard unsaved changes?';

  @override
  String get unsaved_changes_message =>
      'Discard your changes or continue editing.';

  @override
  String get discard_meal_changes_title => 'Leave this meal?';

  @override
  String get discard_meal_changes_message =>
      'Discard your changes or continue editing.';

  @override
  String get save_and_leave => 'Save and leave';

  @override
  String get discard_changes => 'Discard changes';

  @override
  String get continue_editing => 'Continue editing';

  @override
  String get delete_meal => 'Delete meal';

  @override
  String get delete_meal_title => 'Delete this meal?';

  @override
  String get delete_meal_message =>
      'This meal will be removed from the nutrition log.';

  @override
  String get enter_skip_reason => 'Enter a reason before saving.';

  @override
  String get add_food_before_saving =>
      'Add at least one food item before saving.';

  @override
  String get meal_information => 'Meal Information';

  @override
  String get meal_type_label => 'Meal Type';

  @override
  String get meal_details => 'Meal details';

  @override
  String get edit_meal_title => 'Edit meal';

  @override
  String get apply => 'Apply';

  @override
  String get custom_meal_label => 'Custom Meal Label';

  @override
  String get time => 'Time';

  @override
  String get where_did_you_eat => 'Where did you eat?';

  @override
  String get location_description => 'Location Description';

  @override
  String get location_description_hint => 'Describe where you ate';

  @override
  String get who_were_you_with => 'Who were you with?';

  @override
  String get distractions_during_meal => 'Distractions during meal?';

  @override
  String get skipped_this_meal => 'Skipped this meal';

  @override
  String get reason_for_skipping => 'Reason for skipping';

  @override
  String food_items_section(int count) {
    return 'Food Items ($count)';
  }

  @override
  String get add_food => 'Add Food';

  @override
  String get no_food_items_yet => 'No food items yet';

  @override
  String get not_specified => 'Not specified';

  @override
  String get context_home => 'Home';

  @override
  String get context_restaurant => 'Restaurant';

  @override
  String get context_takeout => 'Takeout';

  @override
  String get context_vending => 'Vending';

  @override
  String get context_other => 'Other';

  @override
  String get company_alone => 'Alone';

  @override
  String get company_family => 'Family';

  @override
  String get company_friends => 'Friends';

  @override
  String get company_colleagues => 'Colleagues';

  @override
  String get company_other => 'Other';

  @override
  String get distraction_none => 'None';

  @override
  String get distraction_tv => 'TV';

  @override
  String get distraction_phone => 'Phone';

  @override
  String get distraction_work => 'Work';

  @override
  String get distraction_other => 'Other';

  @override
  String get food_entry_title => 'Food Entry';

  @override
  String get food_information => 'Food Information';

  @override
  String get entry_type => 'Entry Type';

  @override
  String get food_name => 'Food name *';

  @override
  String get nutrition_values_are_for => 'Nutrition values are for';

  @override
  String get brand_name => 'Brand Name';

  @override
  String get description => 'Description';

  @override
  String get description_hint => 'Optional notes about this food';

  @override
  String get meal_info => 'Meal: Use Meal Creator for combined food management';

  @override
  String get open_meal_creator => 'Open Meal Creator';

  @override
  String get amount => 'Amount *';

  @override
  String get unit => 'Unit *';

  @override
  String get serving_size => 'Serving Size (grams) *';

  @override
  String get portion_reference => 'Portion Reference';

  @override
  String get portion_reference_hint => 'e.g., 1 cup, 3 oz, medium apple';

  @override
  String get portion_estimation_method => 'Portion Estimation Method';

  @override
  String get portion_state => 'Portion State';

  @override
  String get yield_factor => 'Yield Factor';

  @override
  String get yield_factor_hint => 'e.g., 0.75';

  @override
  String get edible_portion => 'Edible Portion';

  @override
  String get edible_portion_hint => 'e.g., 0.85';

  @override
  String get nutrition_information => 'Nutrition Information';

  @override
  String get energy_kcal => 'Energy (kcal) *';

  @override
  String get protein_g => 'Protein (g)';

  @override
  String get carbs_g => 'Carbs (g)';

  @override
  String get fat_g => 'Fat (g)';

  @override
  String get protein => 'Protein';

  @override
  String get carbohydrate => 'Carbohydrate';

  @override
  String get fat => 'Fat';

  @override
  String get optional => 'Optional';

  @override
  String get saturated_fat_g => 'Sat. Fat (g)';

  @override
  String get sugars_g => 'Sugars (g)';

  @override
  String get fiber_g => 'Fiber (g)';

  @override
  String get sodium_mg => 'Sodium (mg)';

  @override
  String get required_error => 'Required';

  @override
  String get enter_food_name => 'Please enter a food name';

  @override
  String get enter_serving_size => 'Please enter serving size';

  @override
  String get entry_type_single_ingredient => 'Single Ingredient';

  @override
  String get entry_type_meal => 'Meal';

  @override
  String get entry_type_branded_product => 'Branded Product';

  @override
  String get entry_type_manual_entry => 'Manual Entry';

  @override
  String get portion_method_household => 'Household Measure';

  @override
  String get portion_method_photograph => 'Photograph';

  @override
  String get portion_method_standard_unit => 'Standard Unit';

  @override
  String get portion_method_user_weighted => 'User Weighted';

  @override
  String get portion_method_unknown => 'Unknown';

  @override
  String get portion_state_raw => 'Raw';

  @override
  String get portion_state_cooked => 'Cooked';

  @override
  String get portion_state_as_served => 'As Served';

  @override
  String get my_templates => 'My items';

  @override
  String get manage_saved_items => 'Manage';

  @override
  String get adjust_quantity => 'Adjust quantity';

  @override
  String get edit_this_entry => 'Edit this entry';

  @override
  String get library_edit_title => 'Update reusable item?';

  @override
  String get library_edit_message =>
      'This entry comes from your library. Choose where to save your changes.';

  @override
  String get library_edit_current_entry => 'Only this logged item';

  @override
  String get library_edit_current_entry_and_library =>
      'This item and reusable library item';

  @override
  String get save_to_my_items_action => 'Save to My items';

  @override
  String get external_library_copy => 'Import';

  @override
  String external_library_copy_label(String name) {
    return 'Review and add $name to My library';
  }

  @override
  String get external_library_copy_saved => 'Added to My library';

  @override
  String get external_library_copy_save_error =>
      'Could not add food to My library';

  @override
  String get remove_from_meal => 'Remove from meal';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get save_as_template => 'Add to My items';

  @override
  String get save_meal => 'Save to library';

  @override
  String get done_label => 'Done';

  @override
  String get log_meal => 'Log meal';

  @override
  String get add_items => 'Add items';

  @override
  String add_items_to_meal(String meal) {
    return 'Add items to $meal';
  }

  @override
  String get save_as_reusable_meal => 'Save as reusable meal';

  @override
  String get save_as_reusable_meal_description =>
      'Add this combination to My items so you can use it again.';

  @override
  String get save_food => 'Save food';

  @override
  String get template_name => 'Name';

  @override
  String get template_name_required => 'Meal name *';

  @override
  String get template_tags_optional => 'Tags (optional)';

  @override
  String get template_tags_hint => 'breakfast, quick, healthy';

  @override
  String get template_saved => 'Added to My items';

  @override
  String get select_meal => 'My meals';

  @override
  String get select_food => 'My foods';

  @override
  String get food_library_search_hint =>
      'Search My library and external library…';

  @override
  String get search_templates => 'Search saved foods and meals…';

  @override
  String get no_templates_saved => 'No items yet';

  @override
  String get save_templates_hint =>
      'Save your favorite meals and foods for quick access';

  @override
  String get from_template => 'From My items';

  @override
  String get add_new_food => 'Add New Food';

  @override
  String get delete_template => 'Delete item';

  @override
  String get delete_template_confirmation =>
      'Are you sure you want to delete this item?';

  @override
  String get filter_all => 'All';

  @override
  String get filter_meals => 'Meals';

  @override
  String get filter_foods => 'Foods';

  @override
  String items_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get add => 'Add';

  @override
  String get food_selection_add_to_selection => 'Add to selection';

  @override
  String get food_selection_update_selection => 'Update selection';

  @override
  String get food_selection_selected_items => 'Selected items';

  @override
  String food_selection_view_more(int count) {
    return 'View all $count items';
  }

  @override
  String food_selection_increment(String name) {
    return 'Increase $name';
  }

  @override
  String food_selection_decrement(String name) {
    return 'Decrease $name';
  }

  @override
  String food_selection_delete(String name) {
    return 'Delete $name';
  }

  @override
  String get food_selection_item_removed => 'Item removed';

  @override
  String get food_selection_undo => 'Undo';

  @override
  String food_selection_selected(String name, int quantity) {
    return '$name, selected, quantity $quantity';
  }

  @override
  String food_selection_known_calories(String value, int count) {
    return '$value kcal known · $count unavailable';
  }

  @override
  String food_selection_unknown_calories(int count) {
    return '— kcal · $count unavailable';
  }

  @override
  String food_selection_calories_unavailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: 'one item',
    );
    return 'Calories unavailable for $_temp0';
  }

  @override
  String food_selection_confirm(int count, String meal) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count items to $meal',
      one: 'Add 1 item to $meal',
    );
    return '$_temp0';
  }

  @override
  String serving_amount(num amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: '$amount servings',
      one: '1 serving',
    );
    return '$_temp0';
  }

  @override
  String kcal_value(String value) {
    return '$value kcal';
  }

  @override
  String kcal_per_serving(String value) {
    return '$value kcal / serving';
  }

  @override
  String servings_value(String value) {
    return '$value servings';
  }

  @override
  String get custom => 'Custom';

  @override
  String get database => 'Database';

  @override
  String get no_recent_items => 'No recent items yet';

  @override
  String get brand => 'Brand';

  @override
  String get calorie_basis_100g => 'per 100 g';

  @override
  String calorie_basis_grams(String grams) {
    return 'per $grams g';
  }

  @override
  String get template_type_meal => 'Meal';

  @override
  String get template_type_food => 'Food';

  @override
  String get rename_template => 'Rename item';

  @override
  String get new_name => 'New Name';

  @override
  String get today => 'Today';

  @override
  String get meals => 'Meals';

  @override
  String get food_items => 'Food items';

  @override
  String get tap_to_add_first_meal =>
      'Tap the button above to add your first meal';

  @override
  String get tap_to_add_food => 'Tap to add food';

  @override
  String get add_food_title => 'Add Food';

  @override
  String add_food_to_meal(String meal) {
    return 'Add food to $meal';
  }

  @override
  String get food_quantity_amount => 'Amount';

  @override
  String get food_quantity_weight => 'Weight';

  @override
  String get food_quantity_custom_weight => 'Custom';

  @override
  String food_quantity_library_serving(String weight) {
    return 'Library serving: $weight g';
  }

  @override
  String food_quantity_default_serving(String weight) {
    return 'Default serving: $weight g';
  }

  @override
  String get food_quantity_library_serving_unknown =>
      'Library serving: weight unavailable';

  @override
  String get food_quantity_default_serving_unknown =>
      'Default serving: weight unavailable';

  @override
  String get food_quantity_override_helper =>
      'Changes only this meal selection. My Library and the source item remain unchanged.';

  @override
  String food_quantity_use_library_weight(String weight) {
    return 'Use library weight ($weight g)';
  }

  @override
  String food_quantity_use_default_weight(String weight) {
    return 'Use default weight ($weight g)';
  }

  @override
  String get food_quantity_invalid_amount =>
      'Enter an amount greater than zero';

  @override
  String get food_quantity_serving => 'Serving';

  @override
  String food_quantity_serving_unit(num amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'servings',
      one: 'serving',
    );
    return '$_temp0';
  }

  @override
  String food_quantity_serving_value(String value, String unit) {
    return '$value g per $unit';
  }

  @override
  String get food_quantity_energy => 'Energy';

  @override
  String get food_quantity_protein => 'Protein';

  @override
  String get food_quantity_carbs => 'Carbs';

  @override
  String get food_quantity_fat => 'Fat';

  @override
  String food_quantity_add_to_meal(String meal) {
    return 'Add to $meal';
  }

  @override
  String get food_quantity_add_to_selection => 'Add item';

  @override
  String get food_quantity_add_meal_to_selection => 'Add meal to selection';

  @override
  String get food_quantity_update_selection => 'Save changes';

  @override
  String get food_quantity_nutrition_unavailable =>
      'Nutrition information unavailable';

  @override
  String get save_to_my_items => 'Save to My items for future use';

  @override
  String save_and_add_to_meal(String meal) {
    return 'Save and add to $meal';
  }

  @override
  String get edit_food_title => 'Edit food';

  @override
  String get add_food_manually => 'Create food';

  @override
  String get basic_information => 'Basic Information';

  @override
  String get macronutrients => 'Macronutrients';

  @override
  String get detailed_nutrients => 'Detailed Nutrients';

  @override
  String get daily_nutrition_total => 'Nutrition summary';

  @override
  String get daily_summary => 'Daily summary';

  @override
  String get energy_by_macronutrient => 'Energy by macronutrient';

  @override
  String get total_energy => 'Total energy';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get carbohydrates => 'Carbohydrates';

  @override
  String get fibre => 'Fibre';

  @override
  String get other => 'Other';

  @override
  String some_values_unavailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return 'Some nutrient values are unavailable for $count $_temp0.';
  }

  @override
  String get meal_nutrition => 'Meal Nutrition';

  @override
  String get nutrition_summary => 'Nutrition Summary';

  @override
  String get calorie_distribution => 'Calorie Distribution';

  @override
  String get more_options => 'More options';

  @override
  String get search_food_hint => 'Search foods, meals or brands';

  @override
  String get my_saved_items => 'My library';

  @override
  String get food_library => 'Food library';

  @override
  String get add_food_action => 'Create food';

  @override
  String get add_meal_action => 'Create meal';

  @override
  String get recent_foods => 'Recently added';

  @override
  String get frequently_used_foods => 'Frequently Used';

  @override
  String get global_database => 'Database';

  @override
  String get external_library => 'External library';

  @override
  String get external_library_loading => 'Searching external library…';

  @override
  String get external_library_error =>
      'External library is unavailable. Please try again.';

  @override
  String external_library_results_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count external results found',
      one: '1 external result found',
    );
    return '$_temp0';
  }

  @override
  String get review_copied_food => 'Review food';

  @override
  String get external_library_copy_notice =>
      'Review the details before adding this food to My library. Changes won’t affect the external library.';

  @override
  String get external_library_save_copy => 'Save to My library';

  @override
  String get quick_actions => 'Quick Actions';

  @override
  String get create => 'Create';

  @override
  String get create_meal => 'Create meal';

  @override
  String get create_meal_subtitle => 'Combine multiple foods';

  @override
  String get add_manually => 'Create food manually';

  @override
  String get add_manually_subtitle => 'Enter nutrition facts yourself';

  @override
  String get tap_item_to_choose_serving =>
      'Tap a food to change the serving or amount.';

  @override
  String get scan_barcode => 'Scan Barcode';

  @override
  String get scan_barcode_subtitle => 'Find packaged products quickly';

  @override
  String get barcode_scanner_guidance_initial => 'Point camera at barcode';

  @override
  String get barcode_scanner_no_barcode =>
      'No barcode detected — adjust position';

  @override
  String get barcode_scanner_processing => 'Barcode detected! Processing…';

  @override
  String get barcode_scanner_invalid =>
      'Invalid barcode — try a different angle';

  @override
  String get barcode_scanner_lookup => 'Valid barcode. Looking up…';

  @override
  String get barcode_scanner_distance_guidance =>
      'Large barcode? Move back 15–30 cm\\nSmall barcode? Move closer';

  @override
  String get barcode_scanner_detected => 'DETECTED';

  @override
  String get barcode_scanner_lookup_progress => 'Looking up product…';

  @override
  String get barcode_scanner_toggle_flash => 'Toggle flash';

  @override
  String get barcode_scanner_switch_camera => 'Switch camera';

  @override
  String get barcode_scanner_not_found_title => 'Product not found';

  @override
  String barcode_scanner_not_found_message(String barcode) {
    return 'No product found for barcode: $barcode\\n\\nThis product may not be in the external library yet. You can add it manually or scan another product.';
  }

  @override
  String get barcode_scanner_scan_again => 'Scan again';

  @override
  String get barcode_scanner_error_title => 'Search unavailable';

  @override
  String get search_for_food => 'Search for Food';

  @override
  String get search_food_description =>
      'Try “apple”, “oat milk”, or a brand name.';

  @override
  String get searching_databases => 'Searching databases...';

  @override
  String get end_of_results => 'End of results';

  @override
  String get no_results_found => 'No results found. Try different keywords.';

  @override
  String no_results_for_query(String query) {
    return 'No results for “$query”';
  }

  @override
  String get cant_find_it => 'Can’t find it?';

  @override
  String create_food_from_search(String query) {
    return 'Create “$query” manually';
  }

  @override
  String get food_search_error =>
      'Food search is unavailable. Please try again.';

  @override
  String food_search_results_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results found',
      one: '1 result found',
    );
    return '$_temp0';
  }

  @override
  String get no_matching_templates => 'No matching items';

  @override
  String get detailed_nutrition => 'Detailed Nutrition';

  @override
  String get detailed_nutrition_subtitle => 'Fiber, Sugar, Sodium';

  @override
  String get advanced_options => 'Advanced Options';

  @override
  String get advanced_options_subtitle => 'Food type, serving size, portions';

  @override
  String get details => 'Details';

  @override
  String get meal_context => 'Meal context';

  @override
  String get search_food_database => 'Search Food Database';

  @override
  String get no_data_yet => 'No data yet';

  @override
  String get start_tracking_nutrition =>
      'Start tracking your nutrition by adding meals';

  @override
  String get photoRecallTitle => 'Photo Recall';

  @override
  String get photoRecallSubtitle =>
      'Use photos from this day to remember what you ate.';

  @override
  String get photoRecallPermissionNeeded => 'Tap to enable photo access';

  @override
  String get photoRecallPermissionTitle => 'Enable Photo Access';

  @override
  String get photoRecallPermissionDescription =>
      'Access to your photos helps you recall what you ate. Photos are only displayed on your device.';

  @override
  String get photoRecallNoPhotos => 'No photos found';

  @override
  String get photoRecallNoPhotosSubtitle =>
      'We couldn’t find any photos taken on this day';

  @override
  String get photoRecallTapToEnlarge => 'Tap a photo to view it full screen';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get analyzePhotoTooltip => 'Analyze this food photo';

  @override
  String get analyzingPhoto => 'Analyzing photo...';

  @override
  String get foodAnalysisError => 'Could not analyze image - try manual entry';

  @override
  String get foodAnalysisNetworkError =>
      'Could not connect to analysis service';

  @override
  String get foodAnalysisNoItems => 'No food items detected in image';

  @override
  String get aiEstimatedBanner => 'AI-estimated values - please review';

  @override
  String get selectFoodItemsTitle => 'Select Food Items';

  @override
  String get selectFoodItemsSubtitle =>
      'Select which items to add to your meal';

  @override
  String get addSelected => 'Add Selected';

  @override
  String get analyzeAgain => 'Analyze Again';

  @override
  String get select_all => 'Select All';

  @override
  String get deselect_all => 'Deselect All';

  @override
  String confidenceLabel(int percentage) {
    return 'Confidence: $percentage%';
  }

  @override
  String get min_meals_not_met_title => 'Minimum meals not reached';

  @override
  String min_meals_not_met_message(int count) {
    return 'This task requires at least $count meal(s). You have recorded fewer than required. Leave anyway?';
  }

  @override
  String get leave_anyway => 'Leave anyway';

  @override
  String get nutrition_tracking => 'Nutrition tracking';

  @override
  String get nutrition_statistics => 'Statistics';

  @override
  String get nutrition_recent_7_days => 'Recent 7 days';

  @override
  String get nutrition_recent_30_days => 'Recent 30 days';

  @override
  String nutrition_days_recorded(int recorded, int total) {
    return '$recorded of $total days recorded';
  }

  @override
  String nutrition_completed_days(int completed) {
    String _temp0 = intl.Intl.pluralLogic(
      completed,
      locale: localeName,
      other: '$completed completed days',
      one: '$completed completed day',
    );
    return '$_temp0';
  }

  @override
  String get nutrition_daily_average => 'Average across completed days';

  @override
  String get nutrition_energy_by_study_day => 'Energy by study day';

  @override
  String nutrition_average_value(String value) {
    return 'Average $value across completed days';
  }

  @override
  String get nutrition_tap_bar_hint =>
      'Tap a bar to view its value or open that day.';

  @override
  String get nutrition_nutrient_trend => 'Nutrient trend';

  @override
  String get nutrition_carbs => 'Carbs';

  @override
  String nutrition_average_per_recorded_day(String value) {
    return 'Average $value per completed day';
  }

  @override
  String nutrition_compared_previous_days(int count) {
    return 'Compared with the previous $count days';
  }

  @override
  String get nutrition_record_more_comparisons =>
      'Record more study days to see period comparisons.';

  @override
  String get nutrition_energy => 'Energy';

  @override
  String get nutrition_today_so_far => 'Today so far';

  @override
  String nutrition_chart_day_value(String date, String value) {
    return '$date, $value';
  }

  @override
  String nutrition_chart_day_missing(String date) {
    return '$date, not recorded';
  }

  @override
  String get nutrition_view_day_hint => 'Press Enter to view this day.';

  @override
  String get nutrition_statistics_help_message =>
      'Averages include only completed study days. Today appears in charts as ‘Today so far’ and is excluded from averages until the diary is complete. Missing days are left blank.';

  @override
  String nutrition_kcal_per_day(String value) {
    return '$value kcal/day';
  }

  @override
  String nutrition_grams_per_day(String value) {
    return '$value g/day';
  }

  @override
  String get nutrition_recent_days => 'Recent days';

  @override
  String get nutrition_history => 'History';

  @override
  String get nutrition_history_empty => 'No past food diaries yet.';

  @override
  String get nutrition_history_latest_study_day => 'Latest study day';

  @override
  String get nutrition_history_latest_study_day_description =>
      'Your latest study day remains editable so you can add or correct entries the following morning.';

  @override
  String get nutrition_history_previous_study_days => 'Previous study days';

  @override
  String get nutrition_history_no_foods_logged => 'No foods logged';

  @override
  String historical_editing_date(String date) {
    return 'Editing $date';
  }

  @override
  String get historical_edit_expired => 'This study day is no longer editable.';

  @override
  String get edit_food_definition => 'Edit reusable food';

  @override
  String get food_definition_edit_helper =>
      'Serving description, weight, conversions, and nutrition update the reusable item and selected historical entry. You can also update matching entries in the current study day when available. Selected entry keeps its serving count.';

  @override
  String get nutrition_statistics_empty =>
      'No nutrition data is available yet.';

  @override
  String get nutrition_editable => 'Editable';

  @override
  String get nutrition_read_only => 'Read-only';

  @override
  String get nutrition_logging_guidance =>
      'Log each meal and drink as accurately as you can. Include portions and preparation details when you know them.';

  @override
  String get open_faq => 'Open FAQ';

  @override
  String get nutrition_calories => 'Calories';

  @override
  String get historical_edit_mode_heading => 'Editing a previous study day';

  @override
  String get historical_edit_mode_description =>
      'On this History screen, you can update the meal log from your previous study day. Foods and meals you create here remain available for future meal logs.';

  @override
  String get update_current_day_entries =>
      'Also update matching entries in current study day';

  @override
  String get update => 'Update';

  @override
  String get current_meal_only_banner =>
      'Changes apply only to this meal. For permanent changes, use Food Library.';

  @override
  String grams_per_serving(Object grams) {
    return '$grams g per serving';
  }

  @override
  String get open_food_facts_attribution => '(c) Open Food Facts contributors';

  @override
  String get open_food_facts_attribution_launch_error =>
      'Could not open the Open Food Facts terms of use.';

  @override
  String get food_definition_updated_current_day_opt_out =>
      'Reusable item updated. Matching entries in the current study day were not updated.';

  @override
  String get food_definition_updated_current_day_opt_in =>
      'Reusable item updated. Matching entries in the current study day were also updated.';

  @override
  String get food_quantity_weight_per_serving => 'Weight per serving';

  @override
  String food_quantity_total_weight(String weight) {
    return 'Total weight: $weight g';
  }

  @override
  String get food_quantity_decrease_weight => 'Decrease weight per serving';

  @override
  String get food_quantity_increase_weight => 'Increase weight per serving';

  @override
  String get food_selection_collapse => 'Collapse selected items';

  @override
  String get food_quantity_edit_amount => 'Edit amount';

  @override
  String food_quantity_nutrition_for_amount(Object amount, Object unit) {
    return 'Nutrition for $amount $unit';
  }

  @override
  String food_selection_items_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get nutrition_logged_foods_and_meals => 'Foods and saved meals';

  @override
  String get nutrition_add_food_or_saved_meal => 'Add food or saved meal';

  @override
  String get nutrition_add_food_or_choose_saved_meal =>
      'Add a food or choose a saved meal';

  @override
  String get nutrition_food_badge => 'Food';

  @override
  String get nutrition_saved_meal_badge => 'Saved meal';

  @override
  String nutrition_add_foods_or_saved_meals_to_meal(Object meal) {
    return 'Add foods or saved meals to $meal';
  }

  @override
  String get nutrition_search_foods_saved_meals_or_brands =>
      'Search foods, saved meals, or brands';

  @override
  String get nutrition_create_saved_meal => 'Create saved meal';

  @override
  String get nutrition_create_saved_meal_from_log =>
      'Create saved meal from this log';

  @override
  String get nutrition_edit_saved_meal => 'Edit saved meal';

  @override
  String nutrition_ingredients_section(Object count) {
    return 'Ingredients ($count)';
  }

  @override
  String get nutrition_add_food_ingredient => 'Add food ingredient';

  @override
  String get nutrition_invalid_saved_meal =>
      'This saved meal contains incomplete ingredients and cannot be saved. Add valid food ingredients and try again.';

  @override
  String get nutrition_saved_meals_filter => 'Saved meals';

  @override
  String nutrition_add_food_to_meal(Object meal) {
    return 'Add food to $meal';
  }

  @override
  String get nutrition_search_foods_or_brands => 'Search foods or brands';

  @override
  String get nutrition_saved_meals_expanded_notice =>
      'Saved meals were expanded into food ingredients for review. Your new saved meal will contain food ingredients only.';

  @override
  String get enter_meal_name => 'Please enter a meal name';

  @override
  String get nutrition_servings_required => 'Servings *';

  @override
  String get nutrition_preparation_details => 'Preparation details';

  @override
  String get nutrition_preparation_details_subtitle =>
      'Raw and cooked weights, preparation method';

  @override
  String get nutrition_raw_weight_grams => 'Raw weight (g)';

  @override
  String get nutrition_cooked_weight_grams => 'Cooked weight (g)';

  @override
  String get nutrition_preparation_method => 'Preparation method';

  @override
  String get nutrition_preparation_method_hint => 'e.g., baked, fried, steamed';

  @override
  String get nutrition_add_food_manually => 'Add food manually';

  @override
  String get nutrition_food_name_example => 'e.g., olive oil';

  @override
  String get nutrition_quantity_short => 'Qty';

  @override
  String get nutrition_calories_kcal => 'Calories (kcal)';

  @override
  String get nutrition_no_foods_yet => 'No foods yet';

  @override
  String get nutrition_search_or_add_food_manually =>
      'Search or add food manually to start';

  @override
  String get nutrition_unit_label => 'Unit';

  @override
  String get nutrition_per_serving => 'Nutrition per serving';

  @override
  String photoRecallDateInfo(Object date) {
    return 'Showing photos from $date';
  }
}

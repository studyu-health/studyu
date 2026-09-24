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
  String get browse_public_studies => 'Browse public studies';

  @override
  String get welcome_returning_participant =>
      'Already participated with StudyU?';

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
      'Some studies could not be displayed. This can happen when your app version is outdated. Please update the app to see all available studies, or join one of the studies shown below.';

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
  String get your_journey => 'Your journey';

  @override
  String get journey_overview_description =>
      'Review your study timeline before continuing.';

  @override
  String get journey_results_available => 'Results available';

  @override
  String get consent => 'Consent';

  @override
  String get error => 'An error occurred!';

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
  String get help => 'Help';

  @override
  String get contact => 'Contact';

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
  String get language => 'Language';

  @override
  String get use_device_language => 'Use device language';

  @override
  String get en => 'English';

  @override
  String get de => 'German';

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
  String get mean => 'mean';

  @override
  String get t_statistic => 't-statistic';

  @override
  String get degrees_of_freedom => 'Degrees of freedom';

  @override
  String get p_value => 'p-value';

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
  String get study_settings_section => 'Study settings';

  @override
  String get recovery_phrase_header => 'Recovery phrase';

  @override
  String get copied_to_clipboard =>
      'Copied to clipboard. Paste the recovery phrase somewhere secure on your phone now.';

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
  String get file_saved => 'File saved successfully';

  @override
  String get file_save_error => 'Error saving file';

  @override
  String get copy_btn => 'Copy';

  @override
  String get download_btn => 'Download';

  @override
  String get general_section => 'General';

  @override
  String get participation_options_section => 'Manage participation';

  @override
  String get recovery_phrase_load_error => 'Failed to load recovery phrase';

  @override
  String get deep_link_study_invite_only =>
      'This study requires an invite code to join';

  @override
  String deep_link_invite_invalid(String code) {
    return 'Invalid or expired invite code: $code';
  }

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
  String get questionnaire_review_title => 'Review your answers';

  @override
  String get questionnaire_review_description =>
      'You changed an earlier answer. Review your later answers before you complete the questionnaire.';

  @override
  String get questionnaire_review_confirmation => 'I reviewed my answers';

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
  String get date_picker_button_label => 'Choose date';

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
}

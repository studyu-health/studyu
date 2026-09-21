// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get studyu => 'StudyU';

  @override
  String get loading_message => '로딩 중...';

  @override
  String get language => '언어';

  @override
  String get language_select_tooltip => '언어 선택';

  @override
  String get locale_en => '영어';

  @override
  String get locale_de => '독일어';

  @override
  String get navlink_error_home => '홈으로 돌아가기';

  @override
  String get imprint => '법적 고지';

  @override
  String get link_forgot_password => '비밀번호를 잊으셨나요?';

  @override
  String get link_signup_description => '계정이 없으신가요?';

  @override
  String get link_signup => '회원가입';

  @override
  String get link_login_description => '이미 계정이 있나요?';

  @override
  String get link_login_description2 => '작업 공간에 로그인하시겠습니까?';

  @override
  String get link_login => '로그인';

  @override
  String get action_button_login => '로그인';

  @override
  String get action_button_signup => '계정 생성';

  @override
  String get action_button_password_reset => '비밀번호 재설정';

  @override
  String get signup_tos_intro => 'StudyU의 ';

  @override
  String get signup_tos_terms_of_service => '서비스 약관';

  @override
  String get signup_tos_and => ' 및 ';

  @override
  String get signup_tos_privacy_policy => '개인정보 처리방침';

  @override
  String get signup_tos_outro => '을 읽었으며 이에 동의합니다.';

  @override
  String get login_page_title => '작업 공간에 로그인';

  @override
  String get login_page_description => '디지털 N-of-1 연구로 연구를 가속화하세요.';

  @override
  String get signup_page_title => '작업 공간 생성';

  @override
  String get signup_page_description =>
      '연구 또는 임상 실습을 위해 디지털 N-of-1 연구를 시작하세요. 무료, 오픈소스 및 오픈 사이언스!';

  @override
  String get password_forgot_page_title => '비밀번호 재설정';

  @override
  String get password_forgot_page_description =>
      '계정과 연결된 이메일을 입력하면 비밀번호 재설정 방법이 포함된 이메일을 보내드립니다';

  @override
  String get password_recover_page_title => '새 비밀번호 설정';

  @override
  String get form_field_email => '이메일';

  @override
  String get form_field_email_hint => '이메일';

  @override
  String get form_field_password => '비밀번호';

  @override
  String get form_field_password_hint => '비밀번호';

  @override
  String get form_field_password_confirm => '비밀번호 확인';

  @override
  String get form_field_password_confirm_hint => '비밀번호를 다시 입력하세요';

  @override
  String get form_field_email_invalid => '유효한 이메일을 입력해야 합니다';

  @override
  String get form_field_password_mustmatch => '두 비밀번호가 일치해야 합니다';

  @override
  String form_field_password_minlength(num minLength) {
    return '비밀번호는 최소 $minLength자 이상이어야 합니다';
  }

  @override
  String get form_field_password_new => '새 비밀번호';

  @override
  String get form_field_password_new_hint => '새 비밀번호를 입력하세요';

  @override
  String get form_field_password_new_confirm => '새 비밀번호 확인';

  @override
  String get form_field_password_new_confirm_hint => '새 비밀번호를 다시 입력하세요';

  @override
  String get notification_password_reset_check_email =>
      '비밀번호 재설정 링크를 이메일에서 확인하세요!';

  @override
  String get notification_password_reset_success => '비밀번호가 성공적으로 재설정되었습니다';

  @override
  String get notification_credentials_invalid => '잘못된 자격 증명';

  @override
  String get notification_user_already_registered => '사용자가 이미 등록되었습니다';

  @override
  String get form_field_password_current => '현재 비밀번호';

  @override
  String get form_field_password_current_hint => '현재 비밀번호를 입력하세요';

  @override
  String get form_field_password_current_invalid => '현재 비밀번호가 잘못되었습니다';

  @override
  String get form_field_reset_password => '비밀번호 재설정';

  @override
  String get change_password => '비밀번호 변경';

  @override
  String get password_change_description => '계정의 새 비밀번호를 입력하세요';

  @override
  String get navlink_my_studies => '내 연구';

  @override
  String get navlink_shared_studies => '나와 공유됨';

  @override
  String get navlink_public_studies => '연구 등록부';

  @override
  String get navlink_public_studies_tooltip =>
      '연구 등록부는 StudyU 플랫폼에서 수행된 연구를 공개적으로 모아 놓은 곳입니다. 오픈 사이언스의 취지에 따라 플랫폼의 모든 연구자와 임상의 간 협업과 투명성을 촉진합니다.';

  @override
  String get navlink_public_studies_description =>
      '연구 등록부는 StudyU 플랫폼에서 수행된 연구를 공개적으로 모아 놓은 곳입니다. 오픈 사이언스의 취지에 따라 플랫폼의 모든 연구자와 임상의 간 협업과 투명성을 촉진합니다.';

  @override
  String get navlink_account_settings => '설정';

  @override
  String get navlink_logout => '로그아웃';

  @override
  String get date_format => '날짜 형식';

  @override
  String get time_format => '시간 형식';

  @override
  String get system => '시스템';

  @override
  String get date_format_iso => 'ISO (2024-12-31)';

  @override
  String get date_format_european => '유럽식 (31/12/2024)';

  @override
  String get date_format_us => '미국식 (12/31/2024)';

  @override
  String get date_format_german => '독일식 (31.12.2024)';

  @override
  String get time_format_12_hour => '12시간제 (오후 2:30)';

  @override
  String get time_format_24_hour => '24시간제 (14:30)';

  @override
  String get study_status_draft => '초안';

  @override
  String get study_status_draft_description => '이 연구는 아직 초안 단계입니다.';

  @override
  String get study_status_running => '진행 중';

  @override
  String get study_status_running_description => '이 연구는 현재 진행 중입니다.';

  @override
  String get study_status_closed => '신규 등록 마감';

  @override
  String get study_status_closed_description =>
      '이 연구의 신규 등록이 마감되었습니다.\n새로운 참가자는 더 이상 등록할 수 없습니다.';

  @override
  String get participation_open_who => '모두';

  @override
  String get participation_open_who_description =>
      '모든 StudyU 사용자는 StudyU 앱에서 연구에 등록할 수 있습니다.';

  @override
  String get participation_invite_who => '초대 전용';

  @override
  String get participation_invite_who_description =>
      '초대 코드를 받은 참여자만 StudyU 앱에서 연구에 등록할 수 있습니다.';

  @override
  String get participation_open_as_adjective => '모든 사람에게 공개됩니다';

  @override
  String get participation_invite_as_adjective => '초대받은 참가자에게만 공개됩니다';

  @override
  String get participation_open_launch_description =>
      '시작하면 StudyU 플랫폼의 모든 사용자가 심사 기준을 충족하면 연구에 등록할 수 있습니다.';

  @override
  String get participation_invite_launch_description =>
      '시작하면 참여자에게 코드 전송을 통해 연구에 접속하고 등록하도록 초대할 수 있습니다.';

  @override
  String get phase_sequence_alternating => '교대 (AB AB)';

  @override
  String get phase_sequence_counterbalanced => '역균형 (AB BA)';

  @override
  String get phase_sequence_random => '무작위';

  @override
  String get phase_sequence_custom => '사용자 지정';

  @override
  String get phase_sequence_custom_label => '사용자 지정 시퀀스';

  @override
  String get phase_sequence_custom_label_help => 'A와 B 문자를 사용하여 개입 시퀀스를 입력하세요';

  @override
  String get form_enrollment_option_open => '공개';

  @override
  String get form_enrollment_option_invite => '비공개(초대 전용)';

  @override
  String get notification_code_deleted => '초대 코드가 삭제되었습니다';

  @override
  String get notification_code_clipboard => '코드가 클립보드에 복사되었습니다';

  @override
  String get notification_invite_code_copied => '초대 코드가 복사되었습니다';

  @override
  String get notification_invite_link_copied => '초대 링크가 복사되었습니다';

  @override
  String get notification_invitation_copied => '초대장이 복사되었습니다';

  @override
  String get action_button_new_study => '새 연구';

  @override
  String get action_button_retry => '다시 시도';

  @override
  String get search => '검색';

  @override
  String get navlink_all_studies => '모든 연구';

  @override
  String get studies_list_header_title => '제목';

  @override
  String get studies_list_header_status => '상태';

  @override
  String get studies_list_header_participation => '참여';

  @override
  String get studies_list_header_created_at => '생성됨';

  @override
  String get studies_list_header_participants_enrolled => '등록됨';

  @override
  String get studies_list_header_participants_active => '활성';

  @override
  String get studies_list_header_participants_completed => '완료됨';

  @override
  String get studies_not_found => '연구를 찾을 수 없음';

  @override
  String get modify_query => '쿼리 수정';

  @override
  String studies_count_total(int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '연구 $total개',
      one: '연구 1개',
    );
    return '$_temp0';
  }

  @override
  String studies_count_filtered(int visible, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '연구 $total개',
      one: '연구 1개',
    );
    return '$_temp0 중 $visible개';
  }

  @override
  String get studies_filter_server_side_unsupported =>
      '현재 이 필터를 여기에서 사용할 수 없습니다. 필터를 지우고 다시 시도하세요.';

  @override
  String get studies_empty => '아직 연구가 없습니다';

  @override
  String get studies_empty_description =>
      '새로 연구를 처음부터 만들거나 이미 게시된 연구에서 새 초안 복사본을 만드세요!';

  @override
  String get studies_empty_public => '공개 연구를 찾을 수 없음';

  @override
  String get studies_empty_public_description => '현재 필터와 일치하는 연구가 공개 목록에 없습니다.';

  @override
  String get studies_empty_shared => '공유된 연구를 찾을 수 없음';

  @override
  String get studies_empty_shared_description => '아직 공유된 연구가 없습니다.';

  @override
  String get studies_end_of_list => '모든 연구를 불러왔습니다.';

  @override
  String get studies_load_failed => '연구를 불러올 수 없습니다. 다시 시도하세요.';

  @override
  String get navlink_learn => '배우기';

  @override
  String get navlink_study_design => '설계';

  @override
  String get navlink_study_test => '테스트';

  @override
  String get navlink_study_recruit => '모집';

  @override
  String get navlink_study_monitor => '모니터링';

  @override
  String get navlink_study_analyze => '분석';

  @override
  String get navlink_share => '공유';

  @override
  String get navlink_study_design_info => '연구 정보';

  @override
  String get navlink_study_design_enrollment => '참여';

  @override
  String get navlink_study_design_interventions => '중재';

  @override
  String get navlink_study_design_measurements => '측정';

  @override
  String get navlink_unavailable_tooltip => '이 페이지는 사용하실 수 없습니다';

  @override
  String get study_settings => '연구 설정';

  @override
  String get study_settings_publish_study => '연구 게시';

  @override
  String get study_settings_publish_study_tooltip =>
      '다른 연구자와 임상의는 연구 설계에 접근하고, 테스트하고, 검토하거나 복사본을 만들 수 있습니다. 진행 중인 연구의 참가자 데이터나 연구 결과에는 접근할 수 없습니다. 연구의 모집, 모니터링 및 분석 페이지도 사용할 수 없습니다.';

  @override
  String get study_settings_publish_study_launch_description =>
      '연구자와 임상의 간 협업을 촉진하기 위해 제 연구를 StudyU 연구 등록부에 게시하는 데 동의합니다. 다른 연구자와 임상의는 저에게 연락하고 연구 설계를 검토할 수 있지만, 제가 명시적으로 공유하지 않는 한 참가자 데이터나 결과 데이터에는 접근할 수 없습니다.';

  @override
  String get study_settings_publish_results => '결과 게시';

  @override
  String get study_settings_publish_results_tooltip =>
      '익명화된 연구 결과 및 데이터를 연구 등록부에 제공하세요. 다른 연구자와 임상가는 귀하의 연구 결과에 접근하고 내보내 분석할 수 있습니다(분석 페이지가 제공됩니다). 그러면 연구 설계도 연구 등록부에 자동으로 게시됩니다.';

  @override
  String get action_button_study_launch => '시작';

  @override
  String get action_button_study_close => '신규 등록 마감';

  @override
  String get notification_study_deleted => '연구가 삭제되었습니다';

  @override
  String get notification_study_closed => '신규 등록이 마감되었습니다';

  @override
  String get notification_study_closed_description =>
      '이 연구는 신규 등록이 마감되어 새로운 참가자를 받을 수 없습니다.';

  @override
  String get dialog_study_close_title => '신규 등록을 마감하시겠습니까?';

  @override
  String get dialog_study_close_description =>
      '이 연구의 신규 등록을 마감하시겠습니까? 신규 참가자는 더 이상 등록할 수 없지만 이미 등록한 참가자는 연구를 계속할 수 있습니다. 이 작업은 되돌릴 수 없습니다.';

  @override
  String get dialog_study_delete_title => '영구적으로 삭제하시겠습니까?';

  @override
  String get dialog_study_delete_description =>
      '이 연구를 삭제하면 연구 설정과 저장된 모든 연구 데이터가 영구적으로 제거됩니다.';

  @override
  String get dialog_study_delete_warning_intro =>
      '삭제하기 전에 백업을 저장하고 신규 등록 마감만으로 충분한지 검토해 주세요.';

  @override
  String get dialog_study_delete_backup_step =>
      '삭제하기 전에 연구 정의와 수집된 데이터를 백업으로 저장하세요.';

  @override
  String get dialog_study_delete_close_step => '신규 등록을 마감하되 연구와 기존 데이터는 유지합니다.';

  @override
  String get dialog_study_delete_download_backup => '백업 다운로드';

  @override
  String get dialog_study_delete_data_confirmation =>
      '연구와 관련된 모든 데이터가 영구적으로 삭제되며 다시 복구할 수 없음을 이해합니다.';

  @override
  String get dialog_study_delete_participant_confirmation =>
      '현재 참가자는 연구를 계속할 수 없으며, 현재 및 이전 참가자의 모든 데이터가 삭제되어 참가자와 저 모두 더 이상 접근할 수 없음을 이해합니다.';

  @override
  String get dialog_study_delete_irreversible_confirmation =>
      '제 결정이 최종적이며 되돌릴 수 없으며, 모든 데이터가 완전히 삭제되어 다시 복원할 수 없음을 이해합니다.';

  @override
  String get dialog_study_delete_data_confirmation_emphasis_1 => '영구적으로 삭제됨';

  @override
  String get dialog_study_delete_data_confirmation_emphasis_2 => '다시 복구할 수 없음';

  @override
  String get dialog_study_delete_participant_confirmation_emphasis_1 =>
      '현재 참가자들이 계속할 수 없음';

  @override
  String get dialog_study_delete_participant_confirmation_emphasis_2 =>
      '현재 및 이전 참가자들의 모든 데이터';

  @override
  String get dialog_study_delete_irreversible_confirmation_emphasis_1 =>
      '최종적이며 되돌릴 수 없음';

  @override
  String get dialog_study_delete_irreversible_confirmation_emphasis_2 =>
      '다시 복원할 수 없음';

  @override
  String dialog_study_delete_type_name_instruction(Object studyName) {
    return '삭제를 확인하려면 연구 이름 입력란에 다음을 입력하세요: \"$studyName\".';
  }

  @override
  String get dialog_study_delete_type_name_label => '연구 이름';

  @override
  String dialog_study_close_type_name_instruction(Object studyName) {
    return '신규 등록 마감을 확인하려면 다음 연구 제목을 입력해 주세요: \"$studyName\"';
  }

  @override
  String get dialog_study_close_type_name_label => '신규 등록을 마감할 연구 제목';

  @override
  String get dialog_study_close_irreversible_confirmation =>
      '신규 등록 마감은 최종 결정이며 되돌릴 수 없음을 이해합니다.';

  @override
  String get dialog_study_delete_close_instead => '삭제 대신 신규 등록 마감 검토';

  @override
  String get dialog_study_title_mismatch => '연구 제목이 일치하지 않습니다.';

  @override
  String dialog_delete_title(Object subject) {
    return '$subject 삭제?';
  }

  @override
  String dialog_delete_description(Object subject) {
    return '$subject을(를) 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String dialog_remove_title(Object subject) {
    return '$subject 제거?';
  }

  @override
  String dialog_remove_description(Object subject) {
    return '$subject을(를) 제거하시겠습니까? 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get dialog_subject_study => '연구';

  @override
  String get dialog_subject_item => '항목';

  @override
  String get dialog_subject_question => '질문';

  @override
  String get dialog_subject_screener_question => '선별 질문';

  @override
  String get dialog_subject_answer_option => '답변 옵션';

  @override
  String get dialog_subject_intervention => '개입';

  @override
  String get dialog_subject_intervention_task => '중재 과제';

  @override
  String get dialog_subject_survey => '설문조사';

  @override
  String get dialog_subject_consent_item => '동의 항목';

  @override
  String get dialog_subject_report_section => '보고서 섹션';

  @override
  String get dialog_subject_invite_code => '초대 코드';

  @override
  String get dialog_delete_invite_code_title => '초대 코드를 삭제할까요?';

  @override
  String dialog_delete_invite_code_message(Object code) {
    return '초대 코드 $code를 가진 사람은 더 이상 이 코드를 사용할 수 없습니다.';
  }

  @override
  String get dialog_subject_fitbit_credentials => 'Fitbit 자격 증명';

  @override
  String get form_question_create => '새로운 질문';

  @override
  String get form_question_edit => '질문 편집';

  @override
  String get form_question_readonly => '질문 보기';

  @override
  String get form_field_question => '귀하의 질문';

  @override
  String get form_field_question_tooltip => '참가자에게 앱에서 안내될 질문을 입력하세요';

  @override
  String get form_field_question_required => '질문은 비워둘 수 없습니다';

  @override
  String get form_field_question_help_text => '질문 도움말 텍스트';

  @override
  String get form_field_question_help_text_tooltip =>
      '앱에서 질문 옆에 도움말 아이콘과 함께 표시되는 텍스트를 입력하세요';

  @override
  String get form_field_question_help_text_hint =>
      '질문에 대한 추가적인 맥락, 도움말 또는 지침을 제공하세요';

  @override
  String get form_field_question_help_text_add => '도움말 텍스트 추가';

  @override
  String get form_field_question_help_text_add_tooltip =>
      '앱에서 질문 옆에 있는 도움말 아이콘과 함께 표시되는 텍스트를 추가하세요';

  @override
  String get form_field_question_response_options => '응답 옵션';

  @override
  String get form_field_question_response_options_tooltip =>
      '참가자가 질문에 답할 수 있는 옵션을 정의하세요';

  @override
  String get form_field_question_response_options_description =>
      '질문에 가장 적합한 응답 유형을 선택하고 수집하려는 데이터에 따라 응답 옵션을 정의하세요.';

  @override
  String get question_type_choice => '객관식';

  @override
  String get question_type_free_text => '자유 입력';

  @override
  String get question_type_pain => '통증 추적기';

  @override
  String get question_type_pain_description =>
      '참가자는 다이어그램에서 하나 이상의 신체 부위를 선택하고 각 선택한 부위에 대해 통증 수준을 통증 척도로 지정할 수 있습니다. 이는 국소적인 통증을 추적하는 데 유용합니다.';

  @override
  String get question_type_pain_preview_title => '앱 내 미리보기';

  @override
  String get question_type_pain_preview_description =>
      '아래는 StudyU 앱에서 참여자에게 통증 선택 인터페이스가 어떻게 나타날지에 대한 간단한 예시입니다. 참여자는 신체 부위를 탭하여 선택한 후 통증 수준을 지정할 수 있습니다.';

  @override
  String get question_type_pain_front_view => '앞쪽 보기';

  @override
  String get question_type_pain_back_view => '뒤쪽 보기';

  @override
  String get question_type_pain_functionality_title => '기능';

  @override
  String get question_type_pain_functionality_description =>
      '참가자가 신체 부위를 탭하면 통증 수준을 선택할 수 있는 대화 상자가 나타납니다. 선택된 각 신체 부위에는 서로 다른 통증 수준을 지정할 수 있습니다. 수집된 데이터에는 식별된 신체 부위와 해당 통증 점수가 포함됩니다.';

  @override
  String get question_type_bool => '예/아니오';

  @override
  String get question_type_scale => '척도';

  @override
  String get question_type_image => '이미지';

  @override
  String get question_type_audio => '오디오';

  @override
  String get question_type_fitbit => 'Fitbit';

  @override
  String get form_array_response_options_bool_yes => '예';

  @override
  String get form_array_response_options_bool_no => '아니오';

  @override
  String get form_field_response_pain => '통증 추적기';

  @override
  String get form_field_response_image => '이미지';

  @override
  String get form_field_response_audio => '오디오';

  @override
  String get form_field_response_audio_max_duration_label => '최대 녹음 시간 (초)';

  @override
  String get form_field_response_choice_multiple => '다중 선택';

  @override
  String get form_field_response_choice_multiple_tooltip =>
      '참가자가 여러 응답 옵션을 선택할 수 있도록 허용합니다. 그렇지 않으면 단일 옵션만 선택할 수 있습니다.';

  @override
  String get form_field_response_choice_required => '하나 이상 선택 필수';

  @override
  String get form_field_response_choice_required_tooltip =>
      '참여자가 응답 옵션을 하나 이상 선택하도록 요구합니다.';

  @override
  String get form_array_response_options_choice_new => '옵션 추가';

  @override
  String get form_array_response_options_choice_hint => '옵션';

  @override
  String get form_field_response_scale_min_label => '사용자 지정 최솟값 레이블';

  @override
  String get form_field_response_scale_min_label_tooltip =>
      '척도에서 값의 위치에 표시할 사용자 정의 레이블 입력';

  @override
  String get form_field_response_scale_min_value => '최솟값';

  @override
  String get form_field_response_scale_max_label => '사용자 지정 최댓값 레이블';

  @override
  String get form_field_response_scale_max_label_tooltip =>
      '척도에서 값의 위치에 표시할 사용자 정의 레이블 입력';

  @override
  String get form_field_response_scale_max_value => '최댓값';

  @override
  String get form_field_response_scale_label_hint => '선택적 레이블';

  @override
  String get form_array_response_scale_mid_values => '중간값을 참조하십시오.';

  @override
  String get form_array_response_scale_mid_values_dirty_banner =>
      '중간값과 라벨은 척도의 최저값과 최고값을 반영하도록 자동으로 초기화됩니다.';

  @override
  String get form_field_response_scale_colors_add => '시작 및 종료 색상 추가';

  @override
  String get form_field_response_scale_color_add => '색상 추가';

  @override
  String get form_field_response_scale_color_min => '최솟값 색상';

  @override
  String get form_field_response_scale_color_max => '최댓값 색상';

  @override
  String get form_field_response_scale_color_tooltip =>
      '앱에 표시되는 척도의 사용자 정의 색상 설정';

  @override
  String get navlink_question_visuals => '시각 자료';

  @override
  String get navlink_question_visuals_description =>
      '앱에서 질문의 모양과 느낌을 원하는 대로 맞춤 설정하세요. 이것은 수집되는 데이터를 변경하지는 않지만, 연구 참여자를 시각적으로 안내하는 데 도움이 될 수 있습니다.';

  @override
  String form_array_response_options_choice_countmin(num count) {
    return '질문에는 최소 $count개의 비어 있지 않은 응답 옵션이 있어야 합니다';
  }

  @override
  String form_array_response_options_choice_countmax(num count) {
    return '질문에는 최대 $count개의 비어 있지 않은 응답 옵션만 있어야 합니다';
  }

  @override
  String get form_array_response_options_scale_rangevalid_min =>
      '척도의 최고값은 최저값보다 커야 합니다.';

  @override
  String form_array_response_options_scale_rangevalid_max(num count) {
    return '척도의 최고값과 최저값 사이의 최대 차이는 $count 이하여야 합니다.';
  }

  @override
  String get audio_recording_max_duration_rangevalid_min => '최소 녹음 시간은 1초입니다';

  @override
  String audio_recording_max_duration_rangevalid_max(num count) {
    return '최대 녹음 시간은 $count초입니다';
  }

  @override
  String get free_text_question_logic_not_supported =>
      '자유 텍스트 질문에 대한 스크리너 질문 로직은 아직 지원되지 않습니다.';

  @override
  String get free_text_question_type_any => '모든 텍스트';

  @override
  String get free_text_question_type_alphanumeric => '영숫자';

  @override
  String get free_text_question_type_numeric => '숫자';

  @override
  String get free_text_question_type_custom => '사용자 정의';

  @override
  String get free_text_range_label => '허용되는 텍스트 길이 범위';

  @override
  String get free_text_range_label_helper => '답변에 허용되는 최소 및 최대 문자 수를 입력하십시오.';

  @override
  String get free_text_type_label => '허용된 텍스트 유형';

  @override
  String get free_text_type_label_helper => '답변에 허용되는 텍스트 유형을 선택하세요';

  @override
  String get free_text_type_custom_label => '정규 표현식';

  @override
  String get free_text_type_custom_label_helper => '답변이 일치해야 하는 정규식을 입력하세요';

  @override
  String get free_text_type_custom_helper => '예: 문자만 허용하려면 [a-zA-Z]+를 입력하십시오.';

  @override
  String get free_text_type_custom_explanation =>
      '표현식과 일치하지 않는 모든 입력은 거부됩니다. 위에 지정된 입력 길이 제한은 여전히 적용됩니다. 시작 ^와 끝 \$ 문자가 자동으로 추가됩니다.';

  @override
  String get free_text_example_label => '예시 텍스트 필드';

  @override
  String get free_text_example_label_helper =>
      '이것은 참가자에게 보여질 텍스트 필드의 예시입니다. 위에서 지정한 길이와 입력 유형 제약 조건이 적용됩니다.';

  @override
  String get free_text_example_valid => '입력한 예시가 유효합니다.';

  @override
  String get free_text_example_default_helper => '여기에 텍스트를 입력하여 검증 테스트를 수행하세요.';

  @override
  String free_text_validation_min_length(num countMin) {
    return '입력은 최소 $countMin자여야 합니다.';
  }

  @override
  String free_text_validation_max_length(num countMax) {
    return '입력은 최대 $countMax자여야 합니다.';
  }

  @override
  String get free_text_validation_pattern => '입력은 지정된 형식과 일치해야 합니다.';

  @override
  String get free_text_validation_number => '입력은 숫자여야 합니다.';

  @override
  String free_text_example_explanation(
    String type,
    num countMin,
    num countMax,
  ) {
    return '문자 길이가 $countMin부터 $countMax까지인 $type 유형의 입력이 허용됩니다.';
  }

  @override
  String free_text_example_explanation_custom(String type) {
    return '$type 유형의 입력은 정규 표현식 패턴에 따라 허용됩니다.';
  }

  @override
  String get free_text_question_type_any_explanation => '모든 입력이 허용됩니다.';

  @override
  String get free_text_question_type_alphanumeric_explanation =>
      '영숫자 입력에는 문자와 숫자만 포함됩니다.';

  @override
  String get free_text_question_type_numeric_explanation =>
      '숫자 입력에는 특수 문자가 없는 숫자만 포함됩니다.';

  @override
  String get free_text_question_type_custom_explanation =>
      '입력은 지정된 정규 표현식과 일치해야 합니다.';

  @override
  String get question_type_date => '날짜/시간';

  @override
  String get date_min_date_label => '가장 이른 날짜';

  @override
  String get date_min_date_label_helper => '참가자가 선택할 수 있는 가장 이른 날짜';

  @override
  String get date_max_date_label => '가장 늦은 날짜';

  @override
  String get date_max_date_label_helper => '참가자가 선택할 수 있는 가장 늦은 날짜';

  @override
  String get date_picker_hint => '날짜를 선택하세요';

  @override
  String get time_picker_hint => '시간 선택';

  @override
  String get date_input_type_label => '입력 유형';

  @override
  String get date_input_type_label_helper => '수집할 정보 선택';

  @override
  String get date_input_type_date => '날짜만';

  @override
  String get date_input_type_time => '시간만';

  @override
  String get date_input_type_datetime => '날짜와 시간';

  @override
  String get date_default_option_label => '기본값';

  @override
  String get date_default_option_label_helper => '참여자에게 표시될 초기 값을 선택하세요.';

  @override
  String get date_default_option_none => '기본 없음';

  @override
  String get date_default_option_today => '오늘';

  @override
  String get date_default_option_now => '현재 시간';

  @override
  String get date_default_option_specific => '특정 날짜/시간';

  @override
  String get date_default_specific_date_label => '기본 날짜';

  @override
  String get date_default_specific_date_label_helper => '미리 선택될 날짜';

  @override
  String get date_default_specific_time_label => '기본 시간';

  @override
  String get date_default_specific_time_label_helper => '미리 선택될 시간';

  @override
  String get date_min_time_label => '가장 이른 시간';

  @override
  String get date_min_time_label_helper => '참가자가 선택할 수 있는 가장 이른 시간';

  @override
  String get date_max_time_label => '가장 늦은 시간';

  @override
  String get date_max_time_label_helper => '참가자가 선택할 수 있는 가장 늦은 시간';

  @override
  String get date_validation_min_greater_than_max =>
      '가장 이른 날짜가 가장 늦은 날짜 이후일 수 없습니다';

  @override
  String get date_picker_button_label_datetime => '날짜 선택';

  @override
  String get time_picker_button_label_datetime => '시간 선택';

  @override
  String get time_picker_button_label => '시간을 선택하세요';

  @override
  String get date_picker_validation_required => '날짜를 선택해 주세요';

  @override
  String get time_picker_validation_required => '시간을 선택하세요';

  @override
  String get datetime_picker_validation_required => '날짜와 시간을 모두 선택해 주세요';

  @override
  String get time_picker_validation_range => '허용된 범위 내에서 시간을 선택하세요';

  @override
  String time_picker_range_hint(Object min, Object max) {
    return '$min~$max 사이의 시간을 선택하세요';
  }

  @override
  String time_picker_min_hint(Object min) {
    return '허용되는 가장 이른 시간: $min';
  }

  @override
  String time_picker_max_hint(Object max) {
    return '허용되는 가장 늦은 시간: $max';
  }

  @override
  String get date_validation_default_today_before_min =>
      '\'오늘\'이 허용된 가장 이른 날짜 이전입니다';

  @override
  String get date_validation_default_today_after_max =>
      '\'오늘\'이 허용된 가장 늦은 날짜 이후입니다';

  @override
  String get date_validation_default_specific_before_min =>
      '기본 날짜가 허용된 가장 이른 날짜 이전입니다';

  @override
  String get date_validation_default_specific_after_max =>
      '기본 날짜가 허용된 가장 늦은 날짜 이후입니다';

  @override
  String get fitbit_question_title => 'Fitbit';

  @override
  String get fitbit_question_type_empty => '사용할 수 있는 Fitbit 데이터가 없습니다';

  @override
  String get navlink_question_visibility_logic => '가시성';

  @override
  String get form_array_question_visibility_logic_title => '가시성 로직';

  @override
  String get form_array_question_visibility_logic_question_tooltip =>
      '이 질문은 가시성 로직이 정의되어 있습니다. 조건이 충족될 경우에만 참가자에게 표시됩니다.';

  @override
  String get form_array_question_visibility_logic_description =>
      '이 질문의 가시성 로직을 정의하세요. 조건이 충족될 경우에만 참가자에게 질문이 표시됩니다.';

  @override
  String get form_array_question_visibility_logic_tooltip =>
      '조건은 연구의 다른 질문에 대한 응답을 기반으로 합니다. 현재 질문 다음에 나오는 질문만 가시성 로직에 사용할 수 있습니다.';

  @override
  String get form_array_question_visibility_logic_grouping_title => '조건 결합';

  @override
  String get form_array_question_visibility_logic_grouping_and_title => '그리고';

  @override
  String get form_array_question_visibility_logic_grouping_or_title => '또는';

  @override
  String get from_array_question_visibility_logic_no_conditions =>
      '아직 정의된 조건이 없습니다.';

  @override
  String get form_array_question_visibility_logic_question_title => '질문';

  @override
  String get form_array_question_visibility_logic_comparator_title => '비교기';

  @override
  String get form_array_question_visibility_logic_true => '참';

  @override
  String get form_array_question_visibility_logic_false => '거짓';

  @override
  String get form_array_question_visibility_logic_value_title => '값';

  @override
  String get form_array_question_visibility_logic_add_condition_button =>
      '조건 추가';

  @override
  String
  get form_array_question_visibility_logic_add_condition_disabled_tooltip =>
      '조건을 추가할 수 있는 질문이 없습니다. 현재 질문 이후의 질문만 가시성 로직에 사용할 수 있습니다.';

  @override
  String get form_array_question_visibility_logic_is_true => '참입니다';

  @override
  String get form_array_question_visibility_logic_is_false => '거짓입니다';

  @override
  String get form_array_question_visibility_logic_is => '입니다';

  @override
  String get form_array_question_visibility_logic_is_not => '아닙니다';

  @override
  String get form_array_question_visibility_logic_contains => '포함';

  @override
  String get form_array_question_visibility_logic_does_not_contain => '포함하지 않음';

  @override
  String get form_array_question_visibility_logic_shorter_than => '보다 짧다';

  @override
  String get form_array_question_visibility_logic_shorter_than_or_equal_to =>
      '이하';

  @override
  String get form_array_question_visibility_logic_longer_than => '보다 길다';

  @override
  String get form_array_question_visibility_logic_longer_than_or_equal_to =>
      '이상';

  @override
  String get form_array_question_visibility_logic_same_length_as => '동일한 길이';

  @override
  String get form_array_question_visibility_logic_different_length_as =>
      '길이가 다름';

  @override
  String get form_array_question_visibility_logic_length_greater_than => '길이 >';

  @override
  String get form_array_question_visibility_logic_length_less_than => '길이 <';

  @override
  String
  get form_array_question_visibility_logic_length_greater_than_or_equal =>
      '길이 >=';

  @override
  String get form_array_question_visibility_logic_length_less_than_or_equal =>
      '길이 <=';

  @override
  String get form_array_question_visibility_logic_not => '아님';

  @override
  String get form_array_question_visibility_logic_always_true => '항상 참';

  @override
  String get form_array_question_visibility_logic_preview_description =>
      '다음 조건이 충족될 경우 이 질문을 표시합니다:';

  @override
  String get form_array_question_visibility_logic_unknown_expression =>
      '알 수 없는 표현';

  @override
  String get form_array_question_visibility_logic_this_question => '이 질문';

  @override
  String get form_mode_visibility_create => '조건 생성';

  @override
  String get form_mode_visibility_edit => '조건 편집';

  @override
  String get form_mode_visibility_readonly => '조건 보기';

  @override
  String get validation_number_required => '값은 숫자여야 합니다';

  @override
  String get banner_study_readonly_title => '이 연구는 편집할 수 없습니다.';

  @override
  String get banner_study_readonly_description =>
      '자신이 소유자 또는 협력자인 연구에서만 변경할 수 있습니다. 이미 시작된 연구는 누구도 변경할 수 없습니다.';

  @override
  String get banner_study_closed_title => '이 연구는 신규 등록이 마감되었습니다.';

  @override
  String get banner_study_closed_description =>
      '이 연구는 신규 등록이 마감되어 새로운 참가자를 받을 수 없습니다.';

  @override
  String get form_section_scheduling => '일정 및 준수';

  @override
  String get form_section_scheduling_description =>
      '준수를 개선하기 위해 참가자가 과제를 완료할 수 있는 제한된 시간을 설정하고 지정된 시간에 알림을 보낼 수 있습니다.';

  @override
  String get form_field_has_reminder => '앱 알림';

  @override
  String get form_field_has_reminder_tooltip =>
      '지정된 시간에 참가자의 휴대폰으로 StudyU 앱에서 알림을 전송하려면 이 옵션을 선택하세요.';

  @override
  String get form_field_has_reminder_label => '알림 전송';

  @override
  String get form_field_time_of_day_hint => 'hh:mm';

  @override
  String get form_field_time_restriction => '시간 제한';

  @override
  String get form_field_time_restriction_tooltip =>
      '참가자가 작업을 완료해야 하는 시간대를 제공하세요. 이 시간 외에는 작업을 완료할 수 없으며 데이터 수집 목적으로 누락된 것으로 간주됩니다.';

  @override
  String get form_field_time_restriction_start_hint => '~부터';

  @override
  String get form_field_time_restriction_end_hint => '~까지';

  @override
  String get form_study_design_info_description =>
      '연구에 대한 일반 정보를 참가자에게 제공하십시오. 연구 등록부에 연구를 공개하기로 결정하면 이 정보는 다른 연구자와 임상가에게도 제공됩니다.';

  @override
  String get form_field_study_title => '연구 제목';

  @override
  String get form_field_study_title_tooltip => 'StudyU 앱에 표시될 연구 제목을 제공하세요';

  @override
  String get form_field_study_title_required => '연구 제목은 비어 있을 수 없습니다';

  @override
  String get form_field_study_title_default => '이름 없는 연구';

  @override
  String get form_field_study_description => '설명';

  @override
  String get form_field_study_description_tooltip =>
      '연구 참여자에게 연구에 대한 간단한 요약을 제공하세요';

  @override
  String get form_field_study_description_hint =>
      '연구 참여자에게 연구에 대한 간단한 요약을 제공하세요';

  @override
  String get form_field_study_description_required => '연구 설명은 비어 있을 수 없습니다';

  @override
  String get form_field_study_tags => '태그';

  @override
  String get form_field_study_tags_hint => '태그를 작성하고 Enter 키를 누르세요';

  @override
  String get form_field_study_tags_tooltip =>
      '다른 연구자와 임상의가 연구를 더 쉽게 찾을 수 있도록 연구에 태그를 추가하세요';

  @override
  String form_field_study_tags_error_length(Object count) {
    return '연구에는 최대 $count개의 태그만 추가할 수 있습니다';
  }

  @override
  String form_field_study_tags_helper(Object count) {
    return '목록에서 최대 $count개의 태그를 선택하거나 직접 추가하세요';
  }

  @override
  String get form_field_study_icon_required => '연구에 사용할 아이콘을 선택해야 합니다';

  @override
  String get form_section_publisher => '게시자 및 연락처 정보';

  @override
  String get form_section_publisher_description =>
      '참가자는 이 정보를 사용하여 StudyU 앱을 통해 귀하에게 연락할 수 있습니다. 다른 임상 의사나 연구원은 귀하가 연구를 연구 등록부에 게시하는 것에 동의한 경우에만 연락할 수 있습니다.';

  @override
  String get form_field_organization => '책임 기관';

  @override
  String get form_field_organization_required => '책임 있는 조직은 비워둘 수 없습니다';

  @override
  String get form_field_review_board => '기관심사위원회';

  @override
  String get form_field_review_board_required => '연구에 대한 책임 심사위원회를 지정해야 합니다';

  @override
  String get form_field_review_board_number => '기관심사위원회 프로토콜 번호';

  @override
  String get form_field_review_board_number_required =>
      '연구를 위해 심사위원회 프로토콜 번호를 제공해야 합니다';

  @override
  String get form_field_researchers => '담당자';

  @override
  String get form_field_researchers_required => '연구를 담당하는 연구자를 지정해야 합니다';

  @override
  String get form_field_website => '웹사이트';

  @override
  String get form_field_website_pattern => '유효한 연락처 웹사이트 URL을 입력하세요';

  @override
  String get form_field_contact_email => '이메일';

  @override
  String get form_field_contact_email_required => '연락 가능한 이메일을 지정해야 합니다';

  @override
  String get form_field_contact_email_email => '유효한 연락용 이메일 주소를 입력하세요';

  @override
  String get form_field_contact_phone => '전화';

  @override
  String get form_field_contact_phone_required =>
      '참가자가 연락할 수 있는 전화번호를 지정해야 합니다';

  @override
  String get form_field_contact_additional_info => '추가 정보';

  @override
  String get form_study_design_enrollment_description =>
      '누가 연구에 참여할 수 있는지, 충족해야 하는 기준 및 동의해야 하는 조건을 정의합니다.';

  @override
  String get form_field_enrollment_type => '참가자 풀';

  @override
  String get form_field_enrollment_type_open_description =>
      '귀하의 연구는 (있다면) 스크리닝 기준에 맞는 모든 StudyU 플랫폼 사용자가 등록할 수 있도록 열립니다.';

  @override
  String get form_field_enrollment_type_invite_description =>
      '선택된 참가자만 지정된 초대 코드를 사용하여 연구에 등록할 수 있습니다. 미리 선택된 참가자 풀이 있는 경우 이 옵션을 선택하세요.';

  @override
  String get form_array_screener_questions_title => '스크리닝 기준';

  @override
  String get form_array_screener_questions_description =>
      '선택적 스크리너 질문은 잠재적 참가자가 연구에 참여할 자격이 있는지 결정하는 데 도움을 줄 수 있습니다. 초대 전용 연구의 경우, 참가자를 수동으로 자격 심사하고 모집한 후 StudyU에 초대한다면 스크리닝 질문을 추가하지 않아도 됩니다.';

  @override
  String get form_array_screener_questions_new => '스크리너 질문 추가';

  @override
  String get form_array_screener_questions_test => '스크리너 테스트';

  @override
  String get form_array_consent_items_title => '참가자 동의';

  @override
  String get form_array_consent_items_description =>
      '참가자가 StudyU 앱을 통해 연구에 등록할 때 동의해야 하는 조건을 입력하세요. StudyU에서 연구 참여자를 모집하기 전에 다른 방법으로 참가자의 동의를 받는 경우에는 여기에 조건을 추가하지 않아도 됩니다.';

  @override
  String get form_array_consent_items_new => '동의 문구 추가';

  @override
  String get form_array_consent_items_test => '동의 테스트';

  @override
  String get form_screener_question_create => '새로운 스크리너 질문';

  @override
  String get form_screener_question_edit => '스크리너 질문 편집';

  @override
  String get form_screener_question_readonly => '스크리너 질문 보기';

  @override
  String get form_screener_question_logic_qualify => '자격 부여';

  @override
  String get form_screener_question_logic_disqualify => '자격 박탈';

  @override
  String get navlink_screener_question_content => '콘텐츠';

  @override
  String get navlink_screener_question_logic => '선별';

  @override
  String get form_array_screener_question_logic_title => '심사 규칙';

  @override
  String get form_array_screener_question_logic_description =>
      '참가자가 연구에 등록할 자격이 있는지 없는지를 결정하는 응답을 정의하십시오. 참가자로 자격이 되려면, 이 심사 설문에서 적어도 하나의 유자격 응답 옵션이 선택되고, 어느 불자격 응답 옵션도 선택되지 않아야 합니다.';

  @override
  String get form_array_screener_question_logic_tooltip =>
      '참가자가 선택했을 때 어떤 응답 옵션이 적격 또는 부적격인지를 정의합니다.';

  @override
  String get form_array_screener_question_logic_dirty_banner =>
      '여기에서 보이는 옵션은 사용 가능한 응답을 반영하도록 자동으로 초기화됩니다. 모든 옵션은 명시적으로 불자격으로 표시하지 않는 한 기본적으로 유자격입니다.';

  @override
  String get form_consent_create => '새 참가자 동의';

  @override
  String get form_consent_edit => '참가자 동의 수정';

  @override
  String get form_consent_readonly => '참가자 동의 보기';

  @override
  String get form_field_consent_title => '제목';

  @override
  String get form_field_consent_title_tooltip =>
      '참가자가 읽고 동의해야 하는 약관의 짧은 제목을 입력하세요.\n각 동의 텍스트에 대해 제목과 아이콘이 포함된 카드가 앱 동의 화면에 표시됩니다.';

  @override
  String get form_field_consent_title_hint => '짧은 제목을 입력하세요';

  @override
  String get form_field_consent_title_required => '참가자 동의에 대한 제목을 제공해야 합니다';

  @override
  String get form_field_consent_text => '텍스트';

  @override
  String get form_field_consent_text_tooltip =>
      '참가자가 연구에 등록할 때 읽고 동의해야 하는 약관을 입력하세요. \n약관은 앱의 동의 화면에서 해당 카드를 클릭하면 표시됩니다.';

  @override
  String get form_field_consent_text_hint => '읽고 동의해야 하는 전체 약관을 입력하세요';

  @override
  String get form_field_consent_text_required => '참가자 동의용 텍스트는 비워둘 수 없습니다';

  @override
  String get form_study_design_interventions_description =>
      '연구할 중재의 여러 단계와 그 순서 및 빈도를 정의하세요. N-of-1 시험에서는 한 참가자가 미리 정한 순서에 따라 중재 단계를 한 번 또는 여러 번 거칩니다(다중 교차 시험). 각 중재는 해당 단계에서 수행하는 하나 이상의 중재 과제로 구성됩니다.\n\n참고: 중재를 세 개 이상 지정하면 참가자는 연구를 시작할 때 비교할 중재 두 개를 자유롭게 선택할 수 있습니다.';

  @override
  String get link_n_of_1_learn_more => 'N-of-1 연구에 대해 더 알아보기';

  @override
  String get link_n_of_1_learn_more_url =>
      'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3118090/pdf/nihms297482.pdf';

  @override
  String form_array_interventions_minlength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '비교할 중재를 최소 두 개 정의해야 합니다.',
      two: '비교할 중재를 최소 두 개 정의해야 합니다.',
    );
    return '$_temp0';
  }

  @override
  String get form_array_interventions => '중재 단계';

  @override
  String get form_array_interventions_new => '중재 추가';

  @override
  String get form_array_interventions_empty_title => '정의된 중재가 없습니다';

  @override
  String get form_array_interventions_empty_description =>
      '비교할 중재를 최소 두 개 정의해야 합니다.';

  @override
  String get form_field_intervention_title => '제목';

  @override
  String get form_field_intervention_title_required => '중재 제목은 비워둘 수 없습니다';

  @override
  String get form_field_intervention_title_default => '이름 없는 중재';

  @override
  String get form_field_intervention_title_tooltip =>
      'StudyU 앱에 표시될 개입 단계의 제목을 제공하십시오';

  @override
  String get form_field_intervention_description => '설명';

  @override
  String get form_field_intervention_description_tooltip =>
      '중재 단계가 시작될 때 또는 참가자가 연구 계획에서 해당 단계를 클릭할 때 표시되는 설명 텍스트를 입력합니다';

  @override
  String get form_field_intervention_description_hint => '참가자에게 중재 단계를 설명합니다';

  @override
  String get form_array_intervention_tasks => '중재 과제';

  @override
  String get form_array_intervention_tasks_description =>
      '참가자가 이 중재 단계에서 완료해야 하는 하나 이상의 과제를 정의합니다. StudyU 앱은 참가자에게 매일 이 과제를 완료하도록 안내합니다.';

  @override
  String get form_array_intervention_tasks_new => '중재 과제 추가';

  @override
  String get form_array_intervention_tasks_empty_title => '정의된 중재 과제가 없습니다';

  @override
  String get form_array_intervention_tasks_empty_description =>
      '이 중재 단계에서 참가자가 완료할 과제를 최소 하나 정의해야 합니다.';

  @override
  String form_array_intervention_tasks_minlength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이 중재 단계에서 참가자가 완료할 과제를 최소 하나 정의해야 합니다.',
      one: '이 중재 단계에서 참가자가 완료할 과제를 최소 하나 정의해야 합니다.',
    );
    return '$_temp0';
  }

  @override
  String get form_intervention_task_create => '새 중재 과제';

  @override
  String get form_intervention_task_edit => '중재 과제 편집';

  @override
  String get form_intervention_task_readonly => '중재 과제 보기';

  @override
  String get form_field_intervention_task_title => '제목';

  @override
  String get form_field_intervention_task_default => '이름 없는 중재 과제';

  @override
  String get form_field_intervention_task_title_tooltip =>
      'StudyU 앱의 일일 알림에 표시할 중재 과제 제목을 입력하세요';

  @override
  String get form_field_intervention_task_title_required =>
      '중재 과제 제목은 비워둘 수 없습니다';

  @override
  String get form_field_intervention_task_description => '설명';

  @override
  String get form_field_intervention_task_description_tooltip =>
      'StudyU 앱에서 일일 알림을 클릭할 때 표시되는 자세한 설명을 입력합니다';

  @override
  String get form_field_intervention_task_description_hint =>
      '수행할 중재 과제에 대한 자세한 설명과 동영상 지침 링크 등을 제공하세요';

  @override
  String get form_field_intervention_task_mark_as_completed_label =>
      '참가자가 \"완료로 표시\"하도록 요구합니다';

  @override
  String get form_section_crossover_schedule => '연구 일정';

  @override
  String get navlink_crossover_schedule_test => '테스트 일정';

  @override
  String get form_field_crossover_schedule_sequence => '순서 지정';

  @override
  String get form_field_crossover_schedule_sequence_tooltip =>
      '연구 일정에서 개입 단계가 순서대로 적용되는 패턴을 선택하세요';

  @override
  String get form_field_crossover_schedule_sequence_description =>
      '이는 각 참가자에 대한 기본 개입 순서입니다. 초대 전용 연구에서는 각 참가자별로 이 순서를 개별적으로 재정의할 수 있습니다.';

  @override
  String get form_field_crossover_schedule_phase_length => '단계 길이';

  @override
  String get form_field_crossover_schedule_phase_length_tooltip =>
      '단일 단계가 지속되는 일수입니다. 단계는 하나의 연속된 중재 구간입니다(예: A 또는 B 중재를 7일간 시행).';

  @override
  String form_field_crossover_schedule_phase_length_range(num min, num max) {
    return '중재 단계는 $min일에서 $max일 사이여야 합니다';
  }

  @override
  String get form_field_amount_days => '일';

  @override
  String get form_field_crossover_schedule_num_cycles => '사이클 수';

  @override
  String get form_field_crossover_schedule_num_cycles_tooltip =>
      '교대 / 역균형 / 무작위:  \n반복할 사이클 수(단계 쌍). 한 사이클 = 두 단계 (예: AB 또는 BA).  \n\n사용자 정의:  \n정의한 전체 사용자 지정 시퀀스를 반복하는 횟수. 한 사이클 = 정의한 전체 시퀀스 (예: ABBAA).';

  @override
  String form_field_crossover_schedule_num_cycles_range(num min, num max) {
    return '연구 일정의 사이클 수는 $min에서 $max 사이여야 합니다';
  }

  @override
  String get form_field_amount_crossover_schedule_num_cycles => '주기';

  @override
  String get form_field_crossover_schedule_include_baseline => '기준선 단계';

  @override
  String get form_field_crossover_schedule_include_baseline_tooltip =>
      '연구 시작 시 중재가 없는 기준선 단계를 추가하세요';

  @override
  String get form_field_crossover_schedule_include_baseline_label => '일정에 포함';

  @override
  String get form_study_design_measurements_description =>
      '연구 동안 참가자로부터 수집하려는 데이터를 정의하세요 - 주로 여러분의 개입 효과를 평가하기 위해서입니다. 데이터는 참가자가 StudyU 앱을 통해 매일 제공되는 하나 이상의 설문조사에서 자기보고 방식으로 제출됩니다. 수집된 데이터와 결과는 연구가 시작되면 분석 페이지에서 확인할 수 있습니다.';

  @override
  String form_array_measurements_minlength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '중재 효과를 확인하기 위해 최소한 하나의 설문조사를 정의해야 합니다.',
      one: '중재 효과를 확인하기 위해 최소한 하나의 설문조사를 정의해야 합니다.',
    );
    return '$_temp0';
  }

  @override
  String get form_array_measurements_surveys => '설문조사';

  @override
  String get form_array_measurements_surveys_new => '설문조사 추가';

  @override
  String get form_array_measurements_surveys_empty_title => '정의된 설문조사가 없습니다';

  @override
  String get form_array_measurements_surveys_empty_description =>
      '귀하의 개입 효과를 결정하기 위해 최소한 하나의 설문조사를 정의해야 합니다.';

  @override
  String get form_field_measurement_survey_title => '설문조사 제목';

  @override
  String get form_field_measurement_survey_title_required =>
      '설문조사 제목은 비워둘 수 없습니다';

  @override
  String get form_field_measurement_survey_title_default => '이름 없는 설문조사';

  @override
  String get form_field_measurement_survey_title_tooltip =>
      'StudyU 앱에 표시될 설문조사 제목을 제공하십시오';

  @override
  String get form_field_measurement_survey_intro_text => '소개 텍스트';

  @override
  String get form_field_measurement_survey_intro_text_tooltip =>
      '설문조사 시작 시 가장 처음 표시되는 텍스트를 입력하십시오';

  @override
  String get form_field_measurement_survey_intro_text_hint =>
      '예: 설문조사에 참가자를 환영하고 소개하기';

  @override
  String get form_field_measurement_survey_outro_text => '마무리 텍스트';

  @override
  String get form_field_measurement_survey_outro_text_tooltip =>
      '완료 후 설문조사의 맨 마지막에 표시되는 텍스트를 입력하십시오';

  @override
  String get form_field_measurement_survey_outro_text_hint =>
      '예: 설문조사를 완료한 참가자에게 감사 인사';

  @override
  String get form_array_measurement_survey_questions => '질문';

  @override
  String get form_array_measurement_survey_questions_new => '질문 추가';

  @override
  String get form_array_measurement_survey_questions_empty_title =>
      '정의된 질문이 없습니다';

  @override
  String get form_array_measurement_survey_questions_empty_description =>
      '중재의 효과를 확인하기 위해 최소 한 개의 질문을 정의해야 합니다.';

  @override
  String form_array_measurement_survey_questions_minlength(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '중재의 효과를 확인하기 위해 최소 한 개의 질문을 정의해야 합니다',
      one: '중재의 효과를 확인하기 위해 최소 한 개의 질문을 정의해야 합니다',
    );
    return '$_temp0';
  }

  @override
  String get report_status_primary => '주요';

  @override
  String get report_status_secondary => '보조';

  @override
  String get report_status_primary_description => '주요 보고서';

  @override
  String get report_status_secondary_description => '보조 보고서';

  @override
  String get form_report_create => '새로운 보고서';

  @override
  String get form_report_edit => '보고서 편집';

  @override
  String get form_report_readonly => '보고서 보기';

  @override
  String get form_field_report_title_required => '보고서 제목을 제공해야 합니다';

  @override
  String get form_field_report_text_required => '보고서 설명은 비워둘 수 없습니다';

  @override
  String get form_array_reports_empty_title => '정의된 보고서가 없습니다';

  @override
  String get form_array_report_items_title => '보고서';

  @override
  String get form_array_report_items_description =>
      '참가자가 받게 될 보고서의 형식을 정의하세요. 보고서에는 여러 섹션이 포함되며, 그중 첫 번째가 주요 섹션입니다. 각 섹션에서 데이터를 평균으로 보고할지, 사용자 데이터의 선형 회귀를 통해 보고할지 정의할 수 있습니다. 데이터를 개별 일, 단계 또는 각 중재별로 보고할지 선택할 수 있습니다. 데이터 소스는 보고서 섹션의 기반이 되는 관찰 항목을 정의합니다.';

  @override
  String get form_array_reports_empty_description =>
      '참가자에게 피드백을 제공하려면 적어도 하나 이상의 보고서를 정의해야 합니다.';

  @override
  String get form_array_reports_new => '새 보고서 추가';

  @override
  String get form_field_report_title => '제목';

  @override
  String get form_field_report_title_tooltip => '보고서의 짧은 제목을 입력하세요.';

  @override
  String get form_field_report_title_hint => '짧은 제목 입력';

  @override
  String get form_field_report_text => '보고서 설명';

  @override
  String get form_field_report_text_tooltip => '보고서 설명 입력';

  @override
  String get form_field_report_text_hint => '보고서 설명 입력';

  @override
  String get form_field_report_section_type => '보고서 유형';

  @override
  String get form_field_report_section_type_tooltip => '보고서 유형 선택';

  @override
  String get form_field_report_section_type_description =>
      '보고서에 맞는 보고서 유형을 선택하세요.';

  @override
  String get form_field_report_improvementDirection_title => '개선 방향';

  @override
  String get form_field_report_improvementDirection_tooltip => '개선 방향 정의';

  @override
  String get reportSection_type_average => '평균';

  @override
  String get reportSection_type_textual_summary => '텍스트 요약';

  @override
  String get reportSection_type_gauge_comparison => '게이지 비교';

  @override
  String get reportSection_type_descriptive_statistics => '기술 통계';

  @override
  String get form_field_report_average_temporalAggregation_title => '시간 집계';

  @override
  String get form_field_report_average_temporalAggregation_tooltip =>
      '시간 집계를 정의하세요';

  @override
  String get reportSection_type_temporalAggregation_day => '일';

  @override
  String get reportSection_type_temporalAggregation_phase => '단계';

  @override
  String get reportSection_type_temporalAggregation_intervention => '중재';

  @override
  String get form_field_report_temporalAggregation_required =>
      '시간 집계 값을 정의해야 합니다';

  @override
  String get reportSection_type_linearRegression => '선형 회귀';

  @override
  String get reportSection_type_improvementDirection_positive => '긍정적';

  @override
  String get reportSection_type_improvementDirection_negative => '부정적';

  @override
  String get form_field_report_improvementDirection_required =>
      '개선 방향을 정의해야 합니다.';

  @override
  String get form_field_report_linearRegression_alpha_title => '알파 신뢰도';

  @override
  String get form_field_report_linearRegression_alpha_tooltip => '알파 신뢰도 정의';

  @override
  String get form_field_report_linearRegression_alpha_hint => '숫자 값을 입력하세요';

  @override
  String get form_field_report_alphaConfidence_required => '알파 신뢰 값을 정의해야 합니다';

  @override
  String get form_field_report_alphaConfidence_number => '알파 신뢰 값은 숫자 값이어야 합니다';

  @override
  String get form_field_report_data_source_title => '데이터 소스';

  @override
  String get form_field_report_data_source_tooltip =>
      '데이터 소스는 보고서 섹션이 어떤 관찰을 기반으로 하는지를 정의합니다. 관찰은 수치 결과를 가진 질문이어야 합니다. 예: 척도 질문.';

  @override
  String get form_field_report_data_source_required => '데이터 소스를 정의해야 합니다';

  @override
  String get form_field_report_select_aggregation => '집계 값을 선택하세요';

  @override
  String get study_test_page_description =>
      '테스트 모드에서는 참가자 입장에서 연구를 테스트할 수 있습니다.';

  @override
  String get navlink_study_test_help => '이것은 어떻게 작동합니까?';

  @override
  String get study_test_app_nav_title => '페이지 선택:';

  @override
  String get navlink_study_test_app_overview => '연구 개요';

  @override
  String get navlink_study_test_app_eligibility => '선별 설문';

  @override
  String get navlink_study_test_app_intervention => '중재 선택';

  @override
  String get navlink_study_test_app_intervention_disabled =>
      '연구에 정의된 중재가 세 개 미만이므로 중재 선택이 비활성화되었습니다. 이 경우 중재는 자동으로 선택됩니다.';

  @override
  String get navlink_study_test_app_consent => '동의';

  @override
  String get navlink_study_test_app_journey => '일정';

  @override
  String get navlink_study_test_app_dashboard => '일일 대시보드';

  @override
  String get action_button_study_test_reset => '재설정';

  @override
  String get action_button_study_test_open_new_tab => '새 탭에서 열기';

  @override
  String get preview_overlay_health_checking_title => '앱 사용 가능 여부 확인 중';

  @override
  String get preview_overlay_connecting_title => '앱 미리보기에 연결 중';

  @override
  String get preview_overlay_loading_title => '앱 미리보기를 로딩 중';

  @override
  String preview_overlay_health_checking_description_local(String url) {
    return '$url에서 StudyU 앱이 실행 중인지 확인 중입니다.';
  }

  @override
  String preview_overlay_health_checking_description_remote(String url) {
    return '$url에서 참가자 앱에 접근할 수 있는지 확인 중입니다.';
  }

  @override
  String get preview_overlay_connecting_description_local =>
      '로컬 StudyU 앱에 접근할 수 있습니다. 지금 연결을 설정합니다.';

  @override
  String get preview_overlay_connecting_description_remote =>
      '참가자 앱에 접근할 수 있습니다. 지금 연결을 설정합니다.';

  @override
  String get preview_overlay_loading_description_local =>
      '앱 미리보기가 연결되었습니다. 앱이 이제 휴대폰 프레임 안에서 로딩 중입니다.';

  @override
  String get preview_overlay_loading_description_remote =>
      '앱 미리보기가 연결되었습니다. 참가자 앱이 이제 로딩 중입니다.';

  @override
  String get preview_overlay_local_unavailable_title =>
      '로컬 앱 미리보기를 사용할 수 없습니다.';

  @override
  String get preview_overlay_remote_unavailable_title => '앱 점검 중';

  @override
  String get preview_overlay_local_unavailable_message =>
      '로컬 StudyU 앱에 접근할 수 없습니다.';

  @override
  String get preview_overlay_remote_unavailable_message =>
      'StudyU 모바일 앱은 일시적으로 사용 불가이거나 점검 중입니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get preview_overlay_could_not_load => 'StudyU 앱 미리보기를 불러올 수 없습니다.';

  @override
  String get preview_overlay_preview_not_opened =>
      'StudyU 앱 미리보기를 지금 열 수 없습니다.';

  @override
  String get banner_study_test_unavailable =>
      '다음 정보를 업데이트할 때까지 테스트 모드를 사용할 수 없습니다:';

  @override
  String get banner_study_preview_unavailable =>
      '다음 정보를 업데이트할 때까지 미리보기를 사용할 수 없습니다:';

  @override
  String get dialog_study_test_help_title => '연구를 테스트하세요!';

  @override
  String get dialog_study_test_help_description =>
      '이 페이지에서는 연구 참가자 중 한 명처럼 연구를 체험할 수 있어, 연구 설계를 필요에 맞게 조정하고 모든 것이 제대로 작동하는지 확인할 수 있습니다.';

  @override
  String get dialog_study_test_section_tips => '⭐ 전문가 팁';

  @override
  String get dialog_study_test_section_tips_text =>
      '• 좌측 상단 메뉴를 사용하여 연구의 다양한 부분을 빠르게 미리보기하고 이동하세요.  \n• 앱 대시보드 페이지에서 \'다음 날\'을 클릭하여 참가자의 일정 진행 상황을 빠르게 넘기세요.  \n• 최신 테스트 세션 데이터(분석 탭)를 내보내고 분석하여 결과가 어떻게 나오는지 미리 확인하세요.  \n• 새로운 체험을 위해 모든 데이터를 초기화하고 새로운 테스트 사용자로 등록할 수 있습니다.';

  @override
  String get dialog_study_test_download_url_intro => '• 휴대폰에서 테스트하려면 ';

  @override
  String get dialog_study_test_download_url =>
      'https://github.com/hpi-studyu/studyu#app-stores';

  @override
  String get dialog_study_test_download_url_text => 'StudyU 앱을 다운로드';

  @override
  String get dialog_study_test_download_url_outro => '할 수도 있습니다.';

  @override
  String get dialog_study_test_section_notice => '⚠️ 주의 사항';

  @override
  String get dialog_study_test_section_notice_text =>
      '• 연구를 시작하면 모든 테스트 사용자와 그들의 데이터가 초기화됩니다.';

  @override
  String get dialog_action_study_test_start => '테스트 시작';

  @override
  String enrolled_count_tooltip(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count명이 이 코드로 연구에 등록되었습니다',
      one: '$count명이 이 코드로 연구에 등록되었습니다',
      zero: '아직 이 코드로 연구에 등록된 사람이 없습니다',
    );
    return '$_temp0';
  }

  @override
  String get form_code_create => '새 초대 코드';

  @override
  String get form_code_readonly => '초대 코드';

  @override
  String get form_field_code => '코드';

  @override
  String get form_field_code_tooltip => '참가자가 연구에 등록할 때 사용할 수 있는 고유한 코드를 입력하세요';

  @override
  String get form_field_code_required => '코드는 비워둘 수 없습니다';

  @override
  String form_field_code_minlength(num minLength) {
    return '코드는 최소 $minLength자 이상이어야 합니다';
  }

  @override
  String form_field_code_maxlength(num maxLength) {
    return '코드는 최대 $maxLength자여야 합니다';
  }

  @override
  String get form_field_code_alreadyused => '이 코드는 이미 사용 중입니다';

  @override
  String get form_field_is_preconfigured_schedule => '미리 정의된 일정';

  @override
  String get form_field_is_preconfigured_schedule_description =>
      '이 초대 코드를 통해 연구에 참여하는 모든 참가자에 대해 단계와 개입을 미리 정의할 수 있습니다. 사용 설정 시, 이 설정은 연구 설계에서 정의된 기본 일정을 대체합니다.';

  @override
  String get form_field_preconfigured_schedule_type => '일정';

  @override
  String get form_field_preconfigured_schedule_intervention_a => '개입 A';

  @override
  String get form_field_preconfigured_schedule_intervention_b => '개입 B';

  @override
  String get form_field_preconfigured_schedule_intervention_default => '기본';

  @override
  String get form_field_preconfigured_schedule_intervention_hint => '개입 선택...';

  @override
  String get code_list_section_title => '초대 코드';

  @override
  String get code_public_disabled => '공개 모집';

  @override
  String get code_public_disabled_description =>
      '참가자는 아래 링크를 사용하거나 QR 코드를 스캔하거나 앱의 공개 연구 목록에서 이 연구에 참여할 수 있습니다. 초대 코드는 비공개 연구에서만 사용하므로 여기에는 표시되지 않습니다.';

  @override
  String get code_list_empty_title => '아직 아무도 초대하지 않았습니다.';

  @override
  String get code_list_empty_description => '초대 코드를 통해 연구에 참여자를 추가하세요.';

  @override
  String get code_list_header_code => '코드';

  @override
  String get code_list_header_actions => '작업';

  @override
  String get action_button_code_new => '새 코드';

  @override
  String get participant_details_title => '참여자 상세 정보';

  @override
  String get participant_details_study_days_overview => '연구 일수 개요';

  @override
  String get participant_details_study_days_description =>
      '이 섹션은 참여자의 연구 진행 상황에 대한 개요를 제공합니다. 색상 코딩은 각 날짜별 참여자의 과제 상태를 나타냅니다. 각 날짜 위에 마우스를 올리면 참여자의 활동에 대한 자세한 정보를 볼 수 있습니다.';

  @override
  String get participant_details_color_legend_title => '범례';

  @override
  String get participant_details_color_tooltip_legend_title => '활동 세부 범례';

  @override
  String get participant_details_color_legend_completed_task => '작업 완료';

  @override
  String get participant_details_color_legend_completed_task_tooltip =>
      '참여자가 이 작업을 완료했습니다';

  @override
  String get participant_details_color_legend_missed_task => '작업을 놓침';

  @override
  String get participant_details_color_legend_missed_task_tooltip =>
      '참여자가 이 작업을 놓쳤습니다';

  @override
  String get participant_details_color_legend_completed => '모든 작업 완료';

  @override
  String get participant_details_color_legend_partially_completed =>
      '일부 작업 미완료';

  @override
  String get participant_details_color_legend_missed => '모든 작업을 놓침';

  @override
  String get participant_details_completed_legend_tooltip =>
      '이 날의 모든 중재 과제와 설문 과제가 완료되었습니다';

  @override
  String get participant_details_partially_completed_legend_tooltip =>
      '이 날에는 중재 과제 또는 설문 과제 중 일부만 완료되었습니다';

  @override
  String get participant_details_incomplete_legend_tooltip =>
      '이 날에는 중재 과제와 설문 과제가 하나도 완료되지 않았습니다';

  @override
  String get participant_details_progress_empty_title => '아직 진행 데이터가 없습니다';

  @override
  String get participant_details_progress_empty_description =>
      '참여자가 연구를 시작하면 여기에서 진행 상황을 모니터링할 수 있습니다.';

  @override
  String get monitoring_no_participants_title => '현재 이 연구에는 참가자가 없습니다';

  @override
  String get monitoring_no_participants_description =>
      '참가자가 연구에 등록되면, 여기에서 진행 상황을 모니터링하고 데이터를 확인할 수 있습니다.';

  @override
  String get monitoring_participants_title => '참가자 개요';

  @override
  String get monitoring_total => '참가자 총 수';

  @override
  String get monitoring_active => '활성';

  @override
  String get monitoring_active_tooltip => '현재 연구에 참여 중인 참가자 수';

  @override
  String get monitoring_inactive => '비활성';

  @override
  String get monitoring_inactive_tooltip => '연속 3일 넘게 과제를 완료하지 않은 참가자 수';

  @override
  String get monitoring_dropout => '중도 탈락';

  @override
  String get monitoring_dropout_tooltip =>
      '연구 종료 전에 탈퇴했거나 연속 5일 넘게 활동하지 않은 참가자 수';

  @override
  String get monitoring_completed => '완료';

  @override
  String get monitoring_completed_tooltip => '연구 종료에 도달한 참가자 수';

  @override
  String get monitoring_table_column_participant_id => 'ID';

  @override
  String get monitoring_table_column_invite_code => '초대 코드';

  @override
  String get monitoring_table_column_enrolled => '시작 시간';

  @override
  String get monitoring_table_column_last_activity => '마지막 활동';

  @override
  String get monitoring_table_column_day_in_study => '연구 진행 일수';

  @override
  String get monitoring_table_column_completed_intervention_tasks =>
      '완료된 중재 과제';

  @override
  String get monitoring_table_column_completed_surveys => '완료된 설문조사';

  @override
  String get monitoring_table_row_tooltip_dropout =>
      '이 참가자는 연구에서 탈락했으며 새로운 활동이 추가되지 않습니다';

  @override
  String get monitoring_table_days_in_study_header_tooltip => '참가자가 연구에 참여한 일수';

  @override
  String get monitoring_table_completed_interventions_header_tooltip =>
      '연구 기간 동안 모든 중재 과제를 완료했습니다';

  @override
  String get monitoring_table_completed_surveys_header_tooltip =>
      '설문조사는 해당 일의 모든 과제를 완료하면 완료된 것으로 간주됩니다';

  @override
  String get banner_text_study_recruit_draft =>
      '이 연구는 아직 시작되지 않았기 때문에, 이 페이지의 링크는 아직 작동하지 않습니다.';

  @override
  String get banner_text_study_analyze_draft =>
      '이 연구는 아직 시작되지 않았기 때문에, 이 페이지는 현재 연구 테스트 중 생성된 데이터를 기반으로 하고 있습니다. 실참가자와 함께 연구를 시작하면 이 페이지의 데이터가 초기화됩니다.';

  @override
  String get action_button_study_export => '데이터 내보내기';

  @override
  String get action_button_study_export_prompt => '직접 분석을 실행하시겠습니까?';

  @override
  String get study_export_unavailable_empty_tooltip => '아직 사용할 수 있는 데이터가 없습니다';

  @override
  String get study_export_unavailable_no_permission_tooltip =>
      '이 연구의 데이터에 접근할 충분한 권한이 없습니다';

  @override
  String get study_launch_title => '훌륭한 작업입니다! 👏 시작할 준비가 되셨나요?';

  @override
  String get study_launch_participation_intro => '현재 생성 중인 연구는';

  @override
  String get study_launch_participation_outro => '';

  @override
  String get study_launch_post_launch_intro => '연구를 시작한 후:';

  @override
  String get study_launch_post_launch_summary =>
      '- 연구 설계가 잠기며 더 이상 변경할 수 없습니다.\n- 테스트 실행의 모든 데이터가 초기화됩니다(테스트 사용자, 그들의 작업 및 결과 포함)';

  @override
  String get study_launch_success_title => '연구가 진행 중입니다!';

  @override
  String get study_launch_success_description =>
      '다음으로 StudyU 앱에서 참가자를 초대하고 등록할 수 있습니다.';

  @override
  String get study_public_launch_success_description =>
      '이제 연구가 StudyU 앱에서 모든 사용자에게 제공됩니다.';

  @override
  String get action_button_post_launch_followup => '참가자 추가';

  @override
  String get action_button_post_launch_followup_skip => '지금 건너뛰기';

  @override
  String get action_button_study_participation_change => '참여 변경';

  @override
  String get form_field_required => '필드는 비워둘 수 없습니다';

  @override
  String get form_invalid_prompt => '필수 항목을 모두 입력해 주세요';

  @override
  String get copy_suffix_label => '복사';

  @override
  String date_diff_years(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count년 전',
      one: '1년 전',
    );
    return '$_temp0';
  }

  @override
  String date_diff_months(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개월 전',
      one: '1개월 전',
    );
    return '$_temp0';
  }

  @override
  String date_diff_days(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일 전',
      one: '1일 전',
    );
    return '$_temp0';
  }

  @override
  String date_diff_hours(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count시간 전',
      one: '1시간 전',
    );
    return '$_temp0';
  }

  @override
  String date_diff_minutes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count분 전',
      one: '1분 전',
    );
    return '$_temp0';
  }

  @override
  String date_diff_seconds(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count초 전',
      one: '1초 전',
    );
    return '$_temp0';
  }

  @override
  String get date_just_now => '방금';

  @override
  String get action_edit => '편집';

  @override
  String get action_pin => '고정';

  @override
  String get action_unpin => '핀 제거';

  @override
  String get action_delete => '삭제';

  @override
  String get action_delete_invite_code => '초대 코드 삭제';

  @override
  String get action_delete_code => '코드 삭제';

  @override
  String get action_remove => '제거';

  @override
  String get action_duplicate => '복제';

  @override
  String get action_clipboard => '클립보드에 복사';

  @override
  String get action_copy_invite_code => '초대 코드 복사';

  @override
  String get action_copy_invite_link => '초대 링크 복사';

  @override
  String get action_qr_code_show => 'QR 코드 보기';

  @override
  String get action_qr_code_download => 'QR 코드 다운로드';

  @override
  String get action_share => '초대 링크 공유';

  @override
  String get action_copy_link => '링크 복사';

  @override
  String get action_copy_invitation => '초대장 복사';

  @override
  String get action_reportPrimary => '주요 보고서로 설정';

  @override
  String get action_study_duplicate_draft => '초안으로 복사';

  @override
  String get action_study_export_results => '결과 내보내기';

  @override
  String get action_export_study_definition => '연구 정의 내보내기';

  @override
  String get dialog_continue => '계속';

  @override
  String get dialog_close => '닫기';

  @override
  String get dialog_cancel => '취소';

  @override
  String get dialog_save => '저장';

  @override
  String get sync_initial => '저장할 변경 사항이 없습니다';

  @override
  String get sync_dirty => '저장되지 않은 변경 사항이 있습니다';

  @override
  String get sync_saving => '변경 사항 저장 중...';

  @override
  String get sync_done => '모든 변경 사항이 저장되었습니다';

  @override
  String get sync_last_saved => '마지막 저장';

  @override
  String get sync_failed => '변경 사항을 저장할 수 없습니다';

  @override
  String get iconpicker_nonempty_prompt => '아이콘 변경';

  @override
  String get iconpicker_empty_prompt => '아이콘 선택';

  @override
  String get iconpicker_dialog_title => '아이콘 선택';

  @override
  String get dialog_unsaved_changes_title => '저장되지 않은 변경 사항을 삭제하시겠습니까?';

  @override
  String get dialog_unsaved_changes_description =>
      '지금 나가면 최근 변경 사항이 영구적으로 삭제됩니다.';

  @override
  String get dialog_action_unsaved_changes_stay => '유지';

  @override
  String get dialog_action_unsaved_changes_discard => '변경 사항 폐기';

  @override
  String get under_construction => '준비 중';

  @override
  String get under_construction_description => '이 부분은 아직 작업 중입니다. 곧 다시 확인하세요!';

  @override
  String get fitbit_credentials_instruction =>
      'Fitbit 데이터를 통합하려면 다음 단계를 따라 클라이언트 ID와 클라이언트 시크릿을 얻으세요:';

  @override
  String get fitbit_credentials_step1 => '1. Fitbit Developer Portal로 이동합니다.';

  @override
  String get fitbit_credentials_step2 =>
      '2. Fitbit 계정으로 로그인하거나 계정이 없는 경우 새로 만듭니다.';

  @override
  String get fitbit_credentials_step3 =>
      '3. \'관리\' 섹션으로 이동한 후 \'앱 등록\'을 선택합니다.';

  @override
  String get fitbit_credentials_step4 =>
      '4. 애플리케이션 이름, 설명, 리디렉션 URL(\'studyu://fitbit/auth\' 사용)과 같은 필수 항목을 작성합니다.';

  @override
  String get fitbit_credentials_step5 =>
      '5. \'OAuth 2.0 애플리케이션 유형\'에서 \'클라이언트\'를 선택하고 \'접근\'을 \'읽기 전용\'으로 설정합니다.';

  @override
  String get fitbit_credentials_step6 =>
      '6. 양식을 제출하여 \'클라이언트 ID\'와 \'클라이언트 시크릿\'을 받습니다.';

  @override
  String get fitbit_credentials_step7 =>
      '7. 인트라데이 데이터를 얻으려면 다음 양식을 작성해야 합니다. 이를 작성하지 않으면 Fitbit에서 시험을 위한 어떤 데이터도 얻을 수 없습니다.';

  @override
  String get fitbit_credentials_step8 => '8. 아래 자격 증명을 복사하여 붙여넣습니다.';

  @override
  String get fitbit_credentials_success_instruction =>
      '자격 증명을 입력하면 Fitbit 통합이 연구에 대해 활성화됩니다.';

  @override
  String get fitbit_credentials_add_question_instruction =>
      'Fitbit 질문을 추가하려면 측정 섹션으로 이동하여 측정 내에서 새 Fitbit 질문을 만드십시오.';

  @override
  String get fitbit_credentials_screenshot_step1 => '1단계: 개발자 포털';

  @override
  String get fitbit_credentials_screenshot_step2 => '2단계: 로그인';

  @override
  String get fitbit_credentials_screenshot_step3 => '3단계: 앱 등록';

  @override
  String get fitbit_credentials_screenshot_step4 => '4단계: 세부 정보 입력';

  @override
  String get fitbit_credentials_screenshot_step5 => '5단계: 접근 권한 설정';

  @override
  String get fitbit_credentials_screenshot_step6 => '6단계: 자격 증명 받기';

  @override
  String get fitbit_credentials_screenshot_step7 => '7단계: 양식 작성';

  @override
  String get fitbit_credentials_cannot_change_title =>
      'Fitbit 자격 증명을 변경할 수 없습니다.';

  @override
  String get fitbit_credentials_cannot_change_description =>
      '연구가 초안 모드가 아닐 때는 Fitbit 자격 증명을 변경할 수 없습니다.';

  @override
  String get fitbit_only_participant_title => '연구를 본인만을 위해 진행하는 경우';

  @override
  String get fitbit_only_participant_subtitle =>
      '연구를 생성하고 참여하고 있으므로, 인트라데이 데이터 요청 양식을 작성할 필요가 없습니다. 다음 간단한 단계를 따르면 됩니다:';

  @override
  String get fitbit_only_participant_description =>
      '이 연구를 본인만을 위해 진행하는 경우, 이전 페이지에서 본인의 Fitbit 계정의 Client ID와 Client Secret을 사용해야 합니다.';

  @override
  String get fitbit_multiple_participant_title => '이 연구를 여러 참가자를 위해 진행하는 경우';

  @override
  String get fitbit_multiple_participant_description =>
      '각 참가자는 StudyU 앱에서 자신의 Fitbit 계정으로 로그인해야 합니다. 데이터는 각 참가자별로 별도로 수집됩니다.';

  @override
  String get study_import_title => '연구 가져오기';

  @override
  String get study_import_description =>
      'JSON 파일에서 연구 정의를 가져오세요. 이렇게 하면 새 초안 연구가 생성됩니다.';

  @override
  String get study_import_button => 'JSON에서 연구 가져오기';

  @override
  String get study_import_success => '연구가 성공적으로 가져와졌습니다';

  @override
  String study_import_error(String error) {
    return '연구 가져오기 실패: $error';
  }

  @override
  String get fitbit_only_participant_step_1 =>
      'Fitbit 앱을 생성할 때, 앱 유형으로 \'개인용\'을 선택하세요.';

  @override
  String get fitbit_only_participant_step_2 =>
      '데이터를 동기화할 때, Fitbit 시계와 설정한 Fitbit 앱에 연결된 동일한 Google 계정을 사용해야 합니다.';

  @override
  String get client_id => '클라이언트 ID';

  @override
  String get client_id_label_help =>
      'Fitbit Developer Portal에서 클라이언트 ID를 입력하세요.';

  @override
  String get client_id_hint => '클라이언트 ID';

  @override
  String get client_secret => '클라이언트 시크릿';

  @override
  String get client_secret_label_help =>
      'Fitbit Developer Portal에서 클라이언트 시크릿을 입력하세요.';

  @override
  String get client_secret_hint => '클라이언트 시크릿';

  @override
  String get fitbit_credentials_how_to_obtain => 'Fitbit 자격 증명을 얻는 방법';

  @override
  String get fitbit_client_id_required => '클라이언트 ID는 필수 항목입니다';

  @override
  String get fitbit_client_secret_required => '클라이언트 비밀키는 필수 항목입니다';

  @override
  String get fitbit_question_type_required => '최소 하나의 Fitbit 유형을 선택해야 합니다.';

  @override
  String get screenshots_for_guidance => '안내용 스크린샷:';

  @override
  String get fitbit_credentials_not_set =>
      'Fitbit 자격 증명이 설정되지 않았습니다. 스터디 디자이너에서 \'Fitbit\' 탭으로 이동하여 Fitbit 클라이언트 ID와 클라이언트 시크릿을 입력하세요. 완료되면 여기로 돌아와 Fitbit 질문을 추가하세요.';

  @override
  String get fitbit_question_type_heartrate_description =>
      '하루 동안 매분 측정된 심박수를 기록합니다.';

  @override
  String get fitbit_question_type_steps_description => '매분 측정된 걸음 수를 기록합니다.';

  @override
  String get fitbit_question_type_sleep_description =>
      '수면 중 30초에서 1분 간격으로 수면 단계(깨어 있음, 얕은 수면, 깊은 수면, REM)를 기록합니다.';

  @override
  String get html_styling_banner_description =>
      '스타일 적용 가능으로 표시된 필드의 내용을 스타일링하기 위해 기본 HTML 태그를 사용할 수 있습니다. 몇 가지 예시는 다음과 같습니다:';

  @override
  String get html_styling_bold_example => '텍스트를 굵게 만드세요';

  @override
  String get html_styling_bold_code => '<b>굵은 텍스트</b>';

  @override
  String get html_styling_italic_example => '텍스트를 기울임체로 만드세요';

  @override
  String get html_styling_italic_code => '<i>기울임 텍스트</i>';

  @override
  String get html_styling_underline_example => '텍스트에 밑줄을 긋기';

  @override
  String get html_styling_underline_code => '<u>밑줄 텍스트</u>';

  @override
  String get html_styling_link_example => '클릭 가능한 링크 추가';

  @override
  String get html_styling_link_code =>
      '<a href=\"https://example.com\">링크 텍스트</a>';

  @override
  String get html_styling_linebreak_example => '줄바꿈을 삽입하세요';

  @override
  String get html_styling_linebreak_code => '줄 1<br>줄 2';

  @override
  String get html_styling_more_info => '자세한 내용:';

  @override
  String get html_styling_documentation_link => 'HTML 문서';

  @override
  String get study_schedule_learn_more => '연구 일정 설계에 대해 자세히 알아보기';

  @override
  String get study_schedule_banner_explanation =>
      '우리는 다음과 같은 용어를 사용합니다:\n\n각 시험(trial)은 일정한 길이의 서로 다른 중재 단계(= 중재 기간 = 중재 블록)로 구성됩니다.  \n예를 들어, 한 시험은 각 7일씩 4개의 단계를 포함할 수 있으며, 따라서 총 28일 동안 지속됩니다.  \n추가적인 기준선(baseline) 단계가 있을 수 있으며, 이 기준선 단계는 각 단계와 동일한 길이로 고정됩니다.  \n즉, 각 7일씩 4단계와 추가 기준선 기간이 있는 시험은 총 35일 동안 지속됩니다.\n\n단계들은 서로 다른 순서를 따를 수 있습니다.  \n우리는 두 가지 중재, A와 B를 고려합니다.  \n이들은 교대(alternating), 역균형(counterbalanced), 무작위(random), 또는 맞춤(custom) 설계를 따를 수 있습니다.\n\n교대, 역균형, 무작위 설계에서 한 주기는 두 개의 중재 단계로 이루어진 한 쌍을 뜻합니다.  \n무작위 설계(random design)는 교대(alternating) 또는 역균형(counterbalanced) 순서를 생성합니다.  \n각 설계의 한 주기는 AB(교대), AB(역균형), 또는 AB/BA(무작위)를 생성합니다.  \n두 주기(cycles)는 ABAB(교대), ABBA(역균형), 또는 ABAB/ABBA(무작위)를 생성합니다.\n\n맞춤 설계(custom design)에서는 맞춤 순서를 정의할 수 있습니다, 예: ABBAA.  \n여기서 한 주기는 전체 맞춤 순서를 의미하며, 즉 2주기(cycles) ABBAA는 ABBAAABBAA를 생성합니다.';

  @override
  String get study_schedule_banner_description =>
      '서로 다른 순서 유형과 그것이 연구 결과에 미치는 영향을 이해하여 효과적인 N-of-1 실험을 설계하세요.';

  @override
  String get study_schedule_alternating_description =>
      '교대로: 각 참가자는 ABAB 패턴을 따르며 예측 가능한 순서로 중재를 전환합니다.';

  @override
  String get study_schedule_balanced_description =>
      '역균형: 각 참가자는 ABBA 패턴을 따르며 예측 가능한 순서로 중재를 전환합니다.';

  @override
  String get study_schedule_random_description =>
      '무작위: 순서는 각 주기마다 완전히 무작위로 결정되어 최대한의 변동성을 제공합니다.';

  @override
  String get study_schedule_custom_description =>
      '사용자 정의: 특정 연구 요구 사항을 충족하기 위해 나만의 순서 패턴을 정의하세요.';

  @override
  String get form_nutrition_tracking_title => 'Nutritional Tracking';

  @override
  String get form_nutrition_tracking_enable_hint =>
      'Enable nutritional tracking for this study';

  @override
  String get form_measurement_type_select => 'Select Measurement Type';

  @override
  String get form_measurement_type_survey => 'Survey';

  @override
  String get form_measurement_type_survey_description =>
      'Collect self-reported data from participants using questions and scales.';

  @override
  String get form_measurement_type_nutrition => 'Nutrition Task';

  @override
  String get form_measurement_type_nutrition_description =>
      'Track participant food and drink intake using a structured journal or photo capture.';

  @override
  String get form_field_nutrition_instructions => 'Instructions';

  @override
  String get form_field_nutrition_instructions_hint =>
      'Enter instructions for the participant';

  @override
  String get form_field_nutrition_collect_meal_context =>
      'Collect Meal Context';

  @override
  String get form_field_nutrition_allow_recipes => 'Allow Recipes';

  @override
  String get form_field_nutrition_minimum_meals_required =>
      'Minimum Meals Required';

  @override
  String get form_field_nutrition_minimum_meals_hint => 'Optional';

  @override
  String get form_field_nutrition_default_title => 'Nutrition Tracking';

  @override
  String get form_field_nutrition_custom_meal_types => 'Custom Meal Types';

  @override
  String get form_field_nutrition_custom_meal_types_hint =>
      'Leave empty to use defaults';

  @override
  String get form_field_nutrition_add_meal_type => 'Add meal type';

  @override
  String form_field_nutrition_meal_type_label(Object index) {
    return 'Meal type $index';
  }

  @override
  String get form_field_nutrition_minimum_meals_min_error =>
      'Must be at least 1';

  @override
  String get filter_studies => '연구 필터';

  @override
  String get filter_manage_presets => '사전 설정 관리';

  @override
  String get filter_load_preset => '사전 설정 불러오기';

  @override
  String get filter_save_changes => '변경 사항 저장';

  @override
  String get filter_save_as_new => '새로 저장';

  @override
  String get filter_delete_preset => '프리셋 삭제';

  @override
  String get filter_reset_all => '모두 지우기';

  @override
  String get code_list_filter_title => '초대 코드 필터';

  @override
  String get code_list_filter_enrolled_status => '등록 상태';

  @override
  String get code_list_filter_enrolled_min => '등록 인원 최솟값';

  @override
  String get code_list_filter_enrolled_max => '등록 인원 최댓값';

  @override
  String get code_list_filter_intervention_assignment => '중재 배정';

  @override
  String get code_list_filter_apply => '적용';

  @override
  String get code_list_filter_option_all => '전체';

  @override
  String get code_list_filter_option_unused => '미사용';

  @override
  String get code_list_filter_option_used => '사용됨';

  @override
  String code_list_filter_button_active(int count) {
    return '필터 ($count)';
  }

  @override
  String filter_show_studies(int count) {
    return '$count건의 연구 보기';
  }

  @override
  String get filter_dialog_save_title => '필터 프리셋 저장';

  @override
  String get filter_dialog_preset_name_hint => '프리셋 이름';

  @override
  String get filter_category_basic => '기본 정보';

  @override
  String get filter_category_visibility => '가시성 및 역할';

  @override
  String get filter_category_participants => '참여자';

  @override
  String get filter_category_dates => '날짜';

  @override
  String get filter_field_title => '제목';

  @override
  String get filter_field_status => '상태';

  @override
  String get filter_field_participation => '참여';

  @override
  String get filter_field_result_sharing => '결과 공유';

  @override
  String get filter_field_registry_published => '레지스트리 공개';

  @override
  String get filter_field_participant_count => '참가자 수';

  @override
  String get filter_field_active_count => '활성 개수';

  @override
  String get filter_field_completed_count => '완료된 수';

  @override
  String get filter_field_created_date => '생성 날짜';

  @override
  String get filter_date_from => '시작';

  @override
  String get filter_date_to => '종료';

  @override
  String get filter_operator_contains => '포함';

  @override
  String get filter_operator_equals => '일치';

  @override
  String get filter_operator_starts_with => '~로 시작';

  @override
  String get filter_operator_ends_with => '~로 끝남';

  @override
  String get filter_operator_is => '입니다';

  @override
  String get filter_operator_is_not => '아닙니다';

  @override
  String get filter_operator_min => '최소';

  @override
  String get filter_operator_max => '최대';

  @override
  String get filter_operator_exactly => '정확히';

  @override
  String get filter_operator_more_than => '초과';

  @override
  String get filter_operator_less_than => '미만';

  @override
  String get filter_bool_yes => '예';

  @override
  String get filter_bool_no => '아니요';

  @override
  String get preset_my_active_studies => '내 활성 연구';

  @override
  String get preset_studies_needing_attention => '주의가 필요한 연구';

  @override
  String get preset_recently_created => '최근 생성';

  @override
  String get preset_public_studies => '공개 연구';

  @override
  String get preset_draft_studies => '초안 연구';

  @override
  String get preset_custom => '사용자 지정 사전설정';

  @override
  String get preset_none => '사용자 지정 사전설정 없음';

  @override
  String get preset_tooltip_my_active_studies => '귀하가 소유하며 현재 진행 중인 연구';

  @override
  String get preset_tooltip_studies_needing_attention => '참여율이 낮은 진행 중인 연구';

  @override
  String get preset_tooltip_recently_created => '지난 30일 동안 생성된 연구';

  @override
  String get preset_tooltip_public_studies => '레지스트리에 게시되었거나 공개 결과가 있는 연구';

  @override
  String get preset_tooltip_draft_studies => '현재 초안 모드에 있는 연구';

  @override
  String get preset_loaded_tooltip => '현재 로드된 사전설정';

  @override
  String get filter_result_sharing_public => '공개';

  @override
  String get filter_result_sharing_private => '비공개';

  @override
  String get filter_result_sharing_organization => '조직';

  @override
  String get participation_open => '공개';

  @override
  String get participation_invite => '초대 전용';

  @override
  String get filter_section_default_presets => '기본 사전 설정';

  @override
  String get filter_section_custom_presets => '사용자 정의 사전 설정';

  @override
  String get filter_button_advanced => '필터 구성...';

  @override
  String get filter_button_clear => '필터 지우기';

  @override
  String get filter_button_main => '필터';

  @override
  String get code_list_no_results_title => '일치하는 초대 코드 없음';

  @override
  String get code_list_no_results_description => '더 많은 초대 코드를 보려면 검색어를 변경하세요.';

  @override
  String get code_list_search_hint => '초대 코드 검색';

  @override
  String get code_list_search_hint_compact => '코드 검색';

  @override
  String code_list_active_count(int count) {
    return '활성 초대 코드 $count개';
  }

  @override
  String code_list_total_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '초대 $count개',
      one: '초대 1개',
    );
    return '$_temp0';
  }

  @override
  String get code_list_page_size => '행';

  @override
  String get code_list_rows_per_page => '페이지당 행 수:';

  @override
  String code_list_page(int page) {
    return '$page페이지';
  }

  @override
  String code_list_page_range(int start, int end, int count) {
    return '$count개 중 $start–$end';
  }

  @override
  String code_list_page_loading(int start, int end) {
    return '$start–$end 불러오는 중...';
  }

  @override
  String get code_list_page_fetch_error =>
      '다음 페이지를 불러올 수 없습니다. 연결을 확인하고 다시 시도하세요.';

  @override
  String get code_list_retry => '다시 시도';

  @override
  String get code_list_previous_page => '이전 페이지';

  @override
  String get code_list_next_page => '다음 페이지';

  @override
  String get action_regenerate_invite_code => '초대 코드 재생성';

  @override
  String get dialog_qr_code_description =>
      '참여자가 이 연구에 접근할 수 있도록 링크나 QR 코드를 공유하세요. 참여자가 휴대전화로 링크를 열거나 QR 코드를 스캔하면 StudyU 앱이 열리고 연구에 참여하게 됩니다.';

  @override
  String get all_studies => '모든 연구';

  @override
  String get studies_filter_add_filter => '필터 추가';

  @override
  String get studies_filter_remove_filter => '필터 제거';

  @override
  String get studies_end_of_list_create => '연구를 만드세요.';

  @override
  String get studies_end_of_list_public => '원하는 연구를 찾지 못했나요?';

  @override
  String get error_qr_code_generation => 'QR 코드를 표시할 수 없습니다.';

  @override
  String get form_field_invite_link => '초대 링크';

  @override
  String get form_field_invite_link_tooltip =>
      '참여자가 StudyU 앱을 열고 연구에 참여할 수 있도록 이 링크를 공유하세요.';

  @override
  String get form_field_invitation_message => '초대 메시지';

  @override
  String invitation_message_intro(Object title) {
    return 'StudyU를 사용하여 “$title” 연구에 참여하도록 초대되었습니다.';
  }

  @override
  String get invitation_message_install_app =>
      '1. 필요한 경우 휴대폰에 StudyU Health 앱을 설치하세요:';

  @override
  String invitation_message_android(Object link) {
    return 'Android: $link';
  }

  @override
  String invitation_message_ios(Object link) {
    return 'iPhone/iPad: $link';
  }

  @override
  String get invitation_message_open_link => '2. 휴대폰에서 이 초대 링크를 여세요:';

  @override
  String get invitation_message_alternative =>
      '또는 StudyU Health 앱을 열고 다음 초대 코드를 입력하세요:';

  @override
  String get form_field_report_improvementDirection_hint => '개선 방향을 선택하세요';

  @override
  String get form_field_report_data_source_hint => '데이터 소스를 선택하세요';

  @override
  String get form_field_report_data_source_empty => '척도 설문 문항이 정의되지 않았습니다';
}

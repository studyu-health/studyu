// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get loading => '로딩 중';

  @override
  String get starting_study => '연구를 시작하는 중…';

  @override
  String get loading_error_title => '로딩 오류';

  @override
  String get loading_error_description =>
      '연구 데이터를 불러올 수 없습니다. 현재 연구에 참여 중이라면 먼저 연구 담당자에게 도움을 요청해 주세요. 연구에 참여 중이 아니거나 연구 담당자가 안내한 경우에만 앱 지원팀에 문의해 주세요.\n연구 담당자나 앱 지원팀의 안내 없이 데이터를 삭제하지 마세요. 데이터를 삭제하면 모든 연구 데이터가 삭제되며, 연구에 다시 참여해야 합니다.';

  @override
  String get try_again => '다시 시도';

  @override
  String get delete_all_data => '모든 데이터 삭제';

  @override
  String get delete_all_data_description =>
      '모든 데이터를 삭제하시겠습니까? 모든 연구 데이터가 삭제되며, 연구에 다시 참여해야 합니다.';

  @override
  String get reset_app => '앱 재설정';

  @override
  String get what_is_studyu => 'StudyU는 어떤 앱인가요?';

  @override
  String get description_part1 =>
      '다음과 같은 문장을 읽었다고 생각해 보세요. “오후 6시 이후에 식사하면 수면의 질이 떨어진다.”';

  @override
  String get description_part2 =>
      '그러면 이런 생각이 들 수 있습니다. “알아 두면 좋겠지만… 모든 사람에게 해당할까? 나에게도 그럴까?”';

  @override
  String get description_part3 =>
      '하지만 본인이 그 연구에 직접 참여한 것은 아니므로, 이 질문에 바로 답할 수는 없습니다. 일반적인 연구로는 수면의 질이 영향을 받을 가능성이 더 높은지만 알 수 있습니다. 늦은 식사가 본인의 수면에 어떤 영향을 미치는지는 직접 확인해야 합니다.';

  @override
  String get description_part4 =>
      '이를 확인하려면 늦게 식사하는 기간과 늦게 식사하지 않는 기간을 나누어, 본인을 대상으로 연구를 진행해야 합니다. 수면의 질을 정기적으로 평가하고 결과를 비교하면 늦은 식사가 본인의 수면의 질을 떨어뜨리는지 판단할 수 있습니다. StudyU는 이런 질문에 신뢰할 수 있는 답을 얻도록 돕는 것을 목표로 합니다.';

  @override
  String get description_part5 =>
      'StudyU에서는 전문가가 설계한 N-of-1 연구에 참여할 수 있습니다. N-of-1은 연구 참여자 수를 나타내는 N이 1명이라는 뜻입니다. 일반적인 임상시험과 마찬가지로 N-of-1 연구에도 명확한 연구 계획, 즉 연구 프로토콜이 필요합니다.';

  @override
  String get description_part6 =>
      '좋은 연구 프로토콜을 직접 만들기는 쉽지 않습니다. 그래서 StudyU를 개발했습니다. 관심사에 맞는 N-of-1 연구를 선택하면, 신뢰할 수 있는 결과를 얻을 수 있도록 전문가가 설계한 연구 계획이 자동으로 제공됩니다.';

  @override
  String get description_part7 =>
      '연구를 선택하면 먼저 건강 상태가 연구 참여에 적합한지 확인합니다. 그다음 참여 등록을 하고 연구 계획을 일상생활에 맞게 조정할 수 있습니다. 늦게 식사하기나 피로도 평가 같은 과제를 정해진 주기(예: 하루 한 번)에 따라 수행해야 합니다. 최소 연구 기간(보통 몇 주)을 채우면 무료로 결과를 확인할 수 있습니다.';

  @override
  String get description_part8 =>
      '연구에 더 오래 참여하고 과제를 꾸준히 수행할수록 결과의 신뢰도가 높아집니다. 분석 결과가 왜곡되는 것을 막기 위해 결과를 확인한 뒤에는 해당 연구 참여를 계속할 수 없습니다. 진행률 표시줄에서 결과 확인까지 남은 과제 수와 몇 주 더 참여했을 때 결과의 신뢰도를 얼마나 높일 수 있는지 확인할 수 있습니다.';

  @override
  String get description_part9 => '설명은 여기까지입니다. 이제 StudyU를 시작해 보세요!';

  @override
  String get get_started => '시작하기';

  @override
  String get welcome_find_study_title => '나에게 맞는 방법 찾기';

  @override
  String get made_with_love_in_potsdam => '독일 포츠담에서, 정성을 담아 제작';

  @override
  String get browse_public_studies => '공개 연구 둘러보기';

  @override
  String get welcome_returning_participant => 'StudyU 연구에 참여한 적이 있나요?';

  @override
  String get show_onboarding_again => '시작 안내 다시 보기';

  @override
  String get onboarding_page0_title => 'StudyU에 오신 것을 환영합니다.';

  @override
  String get onboarding_page0_subtitle =>
      '연구진은 평균적으로 어떤 방법이 효과적인지 추정할 수 있습니다. 하지만 특정 습관이나 치료가 본인에게도 효과가 있는지까지 판단할 수는 없습니다. StudyU는 이를 직접 확인할 수 있도록 도와줍니다.';

  @override
  String get onboarding_page1_title => '나만을 위한 연구';

  @override
  String get onboarding_page1_subtitle =>
      'N-of-1 연구에서는 본인 한 명이 연구 참여자가 됩니다. 예를 들어 일찍 식사하는 기간과 늦게 식사하는 기간을 나누어 생활하면서, 수면의 질과 같은 결과를 기록합니다.';

  @override
  String get onboarding_page2_title => '전문가가 설계한 연구 계획';

  @override
  String get onboarding_page2_subtitle =>
      '궁금한 점에 맞는 연구를 선택하세요. StudyU는 전문가가 설계한 연구 계획을 제공하고, 안전하게 참여할 수 있는지 확인하며, 계획을 일상생활에 맞게 조정하도록 도와줍니다.';

  @override
  String get onboarding_page3_title => '정해진 과제 수행하기';

  @override
  String get onboarding_page3_subtitle =>
      '배정된 방법에 따라 과제를 수행하고 관찰 결과를 기록해 주세요. 보통 하루에 한 번 진행합니다. 진행률 표시줄에서 결과를 확인하기까지 남은 과제 수를 볼 수 있습니다.';

  @override
  String get onboarding_page4_title => '신뢰할 수 있는 근거 쌓기';

  @override
  String get onboarding_page4_subtitle =>
      '몇 주가 지나면 각 방법이 본인에게 어떤 효과가 있었는지 비교할 수 있습니다. 과제를 완료할수록 결과의 신뢰도가 높아집니다. 결과를 확인하면 분석 결과가 왜곡되지 않도록 StudyU가 해당 연구 참여를 종료합니다.';

  @override
  String get study_selection => '연구 선택';

  @override
  String get study_selection_single => '한 번에 하나의 연구에만 참여할 수 있습니다.';

  @override
  String get study_selection_single_why => '왜 그런가요?';

  @override
  String get study_selection_single_reason =>
      '여러 연구에 동시에 참여하면 각 연구의 중재가 서로 영향을 주어 결과가 달라질 수 있습니다.';

  @override
  String get study_selection_unsupported_title => '앱 업데이트 필요';

  @override
  String get study_selection_unsupported =>
      '참여하려는 연구는 현재 앱 버전과 호환되지 않습니다. 앱을 최신 버전으로 업데이트해 주세요.';

  @override
  String get study_selection_closed_title => '신규 등록 마감';

  @override
  String get study_selection_closed => '이 연구는 현재 신규 참여자를 받지 않습니다.';

  @override
  String get study_selection_hidden_studies =>
      '일부 연구를 표시할 수 없습니다. 앱 버전이 오래된 경우 이런 문제가 발생할 수 있습니다. 참여 가능한 모든 연구를 보려면 앱을 최신 버전으로 업데이트하세요. 또는 아래에 표시된 연구 중 하나에 참여할 수 있습니다.';

  @override
  String get study_selection_no_public_studies =>
      '현재 참여할 수 있는 공개 연구가 없습니다. 초대 코드가 있으면 비공개 연구에 참여할 수 있습니다.';

  @override
  String get study_overview_title => '연구 개요';

  @override
  String get eligibility_questionnaire_title => '참여 가능 여부 확인';

  @override
  String get please_answer_eligibility =>
      '이 연구에 안전하게 참여할 수 있는지 확인하기 위해 몇 가지 질문에 답해 주세요';

  @override
  String get intervention_selection_title => '중재 선택';

  @override
  String get please_select_interventions => '연구에서 비교할 두 가지 방법(중재)을 선택해 주세요.';

  @override
  String get please_select_interventions_description =>
      '연구 기간 동안 두 중재의 효과를 측정하고 비교합니다.';

  @override
  String get no_interventions_available => '선택할 수 있는 중재가 없습니다.';

  @override
  String get task_already_completed => '오늘 이 과제를 이미 완료했습니다.';

  @override
  String get task_cannot_be_completed => '이 과제를 완료할 수 없습니다.';

  @override
  String get task_outside_period => '중재 기간이 아니므로 이 과제를 완료할 수 없습니다.';

  @override
  String get study_notification_body => '새 과제를 확인해 주세요.';

  @override
  String get intervention_phase_duration => '중재 기간';

  @override
  String get days => '일';

  @override
  String get study_length => '연구 기간';

  @override
  String get study_publisher => '연구 게시자';

  @override
  String get tasks_daily => '과제:';

  @override
  String get baseline_description =>
      '기초 관찰 기간은 이후 결과와 비교하기 위해 연구 시작 시의 상태를 측정하는 기간입니다. 이 기간에는 평소처럼 생활하며, 연구에서 정한 중재는 아직 시행하지 않습니다.';

  @override
  String get baseline => '기초 관찰 기간';

  @override
  String get days_left => '남은 일수';

  @override
  String get today_tasks => '오늘의 과제';

  @override
  String get intervention_current => '현제 중재';

  @override
  String get opt_out => '연구 참여 종료';

  @override
  String get leave_study_keep_data_title => '연구 참여를 종료하고 데이터를 보관하시겠습니까?';

  @override
  String leave_study_keep_data_body(String studyName) {
    return '“$studyName” 연구 참여를 종료합니다. 지금까지 제출한 진행 기록과 응답은 보관되며, 연구진은 익명화된 데이터를 계속 사용할 수 있습니다.\n\n참여를 종료하면 기존 참여를 이어서 진행할 수 없습니다. 이전에 참여한 다른 연구에는 영향을 주지 않습니다.';
  }

  @override
  String get stay_in_study => '계속 참여하기';

  @override
  String get acknowledge_consequences => '위 내용을 읽고, 진행 시 어떤 일이 일어나는지 이해했습니다.';

  @override
  String get leave_keep_data => '참여 종료 및 데이터 보관';

  @override
  String get delete_data => '참여 종료 및 데이터 삭제';

  @override
  String get leave_study_delete_data_title => '연구 참여를 종료하고 데이터를 삭제하시겠습니까?';

  @override
  String leave_study_delete_data_body(String studyName) {
    return '“$studyName” 연구 참여를 종료합니다. 이 연구의 진행 기록과 응답을 서버에서 영구적으로 삭제하고, 이 기기에 저장된 데이터도 삭제합니다.\n\n삭제는 되돌릴 수 없습니다. 본인과 연구팀(관리자) 모두 이 데이터를 복구할 수 없습니다.';
  }

  @override
  String get leave_delete_data => '참여 종료 및 데이터 삭제';

  @override
  String get your_journey => '나의 연구 일정';

  @override
  String get journey_overview_description => '계속하기 전에 연구 진행 일정을 확인하세요.';

  @override
  String get journey_results_available => '결과 확인 가능';

  @override
  String get consent => '동의';

  @override
  String get error => '오류가 발생했습니다.';

  @override
  String get please_give_consent =>
      '연구에 참여하려면 동의가 필요합니다. 각 항목을 눌러 내용을 모두 읽은 뒤 동의 여부를 선택해 주세요.';

  @override
  String get please_give_consent_why => '왜 필요한가요?';

  @override
  String get please_give_consent_reason =>
      '참여자의 안전과 개인정보 보호를 위해 연구마다 별도의 동의가 필요합니다. 각 연구에 참여하려면 참여 의사를 명확히 밝혀 동의해야 합니다.';

  @override
  String get user_did_not_give_consent => '동의하지 않으셨습니다. 참여하려면 동의가 필요합니다.';

  @override
  String get dashboard => '대시보드';

  @override
  String get study_not_available_for_testing_yet => '이 연구는 아직 테스트할 수 없습니다.';

  @override
  String get help => '도움말';

  @override
  String get contact => '문의하기';

  @override
  String support_email_body(String subjectId) {
    return '안녕하세요.\n\nStudyU 앱에서 데이터를 불러오는 중 오류가 발생했습니다.\n참여자 ID: $subjectId\n\n문제를 해결할 수 있도록 도움을 부탁드립니다.\n\n감사합니다.';
  }

  @override
  String get about => '정보';

  @override
  String get study_information => '연구 정보';

  @override
  String get study_information_description => '연구팀에서 요청하는 경우에만 이 정보를 공유하세요.';

  @override
  String get study_name => '연구 제목';

  @override
  String get study_id => '연구 ID';

  @override
  String get subject_id => '참여자 ID';

  @override
  String get study_start_date => '연구 시작일';

  @override
  String get app_version => '앱 버전';

  @override
  String get platform => '플랫폼';

  @override
  String get not_available => '확인 할 수 없음';

  @override
  String get view_study_information => '세부 정보 보기';

  @override
  String get email_study_team => '연구팀에 문의';

  @override
  String get study_team_email_unavailable => '연구팀의 문의 이메일 주소가 등록되어 있지 않습니다.';

  @override
  String get copy_all_information => '모두 복사';

  @override
  String get all_information_copied => '모든 정보가 클립보드에 복사되었습니다.';

  @override
  String get participant_information_email_subject => '[StudyU] 참여자 정보';

  @override
  String get participant_information_email_intro =>
      '안녕하세요.\n\n연구 참여와 관련하여 문의드립니다. 제 StudyU 정보는 다음과 같습니다.';

  @override
  String get email_app_unavailable => '사용할 수 있는 이메일 앱이 없습니다.';

  @override
  String get settings => '설정';

  @override
  String get yes => '예';

  @override
  String get no => '아니요';

  @override
  String get confirm => '선택 확인';

  @override
  String get complete => '완료';

  @override
  String get cancel => '취소';

  @override
  String get accept => '수락';

  @override
  String get decline => '거절';

  @override
  String get next => '다음';

  @override
  String get back => '뒤로';

  @override
  String get done => '완료';

  @override
  String get completed => '완료됨';

  @override
  String get faq_full => '자주 묻는 질문';

  @override
  String get faq => '자주 묻는 질문';

  @override
  String get next_day => '다음 날';

  @override
  String get could_not_save_results => '결과를 저장할 수 없습니다';

  @override
  String get take_a_photo => '사진 촬영';

  @override
  String get start_recording => '녹음 시작';

  @override
  String get stop_recording => '녹음 중지';

  @override
  String get photo_captured => '사진 촬영 완료';

  @override
  String get audio_recorded => '녹음 완료';

  @override
  String get multimodal_not_supported =>
      '다양한 형태의 데이터를 수집하는 멀티모달 연구는 현재 웹 브라우저에서 실행할 수 없습니다. Android 또는 iOS용 StudyU 앱을 사용해 주세요.';

  @override
  String get camera_access_denied => '카메라 사용 권한이 없습니다';

  @override
  String get no_camera_available => '사용할 수 있는 카메라가 없습니다.';

  @override
  String get microphone_access_denied => '마이크 사용 권한이 없습니다';

  @override
  String get camera_error => '카메라 오류';

  @override
  String get recording_error => '녹음 오류';

  @override
  String get language => '언어';

  @override
  String get use_device_language => '기기 언어 사용';

  @override
  String get en => '영어';

  @override
  String get de => '독일어';

  @override
  String get current_report => '현재 보고서';

  @override
  String get report_history => '보고서 기록';

  @override
  String get no_reports_found => '아직 등록된 보고서가 없습니다.';

  @override
  String get current_power_level => '현재 상태';

  @override
  String get not_enough_data => '데이터 부족';

  @override
  String get barely_enough_data => '최소한의 데이터 확보';

  @override
  String get enough_data => '충분한 데이터 확보';

  @override
  String get legal_documents => '약관 및 법적 안내';

  @override
  String get legal_documents_description => '계속하려면 아래 문서를 읽고 동의해 주세요.';

  @override
  String get terms => '이용 약관';

  @override
  String get terms_read => '이용 약관 읽기';

  @override
  String get terms_content => '이용 약관에서는 StudyU 앱의 목적과 이용 방법을 안내합니다.';

  @override
  String get terms_agree => '이용 약관을 읽었으며 이에 동의합니다';

  @override
  String get privacy => '개인정보 처리방침';

  @override
  String get privacy_read => '개인정보 처리방침 읽기';

  @override
  String get privacy_content =>
      '개인정보 처리방침에서는 어떤 데이터를 언제, 어디에, 왜 저장하는지와 데이터 접근 권한, 이용자의 권리를 안내합니다.';

  @override
  String get privacy_agree => '개인정보 처리방침을 읽었으며 이에 동의합니다';

  @override
  String get legal_notice => '법적 고지';

  @override
  String get legal_notice_content => '법적 고지에는 StudyU의 책임자와 문의 방법이 나와 있습니다.';

  @override
  String get imprint_read => '법적 고지 읽기';

  @override
  String get invite_code_button => '초대 코드로 참여';

  @override
  String get private_study_invite_code => '초대 코드 입력';

  @override
  String get private_study_invite_code_description => '연구팀에서 받은 코드를 입력하세요.';

  @override
  String get invite_code => '초대 코드';

  @override
  String get invalid_invite_code => '유효하지 않은 초대 코드입니다.';

  @override
  String get was_saved_to => '파일 저장 위치: ';

  @override
  String get save_not_supported => '오류';

  @override
  String get save_not_supported_description => '현재 웹 버전에서는 파일 다운로드를 지원하지 않습니다.';

  @override
  String get eligible_no => '이 연구의 참여 조건에 해당하지 않습니다';

  @override
  String get eligible_yes => '이 연구의 참여 조건에 해당합니다';

  @override
  String get eligible_mistake => '잘못 입력한 내용이 있다면 답변을 수정할 수 있습니다.';

  @override
  String get eligible_choice_multi_selection => '해당하는 항목을 모두 선택해 주세요 (선택 사항)';

  @override
  String get eligible_choice_multi_selection_required =>
      '해당하는 항목을 모두 선택해 주세요 (하나 이상 필수)';

  @override
  String get report_overview => '보고서 개요';

  @override
  String get report_primary_result => '주요 결과';

  @override
  String get report_disclaimer => '이 보고서는 모든 정보를 올바르게 입력했을 경우에만 유효합니다.';

  @override
  String get performance => '과제 수행 현황';

  @override
  String get performance_overview => '과제 수행 현황';

  @override
  String get performance_overview_interventions => '중재';

  @override
  String get performance_overview_observations => '관찰';

  @override
  String get completed_study =>
      '최근 참여한 연구를 완료했습니다. 이전 보고서를 확인하거나 새 연구를 시작해 보세요.';

  @override
  String get app_support => '앱 관련 문의';

  @override
  String get app_support_text => '앱 관련 문제나 궁금한 점은 여기에 문의해 주세요.';

  @override
  String get study_support => '연구 관련 문의';

  @override
  String get study_support_text => '연구 관련 문제나 궁금한 점은 여기에 문의해 주세요.';

  @override
  String get organization => '기관';

  @override
  String get irb => '기관생명윤리위원회(IRB)';

  @override
  String get researchers => '연구진';

  @override
  String get website => '웹사이트';

  @override
  String get email => '이메일';

  @override
  String get phone => '전화번호';

  @override
  String get additionalInfo => '추가 정보';

  @override
  String free_text_min_length_error(num min) {
    return '최소 $min자 이상 입력해 주세요';
  }

  @override
  String free_text_max_length_error(num max) {
    return '최대 $max자까지 입력해 주세요';
  }

  @override
  String get free_text_alphanumeric_error => '영문자와 숫자만 입력해 주세요.';

  @override
  String get free_text_numeric_error => '숫자만 입력해 주세요';

  @override
  String get free_text_custom_error => '안내된 형식에 맞게 입력해 주세요.';

  @override
  String get app_outdated_message =>
      'StudyU 앱의 새 버전이 있습니다. 최신 기능과 개선 사항을 이용하려면 앱을 업데이트해 주세요. 함께해 주셔서 감사합니다!';

  @override
  String get update_now => '지금 업데이트';

  @override
  String get text_summary_section_prefix_higher => '본인의 ';

  @override
  String get text_summary_section_was_higher => ' 수치가 더 높았던 중재: ';

  @override
  String get text_summary_section_was_lower => ' 수치가 더 낮았던 중재: ';

  @override
  String get text_summary_section_compared_to => ' / 비교 대상: ';

  @override
  String get text_summary_section_and => ' 및 ';

  @override
  String get text_summary_section_no_evidence =>
      '다음 항목에서 중재 간 차이가 있다는 근거는 확인되지 않았습니다: ';

  @override
  String get text_summary_section_between => ' / 비교한 중재: ';

  @override
  String get intervention => '중재';

  @override
  String get phase => '단계';

  @override
  String get day => '일';

  @override
  String get no_data_available_yet => '아직 표시할 데이터가 없습니다.';

  @override
  String get value => '값';

  @override
  String get show_colorless_gauges => '접근성을 높인 차트 사용';

  @override
  String get mean => '평균';

  @override
  String get t_statistic => 't-통계량';

  @override
  String get degrees_of_freedom => '자유도';

  @override
  String get p_value => 'p값';

  @override
  String get level_of_significance => '유의수준';

  @override
  String get t_test_outcome_based_on => '다음 값을 바탕으로 결과를 분석했습니다.';

  @override
  String get statistical_information => '통계 정보';

  @override
  String get close => '닫기';

  @override
  String get significance_level_and_p_value => '유의수준 및 p값';

  @override
  String compare_results_between(String nameA, String nameB) {
    return '$nameA 및 $nameB 결과 비교';
  }

  @override
  String get missing_observations_note => '참고: 관측값이 없는 날은 데이터가 기록되지 않은 날입니다.';

  @override
  String get quick_summary => '간단 요약';

  @override
  String get average_score => '평균 점수';

  @override
  String get data_completeness => '데이터 완전성';

  @override
  String get statistic => '통계량';

  @override
  String get total_recordings => '총 기록 수';

  @override
  String get missing_recordings => '누락된 기록 수';

  @override
  String get average => '평균';

  @override
  String get minimum => '최소값';

  @override
  String get maximum => '최대값';

  @override
  String get support_email_sent => '이메일 작성 화면을 열었습니다';

  @override
  String get support_email_sent_description =>
      '연구팀에 보낼 메시지가 이메일 앱에 준비되었습니다. 내용을 확인하고 이메일을 보낸 뒤, 연구팀의 답변을 기다려 주세요.\n\n현재 연구에 참여 중이라면 문제가 해결될 때까지 앱 외부에서 결과를 계속 기록해 주세요.';

  @override
  String get sync_fitbit_data => 'Fitbit 데이터 동기화';

  @override
  String get fitbit_data_synced => 'Fitbit 데이터가 동기화되었습니다.';

  @override
  String get fitbit_data_not_synced =>
      'Fitbit 데이터를 동기화할 수 없습니다. 먼저 Fitbit 앱에서 데이터 동기화를 완료했는지 확인해 주세요.';

  @override
  String error_syncing_fitbit_data(String error) {
    return 'Fitbit 데이터 동기화 중 오류가 발생했습니다: $error';
  }

  @override
  String get fitbit_data_synced_dialog_title => 'Fitbit 데이터 동기화 완료';

  @override
  String get fitbit_data_synced_info => '다음 유형의 데이터가 동기화되었습니다.';

  @override
  String fitbit_data_earliest_date(String date) {
    return '가장 오래된 데이터 날짜: $date';
  }

  @override
  String fitbit_data_latest_date(String date) {
    return '가장 최근 데이터 날짜: $date';
  }

  @override
  String get fitbit_data_details_btn => '세부 정보';

  @override
  String get fitbit_data_close_btn => '닫기';

  @override
  String get painIndicatorText => '통증 정도';

  @override
  String get dialogTitle => '통증 정도 선택';

  @override
  String get cancelButton => '취소';

  @override
  String get painLevel_0 => '통증 없음';

  @override
  String get painLevel_2 => '약간 아픔';

  @override
  String get painLevel_4 => '조금 더 아픔';

  @override
  String get painLevel_6 => '훨씬 더 아픔';

  @override
  String get painLevel_8 => '매우 아픔';

  @override
  String get painLevel_10 => '상상할 수 있는 가장 심한 통증';

  @override
  String get body_head => '머리';

  @override
  String get body_head_front => '머리 앞쪽';

  @override
  String get body_face => '얼굴';

  @override
  String get body_forehead => '이마';

  @override
  String get body_eyes => '눈';

  @override
  String get body_nose => '코';

  @override
  String get body_mouth => '입';

  @override
  String get body_head_back => '머리 뒤쪽';

  @override
  String get body_inner_ear_balance => '내이(속귀) / 균형(평형)';

  @override
  String get body_neck => '목';

  @override
  String get body_neck_front => '목 앞쪽';

  @override
  String get body_neck_back => '뒷목';

  @override
  String get body_torso => '몸통';

  @override
  String get body_chest => '가슴';

  @override
  String get body_left_chest => '왼쪽 가슴';

  @override
  String get body_right_chest => '오른쪽 가슴';

  @override
  String get body_breastbone => '가슴뼈(흉골)';

  @override
  String get body_upper_back => '등 위쪽';

  @override
  String get body_left_shoulder_blade => '왼쪽 어깨뼈';

  @override
  String get body_right_shoulder_blade => '오른쪽 어깨뼈';

  @override
  String get body_spine_upper_middle => '척추 위쪽/중간';

  @override
  String get body_abdomen => '배(복부)';

  @override
  String get body_upper_abdomen => '윗배';

  @override
  String get body_lower_abdomen => '아랫배';

  @override
  String get body_left_side_abdomen => '배 왼쪽 옆면';

  @override
  String get body_right_side_abdomen => '배 오른쪽 옆면';

  @override
  String get body_lower_back => '허리';

  @override
  String get body_spine_lower => '척추 아래쪽';

  @override
  String get body_left_flank => '왼쪽 옆구리';

  @override
  String get body_right_flank => '오른쪽 옆구리';

  @override
  String get body_arms => '팔';

  @override
  String get body_left_arm => '왼팔';

  @override
  String get body_left_shoulder => '왼쪽 어깨';

  @override
  String get body_left_upper_arm => '왼쪽 위팔(상완)';

  @override
  String get body_left_bicep => '왼쪽 위팔 앞쪽 근육 (이두근)';

  @override
  String get body_left_tricep => '왼쪽 위팔 뒤쪽 근육 (삼두근)';

  @override
  String get body_left_elbow => '왼쪽 팔꿈치';

  @override
  String get body_left_lower_arm => '왼쪽 아래팔';

  @override
  String get body_left_forearm => '왼쪽 앞팔 (전완)';

  @override
  String get body_left_wrist => '왼쪽 손목';

  @override
  String get body_left_hand => '왼손';

  @override
  String get body_left_palm => '왼손바닥';

  @override
  String get body_left_fingers => '왼쪽 손가락';

  @override
  String get body_right_arm => '오른팔';

  @override
  String get body_right_shoulder => '오른쪽 어깨';

  @override
  String get body_right_upper_arm => '오른쪽 위팔(상완)';

  @override
  String get body_right_bicep => '오른쪽 위팔 앞쪽 근육 (이두근)';

  @override
  String get body_right_tricep => '오른쪽 위팔 뒤쪽 근육 (삼두근)';

  @override
  String get body_right_elbow => '오른쪽 팔꿈치';

  @override
  String get body_right_lower_arm => '오른쪽 아래팔';

  @override
  String get body_right_forearm => '오른쪽 앞팔 (전완)';

  @override
  String get body_right_wrist => '오른쪽 손목';

  @override
  String get body_right_hand => '오른손';

  @override
  String get body_right_palm => '오른손바닥';

  @override
  String get body_right_fingers => '오른쪽 손가락';

  @override
  String get body_lower_body => '하체';

  @override
  String get body_pelvis => '골반';

  @override
  String get body_groin => '사타구니';

  @override
  String get body_hips => '엉덩이 / 골반';

  @override
  String get body_buttocks => '엉덩이';

  @override
  String get body_legs => '다리';

  @override
  String get body_left_leg => '왼쪽 다리';

  @override
  String get body_left_upper_leg => '왼쪽 허벅지';

  @override
  String get body_left_thigh_front => '왼쪽 허벅지 (앞)';

  @override
  String get body_left_thigh_back => '왼쪽 허벅지 (뒤)';

  @override
  String get body_left_knee => '왼쪽 무릎';

  @override
  String get body_left_lower_leg => '왼쪽 아랫다리';

  @override
  String get body_left_shin => '왼쪽 정강이';

  @override
  String get body_left_calf => '왼쪽 종아리';

  @override
  String get body_left_ankle => '왼쪽 발목';

  @override
  String get body_left_foot => '왼발';

  @override
  String get body_left_heel => '왼쪽 발뒤꿈치';

  @override
  String get body_left_foot_sole => '왼쪽 발바닥/발바닥 아치';

  @override
  String get body_left_toes => '왼쪽 발가락';

  @override
  String get body_right_leg => '오른쪽 다리';

  @override
  String get body_right_upper_leg => '오른쪽 허벅지';

  @override
  String get body_right_thigh_front => '오른쪽 허벅지 (앞)';

  @override
  String get body_right_thigh_back => '오른쪽 허벅지 (뒤)';

  @override
  String get body_right_knee => '오른쪽 무릎';

  @override
  String get body_right_lower_leg => '오른쪽 아랫다리';

  @override
  String get body_right_shin => '오른쪽 정강이';

  @override
  String get body_right_calf => '오른쪽 종아리';

  @override
  String get body_right_ankle => '오른쪽 발목';

  @override
  String get body_right_foot => '오른발';

  @override
  String get body_right_heel => '오른쪽 발뒤꿈치';

  @override
  String get body_right_foot_sole => '오른쪽 발바닥/발바닥 아치';

  @override
  String get body_right_toes => '오른쪽 발가락';

  @override
  String get painTypeLabel => '통증 유형';

  @override
  String get bodyPartLabel => '신체 부위';

  @override
  String get painTypeUnspecified => '선택 안 함';

  @override
  String get painTypeBurning => '화끈거림';

  @override
  String get painTypeStabbing => '칼로 찌르는 듯한 통증';

  @override
  String get painTypeAching => '쑤심';

  @override
  String get painTypeThrobbing => '욱신거림';

  @override
  String get painTypeSharp => '날카로운 통증';

  @override
  String get painTypeDull => '둔탁한 통증';

  @override
  String get painTypeCramping => '쥐가 나거나 쥐어짜는 듯한 통증';

  @override
  String get painTypeRadiating => '주변으로 퍼지는 통증 (방사통)';

  @override
  String get painTypeTingling => '저리거나 따끔거림';

  @override
  String get painTypeShooting => '쏘는 듯한 통증';

  @override
  String get painTypePulsing => '맥박처럼 뛰는 느낌';

  @override
  String get painTypePressure => '압박감';

  @override
  String get painTypeTightness => '조이는 느낌';

  @override
  String get painTypeSoreness => '뻐근함';

  @override
  String get painTypeStiffness => '뻣뻣함';

  @override
  String get preview_mode => '미리보기 모드';

  @override
  String get preview_mode_active => '미리보기 모드 사용 중';

  @override
  String get preview_mode_active_state => '미리보기 모드가 켜졌습니다.';

  @override
  String get preview_mode_inactive_state => '미리보기 모드가 꺼졌습니다.';

  @override
  String get preview_mode_description =>
      '현재 미리보기 모드입니다. 다음 기능을 사용할 수 있습니다.\n\n• “다음 날” 버튼으로 연구 일정을 빠르게 진행\n• 제한 없이 과제를 여러 번 수행\n• 실제 데이터에 영향을 주지 않고 전체 연구 과정 체험\n\n중요: 미리보기 모드의 결과와 데이터는 저장되지 않으며, 진행 중인 연구의 실제 참여자 결과와 섞이지 않습니다.';

  @override
  String get preview_mode_results_not_saved =>
      '미리보기 모드에서 과제를 완료했습니다. 실제 연구 데이터에 영향을 주지 않도록 결과는 저장되지 않습니다.';

  @override
  String get ok => '확인';

  @override
  String get study_settings_section => '연구 설정';

  @override
  String get recovery_phrase_header => '복구 문구';

  @override
  String get copied_to_clipboard =>
      '클립보드에 복사했습니다. 지금 복구 문구를 휴대전화의 안전한 곳에 붙여 넣어 보관해 주세요.';

  @override
  String get show_recovery_phrase => '복구 문구 보기';

  @override
  String get recovery_phrase_saved_confirmation =>
      '13개 단어를 모두 안전한 곳에 보관했으며, 계정을 복구할 때 다시 확인할 수 있습니다. “연구 설정”에서도 복구 문구를 다시 볼 수 있습니다.';

  @override
  String get recovery_phrase_rotate_button => '복구 문구 재발급';

  @override
  String get recovery_phrase_rotate_dialog_title => '복구 문구를 재발급하시겠습니까?';

  @override
  String get recovery_phrase_rotate_dialog_description =>
      '재발급하면 기존 복구 문구는 즉시 사용할 수 없게 됩니다. 나중에 계정을 복구할 수 있도록 새 복구 문구를 반드시 보관해 주세요.';

  @override
  String get recovery_phrase_rotate_acknowledgement =>
      '기존 복구 문구를 즉시 사용할 수 없게 된다는 점을 이해했습니다.';

  @override
  String get recovery_phrase_rotate_confirm => '문구 재발급';

  @override
  String get recovery_phrase_rotate_success =>
      '새 복구 문구가 발급되었습니다. 지금 안전한 곳에 보관해 주세요.';

  @override
  String get recovery_phrase_rotate_error => '새 복구 문구를 발급할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get continue_to_study => '완료';

  @override
  String get restore_account => '계정 복구';

  @override
  String get enter_recovery_phrase => '복구 문구를 입력하세요';

  @override
  String get restore_account_signed_in_title => '이미 로그인되어 있습니다';

  @override
  String get restore_account_signed_in_description =>
      '이 기기에는 이미 로그인되어 있습니다. 계정을 복구하면 현재 로그인된 계정이 복구한 계정으로 바뀝니다. 복구에 사용한 문구는 이후에도 계속 사용할 수 있습니다.';

  @override
  String get required => '필수';

  @override
  String get invalid_recovery_phrase =>
      '이 복구 문구와 일치하는 계정이 없습니다. 13개 단어를 올바른 순서로 입력했는지 확인해 주세요.';

  @override
  String get recovery_phrase_too_many_words =>
      '복구 문구는 13개 단어로 이루어져 있습니다. 초과한 단어를 지워 주세요.';

  @override
  String deep_link_study_not_found(String studyId) {
    return '연구 ID $studyId에 해당하는 연구를 찾을 수 없거나 이용할 수 없습니다.';
  }

  @override
  String get recovery_in_progress => '계정을 복구하는 중...';

  @override
  String get recovery_failed => '계정을 복구하지 못했습니다. 복구 문구를 확인한 뒤 다시 시도해 주세요.';

  @override
  String get recovery_user_not_found => '이 복구 문구와 일치하는 계정을 찾을 수 없습니다.';

  @override
  String get recovery_network_error =>
      '네트워크 오류가 발생했습니다. 인터넷 연결을 확인한 뒤 다시 시도해 주세요.';

  @override
  String get restore_account_description =>
      '연구에 참여하기 전에 저장한 복구 문구를 사용하여 이 기기에서 계정을 복구하세요.';

  @override
  String get file_saved => '파일이 저장되었습니다';

  @override
  String get file_save_error => '파일 저장 오류';

  @override
  String get copy_btn => '복사';

  @override
  String get download_btn => '다운로드';

  @override
  String get general_section => '일반';

  @override
  String get participation_options_section => '연구 참여 관리';

  @override
  String get recovery_phrase_load_error => '복구 문구를 불러오지 못했습니다';

  @override
  String get deep_link_study_invite_only => '이 연구에 참여하려면 초대 코드가 필요합니다.';

  @override
  String deep_link_invite_invalid(String code) {
    return '잘못되었거나 만료된 초대 코드: $code';
  }

  @override
  String get deep_link_switch_warning_title => '이미 연구에 참여 중입니다';

  @override
  String deep_link_switch_warning_description(
    String currentStudy,
    String targetStudy,
  ) {
    return '현재 참여 중인 연구:\n$currentStudy\n\n이 링크로 연결되는 연구:\n$targetStudy\n\n현재 연구로 돌아가는 것을 권장합니다. 현재 연구 참여를 종료한 뒤 다른 연구로 전환할 수도 있습니다.';
  }

  @override
  String deep_link_switch_warning_opt_out_instruction(String optOut) {
    return '현재 연구 참여를 종료하려면 먼저 “설정”에서 “$optOut” 메뉴를 선택해 주세요. 그런 다음 초대 링크를 다시 열어 주세요.';
  }

  @override
  String get deep_link_switch_open_settings => '설정 열기';

  @override
  String get deep_link_switch_continue_study => '연구 계속하기';

  @override
  String get you_have_been_invited => '연구에 초대되었습니다!';

  @override
  String get download_app_join => 'StudyU 앱 다운로드 및 연구 참여';

  @override
  String get deleted_study_error_title => '연구를 이용할 수 없습니다';

  @override
  String get deleted_study_error_description =>
      '이 연구는 더 이상 서버에서 이용할 수 없습니다. 현재 데이터는 이 기기에 남아 있습니다. 데이터를 삭제하기 전에 연구 담당자나 앱 지원팀에 문의해 주세요. “모든 데이터 삭제”는 담당자나 앱 지원팀에서 앱을 재설정하라고 안내한 경우에만 선택해 주세요.';

  @override
  String get dashboard_showcase_progress_title => '연구 진행 현황';

  @override
  String get dashboard_showcase_progress_description =>
      '현재 연구 진행 단계와 남은 일정을 확인할 수 있습니다.';

  @override
  String get dashboard_showcase_current_intervention_title => '현재 중재';

  @override
  String get dashboard_showcase_current_intervention_description =>
      '현재 중재와 해당 단계에 남은 일수를 확인할 수 있습니다.';

  @override
  String get dashboard_showcase_today_tasks_title => '오늘의 과제';

  @override
  String get dashboard_showcase_today_tasks_description =>
      '오늘 연구에서 수행해야 할 과제를 확인할 수 있습니다.';

  @override
  String get dashboard_showcase_contact_title => '문의하기';

  @override
  String get dashboard_showcase_contact_description => '연구팀의 도움이 필요할 때 이용하세요.';

  @override
  String get dashboard_showcase_report_title => '보고서';

  @override
  String get dashboard_showcase_report_description =>
      '결과를 확인할 수 있게 되면 현재 보고서를 열어 보세요.';

  @override
  String get dashboard_showcase_menu_title => '더 보기';

  @override
  String get dashboard_showcase_menu_description =>
      '설정, 자주 묻는 질문, 보고서 기록 등을 확인할 수 있습니다.';

  @override
  String get dashboard_showcase_finish => '완료';

  @override
  String get support_email_subject_loading_error =>
      'StudyU 지원 요청 - 데이터 불러오기 오류';

  @override
  String get support_email_subject_deleted_study => 'StudyU 지원 요청 - 연구 이용 불가';

  @override
  String deleted_study_support_email_body(String subjectId) {
    return '안녕하세요.\n\nStudyU 앱에 참여 중인 연구를 더 이상 서버에서 이용할 수 없다는 안내가 표시됩니다.\n참여자 ID: $subjectId\n\n기기에 저장된 데이터를 그대로 두어야 하는지, 앱을 재설정해야 하는지 안내 부탁드립니다.\n\n감사합니다.';
  }

  @override
  String get dashboard_tour => '대시보드 둘러보기';

  @override
  String get show_again => '둘러보기 다시 보기';

  @override
  String get free_text_hint => '답변을 입력해 주세요';

  @override
  String get preview_failed_to_initialize => '미리보기를 시작할 수 없습니다.';

  @override
  String get preview_overlay_reset_hint =>
      '현재 미리보기를 열 수 없습니다. 미리보기를 재설정한 뒤 다시 시도해 주세요.';

  @override
  String get preview_overlay_study_not_ready =>
      '이 연구의 미리보기를 아직 열 수 없습니다. 미리보기를 재설정한 뒤 다시 시도해 주세요.';

  @override
  String get preview_overlay_route_open_failed => '현재 미리보기 화면을 열 수 없습니다.';

  @override
  String get continue_label => '계속';

  @override
  String get questionnaire_review_title => '답변 검토';

  @override
  String get questionnaire_review_description =>
      '이전 답변을 변경했습니다. 설문을 완료하기 전에 이후 답변을 검토하세요.';

  @override
  String get questionnaire_review_confirmation => '답변을 검토했습니다';

  @override
  String get complete_task => '과제 완료';

  @override
  String get no_internet_connection =>
      '인터넷에 연결되어 있지 않습니다. 인터넷에 연결한 뒤 다시 시도해 주세요.';

  @override
  String error_occurred_with_message(String message) {
    return '오류가 발생했습니다: $message';
  }

  @override
  String get date_picker_button_label => '날짜 선택';

  @override
  String get date_picker_button_label_datetime => '날짜 선택';

  @override
  String get time_picker_button_label_datetime => '시간 선택';

  @override
  String get time_picker_button_label => '시간 선택';

  @override
  String get date_picker_clear => '지우기';

  @override
  String get date_picker_validation_required => '날짜를 선택해 주세요';

  @override
  String get time_picker_validation_required => '시간을 선택해 주세요';

  @override
  String get datetime_picker_validation_required => '날짜와 시간을 모두 선택해 주세요';

  @override
  String get time_picker_hint => '시간을 선택하세요';

  @override
  String get time_picker_validation_range => '선택 가능한 범위 안에서 시간을 선택해 주세요.';

  @override
  String time_picker_range_hint(Object min, Object max) {
    return '$min~$max 사이의 시간을 선택해 주세요.';
  }

  @override
  String time_picker_min_hint(Object min) {
    return '선택 가능한 가장 이른 시간: $min';
  }

  @override
  String time_picker_max_hint(Object max) {
    return '선택 가능한 가장 늦은 시간: $max';
  }

  @override
  String get please_select_interventions_why => '왜 필요한가요?';

  @override
  String get recovery_phrase_description =>
      '13개 단어를 안전한 곳에 보관해 주세요. 이 기기를 사용할 수 없게 되었을 때 계정을 복구할 수 있는 유일한 수단입니다.';

  @override
  String get recovery_phrase_why => '왜 필요한가요?';

  @override
  String get recovery_phrase_reason =>
      'StudyU는 비밀번호나 이메일 계정을 사용하지 않습니다. 이 13개 단어는 휴대전화를 바꾸거나 앱을 다시 설치했을 때 계정을 복구할 수 있는 유일한 수단입니다. 종이에 적어 두거나 본인만 접근할 수 있는 곳에 디지털 형태로 보관해 주세요. 다른 사람에게 절대 공유하지 마세요. “설정 → 연구 설정”에서 언제든지 복구 문구를 다시 확인할 수 있습니다.';

  @override
  String get study_not_started_title => '연구 참여 등록 완료';

  @override
  String get study_not_started_description =>
      '내일 다시 앱을 열어 연구를 시작해 주세요. 수행할 과제가 있으면 알림으로 알려드립니다.';

  @override
  String recovery_phrase_word_count(Object count, Object total) {
    return '$count/$total개 단어';
  }

  @override
  String get ko => '한국어';

  @override
  String get faq_section_data_storage_privacy => '데이터 저장 및 개인정보 보호';

  @override
  String get faq_question_data_storage => '데이터는 어디에 어떻게 저장되나요?';

  @override
  String get faq_answer_data_storage =>
      '수집된 데이터는 기기에 저장되며, 인터넷에 연결되면 보안 서버로 업로드됩니다. 모든 연구 데이터는 익명으로 수집·저장됩니다.';

  @override
  String get faq_question_personal_data => '앱은 어떤 개인정보를 수집하나요?';

  @override
  String get faq_answer_personal_data => '앱은 사용자의 개인정보를 수집하지 않습니다.';

  @override
  String get faq_section_studies => '연구';

  @override
  String get faq_question_study_duration => '연구를 완료하는 데 얼마나 걸리나요?';

  @override
  String get faq_answer_study_duration => '각 연구의 기간은 처음 연구를 선택할 때 안내됩니다.';

  @override
  String get faq_question_change_intervention => '다른 중재를 선택할 수 있나요?';

  @override
  String get faq_answer_change_intervention =>
      '연구를 시작하기 전에는 “중재 선택” 화면에서 다른 중재를 선택할 수 있습니다. 연구가 시작된 후에는 해당 연구 참여에서 선택한 중재를 바꿀 수 없습니다. 다른 중재를 선택하려면 “설정”에서 현재 연구 참여를 종료하고, 기존 데이터를 보관할지 영구적으로 삭제할지 선택해 주세요. 그런 다음 다시 참여 등록을 하면서 연구와 중재를 선택하세요.';

  @override
  String get faq_question_missed_tasks => '놓친 과제를 다른 날에 수행할 수 있나요?';

  @override
  String get faq_answer_missed_tasks =>
      '아니요. 놓친 과제를 다른 날에 수행할 수는 없습니다. 다만 같은 날에는 언제든지 완료할 수 있습니다.';

  @override
  String get faq_question_leave_study => '현재 연구 참여를 어떻게 종료할 수 있나요?';

  @override
  String get faq_answer_leave_study =>
      '대시보드의 “설정”에서 “연구 참여 종료”를 선택해 주세요. 참여는 종료되지만 진행 기록은 삭제되지 않아 연구 분석에 사용될 수 있습니다. 연구 참여를 종료하고 기기와 서버의 진행 기록도 모두 삭제하려면 “참여 종료 및 데이터 삭제”를 선택해 주세요. 해당 데이터는 기기와 서버에서 영구적으로 삭제됩니다.';

  @override
  String get faq_section_report_details => '보고서 세부 정보';

  @override
  String get faq_question_daily_tasks => '일일 과제란 무엇이며 어떻게 완료하나요?';

  @override
  String get faq_answer_daily_tasks =>
      '본인에게 가장 효과적인 중재를 확인하려면 각 중재에서 정한 과제를 매일 수행해야 합니다. 과제를 마친 뒤 반드시 “완료” 버튼을 눌러 주세요.';

  @override
  String get faq_question_rate_your_day => '“하루 평가”는 어떤 기능인가요?';

  @override
  String get faq_answer_rate_your_day =>
      '“하루 평가”는 연구 기간 동안 건강 상태를 기록하는 기능입니다. 건강과 관련된 몇 가지 질문에 1점부터 10점까지 점수를 매겨 답합니다.';

  @override
  String get faq_question_track_activities => '내 활동을 어떻게 확인할 수 있나요?';

  @override
  String get faq_answer_track_activities =>
      '“보고서 기록”에서 일일 과제 수행 현황과 건강 상태를 한눈에 확인할 수 있습니다.';

  @override
  String get faq_question_download_report => '연구 보고서를 어떻게 다운로드할 수 있나요?';

  @override
  String get faq_answer_download_report =>
      '연구에서 요구하는 최소 과제를 완료하면 보고서를 다운로드할 수 있습니다. 대시보드의 “보고서 기록” 탭에서 확인해 주세요.';

  @override
  String get debug_notifications_not_initialized =>
      '알림 기능이 아직 초기화되지 않았습니다. 연구를 시작한 뒤 “정보” 메뉴에서 이 기능을 다시 열어 주세요.';

  @override
  String get debug_test_notification_title => 'StudyU 테스트 알림';

  @override
  String get debug_test_notification_body =>
      'StudyU 알림이 정상적으로 수신되는지 확인하는 테스트 알림입니다.';

  @override
  String get debug_reset_success => '앱이 재설정되었습니다. 앱을 다시 시작해 주세요.';

  @override
  String get debug_reset_error => '앱을 재설정하는 중 오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get debug_screen_title => '디버그 화면';

  @override
  String get debug_send_information_via_email => '디버그 정보를 이메일로 보내기';

  @override
  String get debug_receive_test_notification => '테스트 알림 받기';

  @override
  String get debug_show_onboarding => '시작 안내 보기';

  @override
  String get invite_landing_instruction_title => 'StudyU Health로 연구에 참여하세요';

  @override
  String get invite_landing_qr_label => '연구 초대 QR 코드';

  @override
  String get invite_landing_invite_code => '초대 코드';

  @override
  String get invite_landing_invalid =>
      '이 초대는 더 이상 사용할 수 없습니다. 링크 또는 코드를 확인한 뒤 다시 시도해 주세요.';

  @override
  String get invite_landing_load_error => '초대를 불러올 수 없습니다. 나중에 다시 시도해 주세요.';

  @override
  String get invite_landing_loading => '초대를 불러오는 중…';

  @override
  String get scan_invite_code => 'QR 코드 스캔';

  @override
  String get scan_invite_code_description => '카메라를 연구 초대 QR 코드에 맞추세요.';

  @override
  String get open_study_app => 'StudyU Health에서 열기';

  @override
  String get invite_landing_google_play => 'Google Play에서 다운로드';

  @override
  String get invite_landing_app_store => 'App Store에서 다운로드';

  @override
  String get invite_landing_step_download => 'StudyU Health 앱 다운로드';

  @override
  String get invite_landing_step_join => '앱에서 연구 참여';

  @override
  String get invite_landing_step_join_description =>
      '휴대전화에서 StudyU Health를 열고 “초대 코드로 참여”를 눌러 주세요. 초대 코드를 입력하거나 QR 코드를 스캔해 연구에 참여할 수 있습니다.';

  @override
  String get invite_landing_invited_title => '연구 참여 초대를 받았습니다';

  @override
  String get invite_landing_phone_instruction =>
      '이 초대 코드를 StudyU Health 앱에 입력하세요.';

  @override
  String get invite_landing_other_device_instruction =>
      '빠르게 접속하려면 휴대전화로 이 QR 코드를 스캔해 주세요.';

  @override
  String get invite_landing_enter_code_title => '초대 코드 입력';

  @override
  String get invite_landing_scan_qr_title => 'QR 코드 스캔';

  @override
  String get invite_landing_copied => '복사됨';

  @override
  String get invite_landing_copy_code => '초대 코드 복사';

  @override
  String get date_format => '날짜 형식';

  @override
  String get date_format_european => '유럽식 (31/12/2024)';

  @override
  String get date_format_german => '독일식 (31.12.2024)';

  @override
  String get date_format_iso => 'ISO (2024-12-31)';

  @override
  String get date_format_us => '미국식 (12/31/2024)';

  @override
  String get system => '기기 설정 따름';

  @override
  String get time_format => '시간 형식';

  @override
  String get time_format_12_hour => '12시간제 (오후 2:30)';

  @override
  String get time_format_24_hour => '24시간제 (14:30)';

  @override
  String get daily_food_diary => 'Daily Food Diary';

  @override
  String get instructions => 'Instructions';

  @override
  String get nutrition_instructions_default =>
      'Please record all the foods and beverages you consumed today. For each meal or snack, provide as much detail as possible including portion sizes and preparation methods.';

  @override
  String min_meals_required(int count) {
    return 'Daily meal target: $count meal(s)';
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
  String get discard_meal_changes_title => '이 항목을 떠날까요?';

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
  String get delete_meal => '항목 삭제';

  @override
  String get delete_meal_title => '이 항목을 삭제할까요?';

  @override
  String get delete_meal_message => '이 항목은 영양 일지에서 제거됩니다.';

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
  String get apply => 'Apply';

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
  String get add_food => '음식 추가';

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
  String get entry_type => '식품 유형';

  @override
  String get food_name => 'Food name *';

  @override
  String get nutrition_values_are_for => '영양 정보의 기준 중량';

  @override
  String get brand_name => '브랜드';

  @override
  String get description => 'Description';

  @override
  String get description_hint => '이 식품에 대한 메모 (선택)';

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
  String get portion_reference => '분량 기준';

  @override
  String get portion_reference_hint => '예: 1컵, 중간 크기 사과 1개';

  @override
  String get portion_estimation_method => '분량 추정 방법';

  @override
  String get portion_state => '음식 상태';

  @override
  String get yield_factor => '수율 계수';

  @override
  String get yield_factor_hint => '예: 0.75';

  @override
  String get edible_portion => '섭취 가능 비율';

  @override
  String get edible_portion_hint => '예: 0.85';

  @override
  String get nutrition_information => '영양 정보';

  @override
  String get energy_kcal => '열량';

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
  String get optional => '선택 사항';

  @override
  String get saturated_fat_g => '포화지방 (g)';

  @override
  String get sugars_g => '당류 (g)';

  @override
  String get fiber_g => '식이섬유 (g)';

  @override
  String get sodium_mg => '나트륨 (mg)';

  @override
  String get required_error => 'Required';

  @override
  String get enter_food_name => 'Please enter a food name';

  @override
  String get enter_serving_size => 'Please enter serving size';

  @override
  String get entry_type_single_ingredient => '단일 재료';

  @override
  String get entry_type_meal => 'Meal';

  @override
  String get entry_type_branded_product => '브랜드 제품';

  @override
  String get entry_type_manual_entry => '직접 입력';

  @override
  String get portion_method_household => '가정용 계량 단위';

  @override
  String get portion_method_photograph => '사진';

  @override
  String get portion_method_standard_unit => '표준 단위';

  @override
  String get portion_method_user_weighted => '직접 계량';

  @override
  String get portion_method_unknown => '알 수 없음';

  @override
  String get portion_state_raw => '조리 전';

  @override
  String get portion_state_cooked => '조리 후';

  @override
  String get portion_state_as_served => '제공된 상태';

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
      '이 항목은 라이브러리에서 가져왔습니다. 변경 사항을 저장할 위치를 선택하세요.';

  @override
  String get library_edit_current_entry => 'Only this logged item';

  @override
  String get library_edit_current_selection => '이 선택 항목만';

  @override
  String get library_edit_selection_message =>
      '이 항목은 라이브러리에서 가져왔습니다. 변경 사항을 저장할 위치를 선택하세요.';

  @override
  String get library_edit_current_entry_and_library =>
      'This item and reusable library item';

  @override
  String get save_to_my_items_action => '항목을 식사로 라이브러리에 저장';

  @override
  String get save_item_to_library => '항목을 라이브러리에 저장';

  @override
  String get external_library_copy => 'Import';

  @override
  String external_library_copy_label(String name) {
    return '$name 확인 후 라이브러리에 추가';
  }

  @override
  String get external_library_copy_saved => '라이브러리에 추가했습니다';

  @override
  String get external_library_copy_save_error => '식품을 라이브러리에 추가하지 못했습니다';

  @override
  String get remove_from_meal => 'Remove from meal';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get save_as_template => 'Add to My items';

  @override
  String get save_meal => '라이브러리에 저장';

  @override
  String get done_label => 'Done';

  @override
  String get log_meal => '일지 항목 추가';

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
  String get food_library_search_hint => '라이브러리 검색';

  @override
  String get search_templates => 'Search saved foods and meals…';

  @override
  String get save_templates_hint =>
      'Save your favorite meals and foods for quick access';

  @override
  String get from_template => 'From My items';

  @override
  String get add_new_food => 'Add New Food';

  @override
  String delete_template(String name) {
    return '$name을(를) 삭제할까요?';
  }

  @override
  String get delete_template_confirmation => '이 항목이 라이브러리에서 삭제됩니다.';

  @override
  String get filter_all => '전체';

  @override
  String get filter_meals => '식사';

  @override
  String get filter_foods => '음식';

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
  String get food_quantity_override_helper => '변경 사항은 이 식사에서 선택한 항목에만 적용됩니다.';

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
  String get food_quantity_add_to_selection => '선택 목록에 추가';

  @override
  String get food_quantity_add_meal_to_selection => 'Add meal to selection';

  @override
  String get food_quantity_update_selection => 'Save changes';

  @override
  String get food_quantity_nutrition_unavailable =>
      'Nutrition information unavailable';

  @override
  String save_and_add_to_meal(String meal) {
    return 'Save and add to $meal';
  }

  @override
  String get edit_food_title => 'Edit food';

  @override
  String get add_food_manually => 'Create food';

  @override
  String get basic_information => '식품 정보';

  @override
  String get macronutrients => '다량 영양소';

  @override
  String get detailed_nutrients => '상세 영양 정보';

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
  String get nutrition_summary => 'Nutrition Summary';

  @override
  String get calorie_distribution => 'Calorie Distribution';

  @override
  String get more_options => 'More options';

  @override
  String get search_food_hint => 'Search foods, meals or brands';

  @override
  String get my_saved_items => '라이브러리';

  @override
  String get food_library => '라이브러리';

  @override
  String get add_food_action => '음식 만들기';

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
      '라이브러리에 저장하기 전에 식품 정보를 확인하세요. 수정 사항은 저장한 사본에 적용됩니다.';

  @override
  String get external_library_save_copy => '라이브러리에 저장';

  @override
  String get quick_actions => 'Quick Actions';

  @override
  String get create => 'Create';

  @override
  String get create_meal => '식사 만들기';

  @override
  String get create_meal_subtitle => 'Combine multiple foods';

  @override
  String get add_manually => 'Create food manually';

  @override
  String get add_manually_subtitle => 'Enter nutrition facts yourself';

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
  String get detailed_nutrition => '상세 영양 정보';

  @override
  String get detailed_nutrition_subtitle => '식이섬유, 당류, 포화지방 및 나트륨';

  @override
  String get advanced_options => '추가 정보';

  @override
  String get advanced_options_subtitle => '식품 유형, 브랜드 및 분량 정보';

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
  String get min_meals_not_met_title => 'Daily meal target not reached';

  @override
  String min_meals_not_met_message(int count) {
    return 'The daily meal target is $count meal(s). You have recorded fewer meals. Leave anyway?';
  }

  @override
  String get leave_anyway => 'Leave anyway';

  @override
  String get nutrition_tracking => '식사 일지';

  @override
  String get nutrition_statistics => 'Statistics';

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
      '이전 연구일의 기록을 추가하거나 수정할 수 있습니다.';

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
  String get nutrition_statistics_empty => '이 기간의 영양 데이터가 없습니다.';

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
      '변경 사항은 이 일지 항목에만 적용됩니다. 재사용 항목을 수정하려면 라이브러리를 이용하세요.';

  @override
  String get current_selection_only_banner =>
      '변경 사항은 이 선택 항목에만 적용됩니다. 영구적으로 변경하려면 라이브러리를 이용하세요.';

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
  String get food_quantity_edit_amount => '수량 수정';

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
  String get nutrition_add_food_or_saved_meal => '항목 추가';

  @override
  String get nutrition_food_badge => 'Food';

  @override
  String get nutrition_saved_meal_badge => 'Saved meal';

  @override
  String nutrition_add_foods_or_saved_meals_to_meal(Object meal) {
    return '$meal에 추가';
  }

  @override
  String get nutrition_search_foods_saved_meals_or_brands => '식품 또는 식사 검색';

  @override
  String get nutrition_create_saved_meal_from_log => '이 기록에서 식사 만들기';

  @override
  String get nutrition_edit_saved_meal => 'Edit saved meal';

  @override
  String get nutrition_invalid_saved_meal =>
      '이 식사의 일부 음식에 세부 정보가 없습니다. 정보가 완전한 음식을 추가한 후 다시 시도하세요.';

  @override
  String nutrition_add_food_to_meal(Object meal) {
    return '음식을 $meal에 추가';
  }

  @override
  String get nutrition_search_foods_or_brands => 'Search foods or brands';

  @override
  String get nutrition_saved_meals_expanded_notice =>
      '이 식사를 저장하기 전에 저장된 식사의 개별 음식을 확인하세요.';

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
  String get nutrition_add_food_manually => '직접 추가';

  @override
  String get nutrition_food_name_example => 'e.g., olive oil';

  @override
  String get nutrition_quantity_short => '수량';

  @override
  String get nutrition_calories_kcal => '열량';

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

  @override
  String get not_added => 'Not added';

  @override
  String get nutrition_statistics_week => '주';

  @override
  String get nutrition_statistics_month => '월';

  @override
  String get nutrition_statistics_previous_period => '이전 기간';

  @override
  String get nutrition_statistics_next_period => '다음 기간';

  @override
  String get nutrition_statistics_go_to_today => '오늘로 이동';

  @override
  String nutrition_energy_change_from_previous_day(Object value) {
    return '전날 대비 $value';
  }

  @override
  String food_selection_remove_title(String name) {
    return '$name 항목을 제거하시겠습니까?';
  }

  @override
  String get food_selection_remove => '제거';

  @override
  String get nutrition_exit => '나가기';

  @override
  String get nutrition_water => '물';

  @override
  String get nutrition_water_unlogged => '기록된 물 없음';

  @override
  String get nutrition_water_add_cup => '물 한 컵 추가';

  @override
  String get nutrition_water_remove_cup => '물 한 컵 빼기';

  @override
  String get nutrition_water_cup_size => '컵 용량';

  @override
  String get nutrition_water_cup_size_invalid => '1~9999mL를 입력하세요.';

  @override
  String get nutrition_water_cup_size_save_error => '컵 용량을 저장하지 못했습니다.';

  @override
  String get nutrition_current_day_ended =>
      '이 영양 기록일이 끝났습니다. 계속하려면 영양 기록 과제를 다시 여세요.';

  @override
  String get nutrition_food_definition_conflict =>
      '이 항목의 새 버전이 있습니다. 현재 버전을 수정하려면 편집기를 다시 여세요.';

  @override
  String get nutrition_invalid_calories => '칼로리는 0 또는 양수로 입력하세요.';

  @override
  String get nutrition_recall_conflict_title => '동기화되지 않은 영양 기록 초안';

  @override
  String get nutrition_recall_conflict_message =>
      '이 초안이 저장된 버전과 충돌합니다. 초안은 이 기기에 남습니다. 이 날의 기록을 다시 수정하려면 초안을 삭제하세요.';

  @override
  String get nutrition_recall_discard_draft => '초안 삭제';

  @override
  String get nutrition_recall_discard_confirmation =>
      '이 기기에서 동기화되지 않은 변경 사항을 삭제합니다. 저장된 기록은 그대로 유지됩니다.';

  @override
  String get nutrition_recall_discard_failed => '초안을 삭제할 수 없습니다. 다시 시도하세요.';

  @override
  String get nutrition_recall_conflict_reopen =>
      '영양 기록 과제를 다시 여세요. 이전 버전이 계속 표시되면 연구를 다시 불러오세요.';

  @override
  String get nutrition_recall_view_draft => '초안 보기';

  @override
  String get nutrition_recall_view_saved => '저장된 버전 보기';

  @override
  String get nutrition_history_local_draft => '이 기기에 저장된 초안';

  @override
  String get nutrition_history_expired_draft =>
      '동기화 기간이 끝났습니다. 이 초안은 이 기기에만 있습니다.';

  @override
  String get nutrition_history_discard_expired_draft =>
      '이 기기에서 이 초안을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get time_now => '지금';

  @override
  String get nutrition_review_previous_day => '이전 연구일의 식사 기록 확인';

  @override
  String get food_library_empty => '표시할 음식이나 식사가 없습니다.';

  @override
  String get nutrition_known_values_hint => '모르는 영양값은 비워 두세요.';

  @override
  String get nutrition_log_again => '일지 항목 다시 기록';

  @override
  String get nutrition_choose_recent_meal => '최근 식사 선택';

  @override
  String get nutrition_meal_items => '항목';

  @override
  String get nutrition_save_meal => '일지 항목 저장';

  @override
  String get nutrition_select_time_to_save => '저장하려면 시간을 선택하세요';

  @override
  String get nutrition_food_details_subtitle => '귀리 플레이크처럼 구체적인 이름을 입력하세요.';

  @override
  String get nutrition_diary_tab => '일지';

  @override
  String nutrition_meal_foods_section(Object count) {
    return '음식 ($count개)';
  }

  @override
  String get nutrition_photo_add => '사진 추가';

  @override
  String get nutrition_photo_replace => '사진 바꾸기';

  @override
  String get nutrition_photo_remove => '사진 삭제';

  @override
  String get nutrition_photo_take => '사진 촬영';

  @override
  String get nutrition_photo_choose => '사진 선택';

  @override
  String get nutrition_photo_invalid =>
      '이 사진을 열 수 없습니다. 다른 이미지를 선택하거나 카메라 접근 권한을 확인하세요.';

  @override
  String get nutrition_photo_save_failed => '항목을 저장했습니다. 사진 변경 사항은 저장하지 못했습니다.';

  @override
  String get nutrition_photo_retry => '사진 다시 저장';

  @override
  String get nutrition_library_available_filters => '사용 가능한 필터';

  @override
  String get nutrition_library_selected_filters => '선택한 필터';

  @override
  String get nutrition_library_created_by_me => '내가 만든 항목';

  @override
  String get nutrition_library_remove_filter => '필터 제거';

  @override
  String get edit_diary_entry_title => '일지 항목 편집';

  @override
  String get meal_neutral_label_inline => '항목';

  @override
  String get nutrition_add_diary_entry => '일지 항목 추가';

  @override
  String get nutrition_create_library_item => '항목 만들기';

  @override
  String get remove_from_entry => '일지 항목에서 제거';
}

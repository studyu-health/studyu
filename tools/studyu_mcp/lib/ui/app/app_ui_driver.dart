import 'dart:convert';

import 'package:studyu_mcp/ui/app/app_ui_flow.dart';
import 'package:studyu_mcp/ui/ui_driver.dart';
import 'package:studyu_mcp/ui/vm_service_ui_driver.dart';

class StudyUAppUiDriver {
  const StudyUAppUiDriver(this._driver);

  final StudyUUiDriver _driver;

  Future<void> connect(String? vmServiceUri) => _driver.connect(vmServiceUri);

  Future<StudyUIScreenSnapshot> readScreen() => _driver.readScreen();

  Future<List<Object?>> completeOnboardingToStudyList() async {
    await StudyUAppUiFlow(
      waitForKey: _driver.waitForValueKey,
      tapKey: _driver.tapByValueKey,
      readScreen: _driver.readScreen,
    ).completeOnboardingToStudyList();
    return visibleStudies();
  }

  Future<List<Object?>> visibleStudies() async {
    final response = await _driver.requestData('visibleStudies');
    final message = response['message'] as String?;
    if (message == null) return [];
    final decoded = jsonDecode(message) as Map<String, dynamic>;
    return (decoded['studies'] as List?) ?? [];
  }

  Future<void> openStudy(String studyId) => StudyUAppUiFlow(
    waitForKey: _driver.waitForValueKey,
    tapKey: _driver.tapByValueKey,
    readScreen: _driver.readScreen,
  ).openStudy(studyId);
}

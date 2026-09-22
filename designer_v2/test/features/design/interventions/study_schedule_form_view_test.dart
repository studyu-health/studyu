import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_view.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('number of cycles uses a dropdown from 1 to 9', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1600);
    addTearDown(tester.view.reset);

    final controls = _StudyScheduleTestControls();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StudyScheduleFormView(formViewModel: controls),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final cyclesDropdown = find.byType(DropdownButtonFormField<int>);
    expect(cyclesDropdown, findsOneWidget);
    expect(tester.getSize(cyclesDropdown).width, 70);
    expect(tester.getSize(cyclesDropdown).height, greaterThanOrEqualTo(48));

    await tester.tap(cyclesDropdown);
    await tester.pumpAndSettle();

    expect(
      tester
          .widgetList<DropdownMenuItem<int>>(find.byType(DropdownMenuItem<int>))
          .map((item) => item.value)
          .toSet(),
      {1, 2, 3, 4, 5, 6, 7, 8, 9},
    );

    await tester.tap(find.text('9').last);
    await tester.pumpAndSettle();

    expect(controls.numCyclesControl.value, 9);
  });
}

class _StudyScheduleTestControls() with StudyScheduleControls;

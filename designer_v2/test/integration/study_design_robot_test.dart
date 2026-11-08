// The web test compiler cannot import robots outside the test directory.
@TestOn('vm')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/features/design/info/study_title_input_group.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

import '../../integration_test/controller/robots/study_design_robot.dart';

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(AppLocalizationsEn());
  });

  testWidgets('robot selects study icon after scrolling to bottom', (
    tester,
  ) async {
    const favoriteIcon = IconOption('favorite', Icons.favorite);
    final titleControl = FormControl<String>();
    final iconControl = FormControl<IconOption>();
    final form = FormGroup({'title': titleControl, 'icon': iconControl});
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    addTearDown(form.dispose);
    final robot = StudyDesignRobot(
      PatrolTester(tester: tester, config: const PatrolTesterConfig()),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  ReactiveForm(
                    formGroup: form,
                    child: StudyTitleInputGroup(
                      titleControl: titleControl,
                      iconControl: iconControl,
                      iconOptions: const [favoriteIcon],
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    await tester.pumpAndSettle();

    final picker = find.byKey(const ValueKey('study_title_icon_picker'));
    expect(picker, findsOneWidget);
    expect(picker.hitTestable(), findsNothing);
    expect(iconControl.value, isNull);

    await robot.selectStudyIcon(favoriteIcon);

    expect(picker.hitTestable(), findsOneWidget);
    expect(iconControl.value, favoriteIcon);
    expect(find.text(tr.iconpicker_nonempty_prompt), findsOneWidget);
    expect(find.byType(IconPickerGallery), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

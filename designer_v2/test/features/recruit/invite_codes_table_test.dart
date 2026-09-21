import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/features/recruit/invite_codes_table.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(lookupAppLocalizations(const Locale('en')));
  });

  Widget buildSubject({
    required List<StudyInvite> invites,
    required ActionsProviderFor<StudyInvite> getActions,
    required ActionsProviderFor<StudyInvite> getInlineActions,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: StudyInvitesTable(
          invites: invites,
          onSelect: (_) {},
          getInlineActions: getInlineActions,
          getActions: getActions,
          getIntervention: (_) => null,
          getParticipantCountForInvite: (_) => 0,
          sortColumn: InviteCodesSortColumn.code,
          sortAscending: true,
          onSortColumn: (_) {},
        ),
      ),
    );
  }

  testWidgets('invite table handles single preselected intervention', (
    tester,
  ) async {
    final invite = StudyInvite(
      'invite-1',
      'study-1',
      preselectedInterventionIds: const ['intervention-a'],
    );

    await tester.pumpWidget(
      buildSubject(
        invites: [invite],
        getInlineActions: (_) => const <ModelAction>[],
        getActions: (_) => const <ModelAction>[],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('invite-1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invite table renders inline link copy action', (tester) async {
    final invite = StudyInvite('invite-2', 'study-1');
    var copied = false;
    await tester.binding.setSurfaceSize(const Size(1600, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildSubject(
        invites: [invite],
        getInlineActions: (_) => [
          ModelAction(
            type: ModelActionType.copyLink,
            label: tr.action_copy_invite_link,
            icon: Icons.link_rounded,
            onExecute: () {
              copied = true;
            },
          ),
        ],
        getActions: (_) => const <ModelAction>[],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(tr.code_list_header_code), findsOneWidget);
    expect(
      find.text(tr.studies_list_header_participants_enrolled),
      findsOneWidget,
    );
    expect(
      find.text(tr.form_field_preconfigured_schedule_intervention_a),
      findsOneWidget,
    );
    expect(
      find.text(tr.form_field_preconfigured_schedule_intervention_b),
      findsOneWidget,
    );
    expect(find.text(tr.code_list_header_actions), findsNothing);
    expect(find.text('#'), findsNothing);

    final copyLinkAction = find.byTooltip(tr.action_copy_invite_link);
    expect(copyLinkAction, findsOneWidget);

    await tester.tap(copyLinkAction);
    await tester.pumpAndSettle();

    expect(copied, isTrue);
  });

  testWidgets('invite table scrolls horizontally at 375 px', (tester) async {
    final invite = StudyInvite('invite-narrow', 'study-1');
    await tester.binding.setSurfaceSize(const Size(375, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildSubject(
        invites: [invite],
        getInlineActions: (_) => const <ModelAction>[],
        getActions: (_) => const <ModelAction>[],
      ),
    );
    await tester.pumpAndSettle();

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    expect(scrollView.scrollDirection, Axis.horizontal);
    expect(tester.takeException(), isNull);
  });

  testWidgets('row menu shows link qr and delete actions', (tester) async {
    final invite = StudyInvite('invite-3', 'study-1');
    await tester.binding.setSurfaceSize(const Size(1600, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildSubject(
        invites: [invite],
        getInlineActions: (_) => const <ModelAction>[],
        getActions: (_) => [
          ModelAction(
            type: ModelActionType.copyLink,
            label: tr.action_copy_invite_link,
            icon: Icons.link_rounded,
            onExecute: () {},
          ),
          ModelAction(
            type: ModelActionType.qrCodeShow,
            label: tr.action_qr_code_show,
            icon: Icons.qr_code_rounded,
            onExecute: () {},
          ),
          ModelAction(
            type: ModelActionType.delete,
            label: tr.action_delete_code,
            icon: Icons.delete_rounded,
            isDestructive: true,
            onExecute: () {},
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    expect(find.text(tr.action_copy_invite_link), findsOneWidget);
    expect(find.text(tr.action_qr_code_show), findsOneWidget);
    expect(find.text(tr.action_delete_code), findsOneWidget);
    expect(find.byType(PopupMenuDivider), findsNothing);
  });
}

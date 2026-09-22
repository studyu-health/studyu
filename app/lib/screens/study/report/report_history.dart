import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class const ReportHistoryScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.report_history)),
      body: RetryFutureBuilder<List<StudySubject>>(
        tryFunction: () => StudySubject.getStudyHistory(
          Supabase.instance.client.auth.currentUser!.id,
        ),
        successBuilder:
            (BuildContext context, List<StudySubject>? pastStudies) {
              return pastStudies == null || pastStudies.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.no_reports_found,
                      ),
                    ) //
                  : ListView.builder(
                      itemCount: pastStudies.length,
                      itemBuilder: (context, index) {
                        return ReportHistoryItem(pastStudies[index]);
                      },
                    );
            },
      ),
    );
  }
}

class const ReportHistoryItem(final StudySubject subject, {super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<AppState>();
    final isActiveStudy = model.activeSubject!.studyId == subject.studyId;
    return Card(
      color: isActiveStudy ? Colors.green[600] : theme.cardColor,
      child: InkWell(
        onTap: () {
          context.push('/${RouteNames.reportDetails}', extra: subject);
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  MdiIconsHelper.fromString(subject.study.iconName) ??
                      MdiIcons.accountHeart,
                  color: isActiveStudy ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    subject.study.title!,
                    style: theme.textTheme.headlineSmall!.copyWith(
                      color: isActiveStudy ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

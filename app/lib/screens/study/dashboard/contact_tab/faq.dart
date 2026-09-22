import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

class const FAQ({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = <Entry>[
      Entry(l10n.faq_section_data_storage_privacy, <Entry>[
        Entry(l10n.faq_question_data_storage, <Entry>[
          Entry(l10n.faq_answer_data_storage),
        ]),
        Entry(l10n.faq_question_personal_data, <Entry>[
          Entry(l10n.faq_answer_personal_data),
        ]),
      ]),
      Entry(l10n.faq_section_studies, <Entry>[
        Entry(l10n.faq_question_study_duration, <Entry>[
          Entry(l10n.faq_answer_study_duration),
        ]),
        Entry(l10n.faq_question_change_intervention, <Entry>[
          Entry(l10n.faq_answer_change_intervention),
        ]),
        Entry(l10n.faq_question_missed_tasks, <Entry>[
          Entry(l10n.faq_answer_missed_tasks),
        ]),
        Entry(l10n.faq_question_leave_study, <Entry>[
          Entry(l10n.faq_answer_leave_study),
        ]),
      ]),
      Entry(l10n.faq_section_report_details, <Entry>[
        Entry(l10n.faq_question_daily_tasks, <Entry>[
          Entry(l10n.faq_answer_daily_tasks),
        ]),
        Entry(l10n.faq_question_rate_your_day, <Entry>[
          Entry(l10n.faq_answer_rate_your_day),
        ]),
        Entry(l10n.faq_question_track_activities, <Entry>[
          Entry(l10n.faq_answer_track_activities),
        ]),
        Entry(l10n.faq_question_download_report, <Entry>[
          Entry(l10n.faq_answer_download_report),
        ]),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.faq_full)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) => EntryItem(entries[index]),
        itemCount: entries.length,
      ),
    );
  }
}

class Entry(final String title, [final List<Entry> children = const <Entry>[]]);

class const EntryItem(final Entry entry, {super.key}) extends StatelessWidget {
  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: root.children.map<Widget>(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

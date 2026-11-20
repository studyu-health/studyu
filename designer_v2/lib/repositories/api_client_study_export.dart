part of 'api_client.dart';

extension _StudyExportQueries on StudyUApiClient {
  Future<Study> _fetchStudy(
    StudyID studyId,
    bool withParticipantActivity,
    bool withInvites,
  ) async {
    await _testDelay();
    final columns = [
      ...StudyUApiClient.studyColumns,
      if (withInvites) StudyUApiClient.studyInviteColumn,
    ];
    final request = getById<Study>(studyId, selectedColumns: columns);
    final study = await _awaitGuarded(
      request,
      onError: {
        PostgrestErrorCodes.isNotSingleItem: (e) =>
            throw StudyNotFoundException(),
      },
    );
    if (withParticipantActivity) {
      study.participants = await _fetchStudyParticipants(studyId);
      study.participantsProgress = await _fetchStudyProgress(studyId);
    }
    return study;
  }

  Future<List<StudySubject>> _fetchStudyParticipants(StudyID studyId) async {
    final participants = <StudySubject>[];
    String? lastId;
    while (true) {
      var query = this.supabaseClient
          .from(StudySubject.tableName)
          .select(
            'id,study_id,user_id,selected_intervention_ids,started_at,'
            'invite_code,is_deleted',
          )
          .eq('study_id', studyId);
      if (lastId != null) query = query.gt('id', lastId);
      final page = await _awaitGuarded(
        query.order('id', ascending: true).limit(500),
      );
      if (page.isEmpty) return participants;
      participants.addAll(deserializeList<StudySubject>(page));
      lastId = participants.last.id;
    }
  }

  Future<List<SubjectProgress>> _fetchStudyProgress(StudyID studyId) async {
    final records = <SubjectProgress>[];
    String? lastCompletedAt;
    String? lastSubjectId;
    while (true) {
      var query = this.supabaseClient
          .from('study_progress_export')
          .select(
            'completed_at,subject_id,started_at,intervention_id,task_id,'
            'result_type,result',
          )
          .eq('study_id', studyId);
      if (lastCompletedAt != null) {
        query = query.or(
          'completed_at.gt.$lastCompletedAt,'
          'and(completed_at.eq.$lastCompletedAt,subject_id.gt.$lastSubjectId)',
        );
      }
      final page = await _awaitGuarded(
        query
            .order('completed_at', ascending: true)
            .order('subject_id', ascending: true)
            .limit(500),
      );
      if (page.isEmpty) return records;
      records.addAll(deserializeList<SubjectProgress>(page));
      lastCompletedAt = page.last['completed_at'] as String;
      lastSubjectId = records.last.subjectId;
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  Future<void> checkPaging({required bool forExport}) async {
    final studyQueries = <Uri>[];
    final participantQueries = <Uri>[];
    final progressQueries = <Uri>[];
    const studyId = 'study-id';
    const startedAt = '2026-01-01T23:00:00Z';
    const completedAt = '2026-01-02T08:00:00.123456+00:00';
    final study = Study(studyId, 'owner-id');
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final client = SupabaseClient(
      'http://${server.address.address}:${server.port}',
      'test-anon-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(() async {
      await client.dispose();
      await server.close(force: true);
    });

    server.listen((request) async {
      final Object response;
      switch (request.uri.path) {
        case '/rest/v1/study':
          studyQueries.add(request.uri);
          response = study.toJson();
        case '/rest/v1/study_subject':
          participantQueries.add(request.uri);
          response = switch (participantQueries.length) {
            1 => [_participant('subject-a', studyId, startedAt)],
            2 => [_participant('subject-b', studyId, startedAt)],
            _ => <Object>[],
          };
        case '/rest/v1/study_progress_export':
          progressQueries.add(request.uri);
          response = switch (progressQueries.length) {
            1 => [_progress('subject-a', startedAt, completedAt)],
            2 => [_progress('subject-b', startedAt, completedAt)],
            _ => <Object>[],
          };
        default:
          request.response.statusCode = HttpStatus.notFound;
          response = {'message': 'Unexpected request'};
      }
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(response));
      await request.response.close();
    });

    final api = StudyUApiClient(supabaseClient: client);
    final result = forExport
        ? await api.fetchStudyForExport(studyId)
        : await api.fetchStudy(studyId);

    expect(result.participants!.map((p) => p.id), ['subject-a', 'subject-b']);
    expect(result.participantsProgress!.map((p) => p.subjectId), [
      'subject-a',
      'subject-b',
    ]);
    if (forExport) {
      expect(
        result.exportData.interventionsData.map((row) => row['invite_code']),
        unorderedEquals(['invite-subject-a', 'invite-subject-b']),
      );
    }
    expect(studyQueries.single.queryParameters['id'], 'eq.$studyId');
    expect(
      studyQueries.single.queryParameters['select'],
      isNot(contains('study_progress_export')),
    );
    expect(participantQueries, hasLength(3));
    expect(progressQueries, hasLength(3));
    for (final uri in [...participantQueries, ...progressQueries]) {
      expect(uri.queryParameters['study_id'], 'eq.$studyId');
      expect(uri.queryParameters['limit'], '500');
    }
    expect(participantQueries[1].queryParameters['id'], 'gt.subject-a');
    expect(
      progressQueries[1].queryParameters['order'],
      'completed_at.asc.nullslast,subject_id.asc.nullslast',
    );
    expect(
      progressQueries[1].queryParameters['or'],
      '(completed_at.gt.$completedAt,'
      'and(completed_at.eq.$completedAt,subject_id.gt.subject-a))',
    );
  }

  test(
    'export fetches every page of participants and progress',
    () => checkPaging(forExport: true),
  );
  test(
    'monitoring fetches every page of participants and progress',
    () => checkPaging(forExport: false),
  );

  test(
    'monitoring requests no participant data for an inaccessible study',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final client = SupabaseClient(
        'http://${server.address.address}:${server.port}',
        'test-anon-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      addTearDown(() async {
        await client.dispose();
        await server.close(force: true);
      });

      final paths = <String>[];
      server.listen((request) async {
        paths.add(request.uri.path);
        request.response.statusCode = HttpStatus.notAcceptable;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'code': 'PGRST116',
            'message': 'JSON object requested, multiple (or no) rows returned',
          }),
        );
        await request.response.close();
      });

      final api = StudyUApiClient(supabaseClient: client);
      await expectLater(
        api.fetchStudy('inaccessible'),
        throwsA(isA<StudyNotFoundException>()),
      );
      expect(paths, ['/rest/v1/study']);
    },
  );
}

Map<String, dynamic> _participant(
  String id,
  String studyId,
  String startedAt,
) => {
  'id': id,
  'study_id': studyId,
  'user_id': 'user-$id',
  'selected_intervention_ids': <String>[],
  'started_at': startedAt,
  'invite_code': 'invite-$id',
  'is_deleted': false,
};

Map<String, dynamic> _progress(
  String subjectId,
  String startedAt,
  String completedAt,
) => {
  'subject_id': subjectId,
  'intervention_id': Study.baselineID,
  'task_id': 'intervention-task',
  'result_type': 'bool',
  'result': {'type': 'bool', 'result': true},
  'started_at': startedAt,
  'completed_at': completedAt,
};

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'invite pagination builds filtered count and inclusive page queries',
    () async {
      final requests = <_CapturedRequest>[];
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
        requests.add(_CapturedRequest.from(request));
        request.response.headers.contentType = ContentType.json;
        if (request.headers.value('prefer') == 'count=exact') {
          request.response.headers.set('content-range', '0-0/73');
          request.response.write('[]');
        } else {
          request.response.write(
            jsonEncode([
              {
                'code': 'invite-code',
                'study_id': 'study-id',
                'study_invite_participant_count': 3,
              },
            ]),
          );
        }
        await request.response.close();
      });

      final apiClient = StudyUApiClient(supabaseClient: client);
      final page = await apiClient.fetchStudyInvitesPage(
        'study-id',
        offset: 50,
        limit: 50,
        query: '  AbC  ',
        sortBy: InviteCodesSortColumn.enrolled,
        ascending: false,
      );
      final count = await apiClient.countStudyInvites(
        'study-id',
        query: '  AbC  ',
      );

      expect(page.single.participantCount, 3);
      expect(count, 73);
      expect(requests, hasLength(2));

      final pageRequest = requests.first;
      expect(pageRequest.method, 'GET');
      expect(pageRequest.uri.path, '/rest/v1/study_invite');
      expect(
        pageRequest.uri.queryParameters,
        containsPair('select', '*,study_invite_participant_count'),
      );
      expect(
        pageRequest.uri.queryParameters,
        containsPair('study_id', 'eq.study-id'),
      );
      expect(
        pageRequest.uri.queryParameters,
        containsPair('code', 'ilike.%AbC%'),
      );
      expect(
        pageRequest.uri.queryParameters,
        containsPair(
          'order',
          'study_invite_participant_count.desc.nullslast,code.asc.nullslast',
        ),
      );
      expect(pageRequest.uri.queryParameters, containsPair('offset', '50'));
      expect(pageRequest.uri.queryParameters, containsPair('limit', '50'));

      final countRequest = requests.last;
      expect(countRequest.method, 'HEAD');
      expect(countRequest.uri.path, '/rest/v1/study_invite');
      expect(countRequest.uri.queryParameters, isNot(contains('select')));
      expect(
        countRequest.uri.queryParameters,
        containsPair('study_id', 'eq.study-id'),
      );
      expect(
        countRequest.uri.queryParameters,
        containsPair('code', 'ilike.%AbC%'),
      );
      expect(countRequest.headers['prefer'], 'count=exact');
    },
  );
}

class const _CapturedRequest({
  required final String method,
  required final Uri uri,
  required final Map<String, String> headers,
}) {
  factory from(HttpRequest request) {
    final headers = <String, String>{};
    request.headers.forEach((name, values) {
      headers[name] = values.join(',');
    });
    return _CapturedRequest(
      method: request.method,
      uri: request.uri,
      headers: headers,
    );
  }
}

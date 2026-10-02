import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';
import 'package:studyu_flutter_common/src/utils/env_loader.dart';

void main() {
  tearDown(() {
    appConnectionStatusController.debugAuthAutoRefreshSync = null;
    appConnectionStatusController.reset();
  });

  test('findWorkingSupabaseUrl updates connection status and still throws '
      'when every candidate URL fails with a transport error', () async {
    final client = MockClient((request) {
      throw const SocketException('Failed host lookup');
    });

    await expectLater(
      () => findWorkingSupabaseUrl(
        ['https://a.example.com', 'https://b.example.com'],
        'anon-key',
        httpClient: client,
      ),
      throwsException,
    );

    expect(
      appConnectionStatusController.status,
      isNot(AppConnectionStatus.healthy),
    );
  });

  test('findWorkingSupabaseUrl leaves connection status healthy when a '
      'candidate URL responds', () async {
    final client = MockClient((request) async {
      return http.Response(
        '[]',
        200,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    });

    final url = await findWorkingSupabaseUrl(
      ['https://a.example.com'],
      'anon-key',
      httpClient: client,
    );

    expect(url, 'https://a.example.com');
    expect(appConnectionStatusController.status, AppConnectionStatus.healthy);
  });
}

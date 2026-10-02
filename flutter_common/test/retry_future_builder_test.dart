import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';
import 'package:studyu_flutter_common/src/utils/retry_future_builder.dart';

void main() {
  tearDown(() {
    appConnectionStatusController.reset();
  });

  testWidgets(
    'RetryFutureBuilder updates and clears tracked connection status',
    (tester) async {
      var shouldFail = true;

      await tester.pumpWidget(
        MaterialApp(
          home: RetryFutureBuilder<void>(
            trackConnectionStatus: true,
            tryFunction: () async {
              if (shouldFail) {
                throw Exception('ClientException: Failed to fetch');
              }
            },
            successBuilder: (context, _) => const Text('loaded'),
          ),
        ),
      );
      await tester.pump();

      expect(
        appConnectionStatusController.status,
        AppConnectionStatus.backendUnavailable,
      );
      expect(find.text('Could not load information.'), findsOneWidget);

      shouldFail = false;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();

      expect(appConnectionStatusController.status, AppConnectionStatus.healthy);
      expect(find.text('loaded'), findsOneWidget);
    },
  );
}

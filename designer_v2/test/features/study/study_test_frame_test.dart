@TestOn('browser')
library;

import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:web/web.dart' as web;

void main() {
  test('form rebuilds keep the loaded intervention preview route', () {
    final initial = previewRouteTarget(
      PreviewFrame(
        'study',
        routeArgs: InterventionFormRouteArgs(
          studyId: 'study',
          interventionId: 'intervention-1',
        ),
      ),
    );
    final editedTask = previewRouteTarget(
      PreviewFrame(
        'study',
        routeArgs: InterventionTaskFormRouteArgs(
          studyId: 'study',
          interventionId: 'intervention-1',
          taskId: 'task-2',
        ),
      ),
    );
    final otherIntervention = previewRouteTarget(
      PreviewFrame(
        'study',
        routeArgs: InterventionFormRouteArgs(
          studyId: 'study',
          interventionId: 'intervention-2',
        ),
      ),
    );

    expect(editedTask, initial);
    expect(otherIntervention, isNot(initial));
  });

  test('preview URL contains no serialized session', () {
    final uri = Uri.parse(
      buildPreviewAppUrl(
        baseUrl: 'https://app.example',
        studyId: 'study id',
        languageCode: 'en',
      ),
    );

    expect(uri.queryParameters, {'studyid': 'study id', 'languageCode': 'en'});
    expect(uri.queryParameters, isNot(contains('session')));
  });

  test('study data stays in memory across edits, reset, and navigation', () {
    final controller =
        WebController(
            'https://app.example/preview?studyid=study',
            'study',
            'session',
          )
          ..generateUrl(
            route: 'intervention',
            extra: 'intervention-1',
            data: '{"title":"old"}',
          )
          ..iFrameElement = web.HTMLIFrameElement();
    final initialUrl = controller.previewSrc;

    controller.updateData('{"title":"edited"}');

    expect(controller.previewSrc, initialUrl);
    expect(controller.routeInformation.data, '{"title":"edited"}');
    expect(Uri.parse(controller.previewSrc).queryParameters, {
      'studyid': 'study',
      'route': 'intervention',
      'extra': 'intervention-1',
    });

    controller.refresh(cmd: 'reset');
    expect(controller.routeInformation.data, '{"title":"edited"}');
    expect(
      Uri.parse(controller.previewSrc).queryParameters,
      isNot(contains('data')),
    );

    controller.navigationEnabled.value = true;
    controller.navigate(route: 'dashboard');
    expect(controller.routeInformation.data, '{"title":"edited"}');
  });

  test('disposed controller does not respond to session requests', () async {
    final origin = web.window.location.origin;
    final iframe = web.HTMLIFrameElement()
      ..srcdoc =
          '''
        <script>
          window.addEventListener('message', (event) => {
            if (event.data === 'request-session') {
              parent.postMessage(
                JSON.stringify({type: 'previewSessionRequest'}),
                parent.location.origin,
              );
              return;
            }
            parent.postMessage(
              JSON.stringify({type: 'previewResponse'}),
              parent.location.origin,
            );
          });
        </script>
      '''
              .toJS;
    web.document.body!.appendChild(iframe);
    addTearDown(() => iframe.remove());
    await iframe.onLoad.first;

    var receivedResponse = false;
    final responseSubscription = web.window.onMessage.listen((event) {
      final data = event.data.dartify();
      final decoded = data is String ? jsonDecode(data) : null;
      if (decoded is Map<String, dynamic> &&
          decoded['type'] == 'previewResponse') {
        receivedResponse = true;
      }
    });
    addTearDown(responseSubscription.cancel);

    final controller =
        WebController('$origin/preview?studyid=study', 'study', 'session')
          ..generateUrl()
          ..iFrameElement = iframe;
    controller.listen();
    controller.dispose();

    iframe.contentWindow!.postMessage('request-session'.toJS, origin.toJS);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(receivedResponse, isFalse);
  });
}

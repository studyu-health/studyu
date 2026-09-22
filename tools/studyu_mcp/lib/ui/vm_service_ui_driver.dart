import 'dart:async';
import 'dart:io';

import 'package:studyu_mcp/ui/ui_driver.dart';
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

class StudyUUiDriver {
  StudyUUiDriver({
    required Set<String> screenKeys,
    required String Function(Set<String> keys) inferScreen,
  }) : _screenKeys = screenKeys,
       _inferScreen = inferScreen;

  final Set<String> _screenKeys;
  final String Function(Set<String> keys) _inferScreen;
  vm.VmService? _service;
  String? _isolateId;

  Future<void> connect(String? vmServiceUri) async {
    if (_service != null && _isolateId != null && vmServiceUri == null) return;

    final uri =
        vmServiceUri ??
        Platform.environment['STUDYU_UI_VM_SERVICE_URI'] ??
        Platform.environment['STUDYU_APP_VM_SERVICE_URI'];
    if (uri == null || uri.isEmpty) {
      throw StateError(
        'Missing vmServiceUri. Start app/lib/driver_main.dart or designer_v2/lib/driver_main.dart and pass its VM service ws://.../ws URI, or set STUDYU_UI_VM_SERVICE_URI.',
      );
    }

    _service = await vmServiceConnectUri(normalizeVmServiceUri(uri));
    final isolates = (await _service!.getVM()).isolates ?? [];
    final mainIsolate = isolates
        .where((isolate) => isolate.id != null)
        .firstWhere(
          (isolate) => isolate.name == 'main',
          orElse: () =>
              throw StateError('No main isolate found in VM service.'),
        );
    _isolateId = mainIsolate.id;
    await _driverCommand({'command': 'get_health'});
  }

  Future<StudyUIScreenSnapshot> readScreen() async {
    final visibleKeys = <String>{};
    for (final key in _screenKeys) {
      if (await waitForValueKey(
        key,
        timeout: const Duration(milliseconds: 100),
      )) {
        visibleKeys.add(key);
      }
    }

    return StudyUIScreenSnapshot(
      screen: _inferScreen(visibleKeys),
      visibleKeys: visibleKeys,
    );
  }

  Future<void> tapByValueKey(String key) => _tapByValueKey(key);

  Future<void> enterTextByValueKey(String key, String text) async {
    await _tapByValueKey(key);
    await _driverCommand({'command': 'enter_text', 'text': text});
  }

  Future<Map<String, dynamic>> requestData(String message) =>
      _driverCommand({'command': 'request_data', 'message': message});

  Future<bool> waitForValueKey(String key, {required Duration timeout}) async {
    try {
      await _driverCommand({
        'command': 'waitFor',
        ..._byValueKey(key),
        'timeout': '${timeout.inMilliseconds}',
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _tapByValueKey(String key) async {
    await _driverCommand({'command': 'tap', ..._byValueKey(key)});
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Future<Map<String, dynamic>> _driverCommand(Map<String, String> args) async {
    final service = _service;
    final isolateId = _isolateId;
    if (service == null || isolateId == null) {
      throw StateError('Not connected. Call connect first.');
    }

    final response = await service.callServiceExtension(
      'ext.flutter.driver',
      isolateId: isolateId,
      args: args,
    );
    final json = response.json;
    if (json == null) return {};
    final isError = json['isError'] as bool? ?? false;
    if (isError) {
      throw StateError('${json['response']}');
    }
    return (json['response'] as Map?)?.cast<String, dynamic>() ?? {};
  }
}

Map<String, String> _byValueKey(String key) => {
  'finderType': 'ByValueKey',
  'keyValueString': key,
  'keyValueType': 'String',
};

String normalizeVmServiceUri(String value) {
  final uri = Uri.parse(value);
  final scheme = switch (uri.scheme) {
    'http' => 'ws',
    'https' => 'wss',
    'ws' || 'wss' => uri.scheme,
    _ => throw const FormatException(
      'VM service URI must use HTTP or WebSocket.',
    ),
  };
  if (!{'localhost', '127.0.0.1', '::1'}.contains(uri.host.toLowerCase())) {
    throw const FormatException('VM service URI must use a loopback host.');
  }
  final basePath = uri.path.endsWith('/')
      ? uri.path.substring(0, uri.path.length - 1)
      : uri.path;
  final path = basePath.endsWith('/ws') ? basePath : '$basePath/ws';
  return uri.replace(scheme: scheme, path: path).toString();
}

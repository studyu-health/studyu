import 'package:studyu_mcp/ui/vm_service_ui_driver.dart';
import 'package:test/test.dart';

void main() {
  group('normalizeVmServiceUri', () {
    test('normalizes a loopback HTTP URI', () {
      expect(
        normalizeVmServiceUri('http://127.0.0.1:1234/token='),
        'ws://127.0.0.1:1234/token=/ws',
      );
    });

    test('normalizes a trailing slash without creating a double slash', () {
      expect(
        normalizeVmServiceUri('http://127.0.0.1:1234/token=/'),
        'ws://127.0.0.1:1234/token=/ws',
      );
    });

    test('accepts loopback WebSocket URIs', () {
      expect(
        normalizeVmServiceUri('ws://localhost:1234/token=/ws'),
        'ws://localhost:1234/token=/ws',
      );
    });

    test('rejects non-loopback hosts', () {
      expect(
        () => normalizeVmServiceUri('ws://example.com:1234/token=/ws'),
        throwsFormatException,
      );
    });
  });
}

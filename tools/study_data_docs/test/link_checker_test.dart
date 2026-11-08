import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:study_data_docs/src/link_checker.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('link_checker_test_');
  });

  tearDown(() {
    tmp.deleteSync(recursive: true);
  });

  test('returns no broken links when all targets exist', () {
    File(p.join(tmp.path, 'a.md')).writeAsStringSync('# A\n\n[B](b.md)\n');
    File(p.join(tmp.path, 'b.md')).writeAsStringSync('# B\n');

    final broken = checkLinks(tmp.path);
    expect(broken, isEmpty);
  });

  test('finds broken relative links', () {
    File(
      p.join(tmp.path, 'a.md'),
    ).writeAsStringSync('# A\n\n[Missing](missing.md)\n');

    final broken = checkLinks(tmp.path);
    expect(broken.length, equals(1));
    expect(broken.first.href, equals('missing.md'));
  });

  test('ignores http(s) links', () {
    File(
      p.join(tmp.path, 'a.md'),
    ).writeAsStringSync('# A\n\n[External](https://example.com)\n');

    final broken = checkLinks(tmp.path);
    expect(broken, isEmpty);
  });

  test('ignores anchor-only links', () {
    File(
      p.join(tmp.path, 'a.md'),
    ).writeAsStringSync('# A\n\n[Heading](#section)\n');

    final broken = checkLinks(tmp.path);
    expect(broken, isEmpty);
  });

  test('validates relative links with heading anchors', () {
    File(
      p.join(tmp.path, 'a.md'),
    ).writeAsStringSync('# A\n\n[B](b.md#section-two)\n');
    File(p.join(tmp.path, 'b.md')).writeAsStringSync('# B\n\n## Section Two\n');

    final broken = checkLinks(tmp.path);
    expect(broken, isEmpty);
  });

  test('validates relative links with explicit html anchors', () {
    File(
      p.join(tmp.path, 'a.md'),
    ).writeAsStringSync('# A\n\n[B](b.md#custom-anchor)\n');
    File(
      p.join(tmp.path, 'b.md'),
    ).writeAsStringSync('# B\n\n<a id="custom-anchor"></a>\n');

    final broken = checkLinks(tmp.path);
    expect(broken, isEmpty);
  });

  test('finds broken relative heading anchors', () {
    File(
      p.join(tmp.path, 'a.md'),
    ).writeAsStringSync('# A\n\n[B](b.md#missing-section)\n');
    File(p.join(tmp.path, 'b.md')).writeAsStringSync('# B\n\n## Section Two\n');

    final broken = checkLinks(tmp.path);
    expect(broken.length, equals(1));
    expect(broken.first.href, equals('b.md#missing-section'));
  });

  test('validates anchors on directory links against index markdown', () {
    Directory(p.join(tmp.path, 'guide')).createSync();
    File(p.join(tmp.path, 'a.md')).writeAsStringSync(
      '# A\n\n[Valid](guide/#section-two)\n[Broken](guide/#missing-section)\n',
    );
    File(
      p.join(tmp.path, 'guide', 'index.md'),
    ).writeAsStringSync('# Guide\n\n## Section Two\n');

    final broken = checkLinks(tmp.path);
    expect(broken.map((link) => link.href), ['guide/#missing-section']);
  });

  test('ignores anchors on external urls', () {
    File(
      p.join(tmp.path, 'a.md'),
    ).writeAsStringSync('# A\n\n[External](https://example.com#missing)\n');

    final broken = checkLinks(tmp.path);
    expect(broken, isEmpty);
  });
}

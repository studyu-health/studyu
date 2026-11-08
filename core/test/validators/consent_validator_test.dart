import 'package:studyu_core/src/models/consent/consent_item.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/consent_validator.dart';
import 'package:test/test.dart';

Study _studyWithConsent(List<ConsentItem> items) {
  final s = Study('id', 'user');
  s.consent = items;
  return s;
}

ConsentItem _item({String? title, String? description}) {
  final c = ConsentItem.withId();
  c.title = title;
  c.description = description;
  return c;
}

void main() {
  test('empty consent at publish -> consent.no_items error', () {
    final r = validateConsent(_studyWithConsent([]), ValidationLevel.publish);
    expect(r.valid, isFalse);
    expect(r.errors.any((e) => e.code == 'consent.no_items'), isTrue);
  });

  test('empty consent at draft -> no warning', () {
    final r = validateConsent(_studyWithConsent([]), ValidationLevel.draft);
    expect(r.valid, isTrue);
    expect(r.warnings.where((w) => w.code == 'consent.no_items'), isEmpty);
  });

  test('consent item with null title -> consent.item_title_required', () {
    final r = validateConsent(
      _studyWithConsent([_item(description: 'desc')]),
      ValidationLevel.draft,
    );
    expect(r.valid, isFalse);
    expect(
      r.errors.any((e) => e.code == 'consent.item_title_required'),
      isTrue,
    );
  });

  test('consent item with empty title -> consent.item_title_required', () {
    final r = validateConsent(
      _studyWithConsent([_item(title: '', description: 'desc')]),
      ValidationLevel.draft,
    );
    expect(r.valid, isFalse);
    expect(
      r.errors.any((e) => e.code == 'consent.item_title_required'),
      isTrue,
    );
  });

  test(
    'consent item with null description -> consent.item_description_required',
    () {
      final r = validateConsent(
        _studyWithConsent([_item(title: 'title')]),
        ValidationLevel.draft,
      );
      expect(r.valid, isFalse);
      expect(
        r.errors.any((e) => e.code == 'consent.item_description_required'),
        isTrue,
      );
    },
  );

  test('consent item with title and description -> passes', () {
    final r = validateConsent(
      _studyWithConsent([_item(title: 'title', description: 'desc')]),
      ValidationLevel.draft,
    );
    expect(r.valid, isTrue);
  });

  test('two items: one valid, one missing description -> one error', () {
    final r = validateConsent(
      _studyWithConsent([
        _item(title: 'title1', description: 'desc1'),
        _item(title: 'title2'),
      ]),
      ValidationLevel.draft,
    );
    expect(r.valid, isFalse);
    expect(r.errors.length, 1);
    expect(r.errors.first.code, 'consent.item_description_required');
  });
}

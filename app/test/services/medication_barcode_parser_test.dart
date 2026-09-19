import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:studyu_app/services/medication_barcode_parser.dart';

void main() {
  test('validates manual PZN and Code 39 payloads', () {
    expect(pznFromManualInput(' 03752864 '), '03752864');
    expect(
      pznFromBarcode(
        const Barcode(format: BarcodeFormat.code39, rawValue: '-03752864'),
      ),
      '03752864',
    );
  });

  test('rejects invalid checksum and unsupported QR format', () {
    expect(pznFromManualInput('03752865'), isNull);
    expect(
      pznFromBarcode(
        const Barcode(format: BarcodeFormat.code39, rawValue: '-03752865'),
      ),
      isNull,
    );
    expect(
      pznFromBarcode(
        const Barcode(format: BarcodeFormat.qrCode, rawValue: '-03752864'),
      ),
      isNull,
    );
  });

  test('uses decoded bytes before raw value and ignores Vision raw bytes', () {
    final barcode = Barcode(
      format: BarcodeFormat.code39,
      rawDecodedBytes: DecodedBarcodeBytes(
        bytes: Uint8List.fromList('-03752864'.codeUnits),
      ),
      rawValue: '-03752865',
    );
    expect(pznFromBarcode(barcode), '03752864');

    final visionBarcode = Barcode(
      format: BarcodeFormat.code39,
      rawDecodedBytes: DecodedVisionBarcodeBytes(
        rawBytes: Uint8List.fromList('-03752864'.codeUnits),
      ),
      rawValue: '-03752865',
    );
    expect(pznFromBarcode(visionBarcode), isNull);
  });

  test('parses GS1 NTIN and ASC Macro 06 PPN payloads', () {
    const pzn = '03752864';
    const gtinData = '0415003752864';
    final gtin = '$gtinData${gtinCheckDigit(gtinData)}';
    expect(parseGs1Payload('(01)$gtin'), pzn);

    const ppid = '00$pzn';
    final ascField = '9N$ppid${ppnCheck(ppid)}';
    final ascPayload = '[)>\u001e06\u001d$ascField\u001e\u0004';
    expect(parseAscPayload(ascPayload), pzn);
  });

  test('parses raw GS1 payload after the symbology identifier', () {
    expect(parseGs1Payload(']d20104150037528643'), '03752864');
  });
  test('rejects empty, malformed, and ambiguous barcode payloads', () {
    expect(pznFromManualInput(''), isNull);
    expect(pznFromManualInput('0375286'), isNull);
    expect(pznFromBarcode(const Barcode(format: BarcodeFormat.code39)), isNull);
    expect(
      pznFromBarcode(
        const Barcode(format: BarcodeFormat.dataMatrix, rawValue: 'not-a-gs1'),
      ),
      isNull,
    );
    expect(parseCode39Payload('03752864'), isNull);
    expect(parseAscPayload(''), isNull);
    expect(
      parseAscPayload('[)>\u001e06\u001d9N000375286400\u001e\u0004'),
      isNull,
    );
  });

  test('handles symbology identifiers and raw GS1 fields', () {
    const pzn = '03752864';
    const gtinData = '0415003752864';
    final gtin = '$gtinData${gtinCheckDigit(gtinData)}';

    expect(parseGs1Payload(']d2(01)$gtin'), pzn);
    expect(parseGs1Payload('01${gtin}10batch'), pzn);
    expect(parseGs1Payload('(10)batch(01)$gtin'), pzn);
    expect(parseGs1Payload('(01)$gtin(01)$gtin'), isNull);
  });

  test('rejects invalid GS1 and PPN checksums', () {
    const pzn = '03752864';
    const gtinData = '0415003752864';
    final gtin = '$gtinData${gtinCheckDigit(gtinData)}';

    expect(parseGs1Payload('(01)${gtin.substring(0, 13)}0'), isNull);
    expect(parseGs1Payload('01${gtin.substring(0, 13)}0'), isNull);
    expect(
      parseAscPayload(
        '[)>\u001e06\u001d9N00$pzn${ppnCheck('10$pzn')}\u001e\u0004',
      ),
      isNull,
    );
    expect(() => gtinCheckDigit('123'), throwsArgumentError);
    expect(isValidPzn('00000001'), isFalse);
  });

  test('covers vision bytes and symbology prefixes', () {
    const gtinData = '0415003752864';
    final gtin = '$gtinData${gtinCheckDigit(gtinData)}';

    final visionBarcode = Barcode(
      format: BarcodeFormat.dataMatrix,
      rawDecodedBytes: DecodedVisionBarcodeBytes(
        bytes: Uint8List.fromList('01$gtin'.codeUnits),
        rawBytes: Uint8List.fromList('vision-payload'.codeUnits),
      ),
      rawValue: 'not-used',
    );
    expect(pznFromBarcode(visionBarcode), '03752864');

    expect(parseGs1Payload(']d2(01)$gtin'), '03752864');
    expect(parseGs1Payload(']d2(10)batch(01)$gtin'), '03752864');
    expect(parseGs1Payload(']d2(17)251231(01)$gtin'), '03752864');
    expect(parseGs1Payload(']d2(21)serial(01)$gtin'), '03752864');
    expect(parseGs1Payload('01$gtin'), '03752864');
    expect(parseGs1Payload('10batch01$gtin'), '03752864');
    expect(parseGs1Payload('1725123101$gtin'), '03752864');
    expect(parseGs1Payload('21serial01$gtin'), '03752864');
  });

  test('handles raw GS1 separators and AI boundaries', () {
    const gtinData = '0415003752864';
    final gtin = '$gtinData${gtinCheckDigit(gtinData)}';

    expect(parseGs1Payload('10batch\u001d01$gtin'), '03752864');
    expect(parseGs1Payload('10batch01$gtin'), '03752864');
    expect(parseGs1Payload('10batch\u001d'), isNull);
  });
}

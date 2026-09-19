import 'dart:convert';

import 'package:mobile_scanner/mobile_scanner.dart';

final RegExp _pznPattern = RegExp(r'^[0-9]{8}$');
final RegExp _code39Pattern = RegExp(r'^-([0-9]{8})$');
final RegExp _ascPpnPattern = RegExp(r'^9N[0-9]{12}$');
final RegExp _digitsPattern = RegExp(r'^[0-9]+$');

/// Returns a checksum-valid eight-digit PZN from manual input.
String? pznFromManualInput(String input) {
  final pzn = input.trim();
  return isValidPzn(pzn) ? pzn : null;
}

/// Returns a checksum-valid PZN from a supported medication barcode.
///
/// Medication scans support Code 39 and Data Matrix only. QR codes are never
/// interpreted as medication identifiers.
String? pznFromBarcode(Barcode barcode) {
  if (barcode.format != BarcodeFormat.code39 &&
      barcode.format != BarcodeFormat.dataMatrix) {
    return null;
  }

  final payload = _decodedBarcodeText(barcode);
  if (payload == null) return null;

  final candidates = <String?>[
    if (barcode.format == BarcodeFormat.code39) parseCode39Payload(payload),
    if (barcode.format == BarcodeFormat.dataMatrix) ...[
      parseAscPayload(payload),
      parseGs1Payload(payload),
    ],
  ].whereType<String>().toList(growable: false);

  if (candidates.length != 1) return null;
  final candidate = candidates.single;
  return isValidPzn(candidate) ? candidate : null;
}

String? _decodedBarcodeText(Barcode barcode) {
  final decodedBytes = barcode.rawDecodedBytes;
  if (decodedBytes is DecodedBarcodeBytes && decodedBytes.bytes.isNotEmpty) {
    return latin1.decode(decodedBytes.bytes);
  }
  if (decodedBytes is DecodedVisionBarcodeBytes &&
      decodedBytes.bytes != null &&
      decodedBytes.bytes!.isNotEmpty) {
    return latin1.decode(decodedBytes.bytes!);
  }

  final rawValue = barcode.rawValue;
  return rawValue == null || rawValue.isEmpty ? null : rawValue;
}

/// Validates the German PZN mod-11 checksum.
bool isValidPzn(String pzn) {
  if (!_pznPattern.hasMatch(pzn)) return false;

  var sum = 0;
  for (var index = 0; index < 7; index++) {
    sum += int.parse(pzn[index]) * (index + 1);
  }
  final remainder = sum % 11;
  return remainder != 10 && remainder == int.parse(pzn[7]);
}

/// Calculates the two-digit PPN check value for a ten-character PPID.
String ppnCheck(String payload) {
  var sum = 0;
  for (var index = 0; index < payload.length; index++) {
    sum += payload.codeUnitAt(index) * (index + 2);
  }
  return (sum % 97).toString().padLeft(2, '0');
}

/// Calculates the GS1 mod-10 check digit for thirteen numeric data digits.
int gtinCheckDigit(String data13) {
  if (!RegExp(r'^[0-9]{13}$').hasMatch(data13)) {
    throw ArgumentError.value(
      data13,
      'data13',
      'Must contain exactly 13 digits.',
    );
  }

  var sum = 0;
  for (var index = data13.length - 1; index >= 0; index--) {
    final positionFromRight = data13.length - index;
    final weight = positionFromRight.isOdd ? 3 : 1;
    sum += int.parse(data13[index]) * weight;
  }
  return (10 - (sum % 10)) % 10;
}

/// Parses a PZN encoded as `-12345678` in Code 39.
String? parseCode39Payload(String payload) =>
    _code39Pattern.firstMatch(payload)?.group(1);

/// Parses an ASC Macro 06 Data Matrix payload containing a valid 9N PPN.
String? parseAscPayload(String payload) {
  const prefix = '[)>\u001e';
  const suffix = '\u001e\u0004';
  if (!payload.startsWith(prefix) || !payload.endsWith(suffix)) return null;

  final body = payload.substring(prefix.length, payload.length - suffix.length);
  if (body.isEmpty || body.contains('\u0004')) return null;

  final records = body.split('\u001e');
  if (records.any((record) => record.isEmpty)) return null;

  final fields = <String>[];
  for (final record in records) {
    final recordFields = record.split('\u001d');
    if (recordFields.any((field) => field.isEmpty)) return null;
    fields.addAll(recordFields);
  }

  // Macro 06 is the first application record; 9N may appear later in any
  // field position.
  if (fields.length < 2 || fields.first != '06') return null;

  final ppnFields = fields
      .where(_ascPpnPattern.hasMatch)
      .toList(growable: false);
  if (ppnFields.length != 1) return null;

  final field = ppnFields.single;
  final ppid = field.substring(2, 12);
  final suppliedCheck = field.substring(12, 14);
  if (ppnCheck(ppid) != suppliedCheck) return null;

  // PPID = PRA (two characters) + PZN (eight digits).
  return ppid.substring(2, 10);
}

/// Parses a GS1 payload with an NTIN in AI 01.
String? parseGs1Payload(String payload) {
  final value = _stripSymbologyIdentifier(payload);
  if (value == null || value.isEmpty) return null;

  final applicationIdentifiers = value.startsWith('(')
      ? _parseHumanReadableGs1(value)
      : _parseRawGs1(value);
  if (applicationIdentifiers == null) return null;

  final ntin = applicationIdentifiers['01'];
  if (ntin == null ||
      !_digitsPattern.hasMatch(ntin) ||
      ntin.length != 14 ||
      !ntin.startsWith('04150')) {
    return null;
  }

  if (gtinCheckDigit(ntin.substring(0, 13)) != int.parse(ntin[13])) {
    return null;
  }
  return ntin.substring(5, 13);
}

String? _stripSymbologyIdentifier(String payload) {
  if (!payload.startsWith(']')) return payload;

  final identifierAndValue = payload.substring(1);
  for (
    var length = 1;
    length <= 3 && length <= identifierAndValue.length;
    length++
  ) {
    final identifier = identifierAndValue.substring(0, length);
    final value = identifierAndValue.substring(length);
    if (RegExp(r'^[A-Za-z0-9]+$').hasMatch(identifier) &&
        _startsWithKnownAi(value)) {
      return value;
    }
  }
  return null;
}

bool _startsWithKnownAi(String value) {
  if (value.startsWith('(')) {
    return value.startsWith('(01)') ||
        value.startsWith('(10)') ||
        value.startsWith('(17)') ||
        value.startsWith('(21)');
  }
  return value.startsWith('01') ||
      value.startsWith('10') ||
      value.startsWith('17') ||
      value.startsWith('21');
}

Map<String, String>? _parseHumanReadableGs1(String payload) {
  final values = <String, String>{};
  var index = 0;

  while (index < payload.length) {
    if (index + 4 > payload.length ||
        payload[index] != '(' ||
        payload[index + 3] != ')') {
      return null;
    }

    final ai = payload.substring(index + 1, index + 3);
    final fixedLength = _fixedLengthForAi(ai);
    if (fixedLength == null && !_isVariableAi(ai)) return null;
    if (values.containsKey(ai)) return null;
    index += 4;

    if (fixedLength != null) {
      if (index + fixedLength > payload.length) return null;
      final value = payload.substring(index, index + fixedLength);
      if (!_digitsPattern.hasMatch(value)) return null;
      values[ai] = value;
      index += fixedLength;
      continue;
    }

    final nextAi = payload.indexOf('(', index);
    final end = nextAi == -1 ? payload.length : nextAi;
    final value = payload.substring(index, end);
    if (value.isEmpty || value.contains('\u001d')) return null;
    values[ai] = value;
    index = end;
  }

  return values;
}

Map<String, String>? _parseRawGs1(String payload) {
  final values = <String, String>{};
  var index = 0;

  while (index < payload.length) {
    if (payload[index] == '\u001d' || index + 2 > payload.length) return null;

    final ai = payload.substring(index, index + 2);
    final fixedLength = _fixedLengthForAi(ai);
    if (fixedLength == null && !_isVariableAi(ai)) return null;
    if (values.containsKey(ai)) return null;
    index += 2;

    if (fixedLength != null) {
      if (index + fixedLength > payload.length) return null;
      final value = payload.substring(index, index + fixedLength);
      if (!_digitsPattern.hasMatch(value)) return null;
      values[ai] = value;
      index += fixedLength;
      continue;
    }

    final end = _rawVariableEnd(payload, index);
    if (end == index) return null;
    values[ai] = payload.substring(index, end);
    if (end == payload.length) {
      index = end;
    } else if (payload[end] == '\u001d') {
      index = end + 1;
      if (index == payload.length) return null;
    } else {
      index = end;
    }
  }

  return values;
}

int? _fixedLengthForAi(String ai) => switch (ai) {
  '01' => 14,
  '17' => 6,
  _ => null,
};

bool _isVariableAi(String ai) => ai == '10' || ai == '21';

int _rawVariableEnd(String payload, int start) {
  for (var index = start; index < payload.length; index++) {
    if (payload[index] == '\u001d' || _looksLikeAiBoundary(payload, index)) {
      return index;
    }
  }
  return payload.length;
}

bool _looksLikeAiBoundary(String payload, int index) {
  if (index + 2 > payload.length) return false;
  final ai = payload.substring(index, index + 2);
  final fixedLength = _fixedLengthForAi(ai);
  if (fixedLength != null) {
    if (index + 2 + fixedLength > payload.length) return false;
    return _digitsPattern.hasMatch(
      payload.substring(index + 2, index + 2 + fixedLength),
    );
  }
  return _isVariableAi(ai) && index + 2 < payload.length;
}

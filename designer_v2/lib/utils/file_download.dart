import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:studyu_designer_v2/utils/json_format.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:web/web.dart' as web;

dynamic downloadFile({required String fileContent, required String filename}) {
  final List<int> bytes = utf8.encode(fileContent);
  return downloadBytes(bytes: bytes, filename: filename);
}

void downloadBytes({required List<int> bytes, required String filename}) {
  final content = base64Encode(bytes);
  final anchor = web.HTMLAnchorElement()
    ..href = 'data:application/octet-stream;base64,$content'
    ..style.display = 'none'
    ..download = filename;

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}

abstract class FileFormatEncoder() {
  Future<String> encodeAsync(List<Map<String, dynamic>> records) {
    return runInBackground<String>(() => encode(records));
  }

  String encode(List<Map<String, dynamic>> records);

  String call(List<Map<String, dynamic>> records) {
    return encode(records);
  }
}

class CSVStringEncoder() extends FileFormatEncoder {
  @override
  String encode(List<Map<String, dynamic>> records) {
    final Set<String> columnNames = {};
    for (final record in records) {
      columnNames.addAll(record.keys);
    }

    final headerRow = columnNames.toList();
    final dataRows = records.map((record) {
      final row = [];
      for (final columnName in headerRow) {
        final cellValue =
            record[columnName] ?? ''; // fill missing columns with empty string
        row.add(cellValue);
      }
      return row;
    }).toList();

    final table = [headerRow, ...dataRows];
    return Csv().encode(table);
  }
}

class JsonStringEncoder() extends FileFormatEncoder {
  @override
  String encode(List<Map<String, dynamic>> records) {
    return prettyJson(records);
  }
}

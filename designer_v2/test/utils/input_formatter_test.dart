import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/utils/input_formatter.dart';

void main() {
  group('StudySequenceFormatter', () {
    final formatter = StudySequenceFormatter();

    TextEditingValue format(String oldText, String newText) {
      return formatter.formatEditUpdate(
        TextEditingValue(text: oldText),
        TextEditingValue(text: newText),
      );
    }

    test('uppercases valid sequence input', () {
      expect(format('', 'abba').text, 'ABBA');
    });

    test('removes whitespace from pasted sequence input', () {
      expect(format('', ' A b B A ').text, 'ABBA');
    });

    test('rejects characters other than A and B', () {
      expect(format('AB', 'ABC').text, 'AB');
    });
  });
}

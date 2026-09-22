import 'package:studyu_core/src/util/recovery.dart';
import 'package:studyu_core/src/util/wordlists.dart';
import 'package:test/test.dart';

void main() {
  group('Recovery Encoding/Decoding', () {
    test('fixed UUID phrases remain stable', () {
      expect(
        encode(BigInt.zero),
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon'
            .split(' '),
      );
      expect(
        encode(
          BigInt.parse('1234567890abcdef1234567890abcdef', radix: 16),
          wordlist: wordlistDe,
        ),
        'abitur befinden gepard aufruf piste import schere hemd heilen farn probe rohr stamm'
            .split(' '),
      );
    });
    test('should encode and decode 128-bit ID correctly', () {
      // Test with a known 128-bit value
      final id = BigInt.parse('1234567890ABCDEF1234567890ABCDEF', radix: 16);

      final words = encode(id);
      expect(words.length, equals(RecoveryConstants.totalWordCount));

      final decoded = decode(words);
      expect(decoded, equals(id));
    });

    test('should encode and decode zero correctly', () {
      final id = BigInt.zero;

      final words = encode(id);
      expect(words.length, equals(RecoveryConstants.totalWordCount));

      final decoded = decode(words);
      expect(decoded, equals(id));
    });

    test('should encode and decode max 128-bit value correctly', () {
      final id = (BigInt.one << 128) - BigInt.one;

      final words = encode(id);
      expect(words.length, equals(RecoveryConstants.totalWordCount));

      final decoded = decode(words);
      expect(decoded, equals(id));
    });

    test('should throw when ID exceeds 128 bits', () {
      final id = BigInt.one << 128;

      expect(() => encode(id), throwsArgumentError);
    });

    test('should throw when ID is negative', () {
      final id = BigInt.from(-1);

      expect(() => encode(id), throwsArgumentError);
    });
  });

  group('Checksum Validation', () {
    test('should detect single word corruption', () {
      final id = BigInt.parse('1234567890ABCDEF1234567890ABCDEF', radix: 16);
      final words = encode(id);

      // Corrupt a single word
      final corruptedWords = List<String>.from(words);
      corruptedWords[5] = 'different';

      expect(() => decode(corruptedWords), throwsArgumentError);
    });

    test('should detect swapped words', () {
      final id = BigInt.parse('1234567890ABCDEF1234567890ABCDEF', radix: 16);
      final words = encode(id);

      // Swap two adjacent words
      final corruptedWords = List<String>.from(words);
      final temp = corruptedWords[3];
      corruptedWords[3] = corruptedWords[4];
      corruptedWords[4] = temp;

      expect(() => decode(corruptedWords), throwsArgumentError);
    });

    test('should detect missing words', () {
      final id = BigInt.parse('1234567890ABCDEF1234567890ABCDEF', radix: 16);
      final words = encode(id);

      // Remove the last word (checksum)
      final truncatedWords = words.sublist(0, words.length - 1);

      expect(() => decode(truncatedWords), throwsArgumentError);
    });

    test('should detect extra words', () {
      final id = BigInt.parse('1234567890ABCDEF1234567890ABCDEF', radix: 16);
      final words = encode(id);

      // Add an extra word
      final extendedWords = List<String>.from(words)..add('extra');

      expect(() => decode(extendedWords), throwsArgumentError);
    });

    test('should accept valid phrase with correct checksum', () {
      final id = BigInt.parse('DEADBEEFCAFEBABE1234567890ABCDEF', radix: 16);
      final words = encode(id);

      // Should not throw
      final decoded = decode(words);
      expect(decoded, equals(id));
    });
  });

  group('Wordlist Validation', () {
    test('English and German wordlists contain 2048 unique words', () {
      for (final wordlist in [wordlistEn, wordlistDe]) {
        expect(wordlist, hasLength(2048));
        expect(wordlist.toSet(), hasLength(2048));
      }
    });
    test('should use English wordlist by default', () {
      final id = BigInt.parse('1234567890ABCDEF1234567890ABCDEF', radix: 16);
      final words = encode(id);

      // All words should be from English wordlist
      for (final word in words) {
        expect(
          wordlistEn.contains(word),
          isTrue,
          reason: 'Word "$word" not found in English wordlist',
        );
      }
    });

    test('should accept German wordlist when specified', () {
      final id = BigInt.parse('1234567890ABCDEF1234567890ABCDEF', radix: 16);
      final words = encode(id, wordlist: wordlistDe);

      // All words should be from German wordlist
      for (final word in words) {
        expect(
          wordlistDe.contains(word),
          isTrue,
          reason: 'Word "$word" not found in German wordlist',
        );
      }

      // Should decode correctly with German wordlist
      final decoded = decode(words, wordlist: wordlistDe);
      expect(decoded, equals(id));
    });

    test('should throw on unknown words', () {
      final invalidWords = [
        'apple',
        'banana',
        'cherry',
        'date',
        'elderberry',
        'fig',
        'grape',
        'honeydew',
        'kiwi',
        'lemon',
        'mango',
        'nectarine',
        'orange',
      ];

      expect(() => decode(invalidWords), throwsArgumentError);
    });
  });

  group('Word Count Constants', () {
    test('should have correct total word count', () {
      expect(RecoveryConstants.totalWordCount, equals(13));
      expect(RecoveryConstants.dataWordCount, equals(12));
    });

    test('should validate word count correctly', () {
      expect(() => validateRecoveryWordCount(13), returnsNormally);
      expect(() => validateRecoveryWordCount(12), throwsArgumentError);
      expect(() => validateRecoveryWordCount(14), throwsArgumentError);
      expect(() => validateRecoveryWordCount(0), throwsArgumentError);
    });

    test('should calculate expected word count correctly', () {
      const config = EncodingConfig();
      final count = getExpectedWordCount(config);
      expect(count, equals(RecoveryConstants.totalWordCount));
    });

    test('should calculate word count without checksum', () {
      const config = EncodingConfig(useChecksum: false);
      final count = getExpectedWordCount(config);
      expect(count, equals(RecoveryConstants.dataWordCount));
    });
  });

  group('Encoding Configuration', () {
    test('should use correct default bit count', () {
      expect(RecoveryConstants.defaultBitCount, equals(128));
    });

    test('should use correct default bits per word', () {
      expect(RecoveryConstants.defaultBitsPerWord, equals(11));
    });

    test('should calculate words needed correctly', () {
      const config = EncodingConfig();
      expect(config.wordsNeeded(128), equals(12));
      expect(config.wordsNeeded(256), equals(24));
    });
  });

  group('Random ID Roundtrips', () {
    final testIds = [
      BigInt.parse('00000000000000000000000000000000', radix: 16),
      BigInt.parse('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', radix: 16),
      BigInt.parse('123456789ABCDEF0123456789ABCDEF0', radix: 16),
      BigInt.parse('AABBCCDDEEFF00112233445566778899', radix: 16),
      BigInt.parse('0102030405060708090A0B0C0D0E0F10', radix: 16),
    ];

    for (var i = 0; i < testIds.length; i++) {
      test('roundtrip test case $i', () {
        final id = testIds[i];
        final words = encode(id);
        final decoded = decode(words);
        expect(
          decoded,
          equals(id),
          reason: 'Failed for ID: ${id.toRadixString(16)}',
        );
      });
    }
  });

  group('Edge Cases', () {
    test('should handle empty word list', () {
      expect(() => decode([]), throwsArgumentError);
    });

    test('should handle single word', () {
      expect(() => decode(['apple']), throwsArgumentError);
    });

    test('should handle words with different casing', () {
      final id = BigInt.parse('1234567890ABCDEF1234567890ABCDEF', radix: 16);
      final words = encode(id);

      // Test uppercase
      final upperWords = words.map((w) => w.toUpperCase()).toList();
      expect(() => decode(upperWords), throwsArgumentError);

      // Test mixed case
      final mixedWords = words
          .asMap()
          .map((i, w) => MapEntry(i, i.isEven ? w.toUpperCase() : w))
          .values
          .toList();
      expect(() => decode(mixedWords), throwsArgumentError);
    });

    test('should handle whitespace in words', () {
      final id = BigInt.parse('1234567890ABCDEF1234567890ABCDEF', radix: 16);
      final words = encode(id);

      // Words with leading/trailing whitespace should fail
      final whitespaceWords = words.map((w) => ' $w ').toList();
      expect(() => decode(whitespaceWords), throwsArgumentError);
    });
  });

  group('Checksum Computation', () {
    test('should compute consistent checksums', () {
      final indices = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
      final checksum1 = computeChecksum(indices, wordlistEn.length);
      final checksum2 = computeChecksum(indices, wordlistEn.length);

      expect(checksum1, equals(checksum2));
    });

    test('should produce different checksums for different inputs', () {
      final indices1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
      final indices2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13];

      final checksum1 = computeChecksum(indices1, wordlistEn.length);
      final checksum2 = computeChecksum(indices2, wordlistEn.length);

      expect(checksum1, isNot(equals(checksum2)));
    });

    test('should throw on empty indices', () {
      expect(() => computeChecksum([], wordlistEn.length), throwsArgumentError);
    });
  });
}

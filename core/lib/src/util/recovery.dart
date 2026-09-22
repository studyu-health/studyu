import 'package:studyu_core/src/util/wordlists.dart';

/// Recovery phrase configuration constants
class RecoveryConstants() {
  /// Number of bits for the recovery ID (128-bit UUID)
  static const int defaultBitCount = 128;

  /// Number of bits per word (11 bits = 2048 wordlist)
  static const int defaultBitsPerWord = 11;

  /// Number of data words (12 words for 128 bits)
  static const int dataWordCount = 12;

  /// Total number of words including checksum (13 words)
  static const int totalWordCount = 13;

  /// Whether to include a checksum word
  static const bool defaultUseChecksum = true;

  /// Default encoding configuration
  static const EncodingConfig defaultConfig = EncodingConfig();
}

class const EncodingConfig({
  final int bitsPerWord = RecoveryConstants.defaultBitsPerWord,
  final bool useChecksum = RecoveryConstants.defaultUseChecksum,
}) {
  int wordsNeeded(int bitCount) {
    return (bitCount / bitsPerWord).ceil();
  }
}

List<int> encodeIdToIndices(
  BigInt participantId,
  int bitCount,
  EncodingConfig config,
) {
  if (participantId < BigInt.zero ||
      participantId >= (BigInt.one << bitCount)) {
    throw ArgumentError('ID must fit within $bitCount bits');
  }

  final numWords = config.wordsNeeded(bitCount);
  final mask = (1 << config.bitsPerWord) - 1;
  final indices = <int>[];

  BigInt remaining = participantId;
  for (int i = 0; i < numWords; i++) {
    final index = (remaining & BigInt.from(mask)).toInt();
    indices.insert(0, index);
    remaining = remaining >> config.bitsPerWord;
  }

  return indices;
}

BigInt decodeFromWords(
  List<String> words,
  List<String> wordlist,
  EncodingConfig config,
) {
  BigInt participantId = BigInt.zero;

  for (final word in words) {
    final index = wordlist.indexOf(word);
    if (index == -1) {
      throw ArgumentError('Invalid word: $word');
    }
    participantId = (participantId << config.bitsPerWord) | BigInt.from(index);
  }

  return participantId;
}

int computeChecksum(List<int> indices, int wordlistSize) {
  if (indices.isEmpty) {
    throw ArgumentError('Need at least one word index');
  }

  const primes = [31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79];

  int hash = 0;
  for (int i = 0; i < indices.length; i++) {
    final prime = primes[i % primes.length];
    hash ^= indices[i] * prime;
  }

  return hash % wordlistSize;
}

List<String> encode(
  BigInt participantId, {
  List<String>? wordlist,
  int bitCount = RecoveryConstants.defaultBitCount,
  EncodingConfig config = RecoveryConstants.defaultConfig,
}) {
  final effectiveWordlist = wordlist ?? wordlistEn;

  if (effectiveWordlist.length < (1 << config.bitsPerWord)) {
    throw ArgumentError(
      'Wordlist must have at least ${1 << config.bitsPerWord} words',
    );
  }

  final indices = encodeIdToIndices(participantId, bitCount, config);

  if (config.useChecksum) {
    final checksumIndex = computeChecksum(indices, effectiveWordlist.length);
    indices.add(checksumIndex);
  }

  return indices.map((i) => effectiveWordlist[i]).toList();
}

BigInt decode(
  List<String> words, {
  List<String>? wordlist,
  EncodingConfig config = RecoveryConstants.defaultConfig,
}) {
  if (words.isEmpty) {
    throw ArgumentError('Must provide at least one word');
  }

  final effectiveWordlist = wordlist ?? wordlistEn;

  List<String> dataWords = words;

  if (config.useChecksum) {
    if (words.length < 2) {
      throw ArgumentError('Need at least 2 words when using checksum');
    }

    dataWords = words.sublist(0, words.length - 1);
    final indices = dataWords.map((w) {
      final idx = effectiveWordlist.indexOf(w);
      if (idx == -1) throw ArgumentError('Invalid word: $w');
      return idx;
    }).toList();

    final expectedChecksum = computeChecksum(indices, effectiveWordlist.length);
    final actualChecksum = effectiveWordlist.indexOf(words.last);

    if (actualChecksum == -1) {
      throw ArgumentError('Invalid checksum word: ${words.last}');
    }

    if (expectedChecksum != actualChecksum) {
      throw ArgumentError(
        'Checksum mismatch: expected ${effectiveWordlist[expectedChecksum]}, '
        'got ${words.last}',
      );
    }
  }

  return decodeFromWords(dataWords, effectiveWordlist, config);
}

/// Validates that the word count matches the expected count for recovery
/// Throws [ArgumentError] if the count is invalid
void validateRecoveryWordCount(int wordCount) {
  if (wordCount != RecoveryConstants.totalWordCount) {
    throw ArgumentError(
      'Expected ${RecoveryConstants.totalWordCount} words, got $wordCount',
    );
  }
}

/// Returns the expected word count for a given configuration
int getExpectedWordCount(EncodingConfig config) {
  final dataWords = config.wordsNeeded(RecoveryConstants.defaultBitCount);
  return config.useChecksum ? dataWords + 1 : dataWords;
}

import 'dart:ui';

import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

extension EnumX on Enum {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension StringX on String {
  bool get isNewId => this == Config.newModelId;
  static String get kCopySuffix => tr.copy_suffix_label;

  String toKey() {
    return toLowerCase().replaceAll(' ', '_');
  }

  String withDuplicateLabel({String? label}) {
    label ??= kCopySuffix;

    final regexStr = r"\((?:" + label + r")\s*(\d*)\)$";
    String suffixFactory(int n) => (n > 0) ? "($label $n)" : "($label)";
    final regex = RegExp(regexStr);

    final Iterable<RegExpMatch> matches = regex.allMatches(this);

    if (matches.isNotEmpty) {
      final matchedSuffix = matches.last;
      final matchedIncrement = matchedSuffix.group(1);
      final currentIncrement =
          (matchedIncrement == null || matchedIncrement == '')
          ? 0
          : int.parse(matchedIncrement);
      final strWithoutLabel = replaceRange(
        matchedSuffix.start,
        matchedSuffix.end,
        '',
      ).trim();
      return "$strWithoutLabel ${suffixFactory(currentIncrement + 1)}";
    }
    return "$this ${suffixFactory(0)}";
  }

  List<String> get alphabet {
    return [
      'a',
      'b',
      'c',
      'd',
      'e',
      'f',
      'g',
      'h',
      'i',
      'j',
      'k',
      'l',
      'm',
      'n',
      'o',
    ];
  }

  String alphabetLetterFrom(int idx) {
    return alphabet[idx % alphabet.length];
  }

  String ensureSuffix(String suffix) {
    if (!endsWith(suffix)) {
      return this + suffix;
    }
    return this;
  }
}

extension DurationX on Duration {
  int get daysPerMonth => 30;
  int get daysPerYear => 365;
  int get microsecondsPerMonth => Duration.microsecondsPerDay * daysPerMonth;
  int get microsecondsPerYear => Duration.microsecondsPerDay * daysPerYear;
  int get inMonths => inMicroseconds ~/ microsecondsPerMonth;
  int get inYears => inMicroseconds ~/ microsecondsPerYear;
}

extension DateTimeAgoX on DateTime {
  String _timeAgoFormatted({bool inSeconds = true}) {
    final Duration diff = DateTime.now().difference(this);

    if (diff.inYears >= 1) {
      return tr.date_diff_years(diff.inYears);
    } else if (diff.inMonths >= 1) {
      return tr.date_diff_months(diff.inMonths);
    } else if (diff.inDays >= 1) {
      return tr.date_diff_days(diff.inDays);
    } else if (diff.inHours >= 1) {
      return tr.date_diff_hours(diff.inHours);
    } else if (diff.inMinutes >= 1) {
      return tr.date_diff_minutes(diff.inMinutes);
    } else if (diff.inSeconds >= 1 && inSeconds) {
      return tr.date_diff_seconds(diff.inSeconds);
    } else {
      return tr.date_just_now;
    }
  }

  String toTimeAgoString() {
    return _timeAgoFormatted(inSeconds: false);
  }

  String toTimeAgoStringPrecise() {
    return _timeAgoFormatted();
  }

  String toLocalizedString({
    required String locale,
    bool showTime = true,
    DateFormatPreference? datePreference,
    TimeFormatPreference? timePreference,
  }) {
    final parsedLocale = locale.replaceAll('-', '_').split('_');
    final localeValue = Locale(
      parsedLocale.first,
      parsedLocale.length > 1 ? parsedLocale[1] : null,
    );
    final time = toLocal();
    if (showTime) {
      return DateTimeFormat.formatDateTimeForLocale(
        localeValue,
        time,
        datePreference: datePreference,
        timePreference: timePreference,
      );
    }
    return DateTimeFormat.formatDateForLocale(
      localeValue,
      time,
      preference: datePreference,
    );
  }
}

typedef ListElementFactory<E> = E Function();

extension ListX<E> on List<E> {
  List<E> separatedBy(ListElementFactory<E> separatorBuilder) {
    final List<E> results = [];
    for (var i = 0; i < length; i++) {
      results.add(this[i]);
      if (i != length - 1) {
        results.add(separatorBuilder());
      }
    }
    return results;
  }

  bool equals(List other) {
    if (length != other.length) {
      return false;
    }
    for (var i = 0; i < length; i++) {
      if (this[i] != other[i]) {
        return false;
      }
    }
    return true;
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

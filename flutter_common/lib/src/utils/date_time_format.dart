import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyu_core/core.dart';

abstract final class DateTimeFormat() {
  static DateFormatPreference defaultDateFormat([Locale? locale]) {
    locale ??= PlatformDispatcher.instance.locale;
    if (locale.languageCode == 'de') return DateFormatPreference.german;
    if (locale.languageCode == 'en' && locale.countryCode == 'US') {
      return DateFormatPreference.us;
    }
    if (locale.languageCode == 'en' &&
        {'GB', 'AU', 'IE'}.contains(locale.countryCode)) {
      return DateFormatPreference.european;
    }
    return DateFormatPreference.iso;
  }

  static TimeFormatPreference defaultTimeFormat(BuildContext context) {
    final use24HourFormat = MediaQuery.maybeOf(context)?.alwaysUse24HourFormat;
    if (use24HourFormat == true) return TimeFormatPreference.h24;
    if (use24HourFormat == false) return TimeFormatPreference.h12;

    return defaultTimeFormatForLocale(PlatformDispatcher.instance.locale);
  }

  static String formatDate(
    BuildContext context,
    DateTime date, {
    DateFormatPreference? preference,
  }) {
    return formatDateForLocale(
      Localizations.localeOf(context),
      date,
      preference: preference,
    );
  }

  static String formatDateForLocale(
    Locale locale,
    DateTime date, {
    DateFormatPreference? preference,
  }) {
    final format = preference ?? defaultDateFormat(locale);
    return DateFormat(format.pattern, locale.toString()).format(date);
  }

  static String formatTime(
    BuildContext context,
    TimeOfDay time, {
    TimeFormatPreference? preference,
  }) {
    return formatTimeForLocale(
      Localizations.localeOf(context),
      time,
      preference: preference,
      use24HourFormat: MediaQuery.maybeOf(context)?.alwaysUse24HourFormat,
    );
  }

  static String formatTimeForLocale(
    Locale locale,
    TimeOfDay time, {
    TimeFormatPreference? preference,
    bool? use24HourFormat,
  }) {
    final format =
        preference ??
        (use24HourFormat == true
            ? TimeFormatPreference.h24
            : use24HourFormat == false
            ? TimeFormatPreference.h12
            : defaultTimeFormatForLocale(locale));
    return DateFormat(
      format.pattern,
      locale.toString(),
    ).format(DateTime(2000, 1, 1, time.hour, time.minute));
  }

  static TimeFormatPreference defaultTimeFormatForLocale(Locale locale) {
    return locale.languageCode == 'en' && locale.countryCode == 'US'
        ? TimeFormatPreference.h12
        : TimeFormatPreference.h24;
  }

  static String formatDateTime(
    BuildContext context,
    DateTime dateTime, {
    DateFormatPreference? datePreference,
    TimeFormatPreference? timePreference,
  }) {
    return formatDateTimeForLocale(
      Localizations.localeOf(context),
      dateTime,
      datePreference: datePreference,
      timePreference: timePreference,
      use24HourFormat: MediaQuery.maybeOf(context)?.alwaysUse24HourFormat,
    );
  }

  static String formatDateTimeForLocale(
    Locale locale,
    DateTime dateTime, {
    DateFormatPreference? datePreference,
    TimeFormatPreference? timePreference,
    bool? use24HourFormat,
  }) {
    return '${formatDateForLocale(locale, dateTime, preference: datePreference)} '
        '${formatTimeForLocale(locale, TimeOfDay.fromDateTime(dateTime), preference: timePreference, use24HourFormat: use24HourFormat)}';
  }
}

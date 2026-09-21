enum DateFormatPreset(final String pattern) {
  iso('yyyy-MM-dd'),
  european('dd/MM/yyyy'),
  us('MM/dd/yyyy'),
  german('dd.MM.yyyy');

  String toJson() => name;
  static DateFormatPreset fromJson(String json) {
    // Backward compatibility with old enum values
    final legacyMap = {
      'isoDate': iso,
      'europeanDate': european,
      'usDate': us,
      'germanDate': german,
      'isoDateTime': iso,
      'europeanDateTime': european,
      'usDateTimeAmPm': us,
    };
    // Handle any unknown values by defaulting to iso
    try {
      return legacyMap[json] ?? values.byName(json);
    } catch (_) {
      return iso;
    }
  }
}

enum TimeFormatPreset(final String pattern) {
  h24('HH:mm'),
  h12('hh:mm a');

  bool get is24Hour => this == TimeFormatPreset.h24;

  String toJson() => name;
  static TimeFormatPreset fromJson(String json) {
    // Backward compatibility - default to h24 if unknown
    try {
      return values.byName(json);
    } catch (_) {
      return h24;
    }
  }
}

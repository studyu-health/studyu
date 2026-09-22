enum DefaultDateOption(final String value) {
  none('none'),
  today('today'),
  now('now'),
  specific('specific');

  String toJson() => value;
  static DefaultDateOption fromJson(String json) => values.firstWhere(
    (e) => e.value == json,
    orElse: () => DefaultDateOption.none,
  );
}

enum DateInputType(final String value) {
  date('date'),
  time('time'),
  dateTime('dateTime');

  bool get isDate =>
      this == DateInputType.date || this == DateInputType.dateTime;
  bool get isTime =>
      this == DateInputType.time || this == DateInputType.dateTime;

  String toJson() => value;
  static DateInputType fromJson(String json) => values.firstWhere(
    (e) => e.value == json,
    orElse: () => DateInputType.date,
  );
}

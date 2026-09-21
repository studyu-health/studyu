import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/questionnaire/answer.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';
import 'package:studyu_core/src/models/questionnaire/questions/date_format_preset.dart';
import 'package:studyu_core/src/models/questionnaire/questions/date_input_type.dart';
import 'package:studyu_core/src/models/questionnaire/questions/default_date_option.dart';

part 'date_question.g.dart';

@JsonSerializable()
class DateQuestion extends Question<DateTime> {
  static const String questionType = 'date';

  @JsonKey(name: 'inputType')
  DateInputType inputType;

  @JsonKey(name: 'minDate')
  DateTime? minDate;

  @JsonKey(name: 'maxDate')
  DateTime? maxDate;

  @JsonKey(name: 'minTime')
  String? minTime;

  @JsonKey(name: 'maxTime')
  String? maxTime;

  @JsonKey(name: 'dateFormatPreset')
  DateFormatPreset dateFormatPreset;

  @JsonKey(name: 'timeFormatPreset')
  TimeFormatPreset timeFormatPreset;

  @JsonKey(name: 'defaultOption')
  DefaultDateOption defaultOption;

  @JsonKey(name: 'defaultSpecificDate')
  DateTime? defaultSpecificDate;

  @JsonKey(name: 'defaultSpecificTime')
  String? defaultSpecificTime;

  new({
    this.inputType = DateInputType.date,
    this.minDate,
    this.maxDate,
    this.minTime,
    this.maxTime,
    this.dateFormatPreset = DateFormatPreset.iso,
    this.timeFormatPreset = TimeFormatPreset.h24,
    this.defaultOption = DefaultDateOption.none,
    this.defaultSpecificDate,
    this.defaultSpecificTime,
  }) : super(questionType);

  new withId({
    this.inputType = DateInputType.date,
    this.minDate,
    this.maxDate,
    this.minTime,
    this.maxTime,
    this.dateFormatPreset = DateFormatPreset.iso,
    this.timeFormatPreset = TimeFormatPreset.h24,
    this.defaultOption = DefaultDateOption.none,
    this.defaultSpecificDate,
    this.defaultSpecificTime,
  }) : super.withId(questionType);

  factory fromJson(Map<String, dynamic> json) {
    // Handle migration from old format presets
    final dateFormatPresetValue = json['dateFormatPreset'] as String?;
    if (dateFormatPresetValue != null) {
      // Check if this is an old format with time included
      final timeVariants = [
        'isoDateTime',
        'europeanDateTime',
        'usDateTimeAmPm',
      ];

      if (timeVariants.contains(dateFormatPresetValue)) {
        // Migrate old time-inclusive format to new structure
        json['inputType'] = 'dateTime';

        // Set time format based on old preset
        if (dateFormatPresetValue == 'usDateTimeAmPm') {
          json['timeFormatPreset'] = 'h12';
        } else {
          json['timeFormatPreset'] = 'h24';
        }
      } else if (!json.containsKey('inputType')) {
        // Old date-only format without inputType field
        json['inputType'] = 'date';
      }
    }

    return _$DateQuestionFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$DateQuestionToJson(this);

  Answer<DateTime> constructAnswer(DateTime response) =>
      Answer.forQuestion(this, response);

  String get dateFormat => dateFormatPreset.pattern;

  String get timeFormat => timeFormatPreset.pattern;

  bool get isDateOnly => inputType == DateInputType.date;

  bool get isTimeOnly => inputType == DateInputType.time;

  bool get isDateTime => inputType == DateInputType.dateTime;

  bool get isDate =>
      inputType == DateInputType.date || inputType == DateInputType.dateTime;

  bool get isTime =>
      inputType == DateInputType.time || inputType == DateInputType.dateTime;

  DateTime? getDefaultValue() {
    switch (defaultOption) {
      case DefaultDateOption.none:
        return null;
      case DefaultDateOption.today:
        if (isDate) {
          return DateTime.now();
        }
        return null;
      case DefaultDateOption.now:
        if (isDateTime) {
          return DateTime.now();
        }
        return null;
      case DefaultDateOption.specific:
        if (defaultSpecificDate != null) {
          return defaultSpecificDate;
        }
        return null;
    }
  }

  String? getInitialTimeValue() {
    if (!isTime) return null;

    switch (defaultOption) {
      case DefaultDateOption.none:
      case DefaultDateOption.today:
        return null;
      case DefaultDateOption.now:
        final now = DateTime.now();
        return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      case DefaultDateOption.specific:
        return defaultSpecificTime;
    }
  }
}

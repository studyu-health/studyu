// ignore_for_file: avoid_classes_with_only_static_members

import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';

part 'analytics.g.dart';

class StudyULogger() {
  static Logger logger = Logger();

  static void trace(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.t(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void debug(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.d(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void info(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void warning(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.w(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void error(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.e(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void fatal(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.f(message, time: time, error: error, stackTrace: stackTrace);
  }
}

@JsonSerializable()
class StudyUAnalytics(
  var bool enabled,
  @JsonKey(name: 'dsn') var String dsn,
  @JsonKey(name: 'samplingRate') var double? samplingRate,
) {
  @JsonKey(includeFromJson: false, includeToJson: false)
  static const String keyStudyUAnalytics = 'analytics_settings';

  factory fromJson(Map<String, dynamic> json) =>
      _$StudyUAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$StudyUAnalyticsToJson(this);
}

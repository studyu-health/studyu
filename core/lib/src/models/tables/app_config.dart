import 'dart:async';

import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase/supabase.dart';

part 'app_config.g.dart';

@JsonSerializable()
class AppConfig(
  var String id, {
  @JsonKey(name: 'app_min_version') required var String appMinVersion,
  @JsonKey(name: 'app_privacy') required var Map<String, String> appPrivacy,
  @JsonKey(name: 'app_terms') required var Map<String, String> appTerms,
  @JsonKey(name: 'designer_privacy')
  required var Map<String, String> designerPrivacy,
  @JsonKey(name: 'designer_terms')
  required var Map<String, String> designerTerms,
  required var Contact contact,
  required var Map<String, String> imprint,
  required var StudyUAnalytics? analytics,
}) extends SupabaseObjectFunctions<AppConfig> {
  static const String tableName = 'app_config';
  static const Duration requestTimeout = Duration(seconds: 5);

  @override
  Map<String, Object> get primaryKeys => {'id': id};

  factory fromJson(Map<String, dynamic> json) => _$AppConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AppConfigToJson(this);

  static Future<AppConfig> getAppConfig() async {
    try {
      return await SupabaseQuery.getById<AppConfig>('prod').timeout(
        requestTimeout,
        onTimeout: () => throw TimeoutException(
          'Connection timeout after ${requestTimeout.inSeconds} seconds',
        ),
      );
    } catch (error) {
      if (shouldRethrowAppConfigError(error)) {
        rethrow;
      }
      throw Exception(
        "Could not load app config. Check if the database is "
        "running and app_config table is properly set up.",
      );
    }
  }

  static Future<Contact> getAppContact() async {
    return (await getAppConfig()).contact;
  }
}

bool shouldRethrowAppConfigError(Object error) {
  if (error is TimeoutException || error is PostgrestException) {
    return true;
  }

  final message = error.toString().toLowerCase();
  return message.contains('clientexception') ||
      message.contains('failed to fetch') ||
      message.contains('socketexception') ||
      message.contains('xmlhttprequest error') ||
      message.contains('timed out');
}

import 'dart:io';

import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/env/env.dart' as env;
import 'package:supabase/supabase.dart';

abstract class SupabaseObject() {
  Map<String, Object> get primaryKeys;

  Map<String, dynamic> toJson();
}

String tableName(Type cls) {
  if (cls == Study) return Study.tableName;
  if (cls == StudySubject) return StudySubject.tableName;
  if (cls == SubjectProgress) return SubjectProgress.tableName;
  if (cls == AppConfig) return AppConfig.tableName;
  if (cls == Repo) return Repo.tableName;
  if (cls == StudyInvite) return StudyInvite.tableName;
  if (cls == StudyUUser) return StudyUUser.tableName;
  if (cls == StudyFitbitCredentials) return StudyFitbitCredentials.tableName;
  throw ArgumentError('$cls is not a supported Supabase type');
}

abstract class SupabaseObjectFunctions<T extends SupabaseObject>()
    implements SupabaseObject {
  static T fromJson<T extends SupabaseObject>(Map<String, dynamic> json) {
    if (T == Study) return Study.fromJson(json) as T;
    if (T == StudySubject) return StudySubject.fromJson(json) as T;
    if (T == SubjectProgress) return SubjectProgress.fromJson(json) as T;
    if (T == AppConfig) return AppConfig.fromJson(json) as T;
    if (T == Repo) return Repo.fromJson(json) as T;
    if (T == StudyInvite) return StudyInvite.fromJson(json) as T;
    if (T == StudyUUser) return StudyUUser.fromJson(json) as T;
    if (T == StudyFitbitCredentials) {
      return StudyFitbitCredentials.fromJson(json) as T;
    }
    throw ArgumentError('$T is not a supported Supabase type');
  }

  Future<T> delete() async => SupabaseQuery.extractSupabaseSingleRow<T>(
    await env.client
        .from(tableName(T))
        .delete()
        .primaryKeys(primaryKeys)
        .select()
        .single(),
  );

  /// Save the object to the database.
  /// By default, this will upsert the object, i.e. insert it if it does not exist, or update it if it does.
  /// If [onlyUpdate] is set to true, the object has to exist in the database, otherwise the result will be empty.
  Future<T> save({bool onlyUpdate = false}) async {
    final tableQuery = env.client.from(tableName(T));
    PostgrestFilterBuilder query;
    if (onlyUpdate) {
      query = tableQuery.upsert(this.toJson());
      for (final entry in primaryKeys.entries) {
        query = query.eq(entry.key, entry.value);
      }
    } else {
      query = tableQuery.upsert(this.toJson());
    }
    return SupabaseQuery.extractSupabaseList<T>(await query.select()).single;
  }
}

// ignore: avoid_classes_with_only_static_members
class SupabaseQuery() {
  static Future<List<T>> getAll<T extends SupabaseObject>({
    List<String> selectedColumns = const ['*'],
    Map<String, Object>? filters,
  }) async {
    try {
      var query = env.client
          .from(tableName(T))
          .select(selectedColumns.join(','));
      filters?.forEach((key, value) {
        query = query.eq(key, value);
      });
      return extractSupabaseList(await query);
    } catch (error, stacktrace) {
      catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  static Future<T> getById<T extends SupabaseObject>(
    String id, {
    List<String> selectedColumns = const ['*'],
  }) async {
    try {
      return extractSupabaseSingleRow(
        await env.client
            .from(tableName(T))
            .select(selectedColumns.join(','))
            .eq('id', id)
            .single(),
      );
    } catch (error, stacktrace) {
      catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  static Future<List<T>> batchUpsert<T extends SupabaseObject>(
    List<Map<String, dynamic>> batchJson,
  ) async {
    try {
      return SupabaseQuery.extractSupabaseList<T>(
        await env.client.from(tableName(T)).upsert(batchJson).select(),
      );
    } catch (error, stacktrace) {
      catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  /// Extracts a list of SupabaseObjects from a response.
  /// If some records could not be extracted, [ExtractionFailedException] is
  /// thrown containing the extracted records and the faulty records.
  static List<T> extractSupabaseList<T extends SupabaseObject>(
    List<Map<String, dynamic>> response, {
    bool throwForNonExtracted = false,
  }) {
    final extracted = <T>[];
    final notExtracted = <JsonWithError>[];
    for (final json in response) {
      try {
        extracted.add(SupabaseObjectFunctions.fromJson<T>(json));
        // ignore: avoid_catching_errors
      } on ArgumentError catch (error) {
        // We are catching ArgumentError because unknown enums throw an ArgumentError
        // and UnknownJsonTypeError is a subclass of ArgumentError
        notExtracted.add(JsonWithError(json, error));
      }
    }
    if (notExtracted.isNotEmpty) {
      StudyULogger.warning(
        'Some records could not be extracted: ${notExtracted.length} errors',
      );
      StudyULogger.debug(
        'Not extracted records: ${notExtracted.map((e) => e.json).join(', ')}',
      );
      StudyULogger.error(
        'Extraction failed for some records',
        error: ExtractionFailedException(extracted, notExtracted),
      );
      // Only throw if we are supposed to throw for non-extracted records.
      // Otherwise, we just log the error and return the extracted records.
      if (throwForNonExtracted) {
        // If some records could not be extracted, we throw an exception
        // with the extracted records and the faulty records
        throw ExtractionFailedException(extracted, notExtracted);
      }
    }
    return extracted;
  }

  static T extractSupabaseSingleRow<T extends SupabaseObject>(
    Map<String, dynamic> response,
  ) {
    return SupabaseObjectFunctions.fromJson<T>(response);
  }

  static void catchSupabaseException(Object error, StackTrace stacktrace) {
    StudyULogger.error(
      'Caught Supabase Error: $error',
      error: error,
      stackTrace: stacktrace,
    );
    if (error is PostgrestException) {
      StudyULogger.fatal(
        'Caught Postgrest Error: $error\nStacktrace: $stacktrace',
      );
      throw error;
    } else if (error is SocketException) {
      // StudyULogger.info("App is suspected to be offline");
      throw error;
    } else {
      StudyULogger.fatal('Caught Supabase Error: $error');
      throw error;
    }
  }
}

extension PrimaryKeyFilterBuilder on PostgrestFilterBuilder {
  PostgrestFilterBuilder primaryKeys(Map<String, Object> primaryKeys) {
    var primaryKeyFilter = this;
    primaryKeys.forEach((columnKey, value) {
      primaryKeyFilter = primaryKeyFilter.eq(columnKey, value);
    });
    return primaryKeyFilter;
  }
}

sealed class ExtractionResult<T>(final List<T> extracted);

class ExtractionSuccess<T>(super.extracted) extends ExtractionResult<T>;

class ExtractionFailedException<T>(
  super.extracted,
  final List<JsonWithError> notExtracted,
) extends ExtractionResult<T> implements Exception {
  @override
  String toString() =>
      'ExtractionFailedException: ${notExtracted.length} records failed to extract.\n'
      'Extracted: $extracted\n'
      'Not Extracted: ${notExtracted.map((e) => 'json: ${e.json}, error: ${e.error}').join('; ')}';
}

class JsonWithError(final Map<String, dynamic> json, final Object error);

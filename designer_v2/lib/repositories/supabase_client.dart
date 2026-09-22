import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client.g.dart';

// TODO: Transfer networking code to core package (+ update app if needed)

/// Interface for implementation by any class that wants to use [SupabaseQueryMixin]
abstract class SupabaseClientDependant() {
  SupabaseClient get supabaseClient;
}

/// An exception that is thrown when Supabase returns a [PostgrestResponse]
/// with an associated [PostgrestError]
class SupabaseQueryError({
  /// Status code of the erroneous [PostgrestResponse]
  required final String? statusCode,

  /// The [PostgrestError] message associated with the [PostgrestResponse]
  required final String message,

  /// The [PostgrestError] details associated with the [PostgrestResponse]
  final dynamic details,
}) implements Exception;

typedef PostgrestDataCallback = Object Function(dynamic data);

/// Mixes in networking & deserialization logic into a [SupabaseClientDependant]
mixin SupabaseQueryMixin on SupabaseClientDependant {
  // - Networking

  Future<List<T>> deleteAll<T extends SupabaseObject>(
    Map<String, Object> selectionCriteria,
  ) async {
    try {
      final data = await this.supabaseClient
          .from(tableName(T))
          .delete()
          .match(selectionCriteria);
      if (data == null) return [];
      return deserializeList<T>(data);
    } on PostgrestException catch (error) {
      throw SupabaseQueryError(
        statusCode: error.code,
        message: error.message,
        details: error.details,
      );
    }
  }

  Future<List<T>> getAll<T extends SupabaseObject>({
    List<String> selectedColumns = const ['*'],
  }) async {
    try {
      final data = await this.supabaseClient
          .from(tableName(T))
          .select(selectedColumns.join(','));
      return deserializeList<T>(data);
    } on PostgrestException catch (error) {
      throw SupabaseQueryError(
        statusCode: error.code,
        message: error.message,
        details: error.details,
      );
    }
  }

  Future<T> getById<T extends SupabaseObject>(
    String id, {
    List<String> selectedColumns = const ['*'],
  }) {
    return getByColumn('id', id, selectedColumns: selectedColumns);
  }

  Future<T> getByColumn<T extends SupabaseObject>(
    String colName,
    String value, {
    List<String> selectedColumns = const ['*'],
  }) async {
    try {
      final data = await this.supabaseClient
          .from(tableName(T))
          .select(selectedColumns.join(','))
          .eq(colName, value)
          .single();
      return deserializeObject<T>(data);
    } on PostgrestException catch (error) {
      throw SupabaseQueryError(
        statusCode: error.code,
        message: error.message,
        details: error.details,
      );
    }
  }

  Future executeRpc(String functionName, {Map<String, dynamic>? params}) async {
    try {
      return await this.supabaseClient.rpc(functionName, params: params);
    } on PostgrestException catch (error) {
      throw SupabaseQueryError(
        statusCode: error.code,
        message: error.message,
        details: error.details,
      );
    }
  }

  // - Deserialization

  List<T> deserializeList<T extends SupabaseObject>(dynamic data) {
    return List<T>.from(
      List<Map<String, dynamic>>.from(data as List)
          .map((json) => SupabaseObjectFunctions.fromJson<T>(json)),
    );
  }

  T deserializeObject<T extends SupabaseObject>(dynamic data) {
    return SupabaseObjectFunctions.fromJson<T>(data as Map<String, dynamic>);
  }
}

// Re-expose the global client object via Riverpod
@riverpod
SupabaseClient supabaseClient(Ref ref) => env.client;

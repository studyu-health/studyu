import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef NutritionPhotoScope = ({String userId, String subjectId});

enum NutritionPhotoKind() {
  item,
  meal,
}

class const NutritionPhotoKey(
  final NutritionPhotoScope scope,
  final NutritionPhotoKind kind,
  final String recordId,
) {
  String get path =>
      '${scope.userId}/${scope.subjectId}/${kind.name}/$recordId.jpg';
}

class NutritionPhotoChange {
  const new replace(Uint8List this.bytes);
  const new remove() : bytes = null;

  final Uint8List? bytes;
}

class NutritionPhotoStorage._(final SupabaseClient _client) {
  this {
    _client.auth.onAuthStateChange.listen(
      (event) {
        final userId = event.session?.user.id;
        if (userId == _userId) return;
        _userId = userId;
        _staged.clear();
        _notify(null);
      },
      onError: (Object _, StackTrace _) {
        // An auth refresh can fail while the participant is offline.
      },
    );
  }

  static const maxBytes = 6000000;
  static NutritionPhotoStorage? _instance;

  static NutritionPhotoStorage? get current {
    try {
      return forClient(Supabase.instance.client);
      // Widget tests can run before the app initializes Supabase.
      // ignore: avoid_catching_errors
    } on AssertionError {
      return null;
    }
  }

  static NutritionPhotoStorage forClient(SupabaseClient client) =>
      _instance ??= ._(client);

  final changedPath = ValueNotifier<({String? path, int revision})?>(null);
  Future<void> _previousCleanup = Future.value();
  late String? _userId = _client.auth.currentUser?.id;
  int _revision = 0;
  final _staged = <String, NutritionPhotoChange>{};

  StorageFileApi get _bucket => _client.storage.from('nutrition-photos');

  bool owns(NutritionPhotoScope scope) =>
      _client.auth.currentUser?.id == scope.userId;

  void _requireOwner(NutritionPhotoScope scope) {
    if (!owns(scope)) throw StateError('The photo account changed.');
  }

  Future<Uint8List?> download(NutritionPhotoKey key) async {
    if (!owns(key.scope)) return null;
    try {
      final bytes = await _bucket.download(key.path);
      return owns(key.scope) ? bytes : null;
    } on StorageException catch (error) {
      if (error.statusCode == '404') return null;
      rethrow;
    }
  }

  NutritionPhotoChange? pendingChange(NutritionPhotoKey key) =>
      owns(key.scope) ? _staged[key.path] : null;

  void stage(NutritionPhotoKey key, NutritionPhotoChange change) {
    if (owns(key.scope)) _staged[key.path] = change;
  }

  bool canRetry(NutritionPhotoKey key, NutritionPhotoChange change) =>
      owns(key.scope) && identical(_staged[key.path], change);

  Future<void> apply(NutritionPhotoKey key, NutritionPhotoChange change) =>
      _serializeCleanup(() async {
        if (!canRetry(key, change)) return;
        if (change.bytes case final bytes?) {
          final pending = await _pending(key.scope);
          if (pending.remove(key.path)) await _writePending(key.scope, pending);
          if (!canRetry(key, change)) return;
          await _bucket.uploadBinary(
            key.path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              cacheControl: '0',
              upsert: true,
            ),
          );
        } else {
          await _bucket.remove([key.path]);
        }
        if (canRetry(key, change)) _staged.remove(key.path);
        _notify(key.path);
      });

  // Queue only deletions of records. A replacement or a removal from an
  // existing record is retried explicitly so an old retry cannot delete it.
  Future<void> deleteWithRetry(NutritionPhotoKey key) {
    _staged.remove(key.path);
    return _serializeCleanup(() async {
      _requireOwner(key.scope);
      final paths = await _pending(key.scope);
      paths.add(key.path);
      await _writePending(key.scope, paths);
      await _drain(key.scope, paths);
    });
  }

  Future<void> retryDeletes(NutritionPhotoScope scope) =>
      _serializeCleanup(() async {
        _requireOwner(scope);
        await _drain(scope, await _pending(scope));
      });

  Future<void> deleteSubject(
    NutritionPhotoScope scope,
  ) => _serializeCleanup(() async {
    _staged.removeWhere(
      (path, _) => path.startsWith('${scope.userId}/${scope.subjectId}/'),
    );
    for (final kind in NutritionPhotoKind.values) {
      final prefix = '${scope.userId}/${scope.subjectId}/${kind.name}';
      while (true) {
        _requireOwner(scope);
        final files = await _bucket.list(path: prefix);
        if (files.isEmpty) break;
        _requireOwner(scope);
        final removed = await _bucket.remove([
          for (final file in files) '$prefix/${file.name}',
        ]);
        if (removed.isEmpty) {
          // The list may have changed since it was read. Leave cleanup pending.
          throw StateError('Could not finish deleting nutrition photos.');
        }
      }
    }
    await _writePending(scope, {});
    _notify(null);
  });

  Future<void> _serializeCleanup(Future<void> Function() action) {
    final run = _previousCleanup.then((_) => action());
    _previousCleanup = run.then<void>((_) {}, onError: (Object _) {});
    return run;
  }

  String _pendingKey(NutritionPhotoScope scope) =>
      'nutrition_photo_deletes_${scope.userId}_${scope.subjectId}';

  Future<Set<String>> _pending(NutritionPhotoScope scope) async {
    final json = await SecureStorage.read(_pendingKey(scope));
    return json == null
        ? {}
        : (jsonDecode(json) as List).cast<String>().toSet();
  }

  Future<void> _writePending(NutritionPhotoScope scope, Set<String> paths) =>
      paths.isEmpty
      ? SecureStorage.delete(_pendingKey(scope))
      : SecureStorage.write(_pendingKey(scope), jsonEncode(paths.toList()));

  Future<void> _drain(NutritionPhotoScope scope, Set<String> paths) async {
    if (paths.isEmpty) return;
    try {
      for (final path in paths.toList()) {
        _requireOwner(scope);
        await _bucket.remove([path]);
        paths.remove(path);
        _notify(path);
      }
    } catch (_, stackTrace) {
      StudyULogger.warning(
        'Nutrition photo cleanup is pending.',
        stackTrace: stackTrace,
      );
    } finally {
      await _writePending(scope, paths);
    }
  }

  void _notify(String? path) {
    changedPath.value = (path: path, revision: ++_revision);
  }
}

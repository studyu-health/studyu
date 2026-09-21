import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String formatCompletionPeriod(
  BuildContext context,
  CompletionPeriod period, {
  TimeFormatPreference? preference,
}) {
  String format(StudyUTimeOfDay time) => DateTimeFormat.formatTime(
    context,
    TimeOfDay(hour: time.hour, minute: time.minute),
    preference: preference,
  );

  return '${format(period.unlockTime)} - ${format(period.lockTime)}';
}

@visibleForTesting
T? synchronizedPreference<T>({
  required T? serverValue,
  required T? localValue,
  required bool localValueIsDirty,
}) => localValueIsDirty ? localValue : serverValue;

class DateTimePreferences() extends ChangeNotifier {
  static const _dateFormatKeyPrefix = 'date_format_';
  static const _timeFormatKeyPrefix = 'time_format_';
  static const _dateFormatDirtyKeyPrefix = 'date_format_dirty_';
  static const _timeFormatDirtyKeyPrefix = 'time_format_dirty_';

  DateFormatPreference? _dateFormat;
  TimeFormatPreference? _timeFormat;
  StudyUUser? _user;
  String? _userId;
  StreamSubscription<AuthState>? _authSubscription;
  int _loadGeneration = 0;
  int _dateFormatOperation = 0;
  int _timeFormatOperation = 0;
  Future<void> _preferencePersistence = Future.value();

  this {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (authState) => _loadUser(authState.session?.user.id),
    );
    _loadUser(Supabase.instance.client.auth.currentUser?.id);
  }

  DateFormatPreference? get dateFormat => _dateFormat;
  TimeFormatPreference? get timeFormat => _timeFormat;

  Future<void> _loadUser(String? userId) async {
    final generation = ++_loadGeneration;
    _userId = userId;
    _user = null;
    _dateFormat = null;
    _timeFormat = null;
    notifyListeners();

    DateFormatPreference? localDateFormat;
    TimeFormatPreference? localTimeFormat;
    var localDateFormatIsDirty = false;
    var localTimeFormatIsDirty = false;
    if (userId != null) {
      try {
        localDateFormat = _parseDateFormat(
          await SecureStorage.read('$_dateFormatKeyPrefix$userId'),
        );
        localTimeFormat = _parseTimeFormat(
          await SecureStorage.read('$_timeFormatKeyPrefix$userId'),
        );
        localDateFormatIsDirty =
            await SecureStorage.readBool('$_dateFormatDirtyKeyPrefix$userId') ??
            false;
        localTimeFormatIsDirty =
            await SecureStorage.readBool('$_timeFormatDirtyKeyPrefix$userId') ??
            false;
      } catch (error) {
        debugPrint('Could not read local date and time preferences: $error');
      }
    }

    if (generation != _loadGeneration) return;

    if (userId == null) {
      _user = null;
      _dateFormat = localDateFormat;
      _timeFormat = localTimeFormat;
      notifyListeners();
      return;
    }

    final dateOperation = _dateFormatOperation;
    final timeOperation = _timeFormatOperation;
    try {
      final user = await SupabaseQuery.getById<StudyUUser>(userId);
      if (generation != _loadGeneration) return;

      final dateOperationIsCurrent = dateOperation == _dateFormatOperation;
      final timeOperationIsCurrent = timeOperation == _timeFormatOperation;
      final dateFormat = dateOperationIsCurrent
          ? synchronizedPreference(
              serverValue: user.preferences.dateFormat,
              localValue: localDateFormat,
              localValueIsDirty: localDateFormatIsDirty,
            )
          : _dateFormat;
      final timeFormat = timeOperationIsCurrent
          ? synchronizedPreference(
              serverValue: user.preferences.timeFormat,
              localValue: localTimeFormat,
              localValueIsDirty: localTimeFormatIsDirty,
            )
          : _timeFormat;

      _user = user;
      if (dateOperationIsCurrent) {
        _dateFormat = dateFormat;
        if (localDateFormatIsDirty) user.preferences.dateFormat = dateFormat;
      } else {
        user.preferences.dateFormat = _dateFormat;
      }
      if (timeOperationIsCurrent) {
        _timeFormat = timeFormat;
        if (localTimeFormatIsDirty) user.preferences.timeFormat = timeFormat;
      } else {
        user.preferences.timeFormat = _timeFormat;
      }

      await _queuePreferencePersistence(() async {
        if (!_isCurrent(generation, userId)) return;

        final synchronizeDate =
            dateOperation == _dateFormatOperation && localDateFormatIsDirty;
        final synchronizeTime =
            timeOperation == _timeFormatOperation && localTimeFormatIsDirty;
        if (synchronizeDate || synchronizeTime) {
          try {
            final synchronizedUser = await user.save(onlyUpdate: true);
            if (!_isCurrent(generation, userId)) return;
            if (dateOperation == _dateFormatOperation &&
                timeOperation == _timeFormatOperation) {
              _user = synchronizedUser;
            }
            if (synchronizeDate &&
                dateOperation == _dateFormatOperation &&
                await _cachePreference(
                  _dateFormatKeyPrefix,
                  userId,
                  dateFormat,
                )) {
              await _clearDirtyPreference(_dateFormatDirtyKeyPrefix, userId);
            }
            if (synchronizeTime &&
                timeOperation == _timeFormatOperation &&
                await _cachePreference(
                  _timeFormatKeyPrefix,
                  userId,
                  timeFormat,
                )) {
              await _clearDirtyPreference(_timeFormatDirtyKeyPrefix, userId);
            }
          } catch (error) {
            debugPrint(
              'Could not synchronize local date and time preferences: $error',
            );
          }
        } else {
          if (dateOperation == _dateFormatOperation) {
            await _cachePreference(_dateFormatKeyPrefix, userId, dateFormat);
          }
          if (timeOperation == _timeFormatOperation) {
            await _cachePreference(_timeFormatKeyPrefix, userId, timeFormat);
          }
        }
      });
    } catch (error) {
      debugPrint('Could not load date and time preferences: $error');
      if (generation != _loadGeneration) return;
      _user = null;
      if (dateOperation == _dateFormatOperation) {
        _dateFormat = localDateFormat;
      }
      if (timeOperation == _timeFormatOperation) {
        _timeFormat = localTimeFormat;
      }
    }

    if (generation == _loadGeneration) notifyListeners();
  }

  Future<void> changeDateFormat(DateFormatPreference? value) async {
    final generation = _loadGeneration;
    final operation = ++_dateFormatOperation;
    final userId = _userId;
    final user = _user;
    final previousValue = _dateFormat;
    final previousUserValue = user?.preferences.dateFormat;
    _dateFormat = value;
    if (user != null) user.preferences.dateFormat = value;
    try {
      await _persist(
        _dateFormatKeyPrefix,
        value?.name,
        generation: generation,
        dateOperation: operation,
        timeOperation: _timeFormatOperation,
        userId: userId,
        user: user,
        previousUserValue: previousUserValue,
      );
    } catch (error) {
      if (_isCurrent(generation, userId) && operation == _dateFormatOperation) {
        _dateFormat = previousValue;
        if (user != null && _user == user) {
          _user!.preferences.dateFormat = previousUserValue;
        }
        notifyListeners();
      }
      rethrow;
    }
    if (_isCurrent(generation, userId) && operation == _dateFormatOperation) {
      notifyListeners();
    }
  }

  Future<void> changeTimeFormat(TimeFormatPreference? value) async {
    final generation = _loadGeneration;
    final operation = ++_timeFormatOperation;
    final userId = _userId;
    final user = _user;
    final previousValue = _timeFormat;
    final previousUserValue = user?.preferences.timeFormat;
    _timeFormat = value;
    if (user != null) user.preferences.timeFormat = value;
    try {
      await _persist(
        _timeFormatKeyPrefix,
        value?.name,
        generation: generation,
        dateOperation: _dateFormatOperation,
        timeOperation: operation,
        userId: userId,
        user: user,
        previousUserValue: previousUserValue,
      );
    } catch (error) {
      if (_isCurrent(generation, userId) && operation == _timeFormatOperation) {
        _timeFormat = previousValue;
        if (user != null && _user == user) {
          _user!.preferences.timeFormat = previousUserValue;
        }
        notifyListeners();
      }
      rethrow;
    }
    if (_isCurrent(generation, userId) && operation == _timeFormatOperation) {
      notifyListeners();
    }
  }

  String formatDate(BuildContext context, DateTime date) {
    return DateTimeFormat.formatDate(context, date, preference: _dateFormat);
  }

  String formatTime(BuildContext context, TimeOfDay time) {
    return DateTimeFormat.formatTime(context, time, preference: _timeFormat);
  }

  String formatDateTime(BuildContext context, DateTime dateTime) {
    return DateTimeFormat.formatDateTime(
      context,
      dateTime,
      datePreference: _dateFormat,
      timePreference: _timeFormat,
    );
  }

  Future<void> _persist(
    String keyPrefix,
    String? value, {
    required int generation,
    required int dateOperation,
    required int timeOperation,
    required String? userId,
    required StudyUUser? user,
    required Object? previousUserValue,
  }) {
    return _queuePreferencePersistence(() async {
      final dirtyKeyPrefix = keyPrefix == _dateFormatKeyPrefix
          ? _dateFormatDirtyKeyPrefix
          : _timeFormatDirtyKeyPrefix;
      if (userId == null) return;

      final cacheKey = '$keyPrefix$userId';
      final dirtyKey = '$dirtyKeyPrefix$userId';
      final previousCachedValue = await SecureStorage.read(cacheKey);
      final previousDirtyValue = await SecureStorage.readBool(dirtyKey);

      if (user == null) {
        await _cacheDirtyPreference(
          cacheKey,
          dirtyKey,
          value,
          previousCachedValue,
          previousDirtyValue,
        );
        return;
      }

      StudyUUser savedUser;
      try {
        savedUser = await user.save(onlyUpdate: true);
      } on SocketException {
        await _cacheDirtyPreference(
          cacheKey,
          dirtyKey,
          value,
          previousCachedValue,
          previousDirtyValue,
        );
        return;
      } catch (_) {
        if (_isCurrent(generation, userId) && user == _user) {
          if (keyPrefix == _dateFormatKeyPrefix &&
              dateOperation == _dateFormatOperation) {
            user.preferences.dateFormat =
                previousUserValue as DateFormatPreference?;
          } else if (keyPrefix == _timeFormatKeyPrefix &&
              timeOperation == _timeFormatOperation) {
            user.preferences.timeFormat =
                previousUserValue as TimeFormatPreference?;
          }
        }
        rethrow;
      }
      await _cachePreference(keyPrefix, userId, value);
      await _clearDirtyPreference(dirtyKeyPrefix, userId);
      if (_isCurrent(generation, userId) &&
          dateOperation == _dateFormatOperation &&
          timeOperation == _timeFormatOperation) {
        _user = savedUser;
      }
    });
  }

  Future<T> _queuePreferencePersistence<T>(Future<T> Function() operation) {
    final result = _preferencePersistence.then((_) => operation());
    _preferencePersistence = result.then<void>((_) {}, onError: (_, _) {});
    return result;
  }

  bool _isCurrent(int generation, String? userId) {
    return generation == _loadGeneration && userId == _userId;
  }

  Future<void> _cacheDirtyPreference(
    String cacheKey,
    String dirtyKey,
    Object? value,
    String? previousCachedValue,
    bool? previousDirtyValue,
  ) async {
    try {
      await _writeCachedPreference(cacheKey, value);
      await SecureStorage.write(dirtyKey, 'true');
    } catch (error) {
      await _restorePreference(
        cacheKey,
        dirtyKey,
        previousCachedValue,
        previousDirtyValue,
      );
      rethrow;
    }
  }

  Future<void> _writeCachedPreference(String key, Object? value) async {
    if (value == null) {
      await SecureStorage.delete(key);
    } else {
      await SecureStorage.write(key, value.toString());
    }
  }

  Future<void> _restorePreference(
    String cacheKey,
    String dirtyKey,
    String? cachedValue,
    bool? dirtyValue,
  ) async {
    try {
      await _writeCachedPreference(cacheKey, cachedValue);
      if (dirtyValue == null) {
        await SecureStorage.delete(dirtyKey);
      } else {
        await SecureStorage.write(dirtyKey, dirtyValue.toString());
      }
    } catch (restoreError) {
      debugPrint('Could not restore date and time preferences: $restoreError');
    }
  }

  Future<bool> _cachePreference(
    String keyPrefix,
    String userId,
    Object? value,
  ) async {
    try {
      final key = '$keyPrefix$userId';
      if (value == null) {
        await SecureStorage.delete(key);
      } else {
        await SecureStorage.write(
          key,
          value is Enum ? value.name : value.toString(),
        );
      }
      return true;
    } catch (error) {
      debugPrint('Could not cache date and time preference: $error');
      return false;
    }
  }

  Future<void> _clearDirtyPreference(String keyPrefix, String userId) async {
    try {
      await SecureStorage.delete('$keyPrefix$userId');
    } catch (error) {
      debugPrint(
        'Could not clear synchronized date and time preference: $error',
      );
    }
  }

  DateFormatPreference? _parseDateFormat(String? value) {
    if (value == null) return null;
    return DateFormatPreference.values
        .where((item) => item.name == value)
        .firstOrNull;
  }

  TimeFormatPreference? _parseTimeFormat(String? value) {
    if (value == null) return null;
    return TimeFormatPreference.values
        .where((item) => item.name == value)
        .firstOrNull;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

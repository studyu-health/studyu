import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/util/date_time_preferences.dart';
import 'package:studyu_core/core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  late Map<String, String> storage;

  setUp(() {
    storage = {};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async {
          final arguments = call.arguments as Map;
          final key = arguments['key'] as String?;
          return switch (call.method) {
            'read' => storage[key],
            'write' => storage[key!] = arguments['value'] as String,
            'delete' => storage.remove(key),
            'deleteAll' => storage.clear(),
            'containsKey' => storage.containsKey(key),
            _ => null,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  test('server System selection ignores a non-dirty cached preference', () {
    expect(
      synchronizedPreference<DateFormatPreference>(
        serverValue: null,
        localValue: DateFormatPreference.german,
        localValueIsDirty: false,
      ),
      isNull,
    );
  });

  test('a dirty offline preference wins during synchronization', () {
    expect(
      synchronizedPreference<DateFormatPreference>(
        serverValue: DateFormatPreference.us,
        localValue: DateFormatPreference.german,
        localValueIsDirty: true,
      ),
      DateFormatPreference.german,
    );
  });

  test('a dirty offline System selection remains System', () {
    expect(
      synchronizedPreference<DateFormatPreference>(
        serverValue: DateFormatPreference.us,
        localValue: null,
        localValueIsDirty: true,
      ),
      isNull,
    );
  });

  testWidgets('loads, changes, caches, and formats preferences', (
    tester,
  ) async {
    final user = _user(
      dateFormat: DateFormatPreference.us,
      timeFormat: TimeFormatPreference.h12,
    );
    final savedUsers = <StudyUUser>[];
    final preferences = _preferences(
      loadUser: (_) async => user,
      saveUser: (user) async {
        savedUsers.add(user);
        return user;
      },
    );
    addTearDown(preferences.dispose);

    await preferences.initialLoad;

    expect(preferences.dateFormat, DateFormatPreference.us);
    expect(preferences.timeFormat, TimeFormatPreference.h12);
    expect(storage['date_format_user-id'], 'us');
    expect(storage['time_format_user-id'], 'h12');

    var notifications = 0;
    preferences.addListener(() => notifications++);
    await preferences.changeDateFormat(null);
    await preferences.changeTimeFormat(TimeFormatPreference.h24);

    expect(preferences.dateFormat, isNull);
    expect(preferences.timeFormat, TimeFormatPreference.h24);
    expect(storage.containsKey('date_format_user-id'), isFalse);
    expect(storage['time_format_user-id'], 'h24');
    expect(savedUsers, hasLength(2));
    expect(notifications, 2);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        home: Builder(
          builder: (context) {
            expect(
              preferences.formatDate(context, DateTime(2024, 12, 31)),
              '12/31/2024',
            );
            expect(
              preferences.formatTime(
                context,
                const TimeOfDay(hour: 14, minute: 30),
              ),
              '14:30',
            );
            expect(
              preferences.formatDateTime(
                context,
                DateTime(2024, 12, 31, 14, 30),
              ),
              '12/31/2024 14:30',
            );
            expect(
              formatCompletionPeriod(
                context,
                CompletionPeriod.noId(
                  unlockTime: StudyUTimeOfDay(hour: 8),
                  lockTime: StudyUTimeOfDay(hour: 20),
                ),
                preference: TimeFormatPreference.h24,
              ),
              '08:00 - 20:00',
            );
            return const SizedBox();
          },
        ),
      ),
    );
  });

  test('synchronizes dirty cached preferences', () async {
    storage.addAll({
      'date_format_user-id': 'german',
      'time_format_user-id': 'h24',
      'date_format_dirty_user-id': 'true',
      'time_format_dirty_user-id': 'true',
    });
    final savedUsers = <StudyUUser>[];
    final preferences = _preferences(
      loadUser: (_) async => _user(
        dateFormat: DateFormatPreference.us,
        timeFormat: TimeFormatPreference.h12,
      ),
      saveUser: (user) async {
        savedUsers.add(user);
        return user;
      },
    );
    addTearDown(preferences.dispose);

    await preferences.initialLoad;

    expect(preferences.dateFormat, DateFormatPreference.german);
    expect(preferences.timeFormat, TimeFormatPreference.h24);
    expect(
      savedUsers.single.preferences.dateFormat,
      DateFormatPreference.german,
    );
    expect(savedUsers.single.preferences.timeFormat, TimeFormatPreference.h24);
    expect(storage.containsKey('date_format_dirty_user-id'), isFalse);
    expect(storage.containsKey('time_format_dirty_user-id'), isFalse);
  });

  test('uses cached preferences when loading the user fails', () async {
    storage.addAll({
      'date_format_user-id': 'iso',
      'time_format_user-id': 'invalid',
    });
    final preferences = _preferences(
      loadUser: (_) async => throw StateError('load failed'),
    );
    addTearDown(preferences.dispose);

    await preferences.initialLoad;

    expect(preferences.dateFormat, DateFormatPreference.iso);
    expect(preferences.timeFormat, isNull);
  });

  test('switches to signed-out preferences after an auth change', () async {
    final userIds = StreamController<String?>();
    final preferences = _preferences(
      userIds: userIds.stream,
      loadUser: (_) async => _user(dateFormat: DateFormatPreference.us),
    );
    addTearDown(() async {
      preferences.dispose();
      await userIds.close();
    });
    await preferences.initialLoad;

    final notified = Completer<void>();
    preferences.addListener(() {
      if (!notified.isCompleted && preferences.dateFormat == null) {
        notified.complete();
      }
    });
    userIds.add(null);
    await notified.future;

    expect(preferences.dateFormat, isNull);
    expect(preferences.timeFormat, isNull);
  });

  test('caches changes as dirty when the user is offline', () async {
    final preferences = _preferences(
      loadUser: (_) async => _user(),
      saveUser: (_) async => throw const SocketException('offline'),
    );
    addTearDown(preferences.dispose);
    await preferences.initialLoad;

    await preferences.changeDateFormat(DateFormatPreference.european);

    expect(preferences.dateFormat, DateFormatPreference.european);
    expect(storage['date_format_user-id'], 'european');
    expect(storage['date_format_dirty_user-id'], 'true');
  });

  test('restores the previous value when saving fails', () async {
    final user = _user(dateFormat: DateFormatPreference.us);
    final preferences = _preferences(
      loadUser: (_) async => user,
      saveUser: (_) async => throw StateError('save failed'),
    );
    addTearDown(preferences.dispose);
    await preferences.initialLoad;

    await expectLater(
      preferences.changeDateFormat(DateFormatPreference.german),
      throwsStateError,
    );

    expect(preferences.dateFormat, DateFormatPreference.us);
    expect(user.preferences.dateFormat, DateFormatPreference.us);
  });

  test('restores the previous time format when saving fails', () async {
    final user = _user(timeFormat: TimeFormatPreference.h12);
    final preferences = _preferences(
      loadUser: (_) async => user,
      saveUser: (_) async => throw StateError('save failed'),
    );
    addTearDown(preferences.dispose);
    await preferences.initialLoad;

    await expectLater(
      preferences.changeTimeFormat(TimeFormatPreference.h24),
      throwsStateError,
    );

    expect(preferences.timeFormat, TimeFormatPreference.h12);
    expect(user.preferences.timeFormat, TimeFormatPreference.h12);
  });

  test('caches a change when the user cannot be loaded', () async {
    final preferences = _preferences(
      loadUser: (_) async => throw StateError('load failed'),
    );
    addTearDown(preferences.dispose);
    await preferences.initialLoad;

    await preferences.changeTimeFormat(TimeFormatPreference.h24);

    expect(storage['time_format_user-id'], 'h24');
    expect(storage['time_format_dirty_user-id'], 'true');
  });

  test('does not notify after disposal', () async {
    final load = Completer<StudyUUser>();
    final preferences = _preferences(loadUser: (_) => load.future);

    preferences.dispose();
    load.complete(_user());

    await expectLater(preferences.initialLoad, completes);
  });
}

DateTimePreferences _preferences({
  Stream<String?>? userIds,
  required Future<StudyUUser> Function(String) loadUser,
  Future<StudyUUser> Function(StudyUUser)? saveUser,
}) {
  return DateTimePreferences(
    userIds: () => userIds ?? const Stream.empty(),
    currentUserId: () => 'user-id',
    loadUser: loadUser,
    saveUser: saveUser ?? (user) async => user,
  );
}

StudyUUser _user({
  DateFormatPreference? dateFormat,
  TimeFormatPreference? timeFormat,
}) {
  return StudyUUser(
    id: 'user-id',
    email: 'user@example.com',
    preferences: Preferences(dateFormat: dateFormat, timeFormat: timeFormat),
  );
}

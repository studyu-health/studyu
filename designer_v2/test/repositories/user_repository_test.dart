import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final initialUser = StudyUUser(id: 'user-id', email: 'user@example.com');

  ProviderContainer createContainer(_FakeApi api) {
    return ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWith(
          (ref) => UserRepository(
            authRepository: _FakeAuthRepository(),
            apiClient: api,
            ref: ref,
          ),
        ),
      ],
    );
  }

  test('consecutive date and time updates use the loaded user', () async {
    final api = _FakeApi(initialUser);
    final container = createContainer(api);
    addTearDown(container.dispose);

    final repository = container.read(userRepositoryProvider);
    await repository.fetchUser();

    final savedDate = await repository.updateDateFormat(
      DateFormatPreference.iso,
    );
    final savedTime = await repository.updateTimeFormat(
      TimeFormatPreference.h12,
    );

    expect(savedDate.preferences.dateFormat, DateFormatPreference.iso);
    expect(savedTime.preferences.timeFormat, TimeFormatPreference.h12);
    expect(repository.cachedUser, same(savedTime));
    expect(api.savedUsers, hasLength(2));
  });

  test('overlapping date and time updates preserve both values', () async {
    final api = _FakeApi(initialUser)..firstSaveBlocker = Completer<void>();
    final container = createContainer(api);
    addTearDown(container.dispose);

    final repository = container.read(userRepositoryProvider);
    await repository.fetchUser();

    final dateUpdate = repository.updateDateFormat(DateFormatPreference.iso);
    final timeUpdate = repository.updateTimeFormat(TimeFormatPreference.h12);
    await Future<void>.delayed(Duration.zero);

    expect(api.saveCalls, 1);
    api.firstSaveBlocker!.complete();
    await Future.wait([dateUpdate, timeUpdate]);

    expect(
      repository.cachedUser?.preferences.dateFormat,
      DateFormatPreference.iso,
    );
    expect(
      repository.cachedUser?.preferences.timeFormat,
      TimeFormatPreference.h12,
    );
    expect(api.savedUsers, hasLength(2));
  });

  test('overlapping date and language updates preserve both values', () async {
    final api = _FakeApi(initialUser)..firstSaveBlocker = Completer<void>();
    final container = createContainer(api);
    addTearDown(container.dispose);

    final repository = container.read(userRepositoryProvider);
    await repository.fetchUser();

    final dateUpdate = repository.updateDateFormat(DateFormatPreference.iso);
    final languageUpdate = repository.updateLanguage('de-DE');
    await Future<void>.delayed(Duration.zero);

    expect(api.saveCalls, 1);
    api.firstSaveBlocker!.complete();
    await Future.wait([dateUpdate, languageUpdate]);

    expect(
      repository.cachedUser?.preferences.dateFormat,
      DateFormatPreference.iso,
    );
    expect(repository.cachedUser?.preferences.language, 'de-DE');
    expect(api.savedUsers, hasLength(2));
  });

  test('user state publishes the saved preferences to consumers', () async {
    final api = _FakeApi(initialUser);
    final container = createContainer(api);
    addTearDown(container.dispose);

    await container.read(userStateProvider.future);
    final savedUser = await container
        .read(userRepositoryProvider)
        .updateDateFormat(DateFormatPreference.german);
    container.read(userStateProvider.notifier).setUser(savedUser);

    expect(
      container.read(userStateProvider).value?.preferences.dateFormat,
      DateFormatPreference.german,
    );
  });

  test('failed preference save does not mutate the cached user', () async {
    final api = _FakeApi(initialUser)..throwOnSave = true;
    final container = createContainer(api);
    addTearDown(container.dispose);

    final repository = container.read(userRepositoryProvider);
    await repository.fetchUser();

    await expectLater(
      repository.updateDateFormat(DateFormatPreference.german),
      throwsStateError,
    );

    expect(repository.cachedUser?.preferences.dateFormat, isNull);
  });

  test('fetches once, saves, and updates pinned studies', () async {
    final fetchBlocker = Completer<void>();
    final api = _FakeApi(initialUser)..fetchBlocker = fetchBlocker;
    final container = createContainer(api);
    addTearDown(container.dispose);
    final repository = container.read(userRepositoryProvider);

    final firstFetch = repository.fetchUser();
    final secondFetch = repository.fetchUser();
    fetchBlocker.complete();

    expect(await firstFetch, same(await secondFetch));
    expect(api.fetchCalls, 1);
    expect(await repository.fetchUser(), same(repository.user));

    await repository.updatePreferences(PreferenceAction.pin, 'study-id');
    expect(repository.user.preferences.pinnedStudies, {'study-id'});
    await repository.updatePreferences(PreferenceAction.pinOff, 'study-id');
    expect(repository.user.preferences.pinnedStudies, isEmpty);
    expect(await repository.saveUser(), same(repository.user));
  });

  test('saves, replaces, lists, and deletes custom presets', () async {
    final api = _FakeApi(initialUser);
    final container = createContainer(api);
    addTearDown(container.dispose);
    final repository = container.read(userRepositoryProvider);
    await repository.fetchUser();

    final preset = SavedFilter(
      id: 'preset-id',
      name: 'First',
      root: FilterGroup(id: 'root'),
    );
    await repository.saveCustomPreset(preset);
    expect(repository.getCustomPresets().single.name, 'First');

    final replacement = SavedFilter(
      id: 'preset-id',
      name: 'Replacement',
      root: FilterGroup(id: 'root'),
    );
    await repository.saveCustomPreset(replacement);
    expect(repository.getCustomPresets().single.name, 'Replacement');

    await repository.deleteCustomPreset('preset-id');
    expect(repository.getCustomPresets(), isEmpty);
  });

  test('saves and reads active filters and sorting', () async {
    final api = _FakeApi(initialUser);
    final container = createContainer(api);
    addTearDown(container.dispose);
    final repository = container.read(userRepositoryProvider);
    await repository.fetchUser();

    expect(repository.getActiveFilter('studies'), (
      presetId: null,
      filterGroup: null,
    ));
    expect(repository.getActiveSort('studies'), (
      sortColumn: null,
      sortAscending: null,
    ));

    final filter = FilterGroup(
      id: 'group-id',
      children: [
        FilterCondition(
          id: 'condition-id',
          property: StudyProperty.status,
          operator: FilterOperator.equals,
          value: 'running',
        ),
      ],
    );
    await repository.saveActiveFilter(
      page: 'studies',
      presetId: 'preset-id',
      filterGroup: filter,
    );
    await repository.saveActiveSort(
      page: 'studies',
      sortColumn: 'createdAt',
      sortAscending: false,
    );

    final activeFilter = repository.getActiveFilter('studies');
    expect(activeFilter.presetId, 'preset-id');
    expect(activeFilter.filterGroup, filter);
    expect(repository.getActiveFilter('other'), (
      presetId: null,
      filterGroup: null,
    ));
    expect(repository.getActiveSort('studies'), (
      sortColumn: 'createdAt',
      sortAscending: false,
    ));
    expect(repository.getActiveSort('other'), (
      sortColumn: null,
      sortAscending: null,
    ));
  });
}

class _FakeApi(var StudyUUser user) implements StudyUApi {
  bool throwOnSave = false;
  int fetchCalls = 0;
  int saveCalls = 0;
  Completer<void>? fetchBlocker;
  Completer<void>? firstSaveBlocker;
  final savedUsers = <StudyUUser>[];

  @override
  Future<StudyUUser> fetchUser(String userId) async {
    fetchCalls++;
    await fetchBlocker?.future;
    return user;
  }

  @override
  Future<StudyUUser> saveUser(StudyUUser user) async {
    final saveCall = ++saveCalls;
    if (throwOnSave) throw StateError('save failed');
    if (saveCall == 1 && firstSaveBlocker != null) {
      await firstSaveBlocker!.future;
    }
    this.user = user;
    savedUsers.add(user);
    return user;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository() implements IAuthRepository {
  @override
  User? get currentUser => const User(
    id: 'user-id',
    appMetadata: {},
    userMetadata: null,
    aud: 'authenticated',
    createdAt: '',
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

part 'locale_state.g.dart';

Locale fallbackLocale = Locale(
  Config.defaultLocale.first,
  Config.defaultLocale.last,
);

@immutable
class const LocaleState(final Locale locale) {
  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale ?? this.locale);
  }
}

@riverpod
class LocaleStateNotifier() extends _$LocaleStateNotifier {
  @override
  LocaleState build() {
    /// Initialize Locale
    /// Can be run at startup to establish the initial local from storage, or the platform
    /// 1. Attempts to restore locale from storage
    /// 2. IF no locale in storage, attempts to set local from the platform settings
    // Attempt to restore from storage
    restoreFromStorage();
    return LocaleState(fallbackLocale);
  }

  static const _localStorageKey = 'lang';

  /// Set Locale
  /// Attempts to set the locale if it's in our list of supported locales.
  /// IF NOT: get the first locale that matches our language code and set that
  /// ELSE: do nothing.
  Future<void> setLocale(Locale locale, {bool persistToServer = true}) async {
    final List<Locale> supportedLocales = ref.watch(supportedLocalesProvider);

    // Set the locale if it's in our list of supported locales
    if (supportedLocales.contains(locale)) {
      state = state.copyWith(locale: locale);
    }

    // Get the closest language locale and set that instead
    Locale? closestLocale;
    for (final Locale supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        closestLocale = supportedLocale;
      }
    }
    if (closestLocale != null) {
      state = state.copyWith(locale: closestLocale);
      await save();
      if (persistToServer) {
        try {
          await ref
              .read(userRepositoryProvider)
              .updateLanguage(state.locale.toLanguageTag());
        } catch (_) {}
      }
    }
  }

  /// Restore Locale from the server, local storage, or platform settings.
  Future<bool> restoreFromStorage() async {
    final supportedLocales = ref.read(supportedLocalesProvider);
    try {
      final user = await ref.read(userRepositoryProvider).fetchUser();
      final serverLocale = resolveSupportedLocale(
        user.preferences.language,
        supportedLocales,
      );
      if (serverLocale != null) {
        state = LocaleState(serverLocale);
        await save();
        return true;
      }

      final loadedState = await load();
      if (loadedState != null) {
        user.preferences.language = loadedState.locale.toLanguageTag();
        await ref.read(userRepositoryProvider).saveUser();
        state = loadedState;
        return true;
      }
    } catch (_) {
      final loadedState = await load();
      if (loadedState != null) {
        state = loadedState;
        return true;
      }
    }

    await setLocale(ref.read(platformLocaleProvider), persistToServer: false);
    return false;
  }

  Future<LocaleState?> load() async {
    final locale = resolveSupportedLocale(
      await SecureStorage.read(_localStorageKey),
      ref.read(supportedLocalesProvider),
    );
    return locale == null ? null : LocaleState(locale);
  }

  Future<void> save() async {
    await SecureStorage.write(_localStorageKey, state.locale.toLanguageTag());
  }
}

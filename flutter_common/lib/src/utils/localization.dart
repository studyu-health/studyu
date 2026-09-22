import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/src/utils/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Locale? resolveSupportedLocale(String? value, List<Locale> supportedLocales) {
  if (value == null || value.isEmpty) return null;

  final parts = value.replaceAll('_', '-').split('-');
  final languageCode = parts.first.toLowerCase();
  final countryCode = parts.length > 1 ? parts.last.toUpperCase() : null;

  for (final locale in supportedLocales) {
    if (locale.languageCode == languageCode &&
        locale.countryCode == countryCode) {
      return locale;
    }
  }

  for (final locale in supportedLocales) {
    if (locale.languageCode == languageCode) return locale;
  }
  return null;
}

class AppLanguage(final List<Locale> supportedLocales) extends ChangeNotifier {
  static const String keyLanguageCode = 'language_code';
  Locale? _appLocale;

  this : super() {
    fetchLocale();
  }

  Locale? get appLocal => _appLocale;

  Future<void> fetchLocale() async {
    _appLocale = resolveSupportedLocale(
      await SecureStorage.read(keyLanguageCode),
      supportedLocales,
    );
    notifyListeners();
  }

  Future<void> synchronizeWithServer() async {
    await fetchLocale();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final user = await SupabaseQuery.getById<StudyUUser>(userId);
      final serverLocale = resolveSupportedLocale(
        user.preferences.language,
        supportedLocales,
      );
      if (serverLocale != null) {
        await _setLocalLocale(serverLocale);
        notifyListeners();
        return;
      }

      if (_appLocale != null) {
        user.preferences.language = _appLocale!.toLanguageTag();
        await user.save(onlyUpdate: true);
      }
    } catch (e, stackTrace) {
      StudyULogger.warning(
        'Failed to synchronize language with server',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> changeLanguage(Locale? locale) async {
    if (locale == null) {
      if (_appLocale == null) return;
      await _setLocalLocale(null);
      notifyListeners();
      await _saveToServer(null);
      return;
    }

    final supportedLocale = resolveSupportedLocale(
      locale.toLanguageTag(),
      supportedLocales,
    );
    if (supportedLocale == null || _appLocale == supportedLocale) return;

    await _setLocalLocale(supportedLocale);
    notifyListeners();
    await _saveToServer(supportedLocale);
  }

  Future<void> _setLocalLocale(Locale? locale) async {
    _appLocale = locale;
    if (locale == null) {
      await SecureStorage.delete(keyLanguageCode);
    } else {
      await SecureStorage.write(keyLanguageCode, locale.toLanguageTag());
    }
  }

  Future<void> _saveToServer(Locale? locale) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final user = await SupabaseQuery.getById<StudyUUser>(userId);
      user.preferences.language = locale?.toLanguageTag() ?? '';
      await user.save(onlyUpdate: true);
    } catch (e, stackTrace) {
      StudyULogger.warning(
        'Failed to save language to server',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

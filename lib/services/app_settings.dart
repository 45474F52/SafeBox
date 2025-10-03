import 'package:flutter/material.dart';
import 'package:safebox/l10n/app_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppSettings {
  static final _prefs = SharedPreferencesAsync();

  static const _biometricsKey = 'sb_prefs_biometrics';
  static const _autolockKey = 'sb_prefs_autolock';
  static const _autolockTimeKey = 'sb_prefs_autolocktime';
  static const _themeModeKey = 'sb_prefs_thememode';
  static const _localeKey = 'sb_prefs_locale';
  static const _notificationsKey = 'sb_prefs_notifications';
  static const _appNotifyOnlyKey = 'sb_prefs_appNotifyOnly';

  static Future<void> load() async {
    _biometricsEnabled = await getBiometricsEnabled();
    _autolockEnabled = await getAutolockEnabled();
    _autolockTime = await getAutolockTime();
    _themeMode = await getThemeMode();
    _locale = await getLocale();
    _notificationsEnabled = await getNotificationsEnabled();
    _onlyAppNotifications = await getOnlyAppNotifications();
  }

  static Future<bool> getBiometricsEnabled() async =>
      await _prefs.getBool(_biometricsKey) ?? false;
  static Future<void> setBiometricsEnabled(bool value) async =>
      await _prefs.setBool(_biometricsKey, value);

  static Future<bool> getAutolockEnabled() async =>
      await _prefs.getBool(_autolockKey) ?? false;
  static Future<void> setAutolockEnabled(bool value) async =>
      await _prefs.setBool(_autolockKey, value);

  static Future<String?> getAutolockTime() async =>
      await _prefs.getString(_autolockTimeKey);
  static Future<void> setAutolockTime(String value) async =>
      await _prefs.setString(_autolockTimeKey, value);

  static Future<ThemeMode> getThemeMode() async =>
      ThemeMode.values[await _prefs.getInt(_themeModeKey) ?? 0];
  static Future<void> setThemeMode(ThemeMode mode) async =>
      await _prefs.setInt(_themeModeKey, mode.index);

  static Future<Locale> getLocale() async {
    final localeString = await _prefs.getStringList(_localeKey);
    final language = localeString?.first;
    final country = localeString?.last;
    if (language != null && country != null) {
      return Locale(language, country.isEmpty ? null : country);
    }
    return AppLocales.defaultLocale;
  }

  static Future<void> setLocale(Locale locale) async {
    final language = locale.languageCode;
    final country = locale.countryCode ?? '';
    await _prefs.setStringList(_localeKey, [language, country]);
  }

  static Future<bool> getNotificationsEnabled() async =>
      await _prefs.getBool(_notificationsKey) ?? false;
  static Future<void> setNotificationsEnabled(bool value) async =>
      _prefs.setBool(_notificationsKey, value);

  static Future<bool> getOnlyAppNotifications() async =>
      await _prefs.getBool(_appNotifyOnlyKey) ?? false;
  static Future<void> setOnlyAppNotifications(bool value) async =>
      _prefs.setBool(_appNotifyOnlyKey, value);

  static late bool _biometricsEnabled;
  static late bool _autolockEnabled;
  static late String? _autolockTime;
  static late ThemeMode _themeMode;
  static late Locale _locale;
  static late bool _notificationsEnabled;
  static late bool _onlyAppNotifications;

  static bool get biometricsEnabled => _biometricsEnabled;
  static bool get autolockEnabled => _autolockEnabled;
  static String? get autolockTime => _autolockTime;
  static ThemeMode get themeMode => _themeMode;
  static Locale get locale => _locale;
  static bool get notificationsEnabled => _notificationsEnabled;
  static bool get onlyAppNotifications => _onlyAppNotifications;
}

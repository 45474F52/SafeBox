import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static final _prefs = SharedPreferencesAsync();

  static const _biometricsKey = 'sb_prefs_biometrics';
  static const _autolockKey = 'sb_prefs_autolock';
  static const _autolockTimeKey = 'sb_prefs_autolocktime';

  static Future<void> load() async {
    _biometricsEnabled = await getBiometricsEnabled();
    _autolockEnabled = await getAutolockEnabled();
    _autolockTime = await getAutolockTime();
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

  static late bool _biometricsEnabled;
  static late bool _autolockEnabled;
  static late String? _autolockTime;

  static bool get biometricsEnabled => _biometricsEnabled;
  static bool get autolockEnabled => _autolockEnabled;
  static String? get autolockTime => _autolockTime;
}

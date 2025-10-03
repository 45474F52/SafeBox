import 'package:shared_preferences/shared_preferences.dart';

abstract final class MasterPasswordManager {
  static const _key = 'mpwd_sb.enc';
  static final _storage = SharedPreferencesAsync();

  static Future<void> save(String password) async =>
      await _storage.setString(_key, password);

  static Future<String?> get() async => _storage.getString(_key);

  static Future<void> delete() async => await _storage.remove(_key);
}

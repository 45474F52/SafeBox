import 'package:shared_preferences/shared_preferences.dart';

class LoginAttemptManager {
  static const _attemptsKey = 'sb_login_attempts';
  static const _lockoutKey = 'sb_lockout_time';
  static const _maxAttempts = 5;
  static const _lockoutDiration = 1;

  static final _prefs = SharedPreferencesAsync();

  static Future<bool> canAttemptLogin() async {
    final now = DateTime.now().microsecondsSinceEpoch;
    final lockoutTime = await getLockoutTime();

    if (lockoutTime != null && now >= lockoutTime) {
      await resetAttempts();
      return true;
    }

    if (lockoutTime != null && now < lockoutTime) {
      return false;
    }

    final attempts = await _getAttemptsCount();
    return attempts < _maxAttempts;
  }

  static Future<void> incrementAttempts() async {
    final attempts = await _getAttemptsCount();
    await _prefs.setInt(_attemptsKey, (attempts + 1));

    if (attempts + 1 >= _maxAttempts) {
      await _setLockoutTime();
    }
  }

  static Future<void> resetAttempts() async {
    await _prefs.remove(_attemptsKey);
    await _prefs.remove(_lockoutKey);
  }

  static Future<int> _getAttemptsCount() async {
    return await _prefs.getInt(_attemptsKey) ?? 0;
  }

  static Future<int?> getLockoutTime() async {
    return await _prefs.getInt(_lockoutKey);
  }

  static Future<void> _setLockoutTime() async {
    final lockoutTime = DateTime.now()
        .add(Duration(minutes: _lockoutDiration))
        .microsecondsSinceEpoch;
    await _prefs.setInt(_lockoutKey, lockoutTime);
  }
}

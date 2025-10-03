import 'package:network_info_plus/network_info_plus.dart';

abstract class NetworkHelper {
  static final NetworkInfo _info = NetworkInfo();

  static String? _lastError;
  static String? get lastError => _lastError;

  static Future<String?> getLocalIP([int timeoutInSeconds = 5]) async {
    try {
      return await _info.getWifiIP();
    } catch (e) {
      _lastError = 'Get local IP address error: $e';
      return null;
    }
  }
}

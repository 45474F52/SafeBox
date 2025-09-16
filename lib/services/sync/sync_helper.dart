import 'package:network_info_plus/network_info_plus.dart';

class SyncHelper {
  static final NetworkInfo _info = NetworkInfo();

  static Future<String?> getLocalIP([int timeoutInSeconds = 5]) async {
    try {
      return await _info.getWifiIP();
    } catch (e) {
      print('Get local IP address error: $e');
      return null;
    }
  }
}

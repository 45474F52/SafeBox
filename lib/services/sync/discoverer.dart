import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:safebox/services/helpers/network_helper.dart';

class Discoverer {
  static const int port = 5150;
  static const String discoverMsg = 'DISCOVER_SAFEBOX';
  static const String greetingMsg = 'HELLO_SAFEBOX';
  static const Duration timeout = Duration(seconds: 10);

  final Set<String> _foundIPs = HashSet<String>();

  Timer? _timer;
  RawDatagramSocket? _socket;

  /// Get IPs of devices with this app in LAN
  /// by listen datagrams with special message
  /// from background_worker + local IP
  Future<List<String>> discoverDevices() async {
    _foundIPs.clear();

    final myIP = await NetworkHelper.getLocalIP();
    if (myIP == null) {
      throw 'Не удалось обнаружить локальный IP (${NetworkHelper.lastError})';
    }

    final List<String> broadcastAddress = _getBroadcastAddress(myIP);

    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    _socket!.broadcastEnabled = true;

    final completer = Completer<List<String>>();

    _timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        _socket!.close();
        completer.complete(_foundIPs.toList());
      }
    });

    _socket!.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = _socket!.receive();

        if (datagram != null && datagram.data.isNotEmpty) {
          final msg = String.fromCharCodes(datagram.data).trim();
          final senderIP = datagram.address.address;

          if (msg.startsWith(greetingMsg) && !senderIP.contains(':')) {
            if (senderIP != myIP) {
              _foundIPs.add(senderIP);
            }
          }
        }
      }
    });

    final data = Uint8List.fromList(discoverMsg.codeUnits);

    for (final broadcast in broadcastAddress) {
      try {
        _socket!.send(data, InternetAddress(broadcast), port);
      } catch (e) {
        throw 'Ошибка отправки на $broadcast: $e';
      }
    }

    return completer.future;
  }

  void cancelDiscover() {
    _timer?.cancel();
    _socket?.close();
    _timer = null;
    _socket = null;
  }

  List<String> _getBroadcastAddress(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) {
      return ['255.255.255.255'];
    }

    final a = int.tryParse(parts[0]) ?? 0;
    final b = int.tryParse(parts[1]) ?? 0;
    final c = int.tryParse(parts[2]) ?? 0;

    final List<String> broadcasts = [];

    if ((a == 192 && b == 168) ||
        (a == 10 && b == 0) ||
        (a == 172 && b >= 16 && b <= 31)) {
      broadcasts.add('$a.$b.$c.255');
    }

    broadcasts.add('255.255.255.255');

    return broadcasts;
  }
}

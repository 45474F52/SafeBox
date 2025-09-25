import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:safebox/services/sync/discoverer.dart';
import 'package:safebox/services/helpers/network_helper.dart';

class BackgroundWorker {
  /// Starts a periodic sending message with local IP in LAN
  static void startAnnouncing() {
    Timer.periodic(Duration(seconds: 3), (_) async {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      final myIP = await NetworkHelper.getLocalIP();
      if (myIP == null) {
        socket.close();
        return;
      }

      final msg = '${Discoverer.greetingMsg} $myIP';
      final data = Uint8List.fromList(msg.codeUnits);

      try {
        socket.send(data, InternetAddress('255.255.255.255'), Discoverer.port);
      } finally {
        socket.close();
      }
    });
  }

  /// Starts a datagram listener and reply
  static void startResponder() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, Discoverer.port).then((
      socket,
    ) {
      socket.broadcastEnabled = true;

      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();

          if (datagram != null) {
            final msg = String.fromCharCodes(datagram.data).trim();

            if (msg == Discoverer.discoverMsg) {
              _replyWithGreeting(socket, datagram);
            }
          }
        }
      });
    });
  }

  static void _replyWithGreeting(
    RawDatagramSocket socket,
    Datagram datagram,
  ) async {
    final myIP = await NetworkHelper.getLocalIP();
    if (myIP == null) {
      return;
    }

    final response = '${Discoverer.greetingMsg} $myIP';
    final data = Uint8List.fromList(response.codeUnits);
    socket.send(data, datagram.address, datagram.port);
  }
}

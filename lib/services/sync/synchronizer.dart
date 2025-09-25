import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:safebox/models/password_item.dart';
import 'package:safebox/services/security/crypto_manager.dart';
import 'package:safebox/services/security/password_storage.dart';
import 'package:safebox/services/sync/items_merger.dart';
import 'package:safebox/services/sync/message.dart';
import 'package:safebox/services/sync/sync_state.dart';

class Synchronizer {
  static const int port = 1409;

  late final PasswordStorage _passwordStorage;
  late final File _remotePasswords;
  late final CryptoManager _cryptoManager;

  late final Future<void> _serverStarted;

  static Future<Synchronizer> create(String master) async {
    final storage = await PasswordStorage.create(master);
    final synchronizer = Synchronizer._(storage);
    await synchronizer._serverStarted;
    return synchronizer;
  }

  Synchronizer._(this._passwordStorage) {
    final parentDir = _passwordStorage.fileDir;
    if (!parentDir.existsSync()) {
      parentDir.createSync(recursive: true);
    }

    _remotePasswords = File('${parentDir.path}/rmt_sbpf.enc');

    if (!_remotePasswords.existsSync()) {
      _remotePasswords.createSync();
    }

    _cryptoManager = CryptoManager();

    _serverStarted = _startServer();
  }

  Future<void> _startServer() async {
    try {
      final server = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        port,
        shared: true,
      );

      server.listen((client) {
        final buffer = StringBuffer();
        var state = WaitingFor.sync;

        client.listen(
          (data) {
            final text = String.fromCharCodes(data);
            buffer.write(text);

            if (text.contains(Platform.lineTerminator)) {
              final message = Message(buffer.toString().trim());
              buffer.clear();

              try {
                switch (state) {
                  case WaitingFor.sync:
                    if (message.isStartSync) {
                      client.writeln(
                        Message.sendPublicKey(_cryptoManager.publicKey),
                      );
                      client.flush();
                      state = WaitingFor.publicKey;
                    }
                    break;
                  case WaitingFor.publicKey:
                    if (message.containPublicKey) {
                      _cryptoManager.remotePublicKey = message.publicKey!;
                      _passwordStorage.load().then((localItems) {
                        final localBytes = _passwordsToBytes(localItems);

                        final encryptedLocalData = _cryptoManager.encryptData(
                          localBytes,
                        );
                        final encryptedLocalTempKey = _cryptoManager
                            .encryptTempKey(
                              base64Decode(_cryptoManager.remotePublicKey!),
                            );

                        client.writeln(
                          Message.sendDataWithKey(
                            encryptedLocalData,
                            encryptedLocalTempKey,
                          ),
                        );
                        client.flush();

                        state = WaitingFor.dataWithKey;
                      });
                    }
                    break;
                  case WaitingFor.dataWithKey:
                    if (message.containData) {
                      final (String data, String key) = message.dataWithKey!;

                      _saveRemoteData(base64Decode(data));
                      _cryptoManager.decryptRemoteTempKey(base64Decode(key));

                      client.writeln(Message.finishSync);
                      client.flush();
                      state = WaitingFor.finish;
                    }
                    break;
                  case WaitingFor.finish:
                    if (message.isFinishSync) {
                      client.close();
                      _syncFile();
                      break;
                    }
                }
              } catch (e) {
                print('SYNC.error: ошибка обработки сообщений - $e');
                client.close();
              }
            }
          },
          onDone: () {
            client.close();
          },
          onError: (e) {
            print('SYNC.error: ошибка сокета - $e');
            client.close();
          },
        );
      });
    } catch (e) {
      print('SYNC.error: не удалось запустить сервер - $e');
    }
  }

  Future<void> initiateSyncWith(String ip) async {
    Socket? socket;
    try {
      socket = await Socket.connect(ip, port, timeout: Duration(seconds: 8));

      final buffer = StringBuffer();
      var state = WaitingFor.publicKey;

      final completer = Completer();
      socket.writeln(Message.startSync);
      await socket.flush();

      socket.listen(
        (data) async {
          final text = String.fromCharCodes(data);
          buffer.write(text);

          if (text.contains(Platform.lineTerminator)) {
            final message = Message(buffer.toString().trim());
            buffer.clear();

            try {
              switch (state) {
                case WaitingFor.publicKey:
                  if (message.containPublicKey) {
                    _cryptoManager.remotePublicKey = message.publicKey!;
                    socket!.writeln(
                      Message.sendPublicKey(_cryptoManager.publicKey),
                    );
                    await socket.flush();
                    state = WaitingFor.dataWithKey;
                  }
                  break;
                case WaitingFor.dataWithKey:
                  if (message.containData) {
                    final (String data, String key) = message.dataWithKey!;

                    await _saveRemoteData(base64Decode(data));
                    _cryptoManager.decryptRemoteTempKey(base64Decode(key));

                    final localItems = await _passwordStorage.load();
                    final localBytes = _passwordsToBytes(localItems);

                    final encryptedLocalData = _cryptoManager.encryptData(
                      localBytes,
                    );
                    final encryptedLocalTempKey = _cryptoManager.encryptTempKey(
                      base64Decode(_cryptoManager.remotePublicKey!),
                    );

                    socket!.writeln(
                      Message.sendDataWithKey(
                        encryptedLocalData,
                        encryptedLocalTempKey,
                      ),
                    );
                    await socket.flush();

                    state = WaitingFor.finish;
                  }
                  break;
                case WaitingFor.finish:
                  if (message.isFinishSync) {
                    socket!.writeln(Message.finishSync);
                    await socket.flush();

                    await _syncFile();
                    if (!completer.isCompleted) {
                      completer.complete();
                    }
                  }
                  break;
                default:
                  throw Exception('State "$state" not supported');
              }
            } catch (e) {
              print('SYNC.error: Ошибка клиента 2 - $e');
              completer.completeError(e);
              socket!.close();
            }
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete();
          }
          socket?.close();
        },
        onError: (e) {
          print('SYNC.error: ошибка клиента 1 — $e');
          completer.completeError(e);
          socket?.close();
        },
        cancelOnError: true,
      );

      await completer.future;
    } catch (e) {
      print('SYNC.error: ошибка подключения — $e');
      rethrow;
    } finally {
      socket?.destroy();
    }
  }

  Future<void> _saveRemoteData(Uint8List encryptedData) async {
    await _remotePasswords.writeAsBytes(encryptedData);
  }

  Future<List<PasswordItem>> _loadRemoteData() async {
    final bytes = await _remotePasswords.readAsBytes();
    final decrypted = _cryptoManager.decryptData(bytes);
    return _bytesToPasswords(decrypted);
  }

  Future<void> _syncFile() async {
    final localItems = await _passwordStorage.load();
    final remoteItems = await _loadRemoteData();
    ItemsMerger.sync(localItems, remoteItems);
    await _passwordStorage.save(localItems);
    await _remotePasswords.delete();
  }

  Uint8List _passwordsToBytes(List<PasswordItem> items) {
    final jsonList = jsonEncode(items.map((item) => item.toJSON()).toList());
    return Uint8List.fromList(utf8.encode(jsonList));
  }

  List<PasswordItem> _bytesToPasswords(Uint8List bytes) {
    if (bytes.isEmpty) {
      return [];
    }
    final jsonString = utf8.decode(bytes);
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => PasswordItem.fromJSON(json)).toList();
  }
}

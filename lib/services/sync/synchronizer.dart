import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:safebox/models/password_item.dart';
import 'package:safebox/services/security/crypto_manager.dart';
import 'package:safebox/services/security/password_storage.dart';
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

    _serverStarted = _startServerInternal();
  }

  Future<void> _startServerInternal() async {
    try {
      await _startServer();
    } catch (e) {
      print('Start sync server error: $e');
    }
  }

  Future<void> initiateSyncWith(String ip) async {
    Socket? socket;
    try {
      socket = await Socket.connect(ip, port, timeout: Duration(seconds: 8));

      final buffer = StringBuffer();
      var state = WaitingFor.publicKey;

      final completer = Completer();
      socket.writeln('START SYNC');
      await socket.flush();

      socket.listen(
        (data) async {
          final text = String.fromCharCodes(data);
          buffer.write(text);

          if (text.contains('\n')) {
            final message = buffer.toString().trim();
            buffer.clear();

            try {
              switch (state) {
                case WaitingFor.publicKey:
                  if (message.startsWith('PK:')) {
                    _cryptoManager.remotePublicKey = message.substring(3);
                    socket!.writeln(
                      'PK:${base64Encode(_cryptoManager.publicKey)}',
                    );
                    await socket.flush();
                    state = WaitingFor.dataWithKey;
                  }
                  break;
                case WaitingFor.dataWithKey:
                  if (message.startsWith('DWK:')) {
                    final pair = message
                        .substring(4)
                        .split(':::'); // {data:::key}
                    final encryptedRemoteData = pair[0];
                    final encryptedRemoteTempKey = pair[1];

                    await _saveRemoteData(base64Decode(encryptedRemoteData));
                    _cryptoManager.decryptRemoteTempKey(
                      base64Decode(encryptedRemoteTempKey),
                    );

                    final localItems = await _passwordStorage.load();
                    final localBytes = _passwordsToBytes(localItems);

                    final encryptedLocalData = _cryptoManager.encryptData(
                      localBytes,
                    );
                    final encryptedLocalTempKey = _cryptoManager.encryptTempKey(
                      base64Decode(_cryptoManager.remotePublicKey!),
                    );

                    socket!.writeln(
                      'DWK:${base64Encode(encryptedLocalData)}:::${base64Encode(encryptedLocalTempKey)}',
                    );
                    await socket.flush();

                    state = WaitingFor.finish;
                  }
                  break;
                case WaitingFor.finish:
                  if (message == 'FINISH SYNC') {
                    socket!.writeln('FINISH SYNC');
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

            if (text.contains('\n')) {
              final msg = buffer.toString().trim();
              buffer.clear();

              try {
                switch (state) {
                  case WaitingFor.sync:
                    if (msg == 'START SYNC') {
                      client.writeln(
                        'PK:${base64Encode(_cryptoManager.publicKey)}',
                      );
                      client.flush();
                      state = WaitingFor.publicKey;
                    }
                    break;
                  case WaitingFor.publicKey:
                    if (msg.startsWith('PK:')) {
                      _cryptoManager.remotePublicKey = msg.substring(3);
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
                          'DWK:${base64Encode(encryptedLocalData)}:::${base64Encode(encryptedLocalTempKey)}',
                        );
                        client.flush();

                        state = WaitingFor.dataWithKey;
                      });
                    }
                    break;
                  case WaitingFor.dataWithKey:
                    if (msg.startsWith('DWK:')) {
                      final pair = msg
                          .substring(4)
                          .split(':::'); // {data:::key}
                      final encryptedRemoteData = pair[0];
                      final encryptedRemoteTempKey = pair[1];

                      _saveRemoteData(base64Decode(encryptedRemoteData));
                      _cryptoManager.decryptRemoteTempKey(
                        base64Decode(encryptedRemoteTempKey),
                      );

                      client.writeln('FINISH SYNC');
                      client.flush();
                      state = WaitingFor.finish;
                    }
                    break;
                  case WaitingFor.finish:
                    if (msg == 'FINISH SYNC') {
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

  Future<void> _saveRemoteData(Uint8List encryptedData) async {
    await _remotePasswords.writeAsBytes(encryptedData);
  }

  Future<void> _syncFile() async {
    try {
      final localItems = await _passwordStorage.load();

      final remoteEncryptedBytes = await _remotePasswords.readAsBytes();

      if (localItems.isEmpty && remoteEncryptedBytes.isEmpty) {
        return;
      }

      if (remoteEncryptedBytes.isEmpty) {
        return;
      }

      final remoteDecryptedBytes = _cryptoManager.decryptData(
        remoteEncryptedBytes,
      );
      final remoteItems = _bytesToPasswords(remoteDecryptedBytes);

      if (localItems.isEmpty) {
        await _passwordStorage.save(remoteItems);
        return;
      }

      final mergedItems = _mergePasswordItems(localItems, remoteItems);
      await _passwordStorage.save(mergedItems);
      await _remotePasswords.delete();
    } catch (e) {
      print('SYNC.error: $e');
      rethrow;
    }
  }

  List<PasswordItem> _mergePasswordItems(
    List<PasswordItem> local,
    List<PasswordItem> remote,
  ) {
    final Map<String, PasswordItem> merged = {};

    for (final item in local) {
      merged[item.id] = item;
    }

    for (final item in remote) {
      final existing = merged[item.id];

      if (existing == null) {
        merged[item.id] = item;
      } else {
        if (item.updatedAt.isAfter(existing.updatedAt)) {
          merged[item.id] = item;
        }
      }
    }

    return merged.values.toList();
  }

  Uint8List _passwordsToBytes(List<PasswordItem> items) {
    final jsonList = jsonEncode(items.map((item) => item.toJSON()).toList());
    return Uint8List.fromList(utf8.encode(jsonList));
  }

  List<PasswordItem> _bytesToPasswords(Uint8List bytes) {
    final jsonString = utf8.decode(bytes);
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => PasswordItem.fromJSON(json)).toList();
  }
}

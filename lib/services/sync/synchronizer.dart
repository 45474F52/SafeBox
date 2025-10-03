import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:safebox/models/exceptions/not_in_case_exception.dart';

import '../../models/bank_card.dart';
import '../../models/password_item.dart';
import '../security/bank_card_storage.dart';
import '../security/crypto_manager.dart';
import '../security/password_storage.dart';
import 'items_merger.dart';
import 'message.dart';
import 'sync_state.dart';

final class Synchronizer {
  static const int port = 1409;

  late final PasswordStorage _passwordStorage;
  late final BankCardStorage _cardStorage;

  late final File _remoteData;

  late final CryptoManager _cryptoManager;

  late final Future<void> _serverStarted;

  static Future<Synchronizer> create(String master) async {
    final storage = await PasswordStorage.create(master);
    final cardsStorage = await BankCardStorage.create(master);
    final synchronizer = Synchronizer._(storage, cardsStorage);
    await synchronizer._serverStarted;
    return synchronizer;
  }

  Synchronizer._(this._passwordStorage, this._cardStorage) {
    final parentDir = _passwordStorage.fileDir;
    if (!parentDir.existsSync()) {
      parentDir.createSync(recursive: true);
    }

    _remoteData = File('${parentDir.path}/rmt_sbdf.enc');

    if (!_remoteData.existsSync()) {
      _remoteData.createSync();
    }
    _cryptoManager = CryptoManager();

    _serverStarted = _startServer();
  }

  Future<void> _startServer() async {
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
                    final loadPasswords = _passwordStorage.load();
                    final loadCards = _cardStorage.load();
                    Future.wait([loadPasswords, loadCards]).then((data) {
                      final passwords = data[0] as List<PasswordItem>;
                      final cards = data[1] as List<BankCard>;

                      final passwordsBytes = _itemsToBytes(
                        passwords,
                        (item) => item.toJSON(),
                      );
                      final cardsBytes = _itemsToBytes(
                        cards,
                        (item) => item.toJSON(),
                      );

                      final metadata = Uint8List(1)
                        ..insert(0, passwordsBytes.length);
                      final dataBytes = Uint8List.fromList(metadata)
                        ..addAll(passwordsBytes)
                        ..addAll(cardsBytes);
                      final encryptedData = _cryptoManager.encryptData(
                        dataBytes,
                      );

                      final encryptedTempKey = _cryptoManager.encryptTempKey(
                        base64Decode(_cryptoManager.remotePublicKey!),
                      );

                      client.writeln(
                        Message.sendDataWithKey(
                          encryptedData,
                          encryptedTempKey,
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
              client.close();
              rethrow;
            }
          }
        },
        onDone: () {
          client.close();
        },
        onError: (e) {
          client.close();
          throw e;
        },
      );
    });
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

                    final passwords = await _passwordStorage.load();
                    final cards = await _cardStorage.load();

                    final passwordsBytes = _itemsToBytes(
                      passwords,
                      (item) => item.toJSON(),
                    );
                    final cardsBytes = _itemsToBytes(
                      cards,
                      (item) => item.toJSON(),
                    );

                    final metadata = Uint8List(1)
                      ..insert(0, passwordsBytes.length);
                    final dataBytes = Uint8List.fromList(metadata)
                      ..addAll(passwordsBytes)
                      ..addAll(cardsBytes);
                    final encryptedData = _cryptoManager.encryptData(dataBytes);

                    final encryptedTempKey = _cryptoManager.encryptTempKey(
                      base64Decode(_cryptoManager.remotePublicKey!),
                    );

                    socket!.writeln(
                      Message.sendDataWithKey(encryptedData, encryptedTempKey),
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
                  throw NotInCaseException(state);
              }
            } catch (e) {
              completer.completeError(e);
              socket!.close();
              rethrow;
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
          completer.completeError(e);
          socket?.close();
          throw e;
        },
        cancelOnError: true,
      );

      await completer.future;
    } catch (e) {
      rethrow;
    } finally {
      socket?.destroy();
    }
  }

  Future<void> _saveRemoteData(Uint8List encryptedData) async {
    await _remoteData.writeAsBytes(encryptedData);
  }

  Future<(List<PasswordItem>, List<BankCard>)> _loadRemoteData() async {
    final bytes = await _remoteData.readAsBytes();
    final decrypted = _cryptoManager.decryptData(bytes);

    final metadata = decrypted.buffer.asUint8List(0, 1).first;

    final passwordsBytes = decrypted.buffer.asUint8List(1, 1 + metadata);
    final cardsBytes = decrypted.buffer.asUint8List(1 + metadata);

    final passwords = _bytesToItems(passwordsBytes, PasswordItem.fromJSON);
    final cards = _bytesToItems(cardsBytes, BankCard.fromJSON);

    return (passwords, cards);
  }

  Future<void> _syncFile() async {
    final localPasswords = await _passwordStorage.load();
    final localCards = await _cardStorage.load();

    final (remotePasswords, remoteCards) = await _loadRemoteData();

    ItemsMerger.sync(localPasswords, remotePasswords);
    ItemsMerger.sync(localCards, remoteCards);

    await _passwordStorage.save(localPasswords);
    await _cardStorage.save(localCards);

    await _remoteData.delete();
  }

  static Uint8List _itemsToBytes<T>(
    List<T> items,
    Map<String, dynamic> Function(T) toJSON,
  ) {
    final jsonList = jsonEncode(items.map((item) => toJSON(item)).toList());
    return Uint8List.fromList(utf8.encode(jsonList));
  }

  static List<T> _bytesToItems<T>(
    Uint8List bytes,
    T Function(Map<String, dynamic>) fromJSON,
  ) {
    if (bytes.isNotEmpty) {
      final jsonString = utf8.decode(bytes);
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => fromJSON(json)).toList();
    }
    return [];
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:safebox/services/helpers/path_helper.dart';
import 'package:safebox/services/log/logger.dart';

import 'package:safebox/models/exceptions/not_in_case_exception.dart';
import 'package:safebox/models/bank_card.dart';
import 'package:safebox/models/password_item.dart';
import 'package:safebox/services/storage/bank_cards_storage.dart';
import 'package:safebox/services/security/crypto_manager.dart';
import 'package:safebox/services/storage/passwords_storage.dart';
import 'items_converter.dart';
import 'items_merger.dart';
import 'message.dart';
import 'sync_state.dart';

// TODO: testing
final class Synchronizer {
  static const port = 1409;
  static const _remoteFileName = 'rmt_sbdf.enc';

  static final _logger = Logger("Synchronizer");

  late final PasswordsStorage _passwordStorage;
  late final BankCardsStorage _cardStorage;
  late final Future<bool> Function() _confirmationDialog;

  late final File _remoteData;

  late final CryptoManager _cryptoManager;

  late final Future<void> _serverStarted;

  static Future<Synchronizer> create(
    String master,
    Future<bool> Function() confirmationDialog,
  ) async {
    final storage = await PasswordsStorage.create(master);
    final cardsStorage = await BankCardsStorage.create(master);
    final synchronizer = Synchronizer._(
      storage,
      cardsStorage,
      confirmationDialog,
    );
    await synchronizer._serverStarted;
    return synchronizer;
  }

  Synchronizer._(
    this._passwordStorage,
    this._cardStorage,
    this._confirmationDialog,
  ) {
    final parentDir = _passwordStorage.fileDir;
    if (!parentDir.existsSync()) {
      parentDir.createSync(recursive: true);
    }

    _remoteData = File(PathHelper.combine(parentDir.path, _remoteFileName));

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

    bool confirm = false;

    server.listen((client) {
      final buffer = StringBuffer();
      var state = WaitingFor.sync;

      client.listen(
        (data) async {
          final text = String.fromCharCodes(data);
          buffer.write(text);

          if (text.contains(Platform.lineTerminator)) {
            final message = Message.parse(buffer.toString().trim());
            buffer.clear();

            try {
              switch (state) {
                case WaitingFor.sync:
                  if (message.isStartSync) {
                    await _sendPublicKeyTo(client);
                    state = WaitingFor.publicKey;
                  }
                  break;
                case WaitingFor.publicKey:
                  if (message.containPublicKey) {
                    _cryptoManager.remotePublicKey = message.publicKey!;

                    confirm = await _confirmationDialog();

                    client.writeln(Message.responseConfirmation(confirm));
                    client.flush();

                    state = WaitingFor.requestData;
                  }
                  break;
                case WaitingFor.requestData:
                  if (message.containDataRequest) {
                    await _sendDataTo(client);
                    state = confirm
                        ? WaitingFor.dataWithKey
                        : WaitingFor.finish;
                  }
                  break;
                case WaitingFor.dataWithKey:
                  if (message.containData) {
                    final (String data, String key) = message.dataWithKey!;

                    _saveRemoteData(base64Decode(data));
                    _cryptoManager.decryptRemoteTempKey(base64Decode(key));

                    await _finishSyncWith(client);
                    state = WaitingFor.finish;
                  }
                  break;
                case WaitingFor.finish:
                  if (message.isFinishSync) {
                    client.close();
                    if (confirm) {
                      _syncFile();
                    }
                    break;
                  }
                default:
                  throw NotInCaseException(state);
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
    late Socket socket;
    try {
      socket = await Socket.connect(ip, port, timeout: Duration(seconds: 8));

      final buffer = StringBuffer();
      var state = WaitingFor.publicKey;

      final completer = Completer();
      socket.writeln(Message.startSync);
      await socket.flush();

      bool confirm = false;

      socket.listen(
        (data) async {
          final text = String.fromCharCodes(data);
          buffer.write(text);

          if (text.contains(Platform.lineTerminator)) {
            final message = Message.parse(buffer.toString().trim());
            buffer.clear();

            try {
              switch (state) {
                case WaitingFor.publicKey:
                  if (message.containPublicKey) {
                    _cryptoManager.remotePublicKey = message.publicKey!;
                    await _sendPublicKeyTo(socket);
                    state = WaitingFor.confirmation;
                  }
                  break;
                case WaitingFor.confirmation:
                  if (message.containConfirmation) {
                    confirm = message.isConfirmed;
                    socket.writeln(Message.requestData);
                    await socket.flush();
                    state = WaitingFor.dataWithKey;
                  }
                  break;
                case WaitingFor.dataWithKey:
                  if (message.containData) {
                    final (String data, String key) = message.dataWithKey!;

                    await _saveRemoteData(base64Decode(data));
                    _cryptoManager.decryptRemoteTempKey(base64Decode(key));

                    if (confirm) {
                      await _sendDataTo(socket);
                      state = WaitingFor.finish;
                    } else {
                      await _handleFinishWith(socket, completer);
                    }
                  }
                  break;
                case WaitingFor.finish:
                  if (message.isFinishSync) {
                    await _handleFinishWith(socket, completer);
                  }
                  break;
                default:
                  throw NotInCaseException(state);
              }
            } catch (e) {
              if (!completer.isCompleted) {
                completer.completeError(e);
              }
              socket.close();
              _logger.error(e.toString());
              rethrow;
            }
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete();
          }
          socket.close();
        },
        onError: (e) {
          completer.completeError(e);
          socket.close();
          throw e;
        },
        cancelOnError: true,
      );

      await completer.future;
    } catch (e) {
      rethrow;
    } finally {
      socket.destroy();
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

    final passwords = ItemsConverter.bytesToItems(
      passwordsBytes,
      PasswordItem.fromJson,
    );
    final cards = ItemsConverter.bytesToItems(cardsBytes, BankCard.fromJson);

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

  Future<void> _sendPublicKeyTo(Socket consumer) async {
    consumer.writeln(Message.sendPublicKey(_cryptoManager.publicKey));
    await consumer.flush();
  }

  Future<void> _sendDataTo(Socket consumer) async {
    final passwords = await _passwordStorage.load();
    final cards = await _cardStorage.load();

    final passwordsBytes = ItemsConverter.itemsToBytes(
      passwords,
      (item) => item.toJson(),
    );
    final cardsBytes = ItemsConverter.itemsToBytes(
      cards,
      (item) => item.toJson(),
    );

    final metadata = [passwordsBytes.length];
    final dataBytes = Uint8List.fromList([
      ...metadata,
      ...passwordsBytes,
      ...cardsBytes,
    ]);

    final encryptedData = _cryptoManager.encryptData(dataBytes);
    final encryptedTempKey = _cryptoManager.encryptTempKey(
      base64Decode(_cryptoManager.remotePublicKey!),
    );

    consumer.writeln(Message.sendDataWithKey(encryptedData, encryptedTempKey));
    consumer.flush();
  }

  Future<void> _finishSyncWith(Socket consumer) async {
    consumer.writeln(Message.finishSync);
    await consumer.flush();
  }

  Future<void> _handleFinishWith(Socket consumer, Completer completer) async {
    await _finishSyncWith(consumer);
    await _syncFile();
    if (!completer.isCompleted) {
      completer.complete();
    }
  }
}

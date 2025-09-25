import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

class CryptoManager {
  late final String _privateKey;
  late final String _publicKey;
  late final String _tempKey;

  String? _remoteTempKey;

  String? remotePublicKey;

  CryptoManager() {
    _privateKey = _generatePrivateKey();
    _publicKey = _generatePublicKey();
    _tempKey = _generateTempKey();
  }

  String _generatePrivateKey() {
    return DateTime.now().microsecondsSinceEpoch.toString() +
        Random.secure().nextInt(1000000).toString();
  }

  String _generatePublicKey() {
    return _privateKey
        .split('')
        .map((char) => (char.codeUnitAt(0) + 5).toString())
        .join();
  }

  String _generateTempKey() {
    return Random.secure().nextInt(1_000_000).toString();
  }

  Uint8List encryptTempKey(Uint8List remotePublicKey) {
    return Uint8List.fromList(
      _tempKey
          .split('')
          .map((char) => char.codeUnitAt(0) ^ _publicKey.length)
          .toList(),
    );
  }

  void decryptRemoteTempKey(Uint8List encryptedTempKey) {
    _remoteTempKey = String.fromCharCodes(
      encryptedTempKey.map((code) => code ^ _privateKey.length).toList(),
    );
  }

  Uint8List encryptData(Uint8List data) {
    return data.isEmpty
        ? data
        : Uint8List.fromList(
            utf8
                .decode(data)
                .split('')
                .map((char) => char.codeUnitAt(0) ^ _tempKey.length)
                .toList(),
          );
  }

  Uint8List decryptData(Uint8List data) {
    return data.isEmpty
        ? data
        : Uint8List.fromList(
            utf8
                .decode(data)
                .split('')
                .map((char) => char.codeUnitAt(0) ^ _remoteTempKey!.length)
                .toList(),
          );
  }

  Uint8List get publicKey => Uint8List.fromList(_publicKey.codeUnits);
}

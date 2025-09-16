import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

class Encryptor {
  late final String _masterPassword;
  late final Uint8List _salt;

  Encryptor(String masterPassword, Uint8List salt) {
    _masterPassword = masterPassword;
    _salt = salt;
  }

  Future<String> encryptData(String data) async {
    final key = await _deriveKey(_salt);
    final iv = encrypt.IV.fromLength(12);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );
    final encrypted = encrypter.encrypt(data, iv: iv);
    final combined = Uint8List.fromList(<int>[...iv.bytes, ...encrypted.bytes]);
    return base64.encode(combined);
  }

  Future<String?> decryptData(String data) async {
    if (data.isEmpty) {
      print('Encryptor: пустые данные для расшифровки');
      return null;
    }

    try {
      final key = await _deriveKey(_salt);
      final encryptedBytes = base64Decode(data);

      if (encryptedBytes.length < 12) {
        print('Encryptor: недостаточно данных для IV');
        return null;
      }

      final iv = encrypt.IV(encryptedBytes.sublist(0, 12));
      final encryptedPart = encrypt.Encrypted(encryptedBytes.sublist(12));

      final decrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );
      final decrypted = decrypter.decrypt(encryptedPart, iv: iv);

      return decrypted;
    } catch (e) {
      print('Encryptor: ошибка расшифровки — $e');
      return null;
    }
  }

  Future<encrypt.Key> _deriveKey(Uint8List salt) async {
    final key = await compute(_deriveKeySync, (_masterPassword, salt));
    return encrypt.Key(key);
  }

  Uint8List _deriveKeySync((String password, Uint8List salt) args) {
    final passwordBytes = utf8.encode(args.$1);
    final params = Pbkdf2Parameters(Uint8List.fromList(args.$2), 10000, 32);
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    derivator.init(params);
    return derivator.process(passwordBytes);
  }
}

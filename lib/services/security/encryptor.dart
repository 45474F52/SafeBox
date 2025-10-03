import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:safebox/services/log/logger.dart';

final class Encryptor {
  static const _log = Logger('Encryptor');

  late final encrypt.Key _key;

  Encryptor(String masterPassword, Uint8List salt) {
    _key = _deriveKey(masterPassword, salt);
  }

  String encryptData(String data) {
    final iv = encrypt.IV.fromLength(12);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_key, mode: encrypt.AESMode.gcm),
    );
    final encrypted = encrypter.encrypt(data, iv: iv);
    final combined = Uint8List.fromList(<int>[...iv.bytes, ...encrypted.bytes]);
    return base64.encode(combined);
  }

  String? decryptData(String data) {
    try {
      if (data.isEmpty) {
        return null;
      }

      final encryptedBytes = base64Decode(data);

      final iv = encrypt.IV(encryptedBytes.sublist(0, 12));
      final encryptedPart = encrypt.Encrypted(encryptedBytes.sublist(12));

      final decrypter = encrypt.Encrypter(
        encrypt.AES(_key, mode: encrypt.AESMode.gcm),
      );
      final decrypted = decrypter.decrypt(encryptedPart, iv: iv);

      return decrypted;
    } catch (e) {
      _log.error(e.toString());
      return null;
    }
  }

  encrypt.Key _deriveKey(String masterPassword, Uint8List salt) {
    final passwordBytes = utf8.encode(masterPassword);
    final params = Pbkdf2Parameters(Uint8List.fromList(salt), 10000, 32);
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    derivator.init(params);
    final key = derivator.process(passwordBytes);
    return encrypt.Key(key);
  }
}

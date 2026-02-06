import 'dart:convert';
import 'dart:typed_data';

class Message {
  static const startSync = 'START SYNC';
  static const publicKeyPrefix = 'PK:';
  static const requestConfirmation = 'CONFIRM';
  static const requestData = 'DATA';
  static const dataWithKeyPrefix = 'DWK:';
  static const dataWithKeySplitter = ':::';
  static const finishSync = 'FINISH SYNC';

  late String _text;
  String get text => _text;

  bool get isStartSync => _text == startSync;
  bool get containPublicKey => _text.startsWith(publicKeyPrefix);
  bool get containConfirmation => text.startsWith(requestConfirmation);
  bool get containDataRequest => text.startsWith(requestData);
  bool get containData => _text.startsWith(dataWithKeyPrefix);
  bool get isFinishSync => _text == finishSync;

  String? get publicKey {
    if (containPublicKey) {
      return text.substring(publicKeyPrefix.length);
    }
    return null;
  }

  bool get isConfirmed {
    if (containConfirmation) {
      final result = text
          .substring(requestConfirmation.length)
          .trim()
          .toLowerCase();
      return bool.parse(result);
    }
    return false;
  }

  (String data, String key)? get dataWithKey {
    if (containData) {
      final pair = text
          .substring(dataWithKeyPrefix.length)
          .split(dataWithKeySplitter);
      if (pair.length == 2) {
        return (pair[0], pair[1]);
      }
    }
    return null;
  }

  Message.parse(String text) {
    Message._(text);
  }

  Message._(String text) {
    _text = text;
  }

  static String sendPublicKey(Uint8List publicKey) {
    final key = base64Encode(publicKey);
    return publicKeyPrefix + key;
  }

  static String sendDataWithKey(Uint8List data, Uint8List key) {
    final dataStr = base64Encode(data);
    final keyStr = base64Encode(key);
    return dataWithKeyPrefix + dataStr + dataWithKeySplitter + keyStr;
  }

  static String responseConfirmation(bool confirm) {
    final confirmStr = confirm.toString();
    return requestConfirmation + confirmStr;
  }

  @override
  String toString() => _text;
}

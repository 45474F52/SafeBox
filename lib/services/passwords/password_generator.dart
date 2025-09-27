import 'dart:math';

class PasswordGenerator {
  static const minLength = 8;
  static const maxLength = 32;
  static const _defaultLength = 12;
  static const _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const _numbers = '0123456789';
  static const _symbols = '!@#\$%^&*()_+-={}|;:,.<>?';

  int _length = _defaultLength;

  int get length => _length;

  set length(int value) {
    _length = value >= minLength ? value : _defaultLength;
  }

  bool includeUppercase = true;
  bool includeLowercase = true;
  bool includeNumbers = true;
  bool includeSymbols = true;
  bool excludeAmbiguous = false;

  String generate() {
    String chars = '';
    if (includeUppercase) chars += _uppercase;
    if (includeLowercase) chars += _lowercase;
    if (includeNumbers) chars += _numbers;
    if (includeSymbols) chars += _symbols;

    if (chars.isEmpty) {
      throw ArgumentError();
    }

    if (excludeAmbiguous) {
      chars = chars.replaceAll(RegExp(r'[0O1lI]'), '');
      if (chars.isEmpty) chars = _lowercase;
    }

    final random = Random();
    String password = List.generate(length, (index) {
      return chars[random.nextInt(chars.length)];
    }).join();

    return password;
  }
}

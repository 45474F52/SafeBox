import 'dart:convert';
import 'dart:typed_data';

class SaltProvider {
  static const String _world = 'safebox-test-salt-02072025';
  static Uint8List getSalt() => Uint8List.fromList(utf8.encode(_world));
}

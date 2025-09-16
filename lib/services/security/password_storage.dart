import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:safebox/services/security/encryptor.dart';
import 'package:safebox/models/password_item.dart';
import 'package:safebox/services/security/salt_provider.dart';

class PasswordStorage {
  static const String _fileName = 'sbpf.enc';

  late final File _passwords;
  late final Encryptor _encryptor;

  Directory get fileDir => _passwords.parent;

  static Future<PasswordStorage> create(String master) async {
    final salt = SaltProvider.getSalt();
    final encryptor = Encryptor(master, salt);
    final file = await _initializeFile();

    return PasswordStorage._(encryptor, file);
  }

  PasswordStorage._(this._encryptor, this._passwords);

  static Future<File> _initializeFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/$_fileName');
    if (!await file.exists()) {
      file.create();
    }
    return file;
  }

  Future<List<PasswordItem>> load() async {
    final encryptedData = await _readFile();
    final data = await _encryptor.decryptData(encryptedData);
    if (data == null || data.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((item) => PasswordItem.fromJSON(item)).toList();
  }

  Future<void> save(List<PasswordItem> items) async {
    final jsonString = jsonEncode(items.map((item) => item.toJSON()).toList());
    final String encryptedData = await _encryptor.encryptData(jsonString);
    await _passwords.writeAsString(encryptedData);
  }

  Future<void> addItem(PasswordItem item) async {
    final items = await load();
    items.add(item);
    await save(items);
  }

  Future<void> updateItem(int index, PasswordItem item) async {
    final items = await load();
    if (index >= 0) {
      items[index] = item.copyWith(updatedAt: DateTime.now());
      await save(items);
    }
  }

  Future<void> deleteItem(int index) async {
    final items = await load();
    if (index >= 0) {
      items.removeAt(index);
      await save(items);
    }
  }

  Future<void> clear() async {
    if (await _passwords.exists()) {
      await _passwords.delete();
    }
  }

  Future<String> _readFile() async {
    if (!await _passwords.exists()) {
      return '';
    }
    return await _passwords.readAsString();
  }
}

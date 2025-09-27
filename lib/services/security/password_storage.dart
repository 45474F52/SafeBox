import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import '../../models/password_item.dart';
import 'encryptor.dart';
import 'salt_provider.dart';

class PasswordStorage {
  static const String _fileName = 'sbpf.enc';
  static const _deleteTimeout = Duration(days: 30);

  late final File _passwords;
  late final Encryptor _encryptor;

  Directory get fileDir => _passwords.parent;

  static Future<PasswordStorage> create(String master) async {
    final salt = SaltProvider.getSalt();
    final encryptor = Encryptor(master, salt);
    final file = await _initializeFile();
    final ps = PasswordStorage._(encryptor, file);
    await ps.cleanExpired();
    return ps;
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
    final data = _encryptor.decryptData(encryptedData);
    if (data == null || data.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((item) => PasswordItem.fromJSON(item)).toList();
  }

  Future<List<PasswordItem>> loadActive() async {
    final items = await load();
    return items.where((item) => item.deletedAt == null).toList();
  }

  Future<void> save(List<PasswordItem> items) async {
    final jsonString = jsonEncode(items.map((item) => item.toJSON()).toList());
    final String encryptedData = _encryptor.encryptData(jsonString);
    await _passwords.writeAsString(encryptedData);
  }

  Future<void> addItem(PasswordItem item) async {
    final items = await load();
    items.add(item);
    await save(items);
  }

  Future<void> updateItem(PasswordItem item) async {
    final items = await load();
    final index = items.indexOf(item);
    if (index >= 0) {
      items[index] = item.copyWith(updatedAt: DateTime.now());
      await save(items);
    }
  }

  Future<void> markAsDeleted(String id) async {
    final items = await load();
    if (id.isNotEmpty) {
      final item = items.firstWhere((item) => item.id == id);
      final index = items.indexOf(item);
      items[index] = item.copyWith(deletedAt: DateTime.now());
    }
    await save(items);
  }

  Future<void> cleanExpired() async {
    try {
      final items = await load();
      final count = items.length;
      final now = DateTime.now();
      items.removeWhere(
        (item) =>
            item.deletedAt != null &&
            now.difference(item.deletedAt!) > _deleteTimeout,
      );
      final newCount = items.length;
      if (newCount != count) {
        await save(items);
      }
    } catch (e) {
      print(e.toString());
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

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:safebox/models/bank_card.dart';
import 'package:safebox/services/log/logger.dart';
import 'encryptor.dart';
import 'salt_provider.dart';

final class BankCardStorage {
  static const _log = Logger('BankCardStorage');
  static const String _fileName = 'sbbcf.enc';
  static const _deleteTimeout = Duration(days: 30);

  late final File _cards;
  late final Encryptor _encryptor;

  Directory get fileDir => _cards.parent;

  static Future<BankCardStorage> create(String master) async {
    final salt = SaltProvider.getSalt();
    final encryptor = Encryptor(master, salt);
    final file = await _initializeFile();
    final ps = BankCardStorage._(encryptor, file);
    await ps.cleanExpired();
    return ps;
  }

  BankCardStorage._(this._encryptor, this._cards);

  static Future<File> _initializeFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/$_fileName');
    if (!await file.exists()) {
      file.create();
    }
    return file;
  }

  Future<List<BankCard>> load() async {
    final encryptedData = await _readFile();
    final data = _encryptor.decryptData(encryptedData);
    if (data == null || data.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((item) => BankCard.fromJSON(item)).toList();
  }

  Future<List<BankCard>> loadActive() async {
    final items = await load();
    return items.where((item) => item.deletedAt == null).toList();
  }

  Future<void> save(List<BankCard> items) async {
    final jsonString = jsonEncode(items.map((item) => item.toJSON()).toList());
    final String encryptedData = _encryptor.encryptData(jsonString);
    await _cards.writeAsString(encryptedData);
  }

  Future<void> addItem(BankCard item) async {
    final items = await load();
    items.add(item);
    await save(items);
  }

  Future<void> updateItem(BankCard item) async {
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
      _log.error(e.toString());
    }
  }

  Future<void> clear() async {
    if (await _cards.exists()) {
      await _cards.delete();
    }
  }

  Future<String> _readFile() async {
    if (!await _cards.exists()) {
      return '';
    }
    return await _cards.readAsString();
  }
}

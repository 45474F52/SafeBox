import 'dart:convert';
import 'dart:io';

import 'package:safebox/services/log/logger.dart';
import 'package:safebox/services/security/encryptor.dart';
import 'package:safebox/services/storage/storable_item.dart';

abstract class StorageBase<T extends StorableItem<T>> {
  static const _deleteTimeout = Duration(days: 30);

  final Logger _log;
  final Encryptor _encryptor;
  final File _file;

  const StorageBase(this._log, this._encryptor, this._file);

  Directory get fileDir => _file.parent;

  Future<List<T>> load() async {
    final encryptedData = await _readFile();
    final data = _encryptor.decryptData(encryptedData);
    if (data == null || data.isEmpty) {
      return [];
    }
    final List jsonList = jsonDecode(data);
    return jsonList.map(parseJson).toList();
  }

  Future<List<T>> loadActive() async {
    final items = await load();
    return items.where((item) => !item.isDeleted).toList();
  }

  Future<void> save(List<T> items) async {
    final jsonString = jsonEncode(items.map((item) => item.toJson()).toList());
    final encryptedData = _encryptor.encryptData(jsonString);
    await _file.writeAsString(encryptedData);
  }

  Future<void> addItem(T item) async {
    final items = await load();
    items.add(item);
    await save(items);
  }

  Future<void> updateItem(T item) async {
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
      await save(items);
    }
  }

  Future<void> cleanExpired() async {
    try {
      final items = await load();
      final count = items.length;
      final now = DateTime.now();
      items.removeWhere(
        (item) =>
            item.isDeleted && now.difference(item.deletedAt!) > _deleteTimeout,
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
    if (await _file.exists()) {
      await _file.delete();
    }
  }

  Future<String> _readFile() async {
    if (!await _file.exists()) {
      return '';
    }
    return await _file.readAsString();
  }

  T parseJson(dynamic json);
}

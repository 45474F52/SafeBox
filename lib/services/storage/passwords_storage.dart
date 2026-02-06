import 'dart:io';

import 'package:safebox/models/password_item.dart';
import 'package:safebox/services/helpers/app_files_helper.dart';
import 'package:safebox/services/log/logger.dart';
import 'package:safebox/services/passwords/strength/password_security_checker.dart';
import 'package:safebox/services/security/encryptor.dart';
import 'package:safebox/services/security/salt_provider.dart';
import 'package:safebox/services/storage/storage_base.dart';

final class PasswordsStorage extends StorageBase<PasswordItem> {
  static const _fileName = 'sbpf.enc';

  PasswordsStorage._(Encryptor encryptor, File file)
    : super(const Logger('PasswordsStorage'), encryptor, file);

  static Future<PasswordsStorage> create(String master) async {
    final salt = SaltProvider.getSalt();
    final encryptor = Encryptor(master, salt);
    final file = await AppFilesHelper.initializeFile(_fileName);
    final storage = PasswordsStorage._(encryptor, file);
    await storage.cleanExpired();
    return storage;
  }

  @override
  PasswordItem parseJson(json) => PasswordItem.fromJson(json);

  Future<bool> needUpdateAny() async {
    final items = await loadActive();
    return items.any((item) => PasswordSecurityChecker.isWeak(item.password));
  }
}

import 'dart:io';

import 'package:safebox/models/bank_card.dart';
import 'package:safebox/services/helpers/app_files_helper.dart';
import 'package:safebox/services/log/logger.dart';
import 'package:safebox/services/security/encryptor.dart';
import 'package:safebox/services/security/salt_provider.dart';
import 'package:safebox/services/storage/storage_base.dart';

final class BankCardsStorage extends StorageBase<BankCard> {
  static const _fileName = 'sbbcf.enc';

  BankCardsStorage._(Encryptor encryptor, File file)
    : super(const Logger('BankCardsStorage'), encryptor, file);

  static Future<BankCardsStorage> create(String master) async {
    final salt = SaltProvider.getSalt();
    final encryptor = Encryptor(master, salt);
    final file = await AppFilesHelper.initializeFile(_fileName);
    final storage = BankCardsStorage._(encryptor, file);
    await storage.cleanExpired();
    return storage;
  }

  @override
  BankCard parseJson(json) => BankCard.fromJson(json);
}

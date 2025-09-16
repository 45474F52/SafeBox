import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:safebox/services/security/encryptor.dart';
import 'package:safebox/services/security/salt_provider.dart';

class Verificator {
  static const String _verificationTokenFileName = 'vfc_tkn.enc';
  static const String _verificationPlaintText = 'Love is everywhere';
  static final Future<File> _verificationTokenFileFuture =
      _initVerificationTokenFile();

  static Future<File> _initVerificationTokenFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    return File('${appDir.path}/$_verificationTokenFileName');
  }

  Future<void> removeToken() async {
    final tokenFile = await _verificationTokenFileFuture;
    if (await tokenFile.exists()) {
      await tokenFile.delete();
    }
  }

  Future<bool> verifyMasterPassword(String masterPassword) async {
    final tokenFile = await _verificationTokenFileFuture;
    if (!await tokenFile.exists()) {
      await _createVerificationToken(masterPassword);
      return true;
    }

    final salt = SaltProvider.getSalt();
    final ecnryptedToken = await tokenFile.readAsString();
    final encryptor = Encryptor(masterPassword, salt);
    final decrypted = await encryptor.decryptData(ecnryptedToken);

    return decrypted == _verificationPlaintText;
  }

  Future<void> _createVerificationToken(String masterPassword) async {
    final salt = SaltProvider.getSalt();
    final encryptor = Encryptor(masterPassword, salt);
    final encrypt = await encryptor.encryptData(_verificationPlaintText);
    final tokenFile = await _verificationTokenFileFuture;
    await tokenFile.writeAsString(encrypt);
  }
}

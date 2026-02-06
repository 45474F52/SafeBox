import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:safebox/services/helpers/path_helper.dart';

abstract final class AppFilesHelper {
  static Future<Directory> get appDocsDir => getApplicationDocumentsDirectory();

  static Future<File> initializeFile(String fileName) async {
    final appDir = await appDocsDir;
    final file = File(PathHelper.combine(appDir.path, fileName));
    if (!await file.exists()) {
      await file.create();
    }
    return file;
  }
}

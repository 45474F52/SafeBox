import 'dart:io';

abstract final class PathHelper {
  static String combine(String dirPath, String fileName) {
    return '$dirPath${Platform.pathSeparator}$fileName';
  }
}

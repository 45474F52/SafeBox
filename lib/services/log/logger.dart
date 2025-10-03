import 'dart:developer' as developer;

import 'package:safebox/services/log/log_level.dart';

final class Logger {
  final String _source;
  const Logger(String source) : _source = 'SafeBox.Log.$source';

  void log(LogLevel level, String text) {
    if ( /*kDebugMode*/ true) {
      developer.log(
        text,
        time: DateTime.now(),
        level: level.index,
        name: _source,
      );
    }
  }

  void debug(String text) {
    log(LogLevel.debug, text);
  }

  void info(String text) {
    log(LogLevel.info, text);
  }

  void warning(String text) {
    log(LogLevel.warning, text);
  }

  void error(String text) {
    log(LogLevel.error, text);
  }
}

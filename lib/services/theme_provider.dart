import 'package:flutter/material.dart';
import 'package:safebox/services/app_settings.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = AppSettings.themeMode;
  ThemeMode get theme => _themeMode;
  set theme(ThemeMode mode) {
    _themeMode = mode;
    AppSettings.setThemeMode(mode);
    notifyListeners();
  }
}

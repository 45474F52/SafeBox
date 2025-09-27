import 'package:flutter/material.dart';
import 'package:safebox/l10n/app_locales.dart';
import 'package:safebox/services/app_settings.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = AppSettings.locale;

  Locale get locale => _locale;

  set locale(Locale value) {
    if (AppLocales.all.contains(value)) {
      _locale = value;
      AppSettings.setLocale(value);
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';

extension LanguageName on Locale {
  String get languageName => switch (languageCode) {
    'ru' => 'Русский',
    'en' => 'English',
    _ => languageCode,
  };
}

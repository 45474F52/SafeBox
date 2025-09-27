import 'dart:ui';

class AppLocales {
  static final ru = const Locale('ru', 'RU');
  static final en = const Locale('en', 'US');

  static Locale get defaultLocale => ru;

  static final all = [ru, en];
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get language => 'Русский';

  @override
  String get appName => 'SafeBox';

  @override
  String get login => 'Логин';

  @override
  String get password => 'Пароль';

  @override
  String get description => 'Описание';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get apply => 'Применить';

  @override
  String get error => 'Ошибка';

  @override
  String get delete => 'Удалить';

  @override
  String get close => 'Закрыть';

  @override
  String get search => 'Поиск';

  @override
  String get copy => 'Скопировать';

  @override
  String get clear => 'Очистить';

  @override
  String get add => 'Добавить';

  @override
  String get edit => 'Редактировать';

  @override
  String get discover => 'Обнаружить';

  @override
  String get stop => 'Стоп';

  @override
  String get minutesPrefix => 'мин.';

  @override
  String get secondsPrefix => 'сек.';

  @override
  String get piecesPrefix => 'шт.';

  @override
  String errorMsg(Object message) {
    return 'Ошибка: $message';
  }

  @override
  String notInCaseError(Object state) {
    return 'State \"$state\" not supported';
  }

  @override
  String get loginTitle => 'Введите мастер-пароль';

  @override
  String get loginLabel => 'Мастер-пароль';

  @override
  String get signIn => 'Войти';

  @override
  String get attempsErrorMessage => 'Слишком много неудачных попыток';

  @override
  String get notAuthenticatedMessage => 'Не удалось подтвердить личность';

  @override
  String lockoutMessage(String message) {
    return 'Доступ заблокирован на $message';
  }

  @override
  String get invalidPasswordError => 'Неверный мастер-пароль';

  @override
  String get loadingMsg => 'Загрузка...';

  @override
  String get initMsg => 'Инициализация...';

  @override
  String get initError => 'Ошибка инициализации';

  @override
  String get passwordsTab => 'Пароли';

  @override
  String get bankCardsTab => 'Карты';

  @override
  String get generatorTab => 'Генератор';

  @override
  String get settingsTab => 'Настройки';

  @override
  String get othersCategory => 'Другие';

  @override
  String get removeQuestion => 'Удалить?';

  @override
  String removePasswordQuestion(String url) {
    return 'Удалить пароль для $url?';
  }

  @override
  String removeBankCardQuestion(String number) {
    return 'Удалить карту $number?';
  }

  @override
  String get filters => 'Фильтры';

  @override
  String get showAll => 'Показать все';

  @override
  String get enterSearchQuery => 'Введите поисковый запрос';

  @override
  String get passwordCopied => 'Пароль скопирован';

  @override
  String get generatorTabTitle => 'Генератор паролей';

  @override
  String get passwordLength => 'Длина пароля:';

  @override
  String get uppercase => 'Заглавные';

  @override
  String get lowercase => 'Строчные';

  @override
  String get numbers => 'Цифры';

  @override
  String get symbols => 'Сиволы';

  @override
  String get excludeAmbigious => 'Исключить похожие (0,O,l,1)';

  @override
  String get generate => 'Сгенерировать';

  @override
  String get generatedPassword => 'Сгенерированный пароль:';

  @override
  String get passphraseGenTitle => 'Генератор парольных фраз';

  @override
  String get passphraseCopied => 'Парольная фраза скопирована';

  @override
  String get wordsCount => 'Количество слов:';

  @override
  String get addYourWord => 'Добавьте своё слово';

  @override
  String get yourWords => 'Ваши слова:';

  @override
  String get generatedPassphrase => 'Сгенерированная парольная фраза:';

  @override
  String get appSettingsTitle => 'Настройки приложения';

  @override
  String get safety => 'Безопасность';

  @override
  String get biometrics => 'Биометрия';

  @override
  String get biometricsUnlock => 'Разблокировка по лицу или отпечатку';

  @override
  String get autolock => 'Автоблокировка';

  @override
  String get idleBlock => 'Блокировать приложение при бездействии';

  @override
  String get timeBeforeBlocking => 'Время до блокировки';

  @override
  String get storage => 'Хранилище';

  @override
  String get synchronization => 'Синхронизация';

  @override
  String get forceSync => 'Принудительно синхронизировать пароли';

  @override
  String get exportImport => 'Экспорт/Импорт';

  @override
  String get clearData => 'Очистить данные';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get developer => 'Разработчик';

  @override
  String get license => 'Лицензия';

  @override
  String get clearAllQuestion => '⚠️ Очистить всё?';

  @override
  String get clearAllQuestionDescription =>
      'Все сохранённые данные будут безвозвратно удалены. Вы уверены?';

  @override
  String get allDataCleared => '✅ Все данные очищены';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get emptyFieldError => 'Поле пустое';

  @override
  String get addTag => 'Добавить тег';

  @override
  String get loginIsRequiredError => 'Логин обязателен';

  @override
  String get fileSaved => 'Файл успешно сохранён';

  @override
  String get selectFileForImport => 'Выберите файл для импорта';

  @override
  String get dataImported => 'Данные успешно импортированы';

  @override
  String get exportPasswords => 'Экспортировать пароли';

  @override
  String get importPasswords => 'Импортировать пароли';

  @override
  String selectedFileMessage(String file) {
    return 'Выбран файл: $file';
  }

  @override
  String get securityStatsTitle => 'Статистика безопасности паролей';

  @override
  String get noDataError => 'Нет данных';

  @override
  String statsSummaryMessage(int totalCount, int weakCount) {
    return 'Проанализировано паролей $totalCount\nНенадёжных паролей: $weakCount';
  }

  @override
  String get veryWeakLevelText =>
      'Крайне ненадёжный пароль.\nНужно увеличить длину и добавить спецсимволы';

  @override
  String get weakLevelText =>
      'Слабый пароль.\nДобавьте спецсимволы и буквы в разных регистрах';

  @override
  String get moderateLevelText =>
      'Средняя надёжность.\nРекомендуется увеличить длину до 16+ символов';

  @override
  String get strongLevelText => 'Надёжный пароль.\nСодержит все типы символов';

  @override
  String get veryStrongLevelText =>
      'Отличный пароль!\nСоответствует всем требованиям безопасности';

  @override
  String get discoverDevices => 'Поиск устройств';

  @override
  String get searchMsg => 'Поиск...';

  @override
  String discoveredCountMessage(int count) {
    return 'Найдено устройств: $count';
  }

  @override
  String get devicesNotFoundMsg => 'Устройства не обнаружены';

  @override
  String startSyncWith(String device) {
    return 'Начать синхронизацию с $device';
  }

  @override
  String get passwordsSynchronized => 'Пароли синхронизированы';

  @override
  String get selectLeastOneCharError => 'Выберите хотя бы один тип символов';

  @override
  String get personalizationSettings => 'Персонализация';

  @override
  String get languageSettings => 'Язык приложения';

  @override
  String get themeSettings => 'Тема приложения';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String savedToMessage(String path) {
    return 'Файл сохранён в $path';
  }
}

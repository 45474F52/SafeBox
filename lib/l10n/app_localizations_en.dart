// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'English';

  @override
  String get appName => 'SafeBox';

  @override
  String get login => 'Login';

  @override
  String get password => 'Password';

  @override
  String get description => 'Description';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String get error => 'Error';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get copy => 'Copy';

  @override
  String get clear => 'Clear';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get discover => 'Discover';

  @override
  String get stop => 'Stop';

  @override
  String get minutesPrefix => 'min.';

  @override
  String get secondsPrefix => 'sec.';

  @override
  String get piecesPrefix => 'pcs.';

  @override
  String errorMsg(Object message) {
    return 'Error: $message';
  }

  @override
  String get loginTitle => 'Enter master-password';

  @override
  String get loginLabel => 'Master-password';

  @override
  String get signIn => 'Sign In';

  @override
  String get attempsErrorMessage => 'Too many failed attempts';

  @override
  String get notAuthenticatedMessage => 'Couldn\'t confirm identity';

  @override
  String lockoutMessage(Object message) {
    return 'Fccess is blocked for $message';
  }

  @override
  String get invalidPasswordError => 'Invalid master password';

  @override
  String get loadingMsg => 'Loading...';

  @override
  String get initMsg => 'Initialization...';

  @override
  String get initError => 'Initialization error';

  @override
  String get passwordsTab => 'Passwords';

  @override
  String get generatorTab => 'Generator';

  @override
  String get settingsTab => 'Settings';

  @override
  String get othersCategory => 'Others';

  @override
  String get removeQuestion => 'Delete?';

  @override
  String removePasswordQuestion(Object url) {
    return 'Delete password for $url?';
  }

  @override
  String get filters => 'Filters';

  @override
  String get showAll => 'Show all';

  @override
  String get enterSearchQuery => 'Enter search query';

  @override
  String get passwordCopied => 'Password has been copied';

  @override
  String get generatorTabTitle => 'Passwords generator';

  @override
  String get passwordLength => 'Password length:';

  @override
  String get uppercase => 'Uppercase';

  @override
  String get lowercase => 'Lowercase';

  @override
  String get numbers => 'Numbers';

  @override
  String get symbols => 'Sybmols';

  @override
  String get excludeAmbigious => 'Exclude ambigious (0,O,l,1)';

  @override
  String get generate => 'Generate';

  @override
  String get generatedPassword => 'Generated password:';

  @override
  String get passphraseGenTitle => 'Password phrase generator';

  @override
  String get passphraseCopied => 'Password phrase has been copied';

  @override
  String get wordsCount => 'Words count:';

  @override
  String get addYourWord => 'Add your word';

  @override
  String get yourWords => 'Your words:';

  @override
  String get generatedPassphrase => 'Generated password phrase:';

  @override
  String get appSettingsTitle => 'App settings';

  @override
  String get safety => 'Safety';

  @override
  String get biometrics => 'Biometrics';

  @override
  String get biometricsUnlock => 'Face or fingerprint unlock';

  @override
  String get autolock => 'Autolock';

  @override
  String get idleBlock => 'Block application when idle';

  @override
  String get timeBeforeBlocking => 'Time before blocking';

  @override
  String get storage => 'Storage';

  @override
  String get synchronization => 'Synchronization';

  @override
  String get forceSync => 'Force synchronization of passwords';

  @override
  String get exportImport => 'Export/Import';

  @override
  String get clearData => 'Clear data';

  @override
  String get aboutApp => 'About app';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get license => 'License';

  @override
  String get clearAllQuestion => '⚠️ Clear all?';

  @override
  String get clearAllQuestionDescription =>
      'All saved passwords will be permanently deleted. Are you sure?';

  @override
  String get allDataCleared => '✅ All data cleared';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get emptyFieldError => 'Empty field';

  @override
  String get addTag => 'Add tag';

  @override
  String get loginIsRequiredError => 'Login is required';

  @override
  String get fileSaved => 'The file was saved successfully';

  @override
  String get selectFileForImport => 'Select file for import';

  @override
  String get dataImported => 'Data was successfully imported';

  @override
  String get exportPasswords => 'Export passwords';

  @override
  String get importPasswords => 'Import passwords';

  @override
  String selectedFileMessage(Object file) {
    return 'File is selected: $file';
  }

  @override
  String get securityStatsTitle => 'Password Security Statistics';

  @override
  String get noDataError => 'No data';

  @override
  String statsSummaryMessage(Object totalCount, Object weakCount) {
    return 'Passwords analyzed $totalCount\nNon-secure passwords: $weakCount';
  }

  @override
  String get veryWeakLevelText =>
      'Extremely unreliable password.\nYou need to increase the length and add special characters';

  @override
  String get weakLevelText =>
      'Weak password.\nAdd special characters and letters in different registers';

  @override
  String get moderateLevelText =>
      'Average reliability.\nIt is recommended to increase the length to 16+ characters';

  @override
  String get strongLevelText =>
      'A strong password.\nContains all types of characters';

  @override
  String get veryStrongLevelText =>
      'Great password!\nMeets all safety requirements';

  @override
  String get discoverDevices => 'Discover devices';

  @override
  String get searchMsg => 'Discover...';

  @override
  String discoveredCountMessage(Object count) {
    return 'Devices found: $count';
  }

  @override
  String get devicesNotFoundMsg => 'Devices not found';

  @override
  String startSyncWith(Object device) {
    return 'Start synchronization with $device';
  }

  @override
  String get passwordsSynchronized => 'Passwords was synchronized';

  @override
  String get selectLeastOneCharError => 'Select at least one character type';

  @override
  String get personalizationSettings => 'Personalization';

  @override
  String get languageSettings => 'App language';

  @override
  String get themeSettings => 'App theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';
}

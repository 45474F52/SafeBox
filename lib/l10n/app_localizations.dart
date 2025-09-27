import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SafeBox'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @minutesPrefix.
  ///
  /// In en, this message translates to:
  /// **'min.'**
  String get minutesPrefix;

  /// No description provided for @secondsPrefix.
  ///
  /// In en, this message translates to:
  /// **'sec.'**
  String get secondsPrefix;

  /// No description provided for @piecesPrefix.
  ///
  /// In en, this message translates to:
  /// **'pcs.'**
  String get piecesPrefix;

  /// Enter error message
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMsg(Object message);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter master-password'**
  String get loginTitle;

  /// No description provided for @loginLabel.
  ///
  /// In en, this message translates to:
  /// **'Master-password'**
  String get loginLabel;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @attempsErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts'**
  String get attempsErrorMessage;

  /// No description provided for @notAuthenticatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t confirm identity'**
  String get notAuthenticatedMessage;

  /// Enter lockout duration
  ///
  /// In en, this message translates to:
  /// **'Fccess is blocked for {message}'**
  String lockoutMessage(Object message);

  /// No description provided for @invalidPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Invalid master password'**
  String get invalidPasswordError;

  /// No description provided for @loadingMsg.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMsg;

  /// No description provided for @initMsg.
  ///
  /// In en, this message translates to:
  /// **'Initialization...'**
  String get initMsg;

  /// No description provided for @initError.
  ///
  /// In en, this message translates to:
  /// **'Initialization error'**
  String get initError;

  /// No description provided for @passwordsTab.
  ///
  /// In en, this message translates to:
  /// **'Passwords'**
  String get passwordsTab;

  /// No description provided for @generatorTab.
  ///
  /// In en, this message translates to:
  /// **'Generator'**
  String get generatorTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @othersCategory.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get othersCategory;

  /// No description provided for @removeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get removeQuestion;

  /// Enter url
  ///
  /// In en, this message translates to:
  /// **'Delete password for {url}?'**
  String removePasswordQuestion(Object url);

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @enterSearchQuery.
  ///
  /// In en, this message translates to:
  /// **'Enter search query'**
  String get enterSearchQuery;

  /// No description provided for @passwordCopied.
  ///
  /// In en, this message translates to:
  /// **'Password has been copied'**
  String get passwordCopied;

  /// No description provided for @generatorTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Passwords generator'**
  String get generatorTabTitle;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password length:'**
  String get passwordLength;

  /// No description provided for @uppercase.
  ///
  /// In en, this message translates to:
  /// **'Uppercase'**
  String get uppercase;

  /// No description provided for @lowercase.
  ///
  /// In en, this message translates to:
  /// **'Lowercase'**
  String get lowercase;

  /// No description provided for @numbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get numbers;

  /// No description provided for @symbols.
  ///
  /// In en, this message translates to:
  /// **'Sybmols'**
  String get symbols;

  /// No description provided for @excludeAmbigious.
  ///
  /// In en, this message translates to:
  /// **'Exclude ambigious (0,O,l,1)'**
  String get excludeAmbigious;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @generatedPassword.
  ///
  /// In en, this message translates to:
  /// **'Generated password:'**
  String get generatedPassword;

  /// No description provided for @passphraseGenTitle.
  ///
  /// In en, this message translates to:
  /// **'Password phrase generator'**
  String get passphraseGenTitle;

  /// No description provided for @passphraseCopied.
  ///
  /// In en, this message translates to:
  /// **'Password phrase has been copied'**
  String get passphraseCopied;

  /// No description provided for @wordsCount.
  ///
  /// In en, this message translates to:
  /// **'Words count:'**
  String get wordsCount;

  /// No description provided for @addYourWord.
  ///
  /// In en, this message translates to:
  /// **'Add your word'**
  String get addYourWord;

  /// No description provided for @yourWords.
  ///
  /// In en, this message translates to:
  /// **'Your words:'**
  String get yourWords;

  /// No description provided for @generatedPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Generated password phrase:'**
  String get generatedPassphrase;

  /// No description provided for @appSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettingsTitle;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// No description provided for @biometricsUnlock.
  ///
  /// In en, this message translates to:
  /// **'Face or fingerprint unlock'**
  String get biometricsUnlock;

  /// No description provided for @autolock.
  ///
  /// In en, this message translates to:
  /// **'Autolock'**
  String get autolock;

  /// No description provided for @idleBlock.
  ///
  /// In en, this message translates to:
  /// **'Block application when idle'**
  String get idleBlock;

  /// No description provided for @timeBeforeBlocking.
  ///
  /// In en, this message translates to:
  /// **'Time before blocking'**
  String get timeBeforeBlocking;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @synchronization.
  ///
  /// In en, this message translates to:
  /// **'Synchronization'**
  String get synchronization;

  /// No description provided for @forceSync.
  ///
  /// In en, this message translates to:
  /// **'Force synchronization of passwords'**
  String get forceSync;

  /// No description provided for @exportImport.
  ///
  /// In en, this message translates to:
  /// **'Export/Import'**
  String get exportImport;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear data'**
  String get clearData;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @clearAllQuestion.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Clear all?'**
  String get clearAllQuestion;

  /// No description provided for @clearAllQuestionDescription.
  ///
  /// In en, this message translates to:
  /// **'All saved passwords will be permanently deleted. Are you sure?'**
  String get clearAllQuestionDescription;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'✅ All data cleared'**
  String get allDataCleared;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @emptyFieldError.
  ///
  /// In en, this message translates to:
  /// **'Empty field'**
  String get emptyFieldError;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @loginIsRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Login is required'**
  String get loginIsRequiredError;

  /// No description provided for @fileSaved.
  ///
  /// In en, this message translates to:
  /// **'The file was saved successfully'**
  String get fileSaved;

  /// No description provided for @selectFileForImport.
  ///
  /// In en, this message translates to:
  /// **'Select file for import'**
  String get selectFileForImport;

  /// No description provided for @dataImported.
  ///
  /// In en, this message translates to:
  /// **'Data was successfully imported'**
  String get dataImported;

  /// No description provided for @exportPasswords.
  ///
  /// In en, this message translates to:
  /// **'Export passwords'**
  String get exportPasswords;

  /// No description provided for @importPasswords.
  ///
  /// In en, this message translates to:
  /// **'Import passwords'**
  String get importPasswords;

  /// Enter selected file path
  ///
  /// In en, this message translates to:
  /// **'File is selected: {file}'**
  String selectedFileMessage(Object file);

  /// No description provided for @securityStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Security Statistics'**
  String get securityStatsTitle;

  /// No description provided for @noDataError.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noDataError;

  /// Enter total count of passwords and count of weak passwords
  ///
  /// In en, this message translates to:
  /// **'Passwords analyzed {totalCount}\nNon-secure passwords: {weakCount}'**
  String statsSummaryMessage(Object totalCount, Object weakCount);

  /// No description provided for @veryWeakLevelText.
  ///
  /// In en, this message translates to:
  /// **'Extremely unreliable password.\nYou need to increase the length and add special characters'**
  String get veryWeakLevelText;

  /// No description provided for @weakLevelText.
  ///
  /// In en, this message translates to:
  /// **'Weak password.\nAdd special characters and letters in different registers'**
  String get weakLevelText;

  /// No description provided for @moderateLevelText.
  ///
  /// In en, this message translates to:
  /// **'Average reliability.\nIt is recommended to increase the length to 16+ characters'**
  String get moderateLevelText;

  /// No description provided for @strongLevelText.
  ///
  /// In en, this message translates to:
  /// **'A strong password.\nContains all types of characters'**
  String get strongLevelText;

  /// No description provided for @veryStrongLevelText.
  ///
  /// In en, this message translates to:
  /// **'Great password!\nMeets all safety requirements'**
  String get veryStrongLevelText;

  /// No description provided for @discoverDevices.
  ///
  /// In en, this message translates to:
  /// **'Discover devices'**
  String get discoverDevices;

  /// No description provided for @searchMsg.
  ///
  /// In en, this message translates to:
  /// **'Discover...'**
  String get searchMsg;

  /// Enter discovered count
  ///
  /// In en, this message translates to:
  /// **'Devices found: {count}'**
  String discoveredCountMessage(Object count);

  /// No description provided for @devicesNotFoundMsg.
  ///
  /// In en, this message translates to:
  /// **'Devices not found'**
  String get devicesNotFoundMsg;

  /// Enter device IP to sync with
  ///
  /// In en, this message translates to:
  /// **'Start synchronization with {device}'**
  String startSyncWith(Object device);

  /// No description provided for @passwordsSynchronized.
  ///
  /// In en, this message translates to:
  /// **'Passwords was synchronized'**
  String get passwordsSynchronized;

  /// No description provided for @selectLeastOneCharError.
  ///
  /// In en, this message translates to:
  /// **'Select at least one character type'**
  String get selectLeastOneCharError;

  /// No description provided for @personalizationSettings.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalizationSettings;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get languageSettings;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'App theme'**
  String get themeSettings;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

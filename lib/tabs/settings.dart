import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safebox/custom_controls/settings_item.dart';
import 'package:safebox/services/helpers/snackbar_provider.dart';
import 'package:safebox/services/notifications/system_notifications_service.dart';
import '../l10n/locale_provider.dart';
import '../l10n/strings.dart';
import '../services/security/bank_card_storage.dart';
import '../services/theme_provider.dart';
import '../custom_controls/login_widget.dart';
import '../l10n/app_locales.dart';
import '../models/lock_option.dart';
import '../screen/export_import_screen.dart';
import '../screen/sync_screen.dart';
import '../services/app_settings.dart';
import '../services/auth/master_password_manager.dart';
import '../services/inactivity_manager.dart';
import '../services/security/password_storage.dart';
import '../services/auth/verificator.dart';
import '../services/sync/synchronizer.dart';
import '../services/helpers/locale_helper.dart';

class SettingsTab extends StatefulWidget {
  final PasswordStorage passwordStorage;
  final BankCardStorage cardStorage;
  final Synchronizer synchronizer;

  const SettingsTab({
    super.key,
    required this.passwordStorage,
    required this.cardStorage,
    required this.synchronizer,
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  static final List<LockOption> _lockOptions = [
    LockOption.fromMinutes(Duration(minutes: 5)),
    LockOption.fromMinutes(Duration(minutes: 25)),
    LockOption.fromMinutes(Duration(minutes: 60)),
  ];
  static final _defLockOption = _lockOptions.first;

  late final _strings = Strings.of(context);

  final Verificator _verificator = Verificator();
  late final LocaleProvider _localeProvider;
  late final ThemeProvider _themeProvider;

  late final FocusNode _localeFocus;
  late final FocusNode _themeFocus;

  bool _biometricsEnabled = false;
  bool _autoLockEnabled = false;
  LockOption _autoLockTime = _defLockOption;
  bool _notificationsEnabled = false;
  bool _onlyAppNotifications = false;

  @override
  void initState() {
    super.initState();
    _localeFocus = FocusNode();
    _themeFocus = FocusNode();
    _localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _loadSettings();
  }

  @override
  void dispose() {
    _localeFocus.dispose();
    _themeFocus.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    await AppSettings.load();

    final biometricsEnabled = AppSettings.biometricsEnabled;
    final autolockEnabled = AppSettings.autolockEnabled;
    final autolockTime = AppSettings.autolockTime;
    final notificationsEnabled = AppSettings.notificationsEnabled;
    final onlyAppNotifications = AppSettings.onlyAppNotifications;
    _localeProvider.locale = AppSettings.locale;
    _themeProvider.theme = AppSettings.themeMode;

    setState(() {
      _biometricsEnabled = biometricsEnabled;
      _autoLockEnabled = autolockTime != null ? autolockEnabled : false;
      _autoLockTime = _autoLockEnabled
          ? LockOption.parse(autolockTime!)
          : LockOption.nullObject();
      _notificationsEnabled = notificationsEnabled;
      _onlyAppNotifications = onlyAppNotifications;
      InactivityManagerSingleton().setDuration(_autoLockTime.duration);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _strings.appSettingsTitle,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          SettingsItem(
            titleIcon: Icons.shield,
            titleText: _strings.safety,
            children: [
              SwitchListTile(
                title: Text(_strings.biometrics),
                subtitle: Text(_strings.biometricsUnlock),
                value: _biometricsEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricsEnabled = value;
                  });
                  AppSettings.setBiometricsEnabled(value);
                },
              ),
              SwitchListTile(
                title: Text(_strings.autolock),
                subtitle: Text(_strings.idleBlock),
                value: _autoLockEnabled,
                onChanged: (value) async {
                  setState(() => _autoLockEnabled = value);
                  await AppSettings.setAutolockEnabled(value);
                  if (value == false) {
                    InactivityManagerSingleton().setDuration(Duration.zero);
                  } else {
                    InactivityManagerSingleton().setDuration(
                      _defLockOption.duration,
                    );
                  }
                },
              ),
              Visibility(
                visible: _autoLockEnabled,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
                  child: DropdownButtonFormField<LockOption>(
                    key: ValueKey(_lockOptions.first.minutes),
                    initialValue: _lockOptions.first,
                    items: _lockOptions.map((option) {
                      final alias =
                          '${option.minutes} ${_strings.minutesPrefix}';
                      return DropdownMenuItem(
                        value: option,
                        child: Text(alias),
                      );
                    }).toList(),
                    onChanged: (LockOption? value) async {
                      if (value != null) {
                        setState(() {
                          _autoLockTime = value;
                        });
                        InactivityManagerSingleton().setDuration(
                          _autoLockTime.duration,
                        );
                        await AppSettings.setAutolockTime(value.minutes);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: _strings.timeBeforeBlocking,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SettingsItem(
            titleIcon: Icons.storage,
            titleText: _strings.storage,
            children: [
              ListTile(
                title: Text(_strings.synchronization),
                subtitle: Text(_strings.forceSync),
                trailing: const Icon(Icons.sync_alt),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SyncScreen(synchronizer: widget.synchronizer),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(_strings.exportImport),
                trailing: const Icon(Icons.import_export),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExportImportScreen(storage: widget.passwordStorage),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  _strings.clearData,
                  style: TextStyle(color: Colors.red),
                ),
                trailing: const Icon(Icons.delete, color: Colors.red),
                onTap: _confirmClearData,
              ),
            ],
          ),

          SettingsItem(
            titleIcon: Icons.color_lens,
            titleText: _strings.personalizationSettings,
            children: [
              ListTile(
                title: Text(_strings.languageSettings),
                trailing: DropdownButton(
                  focusNode: _localeFocus,
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  value: _localeProvider.locale,
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onChanged: (Locale? newValue) {
                    _localeProvider.locale = newValue!;
                    _localeFocus.unfocus();
                  },
                  items: AppLocales.all.map((Locale value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value.languageName),
                    );
                  }).toList(),
                ),
              ),

              ListTile(
                title: Text(_strings.themeSettings),
                trailing: DropdownButton(
                  focusNode: _themeFocus,
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  value: _themeProvider.theme,
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onChanged: (ThemeMode? newValue) {
                    _themeProvider.theme = newValue!;
                    _themeFocus.unfocus();
                  },
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(_strings.themeSystem),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(_strings.themeLight),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(_strings.themeDark),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // TODO: add translate
          SettingsItem(
            titleIcon: Icons.notifications,
            titleText: 'Notifications',
            children: [
              SwitchListTile(
                title: Text('Notifications'),
                subtitle: Text('Enable notifications'),
                value: _notificationsEnabled,
                onChanged: (value) async {
                  setState(() => _notificationsEnabled = value);
                  await AppSettings.setNotificationsEnabled(value);
                  await SystemNotificationsService.cancelAll();
                  if (_notificationsEnabled) {
                    await SystemNotificationsService.scheduleDailyNotification(
                      widget.passwordStorage,
                    );
                  }
                },
              ),
              Visibility(
                visible: _notificationsEnabled,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
                  child: SwitchListTile(
                    title: Text('App notifications'),
                    subtitle: Text('Use app notifications only'),
                    value: _onlyAppNotifications,
                    onChanged: (value) async {
                      setState(() => _onlyAppNotifications = value);
                      await AppSettings.setOnlyAppNotifications(value);
                    },
                  ),
                ),
              ),
            ],
          ),

          SettingsItem(
            titleIcon: Icons.info,
            titleText: _strings.aboutApp,
            useBottomPadding: false,
            children: [
              ListTile(
                title: Text(_strings.version),
                subtitle: Text('SaveBox v1.0'),
              ),
              ListTile(
                title: Text(_strings.developer),
                subtitle: Text('Diego'),
              ),
              ListTile(title: Text(_strings.license), subtitle: Text('MIT')),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_strings.clearAllQuestion),
        content: Text(_strings.clearAllQuestionDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.passwordStorage.clear();
              await widget.cardStorage.clear();
              await _verificator.removeToken();
              await MasterPasswordManager.delete();
              if (mounted) {
                SnackBarProvider.showSuccess(context, _strings.allDataCleared);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginWidget()),
                );
              }
            },
            child: Text(_strings.clear, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

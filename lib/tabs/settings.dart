import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safebox/custom_controls/settings_item.dart';
import '../l10n/locale_provider.dart';
import '../l10n/strings.dart';
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
  final PasswordStorage storage;
  final Synchronizer synchronizer;

  const SettingsTab({
    super.key,
    required this.storage,
    required this.synchronizer,
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  static const _defLockOption = LockOption('5 минут', Duration(minutes: 5));
  static const List<LockOption> _lockOptions = [
    LockOption('5 минут', Duration(minutes: 5)),
    LockOption('25 минут', Duration(minutes: 25)),
    LockOption('60 минут', Duration(minutes: 60)),
  ];

  final Verificator _verificator = Verificator();
  late final PasswordStorage _storage;
  late final LocaleProvider _localeProvider;
  late final ThemeProvider _themeProvider;

  late final FocusNode _localeFocus;
  late final FocusNode _themeFocus;

  bool _biometricsEnabled = false;
  bool _autoLockEnabled = false;
  LockOption _autoLockTime = _defLockOption;

  @override
  void initState() {
    super.initState();
    _localeFocus = FocusNode();
    _themeFocus = FocusNode();
    _storage = widget.storage;
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
    _localeProvider.locale = AppSettings.locale;
    _themeProvider.theme = AppSettings.themeMode;

    setState(() {
      _biometricsEnabled = biometricsEnabled;
      _autoLockEnabled = autolockTime != null ? autolockEnabled : false;
      _autoLockTime = _autoLockEnabled
          ? LockOption.parse(autolockTime!)
          : LockOption('', Duration.zero);
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
            Strings.of(context).appSettingsTitle,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          SettingsItem(
            titleIcon: Icons.shield,
            titleText: Strings.of(context).safety,
            children: [
              SwitchListTile(
                title: Text(Strings.of(context).biometrics),
                subtitle: Text(Strings.of(context).biometricsUnlock),
                value: _biometricsEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricsEnabled = value;
                  });
                  AppSettings.setBiometricsEnabled(value);
                },
              ),
              SwitchListTile(
                title: Text(Strings.of(context).autolock),
                subtitle: Text(Strings.of(context).idleBlock),
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
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option.alias),
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
                      labelText: Strings.of(context).timeBeforeBlocking,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SettingsItem(
            titleIcon: Icons.storage,
            titleText: Strings.of(context).storage,
            children: [
              ListTile(
                title: Text(Strings.of(context).synchronization),
                subtitle: Text(Strings.of(context).forceSync),
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
                title: Text(Strings.of(context).exportImport),
                trailing: const Icon(Icons.import_export),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExportImportScreen(storage: widget.storage),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  Strings.of(context).clearData,
                  style: TextStyle(color: Colors.red),
                ),
                trailing: const Icon(Icons.delete, color: Colors.red),
                onTap: _confirmClearData,
              ),
            ],
          ),

          SettingsItem(
            titleIcon: Icons.color_lens,
            titleText: Strings.of(context).personalizationSettings,
            children: [
              ListTile(
                title: Text(Strings.of(context).languageSettings),
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
                title: Text(Strings.of(context).themeSettings),
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
                      child: Text(Strings.of(context).themeSystem),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(Strings.of(context).themeLight),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(Strings.of(context).themeDark),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SettingsItem(
            titleIcon: Icons.info,
            titleText: Strings.of(context).aboutApp,
            useBottomPadding: false,
            children: [
              ListTile(
                title: Text(Strings.of(context).version),
                subtitle: Text('SaveBox v1.0'),
              ),
              ListTile(
                title: Text(Strings.of(context).developer),
                subtitle: Text('Diego'),
              ),
              ListTile(
                title: Text(Strings.of(context).license),
                subtitle: Text('MIT'),
              ),
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
        title: Text(Strings.of(context).clearAllQuestion),
        content: Text(Strings.of(context).clearAllQuestionDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(Strings.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _storage.clear();
              await _verificator.removeToken();
              await MasterPasswordManager.delete();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(Strings.of(context).allDataCleared),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginWidget()),
                );
              }
            },
            child: Text(
              Strings.of(context).clear,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

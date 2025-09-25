import 'package:flutter/material.dart';
import 'package:safebox/custom_controls/login_widget.dart';
import 'package:safebox/models/lock_option.dart';
import 'package:safebox/screen/export_import_screen.dart';
import 'package:safebox/screen/sync_screen.dart';
import 'package:safebox/services/app_settings.dart';
import 'package:safebox/services/auth/master_password_manager.dart';
import 'package:safebox/services/inactivity_manager.dart';
import 'package:safebox/services/security/password_storage.dart';
import 'package:safebox/services/auth/verificator.dart';
import 'package:safebox/services/sync/synchronizer.dart';

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

  bool _biometricsEnabled = false;
  bool _autoLockEnabled = false;
  LockOption _autoLockTime = _defLockOption;

  @override
  void initState() {
    super.initState();
    _storage = widget.storage;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await AppSettings.load();

    final biometricsEnabled = AppSettings.biometricsEnabled;
    final autolockEnabled = AppSettings.autolockEnabled;
    final autolockTime = AppSettings.autolockTime;

    setState(() {
      _biometricsEnabled = biometricsEnabled;
      _autoLockEnabled = autolockTime != null ? autolockEnabled : false;
      _autoLockTime = _autoLockEnabled
          ? LockOption.parse(autolockTime!)
          : _defLockOption;
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
          const Text(
            'Настройки приложения',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield),
              SizedBox(width: 8.0),
              Text(
                'Безопасность',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Биометрия'),
            subtitle: const Text('Разблокировка по лицу или отпечатку'),
            value: _biometricsEnabled,
            onChanged: (value) {
              setState(() {
                _biometricsEnabled = value;
              });
              AppSettings.setBiometricsEnabled(value);
            },
          ),
          SwitchListTile(
            title: const Text('Автоблокировка'),
            subtitle: const Text('Блокировать приложение при бездействии'),
            value: _autoLockEnabled,
            onChanged: (value) async {
              setState(() => _autoLockEnabled = value);
              await AppSettings.setAutolockEnabled(value);
            },
          ),
          Visibility(
            visible: _autoLockEnabled,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
              child: DropdownButtonFormField<LockOption>(
                key: ValueKey(_autoLockTime.minutes),
                initialValue: _autoLockTime,
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
                decoration: const InputDecoration(
                  labelText: 'Время до блокировки',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storage),
              SizedBox(width: 8.0),
              Text('Хранилище', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(),
          ListTile(
            title: const Text('Синхронизация'),
            subtitle: const Text('Принудительно синхронизировать пароли'),
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
            title: Text('Экспорт/Ипорт'),
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
            title: Text('Очистить данные', style: TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.delete, color: Colors.red),
            onTap: _confirmClearData,
          ),
          const SizedBox(height: 8),

          const SizedBox(height: 24),

          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info),
              SizedBox(width: 8.0),
              Text(
                'О приложении',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(),
          const ListTile(title: Text('Версия'), subtitle: Text('SaveBox v1.0')),
          const ListTile(title: Text('Разработчик'), subtitle: Text('Diego')),
          const ListTile(title: Text('Лицензия'), subtitle: Text('MIT')),
        ],
      ),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Очистить всё?'),
        content: const Text(
          'Все сохранённые пароли будут безвозвратно удалены. '
          'Вы уверены?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _storage.clear();
              await _verificator.removeToken();
              await MasterPasswordManager.delete();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Все данные очищены'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginWidget()),
                );
              }
            },
            child: const Text('Очистить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

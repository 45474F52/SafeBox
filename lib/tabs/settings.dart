import 'package:flutter/material.dart';
import 'package:safebox/screen/start_screen.dart';
import 'package:safebox/screen/sync_screen.dart';
import 'package:safebox/services/security/password_storage.dart';
import 'package:safebox/services/security/verificator.dart';
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
  final Verificator _verificator = Verificator();
  late final PasswordStorage _storage;

  bool _biometricsEnabled = false;
  bool _autoLockEnabled = false;
  String _autoLockTime = '1 минута';

  final List<String> _lockOptions = const ['1 минута', '5 минут', '15 минут'];

  @override
  void initState() {
    super.initState();
    _storage = widget.storage;
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
              if (value) {
                _showFeatureNotReady(() {
                  setState(() {
                    _biometricsEnabled = false;
                  });
                });
              }
            },
          ),
          SwitchListTile(
            title: const Text('Автоблокировка'),
            subtitle: const Text('Закрыть приложение при бездействии'),
            value: _autoLockEnabled,
            onChanged: (value) => setState(() => _autoLockEnabled = value),
          ),
          Visibility(
            visible: _autoLockEnabled,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
              child: DropdownButtonFormField<String>(
                key: ValueKey(_autoLockTime),
                initialValue: _autoLockTime,
                items: _lockOptions.map((time) {
                  return DropdownMenuItem(value: time, child: Text(time));
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _autoLockTime = value;
                    });
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
            title: Text('Очистить данные', style: TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.delete, color: Colors.red),
            onTap: _confirmClearData,
          ),

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

  /// Всплывающее уведомление: функция в разработке
  void _showFeatureNotReady([Function? continueWith]) {
    if (mounted) {
      const duration = Duration(seconds: 2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔧 Эта функция ещё в разработке'),
          duration: duration,
        ),
      );
      if (continueWith != null) {
        Future.delayed(const Duration(seconds: 2), () {
          continueWith();
        });
      }
    }
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
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Все данные очищены'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => StartScreen()),
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

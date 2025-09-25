import 'package:flutter/material.dart';
import 'package:safebox/custom_controls/base_screen.dart';
import 'package:safebox/services/passwords_strength/password_security_checker.dart';
import 'package:safebox/services/passwords_strength/strength_level.dart';
import 'package:safebox/services/security/password_storage.dart';

import '../models/password_item.dart';

class PasswordSecurityScreen extends BaseScreen<PasswordSecurityScreen> {
  final PasswordStorage storage;

  const PasswordSecurityScreen({super.key, required this.storage});

  @override
  State<StatefulWidget> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState
    extends BaseScreenState<PasswordSecurityScreen> {
  late Future<List<PasswordItem>> _futurePasswords;
  int _totalCount = 0;
  int _weakCount = 0;

  @override
  void initState() {
    super.initState();
    _futurePasswords = widget.storage.loadActive().then((passwords) {
      setState(() {
        _totalCount = passwords.length;
        _weakCount = passwords.where((item) {
          final strength = PasswordSecurityChecker.check(item.password);
          return strength == StrengthLevel.veryWeak ||
              strength == StrengthLevel.weak;
        }).length;
      });
      return passwords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Статистика безопасности паролей')),
      body: activityDetection(
        FutureBuilder(
          future: _futurePasswords,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Ошибка при загрузке паролей: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData) {
              return Center(child: Text('Нет данных'));
            }
            final passwords = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: passwords.length,
                    itemBuilder: (context, index) {
                      final item = passwords[index];
                      final strength = PasswordSecurityChecker.check(
                        item.password,
                      );

                      final color = _getColorFromStrength(strength);
                      final text = _getTextFromStrength(strength);
                      final progress = _getProgressFromStrength(strength);

                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.url,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              item.password.length >= 6
                                  ? '${item.password.substring(0, 3)}****${item.password.substring(item.password.length - 3)}'
                                  : '****',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: const Color.fromARGB(255, 116, 116, 116),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Text(
                              text,
                              style: TextStyle(fontSize: 14.0, color: color),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => Divider(),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.all(16.0),
                  child: Text(
                    'Проанализировано паролей: $_totalCount\n'
                    'Ненадежных паролей: $_weakCount',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 116, 116, 116),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Color _getColorFromStrength(StrengthLevel strength) {
    switch (strength) {
      case StrengthLevel.veryWeak:
        return Colors.red;
      case StrengthLevel.weak:
        return Colors.orange;
      case StrengthLevel.moderate:
        return Colors.yellow;
      case StrengthLevel.strong:
        return Colors.green;
      case StrengthLevel.veryStrong:
        return const Color.fromARGB(255, 50, 126, 52);
    }
  }

  static String _getTextFromStrength(StrengthLevel strength) {
    switch (strength) {
      case StrengthLevel.veryWeak:
        return 'Крайне ненадежный пароль. Нужно:\n'
            'увеличить длину и добавить спецсимволы';
      case StrengthLevel.weak:
        return 'Слабый пароль. Добавьте:\n'
            'спецсимволы и заглавные буквы';
      case StrengthLevel.moderate:
        return 'Средняя надежность. Рекомендуется:\n'
            'увеличить длину до 16+ символов';
      case StrengthLevel.strong:
        return 'Надежный пароль. Содержит:\n'
            'все типы символов';
      case StrengthLevel.veryStrong:
        return 'Отличный пароль!\n'
            'Соответствует всем требованиям безопасности';
    }
  }

  static double _getProgressFromStrength(StrengthLevel strength) {
    switch (strength) {
      case StrengthLevel.veryWeak:
        return 0.1;
      case StrengthLevel.weak:
        return 0.3;
      case StrengthLevel.moderate:
        return 0.5;
      case StrengthLevel.strong:
        return 0.8;
      case StrengthLevel.veryStrong:
        return 1.0;
    }
  }
}

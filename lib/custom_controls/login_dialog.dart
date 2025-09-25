import 'package:flutter/material.dart';

import '../services/app_settings.dart';
import '../services/auth/biometric_auth.dart';
import '../services/auth/login_attempt_manager.dart';
import '../services/auth/master_password_manager.dart';
import '../services/auth/verificator.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<StatefulWidget> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  late final _biometricAuth = BiometricAuth();
  final _passCtrl = TextEditingController();

  bool _isBiometricAvailable = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Введите мастер-пароль'),
      content: TextField(
        controller: _passCtrl,
        obscureText: true,
        autofocus: true,
        enabled: !_isLoading,
        decoration: InputDecoration(
          labelText: 'Мастер-пароль',
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: _submit, child: const Text('Войти')),
        if (_isBiometricAvailable)
          IconButton(
            onPressed: _handleBiometricLogin,
            icon: const Icon(Icons.fingerprint, size: 36, color: Colors.blue),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvaildable = await _biometricAuth.isBiometricsAvailable();
      final isBiometricsEnabled = await AppSettings.getBiometricsEnabled();
      setState(() {
        _isBiometricAvailable = isAvaildable && isBiometricsEnabled;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _submit() async {
    if (!await LoginAttemptManager.canAttemptLogin()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Слишком много неудачных попыток'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    String password = _passCtrl.text.trim();
    if (password.isEmpty) {
      setState(() {
        _error = 'Введите мастер-пароль';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final verificator = Verificator();
      final isValid = await verificator.verifyMasterPassword(password);
      if (isValid) {
        await LoginAttemptManager.resetAttempts();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        await LoginAttemptManager.incrementAttempts();
        final canAttempt = await LoginAttemptManager.canAttemptLogin();
        if (!canAttempt) {
          await _showLockoutMessage();
        }
        setState(() {
          _error = 'Неверный мастер-пароль';
        });
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    if (!await LoginAttemptManager.canAttemptLogin()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Слишком много неудачных попыток'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isAuthenticated = await _biometricAuth.authenticate();
      if (isAuthenticated) {
        final password = await MasterPasswordManager.get();
        if (password != null) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          _showPasswordDialog();
        }
      } else {
        await LoginAttemptManager.incrementAttempts();
        final canAttempt = await LoginAttemptManager.canAttemptLogin();
        if (!canAttempt) {
          await _showLockoutMessage();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Не удалось подтвердить личность'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Введите мастер-пароль'),
          content: TextField(controller: controller, obscureText: true),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            TextButton(onPressed: _submit, child: Text('Ok')),
          ],
        );
      },
    );
  }

  Future<void> _showLockoutMessage() async {
    final lockoutTime = await LoginAttemptManager.getLockoutTime();
    if (lockoutTime != null) {
      final remainingTime = DateTime.fromMicrosecondsSinceEpoch(
        lockoutTime,
      ).difference(DateTime.now());

      final text = remainingTime.inMinutes <= 0
          ? '${remainingTime.inSeconds} сек.'
          : '${remainingTime.inMinutes} мин.';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Доступ заблокирован на $text'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

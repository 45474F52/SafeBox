import 'package:flutter/material.dart';
import 'package:safebox/screen/home.dart';
import 'package:safebox/services/app_settings.dart';
import 'package:safebox/services/auth/biometric_auth.dart';
import 'package:safebox/services/auth/login_attempt_manager.dart';
import 'package:safebox/services/auth/master_password_manager.dart';
import 'package:safebox/services/auth/verificator.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
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
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      await AppSettings.load();
      final isAvaildable = await _biometricAuth.isBiometricsAvailable();
      setState(() {
        _isBiometricAvailable = isAvaildable && AppSettings.biometricsEnabled;
      });
    } catch (e) {
      print(e.toString());
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(master: password),
              ),
            );
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
        await MasterPasswordManager.save(password);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(master: password),
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
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
              const SizedBox(height: 20.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16.0,
                      children: [
                        ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Войти'),
                        ),
                        if (_isBiometricAvailable)
                          IconButton(
                            onPressed: _handleBiometricLogin,
                            icon: const Icon(
                              Icons.fingerprint,
                              size: 36,
                              color: Colors.blue,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

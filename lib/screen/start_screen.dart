import 'package:flutter/material.dart';
import 'package:safebox/screen/home.dart';
import 'package:safebox/services/security/verificator.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _passCtrl = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(master: password),
            ),
          );
        }
      } else {
        setState(() {
          _error = 'Неверный мастер-пароль';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка при проверке данных: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              const Text(
                'Введите мастер-пароль для входа в приложение',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                autofocus: true,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Мастер-пароль',
                  errorText: _error,
                  suffixIcon: _isLoading
                      ? const CircularProgressIndicator()
                      : null,
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20.0),
              if (!_isLoading)
                ElevatedButton(onPressed: _submit, child: const Text('Войти'))
              else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

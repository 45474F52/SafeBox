import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../screen/home.dart';
import '../services/app_settings.dart';
import '../services/auth/biometric_auth.dart';
import '../services/auth/login_attempt_manager.dart';
import '../services/auth/master_password_manager.dart';
import '../services/auth/verificator.dart';

class LoginWidget extends StatefulWidget {
  final bool asDialogWindow;
  const LoginWidget({super.key, this.asDialogWindow = false});

  @override
  State<StatefulWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
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

  @override
  Widget build(BuildContext context) {
    return widget.asDialogWindow
        ? AlertDialog(
            title: Text(Strings.of(context).login),
            content: TextField(
              controller: _passCtrl,
              obscureText: true,
              autofocus: true,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: Strings.of(context).loginLabel,
                errorText: _error,
              ),
              onSubmitted: (_) => _submit(),
            ),
            actions: [
              TextButton(
                onPressed: _submit,
                child: Text(Strings.of(context).signIn),
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
          )
        : Scaffold(
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
                        labelText: Strings.of(context).loginLabel,
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
                                child: Text(Strings.of(context).signIn),
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

  Future<void> _checkBiometricAvailability() async {
    try {
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
            content: Text(Strings.of(context).attempsErrorMessage),
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
            if (widget.asDialogWindow) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(master: password),
                ),
              );
            }
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
              content: Text(Strings.of(context).notAuthenticatedMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Strings.of(context).errorMsg(e)),
            backgroundColor: Colors.red,
          ),
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

      if (mounted) {
        final text = remainingTime.inMinutes <= 0
            ? '${remainingTime.inSeconds} ${Strings.of(context).secondsPrefix}'
            : '${remainingTime.inMinutes} ${Strings.of(context).minutesPrefix}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Strings.of(context).lockoutMessage(text)),
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
            content: Text(Strings.of(context).attempsErrorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    String password = _passCtrl.text.trim();
    if (password.isEmpty) {
      setState(() {
        _error = Strings.of(context).loginTitle;
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
        if (!mounted) {
          return;
        }
        await Future.wait([
          LoginAttemptManager.resetAttempts(),
          widget.asDialogWindow
              ? Future.value(null)
              : MasterPasswordManager.save(password),
        ]);
        if (!mounted) {
          return;
        }
        if (widget.asDialogWindow) {
          Navigator.of(context).pop();
        } else {
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
          _error = Strings.of(context).invalidPasswordError;
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
          title: Text(Strings.of(context).loginTitle),
          content: TextField(controller: controller, obscureText: true),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(Strings.of(context).cancel),
            ),
            TextButton(
              onPressed: _submit,
              child: Text(Strings.of(context).apply),
            ),
          ],
        );
      },
    );
  }
}

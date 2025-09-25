import 'dart:async';

import 'package:flutter/material.dart';
import 'package:safebox/custom_controls/login_widget.dart';

class InactivityManagerSingleton {
  static final InactivityManagerSingleton _instance =
      InactivityManagerSingleton._internal();
  factory InactivityManagerSingleton() => _instance;

  late Duration _inactivityDuration;
  bool _isEnabled = true;
  Timer? _timer;
  BuildContext? _context;
  late WidgetsBindingObserver _appLifecycleListener;

  InactivityManagerSingleton._internal() {
    _appLifecycleListener = _AppLifecycleListener(this);
    _inactivityDuration = Duration(minutes: 5);
    _isEnabled = true;
  }

  void startMonitoring({required BuildContext context}) {
    _context = context;
    if (_isEnabled) {
      _resetTimer();
    }
    WidgetsBinding.instance.addObserver(_appLifecycleListener);
  }

  void setDuration(Duration duration) {
    if (duration == Duration.zero) {
      _disableLocking();
    } else {
      _inactivityDuration = duration;
      _enableLocking();
    }
  }

  void _enableLocking() {
    _isEnabled = true;
    _resetTimer();
  }

  void _disableLocking() {
    _isEnabled = false;
    _stopTimer();
  }

  void _resetTimer() {
    if (_isEnabled) {
      _stopTimer();
      _timer = Timer(_inactivityDuration, _lockApp);
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _lockApp() {
    if (_context != null && _isEnabled) {
      _showMasterPasswordDialog(_context!);
    }
  }

  void resetOnUserActivity() {
    if (_isEnabled) {
      _resetTimer();
    }
  }

  void _showMasterPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoginWidget(asDialogWindow: true),
    );
  }
}

class _AppLifecycleListener extends WidgetsBindingObserver {
  final InactivityManagerSingleton _manager;

  _AppLifecycleListener(this._manager);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused && _manager._isEnabled) {
      _manager._resetTimer();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:safebox/services/inactivity_manager.dart';

abstract class BaseScreen<T> extends StatefulWidget {
  const BaseScreen({super.key});
}

abstract class BaseScreenState<T extends BaseScreen<T>> extends State<T> {
  late final _inactivityManager = InactivityManagerSingleton();

  @override
  void initState() {
    super.initState();
    _inactivityManager.startMonitoring(context: context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleUserActivity() => _inactivityManager.resetOnUserActivity();

  Widget activityDetection(Widget child) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: handleUserActivity,
    onPanUpdate: (_) => handleUserActivity(),
    child: child,
  );
}

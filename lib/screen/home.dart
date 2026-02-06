import 'dart:async';

import 'package:flutter/material.dart';
import 'package:safebox/l10n/strings.dart';
import 'package:safebox/services/app_settings.dart';
import 'package:safebox/services/notifications/inapp_notifications_manager.dart';
import 'package:safebox/services/storage/bank_cards_storage.dart';
import 'package:safebox/tabs/bank_cards.dart';
import 'package:safebox/custom_controls/base_screen.dart';
import 'package:safebox/services/sync/background_worker.dart';
import 'package:safebox/services/sync/synchronizer.dart';
import 'package:safebox/tabs/passwords.dart';
import 'package:safebox/tabs/pass_gen.dart';
import 'package:safebox/tabs/settings.dart';
import 'package:safebox/services/storage/passwords_storage.dart';

class HomeScreen extends BaseScreen<HomeScreen> {
  final String master;
  const HomeScreen({super.key, required this.master});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseScreenState<HomeScreen> {
  late final _strings = Strings.of(context);
  late final Future<List<Object>> _initFuture;

  late final _tabs = [
    Tab(icon: Icon(Icons.lock), text: _strings.passwordsTab),
    Tab(icon: Icon(Icons.create), text: _strings.generatorTab),
    Tab(icon: Icon(Icons.credit_card), text: _strings.bankCardsTab),
    Tab(icon: Icon(Icons.settings), text: _strings.settingsTab),
  ];

  @override
  void initState() {
    super.initState();

    _initFuture = Future.wait([
      PasswordsStorage.create(widget.master),
      BankCardsStorage.create(widget.master),
      Synchronizer.create(widget.master, _confirmationDialog),
    ], eagerError: true);

    BackgroundWorker.startAnnouncing();
    BackgroundWorker.startResponder();
  }

  @override
  Widget build(BuildContext context) {
    return activityDetection(
      FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: Text(_strings.loadingMsg)),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16.0),
                    Text(_strings.initMsg),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: Text(_strings.error)),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48.0),
                    SizedBox(height: 16.0),
                    Text(_strings.initError, style: TextStyle(fontSize: 16.0)),
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final passwordsStorage = snapshot.data![0] as PasswordsStorage;
          final cardsStorage = snapshot.data![1] as BankCardsStorage;
          final synchronizer = snapshot.data![2] as Synchronizer;

          if (AppSettings.notificationsEnabled) {
            passwordsStorage.loadActive().then((value) async {
              if (await passwordsStorage.needUpdateAny()) {
                if (context.mounted) {
                  InAppNotificationsManager.showNotification(context);
                }
              }
            });
          }

          return DefaultTabController(
            length: _tabs.length,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: _tabs,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ),
              body: TabBarView(
                children: [
                  PasswordsTab(storage: passwordsStorage),
                  PasswordGeneratorTab(),
                  BankCardsTab(storage: cardsStorage),
                  SettingsTab(
                    passwordStorage: passwordsStorage,
                    cardsStorage: cardsStorage,
                    synchronizer: synchronizer,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmationDialog() async {
    bool? result;
    Timer? timer;
    int remainingTime = 15;

    final dialog = showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_strings.syncConfirmDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_strings.syncConfirmDialogQuestion),
            const SizedBox(height: 8.0),
            Text(
              _strings.syncConfirmDialogTimer(
                remainingTime,
                _strings.secondsPrefix,
              ),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_strings.syncConfirmDialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_strings.syncConfirmDialogAccept),
          ),
        ],
      ),
    );

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop(false);
        }
      }
    });

    result = await dialog;
    timer.cancel();

    return result ?? false;
  }
}

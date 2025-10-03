import 'package:flutter/material.dart';
import 'package:safebox/l10n/strings.dart';
import 'package:safebox/services/app_settings.dart';
import 'package:safebox/services/notifications/inapp_notifications_manager.dart';
import 'package:safebox/services/notifications/system_notifications_service.dart';
import 'package:safebox/services/security/bank_card_storage.dart';
import 'package:safebox/tabs/bank_cards.dart';
import '../custom_controls/base_screen.dart';
import '../services/sync/background_worker.dart';
import '../services/sync/synchronizer.dart';
import '../tabs/passwords.dart';
import '../tabs/pass_gen.dart';
import '../tabs/settings.dart';
import '../services/security/password_storage.dart';

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
      PasswordStorage.create(widget.master),
      BankCardStorage.create(widget.master),
      Synchronizer.create(widget.master),
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

          final passwordsStorage = snapshot.data![0] as PasswordStorage;
          final cardsStorage = snapshot.data![1] as BankCardStorage;
          final synchronizer = snapshot.data![2] as Synchronizer;

          if (AppSettings.notificationsEnabled) {
            if (!AppSettings.onlyAppNotifications) {
              SystemNotificationsService.scheduleDailyNotification(
                passwordsStorage,
              );
            }

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
                    cardStorage: cardsStorage,
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
}

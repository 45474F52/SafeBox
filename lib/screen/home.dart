import 'package:flutter/material.dart';
import 'package:safebox/custom_controls/base_screen.dart';
import 'package:safebox/services/sync/background_worker.dart';
import 'package:safebox/services/sync/synchronizer.dart';
import 'package:safebox/tabs/passwords.dart';
import 'package:safebox/tabs/pass_gen.dart';
import 'package:safebox/tabs/settings.dart';

import '../services/security/password_storage.dart';

class HomeScreen extends BaseScreen<HomeScreen> {
  final String master;
  const HomeScreen({super.key, required this.master});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseScreenState<HomeScreen> {
  late final Future<List<Object>> _initFuture;

  @override
  void initState() {
    super.initState();

    _initFuture = Future.wait([
      PasswordStorage.create(widget.master),
      Synchronizer.create(widget.master),
    ]);

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
              appBar: AppBar(title: Text('Загрузка...')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16.0),
                    Text('Инициализация...'),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: Text('ОШИБКА!')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48.0),
                    SizedBox(height: 16.0),
                    Text(
                      'Ошибка инициализации',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final storage = snapshot.data![0] as PasswordStorage;
          final synchronizer = snapshot.data![1] as Synchronizer;

          return DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.lock), text: 'Пароли'),
                    Tab(icon: Icon(Icons.create), text: 'Генератор'),
                    Tab(icon: Icon(Icons.settings), text: 'Настройки'),
                  ],
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ),
              body: TabBarView(
                children: [
                  PasswordsTab(storage: storage),
                  PasswordGeneratorTab(),
                  SettingsTab(storage: storage, synchronizer: synchronizer),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

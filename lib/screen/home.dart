import 'package:flutter/material.dart';
import 'package:safebox/services/sync/background_worker.dart';
import 'package:safebox/services/sync/synchronizer.dart';
import 'package:safebox/tabs/passwords.dart';
import 'package:safebox/tabs/pass_gen.dart';
import 'package:safebox/tabs/settings.dart';

import '../services/security/password_storage.dart';

class HomeScreen extends StatefulWidget {
  final String master;
  const HomeScreen({super.key, required this.master});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Loading...')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16.0),
                  Text('Initialization...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('ERROR!')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48.0),
                  SizedBox(height: 16.0),
                  Text(
                    'Initialization error',
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
    );
  }
}

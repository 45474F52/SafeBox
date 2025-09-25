import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safebox/custom_controls/login_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(SafeBoxApp());
}

class SafeBoxApp extends StatelessWidget {
  const SafeBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeBox',
      themeMode: ThemeMode.system,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const LoginWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}

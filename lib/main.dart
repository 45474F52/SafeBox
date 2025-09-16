import 'package:flutter/material.dart';
import 'package:safebox/screen/start_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeBox',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const StartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

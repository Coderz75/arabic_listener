import 'package:flutter/material.dart';
import 'classes/HomePage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(),
      ),
    );
  }
}


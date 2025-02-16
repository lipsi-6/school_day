import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/time_tracker.dart';
import 'screens/home_screen.dart';
import 'screens/edit_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TimeTracker(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '高级时间管理',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      routes: {
        '/edit': (context) => const EventEditPage(),
      },
    );
  }
}